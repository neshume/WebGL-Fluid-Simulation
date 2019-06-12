package;

import js.html.PointerEvent;
import js.Browser;
import flow.Flow;

class Main {
	public static function main() {
		new Main();
	}

	var flow:Flow;

	public function new() {
		var flow:Flow = new Flow('LDR_RGB1_0.png');
		trace("test");
		Browser.document.body.onpointerdown = onpointerdown;
		Browser.document.body.onpointermove = onpointermove;
	}

	function onpointerdown(e:PointerEvent) {
		// flow.generateColor(e.pointerId);
	}

	function onpointermove(e:PointerEvent) {
		// flow.applyForce(e.x, e.y, e.pointerId);
	}
}
