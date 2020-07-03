using Toybox.Time;
using Toybox.Cryptography;
using Toybox.StringUtil;
using Toybox.Communications;
 
class AmpacheAPI {
 
	private var d_url;
	private var d_usr;
	private var d_client;
	private var d_hash;		// password hash, required for every handshake
	
	private var d_session;
	private var d_expire;
	
	private var d_callback;
	private var d_fallback;
	
	
	function initialize(settings, fallback) {
		d_url = settings.get("api_url") + "/server/json.server.php";
		d_usr = settings.get("api_usr");
		d_client = (WatchUi.loadResource(Rez.Strings.AppName) + " v" + WatchUi.loadResource(Rez.Strings.AppVersionTitle));
	
		// hash the password
		var hasher = new Cryptography.Hash({:algorithm => Cryptography.HASH_SHA256});
		hasher.update(string_to_ba(settings.get("api_key")));
		d_hash = ba_to_hexstring(hasher.digest());

		d_fallback = fallback;
		
		// print the configuration for debugging
    	System.println("Initialize AmpacheAPI, url: " + d_url 
    										+ ", user: " + d_usr 
    										+ ", pass: " + d_hash
    										+ ", client name: " + d_client);
		
		// check if auth is expired, it may be usable!
		d_expire = new Time.Moment(0);
		d_session = Application.Storage.getValue("AMPACHE_API_SESSION");
		if ((d_session == null)
			|| (d_session["session_expire"] == null)) {
			return;
		}
		var expire = parseISODate(d_session["session_expire"]);
		if (expire == null) {
			return;
		}
		d_expire = expire;
	}
	
	function handshake(callback) {
		d_callback = callback;

		var hasher = new Cryptography.Hash({:algorithm => Cryptography.HASH_SHA256});
		
		// get the time
		var timestamp = Time.now().value().format("%i");
		
		// construct the auth
		hasher.update(string_to_ba(timestamp));
		hasher.update(string_to_ba(d_hash));
		var auth = hasher.digest();
		
		var params = {
			"action" => "handshake",
			"user" => d_usr,
			"timestamp" => timestamp,
			"auth" => auth,
		};
		
		System.println("AmpacheAPI::handshake with timestamp " + timestamp + " and auth " + ba_to_hexstring(auth));
		
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
		
		// store the session
		d_session = data;
		Application.Storage.setValue("AMPACHE_API_SESSION", d_session);

		// store the auth key for future communication
		var expire = parseISODate(d_session["session_expire"]);
		if (expire != null) {
			d_expire = expire;
		}
		d_callback.invoke();
	}
	
	// returns array of playlist objects
	function playlists(callback, params) {
		System.println("AmpacheAPI::playlists");
		
		if (params == null) {
			params = {};
		}

		params.put("action", "playlists");
		params.put("auth", d_session.get("auth"));
		Communications.makeWebRequest(d_url, params, {}, self.method(:onPlaylists));
	}
	
	function onPlaylists(responseCode, data) {
		System.println("AmpacheAPI::onPlaylists with responseCode: " + responseCode + ", payload " + data);
	
		// check if request was successful and response is ok
		if ((responseCode != 200) 
				|| (data == null)) {
			d_fallback.invoke(responseCode, data);
			return;
		}
	d_callback.invoke(data);
    }
	
	// returns single playlist info
	function playlist(callback, params) {
		System.println("AmpacheAPI::playlist id = " + params["id"]);
		
		params.put("action", "playlist");
		params.put("auth", d_session.get("auth"));
		Communications.makeWebRequest(d_url, params, {}, self.method(:onPlaylist));
	}
	
	function onPlaylist(responseCode, data) {
		System.println("AmpacheAPI::onPlaylist with responseCode: " + responseCode + ", payload " + data);
	
		// check if request was successful and response is ok
		if ((responseCode != 200) 
				|| (data == null)) {
			d_fallback.invoke(responseCode, data);
			return;
		}
		d_callback.invoke(data);
    }
	
	// returns array of song objects
	function playlist_songs(callback, params) {
		System.println("AmpacheAPI::playlist_songs " + params["id"]);
		
		params.put("action", "playlist_songs");
		params.put("auth", d_session.get("auth"));
		Communications.makeWebRequest(d_url, params, {}, self.method(:onPlaylist_songs));
	}
	
	function onPlaylist_songs(responseCode, data) {
		System.println("AmpacheAPI::onPlaylist_songs with responseCode: " + responseCode + ", payload " + data);
	
		// check if request was successful and response is ok
		if ((responseCode != 200) 
				|| (data == null)) {
			d_fallback.invoke(responseCode, data);
			return;
		}
		d_callback.invoke(data);
    }
	
	// returns refId to the downloaded song
	function stream(callback, params) {
		d_callback = callback;
		
		params.put("action", "stream");
		params.put("auth", d_session.get("auth"));
		
		if (!params.hasKey("type")) {
			params.put("type", "song");
		}
		var options = {
			:method => Communications.HTTP_REQUEST_METHOD_GET,
			:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
			:mediaEncoding => Media.ENCODING_MP3,
		};
		Communications.makeWebRequest(d_url, params, options, self.method(:onStream));
	}
	
	function onStream(responseCode, data) {
		System.println("AmpacheAPI::onStream with responseCode: " + responseCode);
		
		// check if request was successful and response is ok
		if (responseCode != 200) {
		d_fallback.invoke(responseCode, data);
			return;
		}
		d_callback.invoke(data.getId());
    }
	
	// returns true if the current session is not expired (optionally pass in duration for session)
	function session(duration) {
		var now = new Time.Moment(Time.now().value());
		if (duration != null) {
			now.add(duration);
		}
		return now.lessThan(d_expire);
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
			:year	=> date.substring( 0,  4).toNumber(),
			:month	=> date.substring( 5,  7).toNumber(),
			:day	=> date.substring( 8, 10).toNumber(),
			:hour	=> date.substring(11, 13).toNumber(),
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
	
	function string_to_ba(string) {
		var options = {
			:fromRepresentation => StringUtil.REPRESENTATION_STRING_PLAIN_TEXT,
			:toRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
		};
		return StringUtil.convertEncodedString(string, options);
	}
	
	function ba_to_hexstring(ba) {
		var options = {
			:fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
			:toRepresentation => StringUtil.REPRESENTATION_STRING_HEX,
		};
		return StringUtil.convertEncodedString(ba, options);
	}
}