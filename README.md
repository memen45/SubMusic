# SubMusic
Synchronize playlists from your server using the SubSonic API (Nextcloud - Subsonic - Ampache - Airsonic)

Note there is a limitation for synchronizing larger playlists (above ~25 depending on metadata), due to how Subsonic and the watch work. Remove some songs from the playlist if you receive the -402 error during sync.

Set up Synced Playlists    |  Choose from synced playlists | Enjoy your music 
:-------------------------:|:-------------------------:|:-------------------------:
![](images/ConfigureSyncVIew.png) | ![](images/ChoosePlaybackView.png) | ![](images/PlaybackView.png)

## == Nextcloud ==

Install, enable and open the owncloud/music app. In Settings copy the URL for the SubSonic endpoint and paste it into the connect iq app settings. The URL should look like the following: "https://example.nextcloud.com/apps/music/subsonic", no trailing slash. Now enter a Description (e.g. "Garmin SubMusic") and Generate API password to enable a new access for the SubSonic API endpoint. Enter your username and the generated password in the connect iq app settings.

Only mp3 is supported, since the music app does not transcode music.

![](images/NextcloudView.png)

## == Ampache ==

Enable the SubSonic backend in System settings in the web UI.

## == Subsonic ==

Should be supported now. Please report any issues!

## == Support ==

If you use the "Contact Developer" option, please make sure to attach your email address to the message so I can reply. You can also go to https://github.com/memen45/SubMusic on GitHub and open an issue.
