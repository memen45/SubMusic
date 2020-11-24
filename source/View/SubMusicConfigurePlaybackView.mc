using Toybox.WatchUi;

class SubMusicConfigurePlaybackView extends WatchUi.View {

	private var d_menushown = false;
	private var d_msg = "";

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        // setLayout(Rez.Layouts.ConfigurePlaybackLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    
    	System.println("onShow Configure Playback View");
    	if (d_menushown)
    	{
    		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    		return;
    	}
    	
    	d_menushown = true;
    	
        var playlists = PlaylistStore.getIds();

        // try and build a menu of all local songs
        var empty = true;
        var menu = new WatchUi.Menu2({:title => Rez.Strings.playbackMenuTitle});
        for (var idx = 0; idx < playlists.size(); ++idx) {
			var id = playlists[idx];
			var iplaylist = new IPlaylist(id);

			// if not local, no menu entry is added
			if (!iplaylist.local()) {
				continue;
			}
			
            // mark as not empty
            empty = false; 

            // create the menu item
			var label = iplaylist.name();
			var mins = (iplaylist.time() / 60).toNumber().toString();
			var sublabel = mins + " mins";
			if (!iplaylist.synced()) {
				sublabel += " - needs sync";
			}
			menu.addItem(new WatchUi.MenuItem(label, sublabel, id, null));
		}
        if (empty)
    	{
    		d_msg = "No local playlists";
    		return;
    	}
    	
    	WatchUi.pushView(menu, new SubMusicConfigurePlaybackDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        //View.onUpdate(dc);
        
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM, d_msg, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER );
   
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    	System.println("onHide Configure Playback View");
    }

}
