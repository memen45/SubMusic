class Artist extends Storable {
    hidden var d_storage = {
        "id" => null,       // id of the artist
        "name" => "",       // name of the artist
        "albumCount" => 0,  // number of albums
        "art_id" => null,   // null if no art available
    };

    function initialize(storage) {
        Storable.initialize(storage);
    }
    
	// getters
	function id() {
		return d_storage["id"];
	}

	function name() {
		return d_storage["name"];
	}

	function art_id() {
		return d_storage["art_id"];
	}

	function artwork() {
		if (art_id() == null) {
			return null;
		}

		var artwork = new IArtwork(art_id(), Artwork.SONG);
		return artwork.image();
	}
}