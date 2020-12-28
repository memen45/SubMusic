using Toybox.WatchUi;

module SubMusic {
    module Menu {

        class SongsLocal {

            var title;

            private var d_ids;

            function initialize(title, ids) {
                self.title = title;
                d_ids = ids;
            }

            function getItem(idx) {

                // check if out of bounds
                if (idx >= d_ids.size()) {
                    return null;
                }

                // load the menuitem
                var id = d_ids[idx];
                var isong = new ISong(id);
                var meta = isong.metadata();
                return new WatchUi.MenuItem(
                    meta.title,             // label
                    meta.artist,            // sublabel
                    id,                     // id
                    null
                );
            }

            function loaded() {

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

                // always return true, as everything is loaded
                return true;
            }
        }

        class SongsLocalView extends MenuView {
            function initialize(title) {
                MenuView.initialize(new SongsLocal(title));
            }
        }

        class SongsLocalDelegate extends MenuDelegate {
            function initialize() {
                MenuDelegate.initialize(method(:onSongSelect), null);
                // ids are ids, so have to be handled, no onBack action
            }

            function onSongSelect(id) {
                System.println("SongsLocalDelegate::onSongSelect( id: " + id + ")");
            }
        }
    }
}