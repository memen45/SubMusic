using SubMusic.Utils;

class AmpacheProvider {
	
	private var d_api;
	
    // callbacks
    private var d_callback;  // callback for finished request
    private var d_fallback;  // fallback for failed request
    private var d_progress;  // intermediate callback to update request progress

	// request variables needed to repeat the request if necessary
	private var d_action = null;
	private var d_params = {};  // stores the last request parameters

	enum { MAX_COUNT = 10000, MAX_LIMIT = 20, OFFSET = 0, }
    private var d_limit = MAX_LIMIT;    // defines the number of results in a single response
    private var d_offset = OFFSET;      // defines the offset for the request
	private var d_count = MAX_COUNT;	// count objects for ranged requests

	private var d_encoding;				// encoding parameter needed for stream
	private var d_response;				// construct full response

	enum {
		AMPACHE_ACTION_PING,
		AMPACHE_ACTION_RECORD_PLAY,
		AMPACHE_ACTION_PLAYLIST,
		AMPACHE_ACTION_PLAYLISTS,
		AMPACHE_ACTION_PLAYLIST_SONGS,
		AMPACHE_ACTION_STREAM,
		AMPACHE_ACTION_GET_ART,
		AMPACHE_ACTION_PODCAST,
		AMPACHE_ACTION_PODCASTS,
		AMPACHE_ACTION_EPISODES,
	}
	
	function initialize(settings) {
		d_api = new AmpacheAPI(
			settings, 
			self.method(:onProgress),
			self.method(:onError)
		);
	}
	
	function onSettingsChanged(settings) {
		System.println("AmpacheProvider::onSettingsChanged");
		
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

		d_action = AMPACHE_ACTION_PING;
		do_();
	}
	
	function on_do_ping(response) {
		System.println("AmpacheProvider::on_do_ping( response = " + response + ")");
		
		d_action = null;
		d_callback.invoke(response);
	}

    /**
     * recordPlay
     * 
     * submit a play
     */
	function recordPlay(id, time, callback) {
		d_callback = callback;
		
		d_params = {
			"id" => id,
			"client" => d_api.client(),
			"date" =>  time,
		};
		
		d_action = AMPACHE_ACTION_RECORD_PLAY;
		do_();
	}

