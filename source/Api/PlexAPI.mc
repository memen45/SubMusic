using SubMusic.Utils;

class PlexAPI extends Api {

    private var d_params = {};
    private var d_options = { :headers => { "Accept" => "application/json" } };

    function initialize(settings, progress, fallback) {
        Api.initialize("");
        Api.update(settings);

		// set callbacks
		Api.setProgressCallback(progress);
		Api.setFallback(fallback);

    	System.println("PlexAPI::initialize(client name: " + client() + " )");

        d_params.put("X-Plex-Platform", System.getDeviceSettings().partNumber);
        d_params.put("X-Plex-Device-Name", client());
    }

    function identity(callback) {
        Api.setCallback(callback);

        var url = url() + "/identity";
		var options = {
			:responseType => HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN,
		};
		options = SubMusic.Utils.merge(options, d_options);

        Communications.makeWebRequest(url, {}, options, self.method(:onResponse));
    }

	function scrobble(callback, params) {
		System.println("PlexAPI::scrobble(params: " + params + ")");
	
		Api.setCallback(callback);
		
		var url = url() + "/:/scrobble";
		
		// construct parameters
		params = SubMusic.Utils.merge(params, d_params);

		Communications.makeWebRequest(url, params, d_options, self.method(:onScrobble));
	}

	function onScrobble(responseCode, data) {
		System.println("PlexAPI::onScrobble( responseCode: " + responseCode + ", data: " + data + ")");		
		
		var error = Api.checkResponse(responseCode, data);
		if (error) {
			d_fallback.invoke(error);
			return;
		}
		d_callback.invoke(data);
	}
	
	/*
	 * onIdentity
	 *
	 * checks Dictionary response and returns the MediaContainer element
	 */
	function onResponse(responseCode, data) {
		System.println("PlexAPI::onResponse with responseCode " + responseCode + " payload " + data);
		
		// errors are filtered first
		var error = Api.checkDictionaryResponse(responseCode, data);
		if (error) {
			d_fallback.invoke(error);
			return;
		}
		d_callback.invoke(data["MediaContainer"]);
	}

    function playlists(callback, params) {
		Api.setCallback(callback);

        var url = url() + "/playlists";
        params = Utils.merge(d_params, params);
        System.println("PlexAPI::playlists( params: " + params + ")");

        Communications.makeWebRequest(url, params, d_options, self.method(:onResponse));
    }

    function onPlaylists(responseCode, data) {
        System.println("PlexAPI::onPlaylists( responseCode: " + responseCode + ", data: " + data + ")");		
		
		// check if request was successful and response is ok
    	var error = Api.checkDictionaryResponse(responseCode, data);
    	if (error) {
    		d_fallback.invoke(error);	// add function name and variables available ?
    		return;
    	}
    	
    	var response = data["MediaContainer"]["Metadata"];
		
		d_callback.invoke(response);
    }

    function playlists_items(callback, params, id) {
		Api.setCallback(callback);

        var url = url() + "/playlists/" + id + "/items";
        params = Utils.merge(d_params, params);
        System.println("PlexAPI::playlists_items( id: " + id + ", params: " + params + ")");

        Communications.makeWebRequest(url, params, d_options, self.method(:onResponse));
    }
    
    /**
     * stream
     *
     * downloads a given media file
     */
    function stream(callback, params, id, encoding) {
		System.println("PlexAPI::stream( params: " + params + ", id: " + id + ")");
    
    	Api.setCallback(callback);

		var url = url() + id;
		params = SubMusic.Utils.merge(params, d_params);

		// additional options
    	var options = {
    		:method => Communications.HTTP_REQUEST_METHOD_GET,
          	:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
          	:mediaEncoding => encoding,
			:fileDownloadProgressCallback => method(:onProgress),
   		};

		Communications.makeWebRequest(url, params, options, self.method(:onStream));
	}

	function onStream(responseCode, data) {
		System.println("PlexAPI::onStream with responseCode: " + responseCode);
    	
		// check if request was successful and response is ok
		var error = Api.checkContentResponse(responseCode, data);
		if (error) {
    		d_fallback.invoke(error);
			return;
		}
    	d_callback.invoke(data);
	}

    
    /**
     * photo transcode
     *
     * downloads artwork for given media id
     */
	function photo_transcode(callback, params, id) {
		System.println("PlexAPI::photo_transcode( id: " + id +  " )");

		Api.setCallback(callback);

		var url = url() + "/photo/:/transcode";
		params = SubMusic.Utils.merge(params, d_params);
		params.put("url", id);
		params.put("width", 100);
		params.put("height", 100);

		// additional options
		var options = {
			:maxWidth => 100,
			:maxHeight => 100,
			:fileDownloadProgressCallback => method(:onProgress),
		};

		Communications.makeImageRequest(url, params, options, method(:onPhoto));
	}

	function onPhoto(responseCode, data) {
		System.println("PlexAPI::onPhoto with responseCode: " + responseCode + " and " + data);

		// check if request was successful and response is ok
		var error = Api.checkImageResponse(responseCode, data);
		if (error) {
			d_fallback.invoke(error);
			return;
		}
    	d_callback.invoke(data);
	}

	// @override
	function updateKey(key) {
		Api.updateKey(key);
		d_params.put("X-Plex-Token", key);
	}
}