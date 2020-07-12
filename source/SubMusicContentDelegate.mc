using Toybox.Media;

// This class handles events from the system's media
// player. getContentIterator() returns an iterator
// that iterates over the songs configured to play.
class SubMusicContentDelegate extends Media.ContentDelegate {

	private var d_iterator;
	private var d_events = ["Start", "Skip Next", "Skip Previous", "Playback Notify", "Complete", "Stop", "Pause", "Resume"];

    function initialize() {
        ContentDelegate.initialize();
        
        resetContentIterator();
    }

    // Returns an iterator that is used by the system to play songs.
    // A custom iterator can be created that extends Media.ContentIterator
    // to return only songs chosen in the sync configuration mode.
    function getContentIterator() {
        return d_iterator;
    }

    // Respond to a user ad click
    function onAdAction(adContext) {
    	System.println("Ad Action: " + getSongName(adContext));
    }
    
    function onCustomButton(button) {
    	System.println("Custom Button clicked: " + button);
    }

    // Respond to a thumbs-up action
    function onThumbsUp(contentRefId) {
    	System.println("Thumbs Up: " + getSongName(contentRefId));
    }

    // Respond to a thumbs-down action
    function onThumbsDown(contentRefId) {
    	System.println("Thumbs Down: " + getSongName(contentRefId));
    }

    // Respond to a command to turn shuffle on or off
    function onShuffle() {
    	d_iterator.toggleShuffle();
    }
    
    function onRepeat() {
    	System.println("Repeat Mode change");
    }
    
    function resetContentIterator() {
    	d_iterator = new SubMusicContentIterator();
    	return d_iterator;
    }
    
    function onMore() {
    	System.println("onMore is called");
    }
    function onLibrary() {
    	System.println("onLibrary is called");
    }

    // Handles a notification from the system that an event has
    // been triggered for the given song
    function onSong(contentRefId, songEvent, playbackPosition) {
    	System.println("onSong Event (" + d_events[songEvent] + "): " + getSongName(contentRefId) + " at position " + playbackPosition);
    }
    
    function getSongName(refId) {
    	return Media.getCachedContentObj(new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO)).getMetadata().title;
    }
}
