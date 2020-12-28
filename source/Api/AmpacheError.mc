using Toybox.Lang;

class AmpacheError extends SubMusic.ApiError {
	
// 			Ampache5 error codes
//	enum {
//		ACCESS_CONTROL 	= 4700,
//		HANDSHAKE		= 4701,
//		FEATURE_MISSING	= 4703,
//		NOT_FOUND		= 4704,
//		METHOD_MISSING	= 4705,
//		METHOD_DPRCTD	= 4706,
//		BAD_REQUEST		= 4710,
//		FAILED_ACCESS	= 4742,
//	}
	enum {
		ACCESS_CONTROL 	= 400,
		HANDSHAKE		= 401,
		FEATURE_MISSING	= 403,
		NOT_FOUND		= 404,
		METHOD_MISSING	= 405,
		METHOD_DPRCTD	= 406,
		BAD_REQUEST		= 410,
		FAILED_ACCESS	= 442,
	}
	private var d_code = null;
	private var d_msg = "";
	
	static private var s_name = "Ampache";
	
	function initialize(error_obj) {
		
		// if null error_obj, response is malformed
		if (error_obj) {
			d_code = error_obj["code"];
			d_msg = error_obj["message"];
			// TODO for Ampache 5:
//			d_code = error_obj["errorCode"];		// Ampache5
//			d_msg = error_obj["errorMessage"];		// Ampache5
		}
		
		// default is unknown
		var type = SubMusic.ApiError.UNKNOWN;
		if (d_code == HANDSHAKE) {
			type = SubMusic.ApiError.LOGIN;
		} else if (d_code == FAILED_ACCESS) {
			type = SubMusic.ApiError.ACCESS;
		} else if (d_code == NOT_FOUND) {
			type = SubMusic.ApiError.NOTFOUND;
		} else if ((d_code == ACCESS_CONTROL) || (d_code == FEATURE_MISSING) || (d_code == METHOD_MISSING) || (d_code == METHOD_DPRCTD)) {
			type = SubMusic.ApiError.SERVERCLIENT;
		} else if (d_code == BAD_REQUEST) {
			type = SubMusic.ApiError.BADREQUEST;
		}
		
		SubMusic.ApiError.initialize(type);
	}
	
	function shortString() {
		return SubMusic.ApiError.shortString() + " " + d_code;
	}
	
	function toString() {
		return d_msg;
	}
	
	function code() {
		return d_code;
	}
	
	static function is(responseCode, data) {
		// ampache API errors have http code 200 and a dictionary as body
		if ((responseCode != 200) 
			|| (data == null)
			|| !(data instanceof Lang.Dictionary)
			|| (data["error"] == null)) {
			return null;
		}
		return new AmpacheError(data["error"]);
	}
}