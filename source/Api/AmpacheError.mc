using Toybox.Lang;

class AmpacheError extends SubMusic.ApiError {
	
// 			Ampache5 error codes
	enum {
		ACCESS_CONTROL 	= 4700,
		HANDSHAKE		= 4701,
		FEATURE_MISSING	= 4703,
		NOT_FOUND		= 4704,
		METHOD_MISSING	= 4705,
		METHOD_DPRCTD	= 4706,
		BAD_REQUEST		= 4710,
		FAILED_ACCESS	= 4742,
	}

// 			Ampache4 error codes (deprecated)
	private const ERROR_CODE_OFFSET = 4300;
//	static enum {
//		ACCESS_CONTROL 	= 400,
//		HANDSHAKE		= 401,
//		FEATURE_MISSING	= 403,
//		NOT_FOUND		= 404,
//		METHOD_MISSING	= 405,
//		METHOD_DPRCTD	= 406,
//		BAD_REQUEST		= 410,
//		FAILED_ACCESS	= 442,
//	}
	private var d_type = null;
	private var d_msg = "";
	
	static private var s_name = "AmpacheError";
	
	function initialize(error_obj) {
		
		// if null error_obj, response is malformed
		if ((error_obj != null) && (error_obj["errorCode"] != null)) {
			// TODO for Ampache 5:
			d_type = error_obj["errorCode"];		// Ampache5
			d_msg = error_obj["errorMessage"];		// Ampache5
		} else if ((error_obj != null) && (error_obj["code"] != null)) {
			d_type = error_obj["code"].toNumber() + ERROR_CODE_OFFSET;
			d_msg = error_obj["message"];
		}
		
		// default is unknown
		var apitype = SubMusic.ApiError.UNKNOWN;
		if (d_type == HANDSHAKE) {
			apitype= SubMusic.ApiError.LOGIN;
		} else if (d_type == FAILED_ACCESS) {
			apitype= SubMusic.ApiError.ACCESS;
		} else if (d_type == NOT_FOUND) {
			apitype = SubMusic.ApiError.NOTFOUND;
		} else if ((d_type == ACCESS_CONTROL) || (d_type == FEATURE_MISSING) || (d_type == METHOD_MISSING) || (d_type == METHOD_DPRCTD)) {
			apitype = SubMusic.ApiError.SERVERCLIENT;
		} else if (d_type == BAD_REQUEST) {
			apitype = SubMusic.ApiError.BADREQUEST;
		}
		
		SubMusic.ApiError.initialize(apitype);

		System.println(s_name + "::" + AmpacheError.typeToString(d_type));
	}

	function shortString() {
		return s_name + "::" + d_type;
	}

	function toString() {
		return SubMusic.ApiError.toString() + 
				" --> " + 
				s_name + "::" + AmpacheError.typeToString(d_type) + 
				": " + d_msg;
	}
	
	function type() {
		return d_type;
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

	static function typeToString(type) {
		if (type == ACCESS_CONTROL) {
			return "ACCESS_CONTROL";
		} else if (type == HANDSHAKE) {
			return "HANDSHAKE";
		} else if (type == FEATURE_MISSING) {
			return "FEATURE_MISSING";
		} else if (type == NOT_FOUND) {
			return "NOT_FOUND";
		} else if (type == METHOD_MISSING) {
			return "METHOD_MISSING";
		} else if (type == METHOD_DPRCTD) {
			return "METHOD_DPRCTD";
		} else if (type == BAD_REQUEST) {
			return "BAD_REQUEST";
		} else if (type == FAILED_ACCESS) {
			return "FAILED_ACCESS";
		}
		return "Unknown";
	}
}