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
    	
    	var playlist = Application.Storage.getValue(Storage.PLAYLIST_LOCAL);
    	if (playlist == null || playlist.keys().size() == 0)
    	{
    		d_msg = "No local playlists";
    		return;
    	}
    	
    	WatchUi.pushView(new SubMusicConfigurePlaybackMenu(), new SubMusicConfigurePlaybackDelegate(), WatchUi.SLIDE_IMMEDIATE);
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
