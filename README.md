# SubMusic
SubMusic is a music provider app for the Garmin Connect IQ store and synchronizes playlists from your server using the SubSonic API.

Set up Synced Playlists    |  Choose from synced playlists | Enjoy your music 
:-------------------------:|:-------------------------:|:-------------------------:
![](images/ConfigureSyncView.png)  |  ![](images/ChoosePlaybackView.png) | ![](images/PlaybackView.png)

## == Nextcloud ==

Install, enable and open the owncloud/music app. In Settings copy the URL for the SubSonic endpoint and paste it into the connect iq app settings. The URL should look like the following: "https://example.nextcloud.com/apps/music/subsonic", no trailing slash. Now enter a Description (e.g. "Garmin SubMusic") and Generate API password to enable a new access for the SubSonic API endpoint. Enter your username and the generated password in the connect iq app settings.

![](images/NextcloudView.png)

## == Ampache ==

Enable the SubSonic backend in System settings in the web UI.

## == Support ==

If you use the "Contact Developer" option, make sure to attach your email address to the message so I can reply. You can also go to https://github.com/memen45/SubMusic on GitHub and open an issue.
