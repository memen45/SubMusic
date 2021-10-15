using Toybox.WatchUi;
using SubMusic.Menu;
using SubMusic;

module SubMusic {
	module Menu {
		class NowPlaying extends AudiosLocal {

			function initialize() {
				var iplayable = new SubMusic.IPlayable();
				AudiosLocal.initialize(
					WatchUi.loadResource(Rez.Strings.confPlayback_NowPlaying_title), 
					iplayable.ids(),
					iplayable.types(),
					method(:onAudioSelect)
				);
			}

			function onAudioSelect(audio) {
				// start playback with new songid
				var iplayable = new SubMusic.IPlayable();
				iplayable.setAudio(audio);
				Media.startPlayback(null);
			}
		}
	}
}