using Toybox.System;

class SubsonicError extends SubMusic.ApiError {
    
	enum {
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
	private var d_code = null;
	private var d_msg = "";
	
	static private var s_name = "Subsonic";
	
	function initialize(error_obj) {
	
		// if null error_obj, response is malformed
		if (error_obj) {
			d_code = error_obj["code"];
			d_msg = error_obj["message"];
		}
		
		// default is unknown
		var type = SubMusic.ApiError.UNKNOWN;
		if ((d_code == WRONG_CREDS) || (d_code == TOKEN_SUPPORT) || (d_code == TRIAL_OVER)) {
			type = SubMusic.ApiError.LOGIN;
		} else if (d_code == NOT_AUTHORIZED) {
			type = SubMusic.ApiError.ACCESS;
		} else if (d_code == NOT_FOUND) {
			type = SubMusic.ApiError.NOTFOUND;
		} else if ((d_code == INCOMPAT_CLIENT) || (d_code == INCOMPAT_SERVER)) {
			type = SubMusic.ApiError.SERVERCLIENT;
		} else if (d_code == MISSING_PARAM) {
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
	
	static function is(responseCode, data) {
	
    	// subsonic API errors have http code 200, status failed and an element 'error'
		if ((responseCode != 200)
			|| (data == null)
			|| !(data instanceof Lang.Dictionary)
			|| (data["subsonic-response"] == null)
			|| (data["subsonic-response"]["status"] == null)
			|| !(data["subsonic-response"]["status"].equals("failed"))
			|| (data["subsonic-response"]["error"] == null)) {
			return null;
		}
		return new SubsonicError(data["subsonic-response"]["error"]); 	
	}
}