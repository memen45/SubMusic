 class DonateDelegate extends TapDelegate {
 	
 	function initialize() {
 		TapDelegate.initialize(method(:openLink));
 		openLink();
 	}
 	
	function openLink() {
		var url = "https://www.paypal.com/donate";
		var params = { "hosted_button_id" => "HBUU64LT3QWA4", };
		Communications.openWebPage(url, params, null);
	}
 }