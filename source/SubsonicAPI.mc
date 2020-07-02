using Toybox.Communications;
using Toybox.WatchUi;

// class for interfacing with a subsonic API endpoint
class SubsonicAPI {

	private var d_base_url;
	private var d_user;
	private var d_pass;
	
	private var d_params;
	
	private var d_callback;
	private var d_fallback;		// add null checks!
	
	function initialize(settings, fallback) {
		d_base_url = settings.get("api_url") + "/rest/";
		d_user = settings.get("api_usr");
		d_pass = settings.get("api_key");
		d_params = {
    		"u" => d_user,
    		"p" => d_pass,
    		"c" => (WatchUi.loadResource(Rez.Strings.AppName) + " " + WatchUi.loadResource(Rez.Strings.AppVersionTitle)),
    		"v" => "1.10.2",
    		"f" => "json",
    	};
		d_fallback = fallback;

    	System.println("Initialize SubSonicAPI, url: " + d_base_url + " user: " + d_user + ", pass: " + d_pass + " client name: " + d_params["c"]);
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
	function getPlaylist(callback, params) {
	
		d_callback = callback;
		
		var url = d_base_url + "getPlaylist";
		
		// construct parameters
		var id = params["id"];
		params = d_params;
		params["id"] = id;			// set id for playlist
		
    	var options = {
    		:method => Communications.HTTP_REQUEST_METHOD_GET,
    	};
    	Communications.makeWebRequest(url, params, options, self.method(:onGetPlaylist));
    }
    
    function onGetPlaylist(responseCode, data) {
    	System.println("onGetPlaylist with responseCode: " + responseCode + ", payload " + data);
    	
    	
		// check if request was successful and response is ok
		if ((responseCode != 200) 
				|| (data == null) 
				|| (data["subsonic-response"] == null) 
				|| (data["subsonic-response"]["status"] == null)
				|| !(data["subsonic-response"]["status"].equals("ok"))) {
			d_fallback.invoke(responseCode, data);
			return;
		}
    	
    	d_callback.invoke(data["subsonic-response"]["playlist"]);
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
    function stream(callback, params) {
    
    	d_callback = callback;
    
		var url = d_base_url + "stream";

		// construct parameters
		var id = params["id"];
		var encoding = params["format"];
		params = d_params;
		params["id"] = id;
		params["format"] = encoding;
		
    	var options = {
    		:method => Communications.HTTP_REQUEST_METHOD_GET,
          	:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
          	:mediaEncoding => typeStringToEncoding(encoding),
   		};
    	Communications.makeWebRequest(url, params, options, self.method(:onStream));
    }
    
    function onStream(responseCode, data) {
    	System.println("SubsonicAPI::onStream with responseCode: " + responseCode);
    	
		// check if request was successful and response is ok
		if (responseCode != 200) {
    		d_fallback.invoke(responseCode, data);
			return;
		}
    	d_callback.invoke(data.getId());
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
}