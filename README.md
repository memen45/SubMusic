# SubMusic
Synchronize playlists from your own music server: Nextcloud - Subsonic - Ampache - Airsonic.

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

Should be supported now. Just choose Subsonic API in the Connect IQ app settings and fill in the url, username and your password accordingly.

## Known issues 
Below a list of known 'issues'. These are problems that cannot be fixed by design of either the watch software or the API backends chosen.

**SubSonic API** - synchronization of large playlists (above ~25 depending on metadata) is not supported, due to how the Subsonic API is designed and how the watch works. Remove some songs from the playlist if you receive the -402 error during sync.

**Nextcloud** - does not support transcoding, so supported file types are MP3, MP4, ADTS and WAV files. Please report issues related to the file types!

**General** - self-signed certificates are not supported by the watch (Sync Error: 0). Either use http or proper https certificates.

## == Support ==

If you use the "Contact Developer" option, please make sure to attach your email address to the message so I can reply. You can also go to https://github.com/memen45/SubMusic on GitHub and open an issue.
