using Toybox.WatchUi;

class SubMusicServerView extends TextView {
	
    // api access
    private var d_provider = SubMusic.Provider.get();
	
	function initialize() {
	
		var settings = SubMusic.Provider.getProviderSettings();
		var msg = "";
    	
    	msg += settings["api_url"];
    	msg += "\n" + settings["api_usr"] + "\n";
    	
    	if (settings["api_typ"] == ApiStandard.AMPACHE) {
    		msg += "Ampache";
    	} else {
    		msg += "Subsonic";
    	}
    	
		TextView.initialize(msg);
		
		d_provider.setFallback(method(:onError));
		
		d_provider.ping(method(:onPing));
	}
	
	function onPing(response) {
		System.println("onPing(" + response + ")");
    	
    	if (response != null) {
    		TextView.appendText("\nVersion: " + response["version"]);
    	} else {
    		TextView.appendText("Null response from server");
    	}
	}
	
	function onError(error) {
		WatchUi.pushView(new ErrorView(error), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
	}
}
		