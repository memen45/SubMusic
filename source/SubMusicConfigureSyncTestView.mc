using Toybox.WatchUi;
using Toybox.Media;

class SubMusicConfigureSyncTestView extends WatchUi.ProgressBar {

	private var d_provider;
	private var d_progress;
	private var d_step = (100 / 2).toNumber();

	function initialize(provider) {
		ProgressBar.initialize(WatchUi.loadResource(Rez.Strings.confSync_Test_start), null);
		
		d_provider = provider;
		d_provider.setFallback(method(:onFail));
		
		d_progress = 0;
		setProgress(d_progress);
		
		// start with getallplaylists
		d_provider.getAllPlaylists(method(:onGetAllPlaylists));
	}
	
	function onGetAllPlaylists(response) {
		// if we are here, everything went well probably
		d_progress += d_step;
		setProgress(d_progress);
		
		// return if no playlists returned
		if (response.size() == 0) {
			// cannot complete test, since no playlists are present
			setDisplayString("Inlog OK, but no playlists");
			return;
		}
		
		// select a playlist that has a song
		var playlist = null;
		for (var idx = 0; idx < response.size(); ++idx) {
			if (response[idx]["songCount"] != 0) {
				playlist = response[idx];
				break;
			}
		}
		
		// return if no song found
		if (playlist == null) {
			// cannot complete test, since no playlists are present
			setDisplayString("Inlog OK, but no songs on playlist");
			return;
		}
		
		setDisplayString("Inlog OK");
		d_provider.getPlaylistSongs(playlist["id"], method(:onGetPlaylistSongs));
	}
	
	function onGetPlaylistSongs(response) {
		d_progress += d_step;
		setProgress(d_progress.toNumber());
		
		// return if no songs returned
		if (response.size() == 0) {
			setDisplayString("Inlog OK, but no songs found");
			return;
		}
		setDisplayString("Test Succeeded");
	}
	
	function onFail(responseCode, data) {
		System.println("Test Failed");
		
		setDisplayString("Test failed: " + responseCode + "\ndata:" + data);
		
		WatchUi.pushView(new ErrorView("Test Failed", responseCode + "\n" + data), null, WatchUi.SLIDE_IMMEDIATE);
	}
	
	function onError(error, message, dump) {
		// future error reporting: ask for webpage opener and pass full error message into it (url encoded)
		// https://jsonformatter.curiousconcept.com/?data={test}
	}
		
}