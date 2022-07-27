using Toybox.System;
using Toybox.Media;
using Toybox.Lang;

module SubMusic {
	module Utils {

		// implementation of bubble sort, returning idcs to sort original
//		function sort_idcs(array) {
//			var size = array.size();
//			
//			// empty array is sorted 
//			if (size == 0) {
//				return [];
//			}
//			
//			var result = new[size];
//			for (var idx = 0; idx != size; ++idx) {
//				result[idx] = idx;
//			}
//			
//			var sorted;
//			do {
//				sorted = true;
//				var bubble = result[0];
//				for (var idx = 0; idx != size - 1; ++idx) {
//					if (array[bubble] > array[result[idx + 1]]) {
//						result[idx] = result[idx + 1];
//						result[idx + 1] = bubble;
//						sorted = false;
//					} else {
//						bubble = result[idx + 1];
//					}
//				}
//			} while (!sorted);
//			
//			return result;
//		}
	
		// for numbers only
		function compare(left, right) {
			var diff = left - right;
			if (diff < 0) {
				return -1;
			}
			if (diff > 0) {
				return 1;
			}
			return 0;
		}

		function copy(dict as Lang.Dictionary) as Lang.Dictionary {
			var ret = {};
			for (var idx = 0; idx < dict.keys().size(); ++idx) {
				var key = dict.keys()[idx];
				ret.put(key, dict.get(key));
			}
			return ret;
		}

		// merge two dictionaries, maybe improve by filtering keys e.g.
		// function merge(dict, dict2, keystocopy)
		function merge(dict as Lang.Dictionary, dict2 as Lang.Dictionary) as Lang.Dictionary {
			var ret = copy(dict);
			var keys = dict2.keys();
			for (var idx = 0; idx != keys.size(); ++idx) {
				var key = keys[idx];
				ret.put(key, dict2.get(key));
			}
			return ret;
		}	

		function mimeToEncoding(mime) {
			// mime should be a string
			if (!(mime instanceof Lang.String)) {
				return Media.ENCODING_INVALID;
			}
			// check docs: https://developer.mozilla.org/en-US/docs/Web/Media/Formats/Containers
			if (mime.equals("audio/mpeg")) {
				return Media.ENCODING_MP3;
			}
			if (mime.equals("audio/mp4")) {
				return Media.ENCODING_M4A;
			}
			if (mime.equals("audio/aac")) {
				return Media.ENCODING_ADTS;
			}
			if (mime.equals("audio/wave")
				|| mime.equals("audio/wav")
				|| mime.equals("audio/x-wav")
				|| mime.equals("audio/x-pn-wav")) {
				return Media.ENCODING_WAV;
			}

			// known mime types, but not supported by the sdk
			if (mime.equals("audio/x-flac")) {
				return Media.ENCODING_INVALID;
			}

			// mime type not defined
			return Media.ENCODING_INVALID;
		}
	}
}