package flow;

import flow.typedefs.FBO;

class DoubleFBOReturn {
	public var read:FBO;
	public var write:FBO;

	public function new(fbo1:FBO, fbo2:FBO) {
		read = fbo1;
		write = fbo2;
	}

	@:keep
	public function swap() {
		var temp:FBO = read;
		read = write;
		write = temp;
	}
}
