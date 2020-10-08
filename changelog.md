Version [0.0.16] - 2020-10-08
- added support for d2 delta series and Venu Mercedes-Benz Collection
- fixed null handling (Nextcloud + SMB storage bug)
- fixed incorrect progressbar
- upgrade to storage, requires resync (no reinstall needed)
- improved speed of playback selection
- fixes syncing playlist metadata in background
- fixed managing playlists that are no longer online ('local only')
- fixed marking of incompletely synced playlist ('needs sync')
- added support for adts, wav, mp4 file types (defaults to mp3)

Version [0.0.15] - 2020-08-17
- fixes crash on changing settings
- fixes crash on initialize playlist before sync
- fixes crash on sync with null local songs

Version [0.0.14] - 2020-07-16
- fixes reset session on settings changed (AmpacheAPI)
- fixes potential bug from outdated storage
- fixes error reporting in "Server Info" tab
- fixes sync - 'fake sync' bug
- fixes crash on receiving error (AmpacheAPI)

Version 0.0.13
- added "Server Info" option to the menu to test connection

Version 0.0.12
- minor bug fixes
- improved support for the Ampache API (awaiting nextcloud/music update)

Version 0.0.11
- fixes playback configuration

Version 0.0.10
- rewrite of the sync engine
- alpha support for the Ampache API (limited to 20 songs per playlist)

Version 0.0.9
- added support for removing playlists before sync occured
- added handling of unsupported file types (songs will be skipped)
- improved syncing

Version 0.0.8
- fixes content-type issue on airsonic servers
- minor ui changes

Version 0.0.7
- fixes error reporting
- fixes response verifications

Version 0.0.6
- fixes multiple deletion of same playlist error

Version 0.0.5
- fixes broken sync

Version 0.0.4
- fixes strict responses from Airsonic (possibly also from other Subsonic servers)
- fixes response "ok" verification (less "Media Error Occured" and improves error reporting)
- fixed supported Subsonic API version: 1.10.2

Version 0.0.3
- fixes "Media Error Occured" on initial sync

Version 0.0.2
- fixes duplicate deletion of cached songs
- fixes deletion of playlists

Version 0.0.1
- show available playlists in Configure Sync menu
- only delete songs when not present in any playlist
- incremental change supported (only download new songs)