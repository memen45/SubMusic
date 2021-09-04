using Toybox.WatchUi;
using SubMusic;

module SubMusic {
    module Menu {
        class PlaylistSettingsRemote extends MenuBase {

            private var d_id;
            private var d_playlist;
            
            enum {
                OFFLINE,
                SONGS,
            }
            hidden var d_items = {
                OFFLINE => {
                    LABEL => "Make available offline",
                    SUBLABEL => null,
                    METHOD => OFFLINE,
                },
                SONGS => {},
            };

            function initialize(playlist) {
                d_playlist = playlist;
                d_id = playlist.id();

                // this class could become lazy loaded as well, e.g. for loading playlist details
                MenuBase.initialize(d_playlist.name(), true);

                d_items[SONGS] = new Menu.SongsRemote(
                    WatchUi.loadResource(Rez.Strings.Songs_label),
                    d_id
                );
            }

            function getItem(idx) {

                // defer to base
                if (idx != OFFLINE) {
                    return MenuBase.getItem(idx);
                }
                
                // make toggle item for offline mode
                var item = d_items[idx];
                var iplaylist = new IPlaylist(d_id);
                return new WatchUi.ToggleMenuItem(
                    item.get(LABEL),
                    item.get(SUBLABEL),
                    item.get(METHOD),
                    iplaylist.local(),
                    {}
                );
            }

            function sublabel() {
                var iplaylist = new IPlaylist(d_id);
                if (iplaylist.local() && iplaylist.synced()) {
                    return "Local - synced";
                }
                if (iplaylist.local()) {
                    return "Local - needs sync";
                }

                // not synced or local? use remote playlist object
                return d_playlist.count().toString() + " songs";
            }

            function onOfflineToggle(item) {
                var iplaylist = new IPlaylist(d_id);
                iplaylist.setLocal(item.isEnabled());
                if (item.isEnabled()) { iplaylist.updateMeta(d_playlist); }
            }

            function delegate() {
                return new MenuDelegate(method(:onOfflineToggle), null);
            }
        }
    }
}