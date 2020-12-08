module SubMusic {
	
	class Error {
		enum {
			HTTP,
			API,
		}
		private var d_type;
		
		function initialize(type) {
			d_type = type;
		}
		
		function type() {
			return d_type;
		}
		
		function shortString() {
			return "Error";
	    }
	    
	    function toString() {
	    	return "";
	    }
	}
	
	class ApiError extends Error {
		
		enum {
			LOGIN,
			ACCESS,
			NOTFOUND,
			SERVERCLIENT,
			BADREQUEST,
			BADRESPONSE,
			UNKNOWN,
		}		
		private var d_type;
		static private var s_name = "API";
		
		function initialize(type) {
			Error.initialize(Error.API);
			
			d_type = type;
		}
		
		function shortString() {
			var res = "API::";
			
			if (d_type == LOGIN) {
	    		res += "\"LOGIN\"";
	    	} else if (d_type == ACCESS) {
	    		res += "\"ACCESS\"";
	    	} else if (d_type == NOTFOUND) {
	    		res += "\"NOTFOUND\"";
	    	} else if (d_type == SERVERCLIENT) {
	    		res += "\"SERVERCLIENT\"";
	    	} else if (d_type == BADREQUEST) {
	    		res += "\"BADREQUEST\"";
	    	} else if (d_type == BADRESPONSE) {
	    		res += "\"BADRESPONSE\"";
	    	} else if (d_type == UNKNOWN) {
	    		res += "\"UNKNOWN\"";
	    	} else {
	    		res += "Unknown";
	    	}
	    	return res + " " + Error.shortString();
	    }
	    
	    function typeToString(type) {
	    
	    	if (d_type == LOGIN) {
	    		return "\"LOGIN\"";
	    	} else if (d_type == ACCESS) {
	    		return "\"ACCESS\"";
	    	} else if (d_type == NOTFOUND) {
	    		return "\"NOTFOUND\"";
	    	} else if (d_type == SERVERCLIENT) {
	    		return "\"SERVERCLIENT\"";
	    	} else if (d_type == BADREQUEST) {
	    		return "\"BADREQUEST\"";
	    	} else if (d_type == BADRESPONSE) {
	    		return "\"BADRESPONSE\"";
	    	} else if (d_type == UNKNOWN) {
	    		return "\"UNKNOWN\"";
	    	}
	    	return "Unknown";
	    }
	}
	
	class HttpError extends Error {
		
		enum {
			BAD_REQUEST = 400,
			NOT_FOUND = 404,
		}
		private var d_type;
		static private var s_name = "HTTP";
		
		function initialize(type) {
			Error.initialize(Error.HTTP);
			
			d_type = type;
		}
		
		static function is(responseCode) {
		
			// only error if > 0 but not 200
			if ((responseCode == 200)
				|| (responseCode <= 0)) {
				return null;
			}
			return new HttpError(responseCode);
		}
		
		function shortString() {
			return Error.shortString() + "::" + s_name + "::" + d_type.toString();
		}
		
		function toString() {
			
			if (d_type == BAD_REQUEST) {
				return "BAD_REQUEST";
			} else if (d_type == NOT_FOUND) {
				return "NOT_FOUND";
			}
			return "Unknown";
		}
	}
	
	class GarminSdkError extends Error {
	
		// enum for possible errors can be found in module Communications
		private var d_responseCode;

		function initialize(responseCode) {
			Error.initialize(Error.HTTP);
			
			d_responseCode = responseCode;
		}
	
		static function is(responseCode) {
		
			// Sdk errors are always smaller or equal to zero
			if (responseCode > 0) {
				return null;
			}
			
			return new GarminSdkError(responseCode);
		}
		
		function respCode() {
			return d_responseCode;
		}
		
		function shortString() {
			return d_responseCode.toString();
		}
		
		function toString() {
			return respCodeToString(d_responseCode);
		}
	
		// move to somewhere else later, but now this is one of the two places this is used
	    function respCodeToString(responseCode) {
	    	if (responseCode == Communications.UNKNOWN_ERROR) {
	    		return "\"UNKNOWN_ERROR\"";
	    	} else if (responseCode == Communications.BLE_ERROR) {
	    		return "\"BLE_ERROR\"";
	    	} else if (responseCode == Communications.BLE_HOST_TIMEOUT) {
	    		return "\"BLE_HOST_TIMEOUT\"";
	    	} else if (responseCode == Communications.BLE_SERVER_TIMEOUT) {
	    		return "\"BLE_SERVER_TIMEOUT\"";
	    	} else if (responseCode == Communications.BLE_NO_DATA) {
	    		return "\"BLE_NO_DATA\"";
	    	} else if (responseCode == Communications.BLE_REQUEST_CANCELLED) {
	    		return "\"BLE_REQUEST_CANCELLED\"";
	    	} else if (responseCode == Communications.BLE_QUEUE_FULL) {
	    		return "\"BLE_QUEUE_FULL\"";
	    	} else if (responseCode == Communications.BLE_REQUEST_TOO_LARGE) {
	    		return "\"BLE_REQUEST_TOO_LARGE\"";
	    	} else if (responseCode == Communications.BLE_UNKNOWN_SEND_ERROR) {
	    		return "\"BLE_UNKNOWN_SEND_ERROR\"";
	    	} else if (responseCode == Communications.BLE_CONNECTION_UNAVAILABLE) {
	    		return "\"BLE_CONNECTION_UNAVAILABLE\"";
	    	} else if (responseCode == Communications.INVALID_HTTP_HEADER_FIELDS_IN_REQUEST) {
	    		return "\"INVALID_HTTP_HEADER_FIELDS_IN_REQUEST\"";
	    	} else if (responseCode == Communications.INVALID_HTTP_BODY_IN_REQUEST) {
	    		return "\"INVALID_HTTP_BODY_IN_REQUEST\"";
	    	} else if (responseCode == Communications.INVALID_HTTP_METHOD_IN_REQUEST) {
	    		return "\"INVALID_HTTP_METHOD_IN_REQUEST\"";
	    	} else if (responseCode == Communications.NETWORK_REQUEST_TIMED_OUT) {
	    		return "\"NETWORK_REQUEST_TIMED_OUT\"";
	    	} else if (responseCode == Communications.INVALID_HTTP_BODY_IN_NETWORK_RESPONSE) {
	    		return "\"INVALID_HTTP_BODY_IN_NETWORK_RESPONSE\"";
	    	} else if (responseCode == Communications.INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE) {
	    		return "\"INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE\"";
	    	} else if (responseCode == Communications.NETWORK_RESPONSE_TOO_LARGE) {
	    		return "\"NETWORK_RESPONSE_TOO_LARGE\"";
	    	} else if (responseCode == Communications.NETWORK_RESPONSE_OUT_OF_MEMORY) {
	    		return "\"NETWORK_RESPONSE_OUT_OF_MEMORY\"";
	    	} else if (responseCode == Communications.STORAGE_FULL) {
	    		return "\"STORAGE_FULL\"";
	    	} else if (responseCode == Communications.SECURE_CONNECTION_REQUIRED) {
	    		return "\"SECURE_CONNECTION_REQUIRED\"";
	    	}
	    	return "Unknown";
	    }
	}
}

