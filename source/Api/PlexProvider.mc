using SubMusic.Utils;

class PlexProvider {

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
    private var d_offset = OFFSET;      // defines the offset for the ranged request
	private var d_count = MAX_COUNT;	// defines the number of objects to be received in ranged requests

    private var d_id;       // required for getPlaylist, getPlaylistSongs, getRefId, getArtwork
	private var d_encoding;				// encoding parameter needed for stream
	private var d_response;				// construct full response
    
	enum {
		PLEX_PING,
		PLEX_RECORD_PLAY,
		PLEX_PLAYLIST,
		PLEX_PLAYLISTS,
		PLEX_PLAYLIST_SONGS,
		PLEX_STREAM,
		PLEX_GET_ART,
		PLEX_PODCAST,
		PLEX_PODCASTS,
		PLEX_EPISODES,
	}

    function initialize(settings) {
        d_api = new PlexAPI(
            settings,
            self.method(:onProgress),
            self.method(:onError)
        );
    }
	
	function onSettingsChanged(settings) {
		if ($.debug) {
			System.println("PlexProvider::onSettingsChanged");
		}
		
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

        d_action = PLEX_PING;
        do_();
    }

	function on_do_ping(response) {
		if ($.debug) {
			System.println("PlexProvider::on_do_ping( response = " + response + ")");
		}
		
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
			"key" => id,
            "identifier" => "com.plexapp.plugins.library"
		};
		
