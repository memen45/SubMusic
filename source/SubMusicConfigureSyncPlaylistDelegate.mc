using Toybox.WatchUi;

class SubMusicConfigureSyncPlaylistDelegate extends WatchUi.BehaviorDelegate {

	private var d_synclist = {};
	private var d_todelete = {};
	
	// private var d_liststore;
	// private var d_playlists;

	function initialize() {
		BehaviorDelegate.initialize();
    }
    
    function onSelect(item) {
    	if (item.isChecked()) {
    		d_synclist.put(item.getId(), true);
    		d_todelete.put(item.getId(), false);
    		return;
    	}
    	d_synclist.put(item.getId(), false);
    	d_todelete.put(item.getId(), true);
    }
    
    // store progress even when returning from menu
    function onBack() {
    	storeChecks();
    	WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
    
    function onDone() {
	    storeChecks();
	    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
    
    function storeChecks() {
    	// iterate over the synclist
		var playlists = d_synclist.keys();
    	for (var idx = 0; idx < playlists.size(); ++idx) {
			var playlist = playlists[idx];
    		// add to playlists tosync if true
			if (!d_synclist[playlist]) {
				continue;
			}
			var id = playlist.id();
			var iplaylist = new IPlaylist(id);

			// new playlists need a name etc
			if (!iplaylist.stored()) {
				iplaylist.updateMeta(playlist);
			}
			iplaylist.setLocal(true);
    	}
    	
    	// iterate over the todelete
    	playlists = d_todelete.keys();
    	for (var idx = 0; idx < playlists.size(); ++idx) {
    		var playlist = playlists[idx];
    		// delete if true
    		if (d_todelete[playlist]) {
				var id = playlist.id();
				var iplaylist = new IPlaylist(id);

				// if stored, remove
				if (iplaylist.stored()) {
					iplaylist.setLocal(false);
				}
    		}
    	}
    }

}
