using Toybox.Media;

// class for managing the locally stored songs

class SubMusicSongStore {
	
	private var d_locals = {};		// object on refIds
	private var d_tosync = {};		// object on ids
	private var d_todelete = [];	// array of ids
	
	function initialize() {
		var locals = Application.Storage.getValue(Storage.SONGS_LOCAL);
		if (locals != null) {
			d_locals = locals;
		}
		var tosync = Application.Storage.getValue(Storage.SONGS_SYNC);
		if (tosync != null) {
			d_tosync = tosync;
		}
		var todelete = Application.Storage.getValue(Storage.SONGS_DELETE);
		if (todelete != null) {
			d_todelete = todelete;
		}
	}
	
	function store(key) {
		if (key == Storage.SONGS_LOCAL) {
			Application.Storage.setValue(Storage.SONGS_LOCAL, d_locals);
			return;
		}
		if (key == Storage.SONGS_SYNC) {
			Application.Storage.setValue(Storage.SONGS_SYNC, d_tosync);
			return;
		}
		if (key == Storage.SONGS_DELETE) {
			Application.Storage.setValue(Storage.SONGS_DELETE, d_todelete);
			return;
		}
		System.error("SubMusicSongStore::store(key) -> Invalid 'key': " + key);
	}
	
	/**
	 * addSong
	 * 
	 * adds a song to the to sync list, return true if locally available
	 */
	function addSong(song) {
		System.println("SubMusicSongStore::addSong(id = " + song["id"] + ")");
		
		var refId = getRefIdById(song["id"]);
		
		// check if already local and is about todelete
		if ((refId != null) && (d_todelete.indexOf(refId) != -1)) {
			// increment ref count on locals
			d_locals[refId]["refCount"] += 1;
			store(Storage.SONGS_LOCAL);
			
			// remove from todeletes
			d_todelete.remove(refId);
			store(Storage.SONGS_DELETE);
			return true;
		}
		
		// check if already local
		if (refId != null) {
			d_locals[refId]["refCount"] += 1;
			store(Storage.SONGS_LOCAL);
			return true;
		}
		
		// check if it was already to be synced
		if (d_tosync.hasKey(song["id"])) {
			d_tosync[song["id"]]["refCount"] += 1;
			store(Storage.SONGS_SYNC);
			return false;
		}
		
		song["refCount"] = 1;
		d_tosync[song["id"]] = song;
		store(Storage.SONGS_SYNC);
		return false;
	}
	
	/** 
	 * subSong
	 *
	 * subtracts the refcount on a song, add todelete if zero references left
	 * returns 0 if operation deferred (delete is deferred operation),
	 * 1 if operation finished (refCount subtracted or failed)
	 */
	function subSong(song) {
		System.println("SubMusicSongStore::subSong(id = " + song["id"] + ")");
	
		// if song not local, nothing to do
		var refId = getRefIdById(song["id"]);
		if (refId == null) {
			return 1;
		}
		
		// decrement reference counter
		d_locals[refId]["refCount"] -= 1;
		store(Storage.SONGS_LOCAL);
		
		// if refcount did not reach 0, nothing to do
		if (d_locals[refId]["refCount"] != 0) {
			return 1;
		}
		d_todelete.add(refId);
		store(Storage.SONGS_DELETE);
		return 0;
	}
	
	/** 
	 * getToSyncIds
	 *
	 * returns an array of ids that still requires a sync
	 */
	function getToSyncIds() {
		return d_tosync.keys();
	}
	
	/** 
	 * storeSong
	 *
	 * links the given refId to the tosync song information
	 */
	function storeSong(id, refId) {
		var song = d_tosync[id];
		if (song == null) {
			return;
		}
		
		// store locally
		d_locals[refId] = song;
		store(Storage.SONGS_LOCAL);
		
		// remove from the to sync list
		d_tosync.remove(id);
		store(Storage.SONGS_SYNC);
	}
	
	function skipSong(id) {
		d_tosync.remove(id);
		store(Storage.SONGS_SYNC);
	}
	
	/** 
	 * flushDelete
	 *
	 * all pending deletes are now permanently removed from cache
	 */
	function flushDelete() {
		System.println("SubMusicSongStore::flushDelete(): " + d_todelete);
		for (var idx = 0; idx < d_todelete.size(); ++idx) {
			var refId = d_todelete[idx];
			var contentRef = new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO);
			Media.deleteCachedItem(contentRef);
			
			d_locals.remove(refId);
			store(Storage.SONGS_LOCAL);
		}
		var count = d_todelete.size();
		
		// clear todelete list
		d_todelete = [];
		store(Storage.SONGS_DELETE);
		
		return count;
	}
	
	/** 
	 * getRefIdById
	 * 
	 * returns the refId of the local song given the songId
	 */
	function getRefIdById(songId) {
		var keys = d_locals.keys();
		for (var idx = 0; idx < keys.size(); ++idx) {
			if (d_locals[keys[idx]]["id"].equals(songId)) {
				return keys[idx];
			}
		}
		return null;
	}
	
	function getSongCount() {
		return d_locals.keys().size();
	}
	
	function getSyncCount() {
		return d_tosync.keys().size();
	}
	
	function getDeleteCount() {
		return d_todelete.size();
	}
}