using Toybox.WatchUi;

class SubMusicConfirmationDelegate extends WatchUi.ConfirmationDelegate {
	
	var d_callback;
	
	function initialize(callback) {
		ConfirmationDelegate.initialize();
		
		d_callback = callback;
	}
	
	function onResponse(response) {
		if ((d_callback == null) 
			|| (response == WatchUi.CONFIRM_NO)) { 
			return;
		}
		
		d_callback.invoke();
	}
}