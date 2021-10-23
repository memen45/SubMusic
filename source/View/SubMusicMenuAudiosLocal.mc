using Toybox.WatchUi;

module SubMusic {
    module Menu {

        class AudiosLocal extends MenuBase {

            private var d_ids;
            private var d_types;

            // performs the action on choice of song id
            private var d_handler = null;

            function initialize(title, ids, types, handler) {
                MenuBase.initialize(title, false);

                d_handler = handler;
                d_ids = ids;
                d_types = types;
            }

            function load() {
				System.println("Menu.AudiosLocal::load()");
                
                // only add local songs
                var audios = [];
                for (var idx = 0; idx != d_ids.size(); ++idx) {

                    var id = d_ids[idx];
                    var type = d_types[idx];
                    var audio = new Audio(id, type);

                    // if local, menu entry is added
                    if (audio.refId() != null) {
                        audios.add(audio);
                    }
                }

                // load the actual menu items 
                var items = [];
                for (var idx = 0; idx != audios.size(); ++idx) {
                    // load the menuitem
                    var audio = audios[idx];
                    var meta = audio.metadata();
                    items.add({
                        LABEL => meta.title,
                        SUBLABEL => meta.artist,
                        METHOD => audio.toStorage(),
                    });
                }
                // this can be reloaded
				return MenuBase.load(items);
            }

            function onSelect(item) {
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
                return new MenuDelegate(method(:onSelect), null);
            }
        }
    }
}