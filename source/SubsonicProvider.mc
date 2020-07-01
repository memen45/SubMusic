class SubsonicProvider {
	
	private var d_api;

	private var d_callback;
	private var d_fallback;
	
	function initialize(settings) {
		d_api = new SubsonicAPI(settings, self.method(:onFailed));
	}
	
	// functions:
	// - getAllPlaylists - returns array of all playlists available for Subsonic user
	// - getPlaylistSongs - returns an array of songs on the playlist with id
	// - getRefId - returns a refId for a song by id (this downloads the song)
	//
	// to be added in the future (not possible for SubsonicAPI, so return allplaylists):
	// - getUpdatedPlaylists - returns array of all playlists updated since Moment
	
	/**
	 * getAllPlaylists
	 *
	 * returns array of all playlists available for Ampache user
	 */
	function getAllPlaylists(callback) {
		d_callback = callback;
		d_api.getPlaylists(self.method(:onGetPlaylists));
	}
	
	/**
	 * getPlaylistSongs
	 * 
	 * returns an array of songs on the playlist with id
	 */
	function getPlaylistSongs(id, callback) {
		d_callback = callback;

		var params = {
			"id" => id,
		};

		d_api.getPlaylist(self.method(:onGetPlaylist), params);
	}

	/**
	 * getRefId
	 *
	 *  returns a refId for a song by id (this downloads the song)
	 */	
	function getRefId(id, callback) {
		d_callback = callback;

		var params = {
			"id" => id,
			"format" => "mp3",
		};
		d_api.stream(self.method(:onStream), params);
	}

	function onGetPlaylists(response) {

		// construct the standard array of playlist objects
		var playlists = [];
		for (var idx = 0; idx < response.size(); ++idx) {
			playlists[idx] = {
				"id" => response[idx]["id"],
				"name" => response[idx]["name"],
				"songCount" => response[idx]["songCount"],
			};
		}
		d_callback.invoke(playlists);
	}

	function onGetPlaylist(response) {
		// construct the standard array of song objects
		var songs = [];
		for (var idx = 0; idx < response["entry"].size(); ++idx) {
			var song = response["entry"][idx];
			songs[idx] = {
				"id" => song["id"],
			};
		}
		d_callback.invoke(songs);
	}

	function onStream(refId) {
		d_callback.invoke(refId);
	}
	
	function onFailed(responseCode, data) {
		d_fallback.invoke(responseCode, data);
	}
    
    function setFallback(fallback) {
    	d_fallback = fallback;
    }
}