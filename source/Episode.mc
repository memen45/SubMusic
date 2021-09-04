using Toybox.Media;
using Toybox.Application;

class Episode extends Storable {

	hidden var d_storage = {
		// required external episode properties
		"id" => null,			// id of the episode
		"title" => "",			// title of the episode
		"time" => 0,			// duration of the episode
		"mime" => "",			// string e.g. "audio/mpeg"
		"art_id" => null,		// null if no art_id available

		// required internal episode properties
		"refId" => null,		// null if no audio file is local
		"playback" => 0,		// last playback position
	};

	function initialize(storage) {
		System.println("Episode::initialize( storage = " + storage + " )");

		Storable.initialize(storage);
	}
	
	// getters
	function id() {
		return d_storage["id"];
	}

	function title() {
		return d_storage["title"];
	}
	
	function time() {
		return d_storage["time"];
	}
	
	function mime() {
		return d_storage["mime"];
	}

	function art_id() {
		return d_storage["art_id"];
	}
	
	function refId() {
		return d_storage["refId"];
	}

	function playback() {
		return d_storage["playback"];
	}

	function artwork() {
		if (art_id() == null) {
			return null;
		}

		var artwork = new IArtwork(art_id());
		return artwork.get();
	}

	function metadata() {
		// metadata only available when refId != null
		if (refId() == null) {
			return null;
		}
		return Media.getCachedContentObj(new Media.ContentRef(refId(), Media.CONTENT_TYPE_AUDIO)).getMetadata();
	}
}

// interface episode storage object
class IEpisode extends Episode {
	
	// storage access
	private var d_stored = false;						// true if song metadata is in storage
	
	function initialize(id) {
		System.println("IEpisode::initialize( id : " + id + " )");
		var storage = EpisodeStore.get(id);
		if (storage != null) {
			d_stored = true;
		} else {
			storage = {"id" => id};		// nothing known yet except for id
		}
		Episode.initialize(storage);
	}
	
	// setters
	// use for == comparison only
	function set(key, value) {
		
		// nothing to do if not changed
		if (d_storage[key] == value) {
			return false;
		}
		d_storage[key] = value;
		
		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}

	function setString(key, string) {
		// not a valid string? do not update
		if (string == null) {
			return false;
		}

		// nothing to do if not changed
		if (d_storage[key].equals(string)) {
			return false;
		}
		d_storage[key] = string;

		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}

	function setTitle(title) {
		return set("title", title);
	}
	
	function setTime(time) {
		return set("time", time);
	}
	
	function setMime(mime) {
		return setString("mime", mime);
	}
	
// 	// returns true if changes saved
// 	function setMime(mime) {

// 		if (mime == null) {
// 			return false;
// 		}
	
// 		// nothing to do if not changed
// 		if (d_mime.equals(mime)) {
// 			return false;
// 		}
// 		d_mime = mime;
		
// 		// nothing to do if not stored
// 		if (d_stored) {
// 			save();
// 		}
// 		return true;
// 	}
	 
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
	
// 	function incRefCount() {
// 		d_refCount += 1;
		
// 		// nothing to do if not stored
// 		if (d_stored) {
// 			save();
// 		}
// 		return true;
// 	}
	
// 	function decRefCount() {
// 		d_refCount -= 1;
		
// 		// nothing to do if not stored
// 		if (d_stored) {
// 			save();
// 		}
// 		return true;
// 	}

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
		if (art_id() == art_id) {
			return false;
		}

		// if previous art_id stored, remove safely
		if (art_id() != null) {
			var iartwork = new IArtwork(art_id());
			iartwork.decRefCount();
		}

		d_storage["art_id"] = art_id;

		// if no new artwork, nothing to do
		if (art_id() == null) {
			return true;
		}

		// reference the artwork
		var iartwork = new IArtwork(art_id());
		iartwork.incRefCount();
		return true;
	}
	 
	function setArtwork(artwork) {
		var iartwork = new IArtwork(art_id());
		return iartwork.set(artwork);
	}

	function save() {
		d_stored = EpisodeStore.save(self);
		return d_stored;
	}

	// removes the episode from the EpisodeStore
	function remove() {
		if (!d_stored) {
			return;
		}

		setRefId(null);				// delete from cache
		setArt_id(null);			// remove reference to art_id
		EpisodeStore.remove(self);		// remove self from storage
		d_stored = false;
		return;
	}
	
	// saves the new item to application storage
	function updateMeta(episode) {
		System.println("IEpisode::updateMeta( episode : " + episode.toStorage() + " )");
		
		var changed = setTime(episode.time());
		changed |= setTitle(episode.title());
		changed |= setMime(episode.mime());
		changed |= setArt_id(episode.art_id());
		if (changed) {
			d_stored = save();
		}
	}
}