using Toybox.Media;
using Toybox.WatchUi;

// Delegate for playback menu
class SubMusicConfigurePlaybackMenuDelegate extends WatchUi.Menu2InputDelegate {

    // Constructor
    function initialize() {
        Menu2InputDelegate.initialize();
        
        System.println("Constructing PlaybackMenuDelegate");
    }

    // When an item is selected, add or remove it from the system playlist
    function onSelect(item) {
    
        System.println("onSelect PlaybackMenuDelegate");
        var playlist = Application.Storage.getValue(Storage.PLAYLIST);

        if (playlist == null) {
            playlist = [];
        }

        if (item.isChecked()) {
            playlist.add(item.getId());
        } else {
            playlist.remove(item.getId());
        }

        Application.Storage.setValue(Storage.PLAYLIST, playlist);
    }

    // Pop the view when done
    function onDone() {
        Media.startPlayback(null);
    }

    // Pop the view when back is pushed
    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}