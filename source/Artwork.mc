using SubMusic.Storage;

class Artwork extends Storable {

	enum { SONG, ARTIST, ALBUM, PLAYLIST, SEARCH, PODCAST, END }		// only add types at end, as these are stored
    static private var s_types = [ "song", "artist", "album", "playlist", "search", "podcast" ];

    hidden var d_storage = {
        "id" => null,
        "art_id" => null,
        "type" => Audio.SONG,
        "refCount" => 0,
    };

    function initialize(storage) {
        System.println("Artwork::initialize( storage = " + storage + ")");

        Storable.initialize(storage);
    }

    // getters
    function art_id() {
        return get("art_id");
    }
	
	function refCount() {
		return get("refCount");
	}

    function type() {
        return get("type");
    }

    static function typeToString(type) {
        return s_types[type];
    }

    function id() {
        // only compute id once. art_id and type are fixed after creation
        if (get("id") == null) {
            set("id", compute_id(art_id(), type()));
        }
        return get("id");
    }

    static function compute_id(art_id, type) {
        // System.println("Artwork::compute_id() for art_id: " + art_id + ", type: " + type + " )");
        if (art_id == null) {
            return null;
        }
        return (Storage.ARTWORK_PREFIX).toString() + art_id.toString() + type.toString();
    }

    function image() {
        if (id() == null) {
            return null;
        }
        return Application.Storage.getValue(id());
    }
}

class IArtwork extends Artwork {

    //storage access
    private var d_stored = false;       // true if artwork metadata is in storage

    function initialize(art_id, type) {
        System.println("IArtwork::initialize( art_id : " + art_id + " type : " + type + " )");

        var id = compute_id(art_id, type);
        var storage = ArtworkStore.get(id);
        if (storage != null) {
            d_stored = true;
            storage["id"] = id;     // tmp fix for bw compat
        } else {
            storage = {
                "id" => id,
                "art_id" => art_id,
                "type" => type,
            };     // nothing known yet except for id, art_id and type
        }
        Artwork.initialize(storage);
    }

    function setImage(artwork) {
		Application.Storage.setValue(id(), artwork);
        return save();
    }
	
	function incRefCount() {
		set("refCount", refCount() + 1);
		return save();
	}
	
	function decRefCount() {
		set("refCount", refCount() - 1);
		return save();
	}

	function save() {
        // do not save if id invalid
        if (art_id == null) {
            return false;
        }
        
		d_stored = ArtworkStore.save(self);
		return d_stored;
	}

	// removes the metadata from the ArtworkStore
	function remove() {
		ArtworkStore.remove(self);		// remove self from storage
		d_stored = false;
        Application.Storage.deleteValue(id()); // remove the downloaded image
		return;
	}
}