	function on_do_record_play(response) {
		System.println("AmpacheProvider::on_do_record_play( response = " + response + ")");
		
		d_action = null;
		d_callback.invoke(response["success"]); // expected success string
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
		d_params = {};

		// set range parameters
		d_limit = MAX_LIMIT;
		d_offset = OFFSET;

		d_action = AMPACHE_ACTION_PLAYLISTS;
		do_();
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
		checkDone(response);
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
		d_count = 1;		// expect only 1 object

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

		d_params = { "filter" => id	};

		// set range parameters
		d_limit = MAX_LIMIT;
		d_offset = OFFSET;

		d_action = AMPACHE_ACTION_PLAYLIST_SONGS;
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
				// "title" => song["title"],
				// "artist" => song["artist"]["name"],
				"time" => time.toNumber(),
				"mime" => song["mime"],
				"art_id" => song["id"],
			}));
		}
		checkDone(response);
	}

	/**
	 * getRefId
	 *
	 *  returns a refId for a song by id (this downloads the song)
	 */	
	function getRefId(id, mime, type, callback) {
		d_callback = callback;

		d_encoding = Utils.mimeToEncoding(mime);
		var format = "mp3";
		if (d_encoding == Media.ENCODING_INVALID) {
			// default to mp3 transcoding 
			d_encoding = Media.ENCODING_MP3;
		} else {
			// if mime is supported, request raw
			format = "raw";
		}

		// interpret type to string
		var typ = Audio.typeToString(type);

		d_params = {
			"id" => id,
			"type" => typ,
			"format" => format,
		};
		d_action = AMPACHE_ACTION_STREAM;
		do_();
	}

	function on_do_stream(contentRef) {
		d_action = null;
		d_callback.invoke(contentRef.getId());
	}

	/**
	 * getArtwork
	 *
	 *  returns a BitmapResource for a song/podcast by id
	 */	
	function getArtwork(id, type, callback) {
		d_callback = callback;

		var typ = Artwork.typeToString(type);
		d_params = {
			"id" => id,
			"type" => typ,
		};

		d_action = AMPACHE_ACTION_GET_ART;
		do_();
	}

	function on_do_get_art(artwork) {
		d_action = null;
		d_callback.invoke(artwork);
	}
	
	/**
	 * getAllPodcasts
	 *
	 * returns array of all podcasts available for Ampache user
	 */
	function getAllPodcasts(callback) {
		d_callback = callback;

		// create empty array as initial response
		d_response = [];
		d_params = {};

		// set range parameters
		d_limit = 5;			// use lower limit due to description
		d_offset = OFFSET;

		d_action = AMPACHE_ACTION_PODCASTS;
		do_();
	}
	
	/**
	 * getPodcast
	 *
	 * returns array of one podcast object for id
	 */
	function getPodcast(id, callback) {
		d_callback = callback;

		// create empty array as initial response
		d_response = [];
		d_count = 1;

		d_params = {
			"filter" => id,
		};
		d_action = AMPACHE_ACTION_PODCAST;
		do_();
	}
	
	/**
	 * getEpisodes
	 *
	 * returns array of episodes available for Ampache user
	 */
	function getEpisodes(id, range, callback) {
		d_callback = callback;

		// create empty array as initial response
		d_response = [];
		d_params = { "filter" => id	};

		// set range parameters
		d_limit = 5;				// use lower limit due to description
		d_offset = range[0];		// first in range is starting point
		d_count = range[1] - range[0];

		d_action = AMPACHE_ACTION_EPISODES;
		do_();
	}

	function checkDone(response) {
		// if response less than limit, or collected count objects
		// - no more requests required
		if (d_limit == null) {
			d_limit = MAX_LIMIT;
		}
		System.println("AmpacheProvider::checkDone()");
		System.println(d_response.size());
		System.println(response.size());
		System.println(d_count);
		System.println(d_limit);
		if ((d_response.size() < d_count)		// count not reached 
			&& (response.size() >= d_limit)) {	// limit reached
			// request required, since response was full and count not reached
			System.println("AmpacheProvider::checkDone - next request");
			d_offset += d_limit;	// increase offset
			do_();
			return;
		}
		
		// no more requests needed, reset and callback
		d_action = null;
		d_count = MAX_COUNT;		// reset to max count for next request
		d_callback.invoke(d_response);
	}

	function on_do_podcasts(response) {		
		// append the standard podcast objects to the array
		for (var idx = 0; idx < response.size(); ++idx) {
			var podcast = response[idx];

			d_response.add(new Podcast({
				"id" => podcast["id"],
				"name" => podcast["name"],
				"description" => podcast["description"],
				"copyright" => podcast["copyright"],
				"remote" => true,
				"art_id" => podcast["id"]
			}));
		}
		checkDone(response);
	}

	function on_do_episodes(response) {

		// count nr of episodes to add
		var count = d_count - d_response.size();
		if (response.size() < count) {
			count = response.size();
		}

		// append the standard episode objects to the array
		for (var idx = 0; idx < count; ++idx) {
			var episode = response[idx];

			d_response.add(new Episode({
				"id" => episode["id"],
				"title" => episode["title"],
				"time" => episode["filelength"],		// string, should be int
				"mime" => episode["mime"],
				"art_id" => d_params["filter"],			// set art id to id of podcast instead
				"description" => episode["description"],
			}));
		}
		checkDone(response);
	}

	/*
	 * do_
	 * 
	 * dispatcher function from enum to api call
	 * assumes required params are set, can be repeated
	 */
	function do_() {
		
		// ping does not need authentication
		if (d_action == AMPACHE_ACTION_PING) {
			d_api.ping(self.method(:on_do_ping));
			return;
		}
		
		// check if session still valid
		if (!d_api.session(null)) {
			d_api.handshake(self.method(:do_));
			return;
		}
		if (d_action == AMPACHE_ACTION_RECORD_PLAY) {
			d_api.record_play(self.method(:on_do_record_play), d_params);
			return;
		}
		if (d_action == AMPACHE_ACTION_PLAYLIST) {
			d_api.playlist(self.method(:on_do_playlists), d_params);
			return;
		}
		if (d_action == AMPACHE_ACTION_STREAM) {
			d_api.stream(self.method(:on_do_stream), d_params, d_encoding);
			return;
		}
		if (d_action == AMPACHE_ACTION_GET_ART) {
			d_api.get_art(self.method(:on_do_get_art), d_params);
			return;
		}
		if (d_action == AMPACHE_ACTION_PODCAST) {
			d_api.podcast(self.method(:on_do_podcasts), d_params);
			return;
		}

		// following requests are ranged requests, limit and offset should be provided
		d_params.put("limit", d_limit);
		d_params.put("offset", d_offset);

		if (d_action == AMPACHE_ACTION_PLAYLISTS) {
			d_api.playlists(self.method(:on_do_playlists), d_params);
			return;
		}
		if (d_action == AMPACHE_ACTION_PLAYLIST_SONGS) {
			d_api.playlist_songs(self.method(:on_do_playlist_songs), d_params);
			return;
		}
		if (d_action == AMPACHE_ACTION_PODCASTS) {
			d_api.podcasts(self.method(:on_do_podcasts), d_params);
			return;
		}
		if (d_action == AMPACHE_ACTION_EPISODES) {
			d_api.podcast_episodes(self.method(:on_do_episodes), d_params);
			return;
		}

		// no valid action defined
	}
	
	function onError(error) {
	
		// if handshake error on otherwise valid session, delete session and retry handshake
		if ((error instanceof AmpacheError)
			&& (error.type() == AmpacheError.HANDSHAKE)
			&& d_api.session(null)) {
			
			d_api.deleteSession();
			do_();
			return;
		}
		
		// if response too large and limit is possible
		if ((error instanceof SubMusic.GarminSdkError)
			&& (error.respCode() == Communications.NETWORK_RESPONSE_TOO_LARGE)
			&& (d_limit > 1)) {
			
			d_limit = (d_limit / 2).toNumber();		// half the response
			System.println("AmpacheProvider limit was lowered to " + d_limit);
			do_();														// retry the request
			return;
		}
		
		d_action = null;
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