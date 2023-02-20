using Toybox.WatchUi;
using SubMusic;

module SubMusic {
    module Menu {
        class PlaylistSettingsRemote extends MenuBase {

            private var d_id;
            private var d_playlist;

            function initialize(playlist) {
                MenuBase.initialize(playlist.name(), false);

                d_playlist = playlist;
                d_id = playlist.id();
            }

            function load() {
				if ($.debug) {
					System.println("Menu.PlaylistSettingsRemote::load()");
				}

                return MenuBase.load([
                    {
                        LABEL => "Make available offline",
                        SUBLABEL => null,
                        METHOD => "offline",
                        OPTION => method(:isOffline),
                    },
                    new Menu.SongsRemote(
                        WatchUi.loadResource(Rez.Strings.Songs_label),
                        d_id
                    ),
                ]);
            }

            function isOffline() {
                var iplaylist = new IPlaylist(d_id);
                return iplaylist.local();
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