/* 

- Garmin IQ network/http errors
	- responsecode not in http response codes
	- INVALID_HTTP_BODY_IN_REQUEST, etc...
	
API-defined:
	- Subsonic: responsecode 200,
		0 	A generic error.
		10 	Required parameter is missing.
		20 	Incompatible Subsonic REST protocol version. Client must upgrade.
		30 	Incompatible Subsonic REST protocol version. Server must upgrade.
		40 	Wrong username or password.
		41 	Token authentication not supported for LDAP users.
		50 	User is not authorized for the given operation.
		60 	The trial period for the Subsonic server is over. Please upgrade to Subsonic Premium. Visit subsonic.org for details.
		70 	The requested data was not found.
	- Ampache: responsecode 200
		4700 Access Control not Enabled		The API is disabled. Enable 'access_control' in your config
    	4701 Received Invalid Handshake		This is a temporary error, this means no valid session was passed or the handshake failed
	    4703 Access Denied					The requested method is not available, 
	    	You can check the error message for details about which feature is disabled
	    4704 Not Found						The API could not find the requested object
	    4705 Missing						This is a fatal error, the service requested a method that the API does not implement
	    4706 Depreciated					This is a fatal error, the method requested is no longer available
	    4710 Bad Request					Used when you have specified a valid method but something about the input is incorrect, invalid or missing, 
	    	You can check the error message for details, but do not re-attempt the exact same request
	    4742 Failed Access Check	        Access denied to the requested object or function for this user
	- common errors
		- login problem (subsonic 40, 41, 60) (ampache 4701)
		- access problem (subsonic 50) (ampache 4742)
		- data not found (subsonic 70) (ampache 4704)
		- server/client problem (subsonic 20, 30) (ampache 4700, 4703, 4705, 4706)
		- bad request (subsonic 10) (ampache 4710)
		- bad response 
		
*/