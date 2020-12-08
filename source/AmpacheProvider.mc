class AmpacheProvider {
	
	private var d_api;
	
	private var d_callback;
	private var d_fallback;

	// request variables needed to repeat the request if necessary
	private var d_action = null;
	private var d_params = {
		"limit" => 20,			// defines the number of songs in single response
		"offset" => 0,			// defines the offset for the last request
	};
	private var d_encoding;		// encoding parameter needed for stream
	private var d_response;		// construct full response

	enum {
		AMPACHE_ACTION_PING,
		AMPACHE_ACTION_PLAYLIST,
		AMPACHE_ACTION_PLAYLISTS,
		AMPACHE_ACTION_PLAYLIST_SONGS,
		AMPACHE_ACTION_STREAM,
	}
	
	function initialize(settings) {
		d_api = new AmpacheAPI(settings, self.method(:onError));
	}
	
	function onSettingsChanged(settings) {
		System.println("AmpacheProvider::onSettingsChanged");
		
		d_api.update(settings);
	}
	
	// functions:
	// - ping				returns an object with server version
	// - getAllPlaylists	returns array of all playlists available for Ampache user
	// - getPlaylist		returns an array of one playlist object with id
	// - getPlaylistSongs	returns an array of songs on the playlist with id
	// - getRefId			returns a refId for a song by id (this downloads the song)
	//
	// to be added in the future:
	// - getUpdatedPlaylists - returns array of all playlists updated since Moment
	
	/**
	 * ping
	 *
	 * returns an object with server version
	 */
	function ping(callback) {
		d_callback = callback;

		d_action = AMPACHE_ACTION_PING;
		do_();
	}
	
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
		d_action = AMPACHE_ACTION_PLAYLISTS;
		do_();
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
		d_action = AMPACHE_ACTION_PLAYLIST;
		do_();
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

		d_action = AMPACHE_ACTION_PLAYLIST_SONGS;
		do_();
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
		d_action = AMPACHE_ACTION_STREAM;
		do_();
	}

	function on_do_ping(response) {
		System.println("AmpacheProvider::on_do_ping( response = " + response + ")");
		
		
		d_callback.invoke(response);
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
		d_action = null;
		d_callback.invoke(d_response);
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
			d_action = null;	
			d_callback.invoke(d_response);
			return;
		}
		d_params["offset"] += d_params["limit"];	// increase offset
		do_();
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
			d_action = null;
			d_callback.invoke(d_response);
			return;
		}
		d_params["offset"] += d_params["limit"];	// increase offset
		do_();
	}

	function on_do_stream(refId) {
		d_action = null;
		d_callback.invoke(refId);
	}

	/*
	 * do_
	 * 
	 * dispatcher function from enum to api call
	 * assumes required params are set, can be repeated
	 */
	function do_() {
		// check if session still valid
		if (!d_api.session(null)) {
			d_api.handshake(self.method(:do_));
			return;
		}

		if (d_action == AMPACHE_ACTION_PING) {
			d_api.ping(self.method(:on_do_ping));
			return;
		}
		if (d_action == AMPACHE_ACTION_PLAYLIST) {
			d_api.playlist(self.method(:on_do_playlist), d_params);
			return;
		}
		if (d_action == AMPACHE_ACTION_PLAYLISTS) {
			d_api.playlists(self.method(:on_do_playlists), d_params);
			return;
		}
		if (d_action == AMPACHE_ACTION_PLAYLIST_SONGS) {
			d_api.playlist_songs(self.method(:on_do_playlist_songs), d_params);
			return;
		}
		if (d_action == AMPACHE_ACTION_STREAM) {
			d_api.stream(self.method(:on_do_stream), d_params, d_encoding);
			return;
		}

		// no valid action defined
	}
	
	function onError(error) {
	
		// if handshake error on otherwise valid session, delete session and retry handshake
		if ((error instanceof AmpacheError)
			&& (error.code() == AmpacheError.HANDSHAKE)
			&& d_api.session(null)) {
			
			d_api.deleteSession();
			do_();
			return;
		}
		
		// if response too large and limit is possible
		if ((error instanceof SubMusic.GarminSdkError)
			&& (error.respCode() == Communications.NETWORK_RESPONSE_TOO_LARGE)
			&& (d_params["limit"] > 1)) {
			
			d_params["limit"] = (d_params["limit"] / 2).toNumber();		// half the response
			System.println("AmpacheProvider limit was lowered to " + d_params["limit"]);
			do_();														// retry the request
			return;
		}
		
		d_action = null;
		d_fallback.invoke(error);
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

		// known mime types, but not supported by the sdk
		if (mime.equals("audio/x-flac")) {
			return Media.ENCODING_INVALID;
		}

		// mime type not defined
		return Media.ENCODING_INVALID;
	}
}