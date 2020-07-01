using Toybox.Application;
using Toybox.WatchUi;

class SubMusicApp extends Application.AudioContentProviderApp {

	private var d_provider;

    function initialize() {
        AudioContentProviderApp.initialize();
        
//        Application.Storage.clearValues();

        // construct the selected provider
        var settings = {
        	"api_url" => Application.Properties.getValue("subsonic_API_URL"),
			"api_usr" => Application.Properties.getValue("subsonic_API_usr"),
			"api_key" => Application.Properties.getValue("subsonic_API_key"),
		};
        
        var type = Application.Properties.getValue("API_standard");
        if (type == ApiStandard.AMPACHE) {
        	d_provider = new AmpacheProvider(settings);
            return;
        }
        d_provider = new SubsonicProvider(settings);
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Get a Media.ContentDelegate for use by the system to get and iterate through media on the device
    function getContentDelegate(arg) {
        return new SubMusicContentDelegate();
    }

    // Get a delegate that communicates sync status to the system for syncing media content to the device
    function getSyncDelegate() {
        return new SubMusicSyncDelegate(d_provider);
    }

    // Get the initial view for configuring playback
    function getPlaybackConfigurationView() {
        return [ new SubMusicConfigurePlaybackView(), new WatchUi.BehaviorDelegate() ];
    }

    // Get the initial view for configuring sync
    function getSyncConfigurationView() {
        return [ new SubMusicConfigureSyncView(d_provider), new WatchUi.BehaviorDelegate() ];
    }

}
