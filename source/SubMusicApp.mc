using Toybox.Application;
using Toybox.WatchUi;

class SubMusicApp extends Application.AudioContentProviderApp {

	private var d_provider = null;

    function initialize() {
        AudioContentProviderApp.initialize();
        
        // in case variables need to be reset
        // Application.Storage.clearValues();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }
    
    function onSettingsChanged() {
    	System.println("Settings changed");
    	
    	// reset the sessions for the provider
    	if (d_provider == null) {
    		return;
    	}
    	d_provider.onSettingsChanged(getProviderSettings());
    }

    // Get a Media.ContentDelegate for use by the system to get and iterate through media on the device
    function getContentDelegate(arg) {
        return new SubMusicContentDelegate();
    }

    // Get a delegate that communicates sync status to the system for syncing media content to the device
    function getSyncDelegate() {
    	if (d_provider == null) {
    		d_provider = providerFactory();
    	}
        return new SubMusicSyncDelegate(d_provider);
    }

    // Get the initial view for configuring playback
    function getPlaybackConfigurationView() {
        return [ new SubMusicConfigurePlaybackView(), new WatchUi.BehaviorDelegate() ];
    }

    // Get the initial view for configuring sync
    function getSyncConfigurationView() {
    	if (d_provider == null) {
    		d_provider = providerFactory();
    	}
        return [ new SubMusicConfigureSyncView(), new SubMusicConfigureSyncDelegate(d_provider) ];
    }
    
    function getProviderSettings() {
    	return {
        	"api_url" => Application.Properties.getValue("subsonic_API_URL"),
			"api_usr" => Application.Properties.getValue("subsonic_API_usr"),
			"api_key" => Application.Properties.getValue("subsonic_API_key"),
		};
    }
    
    function providerFactory() {
        // construct the selected provider
        var settings = getProviderSettings();
        
        var type = Application.Properties.getValue("API_standard");
        if (type == ApiStandard.AMPACHE) {
        	return new AmpacheProvider(settings);
        }
        return new SubsonicProvider(settings);
    }
}
