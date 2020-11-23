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
	private var d_code;
	private var d_msg;
	
	function initialize(code, msg) {
		
		var type = SubMusic.ApiError.UNKNOWN;
		if ((code == WRONG_CREDS) || (code == TOKEN_SUPPORT) || (code == TRIAL_OVER)) {
			type = SubMusic.ApiError.LOGIN;
		} else if (code == NOT_AUTHORIZED) {
			type = SubMusic.ApiError.ACCESS;
		} else if (code == NOT_FOUND) {
			type = SubMusic.ApiError.NOTFOUND;
		} else if ((code == INCOMPAT_CLIENT) || (code == INCOMPAT_SERVER)) {
			type = SubMusic.ApiError.SERVERCLIENT;
		} else if (code == MISSING_PARAM) {
			type = SubMusic.ApiError.BADREQUEST;
		}
		
		SubMusic.ApiError.initialize("Subsonic", type);
		d_code = code;
		d_msg = msg;
	}
	
	function shortString() {
		return SubMusic.ApiError.shortString() + " " + d_code;
	}
	
	function toString() {
		return d_msg;
	}
	
	static function is(responseCode, data) {
	
    	// subsonic API errors have http code 200
		if (responseCode != 200) {
			var error = SubMusic.SdkError.is(responseCode, data);
			return error ? error : new SubMusic.ApiError("Subsonic", SubMusic.ApiError.BADRESPONSE);
		}
		
		// check for incorrect structure
		if ((data == null)
			|| (data["subsonic-response"] == null)
			|| (data["subsonic-response"]["status"] == null)) {
			return new SubMusic.ApiError("Subsonic", SubMusic.ApiError.BADRESPONSE);
		}
		
		// check if ok
		if (data["subsonic-response"]["status"].equals("ok")) {
			return null;
		}
		
		// check for missing error element
		if ((data["subsonic-response"]["error"] == null)) {
			return new SubMusic.ApiError("Subsonic", SubMusic.ApiError.BADRESPONSE);
		}
		
		var code = data["subsonic-response"]["error"]["code"];
		var msg = data["subsonic-response"]["error"]["message"];
		
		return new SubsonicError(code, msg); 	
	}
}