using Toybox.WatchUi;

class SubMusicPlaylistView extends WatchUi.View {

	private var d_playlist;
	
	private var d_textarea;
	
	function initialize(playlist) {
		View.initialize();
		
		d_playlist = playlist;
	}

    function onLayout(dc) {
    	System.println("text area is " + dc.getWidth() + " x " + dc.getHeight());
    	d_textarea = new WatchUi.TextArea({
    		:text => d_playlist.name() + "\n" + d_playlist.count() + " songs",
    		:color => Graphics.COLOR_WHITE,
    		:font => [ Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_XTINY ],
    		:justification => Graphics.TEXT_JUSTIFY_CENTER,
    		:locX => WatchUi.LAYOUT_HALIGN_CENTER,
    		:locY => WatchUi.LAYOUT_VALIGN_CENTER,
            :width=> dc.getWidth() * 2 / 3,
            :height=> dc.getHeight() * 2 / 3,
    	});
    }
    	

    // Update the View
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        d_textarea.draw(dc);
    }
	
}
		