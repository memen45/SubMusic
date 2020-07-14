using Toybox.WatchUi;

class SubMusicConfigureSyncPlaylistDelegate extends WatchUi.BehaviorDelegate {

	private var d_synclist = {};
	private var d_todelete = {};
	
	private var d_liststore;
	private var d_playlists;

	function initialize(playlists) {
		BehaviorDelegate.initialize();
		
		d_playlists = playlists;
		d_liststore = new SubMusicPlaylistStore();
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
	    Media.startSync();
    }
    
    function storeChecks() {
    	// iterate over the synclist
    	var keys = d_synclist.keys();
    	for (var idx = 0; idx < keys.size(); ++idx) {
    	
    		// add to playlists tosync if true
    		if (d_synclist[keys[idx]]) {
    			d_liststore.add(findById(keys[idx], d_playlists));
    		}
    	}
    	
    	// iterate over the todelete
    	keys = d_todelete.keys();
    	for (var idx = 0; idx < keys.size(); ++idx) {
    		
    		// delete if true
    		if (d_todelete[keys[idx]]) {
    			d_liststore.delete(keys[idx]);
    		}
    	}
    }

	function findById(id, playlists) {
		System.println("id = " + id);
		System.println("playlists: " + playlists);
		
		id = id.toNumber();
		for (var idx = 0; idx < playlists.size(); ++idx) {
			if (id == playlists[idx]["id"].toNumber()) {
				return playlists[idx];
			}
		}
		return null;
	}

}
