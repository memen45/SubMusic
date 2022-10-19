using Toybox.WatchUi;

module SubMusic {
    module Menu {

        class SongsLocal extends MenuBase {

            private var d_ids;

            // performs the action on choice of song id
            private var d_handler = null;

            function initialize(title, song_ids, handler) {
                MenuBase.initialize(title, false);

                d_ids = song_ids;
                d_handler = handler;

                // do not load the menu items
            }

            function load() {
                System.println("Menu.SongsLocal::load()");

                // remove the non local songs
                var todelete = [];
                for (var idx = 0; idx != d_ids.size(); ++idx) {
                    var id = d_ids[idx];
                    var isong = new ISong(id);

                    // if not local, no menu entry is added
                    if (isong.refId() == null) {
                        todelete.add(id);
                    }
                }
                for (var idx = 0; idx != todelete.size(); ++idx) {
                    d_ids.remove(todelete[idx]);
                }

                // load the actual menu items 
                var items = [];
                for (var idx = 0; idx != d_ids.size(); ++idx) {
                    // load the menuitem
                    var id = d_ids[idx];
                    var isong = new ISong(id);
                    var metadata = isong.metadata();

                    // add stored metadata if not given in file (Plex does not provide metadata in file)
                    var has_title = (metadata.title != null) && (metadata.title instanceof Lang.String) && (!metadata.title.equals(""));
                    var has_artist = (metadata.artist != null) && (metadata.artist instanceof Lang.String) && (!metadata.artist.equals(""));
                    if (!has_title) {
                        metadata.title = isong.title();
                    }
                    if (!has_artist) {
                        metadata.artist = isong.artist();
                    }

                    // add the item
                    items.add({
                        LABEL => metadata.title,
                        SUBLABEL => metadata.artist,
                        METHOD => id,
//                        OPTION => isong.artwork(),
                    });
                }
                return MenuBase.load(items);
            }

            function onSongSelect(item) {
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
                return new MenuDelegate(method(:onSongSelect), null);
            }
        }
    }
}