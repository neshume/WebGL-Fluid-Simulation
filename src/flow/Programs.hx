package flow;

import flow.GLProgram;

class Programs {
	public static var clearProgram:GLProgram;
	public static var colorProgram:GLProgram;
	public static var backgroundProgram:GLProgram;
	public static var displayProgram:GLProgram;
	public static var displayBloomProgram:GLProgram;
	public static var displayShadingProgram:GLProgram;
	public static var displayBloomShadingProgram:GLProgram;
	public static var bloomPrefilterProgram:GLProgram;
	public static var bloomBlurProgram:GLProgram;
	public static var bloomFinalProgram:GLProgram;
	public static var splatProgram:GLProgram;
	public static var advectionProgram:GLProgram;
	public static var divergenceProgram:GLProgram;
	public static var curlProgram:GLProgram;
	public static var vorticityProgram:GLProgram;
	public static var pressureProgram:GLProgram;
	public static var gradienSubtractProgram:GLProgram;

	public static function init() {
		clearProgram = new GLProgram(Shaders.baseVertexShader, Shaders.clearShader);
		colorProgram = new GLProgram(Shaders.baseVertexShader, Shaders.colorShader);
		backgroundProgram = new GLProgram(Shaders.baseVertexShader, Shaders.backgroundShader);
		displayProgram = new GLProgram(Shaders.baseVertexShader, Shaders.displayShader);
		displayBloomProgram = new GLProgram(Shaders.baseVertexShader, Shaders.displayBloomShader);
		displayShadingProgram = new GLProgram(Shaders.baseVertexShader, Shaders.displayShadingShader);
		displayBloomShadingProgram = new GLProgram(Shaders.baseVertexShader, Shaders.displayBloomShadingShader);
		bloomPrefilterProgram = new GLProgram(Shaders.baseVertexShader, Shaders.bloomPrefilterShader);
		bloomBlurProgram = new GLProgram(Shaders.baseVertexShader, Shaders.bloomBlurShader);
		bloomFinalProgram = new GLProgram(Shaders.baseVertexShader, Shaders.bloomFinalShader);
		splatProgram = new GLProgram(Shaders.baseVertexShader, Shaders.splatShader);
		advectionProgram = new GLProgram(Shaders.baseVertexShader,
			Flow.ext.supportLinearFiltering ? Shaders.advectionShader : Shaders.advectionManualFilteringShader);
		divergenceProgram = new GLProgram(Shaders.baseVertexShader, Shaders.divergenceShader);
		curlProgram = new GLProgram(Shaders.baseVertexShader, Shaders.curlShader);
		vorticityProgram = new GLProgram(Shaders.baseVertexShader, Shaders.vorticityShader);
		pressureProgram = new GLProgram(Shaders.baseVertexShader, Shaders.pressureShader);
		gradienSubtractProgram = new GLProgram(Shaders.baseVertexShader, Shaders.gradientSubtractShader);
	}
}
