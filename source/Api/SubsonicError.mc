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
	private var d_type = null;
	private var d_msg = "";
	
	static private var s_name = "SubsonicError";
	
	function initialize(error_obj) {
	
		// if null error_obj, response is malformed
		if (error_obj) {
			d_type = error_obj["code"];
			d_msg = error_obj["message"];
		}
		
		// default is unknown
		var apitype = SubMusic.ApiError.UNKNOWN;
		if ((d_type == WRONG_CREDS) || (d_type == TOKEN_SUPPORT) || (d_type == TRIAL_OVER)) {
			apitype = SubMusic.ApiError.LOGIN;
		} else if (d_type == NOT_AUTHORIZED) {
			apitype = SubMusic.ApiError.ACCESS;
		} else if (d_type == NOT_FOUND) {
			apitype = SubMusic.ApiError.NOTFOUND;
		} else if ((d_type == INCOMPAT_CLIENT) || (d_type == INCOMPAT_SERVER)) {
			apitype = SubMusic.ApiError.SERVERCLIENT;
		} else if (d_type == MISSING_PARAM) {
			apitype = SubMusic.ApiError.BADREQUEST;
		}
		
		SubMusic.ApiError.initialize(apitype);

		System.println(s_name + "::" + SubsonicError.typeToString(d_type));
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
		if (type == GENERIC) {
			return "GENERIC";
		} else if (type == MISSING_PARAM) {
			return "MISSING_PARAM";
		} else if (type == INCOMPAT_CLIENT) {
			return "INCOMPAT_CLIENT";
		} else if (type == INCOMPAT_SERVER) {
			return "INCOMPAT_SERVER";
		} else if (type == WRONG_CREDS) {
			return "WRONG_CREDS";
		} else if (type == TOKEN_SUPPORT) {
			return "TOKEN_SUPPORT";
		} else if (type == NOT_AUTHORIZED) {
			return "NOT_AUTHORIZED";
		} else if (type == TRIAL_OVER) {
			return "TRIAL_OVER";
		} else if (type == NOT_FOUND) {
			return "NOT_FOUND";
		}
		return "Unknown";
	}
}