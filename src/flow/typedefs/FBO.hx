package flow.typedefs;

import js.html.webgl.Texture;
import js.html.webgl.Framebuffer;

typedef FBO = {
	texture:Texture,
	?fbo:Framebuffer,
	width:Int,
	height:Int,
	attach:(id:Int) -> Int
}
