using SubMusic.Utils;

class SubsonicProvider {
	
	private var d_api;

    // callbacks
    private var d_callback;  // callback for finished request
    private var d_fallback;  // fallback for failed request
    private var d_progress;  // intermediate callback to update request progress
	
	private var d_range;		// stores range for ranged requests

	function initialize(settings) {
		d_api = new SubsonicAPI(
			settings, 
			self.method(:onProgress), 
			self.method(:onError)
		);
	}
	
	function onSettingsChanged(settings) {
		System.println("SubsonicProvider::onSettingsChanged");
		
		d_api.update(settings);
	}
	
	// functions:
	// - ping				returns an object with server version
	// - recordPlay			submit a play
	// - getAllPlaylists	returns an array of all playlists available for Ampache user
	// - getPlaylist		returns an array of one playlist object for id
	// - getPlaylistSongs	returns an array of songs on the playlist with id
	// - getRefId			returns a refId for a song by id (this downloads the song)
	// - getArtwork			returns a BitmapResource for a song id
	// - getAllPodcasts		returns an array of all podcasts available for Ampache user
	// - getPodcast			returns an array of one podcast object for id
	// - getEpisodes		returns an array of episodes in the podcast with id
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
		
		d_api.ping(self.method(:onPing));
	}
	
	function recordPlay(id, time, callback) {
		d_callback = callback;
		
		var params = {
			"id" => id,
			"time" => time,
		};
		d_api.scrobble(self.method(:onRecordPlay), params);		// scrobble is only way to submit a play
	}

	/**
	 * getAllPlaylists
	 *
	 * returns array of all playlists available for Ampache user
	 */
	function getAllPlaylists(callback) {
		d_callback = callback;
		d_api.getPlaylists(self.method(:onGetAllPlaylists));
	}

	/**
	 * getPlaylist
	 *
	 * returns an array of one playlist object for id
	 */
	function getPlaylist(id, callback) {
		d_callback = callback;

		var params = {
			"id" => id,
		};
		d_api.getPlaylist(self.method(:onGetPlaylist), params);
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

		d_api.getPlaylist(self.method(:onGetPlaylistSongs), params);
	}

	/**
	 * getRefId
	 *
	 *  returns a refId for a song by id (this downloads the song)
	 */	
	function getRefId(id, mime, type, callback) {
		d_callback = callback;

		var encoding = SubMusic.Utils.mimeToEncoding(mime);
		var format = "mp3";
		if (encoding == Media.ENCODING_INVALID) {
			// default to mp3 transcoding
			encoding = Media.ENCODING_MP3;
		} else {
			// if mime is supported, request raw
			format = "raw";
		}
		var params = {
			"id" => id,
			"format" => format,
		};
		d_api.stream(self.method(:onStream), params, encoding);
	}

	/**
	 * getArtwork
	 *
	 *  returns artwork for an object by id, type is not used here
	 */	
	function getArtwork(id, type, callback) {
		d_callback = callback;

		var params = {
			"id" => id,
		};
		d_api.getCoverArt(self.method(:onGetCoverArt), params);
	}

	/**
	 * getAllPodcasts
	 *
	 * returns array of all podcasts available for Subsonic user
	 */
	function getAllPodcasts(callback) {
		d_callback = callback;

		var params = {
			// id left blank to receive all
			"includeEpisodes" => "false",
		};
		d_api.getPodcasts(self.method(:onGetPodcasts), params);
	}

	/**
	 * getPodcast
	 *
	 * returns array of all podcasts available for Subsonic user
	 */
	function getPodcast(id, callback) {
		d_callback = callback;

		var params = {
			"id" => id,
			"includeEpisodes" => "false",
		};
		d_api.getPodcasts(self.method(:onGetPodcasts), params);
	}

	/**
	 * getEpisodes
	 *
	 * returns array of all episodes available for Subsonic user
	 */
	function getEpisodes(id, range, callback) {
		d_callback = callback;

		d_range = range;	// only used to slice response
		
		var params = {
			"id" => id,
			// includeEpisodes is true by default
		};
		d_api.getPodcasts(self.method(:onGetEpisodes), params);
	}
	
	function onPing(response) {
		System.println("SubsonicProvider::onPing( response = " + response + ")");
		
		
		d_callback.invoke(response);
	}
	
	function onRecordPlay(response) {
		System.println("SubsonicProvider::onRecordPlay( response = " + response + ")");
		
		d_callback.invoke(response); // expected empty element
	}

	function onGetAllPlaylists(response) {
		System.println("SubsonicProvider::onGetAllPlaylists( response = " + response + ")");
		
		// response should be array, and have length
		if (!(response instanceof Lang.Array)
			|| (response.size() == 0)) {
			d_callback.invoke([]);
			return;
		}
		
		// construct the standard array of playlist objects
		var playlists = [];
		
		// construct the playlist instance
		for (var idx = 0; idx < response.size(); ++idx) {
			var playlist = response[idx];

			var songCount = playlist["songCount"];
			if (songCount == null) {
				songCount = 0;		// assume 0 if not defined
			}
			
			playlists.add(new Playlist({
				"id" => playlist["id"],
				"name" => playlist["name"],
				"songCount" => songCount.toNumber(),
				"remote" => true,
			}));
		}
		d_callback.invoke(playlists);
	}

	function onGetPodcasts(response) {
		System.println("SubsonicProvider::onGetPodcasts( response = " + response + ")");
		
		// response should be array, and have length
		if (!(response instanceof Lang.Array)
			|| (response.size() == 0)) {
			d_callback.invoke([]);
			return;
		}
		
		// construct the standard array of podcast objects
		var podcasts = [];
		
		// construct the podcast instances
		for (var idx = 0; idx < response.size(); ++idx) {
			var podcast = response[idx];
			podcasts.add(new Podcast({
				"id" => podcast["id"],
				"name" => podcast["title"],
				"description" => podcast["description"],
				"copyright" => podcast["copyright"],
				"remote" => true,
				"art_id" => podcast["coverArt"],
			}));
		}
		d_callback.invoke(podcasts);
	}

	function onGetEpisodes(response) {
		System.println("SubsonicProvider::onGetEpisodes( response = " + response + ")");
		
		// assume id ensures first item is needed
		if ( (response.size() == 0) 
			|| (response[0] == null)
			|| (response[0]["episode"] == null)) {
			d_callback.invoke([]);
			return;
		}
		
		response = response[0]["episode"];

		// response should be array, and have length
		if (!(response instanceof Lang.Array)
			|| (response.size() == 0)) {
			d_callback.invoke([]);
			return;
		}

		// construct the standard array of song objects
		var episodes = [];

		var start = d_range[0];
		var end = d_range[1];
		if (response.size() < end) {
			end = response.size();
		}
		
		// construct the song instances array
		for (var idx = start; idx != end; ++idx) {
			var episode = response[idx];

			var time = episode["duration"];
			if (time == null) {
				time = 0;
			}
			episodes.add(new Episode({
				"id" => episode["id"],
				"title" => episode["title"],
				"time" => time.toNumber(),
				"mime" => episode["contentType"],
				"art_id" => episode["coverArt"],
			}));
		}
		
		d_callback.invoke(episodes);
	}

	function onGetPlaylist(response) {
		System.println("SubsonicProvider::onGetPlaylist( response = " + response + ")");
		
		var songCount = response["songCount"];
		if (songCount == null) {
			songCount = 0;		// assume 0 if not defined
		}

		d_callback.invoke([new Playlist({
				"id" => response["id"],
				"name" => response["name"],
				"songCount" => songCount.toNumber(),
				"remote" => true,
		})]);
	}

	function onGetPlaylistSongs(response) {
		System.println("SubsonicProvider::onGetPlaylistSongs( response = " + response + ")");
		
		response = response["entry"];

		// response should be array, and have length
		if (!(response instanceof Lang.Array)
			|| (response.size() == 0)) {
			d_callback.invoke([]);
			return;
		}

		// construct the standard array of song objects
		var songs = [];
		
		// construct the song instances array
		for (var idx = 0; idx < response.size(); ++idx) {
			var song = response[idx];

			var time = song["duration"];
			if (time == null) {
				time = 0;
			}
			songs.add(new Song({
				"id" => song["id"],
				"title" => song["title"],
				"artist" => song["artist"],
				"time" => time.toNumber(),
				"mime" => song["contentType"],
				"media_url" => song["id"],
				"art_id" => song["coverArt"],
			}));
		}
		
		d_callback.invoke(songs);
	}

	function onStream(contentRef) {
		d_callback.invoke(contentRef.getId());
	}

	function onGetCoverArt(artwork) {
		d_callback.invoke(artwork);
	}
	
	function onError(error) {
		d_fallback.invoke(error);
	}

	function onProgress(progress) {
		d_progress.invoke(progress);
	}
    
    function setFallback(fallback) {
    	d_fallback = fallback;
    }

	function setProgressCallback(progress) {
		d_progress = progress;
	}
}