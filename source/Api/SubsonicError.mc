using Toybox.System;
using Toybox.Lang;

class SubsonicError extends SubMusic.ApiError {
    
	static enum {
		GENERIC 		= 0,		// 0 	A generic error.
		MISSING_PARAM 	= 10,		// 10 	Required parameter is missing.
		INCOMPAT_CLIENT = 20,		// 20 	Incompatible Subsonic REST protocol version. Client must upgrade.
		INCOMPAT_SERVER = 30,		// 30 	Incompatible Subsonic REST protocol version. Server must upgrade.
		WRONG_CREDS 	= 40,		// 40 	Wrong username or password.
		TOKEN_SUPPORT	= 41,		// 41 	Token authentication not supported for LDAP users.
		NOT_AUTHORIZED	= 50,		// 50 	User is not authorized for the given operation.
		TRIAL_OVER		= 60,		// 60 	The trial period for the Subsonic server is over. Please upgrade to Subsonic Premium. Visit subsonic.org for details.
		NOT_FOUND		= 70,		// 70 	The requested data was not found.
	}

	// map subsonic errors to string representation
	static private var stringmap = {
		GENERIC 		=> "GENERIC",
		MISSING_PARAM 	=> "MISSING_PARAM",
		INCOMPAT_CLIENT => "INCOMPAT_CLIENT",
		INCOMPAT_SERVER => "INCOMPAT_SERVER",
		WRONG_CREDS 	=> "WRONG_CREDS",
		TOKEN_SUPPORT 	=> "TOKEN_SUPPORT",
		NOT_AUTHORIZED 	=> "NOT_AUTHORIZED",
		TRIAL_OVER 		=> "TRIAL_OVER",
		NOT_FOUND 		=> "NOT_FOUND",
	};

	// map subsonic errors to API level errors
	static private var apimap = {
		GENERIC 		=> SubMusic.ApiError.UNKNOWN,
		MISSING_PARAM 	=> SubMusic.ApiError.BADREQUEST,
		INCOMPAT_CLIENT => SubMusic.ApiError.SERVERCLIENT,
		INCOMPAT_SERVER => SubMusic.ApiError.SERVERCLIENT,
		WRONG_CREDS 	=> SubMusic.ApiError.LOGIN,
		TOKEN_SUPPORT 	=> SubMusic.ApiError.LOGIN,
		NOT_AUTHORIZED 	=> SubMusic.ApiError.ACCESS,
		TRIAL_OVER 		=> SubMusic.ApiError.LOGIN,
		NOT_FOUND 		=> SubMusic.ApiError.NOTFOUND,
	};
	private var d_type = null;
	private var d_msg = "";
	
	static private var s_name = "SubsonicError";
	
	function initialize(error_obj) {
	
		// if null error_obj, response is malformed
		if (error_obj) {
			d_type = error_obj["code"];
			d_msg = error_obj["message"];
		}		

		var apitype = apimap.get(d_type);
		if (apitype == null) {
			apitype = SubMusic.ApiError.UNKNOWN;
		}
		SubMusic.ApiError.initialize(apitype);

		if ($.debug) {
			System.println(s_name + "::" + SubsonicError.typeToString(d_type));
		}
	}
	
	function shortString() {
		return s_name + "::" + d_type;
	}
	
	function toString() {
		return SubMusic.ApiError.toString() + 
				" --> " + 
				s_name + "::" + SubsonicError.typeToString(d_type) + 
				": " + d_msg;
	}
	
	function type() {
		return d_type;
	}
	
	static function is(responseCode, data) {
	
    	// subsonic API errors have http code 200, status failed and an element 'error'
		if ((responseCode != 200)
			|| (data == null)
			|| !(data instanceof Lang.Dictionary)
			|| (data["subsonic-response"] == null)
			|| !(data["subsonic-response"]["status"] instanceof Lang.String)
			|| !(data["subsonic-response"]["status"].equals("failed"))
			|| (data["subsonic-response"]["error"] == null)) {
			return null;
		}
		return new SubsonicError(data["subsonic-response"]["error"]); 	
	}

	static function typeToString(type) {
		var string = stringmap.get(type);
		if (string == null) {
			string = "Unknown";
		}
		return string;
	}
}