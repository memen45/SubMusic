using Toybox.Application;
using Toybox.WatchUi;

class SubMusicApp extends Application.AudioContentProviderApp {

    function initialize() {
        AudioContentProviderApp.initialize();
        
        // in case variables need to be reset
    //    Application.Storage.clearValues();

        // perform storage check and fix if possible
        Storage.check();
    }

    // onStart() is called on application start up
    function onStart(state) {
    	System.println("Start with state: " + state);
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    	System.println("Stop with state: " + state);
    }
    
    function onSettingsChanged() {
    	System.println("Settings changed");
    	
    	// reset the sessions for the provider
    	SubMusic.Provider.onSettingsChanged();
    }

    // Get a Media.ContentDelegate for use by the system to get and iterate through media on the device
    function getContentDelegate(arg) {
    	System.println("getContentDelegate with arg: " + arg);
        return new SubMusicContentDelegate();
    }

    // Get a delegate that communicates sync status to the system for syncing media content to the device
    function getSyncDelegate() {
        return new SubMusicSyncDelegate();
    }

    // Get the initial view for configuring playback
    function getPlaybackConfigurationView() {
    	return [ new SubMusic.Menu.PlaybackView(), new SubMusic.Menu.PlaybackDelegate() ];
    }

    // Get the initial view for configuring sync
    function getSyncConfigurationView() {
    	return [ new SubMusic.Menu.SyncView(), new SubMusic.Menu.SyncDelegate(method(:onBack)) ];		// show note on exit
    }
    
    function onBack() {
    	var msg = "Note: \"Start syncing music\" might not complete on this device";
    	WatchUi.switchToView(new TextView(msg), new TapDelegate(method(:popView)), WatchUi.SLIDE_IMMEDIATE);
    }
    
    function popView() {
    	WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
