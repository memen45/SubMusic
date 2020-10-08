class AmpacheProvider {
	
	private var d_api;
	private var d_params = {
		"limit" => 20,			// defines the number of songs in single response
		"offset" => 0,			// defines the offset for the last request
	};
	private var d_encoding;		// encoding parameter needed for stream
	private var d_response;		// construct full response

	private var d_callback;
	private var d_fallback;
	
	function initialize(settings) {
		d_api = new AmpacheAPI(settings, self.method(:onFailed));
	}
	
	function onSettingsChanged(settings) {
		d_api.update(settings);
	}
	
	// functions:
	// - getAllPlaylists - returns array of all playlists available for Ampache user
	// - getPlaylistSongs - returns an array of songs on the playlist with id
	// - getRefId - returns a refId for a song by id (this downloads the song)
	//
	// to be added in the future:
	// - getUpdatedPlaylists - returns array of all playlists updated since Moment
	
	/**
	 * getAllPlaylists
	 *
	 * returns array of all playlists available for Ampache user
	 */
	function getAllPlaylists(callback) {
		d_callback = callback;

		// create empty array as initial response
		d_response = [];
		d_params = {
			"limit" => 20,
			"offset" => 0,
		};
		do_playlists();
	}

	/**
	 * getPlaylist
	 *
	 * returns an array of one playlist object for id
	 */
	function getPlaylist(id, callback) {
		d_callback = callback;

		// create empty array as initial response
		d_response = [];
		d_params = {
			"filter" => id,
		};
		do_playlist();
	}
	
	/**
	 * getPlaylistSongs
	 * 
	 * returns an array of songs on the playlist with id
	 */
	function getPlaylistSongs(id, callback) {
		d_callback = callback;

		// create empty response
		d_response = [];
		d_params = {
			"filter" => id,
			"limit" => 20,
			"offset" => 0,
		};

		do_playlist_songs();
	}

	/**
	 * getRefId
	 *
	 *  returns a refId for a song by id (this downloads the song)
	 */	
	function getRefId(id, mime, callback) {
		d_callback = callback;

		d_encoding = mimeToEncoding(mime);
		var format = "mp3";
		if (d_encoding == Media.ENCODING_INVALID) {
			// default to mp3 transcoding 
			d_encoding = Media.ENCODING_MP3;
		} else {
			// if mime is supported, request raw
			format = "raw";
		}
		var type = "song";

		d_params = {
			"id" => id,
			"type" => type,
			"format" => format,
		};
		do_stream();
	}

	function do_playlist() {
		if (!d_api.session(null)) {
			d_api.handshake(self.method(:do_playlist));
			return;
		}
		d_api.playlist(self.method(:on_do_playlist), d_params);
	}

	function on_do_playlist(response) {
		// append the standard playlist objects to the array
		for (var idx = 0; idx < response.size(); ++idx) {
			var playlist = response[idx];
			var items = playlist["items"];
			if (items == null) {
				items = 0;
			}
			d_response.add(new Playlist({
				"id" => playlist["id"],
				"name" => playlist["name"],
				"songCount" => items.toNumber(),
				"remote" => true,
			}));
		}
		d_callback.invoke(d_response);
	}
	
	function do_playlists() {
		if (!d_api.session(null)) {
			d_api.handshake(self.method(:do_playlists));
			return;
		}
		d_api.playlists(self.method(:on_do_playlists), d_params);
	}

	function on_do_playlists(response) {		
		// append the standard playlist objects to the array
		for (var idx = 0; idx < response.size(); ++idx) {
			var playlist = response[idx];
			var items = playlist["items"];
			if (items == null) {
				items = 0;
			}
			d_response.add(new Playlist({
				"id" => playlist["id"],
				"name" => playlist["name"],
				"songCount" => items.toNumber(),
				"remote" => true,
			}));
		}

		// if less than limit, no more requests required
		if (response.size() < d_params["limit"]) {	
			d_callback.invoke(d_response);
			return;
		}
		d_params["offset"] += d_params["limit"];	// increase offset
		do_playlists();
	}

	function do_playlist_songs() {
		if (!d_api.session(null)) {
			d_api.handshake(self.method(:do_playlist_songs));
			return;
		}
		d_api.playlist_songs(self.method(:on_do_playlist_songs), d_params);
	}

	function on_do_playlist_songs(response) {		
		// append the standard song objects to the array
		for (var idx = 0; idx < response.size(); ++idx) {
			var song = response[idx];

			// new way of storing songs
			var time = song["time"];
			if (time == null) {
				time = 0;
			}
			d_response.add(new Song({
				"id" => song["id"],
				"time" => time.toNumber(),
				"mime" => song["mime"],
			}));
		}

		if (response.size() < d_params["limit"]) {
			d_callback.invoke(d_response);
			return;
		}
		d_params["offset"] += d_params["limit"];	// increase offset
		do_playlist_songs();
	}

	function do_stream() {
		// check if session still valid
		if (!d_api.session(null)) {
			d_api.handshake(self.method(:do_stream));
			return;
		}
		d_api.stream(self.method(:on_do_stream), d_params, d_encoding);
	}

	function on_do_stream(refId) {
		d_callback.invoke(refId);
	}

	function onFailed(responseCode, data) {
		d_fallback.invoke(responseCode, data);
	}
    
    function setFallback(fallback) {
    	d_fallback = fallback;
    }

	function mimeToEncoding(mime) {
		// mime should be a string
		if (!(mime instanceof Lang.String)) {
			return Media.ENCODING_INVALID;
		}
		// check docs: https://developer.mozilla.org/en-US/docs/Web/Media/Formats/Containers
		if (mime.equals("audio/mpeg")) {
			return Media.ENCODING_MP3;
		}
		if (mime.equals("audio/mp4")) {
			return Media.ENCODING_M4A;
		}
		if (mime.equals("audio/aac")) {
			return Media.ENCODING_ADTS;
		}
		if (mime.equals("audio/wave")
			|| mime.equals("audio/wav")
			|| mime.equals("audio/x-wav")
			|| mime.equals("audio/x-pn-wav")) {
			return Media.ENCODING_WAV;
		}
		return Media.ENCODING_INVALID;
	}
}