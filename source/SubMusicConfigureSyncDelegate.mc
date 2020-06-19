using Toybox.WatchUi;

class SubMusicConfigureSyncDelegate extends WatchUi.BehaviorDelegate {

	private var d_synclist;
	private var d_deletelist;

    function initialize() {
        BehaviorDelegate.initialize();
        
        d_synclist = [];
        d_deletelist = [];
    }
    
    function onSelect(item) {
    	if (item.isChecked()) {
    		d_synclist.add(item.getId());
    		d_deletelist.remove(item.getId());
    		return;
    	}
    	d_synclist.remove(item.getId());
    	d_deletelist.add(item.getId());
    }
    
    // store progress even when returning from menu
    function onBack() {
    	onDone();
    }
    
    function onDone() {
    	
    	// get playlists currently stored on the system
    	var playlists = Application.Storage.getValue(Storage.PLAYLIST_LOCAL);
    	if (playlists == null) {
    		playlists = {};
    	}
    	
    	// get playlists already in the sync list
    	var synclists = Application.Storage.getValue(Storage.PLAYLIST_SYNC);
    	if (synclists == null) {
    		synclists = {};
    	}
    	
    	// add each playlist from the sync list to the object store sync list
    	System.println("To Sync: " + synclists);
    	System.println("Add to sync: " + d_synclist);
    	for (var idx = 0; idx < d_synclist.size(); ++idx) {
    		if (getPlaylistById(d_synclist[idx]["id"], playlists) == null) {
    			synclists[d_synclist[idx]["id"]] = d_synclist[idx];
    		}
    	}
    	
    	// add to delete playlists from the sync list to the object store delete list
    	var deletelists = Application.Storage.getValue(Storage.PLAYLIST_DELETE);
    	if (deletelists == null) {
    		deletelists = [];
    	}
    	System.println("To Delete: " + deletelists);
    	System.println("Add to delete: " + d_deletelist);
    	for (var idx = 0; idx < d_deletelist.size(); ++idx) {
    		// check if it is already on deletelist
    		var in_delete = (-1 != deletelists.indexOf(d_deletelist[idx]["id"]));
    		if (in_delete) {
    			continue;
    		}
    		// check if it is local
    		var in_local = (null != getPlaylistById(d_deletelist[idx]["id"], playlists));
    		if (in_local) {
    			deletelists.add(d_deletelist[idx]["id"]);
    			continue;
    		}
    		
    		// check if on the to_sync
    		var in_sync = (null != getPlaylistById(d_deletelist[idx]["id"], synclists));
    		System.println("in_sync: " + in_sync);
    		if (in_sync) {
    			synclists.remove(d_deletelist[idx]["id"]);
    		}
    	}
    	Application.Storage.setValue(Storage.PLAYLIST_SYNC, synclists);
    	Application.Storage.setValue(Storage.PLAYLIST_DELETE, deletelists);
    	
    	WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

	function getPlaylistById(id, playlists) {
		System.println("id = " + id);
		System.println("playlists: " + playlists);
		
		id = id.toNumber();
		var keys = playlists.keys();
		for (var idx = 0; idx < keys.size(); ++idx) {
			if (id == playlists[keys[idx]]["id"].toNumber()) {
				return playlists[keys[idx]];
			}
		}
		return null;
	}

}
