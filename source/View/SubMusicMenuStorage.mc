using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Application;
using Toybox.Lang;
using SubMusic.Menu;

module SubMusic {
	module Menu {
		class Storage extends MenuBase {

			function initialize() {
				MenuBase.initialize(WatchUi.loadResource(Rez.Strings.Storage_label), false);
			}

			function load() {
				System.println("Menu.Storage::load()");
				return MenuBase.load([
					{
						LABEL => WatchUi.loadResource(Rez.Strings.Memory_label), 
						SUBLABEL => method(:sublabel_Memory), 
						METHOD => "cache",		// not used, null does not work
					},
					{
						LABEL => WatchUi.loadResource(Rez.Strings.Cache_label), 
						SUBLABEL => method(:sublabel_Cache), 
						METHOD => "cache",		// not used, null does not work
					},
					{
						LABEL => WatchUi.loadResource(Rez.Strings.confSync_MoreInfo_RemoveAll_label), 
						SUBLABEL => WatchUi.loadResource(Rez.Strings.confSync_MoreInfo_RemoveAll_sublabel),
						METHOD => method(:onRemoveAll),
					}
				]);
			}

			static function sublabel_Memory() as Lang.String {
				var stats = System.getSystemStats();
				return formatBytes(stats.usedMemory) + " / " + formatBytes(stats.totalMemory);
			}

			static function sublabel_Cache() as Lang.String {
				var stats = Media.getCacheStatistics();
				return formatBytes(stats.size) + " / " + formatBytes(stats.capacity);
			}

			static function onDonate() {
				WatchUi.pushView(new DonateView(), new DonateDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
			
			static function onRemoveAll() {
				var msg = "Are you sure you want to delete all Application data?";
				WatchUi.pushView(new WatchUi.Confirmation(msg), new SubMusicConfirmationDelegate(self.method(:removeAll)), WatchUi.SLIDE_IMMEDIATE);
			}
			
			static function removeAll() {
				System.println("Settings::removeAll()");
				// collect all ids of songs
				// var ids = SongStore.getIds();
				// for (var idx = 0; idx != ids.size(); ++idx) {
				// 	var id = ids[idx];
				// 	var isong = new ISong(id);
				// 	isong.remove();					// remove from Store
				// }
				// ids = EpisodeStore.getIds();
				// for (var idx = 0; idx != ids.size(); ++idx) {
				// 	var id = ids[idx];
				// 	var iepisode = new IEpisode(id);
				// 	iepisode.remove();					// remove from Store
				// }
				// ids = ArtworkStore.getIds();
				// for (var idx = 0; idx < ids.size(); ++idx) {
				// 	var id = ids[idx];
				// 	var iartwork = new IArtwork(id);
				// 	iartwork.remove();				// remove from Storage
				// }

				// remove all cached media
				Media.resetContentCache();
				
				// remove all metadata
				Application.Storage.clearValues();
				
				// check storage to set the storage version number
				SubMusic.Storage.check();

				// exit app to make sure ram is cleared
				System.exit();
			}

			static function formatBytes(bytes as Lang.Integer) as Lang.String {
				var k = 1024;
				var sizes = ["Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
				var in = Math.floor(Math.log(bytes, 10) / Math.log(k, 10));
				var flt = (bytes / Math.pow(k, in));
				return flt.format("%.1f") +  sizes[in.toNumber()];
			}
		}
	}
}