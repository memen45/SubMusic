using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using SubMusic;
using SubMusic.Utils;
using SubMusic.Storage;

// class for interfacing with a subsonic API endpoint
class SubsonicAPI extends Api {

	private var d_params = {};
	private var d_options = {};
	
	function initialize(settings, progress, fallback) {
		Api.initialize("/rest/");
		update(settings);			// call overridden updater from here

		// set callbacks
		Api.setProgressCallback(progress);
		Api.setFallback(fallback);

    	System.println("SubsonicAPI::initialize(client name: " + client() + " )");

		d_params.put("c", client());
		d_params.put("v", "1.10.2");		// subsonic api version
		d_params.put("f", "json");			// request format
		// params "u" and "p" are set through updateUsr and updateKey respectively
	}
	
	function ping(callback) {
		Api.setCallback(callback);
		
		var url = url() + "ping";
    	Communications.makeWebRequest(url, d_params, d_options, self.method(:onResponse));
    }
	
	function scrobble(callback, params) {
		System.println("SubsonicAPI::scrobble(params: " + params + ")");
	
		Api.setCallback(callback);
		
		var url = url() + "scrobble";
		
		// construct parameters
		var id = params["id"];
		var time = params["time"];
		params = Utils.copy(d_params);
		params["id"] = id;			// set id for scrobble
		params["time"] = time;		// set time for scrobble
		
    	Communications.makeWebRequest(url, params, d_options, self.method(:onResponse));
    }

	function onResponse(responseCode, data) {
		System.println("SubsonicAPI::onResponse( responseCode: " + responseCode + ", data: " + data + ")");		
		
		// check if request was successful and response is ok
    	var error = Api.checkDictionaryResponse(responseCode, data);
    	if (error) {
    		d_fallback.invoke(error);	// add function name and variables available ?
    		return;
    	}
		d_callback.invoke(data["subsonic-response"]);
	}
	
	/**
	 * getPlaylists
	 *
	 * returns all playlists the user is allowed to play.
	 */
	function getPlaylists(callback) {
		System.println("SubsonicAPI::getPlaylists");
		
		Api.setCallback(callback);
		
		var url = url() + "getPlaylists";
    	Communications.makeWebRequest(url, d_params, d_options, self.method(:onGetPlaylists));
	}
	
	function onGetPlaylists(responseCode, data) {
		System.println("SubsonicAPI::onGetPlaylists( responseCode: " + responseCode + ", data: " + data + ")");		
		
		// check if request was successful and response is ok
    	var error = Api.checkDictionaryResponse(responseCode, data);
    	if (error) {
    		d_fallback.invoke(error);	// add function name and variables available ?
    		return;
    	}
    	
    	var response = data["subsonic-response"]["playlists"]["playlist"];
		
		d_callback.invoke(response);
	}
	
	/**
	 * getPodcasts
	 *
	 * returns all podcasts the user is allowed to play.
	 */
	function getPodcasts(callback, params) {
		System.println("SubsonicAPI::getPodcasts(params: " + params + ")");
		
		Api.setCallback(callback);
		
		var url = url() + "getPodcasts";

		// construct parameters 
		params = Utils.merge(d_params, params);

    	Communications.makeWebRequest(url, params, d_options, self.method(:onGetPodcasts));
	}
	
	function onGetPodcasts(responseCode as Lang.Number, data as Lang.Dictionary or Null) {
		System.println("SubsonicAPI::onGetPodcasts( responseCode: " + responseCode + ", data: " + data + ")");		
		
		// check if request was successful and response is ok
    	var error = Api.checkDictionaryResponse(responseCode, data);
    	if (error) {
    		d_fallback.invoke(error);	// add function name and variables available ?
    		return;
    	}
    	
    	var response = data["subsonic-response"]["podcasts"]["channel"];

		d_callback.invoke(response);
	}
		
	
	/**
	 * getPlaylist
	 *
	 * returns a listing of files in a saved playlist
	 */
	function getPlaylist(callback, params) {
		System.println("SubsonicAPI::getPlaylist(params: " + params + ")");
	
		Api.setCallback(callback);
		
		var url = url() + "getPlaylist";
		
		// construct parameters
		var id = params["id"];
		params = Utils.copy(d_params);
		params["id"] = id;			// set id for playlist

    	Communications.makeWebRequest(url, params, d_options, self.method(:onGetPlaylist));
    }
    
