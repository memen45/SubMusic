using Toybox.Media;
using Toybox.Application;

// Keys for Storage
module Storage_Deprecated {
	enum {
		PLAYLIST,
		SONGS_LOCAL,
		PLAYLIST_LOCAL,
		PLAYLIST_SYNC,
		PLAYLIST_DELETE,
		
		SONGS_SYNC,
		SONGS_DELETE,
	}
}

module Storage {
	enum {
		PLAYLIST,		// playlist id of current playist

		SONGS,			// dictionary where song id is key
		SONGS_DELETE,	// array of song ids of todelete songs (refCount == 0)
		
		PLAYLISTS,		// dictionary where playlist id is key
		
		LAST_SYNC,		// dictionary with details on last sync 
		VERSION = 200,	// version string of store
	}

	class Version {

		private var d_major = 0;
		private var d_minor = 0;
		private var d_patch = 16;

		function initialize(storage) {
			if (storage == null) {
				return;
			}
			d_major = storage["major"];
			d_minor = storage["minor"];
			d_patch = storage["patch"];
		}

		function equals(storage) {
			if (storage == null) {
				return false;
			}
			if (!(storage instanceof Lang.Dictionary)) {
				return false;
			}
			return toString().equals(storage["version"]);
		}

		function toString() {
			return d_major.toString() 
					+ "." + d_minor.toString()
					+ "." + d_patch.toString();
		}

		function toStorage() {
			return {
				"version" => toString(),
				"major" => d_major,
				"minor" => d_minor,
				"patch" => d_patch,
			};
		}
	}

	function check() {
		var current = new Version(null);
		
		var storage = Application.Storage.getValue(VERSION);
		if (storage == null) {
			// normally: new install
			// for Version.V0_0_16_PI only: fix storage if available
			tryFixDeprecated();

			// store current version number to storage
			Application.Storage.setValue(VERSION, current.toStorage());
			return;
		}
		var version = new Version(storage);
		if (current.equals(version)) {
			// same version, nothing to do
			return;
		}
		// future should provide code here to update existing storages
	}

	function tryFixDeprecated() {
		// check if any existing playlists
		var playlists = Application.Storage.getValue(Storage_Deprecated.PLAYLIST_LOCAL);
		if (playlists == null) {
			Application.Storage.clearValues();
			return;
		}

		// check if any existing songs
		var songs = Application.Storage.getValue(Storage_Deprecated.SONGS_LOCAL);
		if (songs == null) {
			Application.Storage.clearValues();
			return;
		}
		Application.Storage.clearValues();

		// here we have both playlists and songs

		// store playlist ids
		var pl_ids = playlists.keys();
		for (var idx = 0; idx < pl_ids.size(); ++idx) {
			var playlist = new IPlaylist(pl_ids[idx]);
			playlist.setLocal(true);
			playlist.setName(playlists[pl_ids[idx]]["name"]);
			playlist.setCount(playlists[pl_ids[idx]]["songCount"]);
			playlist.setRemote(true);
		}

		// safely remove all songs from cache
		var refIds = songs.keys();
		for (var idx = 0; idx < refIds.size(); ++idx) {
			var refId = refIds[idx];
			if (refId != null) {
				// remove from media cache
				var contentRef = new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO);
				Media.deleteCachedItem(contentRef);
			}
		}
	}
}

module ApiStandard {
	enum {
		SUBSONIC = 0,
		AMPACHE = 1,
	}
}

// Menu keys - not stored persistently
module SyncMenu {
	enum {
		START_SYNC,
		PLAYLISTS,
		TEST,
	}
}
