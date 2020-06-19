using Toybox.Time;
using Toybox.Cryptography;
using Toybox.Communications;
 
class AmpacheAPI {
 
	private var d_url = Application.Properties.getValue("API_url") + "/server/json.server.php";
 	private var d_user = Application.Properties.getValue("API_user");
 	private var d_client = "SubMusic";
 	private var d_hash;		// password hash, required for every handshake
 	
 	private var d_auth;
 	private var d_auth_expire;
 	
 	
 	function initialize() {
 		var hasher = new Cryptography.Hash({:algorithm => Cryptography.HASH_SHA256});
 		
 		// hash the password
 		var pw = Application.Properties.getValue("API_key");
 		hasher.update(pw);
 		d_hash = hasher.digest();
 		
 		// set expire time to 0
 		d_auth_expire = new Time.Moment(0);
 	}
 	
 	function handshake() {
 		var hasher = new Cryptography.Hash({:algorithm => Cryptography.HASH_SHA256});
 		
 		// get the time
 		var timestamp = Time.now().value();
 		
 		// construct the auth
 		hasher.update(timestamp);
 		hasher.update(d_hash);
 		d_auth = hasher.digest();
 		
 		var params = {
 			"action" => "handshake",
 			"user" => d_user,
 			"timestamp" => timestamp,
 			"auth" => d_auth,
 		};
 		Communications.makeWebRequest(d_url, params, {}, self.method(:onHandshake));
 	}
 	
 	function onHandshake(responseCode, data) {
 		System.println("AmpacheAPI: onHandshake with responseCode " + responseCode + " payload " + data);
 		
 		// check if request was successful 
 		if ((responseCode != 200)
 				|| (data == null)
 				|| (data["error"] != null)) {
 			d_fallback.invoke(responseCode, data);
 			return;
 		}
 		
 		// store the auth key for future communication
 		d_auth = data["auth"];
 		var expire = parseISODate(data["session_expire"]);
 		if (expire != null) {
 			d_auth_expire = expire;
 		}
 	}
 	
 	// returns true if the current session is not expired
 	function session() {
 		var now = new Time.Moment(Time.now().value());
 		return now.lessThan(d_auth_expire);
 	}
 	
 	// converts rfc3339 formatted timestamp to Time::Moment (null on error)
	function parseISODate(date) {
		// assert(date instanceOf String)
		if (date == null) {
			return null;
		}
		
		// 0123456789012345678901234
		// 2011-10-17T13:00:00-07:00
		// 2011-10-17T16:30:55.000Z
		// 2011-10-17T16:30:55Z
		if (date.length() < 20) {
			return null;
		}
		
		var moment = Gregorian.moment({
			:year 	=> date.substring( 0,  4).toNumber(),
			:month 	=> date.substring( 5,  7).toNumber(),
			:day 	=> date.substring( 8, 10).toNumber(),
			:hour 	=> date.substring(11, 13).toNumber(),
			:minute => date.substring(14, 16).toNumber(),
			:second => date.substring(17, 19).toNumber(),
		});
		var suffix = date.substring(19, date.length());
		
		// skip over to time zone
		var tz = 0;
		if (suffix.substring(tz, tz + 1).equals(".")) {
			while (tz < suffix.length()) {
				var first = suffix.substring(tz, tz + 1);
				if ("-+Z".find(first) != null) {
					break;
				}
				tz++;
			}
		}
		
		if (tz >= suffix.length()) {
			// no timezone given
			return null;
		}
		var tzOffset = 0;
		if (!suffix.substring(tz, tz + 1).equals("Z")) {
			// +HH:MM
			if (suffix.length() - tz < 6) {
				return null;
			}
			tzOffset = suffix.substring(tz + 1, tz + 3).toNumber() * Gregorian.SECONDS_PER_HOUR;
			tzOffset += suffix.substring(tz + 4, tz + 6).toNumber() * Gregorian.SECONDS_PER_MINUTE;
		
			var sign = suffix.substring(tz, tz + 1);
			if (sign.equals("+")) {
				tzOffset = -tzOffset;
			} else if (sign.equals("-") && tzOffset == 0) {
				// -00:00 denotes unknown timezone
				return null;
			}
		}
		return moment.add(new Time.Duration(tzOffset));
	}
}