package flow;

import js.html.webgl.Framebuffer;
import js.lib.Float32Array;
import js.lib.Uint16Array;
import js.html.webgl.GL;
import js.html.CanvasElement;
import flow.typedefs.Size;
import flow.typedefs.FlowColor;

class FlowUtils {
	var canvas:CanvasElement;
	var gl:GL;

	public function new(canvas:CanvasElement, gl:GL) {
		this.canvas = canvas;
		this.gl = gl;

		gl.bindBuffer(GL.ARRAY_BUFFER, gl.createBuffer());
		gl.bufferData(GL.ARRAY_BUFFER, new Float32Array([-1, -1, -1, 1, 1, 1, 1, -1]), GL.STATIC_DRAW);
		gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, gl.createBuffer());
		gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, new Uint16Array([0, 1, 2, 0, 2, 3]), GL.STATIC_DRAW);
		gl.vertexAttribPointer(0, 2, GL.FLOAT, false, 0, 0);
		gl.enableVertexAttribArray(0);
	}

	public function blit(destination:Framebuffer) {
		gl.bindFramebuffer(GL.FRAMEBUFFER, destination);
		gl.drawElements(GL.TRIANGLES, 6, GL.UNSIGNED_SHORT, 0);
	}

	public function multipleSplats(amount:Int) {
		for (i in 0...amount) {
			var color:FlowColor = generateColor();
			color.red = color.red * 10.0;
			color.green = color.green * 10.0;
			color.blue = color.blue * 10.0;
			var x = canvas.width * Math.random();
			var y = canvas.height * Math.random();
			var dx = 1000 * (Math.random() - 0.5);
			var dy = 1000 * (Math.random() - 0.5);
			splat(x, y, dx, dy, color);
		}
	}

	public function generateColor(hue:Null<Float> = null, multiplier:Float = 0.15) {
		if (hue == null)
			hue = Math.random();
		var c:FlowColor = HSVtoRGB(hue, 1.0, 1.0);
		c.red = c.red * multiplier;
		c.green = c.green * multiplier;
		c.blue = c.blue * multiplier;
		return c;
	}

	function HSVtoRGB(h:Float, s:Float, v:Float):FlowColor {
		var color:FlowColor = {red: 0, green: 0, blue: 0};
		var i:Int = 0;
		var f:Float = 0;
		var p:Float = 0;
		var q:Float = 0;
		var t:Float = 0;

		i = Math.floor(h * 6);
		f = h * 6 - i;
		p = v * (1 - s);
		q = v * (1 - f * s);
		t = v * (1 - (1 - f) * s);

		var m:Int = i % 6;
		switch m {
			case 0:
				color.red = v;
				color.green = t;
				color.blue = p;
			case 1:
				color.red = q;
				color.green = v;
				color.blue = p;
			case 2:
				color.red = p;
				color.green = v;
				color.blue = t;
			case 3:
				color.red = p;
				color.green = q;
				color.blue = v;
			case 4:
				color.red = t;
				color.green = p;
				color.blue = v;
			case 5:
				color.red = v;
				color.green = p;
				color.blue = q;
		}

		return color;
	}

	public function splat(x:Float, y:Float, dx:Float, dy:Float, color:FlowColor) {
		gl.viewport(0, 0, Flow.simWidth, Flow.simHeight);
		Programs.splatProgram.bind();
		gl.uniform1i(Programs.splatProgram.uniforms.uTarget, Flow.velocity.read.attach(0));
		gl.uniform1f(Programs.splatProgram.uniforms.aspectRatio, canvas.width / canvas.height);
		gl.uniform2f(Programs.splatProgram.uniforms.point, x / canvas.width, 1.0 - y / canvas.height);
		gl.uniform3f(Programs.splatProgram.uniforms.color, dx, -dy, 1.0);
		gl.uniform1f(Programs.splatProgram.uniforms.radius, Flow.config.SPLAT_RADIUS / 100.0);
		blit(Flow.velocity.write.fbo);
		Flow.velocity.swap();

		gl.viewport(0, 0, Flow.dyeWidth, Flow.dyeHeight);
		gl.uniform1i(Programs.splatProgram.uniforms.uTarget, Flow.density.read.attach(0));
		gl.uniform3f(Programs.splatProgram.uniforms.color, color.red, color.green, color.blue);
		blit(Flow.density.write.fbo);
		Flow.density.swap();
	}

	public function applyBloom(source:Dynamic, destination:Dynamic) {
		if (Flow.bloomFramebuffers.length < 2)
			return;

		var last = destination;

		gl.disable(GL.BLEND);
		Programs.bloomPrefilterProgram.bind();
		var knee = Flow.config.BLOOM_THRESHOLD * Flow.config.BLOOM_SOFT_KNEE + 0.0001;
		var curve0 = Flow.config.BLOOM_THRESHOLD - knee;
		var curve1 = knee * 2;
		var curve2 = 0.25 / knee;
		gl.uniform3f(Programs.bloomPrefilterProgram.uniforms.curve, curve0, curve1, curve2);
		gl.uniform1f(Programs.bloomPrefilterProgram.uniforms.threshold, Flow.config.BLOOM_THRESHOLD);
		gl.uniform1i(Programs.bloomPrefilterProgram.uniforms.uTexture, source.attach(0));
		gl.viewport(0, 0, last.width, last.height);
		blit(last.fbo);

		Programs.bloomBlurProgram.bind();
		for (i in 0...Flow.bloomFramebuffers.length) {
			var dest = Flow.bloomFramebuffers[i];
			gl.uniform2f(Programs.bloomBlurProgram.uniforms.texelSize, 1.0 / last.width, 1.0 / last.height);
			gl.uniform1i(Programs.bloomBlurProgram.uniforms.uTexture, last.attach(0));
			gl.viewport(0, 0, dest.width, dest.height);
			blit(dest.fbo);
			last = dest;
		}

		gl.blendFunc(GL.ONE, GL.ONE);
		gl.enable(GL.BLEND);

		// or (let i = bloomFramebuffers.length - 2; i >= 0; i--) {
		var i:Int = Flow.bloomFramebuffers.length - 2;
		while (i >= 0) {
			var baseTex = Flow.bloomFramebuffers[i];
			gl.uniform2f(Programs.bloomBlurProgram.uniforms.texelSize, 1.0 / last.width, 1.0 / last.height);
			gl.uniform1i(Programs.bloomBlurProgram.uniforms.uTexture, last.attach(0));
			gl.viewport(0, 0, baseTex.width, baseTex.height);
			blit(baseTex.fbo);
			last = baseTex;
			i--;
		}

		gl.disable(GL.BLEND);
		Programs.bloomFinalProgram.bind();
		gl.uniform2f(Programs.bloomFinalProgram.uniforms.texelSize, 1.0 / last.width, 1.0 / last.height);
		gl.uniform1i(Programs.bloomFinalProgram.uniforms.uTexture, last.attach(0));
		gl.uniform1f(Programs.bloomFinalProgram.uniforms.intensity, Flow.config.BLOOM_INTENSITY);
		gl.viewport(0, 0, destination.width, destination.height);
		blit(destination.fbo);
	}
}
