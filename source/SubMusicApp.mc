using Toybox.Application;
using Toybox.WatchUi;
using SubMusic.Menu;

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

        // reload the media profile
        Media.requestPlaybackProfileUpdate();
    }

    // Get a Media.ContentDelegate for use by the system to get and iterate through media on the device
    function getContentDelegate(arg) {
    	System.println("getContentDelegate with arg: " + arg);
        
        return new SubMusicContentDelegate();
    }

    // Get a delegate that communicates sync status to the system for syncing media content to the device
    function getSyncDelegate() {
        var syncrequest = Application.Storage.getValue(Storage.SYNC_REQUEST);
        System.println("SubMusicApp syncrequest " + syncrequest);
        // return deprecated if sync was not started from the menu (i.e. autostart)
        if (syncrequest != true) {
            return new SubMusic.SyncDelegate_deprecated();
        }
        return new SubMusic.SyncDelegate();
    }

    // Get the initial view for configuring playback
    function getPlaybackConfigurationView() {
        var menu = new Menu.Playback();
        menu.load();    // menu needs to be loaded when MenuLoader is not used
    	return [ new Menu.MenuView(menu), menu.delegate() ];
    }

    // Get the initial view for configuring sync
    function getSyncConfigurationView() {
        var menu = new Menu.Sync();
        menu.load();    // menu needs to be loaded when MenuLoader is not used
    	return [ new SubMusic.Menu.MenuView(menu), menu.delegate() ];
    }
    
    function popView() {
    	WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
