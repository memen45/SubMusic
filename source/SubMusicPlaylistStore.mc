class SubMusicPlaylistsBase {
	
	hidden var d_locals = {};		// object on ids
	hidden var d_tosync = {};		// object on ids
	hidden var d_todelete = [];	// array of ids
	
	function initialize() {
		var locals = Application.Storage.getValue(Storage.PLAYLIST_LOCAL);
		if (locals != null) {
			d_locals = locals;
		}
		var tosync = Application.Storage.getValue(Storage.PLAYLIST_SYNC);
		if (tosync != null) {
			d_tosync = tosync;
		}
		var todelete = Application.Storage.getValue(Storage.PLAYLIST_DELETE);
		if (todelete != null) {
			d_todelete = todelete;
		}
	}
	
	function store(key) {
		if (key == Storage.PLAYLIST_LOCAL) {
			Application.Storage.setValue(Storage.PLAYLIST_LOCAL, d_locals);
			return;
		}
		if (key == Storage.PLAYLIST_SYNC) {
			Application.Storage.setValue(Storage.PLAYLIST_SYNC, d_tosync);
			return;
		}
		if (key == Storage.PLAYLIST_DELETE) {
			Application.Storage.setValue(Storage.PLAYLIST_DELETE, d_todelete);
			return;
		}
		System.error("SubMusicPlaylistsBase::store(key) -> Invalid 'key': " + key);
	}
	
	// returns ids of all the locally available playlists
	function getLocalIds() {
		return d_locals.keys();
	}
	
	// returns ids of all the playlists on tosync list
	function getToSyncIds() {
		return d_tosync.keys();
	}
	
	// return ids of all the playlists on todelete list
	function getToDeleteIds() {
		return d_todelete;		// already an array of ids
	}
}

class SubMusicPlaylistStore extends SubMusicPlaylistsBase {

	function initialize() {
		SubMusicPlaylistsBase.initialize();
	}
	
	// add a playlist to the tosync list
	function add(playlist) {
		if (playlist == null) {
			return;
		}
		
		// if id was on todelete, nothing to do more
		if (d_todelete.remove(playlist["id"])) {
			store(Storage.PLAYLIST_DELETE);
			return;
		}
		
		// if already local, nothing to do
		if (d_locals.hasKey(playlist["id"])
			|| d_tosync.hasKey(playlist["id"])) {
			return;
		}
		
		// store in tosync list
		d_tosync.put(playlist["id"], playlist);
		store(Storage.PLAYLIST_SYNC);
	}
	
	// add a playlist to the todelete list
	function delete(id) {
		if (id == null) {
			return;
		}
		
		// if not local, nothing to do
		var local = (d_locals.hasKey(id) || d_tosync.hasKey(id));
		if (!local) {
			return;
		}
		
		// if already on todelete, nothing to do
		if (d_todelete.indexOf(id) != -1) {
			return;
		}
		
		d_todelete.add(id);
		store(Storage.PLAYLIST_DELETE);
	}
}

class SubMusicPlaylistSync extends SubMusicPlaylistsBase {

	private var d_songstore;
	
	function initialize() {
		SubMusicPlaylistsBase.initialize();
		
		d_songstore = new SubMusicSongStore();
	}
	
	// update the given playlist on either locals or tosync
	function update(id, songs) {
		var locals;
		
		// load local list, return if not available
		if (d_locals.hasKey(id)) {
			locals = d_locals[id]["songs"];
		} else if (d_tosync.hasKey(id)) {
			locals = [];
			
			// copy the playlist to the locals list
			d_locals[id] = d_tosync.get(id);
			d_locals[id]["songs"] = [];
		} else {
			return 0;
		}
		
		var remotes = songs;
		var count = 0;
		
		// calculate time of the playlist
		var time = 0;
		for (var idx = 0; idx < remotes.size(); ++idx) {
			time += remotes[idx]["time"];
		}
		d_locals[id]["time"] = time;
		
		// find remote additions
		for (var idx = 0; idx < remotes.size(); ++idx) {
			var local = findById(remotes[idx]["id"], locals);
			
			// if song was on old list, nothing to do
			if (local != null) {
				locals.remove(local);
				count++;
				continue;
			}
			
			// add song if it was not already local
			var is_local = d_songstore.addSong(remotes[idx]);
			if (is_local) {
				count++;
			}
		}
		
		// find local extra's 
		for (var idx = 0; idx < locals.size(); ++idx) {
			count += d_songstore.subSong(locals[idx]);
		}
		
		// add / overwrite the local playlist
		d_locals[id]["songs"] = songs;
		store(Storage.PLAYLIST_LOCAL);
		
		// remove from the tosync list
		d_tosync.remove(id);
		store(Storage.PLAYLIST_SYNC);
		
		System.println("SubMusicPlaylistSync::update(id = " + id + ") synced " + count);

		return count;
	}
	
	// remove all todelete playlists, sub all songs on them
	function delete() {
		System.println("SubMusicPlaylistSync::delete() with " + d_todelete.size() + " playlist to delete");
		var count = 0;
		
		// iterate over the todelete playlists
		for (var idx = 0; idx < d_todelete.size(); ++idx) {
			var id = d_todelete[idx];
			var local = d_locals[id];
			
			//if not local, nothing to do
			if (local == null) {
				continue;
			}
			
			// iterate over all the songs in the playlist
			var songs = local["songs"];
			for (var song_idx = 0; song_idx < songs.size(); ++song_idx) {
				count += d_songstore.subSong(songs[song_idx]);
			}
			
			// set locals to empty playlist
			d_locals.remove(id);
			store(Storage.PLAYLIST_LOCAL);		// immediate save in case of sync interruptions
		}
		d_todelete = [];
		store(Storage.PLAYLIST_DELETE);
		
		return count;
	}
	
	// returns an array of song ids that need to be synced
	function getSongsToSyncIds() {
		return d_songstore.getToSyncIds();
	}
	
	// stores the refId along with the song metadata to the songstore
	function storeSong(id, refId) {
		d_songstore.storeSong(id, refId);
	}
	
	// remove pending deletes permanently from the cache
	function flushDelete() {
		return d_songstore.flushDelete();
	}
	
	function countSongs() {
		var count = 0;
		
		// count songs from local lists
		var keys = d_locals.keys();
		for (var idx = 0; idx < keys.size(); ++idx) {
			count += d_locals[keys[idx]]["songCount"].toNumber();
		}
		
		// count songs from tosync lists
		keys = d_tosync.keys();
		for (var idx = 0; idx < keys.size(); ++idx) {
			count += d_tosync[keys[idx]]["songCount"].toNumber();
		}
		
		// do not count songs on todelete playlists, since those are 
		// always local lists, so already accounted for

		return count;
	}
	
	function countSyncs() {
		var count = 0;
		
		// count songs from tosync lists
		var keys = d_tosync.keys();
		for (var idx = 0; idx < keys.size(); ++idx) {
			count += d_tosync[keys[idx]]["songCount"].toNumber();
		}
		
		// add songs to be downloaded
		count += d_songstore.getSyncCount();
		
		// add songs to be deleted
		count += d_songstore.getDeleteCount();
		
		return count;
	}
    
    /**
     * findById
     *
     * searches for "id" = id  in an array of objects
     */
    function findById(id, locals) {
    	for (var idx = 0; idx < locals.size(); ++idx) {
    		if (locals[idx]["id"].equals(id)) {
    			return locals[idx];
    		}
    	}
    	return null;
    }
		
}