using Toybox.Media;
using Toybox.Application;

// 
class Song {
	
	// required external song properties
	hidden var d_id;				// id of the song
	hidden var d_time = 0;			// duration of the song
	hidden var d_mime = "";			// string e.g. "audio/mpeg"
	
	// required internal song properties
	hidden var d_refId = null;		// null if no song file is present
	hidden var d_refCount = 0;		// count the number of playlists this song is on
	hidden var d_playback = 0;		// last playback position
	hidden var d_art_id = null;		// null if no art_id available

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
			"playback" => d_playback,
			"art_id" => d_art_id,
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
		if ((storage["playback"] != null) && (d_playback != storage["playback"])) {
			d_playback = storage["playback"];
			changed = true;
		}
		if ((storage["art_id"] != null) && (d_art_id != storage["art_id"])) {
			d_art_id = storage["art_id"];
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

	function playback() {
		return d_playback;
	}

	function art_id() {
		return d_art_id;
	}

	function artwork() {
		if (d_art_id == null) {
			return null;
		}

		var artwork = new IArtwork(d_art_id);
		return artwork.get();
	}

	function metadata() {
		// metadata only available when refId != null
		if (d_refId == null) {
			return null;
		}
		return Media.getCachedContentObj(new Media.ContentRef(d_refId, Media.CONTENT_TYPE_AUDIO)).getMetadata();
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

	function setPlayback(position) {
		d_playback = position;

		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}

	function setArt_id(art_id) {
		// if equal, nothing to do
		if (d_art_id == art_id) {
			return false;
		}

		// if previous art_id stored, remove safely
		if (d_art_id != null) {
			var iartwork = new IArtwork(d_art_id);
			iartwork.decRefCount();
		}

		d_art_id = art_id;

		// if no new artwork, nothing to do
		if (d_art_id == null) {
			return true;
		}

		// reference the artwork
		var iartwork = new IArtwork(art_id);
		iartwork.incRefCount();
		return true;
	}
	 
	function setArtwork(artwork) {
		var iartwork = new IArtwork(d_art_id);
		return iartwork.set(artwork);
	}

	function save() {
		d_stored = SongStore.save(self);
		return d_stored;
	}

	// removes the song from the SongStore
	function remove() {
		setRefId(null);				// delete from cache
		setArt_id(null);			// remove reference to art_id
		SongStore.remove(self);		// remove self from storage
		d_stored = false;
		return;
	}
	
	// saves the new item to application storage
	function updateMeta(song) {
		System.println("ISong::updateMeta( song : " + song.toStorage() + " )");
		
		var changed = setTime(song.time());
		changed |= setMime(song.mime());
		changed |= setArt_id(song.art_id());
		if (changed) {
			d_stored = save();
		}
	}
}