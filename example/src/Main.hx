package;

import openfl.events.Event;
import openfl.display.Sprite;
import js.html.PointerEvent;
import js.Browser;
import flow.Flow;

class Main extends Sprite {
	var flow:Flow;

	public function new() {
		super();
		flow = new Flow('assets/LDR_RGB1_0.png');
		stage.addEventListener(Event.ENTER_FRAME, onTick);
		stage.addEventListener(Event.RESIZE, onResize);
		onResize();
	}

	function onTick(e:Event) {
		flow.canvas.onpointerdown = onpointerdown;
		flow.update(false);
	}

	function onResize(e:Event = null) {
		flow.resizeCanvas();
	}

	function onpointerdown(e:PointerEvent) {
		flow.generateColor(e.pointerId);

		flow.canvas.onpointermove = onpointermove;
		flow.canvas.onpointerup = onpointerup;
	}

	function onpointermove(e:PointerEvent) {
		flow.applyForce(e.x, e.y, e.pointerId);
	}

	function onpointerup(e:PointerEvent) {
		flow.canvas.onpointermove = null;
		flow.canvas.onpointerup = null;
	}
}