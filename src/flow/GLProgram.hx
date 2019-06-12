package flow;

import js.html.webgl.Program;
import js.html.webgl.Shader;
import js.html.webgl.GL;
import js.html.webgl.UniformLocation;

class GLProgram {
	public var uniforms:Dynamic;
	public var program:Program;

	public function new(vertexShader:Shader, fragmentShader:Shader) {
		uniforms = {};
		program = Flow.gl.createProgram();

		Flow.gl.attachShader(program, vertexShader);
		Flow.gl.attachShader(program, fragmentShader);
		Flow.gl.linkProgram(program);

		if (!Flow.gl.getProgramParameter(program, GL.LINK_STATUS))
			throw Flow.gl.getProgramInfoLog(program);

		var uniformCount = Flow.gl.getProgramParameter(program, GL.ACTIVE_UNIFORMS);
		for (i in 0...uniformCount) {
			var uniformName:String = Flow.gl.getActiveUniform(program, i).name;
			Reflect.setProperty(uniforms, uniformName, Flow.gl.getUniformLocation(program, uniformName));
		}
	}

	public function bind() {
		Flow.gl.useProgram(program);
	}
}
