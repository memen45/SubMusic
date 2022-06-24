using Toybox.Lang;
using Toybox.Media;
using Toybox.System;
using Toybox.WatchUi;
using SubMusic;

class Api {

    private var d_client;    // the client name

    // callbacks
    hidden var d_callback;  // callback for finished request
    hidden var d_fallback;  // fallback for failed request
    hidden var d_progress;  // intermediate callback to update request progress

    // settings
    private var d_url_add;  // specific addition to the base url
    private var d_url;      // the base url for the api
    private var d_usr;      // the user 
    private var d_key;      // the key used to login


    function initialize(url_add) {
        d_url_add = url_add;
        d_client = (WatchUi.loadResource(Rez.Strings.AppName) + "-v" + (new SubMusicVersion(null).toString()));
    }

    function client() {
        return d_client;
    }

    function url() {
        return d_url + d_url_add;
    }

    function usr() {
        return d_usr;
    }

    function key() {
        return d_key;
    }

    function update(settings) {
        System.println("Api::update( " + settings + ")");

        updateUrl(settings.get("api_url"));
        updateUsr(settings.get("api_usr"));
        updateKey(settings.get("api_key"));
    }
    
    function updateUrl(url) {
        d_url = url;
    }

    function updateUsr(usr) {
        d_usr = usr;
    }

    function updateKey(key) {
        d_key = key;
    }

    /*
	 * checkResponse
	 *
	 * returns http/sdk errors if found
	 */
	function checkResponse(responseCode, data) {
		var error = SubMusic.HttpError.is(responseCode);
		if (error) { return error; }
		error = SubMusic.GarminSdkError.is(responseCode);
        if (error) { return error; }
        return self.checkApiError(responseCode, data);
    }

    function checkApiError(responseCode, data) {
        System.println("WARNING: Api::checkApiError() was called, but should not be called");
        System.println("responseCode: " + responseCode + " data: " + data);
        return null;
    }

    function checkDictionaryResponse(responseCode, data) {
        var error = checkResponse(responseCode, data);
        if (error) { return error; }
        return isDictionary(data);      // check type of received object
    }

    function checkArrayResponse(responseCode, data) {
        var error = checkResponse(responseCode, data);
        if (error) { return error; }
        return isArray(data);           // check type of received object
    }

    static function isDictionary(data) {
        // check type of received object
        if (data instanceof Lang.Dictionary) { return null; }
        return new SubMusic.ApiError(SubMusic.ApiError.BADRESPONSE);
    }

    static function isArray(data) {
        // check type of received object
        if (data instanceof Lang.Array) { return null; }
        return new SubMusic.ApiError(SubMusic.ApiError.BADRESPONSE);
    }

    function checkContentResponse(responseCode, data) {
        var error = checkResponse(responseCode, data);
        if (error) { return error; }

        // check type of received object
        if (data instanceof Media.ContentRef) { return null; }
        return new SubMusic.ApiError(SubMusic.ApiError.BADRESPONSE);
    }

    function checkImageResponse(responseCode, data) {
        var error = checkResponse(responseCode, data);
        if (error) { return error; }

        // check type of received object
        if (data instanceof WatchUi.BitmapResource) { return null; }
        return new SubMusic.ApiError(SubMusic.ApiError.BADRESPONSE);
    }

	function onProgress(totalBytesTransferred, fileSize) {
		// if total fileSize is null, progress = 0
        System.println(totalBytesTransferred + " of " + fileSize);
		var progress = 0;
		if (fileSize) {
			progress = 100 * (totalBytesTransferred / fileSize.toFloat());
		}
		// callback the progress update
		d_progress.invoke(progress);
	}

    function setCallback(callback) {
        d_callback = callback;
    }

    function setFallback(fallback) {
        d_fallback = fallback;
    }

    function setProgressCallback(progress) {
        d_progress = progress;
    }
}