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
    		"c" => (WatchUi.loadResource(Rez.Strings.AppName) + " v" + WatchUi.loadResource(Rez.Strings.AppVersionTitle)),
    		"v" => "1.10.2",
    		"f" => "json",
    	};
		d_fallback = fallback;

    	System.println("SubsonicAPI::initialize(client name: " + d_params["c"]);
	}
	
	/**
	 * getPlaylists
	 *
	 * returns all playlists the user is allowed to play.
	 */
	function getPlaylists(callback) {
		System.println("SubsonicAPI::getPlaylists");
		
		d_callback = callback;
		
		var url = d_base_url + "getPlaylists";
    	Communications.makeWebRequest(url, d_params, {}, self.method(:onGetPlaylists));
	}
	
	function onGetPlaylists(responseCode, data) {
		System.println("SubsonicAPI::onGetPlaylists( responseCode: " + responseCode + ", data: " + data + ")");		
		
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
		System.println("SubsonicAPI::getPlaylist(params: " + params + ")");
	
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
    	System.println("Subsonic::onGetPlaylist(responseCode: " + responseCode + ", data: " + data);
    	
    	
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
     * stream
     *
     * downloads a given media file
     */
    function stream(callback, params, encoding) {
    	System.println("SubsonicAPI::stream( params: " + params + ")");
    
    	d_callback = callback;
    
		var url = d_base_url + "stream";

		// construct parameters
		var id = params["id"];
		var format = params["format"];
		params = d_params;
		params["id"] = id;
		params["format"] = format;
		
    	var options = {
    		:method => Communications.HTTP_REQUEST_METHOD_GET,
          	:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
          	:mediaEncoding => encoding,
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
    
    function update(settings) {
		System.println("SubsonicAPI::update(settings)");
		
    	// no persistent session info, so only update variables for future requests
    	set(settings);
   	}
    
    function set(settings) {
    	System.println("SubsonicAPI::set(url: " + d_base_url + " user: " + d_user + ", pass: " + d_pass + ")");
    	
    	d_base_url = settings.get("api_url") + "/rest/";
		d_user = settings.get("api_usr");
		d_pass = settings.get("api_key");
    }
}