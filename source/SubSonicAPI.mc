using Toybox.Communications;

// class for interfacing with a subsonic API endpoint
class SubSonicAPI {

	private var d_base_url = Application.Properties.getValue("subsonic_API_URL") + "/rest/";
	private var d_user = Application.Properties.getValue("subsonic_API_usr");
	private var d_pass = Application.Properties.getValue("subsonic_API_key");
	
	private var d_params;
	
	private var d_callback;
	private var d_fallback;
	
	function initialize(fallback) {
		d_params = {
    		"u" => d_user,
    		"p" => d_pass,
    		"c" => Rez.Strings.AppName,
    		"v" => "1.10.2",
    		"f" => "json",
    	};
		
		d_fallback = fallback;
	}
	
	/**
	 * getPlaylists
	 *
	 * returns all playlists the user is allowed to play.
	 */
	function getPlaylists(callback) {
		System.println("Inside call getPlaylists");
		
		d_callback = callback;
		
		var url = d_base_url + "getPlaylists";
    	Communications.makeWebRequest(url, d_params, {}, self.method(:onGetPlaylists));
	}
	
	function onGetPlaylists(responseCode, data) {
		System.println("onGetPlaylists with responseCode: " + responseCode + ", payload " + data);		
		
		// check if request was successful and response is ok
		if ((responseCode != 200) 
				|| (data == null) 
				|| (data["subsonic-response"] == null) 
				|| (data["subsonic-response"]["status"] == null)
				|| !(data["subsonic-response"]["status"].equals("ok"))) {
			d_fallback.invoke(responseCode, data);
			return;
		}
		d_callback.invoke(data["subsonic-response"]["playlists"]["playlist"]);
	}
		
	
	/**
	 * getPlaylist
	 *
	 * returns a listing of files in a saved playlist
	 */
	function getPlaylist(id, callback, context) {
	
		d_callback = callback;
		
		var url = d_base_url + "getPlaylist";
		
		var params = d_params;
		params["id"] = id;			// set id for playlist
		
    	var options = {
    		:method => Communications.HTTP_REQUEST_METHOD_GET,
    		:context => context,
    	};
    	Communications.makeWebRequest(url, params, options, self.method(:onGetPlaylist));
    }
    
    function onGetPlaylist(responseCode, data, context) {
    	System.println("onGetPlaylist with responseCode: " + responseCode + ", payload " + data);
    	
    	
		// check if request was successful and response is ok
		if ((responseCode != 200) 
				|| (data == null) 
				|| (data["subsonic-response"] == null) 
				|| (data["subsonic-response"]["status"] == null)
				|| !(data["subsonic-response"]["status"].equals("ok"))) {
			d_fallback.invoke(responseCode, data, context);
			return;
		}
    	
    	d_callback.invoke(data["subsonic-response"]["playlist"], context);
    }
    
    /**
     * download
     *
     * downloads a given media file. Similar to stream, 
     * but this method returns the original media data 
     * without transcoding or downsampling
     */
    function download(id, encoding, callback, context) {
    
    	d_callback = callback;
    
		var url = d_base_url + "download";
		var params = d_params;
		params["id"] = id;
		
    	var options = {
    		:method => Communications.HTTP_REQUEST_METHOD_GET,
          	:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
          	:mediaEncoding => typeStringToEncoding(encoding),
          	:context => context,
   		};
    	Communications.makeWebRequest(url, params, options, self.method(:onDownload));
    }
    
    function onDownload(responseCode, data, context) {
    	System.println("onDownload with responseCode: " + responseCode);
    	
		// check if request was successful and response is ok
		if (responseCode != 200) {
    		d_fallback.invoke(responseCode, data, context);
			return;
		}
    	d_callback.invoke(data.getId(), context);
    }
    
    /**
     * stream
     *
     * downloads a given media file
     */
    function stream(id, encoding, callback, context) {
    
    	d_callback = callback;
    
		var url = d_base_url + "stream";
		var params = d_params;
		params["id"] = id;
		params["format"] = encoding;
		
    	var options = {
    		:method => Communications.HTTP_REQUEST_METHOD_GET,
          	:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
          	:mediaEncoding => typeStringToEncoding(encoding),
          	:context => context,
   		};
    	Communications.makeWebRequest(url, params, options, self.method(:onStream));
    }
    
    function onStream(responseCode, data, context) {
    	System.println("onStream with responseCode: " + responseCode);
    	
		// check if request was successful and response is ok
		if (responseCode != 200) {
    		d_fallback.invoke(responseCode, data, context);
			return;
		}
    	d_callback.invoke(data.getId(), context);
    }
    
    function typeStringToEncoding(type) {
        var encoding = Media.ENCODING_INVALID;
        
        if (type.equals("mp3")) {
                encoding = Media.ENCODING_MP3;
        } else if (type.equals("m4a")) {
                encoding = Media.ENCODING_M4A;
        } else if (type.equals("wav")) {
                encoding = Media.ENCODING_WAV;
        } else if (type.equals("adts")) {
                encoding = Media.ENCODING_ADTS;
        }
        return encoding;
    }
    
    function respCodeToString(responseCode) {
    	if (responseCode == Communications.INVALID_HTTP_HEADER_FIELDS_IN_REQUEST) {
    		return "\"INVALID_HTTP_HEADER_FIELDS_IN_REQUEST\"";
    	} else if (responseCode == Communications.INVALID_HTTP_BODY_IN_REQUEST) {
    		return "\"INVALID_HTTP_BODY_IN_REQUEST\"";
    	} else if (responseCode == Communications.INVALID_HTTP_METHOD_IN_REQUEST) {
    		return "\"INVALID_HTTP_METHOD_IN_REQUEST\"";
    	} else if (responseCode == Communications.NETWORK_REQUEST_TIMED_OUT) {
    		return "\"NETWORK_REQUEST_TIMED_OUT\"";
    	} else if (responseCode == Communications.INVALID_HTTP_BODY_IN_NETWORK_RESPONSE) {
    		return "\"INVALID_HTTP_BODY_IN_NETWORK_RESPONSE\"";
    	} else if (responseCode == Communications.INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE) {
    		return "\"INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE\"";
    	} else if (responseCode == Communications.NETWORK_RESPONSE_TOO_LARGE) {
    		return "\"NETWORK_RESPONSE_TOO_LARGE\"";
    	} else if (responseCode == Communications.NETWORK_RESPONSE_OUT_OF_MEMORY) {
    		return "\"NETWORK_RESPONSE_OUT_OF_MEMORY\"";
    	} else if (responseCode == Communications.STORAGE_FULL) {
    		return "\"STORAGE_FULL\"";
    	} else if (responseCode == Communications.SECURE_CONNECTION_REQUIRED) {
    		return "\"SECURE_CONNECTION_REQUIRED\"";
    	}
    	return "Unknown";
    }
    
    function setFallback(fallback) {
    	d_fallback = fallback;
    }
}