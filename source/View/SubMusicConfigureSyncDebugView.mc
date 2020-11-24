using Toybox.WatchUi;

// This is the menu with options to show before sync
class SubMusicConfigureSyncDebugView extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title=>Rez.Strings.confSync_DebugInfo_label});
        
        addItem(new WatchUi.MenuItem(
        	Rez.Strings.confSync_DebugInfo_TestServer_label,		// label
        	null,	// sublabel
        	SyncDebugMenu.TEST_SERVER,							// identifier
        	null
        ));
    }
}
