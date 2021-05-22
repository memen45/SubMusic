using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.System;
using SubMusic;

// class for interfacing with a subsonic API endpoint
class SubsonicAPI extends Api {

	private var d_params = {};
	
	function initialize(settings, progress, fallback) {
		Api.initialize("/rest/");
		Api.update(settings);

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
    	Communications.makeWebRequest(url, d_params, {}, self.method(:onResponse));
    }
	
	function scrobble(callback, params) {
		System.println("SubsonicAPI::scrobble(params: " + params + ")");
	
		Api.setCallback(callback);
		
		var url = url() + "scrobble";
		
		// construct parameters
		var id = params["id"];
		var time = params["time"];
		params = copy(d_params);
		params["id"] = id;			// set id for scrobble
		params["time"] = time;		// set time for scrobble
		
    	Communications.makeWebRequest(url, params, {}, self.method(:onResponse));
    }

	function onResponse(responseCode, data) {
		System.println("SubsonicAPI::onResponse( responseCode: " + responseCode + ", data: " + data + ")");		
		
		// check if request was successful and response is ok
    	var error = checkResponse(responseCode, data);
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
    	Communications.makeWebRequest(url, d_params, {}, self.method(:onGetPlaylists));
	}
	
	function onGetPlaylists(responseCode, data) {
		System.println("SubsonicAPI::onGetPlaylists( responseCode: " + responseCode + ", data: " + data + ")");		
		
		// check if request was successful and response is ok
    	var error = checkResponse(responseCode, data);
    	if (error) {
    		d_fallback.invoke(error);	// add function name and variables available ?
    		return;
    	}
    	
    	var response = data["subsonic-response"]["playlists"]["playlist"];
    	
    	// finally, expecting array as response
		if (!(response instanceof Lang.Array)) { 
			d_fallback.invoke(new SubsonicError(null));
			return;
		 }
		
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
		params = copy(d_params);
		params["id"] = id;			// set id for playlist
		
    	var options = {
    		:method => Communications.HTTP_REQUEST_METHOD_GET,
    	};
    	Communications.makeWebRequest(url, params, options, self.method(:onGetPlaylist));
    }
    
    function onGetPlaylist(responseCode, data) {
    	System.println("Subsonic::onGetPlaylist(responseCode: " + responseCode + ", data: " + data);
    	
		// check if request was successful and response is ok
	   	var error = checkResponse(responseCode, data);
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
		params = copy(d_params);
		params["id"] = id;
		params["format"] = format;
		
    	var options = {
    		:method => Communications.HTTP_REQUEST_METHOD_GET,
          	:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
          	:mediaEncoding => encoding,
			:fileDownloadProgressCallback => method(:onProgress),
   		};
    	Communications.makeWebRequest(url, params, options, self.method(:onStream));
    }
    
    function onStream(responseCode, data) {
    	System.println("SubsonicAPI::onStream with responseCode: " + responseCode);
    	
		// check if request was successful and response is ok
		var error = checkResponse(responseCode, data);
		if (error) {
    		d_fallback.invoke(error);
			return;
		}
    	d_callback.invoke(data.getId());
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
		params = copy(d_params);
		params["id"] = id;

		params["size"] = 100;
		
		var options = {
			:maxWidth => 100,
			:maxHeight => 100,
			:fileDownloadProgressCallback => method(:onProgress),
		};
    	Communications.makeImageRequest(url, params, options, self.method(:onGetCoverArt));
    }
    
    function onGetCoverArt(responseCode, data) {
    	System.println("SubsonicAPI::onGetCoverArt with responseCode: " + responseCode + " and " + data);
    	
		// check if request was successful and response is ok
		var error = checkResponse(responseCode, data);
		if (error) {
    		d_fallback.invoke(error);
			return;
		}
    	d_callback.invoke(data);
    }

	function checkResponse(responseCode, data) {
		var error = Api.checkResponse(responseCode, data);
		if (error) { return error; }
		return SubsonicError.is(responseCode, data);
	}

	function copy(dict) {
		var ret = {};
		for (var idx = 0; idx < dict.keys().size(); ++idx) {
			var key = dict.keys()[idx];
			ret.put(key, dict.get(key));
		}
		return ret;
	}
    
    // function update(settings) {
	// 	System.println("SubsonicAPI::update(settings)");
		
	// 	// update the settings
    // 	set(settings);

	// 	// no persistent session info, so only update variables for future requests
   	// }

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
    
    // function set(settings) {
    // 	d_base_url = settings.get("api_url") + "/rest/";
	// 	d_params.put("u", settings.get("api_usr"));
    // 	d_params.put("p", settings.get("api_key"));

    // 	System.println("SubsonicAPI::set(url: " + d_base_url + " user: " + d_params.get("u") + ", pass: " + d_params.get("p") + ")");
    // }
}