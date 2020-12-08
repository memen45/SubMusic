using Toybox.Graphics;
using Toybox.WatchUi;

// View to display an error message

// future error reporting: ask for webpage opener and pass full error message into it (url encoded)
// https://jsonformatter.curiousconcept.com/?data={test}
class ErrorView extends TextView {

    // The error message
    private var d_title;
    private var d_detail;
    
    hidden var d_textarea;

    // Constructor
    function initialize(error) {
		d_title = error.shortString();
		d_detail = error.toString();
		
        TextView.initialize(d_title + "\n" + d_detail);
    }
}