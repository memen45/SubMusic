using Toybox.WatchUi;
using Toybox.Media;

// Menu to choose what songs to playback
class SubMusicConfigurePlaybackMenu extends WatchUi.Menu2 {

	// Constructor
    function initialize() {
        Menu2.initialize({:title => Rez.Strings.playbackMenuTitle});

    	System.println("Constructing ConfigurePlaybackMenu");

        // For each playlist, add a menu item
        var local_playlists = Application.Storage.getValue(Storage.PLAYLIST_LOCAL);
		var keys = local_playlists.keys();
		for (var idx = 0; idx < keys.size(); ++idx) {
			var id = keys[idx];
			var label = local_playlists[id]["name"];
			var sublabel = (local_playlists[id]["time"] / 60).toNumber().toString() + " mins";
			addItem(new WatchUi.MenuItem(label, sublabel, id, null));
		}
    }
}
