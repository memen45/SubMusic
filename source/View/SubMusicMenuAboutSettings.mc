using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Application;
using Toybox.Media;

module SubMusic {
	module Menu {
		class AboutSettings extends MenuBase {

			hidden var d_items = [
				{
					LABEL => WatchUi.loadResource(Rez.Strings.confSync_MoreInfo_RemoveAll_label), 
					SUBLABEL => WatchUi.loadResource(Rez.Strings.confSync_MoreInfo_RemoveAll_sublabel),
					METHOD => method(:onRemoveAll),
				},
				{
					LABEL => WatchUi.loadResource(Rez.Strings.Donate_label), 
					SUBLABEL => null, 
					METHOD => method(:onDonate),
				},
			];

			function initialize() {
				MenuBase.initialize(WatchUi.loadResource(Rez.Strings.Settings_label), true);
			}
			
			function onDonate() {
				WatchUi.pushView(new DonateView(), new DonateDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
			
			function onRemoveAll() {
				var msg = "Are you sure you want to delete all Application data?";
				WatchUi.pushView(new WatchUi.Confirmation(msg), new SubMusicConfirmationDelegate(self.method(:removeAll)), WatchUi.SLIDE_IMMEDIATE);
			}
			
			function removeAll() {
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
				Storage.check();

				// exit app to make sure ram is cleared
				System.exit();
			}
		}
	}
}