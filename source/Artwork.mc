class Artwork {

    hidden var d_id;                   // the id of the artwork
    hidden var d_refCount = 0;         // count of usage
    hidden var d_type = "song";                  // song / podcast / playlist, string

    function initialize(storage) {
        System.println("Artwork::initialize( storage = " + storage + ")");

        d_id = storage["id"];
        fromStorage(storage);
    }

    function toStorage() {
        return {
            "id" => d_id,
            "refCount" => d_refCount,
        };
    }

    function fromStorage(storage) {
        var changed = false;
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
	
	function refCount() {
		return d_refCount;
	}

    function type() {
        return d_type;
    }

    function get() {
        return Application.Storage.getValue(Storage.ARTWORK_PREFIX + d_id.toString());
    }
}

class IArtwork extends Artwork {

    //storage access
    private var d_stored = false;       // true if artwork metadata is in storage

    function initialize(id) {
        System.println("IArtwork::initialize( id : " + id + " )");

        var storage = ArtworkStore.get(id);
        if (storage != null) {
            d_stored = true;
        } else {
            storage = {"id" => id};     // nothing known yet except for id
        }
        Artwork.initialize(storage);
    }

    function set(artwork) {
		Application.Storage.setValue(Storage.ARTWORK_PREFIX + d_id.toString(), artwork);
        return save();
    }
	
	function incRefCount() {
		d_refCount += 1;
		return save();
	}
	
	function decRefCount() {
		d_refCount -= 1;
		return save();
	}

    function setType(type) {
        d_type = type;
    }

	function save() {
		d_stored = ArtworkStore.save(self);
		return d_stored;
	}

	// removes the metadata from the ArtworkStore
	function remove() {
		ArtworkStore.remove(self);		// remove self from storage
        Application.Storage.deleteValue(Storage.ARTWORK_PREFIX + d_id.toString());
		d_stored = false;
		return;
	}
}