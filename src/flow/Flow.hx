package flow;

import js.Lib;
import js.Browser;
import js.html.Image;
import js.lib.Uint8Array;
import js.html.webgl.GL2;
import js.html.CanvasElement;
import flow.typedefs.FBO;
import flow.typedefs.Ext;
import flow.typedefs.Config;
import flow.typedefs.PointerPrototype;
import flow.typedefs.Size;
import flow.typedefs.Format;
import js.html.webgl.GL;
import js.html.webgl.Texture;

class Flow {
	public static var gl:GL;
	public static var ext:Ext;
	public static var config:Config;

	public var canvas:CanvasElement;
	public var ditheringTexture:{
		texture:Texture,
		width:Int,
		height:Int,
		attach:(id:Int) -> Int
	}

	public static var simWidth:Dynamic;
	public static var simHeight:Dynamic;
	public static var dyeWidth:Dynamic;
	public static var dyeHeight:Dynamic;
	public static var density:Dynamic;
	public static var velocity:Dynamic;
	public static var divergence:FBO;
	public static var curl:FBO;
	public static var pressure:Dynamic;
	public static var bloom:FBO;
	public static var bloomFramebuffers:Array<FBO>;

	var lastColorChangeTime:Float;
	var pointers:Array<PointerPrototype>;
	var splatStack:Array<Int>;
	var flowUtils:FlowUtils;

	public function new(ditheringImage:String) {
		bloomFramebuffers = [];
		pointers = [];
		splatStack = [];

		canvas = Browser.document.createCanvasElement();
		canvas.id = "flow";
		Browser.document.body.appendChild(canvas);

		canvas.width = canvas.clientWidth;
		canvas.height = canvas.clientHeight;

		config = {
			SIM_RESOLUTION: 128,
			DYE_RESOLUTION: 512,
			DENSITY_DISSIPATION: 0.97,
			VELOCITY_DISSIPATION: 0.98,
			PRESSURE_DISSIPATION: 0.8,
			PRESSURE_ITERATIONS: 20,
			CURL: 30,
			SPLAT_RADIUS: 0.5,
			SHADING: true,
			COLORFUL: true,
			PAUSED: false,
			BACK_COLOR: {red: 0, green: 0, blue: 0},
			TRANSPARENT: false,
			BLOOM: true,
			BLOOM_ITERATIONS: 8,
			BLOOM_RESOLUTION: 256,
			BLOOM_INTENSITY: 0.8,
			BLOOM_THRESHOLD: 0.6,
			BLOOM_SOFT_KNEE: 0.7
		}

		var context:{gl:GL, ext:Ext} = getWebGLContext(canvas);
		gl = context.gl;
		Flow.ext = context.ext;

		if (isMobile())
			Flow.config.SHADING = false;
		if (!Flow.ext.supportLinearFiltering) {
			Flow.config.SHADING = false;
			Flow.config.BLOOM = false;
		}

		for (i in 0...10) {
			pointers.push({
				id: i,
				x: 0,
				y: 0,
				dx: 0,
				dy: 0,
				down: false,
				moved: false,
				color: null,
				strength: 5
			});
		}

		lastColorChangeTime = Date.now().getTime();
		ditheringTexture = createTextureAsync(ditheringImage);

		flowUtils = new FlowUtils(canvas, gl);

		Shaders.init();
		Programs.init();

		initFramebuffers();
	}

	function createTextureAsync(url:String) {
		var texture = gl.createTexture();
		gl.bindTexture(GL.TEXTURE_2D, texture);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
		gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGB, 1, 1, 0, GL.RGB, GL.UNSIGNED_BYTE, new Uint8Array([255, 255, 255]));

		var obj:FBO = {
			texture: texture,
			width: 1,
			height: 1,
			attach: (id) -> {
				gl.activeTexture(GL.TEXTURE0 + id);
				gl.bindTexture(GL.TEXTURE_2D, texture);
				return id;
			}
		};

