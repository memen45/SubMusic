using Toybox.Communications;

module SubMusic {
	
	class Error {
		static enum {
			HTTP,
			API,
		}
		static private var s_name = "Error";
		private var d_type;
		
		function initialize(type) {
			System.println(s_name + "::" + Error.typeToString(type));
			d_type = type;
		}
		
		function type() {
			return d_type;
		}
		
		function shortString() {
			return s_name + " " + Error.typeToString(d_type);
	    }
	    
	    function toString() {
	    	return s_name + " " + Error.typeToString(d_type);
	    }

		static function typeToString(type) {
			if (type == HTTP) {
				return "HTTP";
			} else if (type == API) {
				return "API";
			}
			return "Unknown Error";
		}
	}
	
	class ApiError extends Error {
		
		static enum {
			LOGIN,
			ACCESS,
			NOTFOUND,
			SERVERCLIENT,
			BADREQUEST,
			BADRESPONSE,
			UNKNOWN,
		}		
		private var d_type;
		static private var s_name = "ApiError";
		
		function initialize(type) {
			Error.initialize(Error.API);

			System.println(s_name + "::" + ApiError.typeToString(type));
			
			d_type = type;
		}
		
		function shortString() {
	    	return s_name + "::" + ApiError.typeToString(d_type);
	    }

		function toString() {
			return SubMusic.Error.toString() + 
					" --> " + 
					s_name + "::" + ApiError.typeToString(d_type);
		}
	    
	    function type() {
	    	return d_type;
	    }

		function api_type() {
			return ApiError.type();
		}
	    
	    static function typeToString(type) {
	    
	    	if (type == LOGIN) {
	    		return "\"LOGIN\"";
	    	} else if (type == ACCESS) {
	    		return "\"ACCESS\"";
	    	} else if (type == NOTFOUND) {
	    		return "\"NOTFOUND\"";
	    	} else if (type == SERVERCLIENT) {
	    		return "\"SERVERCLIENT\"";
	    	} else if (type == BADREQUEST) {
	    		return "\"BADREQUEST\"";
	    	} else if (type == BADRESPONSE) {
	    		return "\"BADRESPONSE\"";
	    	} else if (type == UNKNOWN) {
	    		return "\"UNKNOWN\"";
	    	}
	    	return "Unknown ApiError";
	    }
	}
	
	class HttpError extends Error {
		
		static enum {
			BAD_REQUEST = 400,
			UNAUTHORIZED = 401,
			FORBIDDEN = 403,
			NOT_FOUND = 404,
		}
		private var d_type;
		static private var s_name = "HttpError";
		
		function initialize(type) {
			Error.initialize(Error.HTTP);
			d_type = type;

			System.println(HttpError.toString());
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
			return s_name + "::" + d_type.toString();
		}

		function toString() {
			return Error.toString() +
					" --> " + 
					s_name + "::" + HttpError.typeToString(d_type);
		}
		
		static function typeToString(type) {
			
			if (type == BAD_REQUEST) {
				return "Bad Request";
			} else if (type == UNAUTHORIZED) {
				return "Unauthorized";
			} else if (type == FORBIDDEN) {
				return "Forbidden";
			} else if (type == NOT_FOUND) {
				return "Not Found";
			}
			return "Unknown HttpError";
		}
	}
	
	class GarminSdkError extends Error {
	
		// enum for possible errors can be found in module Communications
		private var d_responseCode;
		static private var s_name = "GarminSdkError";

		function initialize(responseCode) {
			Error.initialize(Error.HTTP);
			d_responseCode = responseCode;

			System.println(GarminSdkError.toString());
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
			return s_name + "::" + d_responseCode.toString();
		}
		
		function toString() {
			return Error.toString() + 
					" --> " + 
					s_name + "::" + GarminSdkError.respCodeToString(d_responseCode);
		}
	
		// move to somewhere else later, but now this is one of the two places this is used
	    static function respCodeToString(responseCode) {
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
	    	} else if (responseCode == Communications.UNSUPPORTED_CONTENT_TYPE_IN_RESPONSE) {
	    		return "\"UNSUPPORTED_CONTENT_TYPE_IN_RESPONSE\"";
	    	} else if (responseCode == Communications.REQUEST_CANCELLED) {
	    		return "\"REQUEST_CANCELLED\"";
	    	} else if (responseCode == Communications.REQUEST_CONNECTION_DROPPED) {
	    		return "\"REQUEST_CONNECTION_DROPPED\"";
	    	} else if (responseCode == Communications.UNABLE_TO_PROCESS_MEDIA) {
	    		return "\"UNABLE_TO_PROCESS_MEDIA\"";
	    	} else if (responseCode == Communications.UNABLE_TO_PROCESS_IMAGE) {
	    		return "\"UNABLE_TO_PROCESS_IMAGE\"";
	    	} else if (responseCode == Communications.UNABLE_TO_PROCESS_HLS) {
	    		return "\"UNABLE_TO_PROCESS_HLS\"";
	    	}
	    	return "Unknown GarminSdkError";
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