using Toybox.Media;

// 
class Song {
	
	// required external song properties
	hidden var d_id;				// id of the song
	hidden var d_time = 0;			// duration of the song
	hidden var d_mime = "";			// string e.g. "audio/mpeg"
	
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
		if ((storage["mime"] != null) && (d_mime != storage["mime"])) {
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

		if (mime == null) {
			return false;
		}
	
		// nothing to do if not changed
		if (d_mime.equals(mime)) {
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