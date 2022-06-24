using Toybox.Communications;

module SubMusic {
	
	class Error {
		static enum {
			HTTP,
			API,
		}

		// map errors to string representation
		static private var stringmap = {
			HTTP => "HTTP",
			API => "API",
		};

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
			var string = stringmap.get(type);
			if (string == null) {
				string = "Unknown";
			}
			return string;
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

		// map errors to string representation
		static private var stringmap = {
			LOGIN 			=> "LOGIN",
	    	ACCESS 			=> "ACCESS",
	    	NOTFOUND 		=> "NOTFOUND",
	    	SERVERCLIENT 	=> "SERVERCLIENT",
	    	BADREQUEST 		=> "BADREQUEST",
	    	BADRESPONSE 	=> "BADRESPONSE",
	    	UNKNOWN 		=> "UNKNOWN",
		};
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
			var string = stringmap.get(type);
			if (string == null) {
				string = "Unknown";
			}
			return string;
	    }
	}
	
	class HttpError extends Error {
		
		static enum {
			BAD_REQUEST = 400,
			UNAUTHORIZED = 401,
			FORBIDDEN = 403,
			NOT_FOUND = 404,
		}

		// map errors to string representation
		static private var stringmap = {
			BAD_REQUEST => "Bad Request",
			UNAUTHORIZED => "Unauthorized",
			FORBIDDEN => "Forbidden",
			NOT_FOUND => "Not Found",
		};

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
			var string = stringmap.get(type);
			if (string == null) {
				string = "Unknown";
			}
			return string;
		}
	}
	
	class GarminSdkError extends Error {
	
		// enum for possible errors can be found in module Communications

		// map errors to string representation
		static private var stringmap = {
			Communications.UNKNOWN_ERROR 									=> "UNKNOWN_ERROR",
	    	Communications.BLE_ERROR 										=> "BLE_ERROR",
	    	Communications.BLE_HOST_TIMEOUT 								=> "BLE_HOST_TIMEOUT",
	    	Communications.BLE_SERVER_TIMEOUT 								=> "BLE_SERVER_TIMEOUT",
	    	Communications.BLE_NO_DATA 										=> "BLE_NO_DATA",
	    	Communications.BLE_REQUEST_CANCELLED 							=> "BLE_REQUEST_CANCELLED",
	    	Communications.BLE_QUEUE_FULL 									=> "BLE_QUEUE_FULL",
	    	Communications.BLE_REQUEST_TOO_LARGE 							=> "BLE_REQUEST_TOO_LARGE",
	    	Communications.BLE_UNKNOWN_SEND_ERROR 							=> "BLE_UNKNOWN_SEND_ERROR",
	    	Communications.BLE_CONNECTION_UNAVAILABLE 						=> "BLE_CONNECTION_UNAVAILABLE",
	    	Communications.INVALID_HTTP_HEADER_FIELDS_IN_REQUEST 			=> "INVALID_HTTP_HEADER_FIELDS_IN_REQUEST",
	    	Communications.INVALID_HTTP_BODY_IN_REQUEST 					=> "INVALID_HTTP_BODY_IN_REQUEST",
	    	Communications.INVALID_HTTP_METHOD_IN_REQUEST 					=> "INVALID_HTTP_METHOD_IN_REQUEST",
	    	Communications.NETWORK_REQUEST_TIMED_OUT 						=> "NETWORK_REQUEST_TIMED_OUT",
	    	Communications.INVALID_HTTP_BODY_IN_NETWORK_RESPONSE 			=> "INVALID_HTTP_BODY_IN_NETWORK_RESPONSE",
	    	Communications.INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE	=> "INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE",
	    	Communications.NETWORK_RESPONSE_TOO_LARGE 						=> "NETWORK_RESPONSE_TOO_LARGE",
	    	Communications.NETWORK_RESPONSE_OUT_OF_MEMORY 					=> "NETWORK_RESPONSE_OUT_OF_MEMORY",
	    	Communications.STORAGE_FULL 									=> "STORAGE_FULL",
	    	Communications.SECURE_CONNECTION_REQUIRED 						=> "SECURE_CONNECTION_REQUIRED",
	    	Communications.UNSUPPORTED_CONTENT_TYPE_IN_RESPONSE 			=> "UNSUPPORTED_CONTENT_TYPE_IN_RESPONSE",
	    	Communications.REQUEST_CANCELLED 								=> "REQUEST_CANCELLED",
	    	Communications.REQUEST_CONNECTION_DROPPED 						=> "REQUEST_CONNECTION_DROPPED",
	    	Communications.UNABLE_TO_PROCESS_MEDIA 							=> "UNABLE_TO_PROCESS_MEDIA",
	    	Communications.UNABLE_TO_PROCESS_IMAGE 							=> "UNABLE_TO_PROCESS_IMAGE",
	    	Communications.UNABLE_TO_PROCESS_HLS 							=> "UNABLE_TO_PROCESS_HLS",
		};
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
			var string = stringmap.get(responseCode);
			if (string == null) {
				string = "Unknown";
			}
			return string;
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