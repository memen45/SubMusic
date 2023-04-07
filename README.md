# SubMusic
Synchronize playlists from your own music server: Nextcloud - Subsonic - Ampache - Airsonic - Plex

[<img src="https://developer.garmin.com/static/available-badge-9e49ebfb7336ce47f8df66dfe45d28ae.svg" width="200">](https://apps.garmin.com/en-US/apps/600bd75f-6ccf-4ca5-bc7a-0a4fcfdcf794)

## Features:
- Browse your online playlists and podcasts
- Make playlists available offline
- Make latest podcast episode available offline
- Browse and play your songs offline by playlist, shuffle, play all at once
- Enable podcast mode if you have podcast episodes in a playlist
- Listening count is uploaded to your server next time you sync
- Enjoy Album art (if available on server, not supported on all devices)

## How to use

Set up Synced Playlists    |  Choose from synced playlists | Enjoy your music 
:-------------------------:|:-------------------------:|:-------------------------:
![](images/ConfigureSyncVIew.png) | ![](images/ChoosePlaybackView.png) | ![](images/PlaybackView.png)

## How to set up
You need a music server supporting either the Ampache API or the Subsonic API and a compatible Garmin Watch. Check the [Garmin App store](https://apps.garmin.com/en-US/apps/600bd75f-6ccf-4ca5-bc7a-0a4fcfdcf794).

### == Nextcloud ==

In the connect iq app settings, choose 'Ampache API' for the 'API backend' option. Install, enable and open the [owncloud/music](https://apps.nextcloud.com/apps/music) app (v0.15.1 or higher). In Settings copy the URL for the Ampache endpoint and paste it into the connect iq app settings. The URL should look like the following: "https://example.nextcloud.com/apps/music/ampache", no trailing slash. Now enter a Description (e.g. "Garmin SubMusic") and Generate API password to enable a new access for the Ampache API endpoint. Enter your username and the generated password in the connect iq app settings.

The music app does not transcode music, so supported file types are MP3, MP4, ADTS and WAV files. Only MP3 has been tested, support for the other formats is in beta. Please report issues!

![](images/NextcloudView.png)

### == Ampache ==

Requires Ampache version 4.2.0 or higher. For older versions you can enable the SubSonic backend in System settings in the Ampache web UI and select Subsonic API in the connect iq app settings. Choose Ampache API in the Connect IQ app settings and fill in the url, username and password accordingly.

### == Subsonic/Airsonic ==

Supported. Just choose Subsonic API in the Connect IQ app settings and fill in the url, username and your password accordingly.

### == Plex ==

Should be supported now including transcoding. Make sure you enable remote access inside Plex, then login through `plex.tv` and follow [these instructions](https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/) to obtain the server address and the API key. The Server Address should look like `https://ip-adress.somehashvalue.plex.direct:32400/`, where `ip-address` and `somehashvalue` are unique for your situation. Now head to Connect IQ app store, choose Plex API in the SubMusic app settings and fill in the Server Address and API key you found. Enjoy your music!

## Known issues 
Below a list of known 'issues'. These are problems that cannot be fixed by design of either the watch software or the API backends chosen.

**General** - 'Error -300' or 'Error 0': first check the server address for typos. If using HTTP, enable HTTPS on your server. 
- Do you use self-signed certificates? Install certificates signed by a certificate authority (CA) e.g. Let's Encrypt. Do you limit the TLS cipher suites to only the latest? Try enabling some older ones, see [this issue](https://github.com/memen45/SubMusic/issues/42#issuecomment-1073341881). 
- Are you using default custom ports such as `<address>:4040` or `<address>:32400`? This is not supported, so use ports 80 and 443 only!

**SubSonic API** - no more than ~25 songs on a playlist, due to Subsonic API and watch limitations. Do you get 'Error -402' during sync? Remove some songs from the playlist.

**Nextcloud** - does not support transcoding, so supported file types are MP3, MP4, ADTS and WAV files. Other file types will be skipped (shows a 'need sync' in playlist overview).

## == Support ==

If you use the "Contact Developer" option, please make sure to attach your email address to the message so I can reply. You can also go to https://github.com/memen45/SubMusic on GitHub and open an issue.
