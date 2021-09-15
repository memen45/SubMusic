using Toybox.WatchUi;

class SubMusicTestView extends WatchUi.ProgressBar {

    // api access
    private var d_provider = SubMusic.Provider.get();

	private var d_progress;
	private var d_step = (100 / 4).toNumber();

	function initialize() {
		ProgressBar.initialize(WatchUi.loadResource(Rez.Strings.confSync_Test_start), null);
		
		d_provider.setFallback(method(:onError));
		
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
			if (response[idx].count() != 0) {
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
		d_provider.getPlaylistSongs(playlist.id(), method(:onGetPlaylistSongs));
	}
	
	function onGetPlaylistSongs(response) {
		d_progress += d_step;
		setProgress(d_progress.toNumber());
		
		// return if no songs returned
		if (response.size() == 0) {
			setDisplayString("Inlog OK\nNo songs found");
			return;
		}
		setDisplayString("Inlog OK\nPlaylists good");
		d_provider.getAllPodcasts(method(:onGetAllPodcasts));
	}
	
	function onGetAllPodcasts(response) {
		// if we are here, everything went well probably
		d_progress += d_step;
		setProgress(d_progress);
		
		// return if no podcasts returned
		if (response.size() == 0) {
			// cannot complete test, since no playlists are present
			setDisplayString("Inlog OK\nNo podcasts");
			return;
		}
		
		// select first podcast (cannot check episode count)
		var podcast = response[0];
		
		setDisplayString("Inlog OK");
		d_provider.getEpisodes(podcast.id(), [0, 1], method(:onGetEpisodes));
	}
	
	function onGetEpisodes(response) {
		d_progress += d_step;
		setProgress(d_progress.toNumber());
		
		// return if no songs returned
		if (response.size() == 0) {
			setDisplayString("Inlog OK\nNo episode found");
			return;
		}
		setDisplayString("Test Succeeded");
	}
	
	function onError(error) {
		System.println("Test Failed");
		
		setDisplayString("Test failed:\n" + error.shortString() + "\n" + error.toString());
		
		WatchUi.pushView(new ErrorView(error), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
	}
		
}