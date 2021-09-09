class Artwork extends Storable {


	enum { SONG, ARTIST, ALBUM, PLAYLIST, SEARCH, PODCAST, END }		// only add types at end, as these are stored
    static private var s_types = [ "song", "artist", "album", "playlist", "search", "podcast" ];
	hidden var d_type;

    hidden var d_storage = {
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
        return compute_id(art_id(), type());
    }

    static function compute_id(art_id, type) {
        System.println("Artwork::compute_id() " + art_id + type);
        return (Storage.ARTWORK_PREFIX).toString() + art_id.toString() + type.toString();
    }

    function image() {
        return Application.Storage.getValue(id());
    }
}

class IArtwork extends Artwork {

    //storage access
    private var d_stored = false;       // true if artwork metadata is in storage

    function initialize(id, type) {
        System.println("IArtwork::initialize( id : " + id + " type : " + type + " )");

        var storage = ArtworkStore.get(compute_id(id, type));
        if (storage != null) {
            d_stored = true;
        } else {
            storage = {
                "art_id" => id,
                "type" => type,
            };     // nothing known yet except for id and type
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
		d_stored = ArtworkStore.save(self);
		return d_stored;
	}

	// removes the metadata from the ArtworkStore
	function remove() {
		ArtworkStore.remove(self);		// remove self from storage
        Application.Storage.deleteValue(id());
		d_stored = false;
		return;
	}
}