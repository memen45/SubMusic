using Toybox.Graphics;
using Toybox.WatchUi;

// View to display an error message

// future error reporting: ask for webpage opener and pass full error message into it (url encoded)
// https://jsonformatter.curiousconcept.com/?data={test}
class ErrorView extends WatchUi.View {

    // The error message
    private var d_title;
    private var d_detail;
    
    hidden var d_textarea;

    // Constructor
    function initialize(error) {
        View.initialize();

		d_title = error.shortString();
		d_detail = error.toString();
    }
    
    function onShow() {
    	d_textarea = new WatchUi.TextArea({
    		:text => d_title + "\n" + d_detail,
    		:color => Graphics.COLOR_WHITE,
    		:font => [ Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_XTINY ],
    		:justification => Graphics.TEXT_JUSTIFY_CENTER,
    		:locX => WatchUi.LAYOUT_HALIGN_CENTER,
    		:locY => WatchUi.LAYOUT_VALIGN_CENTER,
            :width=>160,
            :height=>160,
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