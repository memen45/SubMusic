using Toybox.WatchUi;
using Toybox.Application;

module SubMusic {
    module Menu {

        class PodcastsLocal extends MenuBase {

            function initialize(title) {
                MenuBase.initialize(title, false);
            }

            // reload the ids on request
			function load() {
                if ($.debug) {
                	System.println("Menu.PodcastsLocal::load()");
                }

                var ipodcasts = [];
                var ids = PodcastStore.getIds();

                // remove the non local podcast ids
                var todelete = [];
                for (var idx = 0; idx != ids.size(); ++idx) {
                    var id = ids[idx];
                    var ipodcast = new IPodcast(id);
                    if (ipodcast.local()) {
                        ipodcasts.add(ipodcast);
                    }
                }

                // create the menu items
                var items = [];
                for (var idx = 0; idx != ipodcasts.size(); ++idx) {
                    items.add(new Menu.PodcastSettings(ipodcasts[idx]));
                }
                return MenuBase.load(items);
			}
        }
    }
}