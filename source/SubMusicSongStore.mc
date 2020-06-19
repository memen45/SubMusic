using Toybox.Media;

// class for managing the locally stored songs

class SubMusicSongStore {
	
	private var d_locals;		// object on refIds
	private var d_tosync;		// object on ids
	private var d_todelete;		// array of ids
	
	function initialize() {
		d_locals = Application.Storage.getValue(Storage.SONGS_LOCAL);
		if (d_locals == null) {
			d_locals = {};
		}
		d_tosync = {};
		d_todelete = [];
	}
	
	/**
	 * addSong
	 * 
	 * adds a song to the to sync list, return true if locally available
	 */
	function addSong(song) {
		var refId = getRefIdById(song["id"]);
		if ((refId != null) && (d_todelete.indexOf(refId) != -1)) {
			d_locals[refId]["refCount"] += 1;
			d_todelete.remove(song["id"]);
			return true;
		}
		if (refId != null) {
			d_locals[refId]["refCount"] += 1;
			return true;
		}
		
		// check if it was already to be synced
		if (d_tosync.hasKey(song["id"])) {
			d_tosync[song["id"]]["refCount"] += 1;
			return false;
		}
		
		song["refCount"] = 1;
		d_tosync[song["id"]] = song;
		return false;
	}
	
	/** 
	 * subSong
	 *
	 * subtracts the refcount on a song, add todelete if zero references left
	 */
	function subSong(song) {
		var refId = getRefIdById(song["id"]);
		if (refId == null) {
			return;
		}
		d_locals[refId]["refCount"] -= 1;
		if (d_locals[refId]["refCount"] != 0) {
			return;
		}
		d_todelete.add(refId);
	}
	
	/** 
	 * getSyncIds
	 *
	 * returns an array of ids that still requires a sync
	 */
	function getFrontSync() {
		var keys = d_tosync.keys();
		if (keys.size() == 0) {
			return null;
		}
		return d_tosync.get(keys[0]);
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
		Application.Storage.setValue(Storage.SONGS_LOCAL, d_locals);
		
		// remove from the to sync list
		d_tosync.remove(id);
	}
	
	function skipSong(id) {
		d_tosync.remove(id);
	}
	
	/** 
	 * flushDelete
	 *
	 * all pending deletes are now permanently removed from cache
	 */
	function flushDelete(callback) {
		System.println("flushDelete: " + d_todelete);
		var count = d_todelete.size();
		for (var idx = 0; idx < d_todelete.size(); ++idx) {
			var refId = d_todelete[idx];
			var contentRef = new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO);
			Media.deleteCachedItem(contentRef);
			d_locals.remove(refId);
			
			// immediately store 
			Application.Storage.setValue(Storage.SONGS_LOCAL, d_locals);
			
			// update sync progress
			callback.invoke(1);
		}
		d_todelete = [];
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
	
	function writeToStorage() {
		Application.Storage.setValue(Storage.SONGS_LOCAL, d_locals);
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