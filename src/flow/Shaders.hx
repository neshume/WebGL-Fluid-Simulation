package flow;

import js.Lib;
import js.html.webgl.GL;
import js.html.webgl.Shader;
import openfl.Assets;

class Shaders {
	public static var baseVertexShader:Shader;
	public static var clearShader:Shader;
	public static var colorShader:Shader;
	public static var backgroundShader:Shader;
	public static var displayShader:Shader;
	public static var displayBloomShader:Shader;
	public static var displayShadingShader:Shader;
	public static var displayBloomShadingShader:Shader;
	public static var bloomPrefilterShader:Shader;
	public static var bloomBlurShader:Shader;
	public static var bloomFinalShader:Shader;
	public static var splatShader:Shader;
	public static var advectionManualFilteringShader:Shader;
	public static var advectionShader:Shader;
	public static var divergenceShader:Shader;
	public static var curlShader:Shader;
	public static var vorticityShader:Shader;
	public static var pressureShader:Shader;
	public static var gradientSubtractShader:Shader;

	public static function init() {
		baseVertexShader = compileShader(GL.VERTEX_SHADER, "baseVertexShader");
		clearShader = compileShader(GL.FRAGMENT_SHADER, "clearShader");
		colorShader = compileShader(GL.FRAGMENT_SHADER, "colorShader");
		backgroundShader = compileShader(GL.FRAGMENT_SHADER, "backgroundShader");
		displayShader = compileShader(GL.FRAGMENT_SHADER, "displayShader");
		displayBloomShader = compileShader(GL.FRAGMENT_SHADER, "displayBloomShader");
		displayShadingShader = compileShader(GL.FRAGMENT_SHADER, "displayShadingShader");
		displayBloomShadingShader = compileShader(GL.FRAGMENT_SHADER, "displayBloomShadingShader");
		bloomPrefilterShader = compileShader(GL.FRAGMENT_SHADER, "bloomPrefilterShader");
		bloomBlurShader = compileShader(GL.FRAGMENT_SHADER, "bloomBlurShader");
		bloomFinalShader = compileShader(GL.FRAGMENT_SHADER, "bloomFinalShader");
		splatShader = compileShader(GL.FRAGMENT_SHADER, "splatShader");
		advectionManualFilteringShader = compileShader(GL.FRAGMENT_SHADER, "advectionManualFilteringShader");
		advectionShader = compileShader(GL.FRAGMENT_SHADER, "advectionShader");
		divergenceShader = compileShader(GL.FRAGMENT_SHADER, "divergenceShader");
		curlShader = compileShader(GL.FRAGMENT_SHADER, "curlShader");
		vorticityShader = compileShader(GL.FRAGMENT_SHADER, "vorticityShader");
		pressureShader = compileShader(GL.FRAGMENT_SHADER, "pressureShader");
		gradientSubtractShader = compileShader(GL.FRAGMENT_SHADER, "gradientSubtractShader");
	}

	static function compileShader(type:Int, name:String):Shader {
		var shaderStr:String = Assets.getText("shaders/" + name + ".glsl");
		// var shaderStr:String = Lib.require("shaders/" + name + ".glsl");
		var shader:Shader = Flow.gl.createShader(type);
		Flow.gl.shaderSource(shader, shaderStr);
		Flow.gl.compileShader(shader);

		if (!Flow.gl.getShaderParameter(shader, GL.COMPILE_STATUS))
			throw Flow.gl.getShaderInfoLog(shader);

		return shader;
	};
}
