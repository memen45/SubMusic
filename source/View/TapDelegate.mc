using Toybox.WatchUi;

class TapDelegate extends WatchUi.BehaviorDelegate {
	
	private var d_callback;
	
	function initialize(callback) {
		BehaviorDelegate.initialize();
		
		d_callback = callback;
	}
	
	function onSelect() {
		if (d_callback) {
			d_callback.invoke();
		}
	}
	
	function onBack() {
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
	}
}