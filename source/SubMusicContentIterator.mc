using Toybox.Media;
using Toybox.Math;
using SubMusic;

class SubMusicContentIterator extends Media.ContentIterator {

	private var d_songcount;
	private var d_playable;

    function initialize() {
        ContentIterator.initialize();

		// retrieve now playing
		d_playable = new SubMusic.IPlayable();
		
		d_songcount = d_playable.size();
    }

    // Determine if the the current track can be skipped.
    function canSkip() {
        return true;			// probably behaviour should depend on podcast/playlist type
    }

    // Get the current media content object.
    function get() {
    	if (d_playable.songidx() >= d_songcount)
    	{
    		return null;
    	}
        return getObj(d_playable.songidx());
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
        ];
		// add skip forward buttons if enabled
		if (Application.Properties.getValue("skip_30s")) {
			profile.playbackControls.addAll([
				PLAYBACK_CONTROL_SKIP_FORWARD,
				PLAYBACK_CONTROL_SKIP_BACKWARD,
			]);
		}
        profile.playbackNotificationThreshold = 30;
        profile.requirePlaybackNotification = true;		// notify played
        profile.skipPreviousThreshold = 5;
        // profile.supportsPlaylistPreview = true;
        return profile;
    }

    // Get the next media content object.
    function next() {
    	if ((d_playable.songidx() + 1) >= d_songcount)
    	{
    		return null;
    	}
		d_playable.incSongIdx();
    	return getObj(d_playable.songidx());
    }

    // Get the next media content object without incrementing the iterator.
    function peekNext() {
    	if ((d_playable.songidx() + 1) >= d_songcount)
    	{
    		return null;
    	}
    	return getObj(d_playable.songidx() + 1);
    }

    // Get the previous media content object without decrementing the iterator.
    function peekPrevious() {
    	if (d_playable.songidx() == 0)
    	{
    		return null;
    	}
    	return getObj(d_playable.songidx() - 1);
    }

    // Get the previous media content object.
    function previous() {
    	if (d_playable.songidx() == 0)
    	{
    		return null;
    	}
		d_playable.decSongIdx();
    	return getObj(d_playable.songidx());
    }

    // Determine if playback is currently set to shuffle.
    function shuffling() {
        return d_playable.shuffle();
    }
    
    function toggleShuffle() {
		d_playable.shuffleIdcs(!d_playable.shuffle());
    }

	// Retrieve the cached object from Media
	function getObj(idx) {

		// retrieve content reference
		var audio = d_playable.getAudio(idx);
		var contentRef = new Media.ContentRef(audio.refId(), Media.CONTENT_TYPE_AUDIO);
		
		// retrieve metadata
		var content = Media.getCachedContentObj(contentRef);
		var metadata = content.getMetadata();

		// add stored metadata if not given in file (Plex does not provide metadata in file)
		var has_title = (metadata.title != null) && (metadata.title instanceof Lang.String) && (!metadata.title.equals(""));
		var has_artist = (metadata.artist != null) && (metadata.artist instanceof Lang.String) && (!metadata.artist.equals(""));
		if (!has_title) {
			metadata.title = audio.title();
		}
		if (!has_artist) {
			metadata.artist = audio.artist();
		}
		
		// default playback is 0, unless in podcast mode, some position is stored before and position is not within five seconds of the end
		var playbackStartPos = 0;	
		if (d_playable.podcast_mode()
			&& (audio.playback() != null)) {
			playbackStartPos = audio.playback();
		}

		// return content
		return new Media.ActiveContent(contentRef, metadata, playbackStartPos);
	}
}