    function onGetPlaylist(responseCode, data) {
    	System.println("Subsonic::onGetPlaylist(responseCode: " + responseCode + ", data: " + data);
    	
		// check if request was successful and response is ok
	   	var error = Api.checkDictionaryResponse(responseCode, data);
    	if (error) {
    		d_fallback.invoke(error);	// add function name and variables available ?
    		return;
    	}
    	d_callback.invoke(data["subsonic-response"]["playlist"]);
    }
    
    /**
     * stream
     *
     * downloads a given media file
     */
    function stream(callback, params, encoding) {
    	System.println("SubsonicAPI::stream( params: " + params + ")");
    
    	Api.setCallback(callback);
    
		var url = url() + "stream";

		// construct parameters
		var id = params["id"];
		var format = params["format"];
		params = Utils.copy(d_params);
		params["id"] = id;
		params["format"] = format;
		
		// additional options
    	var options = {
    		:method => Communications.HTTP_REQUEST_METHOD_GET,
          	:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
          	:mediaEncoding => encoding,
			:fileDownloadProgressCallback => method(:onProgress),
   		};
		options = SubMusic.Utils.merge(options, d_options);

    	Communications.makeWebRequest(url, params, options, self.method(:onStream));
    }
    
    function onStream(responseCode, data) {
    	System.println("SubsonicAPI::onStream with responseCode: " + responseCode);
    	
		// check if request was successful and response is ok
		var error = Api.checkContentResponse(responseCode, data);
		if (error) {
    		d_fallback.invoke(error);
			return;
		}
    	d_callback.invoke(data);
    }
    
    /**
     * getCoverArt
     *
     * downloads artwork for given media id
     */
    function getCoverArt(callback, params) {
    	System.println("SubsonicAPI::getCoverArt( params: " + params + ")");
    	
    	System.println("d_params = " + d_params);
    
    	Api.setCallback(callback);
    
		var url = url() + "getCoverArt";

		// construct parameters
		var id = params["id"];
		params = Utils.copy(d_params);
		params["id"] = id;

		params["size"] = 100;
		
		// additional options
		var options = {
			:maxWidth => 100,
			:maxHeight => 100,
			:fileDownloadProgressCallback => method(:onProgress),
		};
		options = SubMusic.Utils.merge(options, d_options);

    	Communications.makeImageRequest(url, params, options, self.method(:onGetCoverArt));
    }
    
    function onGetCoverArt(responseCode, data) {
    	System.println("SubsonicAPI::onGetCoverArt with responseCode: " + responseCode + " and " + data);
    	
		// check if request was successful and response is ok
		var error = Api.checkImageResponse(responseCode, data);
		if (error) {
			d_fallback.invoke(error);
			return;
		}
    	d_callback.invoke(data);
    }

	// @override
	function checkApiError(responseCode, data) {
		return SubsonicError.is(responseCode, data);
	}

	// @override
	function update(settings) {
		Api.update(settings);					// normal update
		updateAut(settings.get("api_aut"));		// add auth update
	}

	// @override
	function updateUsr(usr) {
		Api.updateUsr(usr);
		d_params.put("u", usr);
	}

	// @override
	function updateKey(key) {
		Api.updateKey(key);
		d_params.put("p", key);
	}

	function updateAut(aut) {
		// clear authentication headers 
		if (aut == Storage.ApiAuthMethod.API_AUTH) {
			d_options = {};
			return;
		}
		
		// set header if auth method is set to HTTP Basic
		var options = {
			:fromRepresentation => StringUtil.REPRESENTATION_STRING_PLAIN_TEXT,
			:toRepresentation => StringUtil.REPRESENTATION_STRING_BASE64,
		};
		var creds = StringUtil.convertEncodedString(usr() + ":" + key(), options);
		d_options = {
			:headers => {
				"Authorization" => "Basic " + creds,
			}
		};
	}
}