using Toybox.WatchUi;
using Toybox.Application;

module SubMusic {
    module Menu {

        class PodcastsLocal extends MenuBase {

            // menu items will be loaded in here 
            hidden var d_items = [];

            function initialize(title) {
                // initialize base as loaded
                MenuBase.initialize(title, true);

                // load the items
                load();
            }

            // reload the ids on request
			function load() {
                var podcasts = [];
                var ids = PodcastStore.getIds();

                // remove the non local podcast ids
                var todelete = [];
                for (var idx = 0; idx != ids.size(); ++idx) {
                    var id = ids[idx];
                    var ipodcast = new IPodcast(id);
                    if (ipodcast.local()) {
                        podcasts.add(ipodcast);
                    }
                }

                // create the menu items
                for (var idx = 0; idx != podcasts.size(); ++idx) {
                    d_items.add(new Menu.PodcastSettings(podcasts[idx]));
                }
			}
        }
    }
}