		d_action = PLEX_RECORD_PLAY;
		do_();
	}

	function on_do_record_play(response) {
		if ($.debug) {
			System.println("PlexProvider::on_do_record_play( response = " + response + ")");
		}
		
		d_action = null;
		d_callback.invoke(response); // expected empty response
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
		d_params = { "playlistType" => "audio" };   // only audio playlists

		// set range parameters
		d_limit = MAX_LIMIT;
        d_offset = OFFSET;
		d_count = MAX_COUNT;

		d_action = PLEX_PLAYLISTS;
		do_();
	}

	function on_do_playlists(response) {
		
		// get the array of playlists
		response = response["Metadata"];
		if (!(response instanceof Lang.Array)) {
			response = [];
		}

		// append the standard playlist objects to the array
		for (var idx = 0; idx < response.size(); ++idx) {
			var playlist = response[idx];
			d_response.add(plex_to_playlist(playlist));
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

		d_params = {};
        d_id = id;

		d_action = PLEX_PLAYLIST;
		do_();
	}

	function on_do_playlist(response) {
		d_response.add(plex_to_playlist(response));

		d_action = null;
		d_count = MAX_COUNT;
		d_callback.invoke(d_response);
	}

	function plex_to_playlist(playlist) {
		var items = playlist["leafCount"];
		if (items == null) {
			items = 0;
		}
		return new Playlist({
			"id" => playlist["ratingKey"],
			"name" => playlist["title"],
			"songCount" => items.toNumber(),
			"remote" => true,
		});
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

		d_params = {};
        d_id = id;

        // set range parameters
		d_limit = MAX_LIMIT;
		d_offset = OFFSET;
		d_count = MAX_COUNT;

		d_action = PLEX_PLAYLIST_SONGS;
		do_();
	}

	function on_do_playlist_songs(response) {	

		// get the array of songs on the playlist
		response = response["Metadata"];
		if (!(response instanceof Lang.Array)) {
			response = [];
		}

		// append the standard song objects to the array
		for (var idx = 0; idx < response.size(); ++idx) {
			var song = response[idx];

			// new way of storing songs
			var time = song["duration"];
			if (time == null) {
				time = 0;
			}

			var container = song["Media"][0]["Part"][0]["container"];
			d_response.add(new Song({
				"id" => song["ratingKey"],
				"title" => song["title"],
				"artist" => song["grandparentTitle"],
				"time" => time.toNumber() / 1000,
				"mime" => containerToMime(container),
				"art_id" => song["art"],
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
		if (d_encoding == Media.ENCODING_INVALID) {
			// default to mp3 transcoding 
			d_encoding = Media.ENCODING_MP3;
		}

		d_params = {
			"path" => "/library/metadata/" + id,
			"download" => 1,
			"X-Plex-Client-Profile-Extra" => "add-transcode-target(type=musicProfile&context=streaming&protocol=hls&container=mpegts&audioCodec=aac,mp3)"
		};

		d_action = PLEX_STREAM;
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

		d_params = {};
		d_id = id;

		d_action = PLEX_GET_ART;
		do_();
	}

	function on_do_get_art(artwork) {
		d_action = null; 
		d_callback.invoke(artwork);
	}

	/**
	 * getAllPodcasts
	 *
	 * returns array of all podcasts available for Plex user
	 */
	function getAllPodcasts(callback) {
		if ($.debug) {
			System.println("PlexProvider::getAllPodcasts( no API method available )");
		}
		callback.invoke([]);
	}

	/**
	 * getPodcast
	 *
	 * returns array of all podcasts available for Plex user
	 */
	function getPodcast(id, callback) {
		if ($.debug) {
			System.println("PlexProvider::getPodcast( no API method available )");
		}
		callback.invoke([]);
	}

	/**
	 * getEpisodes
	 *
	 * returns an array of episodes in the podcast with id
	 */
	function getEpisodes(id, range, callback) {
		if ($.debug) {
			System.println("PlexProvider::getEpisodes( no API method available )");
		}
		callback.invoke([]);
	}
    
	function checkDone(response) {
		// if response less than limit, or collected count objects
		// - no more requests required
		if (d_limit == null) {
			d_limit = MAX_LIMIT;
		}

		if ($.debug) {
			System.println("PlexProvider::checkDone()");
			System.println("Total received: " + d_response.size());
			System.println("Last received: " + response.size());
			System.println("Max total: " + d_count);
			System.println("Max at once: " + d_limit);
		}

		if ((d_response.size() < d_count)		// count not reached 
			&& (response.size() >= d_limit)) {	// limit reached
			// request required, since response was full and count not reached
			if ($.debug) {
				System.println("PlexProvider::checkDone - next request");
			}
			d_offset += d_limit;	// increase offset
			do_();
			return;
		}
		
		// no more requests needed, reset and callback
		d_action = null;
		d_count = MAX_COUNT;		// reset to max count for next request
		d_callback.invoke(d_response);
	}

	/*
	 * do_
	 * 
	 * dispatcher function from enum to api call
	 * assumes required params are set, can be repeated
	 */
	function do_() {
		
		// ping does not need authentication
		if (d_action == PLEX_PING) {
			d_api.identity(self.method(:on_do_ping));
			return;
		}
		if (d_action == PLEX_RECORD_PLAY) {
			d_api.scrobble(self.method(:on_do_record_play), d_params);
			return;
		}
		if (d_action == PLEX_STREAM) {
			d_api.music_transcode(self.method(:on_do_stream), d_params, d_encoding);
			return;
		}
		if (d_action == PLEX_GET_ART) {
			d_api.photo_transcode(self.method(:on_do_get_art), d_params, d_id);
			return;
		}
		// if (d_action == PLEX_PODCAST) {
		// 	d_api.podcast(self.method(:on_do_podcasts), d_params);
		// 	return;
		// }

        // following requests are ranged requests, limit and offset should be provided
        d_params.put("X-Plex-Container-Size", d_limit);
        d_params.put("X-Plex-Container-Start", d_offset);

		if (d_action == PLEX_PLAYLIST) {
			d_api.playlists_items(self.method(:on_do_playlist), d_params, d_id);
			return;
		}
		if (d_action == PLEX_PLAYLISTS) {
			d_api.playlists(self.method(:on_do_playlists), d_params);
			return;
		}
		if (d_action == PLEX_PLAYLIST_SONGS) {
			d_api.playlists_items(self.method(:on_do_playlist_songs), d_params, d_id);
			return;
		}
		// if (d_action == PLEX_PODCASTS) {
		// 	d_api.podcasts(self.method(:on_do_podcasts), d_params);
		// 	return;
		// }
		// if (d_action == PLEX_EPISODES) {
		// 	d_api.podcast_episodes(self.method(:on_do_episodes), d_params);
		// 	return;
		// }

		// no valid action defined
	}

    function onError(error) {

        // if response too large and limit is possible
		if ((error instanceof SubMusic.GarminSdkError)
			&& (error.respCode() == Communications.NETWORK_RESPONSE_TOO_LARGE)
			&& (d_limit > 1)) {
			
			d_limit = (d_limit / 2).toNumber();		// half the response
			if ($.debug) {
				System.println("PlexProvider limit was lowered to " + d_limit);
			}
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

	function containerToMime(container) {
		var map = {
			"mp3" => "audio/mpeg",
			"mp4" => "audio/mp4",
			"wav" => "audio/wav",
		};
		if (!(container instanceof Lang.String)) {
			container = "mp3";
		}
		return map[container];
	}
}