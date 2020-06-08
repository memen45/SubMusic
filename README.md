# SubMusic
SubMusic is a music provider app for the Garmin Connect IQ store and synchronizes playlists from your server using the SubSonic API.

Set up Synced Playlists    |  Choose from synced playlists | Enjoy your music 
:-------------------------:|:-------------------------:|:-------------------------:
![](images/ConfigureSyncVIew.png) | ![](images/ChoosePlaybackView.png) | ![](images/PlaybackView.png)

## == Nextcloud ==

Install, enable and open the owncloud/music app. In Settings copy the URL for the SubSonic endpoint and paste it into the connect iq app settings. The URL should look like the following: "https://example.nextcloud.com/apps/music/subsonic", no trailing slash. Now enter a Description (e.g. "Garmin SubMusic") and Generate API password to enable a new access for the SubSonic API endpoint. Enter your username and the generated password in the connect iq app settings.

![](images/NextcloudView.png)

## == Ampache ==

Enable the SubSonic backend in System settings in the web UI.

## == Subsonic ==

Follow the Getting Started directions at http://www.subsonic.org/pages/getting-started.jsp for remote access and using https. If you do not want to pay for this premium feature, you can set up a DNS yourself at https://freedns.afraid.org/:
1. Create an account, create a subdomain off of one of the many free domains and point it to your server's internet ip address. 
2. Set up Port Forwarding on your router from external port 443 (and optionally port 80) to the local server ip address with port 4040. 
3. Set up Let's Encrypt on the subdomain you chose. This process depends on the OS of your Subsonic server.
Find online tutorials for each of the above points, the specific steps differ depending on used hardware and software. Hopefully this provides some direction.

## == Support ==

If you use the "Contact Developer" option, please make sure to attach your email address to the message so I can reply. You can also go to https://github.com/memen45/SubMusic on GitHub and open an issue.
