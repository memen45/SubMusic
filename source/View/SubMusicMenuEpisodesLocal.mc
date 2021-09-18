using Toybox.WatchUi;

module SubMusic {
    module Menu {

        class EpisodesLocal extends MenuBase {

            private var d_ids;

            // performs the action on choice of episode id
            private var d_handler = null;

            function initialize(title, episode_ids, handler) {
                MenuBase.initialize(title, false);

                d_ids = episode_ids;
                d_handler = handler;
            }

            function load() {

                // remove the non local episodes
                var todelete = [];
                for (var idx = 0; idx != d_ids.size(); ++idx) {
                    var id = d_ids[idx];
                    var iepisode = new IEpisode(id);

                    // if not local, no menu entry is added
                    if (iepisode.refId() == null) {
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
                    var iepisode = new IEpisode(id);
                    var meta = iepisode.metadata();
                    items.add({
                        LABEL => meta.title,
                        SUBLABEL => meta.artist,
                        METHOD => id,
                    });
                }
				return MenuBase.load(items);
            }

            function onEpisodeSelect(item) {
                var id = item.getId();
                // action onEpisodeSelect should be defined by implementer classes
                if (d_handler) { d_handler.invoke(id); }
                // future: default start playable with only this episode

                // store selection as current playlist/episode
                // SubMusic.NowPlaying.setEpisodeId(id); // deprecated

				// start the playback of this episode
                // Media.startPlayback(null);    // nothing to start
            }

            function delegate() {
                return new MenuDelegate(method(:onEpisodeSelect), null);
            }
        }
    }
}