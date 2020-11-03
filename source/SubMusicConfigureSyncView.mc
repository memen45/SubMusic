using Toybox.WatchUi;

// This is the menu with options to show before sync
class SubMusicConfigureSyncView extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title=>Rez.Strings.confSync_Title});
        
        addItem(new WatchUi.MenuItem(
        	Rez.Strings.confSync_SelectPlaylists_label,		// label
        	null,	// sublabel
        	SyncMenu.SELECT_PLAYLISTS,							// identifier
        	null
        ));
        addItem(new WatchUi.MenuItem(
        	Rez.Strings.confSync_ManagePlaylists_label,		// label
        	null,	// sublabel
        	SyncMenu.MANAGE_PLAYLISTS,						// identifier
        	null
        ));
        addItem(new WatchUi.MenuItem(
        	Rez.Strings.confSync_startsync,		// label
        	null,	// sublabel
        	SyncMenu.START_SYNC,				// identifier
        	null
        ));
        addItem(new WatchUi.MenuItem(
        	Rez.Strings.confSync_Test_label,		// label
        	Rez.Strings.confSync_Test_sublabel,		// sublabel
        	SyncMenu.TEST,							// identifier
        	null
        ));
    }
}
