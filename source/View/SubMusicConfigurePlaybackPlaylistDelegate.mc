using Toybox.WatchUi;
using Toybox.Media;

class SubMusicConfigurePlaybackPlaylistDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
        
    }
    
    function onSelect(item) {   	
    	
    	// store selection as current playlist
    	Application.Storage.setValue(Storage.PLAYLIST, item.getId());
    	Media.startPlayback(null);
    }
    
    function onBack() {
    	WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
