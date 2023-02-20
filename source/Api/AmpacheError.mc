using Toybox.Lang;

class AmpacheError extends SubMusic.ApiError {
	
// 			Ampache5 error codes
//	static enum {
//		ACCESS_CONTROL 	= 4700,
//		HANDSHAKE		= 4701,
//		FEATURE_MISSING	= 4703,
//		NOT_FOUND		= 4704,
//		METHOD_MISSING	= 4705,
//		METHOD_DPRCTD	= 4706,
//		BAD_REQUEST		= 4710,
//		FAILED_ACCESS	= 4742,
//	}

// 			Ampache4 error codes (deprecated)
	static enum {
		ACCESS_CONTROL 	= 400,
		HANDSHAKE		= 401,
		FEATURE_MISSING	= 403,
		NOT_FOUND		= 404,
		METHOD_MISSING	= 405,
		METHOD_DPRCTD	= 406,
		BAD_REQUEST		= 410,
		FAILED_ACCESS	= 442,
	}

	// map ampache errors to string representation
	static private var stringmap = {
		ACCESS_CONTROL 	=> "ACCESS_CONTROL",
		HANDSHAKE 		=> "HANDSHAKE",
		FEATURE_MISSING => "FEATURE_MISSING",
		NOT_FOUND 		=> "NOT_FOUND",
		METHOD_MISSING 	=> "METHOD_MISSING",
		METHOD_DPRCTD 	=> "METHOD_DPRCTD",
		BAD_REQUEST 	=> "BAD_REQUEST",
		FAILED_ACCESS 	=> "FAILED_ACCESS",
	};

	// map subsonic errors to API level errors
	static private var apimap = {
		ACCESS_CONTROL 	=> SubMusic.ApiError.SERVERCLIENT,
		HANDSHAKE 		=> SubMusic.ApiError.LOGIN,
		FEATURE_MISSING => SubMusic.ApiError.SERVERCLIENT,
		NOT_FOUND 		=> SubMusic.ApiError.NOTFOUND,
		METHOD_MISSING 	=> SubMusic.ApiError.SERVERCLIENT,
		METHOD_DPRCTD 	=> SubMusic.ApiError.SERVERCLIENT,
		BAD_REQUEST 	=> SubMusic.ApiError.BADREQUEST,
		FAILED_ACCESS 	=> SubMusic.ApiError.ACCESS,
	};
	private var d_type = null;
	private var d_msg = "";
	
	static private var s_name = "AmpacheError";
	
	function initialize(error_obj) {
		
		// if null error_obj, response is malformed
		if ((error_obj != null) && (error_obj["code"] != null)) {
			d_type = error_obj["code"].toNumber();
			d_msg = error_obj["message"];
		}		

		var apitype = null;
		if (d_type != null) {
			apitype = apimap.get(d_type);
		}
		if (apitype == null) {
			apitype = SubMusic.ApiError.UNKNOWN;
		}
		SubMusic.ApiError.initialize(apitype);

		if ($.debug) {
			System.println(s_name + "::" + AmpacheError.typeToString(d_type));
		}
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
		var string = stringmap.get(type);
		if (string == null) {
			string = "Unknown";
		}
		return string;
	}
}