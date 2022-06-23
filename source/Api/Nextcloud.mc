// using Toybox.Lang;
// using Toybox.Communications;

// class Test {
//     function startOAuth() {

//         var url = "https://cloud.next.nl";
//         var requestUrl = url + "/apps/oauth/authorize";
//         var requestParams = {
//             "scope" => Communications.encodeURL(url),
//             "redirect_uri" => "http://localhost",
//            // "app_id" => "xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69",
//             // "app_secret" => "UBntmLjC2yYCeHwsyj73Uwo9TAaecAetRwMw0xYcvNL9yRdLSUi0hUAHfvCHFeFh",
//         };
//         var resultUrl = url + "/apps/oauth2/api/v1/token";
//         var resultType = Communications.OAUTH_RESULT_TYPE_URL;
//         var resultKeys = {
//             "ocs"   => "some_code",
//         };

//         Communications.registerForOAuthMessages(method(:onOAuthMessage));

//         Communications.makeOAuthRequest(requestUrl, requestParams, resultUrl, resultType, resultKeys);
//     }

//     function onOAuthMessage(message) {
//         System.println("Test::onOAuthMessage( message: " + message + " )" );
//         var ocs = message.data["some_code"];
//     }

// }