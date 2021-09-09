using Toybox.WatchUi;

module SubMusic {
    module Menu {

        class AudiosLocal extends MenuBase {

            private var d_audios = [];

            // performs the action on choice of song id
            private var d_handler = null;

            // the actual menu items
            hidden var d_items = [];

            function initialize(title, audios, handler) {
                MenuBase.initialize(title, true);

                d_handler = handler;

                // only add local songs
                for (var idx = 0; idx != audios.size(); ++idx) {

                    var id = audios[idx]["id"];
                    var type = audios[idx]["type"];
                    var audio = new Audio(id, type);

                    // if local, menu entry is added
                    if (audio.refId() != null) {
                        d_audios.add(audio);
                    }
                }

                // load the actual menu items 
                for (var idx = 0; idx != d_audios.size(); ++idx) {
                    // load the menuitem
                    var audio = d_audios[idx];
                    var meta = audio.metadata();
                    d_items.add({
                        LABEL => meta.title,
                        SUBLABEL => meta.artist,
                        METHOD => audio.toStorage(),
                    });
                }
            }

            function onAudioSelect(item) {
                var id = item.getId();
                // action onSongSelect should be defined by implementer classes
                if (d_handler) { d_handler.invoke(id); }
                // future: default start playable with only this song

                // store selection as current playlist/song
                // SubMusic.NowPlaying.setSongId(id); // deprecated

				// start the playback of this song
                // Media.startPlayback(null);    // nothing to start
            }

            function delegate() {
                return new MenuDelegate(method(:onAudioSelect), null);
            }
        }
    }
}