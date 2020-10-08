using Toybox.Media;

// class SongStore {

// 	private var d_songs = {}; 		// dictionary by song id (all saved songs)
// 	private var d_locals = [];
// 	private var d_sync = [];
// 	private var d_delete = [];
	
// 	function initialize() {
	
// 		// retrieve all saved songs
// 		var songs = Application.Storage.getValue(Storage.SONGS);
// 		if (songs != null) {
// 			d_songs = songs;
// 		}
// 		var locals = Application.Storage.getValue(Storage.SONGS_LOCAL);
// 		if (locals != null) {
// 			d_locals = locals;
// 		}
// 		var sync = Application.Storage.getValue(Storage.SONGS_SYNC);
// 		if (sync != null) {
// 			d_sync = sync;
// 		}
// 		var delete = Application.Storage.getValue(Storage.SONGS_DELETE);
// 		if (delete != null) {
// 			d_delete = delete;
// 		}
// 	}
	
// 	function get(id) {
// 		if (id == null) {
// 			return null;
// 		}
// 		return d_songs[id];
// 	}
	
// 	function save(song) {
		
// 		var id = song.id();
// 		if (id == null) {
// 			return false;
// 		}
		
// 		// save details of the song
// 		d_songs[id] = song.toStorage();
// 		Application.Storage.setValue(Storage.SONGS, d_songs);
		
// 		// update tracking
// 		track(song);
		
// 		// indicate successful save
// 		return true;
// 	}
	
// 	// removes songs on todelete list from storage
// 	function flushDeletes() {
// 		for (var idx = 0; idx < d_delete.size(); ++idx) {
// 			var id = d_delete[idx];
// 			var isong = new ISong(id);
			
// 			songRemove(isong);
// 		}
// 		d_delete = [];
// 		Application.Storage.setValue(Storage.SONGS_DELETE, d_delete);
// 	}
	
// 	// ?
// 	function verifyStorage() {
// 		var ids = d_songs.keys();
// 		for (var idx = 0; idx < ids.size(); ++idx) {
// 			var isong = new ISong(ids[idx]);
// 			track(isong);
// 			if (d_delete.indexOf(ids[idx]) >= 0) {
// 				songRemove(isong);
// 			}
// 		}
// 	}
	
// 	function track(song) {
// 		var id = song.id();
		
// 		// update local tracking
// 		var local = (song.refId() != null);
// 		var onlocal = (d_locals.indexOf(id) >= 0);
// 		if (local && !onlocal) {
// 			d_locals.add(id);
// 		} else if (!local && onlocal) {
// 			d_locals.remove(id);
// 		}
// 		Application.Storage.setValue(Storage.SONGS_LOCAL, d_locals);
		
// 		// update delete tracking
// 		var delete = (song.refCount() <= 0);
// 		var ondelete = (d_delete.indexOf(id) >= 0);
// 		if (delete && !ondelete) {
// 			d_delete.add(id);
// 		} else if (!delete && ondelete) {
// 			d_delete.remove(id);
// 		}
// 		Application.Storage.setValue(Storage.SONGS_DELETE, d_delete);

// 		// update sync tracking
// 		var sync = !local && !delete;
// 		var onsync = (d_sync.indexOf(id) >= 0);
// 		if (sync && !onsync) {
// 			d_sync.add(id);
// 		} else if (!sync && onsync) {
// 			d_sync.remove(id);
// 		}
// 		Application.Storage.setValue(Storage.SONGS_SYNC, d_sync);
// 	}
	
// 	function songRemove(song) {
// 		var id = song.id();

// 		// remove from storage
// 		d_songs.remove(id);
// 		Application.Storage.setValue(Storage.SONGS, d_songs);
		
// 		// nothing to do if not stored
// 		if (song.refId() == null) {
// 			return;
// 		}
		
// 		// remove from media cache
// 		var contentRef = new Media.ContentRef(song.refId(), Media.CONTENT_TYPE_AUDIO);
// 		Media.deleteCachedItem(contentRef);
// 	}
// }

// 
class Song {
	
	// required external song properties
	hidden var d_id;				// id of the song
	hidden var d_time = 0;			// duration of the song
	hidden var d_mime = null;		// string e.g. "audio/mpeg"
	
	// required internal song properties
	hidden var d_refId = null;		// null if no song file is present
	hidden var d_refCount = 0;		// count the number of playlists this song is on
	
	function initialize(storage) {
		System.println("Song::initialize( storage = " + storage + " )");
		d_id = storage["id"];
		fromStorage(storage);
	}
	
	function toStorage() {
		return {
			"id" => d_id,
			"time" => d_time,
			"mime" => d_mime,
			
			"refId" => d_refId,
			"refCount" => d_refCount,
		};
	}
	
	function fromStorage(storage) {
		var changed = false;
		if (d_time != storage["time"]) {
			d_time = storage["time"];
			changed = true;
		}
		if (d_mime != storage["mime"]) {
			d_mime = storage["mime"];
			changed = true;
		}
		if ((storage["refId"] != null) && (d_refId != storage["refId"])) {
			d_refId = storage["refId"];
			changed = true;
		}
		if ((storage["refCount"] != null) && (d_refCount != storage["refCount"])) {
			d_refCount = storage["refCount"];
			changed = true;
		}
		return changed;
	}
	
	// getters
	function id() {
		return d_id;
	}
	
	function time() {
		return d_time;
	}
	
	function mime() {
		return d_mime;
	}
	
	function refId() {
		return d_refId;
	}
	
	function refCount() {
		return d_refCount;
	}
}

// interface song storage object
class ISong extends Song {
	
	// storage access
	private var d_stored = false;						// true if song metadata is in storage
	
	function initialize(id) {
		System.println("ISong::initialize( id : " + id + " )");
		var storage = SongStore.get(id);
		if (storage != null) {
			d_stored = true;
		} else {
			storage = {"id" => id};		// nothing known yet except for id
		}
		Song.initialize(storage);
	}
	
	// setters
	
	// returns true if changes saved 
	function setTime(time) {
		// nothing to do if not changed
		if (d_time == time) {
			return false;
		}
		d_time = time;
		
		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}
	
	// returns true if changes saved
	function setMime(mime) {
		// nothing to do if not changed
		if (mime.equals(d_mime)) {
			return false;
		}
		d_mime = mime;
		
		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}
	 
	function setRefId(refId) {
		// if equal, nothing to do
		if (d_refId == refId) {
			return false;
		}

		// safely delete old item from cache
		if (d_refId != null) {
			// remove from media cache
			var contentRef = new Media.ContentRef(d_refId, Media.CONTENT_TYPE_AUDIO);
			Media.deleteCachedItem(contentRef);
		}

		// store new refId
		d_refId = refId;
		return save();		// always saved, due to responsibility for refId
	}
	
	function incRefCount() {
		d_refCount += 1;
		
		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}
	
	function decRefCount() {
		d_refCount -= 1;
		
		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}

	function save() {
		d_stored = SongStore.save(self);
		return d_stored;
	}

	// removes the song from the SongStore
	function remove() {
		SongStore.remove(self);
		d_stored = false;
		return;
	}
	
	// saves the new item to application storage
	function updateMeta(song) {
		System.println("ISong::updateMeta( song : " + song.toStorage() + " )");
		
		var changed = setTime(song.time());
		changed |= setMime(song.mime());
		if (changed) {
			d_stored = save();
		}
	}
}