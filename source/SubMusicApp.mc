using Toybox.Application;
using Toybox.WatchUi;

class SubMusicApp extends Application.AudioContentProviderApp {

    function initialize() {
        AudioContentProviderApp.initialize();
        
//        Application.Storage.clearValues();
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
        return new SubMusicSyncDelegate();
    }

    // Get the initial view for configuring playback
    function getPlaybackConfigurationView() {
        return [ new SubMusicConfigurePlaybackView(), new WatchUi.BehaviorDelegate() ];
    }

    // Get the initial view for configuring sync
    function getSyncConfigurationView() {
        return [ new SubMusicConfigureSyncView(), new WatchUi.BehaviorDelegate() ];
    }

}
