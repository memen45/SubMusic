class AmpacheProvider {
	
	private var d_api;
	private var d_params = {
		"limit" => 20,			// defines the number of songs in single response
		"offset" => 0,			// defines the offset for the last request
	};
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
	function getRefId(id, callback) {
		d_callback = callback;

		d_params = {
			"id" => id,
			"type" => "song",
			"format" => "mp3",
		};
		do_stream();
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
			d_response.add({
				"id" => playlist["id"],
				"name" => playlist["name"],
				"songCount" => playlist["items"].toNumber(),
			});
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
			d_response.add({
				"id" => song["id"],
				"time" => song["time"].toNumber(),
			});
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
		d_api.stream(self.method(:on_do_stream), d_params);
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
}