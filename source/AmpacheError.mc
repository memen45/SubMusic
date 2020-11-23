using Toybox.Lang;

class AmpacheError extends SubMusic.ApiError {
	
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
	private var d_code;
	private var d_msg;
	
	function initialize(code, msg) {
		
		var type = SubMusic.ApiError.UNKNOWN;
		if (code == HANDSHAKE) {
			type = SubMusic.ApiError.LOGIN;
		} else if (code == FAILED_ACCESS) {
			type = SubMusic.ApiError.ACCESS;
		} else if (code == NOT_FOUND) {
			type = SubMusic.ApiError.NOTFOUND;
		} else if ((code == ACCESS_CONTROL) || (code == FEATURE_MISSING) || (code == METHOD_MISSING) || (code == METHOD_DPRCTD)) {
			type = SubMusic.ApiError.SERVERCLIENT;
		} else if (code == BAD_REQUEST) {
			type = SubMusic.ApiError.BADREQUEST;
		}
		
		SubMusic.ApiError.initialize("Ampache", type);
		d_code = code;
		d_msg = msg;
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
		// ampache API errors have http code 200
		if (responseCode != 200) {
			var error = SubMusic.SdkError.is(responseCode, data);
			return error ? error : new SubMusic.ApiError("Ampache", SubMusic.ApiError.BADRESPONSE);
		}
		
		// check for empty body
		if (data == null) {
			return new SubMusic.ApiError("Ampache", SubMusic.ApiError.BADRESPONSE);
		}    		
		
		if ((data instanceof Lang.Dictionary)
			&& (data["error"] != null)) {
//			return new AmpacheError(data["error"]["errorCode"], data["error"]["errorMessage"]);
			return new AmpacheError(data["error"]["code"], data["error"]["message"]);
		}
		
		return null;
	}
}