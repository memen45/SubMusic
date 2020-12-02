using Toybox.WatchUi;

class SubMusicConfirmationDelegate extends WatchUi.ConfirmationDelegate {
	
	var d_callback;
	
	function initialize(callback) {
		ConfirmationDelegate.initialize();
		
		d_callback = callback;
	}
	
	function onResponse(response) {
		if (response != WatchUi.CONFIRM_YES) {
			return;
		}
		d_callback.invoke();
	}
}