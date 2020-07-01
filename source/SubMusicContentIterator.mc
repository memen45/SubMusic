using Toybox.Media;
using Toybox.Math;

class SubMusicContentIterator extends Media.ContentIterator {

	private var d_songidx = 0;
	private var d_playlist;
	
	private var d_shuffle = false;

    function initialize() {
        ContentIterator.initialize();
    
    	initializePlaylist();
    }

    // Determine if the the current track can be skipped.
    function canSkip() {
        return false;
    }

    // Get the current media content object.
    function get() {
    	if (d_songidx >= d_playlist.size())
    	{
    		return null;
    	}
    	
        return getObj(d_songidx);
    }

    // Get the current media content playback profile
    function getPlaybackProfile() {
        var profile = new Media.PlaybackProfile();
        profile.attemptSkipAfterThumbsDown = true;
        profile.playbackControls = [
            PLAYBACK_CONTROL_NEXT,
            PLAYBACK_CONTROL_PREVIOUS,
            PLAYBACK_CONTROL_VOLUME,
            
            PLAYBACK_CONTROL_LIBRARY,
            
            PLAYBACK_CONTROL_SHUFFLE,
            PLAYBACK_CONTROL_REPEAT,
			PLAYBACK_CONTROL_SKIP_FORWARD,
			PLAYBACK_CONTROL_SKIP_BACKWARD,
        ];
        profile.playbackNotificationThreshold = 1;
        profile.requirePlaybackNotification = false;
        profile.skipPreviousThreshold = 5;
        profile.supportsPlaylistPreview = true;
        return profile;
    }

    // Get the next media content object.
    function next() {
    	if ((d_songidx + 1) >= d_playlist.size())
    	{
    		return null;
    	}
    	d_songidx++;
    	return getObj(d_songidx);
    }

    // Get the next media content object without incrementing the iterator.
    function peekNext() {
    	if ((d_songidx + 1) >= d_playlist.size())
    	{
    		return null;
    	}
    	return getObj(d_songidx + 1);
    }

    // Get the previous media content object without decrementing the iterator.
    function peekPrevious() {
    	if (d_songidx == 0)
    	{
    		return null;
    	}
    	return getObj(d_songidx - 1);
    }

    // Get the previous media content object.
    function previous() {
    	if (d_songidx == 0)
    	{
    		return null;
    	}
    	d_songidx--;
    	return getObj(d_songidx);
    }

    // Determine if playback is currently set to shuffle.
    function shuffling() {
        return d_shuffle;
    }
    
    function toggleShuffle() {
    	d_shuffle = !d_shuffle;
    	
     	if (d_shuffle) {
     		shufflePlaylist();
     	} else {
     		initializePlaylist();
     	}
    }

	// Load playlist from storage or create one from all songs available
	function initializePlaylist() {
		d_playlist = [];
		
		var playlist = Application.Storage.getValue(Storage.PLAYLIST);
		var lists = Application.Storage.getValue(Storage.PLAYLIST_LOCAL);
		
		if ((playlist != null) && (lists[playlist] != null))
		{
			var songs = lists[playlist]["entry"];
			var store = new SubMusicSongStore();
			for (var idx = 0; idx < songs.size(); ++idx) {
				var refId = store.getRefIdById(songs[idx]["id"]);
				if (refId != null) {
					d_playlist.add(refId);
				}
			}
			return;
		}
		
		var availables = Media.getContentRefIter({:contentType => Media.CONTENT_TYPE_AUDIO});
		if (availables == null)
		{
			return;
		}
		
		var song = availables.next();
		while (song != null) {
			d_playlist.add(song.getId());
			song = availables.next();
		}
	}
	
	// Retrieve the cached object from Media
	function getObj(idx) {
		return Media.getCachedContentObj(new Media.ContentRef(d_playlist[idx], Media.CONTENT_TYPE_AUDIO));
	}
	
	// reorder the playlist randomly
	function shufflePlaylist() {
		// swap current to head of list
		var tmp = d_playlist[0];
		d_playlist[0] = d_playlist[d_songidx];
		d_playlist[d_songidx] = tmp;
	
		for (var idx = 1; idx < d_playlist.size(); ++idx) {
			tmp = d_playlist[idx];
			var other = (Math.rand() % (d_playlist.size() - idx)) + idx;
			d_playlist[idx] = d_playlist[other];
			d_playlist[other] = tmp;
		}
		
		d_songidx = 0;
	}
}
