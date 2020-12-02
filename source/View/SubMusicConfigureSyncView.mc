using Toybox.WatchUi;
using Toybox.Time;
using Toybox.Application;

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
        
        var lastsync = Application.Storage.getValue(Storage.LAST_SYNC);
        var sublabel = null;
        if ((lastsync != null) && (lastsync["time"] instanceof Lang.Number)) {
        	var moment = new Time.Moment(lastsync["time"]);
	        var info = Time.Gregorian.info(moment, Time.FORMAT_MEDIUM);
	        sublabel = Lang.format("$1$ $2$ $3$ - $4$:$5$", [ info.day, info.month, info.year, info.hour, info.min ]);
        }
        addItem(new WatchUi.MenuItem(
        	Rez.Strings.confSync_startsync,		// label
        	sublabel,							// sublabel
        	SyncMenu.START_SYNC,				// identifier
        	null
        ));
        
        addItem(new WatchUi.MenuItem(
        	Rez.Strings.confSync_DebugInfo_label,		// label
        	null,		// sublabel
        	SyncMenu.DEBUG_INFO,							// identifier
        	null
        ));
    }
}
