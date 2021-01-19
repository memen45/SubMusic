using Toybox.Media;
using Toybox.Math;

class SubMusicContentIterator extends Media.ContentIterator {

	private var d_songidx = 0;
	private var d_songcount;
	
	private var d_playable;

    function initialize() {
        ContentIterator.initialize();

		// retrieve now playing start object
		d_playable = SubMusic.NowPlaying.getPlayable();
		d_songidx = d_playable.songIdx();
		d_songcount = d_playable.size();
    }

	// function initializePlaylist() {

	// 	// reset current array of refIds
	// 	d_songs = [];
	// 	d_songidx = 0;

	// 	// retrieve now playing
	// 	var playable = SubMusic.NowPlaying.getPlayable();
	// 	d_songs = playable.getRefIds();
	// 	d_songidx = playable.getSongIdx();

	// 	// if something on the list, done
	// 	if (d_songs.size() != 0) {
	// 		return;
	// 	}

	// 	// otherwise, just try the first playlist with songs
	// 	var ids = PlaylistStore.getIds();
	// 	var loaded = false;
	// 	for (var idx = 0; idx < ids.size(); ++idx) {
	// 		var  playlist = new IPlaylist(ids[idx]);
	// 		if (playlist.songs().size() != 0) {
	// 			load(playlist);
	// 			return;
	// 		}
	// 	}

	// 	// if everything fails, initialize from cached songs
	// 	loadEmpty();
	// }

    // Determine if the the current track can be skipped.
    function canSkip() {
        return true;			// probably behaviour should depend on podcast/playlist type
    }

    // Get the current media content object.
    function get() {
    	if (d_songidx >= d_songcount)
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
        profile.playbackNotificationThreshold = 30;
        profile.requirePlaybackNotification = true;		// notify played
        profile.skipPreviousThreshold = 5;
        profile.supportsPlaylistPreview = true;
        return profile;
    }

    // Get the next media content object.
    function next() {
    	if ((d_songidx + 1) >= d_songcount)
    	{
    		return null;
    	}

    	d_songidx++;
		d_playable.incSongIdx();

    	return getObj(d_songidx);
    }

    // Get the next media content object without incrementing the iterator.
    function peekNext() {
    	if ((d_songidx + 1) >= d_songcount)
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
		d_playable.decSongIdx();
    	return getObj(d_songidx);
    }

    // Determine if playback is currently set to shuffle.
    function shuffling() {
        return d_playable.shuffle();
    }
    
    function toggleShuffle() {
		d_playable.shuffleIdcs(!d_playable.shuffle());
    }

	// // Load playlist from storage or create one from all songs available
	// function load(playlist) {
	// 	d_songs = [];
	// 	d_songidx = 0;
		
	// 	// add all songs with a refId to list
	// 	var songs = playlist.songs();
	// 	for (var idx = 0; idx < songs.size(); ++idx) {
	// 		var isong = new ISong(songs[idx]);
	// 		var refId = isong.refId();
	// 		if (refId != null) {
	// 			d_songs.add(refId);
	// 		}
	// 	}
	// }

	// function loadEmpty() {
	// 	d_songs = [];

	// 	var availables = Media.getContentRefIter({:contentType => Media.CONTENT_TYPE_AUDIO});
	// 	if (availables == null) {
	// 		return;
	// 	}
		
	// 	// add all songs available 
	// 	var song = availables.next();
	// 	while (song != null) {
	// 		d_songs.add(song.getId());
	// 		song = availables.next();
	// 	}
	// }
	
	// Retrieve the cached object from Media
	function getObj(idx) {

		// retrieve content reference
		var songid = d_playable.getSongId(idx);
		var isong = new ISong(songid);
		var contentRef = new Media.ContentRef(isong.refId(), Media.CONTENT_TYPE_AUDIO);
		
		// retrieve metadata
		var content = Media.getCachedContentObj(contentRef);
		var metadata = content.getMetadata();

		// default playback is 0, unless in podcast mode, some position is stored before and position is not within five seconds of the end
		var playbackStartPos = 0;	
		if (d_playable.podcast()
			&& (isong.playback() != null)) {
			playbackStartPos = isong.playback();
		}

		// return content
		return new Media.ActiveContent(contentRef, metadata, playbackStartPos);
	}
	
	// reorder the playlist randomly
	// function shufflePlaylist() {
	
	// 	// check for empty playlist
	// 	if (d_songs.size() == 0) {
	// 		d_songidx = 0;
	// 		return;
	// 	}
		
	// 	// swap current to head of list
	// 	var tmp = d_songs[0];
	// 	d_songs[0] = d_songs[d_songidx];
	// 	d_songs[d_songidx] = tmp;
	
	// 	for (var idx = 1; idx < d_songs.size(); ++idx) {
	// 		tmp = d_songs[idx];
	// 		var other = (Math.rand() % (d_songs.size() - idx)) + idx;
	// 		d_songs[idx] = d_songs[other];
	// 		d_songs[other] = tmp;
	// 	}
		
	// 	d_songidx = 0;
	// }
}
