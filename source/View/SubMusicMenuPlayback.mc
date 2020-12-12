using Toybox.WatchUi;

using SubMusic.Menu;

module SubMusic {
	module Menu {
		class Playback {
			var title = Rez.Strings.confPlayback_Title;
			enum {
				SELECT_PLAYLIST,
				OPEN_SYNC,
				DONATE,
			}			
			var items = {
				SELECT_PLAYLIST => { 
					LABEL => Rez.Strings.confPlayback_SelectPlaylist_label, 
					SUBLABEL => null, 
					METHOD => method(:onSelectPlaylist),
				},
				OPEN_SYNC => {
					LABEL => Rez.Strings.confPlayback_OpenSync_label, 
					SUBLABEL => null, 
					METHOD => method(:onOpenSync),
				},
				DONATE => {
					LABEL => Rez.Strings.Donate_label, 
					SUBLABEL => null, 
					METHOD => method(:onDonate),
				},
			};
			
			function onSelectPlaylist() {
				WatchUi.pushView(new SubMusicConfigurePlaybackPlaylistView(), null, WatchUi.SLIDE_IMMEDIATE);
			}
			
			function onOpenSync() {
				// pass false to indicate we are coming from another sync flow than normal
				WatchUi.pushView(new SubMusic.Menu.SyncView(false), new SubMusic.Menu.Delegate(), WatchUi.SLIDE_IMMEDIATE);
			}
			
			function onDonate() {
				WatchUi.pushView(new DonateView(), new DonateDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
		}
		
		class PlaybackView extends MenuView {
			function initialize() {
				MenuView.initialize(new Playback());
			}
		}
	}
}