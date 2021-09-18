using Toybox.Media;
using Toybox.Application;
using Toybox.Test;

// 
class Song extends Storable {

	hidden var d_storage = {
		// required external song properties
		"id" => null,			// id of the song
		"title" => "",			// title of the song
		"artist" => "",			// artist of the song
		"time" => 0,			// duration of the song
		"mime" => "",			// string e.g. "audio/mpeg"
		"art_id" => null,		// null if no art_id available

		// required internal song properties
		"refId" => null,		// null if no audio file is local
		"refCount" => 0,		// count the number of playlists this song is on
		"playback" => 0,		// last playback position
	};
	function initialize(storage) {
		System.println("Song::initialize( storage = " + storage + " )");
		
		Storable.initialize(storage);
	}
	
	// getters
	function id() {
		return d_storage["id"];
	}

	function title() {
		return d_storage["title"];
	}

	function artist() {
		return d_storage["artist"];
	}
	
	function time() {
		return d_storage["time"];
	}
	
	function mime() {
		return d_storage["mime"];
	}
	
	function refId() {
		return d_storage["refId"];
	}
	
	function refCount() {
		return d_storage["refCount"];
	}

	function playback() {
		return d_storage["playback"];
	}

	function art_id() {
		return d_storage["art_id"];
	}

	function metadata() {
		// metadata only available when refId != null
		if (refId() == null) {
			return null;
		}
		return Media.getCachedContentObj(new Media.ContentRef(refId(), Media.CONTENT_TYPE_AUDIO)).getMetadata();
	}
}

// interface song storage object
class ISong extends Song {
	
	// storage access
	private var d_stored = false;						// true if song metadata is in storage
	
	private var d_artwork = null;

	function initialize(id) {
		System.println("ISong::initialize( id : " + id + " )");
		var storage = SongStore.get(id);
		if (storage != null) {
			d_stored = true;
		} else {
			storage = {"id" => id};		// nothing known yet except for id
		}
		Song.initialize(storage);

		// load artwork if defined
		if (art_id() != null) {
			d_artwork = new IArtwork(art_id(), Artwork.SONG);
		}
	}

	function artwork() {
		if (d_artwork == null) {
			return null;
		}
		return d_artwork.image();
	}
	
	// setters
	
	// returns true if changes saved 
	function setTime(time) {
		// nothing to do if not changed
		if (time() == time) {
			return false;
		}
		d_storage["time"] = time;
		
		System.println("ISong::setTime( time: " + time + " )");
		
		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}
	
	// returns true if changes saved
	function setMime(mime) {

		// new mime should not be null
		if (mime == null) {
			return false;
		}
	
		// nothing to do if not changed
		if (mime().equals(mime)) {
			return false;
		}
		d_storage["mime"] = mime;

		System.println("ISong::setMime( mime: " + mime + " )");
		
		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}
	 
	function setRefId(refId) {
		// if equal, nothing to do
		if (refId() == refId) {
			return false;
		}

		// safely delete old item from cache
		if (refId() != null) {
			// remove from media cache
			var contentRef = new Media.ContentRef(refId(), Media.CONTENT_TYPE_AUDIO);
			Media.deleteCachedItem(contentRef);
		}

		// store new refId
		d_storage["refId"] = refId;
		return save();		// always saved, due to responsibility for refId
	}
	
	function incRefCount() {
		d_storage["refCount"] += 1;
		
		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}
	
	function decRefCount() {
		d_storage["refCount"] -= 1;
		
		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}

	function setPlayback(position) {
		d_storage["playback"] = position;

		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}

	function setArt_id(art_id) {
		// if equal, nothing to do
		var changed = updateAny("art_id", art_id);

		// if nothing changed, nothing to update
		if (!changed) {
			return changed;
		}

		System.println("ISong::setArt_id( art_id: " + art_id + " )");

		// dereference previous art
		if (d_artwork != null) {
			d_artwork.decRefCount();
		}

		// if new artwork, load it
		if (art_id() != null) {
			d_artwork = new IArtwork(art_id(), Artwork.SONG);
			
			// reference the artwork
			d_artwork.incRefCount();
		}

		d_artwork = null;
		return changed;
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
		
		// only single save is needed, so mark as not stored temporarily
		d_stored = false;

		// update the variables
		var changed = setTime(song.time());
		changed |= setMime(song.mime());
		changed |= setArt_id(song.art_id());
		if (changed) {
			save();
		}
		d_stored = true;
	}
}