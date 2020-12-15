using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.System;
using SubMusic;

// class for interfacing with a subsonic API endpoint
class SubsonicAPI {

	private var d_base_url;
	private var d_client;
	
	private var d_params = {};
	
	private var d_callback;
	private var d_fallback;
	
	function initialize(settings, fallback) {
		set(settings);
		
		d_client = (WatchUi.loadResource(Rez.Strings.AppName) + " v" + (new SubMusicVersion(null).toString()));
		d_params.put("c", d_client);
		d_params.put("v", "1.10.2");		// subsonic api version
		d_params.put("f", "json");			// request format

		d_fallback = fallback;

    	System.println("SubsonicAPI::initialize(client name: " + d_params["c"] + " )");
	}
	
	function ping(callback) {
		d_callback = callback;
		
		var url = d_base_url + "ping";
    	Communications.makeWebRequest(url, d_params, {}, self.method(:onPing));
    }
    
    function onPing(responseCode, data) {
    	System.println("SubsonicAPI::onPing( responseCode: " + responseCode + ", data: " + data + ")");		
		
		// check if request was successful and response is ok
    	var error = checkResponse(responseCode, data);
    	if (error) {
    		d_fallback.invoke(error);	// add function name and variables available ?
    		return;
    	}
		d_callback.invoke(data["subsonic-response"]);
	}
	
	function scrobble(callback, params) {
		System.println("SubsonicAPI::scrobble(params: " + params + ")");
	
		d_callback = callback;
		
		var url = d_base_url + "scrobble";
		
		// construct parameters
		var id = params["id"];
		var time = params["time"];
		params = d_params;
		params["id"] = id;			// set id for scrobble
		params["time"] = time;		// set time for scrobble
		
    	Communications.makeWebRequest(url, params, {}, self.method(:onGetPlaylist));
    }
    
    function onScrobble(responseCode, data) {
    	System.println("SubsonicAPI::onScrobble( responseCode: " + responseCode + ", data: " + data + ")");		
		
		// check if request was successful and response is ok
    	var error = checkResponse(responseCode, data);
    	if (error) {
    		d_fallback.invoke(error);	// add function name and variables available ?
    		return;
    	}
		d_callback.invoke(data["subsonic-response"]);		// empty response on success
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
    	var error = checkResponse(responseCode, data);
    	if (error) {
    		d_fallback.invoke(error);	// add function name and variables available ?
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
		var error = checkResponse(responseCode, data);
		if (error) {
    		d_fallback.invoke(error);
			return;
		}
    	d_callback.invoke(data.getId());
    }

	function checkResponse(responseCode, data) {
		var error = SubMusic.HttpError.is(responseCode);
		if (error) { return error; }
		error = SubMusic.GarminSdkError.is(responseCode);
		if (error) { return error; }
		error = SubsonicError.is(responseCode, data);
		return error;
	}
    
    function update(settings) {
		System.println("SubsonicAPI::update(settings)");
		
		// update the settings
    	set(settings);

		// no persistent session info, so only update variables for future requests
   	}
    
    function set(settings) {
    	d_base_url = settings.get("api_url") + "/rest/";
		d_params.put("u", settings.get("api_usr"));
    	d_params.put("p", settings.get("api_key"));

    	System.println("SubsonicAPI::set(url: " + d_base_url + " user: " + d_params.get("u") + ", pass: " + d_params.get("p") + ")");
    }

	function client() {
		return d_client;
	}
}