		var image = new Image();
		image.onload = () -> {
			obj.width = image.width;
			obj.height = image.height;
			gl.bindTexture(GL.TEXTURE_2D, texture);
			gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGB, GL.RGB, GL.UNSIGNED_BYTE, image);
		};
		image.src = url;

		return obj;
	}

	function getWebGLContext(canvas):{gl:GL, ext:Ext} {
		var params = {
			alpha: true,
			depth: false,
			stencil: false,
			antialias: false,
			preserveDrawingBuffer: false
		};

		gl = canvas.getContext('webgl2', params);
		var isWebGL2 = gl != null;
		if (!isWebGL2) {
			gl = canvas.getContext('webgl', params);
		}
		if (gl == null) {
			gl = canvas.getContext('experimental-webgl', params);
		}

		var halfFloat;
		var supportLinearFiltering;
		if (isWebGL2) {
			gl.getExtension('EXT_color_buffer_float');
			supportLinearFiltering = gl.getExtension('OES_texture_float_linear');
		} else {
			halfFloat = gl.getExtension('OES_texture_half_float');
			supportLinearFiltering = gl.getExtension('OES_texture_half_float_linear');
		}

		gl.clearColor(0.0, 0.0, 0.0, 1.0);

		// var halfFloatTexType = isWebGL2 ? GL2.HALF_FLOAT : halfFloat.HALF_FLOAT_OES;
		var halfFloatTexType = GL2.HALF_FLOAT;
		var formatRGBA:Format;
		var formatRG:Format;
		var formatR:Format;

		if (isWebGL2) {
			formatRGBA = getSupportedFormat(gl, GL2.RGBA16F, GL.RGBA, halfFloatTexType);
			formatRG = getSupportedFormat(gl, GL2.RG16F, GL2.RG, halfFloatTexType);
			formatR = getSupportedFormat(gl, GL2.R16F, GL2.RED, halfFloatTexType);
		} else {
			formatRGBA = getSupportedFormat(gl, GL.RGBA, GL.RGBA, halfFloatTexType);
			formatRG = getSupportedFormat(gl, GL.RGBA, GL.RGBA, halfFloatTexType);
			formatR = getSupportedFormat(gl, GL.RGBA, GL.RGBA, halfFloatTexType);
		}

		return {
			gl: gl,
			ext: {
				formatRGBA: formatRGBA,
				formatRG: formatRG,
				formatR: formatR,
				halfFloatTexType: halfFloatTexType,
				supportLinearFiltering: supportLinearFiltering
			}
		};
	}

	function getSupportedFormat(gl:GL, internalFormat:Int, format:Int, type:Int) {
		if (!supportRenderTextureFormat(gl, internalFormat, format, type)) {
			switch (internalFormat) {
				case GL2.R16F:
					return getSupportedFormat(gl, GL2.RG16F, GL2.RG, type);
				case GL2.RG16F:
					return getSupportedFormat(gl, GL2.RGBA16F, GL2.RGBA, type);
				default:
					return null;
			}
		}

		return {
			internalFormat: internalFormat,
			format: format
		}
	}

	function supportRenderTextureFormat(gl:GL, internalFormat:Int, format:Int, type:Int) {
		var texture = gl.createTexture();
		gl.bindTexture(GL.TEXTURE_2D, texture);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		gl.texImage2D(GL.TEXTURE_2D, 0, internalFormat, 4, 4, 0, format, type, null);

		var fbo = gl.createFramebuffer();
		gl.bindFramebuffer(GL.FRAMEBUFFER, fbo);
		gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);

		var status = gl.checkFramebufferStatus(GL.FRAMEBUFFER);
		if (status != GL.FRAMEBUFFER_COMPLETE)
			return false;
		return true;
	}

	function isMobile() {
		return false; // ~/Mobi|Android/i.test(navigator.userAgent);
	}

	public function resizeCanvas() {
		if (canvas.width != canvas.clientWidth || canvas.height != canvas.clientHeight) {
			canvas.width = canvas.clientWidth;
			canvas.height = canvas.clientHeight;
			initFramebuffers();
		}
	}

	public function generateColor(index:Int = 0, hue:Null<Float> = null, multiplier:Float = 0.15) {
		pointers[index].color = flowUtils.generateColor(hue, multiplier);
	}

	public function setStrength(index:Int = 0, strength:Float) {
		pointers[index].strength = strength;
	}

	public function applyForce(x:Float, y:Float, index:Int = 0, dx:Null<Float> = null, dy:Null<Float> = null) {
		var pointer:PointerPrototype = pointers[index];
		pointer.moved = true; // pointer.down;
		if (dx == null)
			pointer.dx = (x - pointer.x) * pointer.strength;
		else
			pointer.dx = dx;

		if (dy == null)
			pointer.dy = (y - pointer.y) * pointer.strength;
		else
			pointer.dy = dy;

		pointer.x = x;
		pointer.y = y;
	}

	public function update(paused:Bool = false) {
		input();
		if (!paused)
			step(0.016);
		render(null);
	}

	public function input() {
		if (splatStack.length > 0)
			flowUtils.multipleSplats(splatStack.pop());

		for (p in pointers) {
			// const p = pointers[i];
			if (p.moved) {
				flowUtils.splat(p.x, p.y, p.dx, p.dy, p.color);
				p.moved = false;
			}
		}

		if (!Flow.config.COLORFUL)
			return;

		if (lastColorChangeTime + 100 < Date.now().getTime()) {
			lastColorChangeTime = Date.now().getTime();
			// for (p in pointers) {
			//	p.color = flowUtils.generateColor();
			// }
		}
	}

	public function step(dt:Float) {
		gl.disable(GL.BLEND);
		gl.viewport(0, 0, simWidth, simHeight);

		Programs.curlProgram.bind();
		gl.uniform2f(Programs.curlProgram.uniforms.texelSize, 1.0 / simWidth, 1.0 / simHeight);
		gl.uniform1i(Programs.curlProgram.uniforms.uVelocity, velocity.read.attach(0));
		flowUtils.blit(curl.fbo);

		Programs.vorticityProgram.bind();
		gl.uniform2f(Programs.vorticityProgram.uniforms.texelSize, 1.0 / simWidth, 1.0 / simHeight);
		gl.uniform1i(Programs.vorticityProgram.uniforms.uVelocity, velocity.read.attach(0));
		gl.uniform1i(Programs.vorticityProgram.uniforms.uCurl, curl.attach(1));
		gl.uniform1f(Programs.vorticityProgram.uniforms.curl, Flow.config.CURL);
		gl.uniform1f(Programs.vorticityProgram.uniforms.dt, dt);
		flowUtils.blit(velocity.write.fbo);
		velocity.swap();

		Programs.divergenceProgram.bind();
		gl.uniform2f(Programs.divergenceProgram.uniforms.texelSize, 1.0 / simWidth, 1.0 / simHeight);
		gl.uniform1i(Programs.divergenceProgram.uniforms.uVelocity, velocity.read.attach(0));
		flowUtils.blit(divergence.fbo);

		Programs.clearProgram.bind();
		gl.uniform1i(Programs.clearProgram.uniforms.uTexture, pressure.read.attach(0));
		gl.uniform1f(Programs.clearProgram.uniforms.value, Flow.config.PRESSURE_DISSIPATION);
		flowUtils.blit(pressure.write.fbo);
		pressure.swap();

		Programs.pressureProgram.bind();
		gl.uniform2f(Programs.pressureProgram.uniforms.texelSize, 1.0 / simWidth, 1.0 / simHeight);
		gl.uniform1i(Programs.pressureProgram.uniforms.uDivergence, divergence.attach(0));
		for (i in 0...Flow.config.PRESSURE_ITERATIONS) {
			gl.uniform1i(Programs.pressureProgram.uniforms.uPressure, pressure.read.attach(1));
			flowUtils.blit(pressure.write.fbo);
			pressure.swap();
		}

		Programs.gradienSubtractProgram.bind();
		gl.uniform2f(Programs.gradienSubtractProgram.uniforms.texelSize, 1.0 / simWidth, 1.0 / simHeight);
		gl.uniform1i(Programs.gradienSubtractProgram.uniforms.uPressure, pressure.read.attach(0));
		gl.uniform1i(Programs.gradienSubtractProgram.uniforms.uVelocity, velocity.read.attach(1));
		flowUtils.blit(velocity.write.fbo);
		velocity.swap();

		Programs.advectionProgram.bind();
		gl.uniform2f(Programs.advectionProgram.uniforms.texelSize, 1.0 / simWidth, 1.0 / simHeight);
		if (!Flow.ext.supportLinearFiltering)
			gl.uniform2f(Programs.advectionProgram.uniforms.dyeTexelSize, 1.0 / simWidth, 1.0 / simHeight);
		var velocityId = velocity.read.attach(0);
		gl.uniform1i(Programs.advectionProgram.uniforms.uVelocity, velocityId);
		gl.uniform1i(Programs.advectionProgram.uniforms.uSource, velocityId);
		gl.uniform1f(Programs.advectionProgram.uniforms.dt, dt);
		gl.uniform1f(Programs.advectionProgram.uniforms.dissipation, Flow.config.VELOCITY_DISSIPATION);
		flowUtils.blit(velocity.write.fbo);
		velocity.swap();

		gl.viewport(0, 0, dyeWidth, dyeHeight);

		if (!Flow.ext.supportLinearFiltering)
			gl.uniform2f(Programs.advectionProgram.uniforms.dyeTexelSize, 1.0 / dyeWidth, 1.0 / dyeHeight);
		gl.uniform1i(Programs.advectionProgram.uniforms.uVelocity, velocity.read.attach(0));
		gl.uniform1i(Programs.advectionProgram.uniforms.uSource, density.read.attach(1));
		gl.uniform1f(Programs.advectionProgram.uniforms.dissipation, Flow.config.DENSITY_DISSIPATION);
		flowUtils.blit(density.write.fbo);
		density.swap();
	}

	public function render(target:Dynamic = null) {
		if (Flow.config.BLOOM)
			flowUtils.applyBloom(density.read, bloom);

		if (target == null || !Flow.config.TRANSPARENT) {
			gl.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA);
			gl.enable(GL.BLEND);
		} else {
			gl.disable(GL.BLEND);
		}

		var width = target == null ? gl.drawingBufferWidth : dyeWidth;
		var height = target == null ? gl.drawingBufferHeight : dyeHeight;

		gl.viewport(0, 0, width, height);

		if (!Flow.config.TRANSPARENT) {
			Programs.colorProgram.bind();
			var bc = Flow.config.BACK_COLOR;
			gl.uniform4f(Programs.colorProgram.uniforms.color, bc.red / 255, bc.green / 255, bc.blue / 255, 0);
			flowUtils.blit(target);
		}

		if (target == null && Flow.config.TRANSPARENT) {
			Programs.backgroundProgram.bind();
			gl.uniform1f(Programs.backgroundProgram.uniforms.aspectRatio, canvas.width / canvas.height);
			flowUtils.blit(null);
		}

		if (Flow.config.SHADING) {
			var program = Flow.config.BLOOM ? Programs.displayBloomShadingProgram : Programs.displayShadingProgram;
			program.bind();
			gl.uniform2f(program.uniforms.texelSize, 1.0 / width, 1.0 / height);
			gl.uniform1i(program.uniforms.uTexture, density.read.attach(0));
			if (Flow.config.BLOOM) {
				gl.uniform1i(program.uniforms.uBloom, bloom.attach(1));
				gl.uniform1i(program.uniforms.uDithering, ditheringTexture.attach(2));
				var scale = getTextureScale(ditheringTexture, width, height);
				gl.uniform2f(program.uniforms.ditherScale, scale.x, scale.y);
			}
		} else {
			var program = Flow.config.BLOOM ? Programs.displayBloomProgram : Programs.displayProgram;
			program.bind();
			gl.uniform1i(program.uniforms.uTexture, density.read.attach(0));
			if (Flow.config.BLOOM) {
				gl.uniform1i(program.uniforms.uBloom, bloom.attach(1));
				gl.uniform1i(program.uniforms.uDithering, ditheringTexture.attach(2));
				var scale = getTextureScale(ditheringTexture, width, height);
				gl.uniform2f(program.uniforms.ditherScale, scale.x, scale.y);
			}
		}

		flowUtils.blit(target);
	}

	function getTextureScale(texture:{width:Int, height:Int}, width:Int, height:Int) {
		return {
			x: width / texture.width,
			y: height / texture.height
		};
	}

	function initBloomFramebuffers() {
		var res:Size = getResolution(Flow.config.BLOOM_RESOLUTION);

		var texType = Flow.ext.halfFloatTexType;
		var rgba = Flow.ext.formatRGBA;
		var filtering = Flow.ext.supportLinearFiltering ? GL.LINEAR : GL.NEAREST;

		bloom = createFBO(res.width, res.height, rgba.internalFormat, rgba.format, texType, filtering);

		bloomFramebuffers.splice(0, bloomFramebuffers.length);
		for (i in 0...Flow.config.BLOOM_ITERATIONS) {
			var width = res.width >> (i + 1);
			var height = res.height >> (i + 1);

			if (width < 2 || height < 2)
				break;

			var fbo:FBO = createFBO(width, height, rgba.internalFormat, rgba.format, texType, filtering);
			bloomFramebuffers.push(fbo);
		}
	}

	function initFramebuffers() {
		var simRes = getResolution(Flow.config.SIM_RESOLUTION);
		var dyeRes = getResolution(Flow.config.DYE_RESOLUTION);

		simWidth = simRes.width;
		simHeight = simRes.height;
		dyeWidth = dyeRes.width;
		dyeHeight = dyeRes.height;

		var texType = Flow.ext.halfFloatTexType;
		var rgba = Flow.ext.formatRGBA;
		var rg = Flow.ext.formatRG;
		var r = Flow.ext.formatR;
		var filtering = Flow.ext.supportLinearFiltering ? GL.LINEAR : GL.NEAREST;

		if (density == null)
			density = createDoubleFBO(dyeWidth, dyeHeight, rgba.internalFormat, rgba.format, texType, filtering);
		else
			density = resizeDoubleFBO(density, dyeWidth, dyeHeight, rgba.internalFormat, rgba.format, texType, filtering);

		if (velocity == null)
			velocity = createDoubleFBO(simWidth, simHeight, rg.internalFormat, rg.format, texType, filtering);
		else
			velocity = resizeDoubleFBO(velocity, simWidth, simHeight, rg.internalFormat, rg.format, texType, filtering);

		divergence = createFBO(simWidth, simHeight, r.internalFormat, r.format, texType, GL.NEAREST);
		curl = createFBO(simWidth, simHeight, r.internalFormat, r.format, texType, GL.NEAREST);
		pressure = createDoubleFBO(simWidth, simHeight, r.internalFormat, r.format, texType, GL.NEAREST);

		initBloomFramebuffers();
	}

	function createDoubleFBO(w:Int, h:Int, internalFormat, format, type, param):DoubleFBOReturn {
		var fbo1:FBO = createFBO(w, h, internalFormat, format, type, param);
		var fbo2:FBO = createFBO(w, h, internalFormat, format, type, param);

		return new DoubleFBOReturn(fbo1, fbo2);
	}

	function resizeDoubleFBO(target:DoubleFBOReturn, w:Int, h:Int, internalFormat, format, type, param):DoubleFBOReturn {
		target.read = resizeFBO(target.read, w, h, internalFormat, format, type, param);
		target.write = createFBO(w, h, internalFormat, format, type, param);
		return target;
	}

	function resizeFBO(target, w, h, internalFormat, format, type, param) {
		var newFBO:FBO = createFBO(w, h, internalFormat, format, type, param);
		Programs.clearProgram.bind();
		gl.uniform1i(Programs.clearProgram.uniforms.uTexture, target.attach(0));
		gl.uniform1f(Programs.clearProgram.uniforms.value, 1);
		flowUtils.blit(newFBO.fbo);
		return newFBO;
	}

	function createFBO(w:Int, h:Int, internalFormat:Int, format:Int, type:Int, param:Int):FBO {
		gl.activeTexture(GL.TEXTURE0);
		var texture = gl.createTexture();
		gl.bindTexture(GL.TEXTURE_2D, texture);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, param);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, param);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		gl.texImage2D(GL.TEXTURE_2D, 0, internalFormat, w, h, 0, format, type, null);

		var fbo = gl.createFramebuffer();
		gl.bindFramebuffer(GL.FRAMEBUFFER, fbo);
		gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);
		gl.viewport(0, 0, w, h);
		gl.clear(GL.COLOR_BUFFER_BIT);

		return {
			texture: texture,
			fbo: fbo,
			width: w,
			height: h,
			attach: (id:Int) -> {
				gl.activeTexture(GL.TEXTURE0 + id);
				gl.bindTexture(GL.TEXTURE_2D, texture);
				return id;
			}
		};
	}

	function getResolution(resolution:Int):Size {
		var aspectRatio:Float = gl.drawingBufferWidth / gl.drawingBufferHeight;
		if (aspectRatio < 1)
			aspectRatio = 1.0 / aspectRatio;

		var max:Int = Math.round(resolution * aspectRatio);
		var min:Int = Math.round(resolution);

		if (gl.drawingBufferWidth > gl.drawingBufferHeight)
			return {width: max, height: min};
		else
			return {width: min, height: max};
	}
}
