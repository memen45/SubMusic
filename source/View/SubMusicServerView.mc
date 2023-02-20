using Toybox.WatchUi;
using SubMusic.Storage;

class SubMusicServerView extends TextView {
	
    // api access
    private var d_provider = SubMusic.Provider.get();
	
	function initialize() {
	
		var settings = SubMusic.Provider.getProviderSettings();
		var msg = "";
    	
    	msg += settings["api_url"];
    	msg += "\n" + settings["api_usr"] + "\n";
    	
		var api_map = {
			Storage.ApiStandard.AMPACHE 	=> WatchUi.loadResource(Rez.Strings.ApiStandardAmpache),
			Storage.ApiStandard.SUBSONIC 	=> WatchUi.loadResource(Rez.Strings.ApiStandardSubsonic),
			Storage.ApiStandard.PLEX 		=> WatchUi.loadResource(Rez.Strings.ApiStandardPlex),
		};
		msg += api_map[settings["api_typ"]];
    	
		TextView.initialize(msg);
		
		d_provider.setFallback(method(:onError));
		
		d_provider.ping(method(:onPing));
	}
	
	function onPing(response) {
		if ($.debug) {
			System.println("onPing(" + response + ")");
		}
    	
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
		