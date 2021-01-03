Version [] - 
- (tentative) added 'Manage...' option for more playlist options
- (tentative) added alpha podcast implementation (feedback needed)

Version [0.1.2] - 2021-01-03
- fixes 'choose playlist'
- added start play by song (Playlists -> playlist1 -> Songs)

Version [0.1.1] - 2020-12-30
- fixed broken error report views
- bug fixes and improvements

Version [0.1.0] - 2020-12-28
- added Now Playing option to play per song
- fixes Subsonic scrobble 
- added granular progress during sync 

Version [0.0.24] - 2020-12-18
- fixed sync issues (delete after sync)
- added interrupting syncs on errors that cannot be skipped/handled

Version [0.0.23] - 2020-12-15
- added support for updating play count to server (feedback required)
- added warning for possibly hanging sync
- update last sync in menu
- refactor in menus
- fixes potential ampache crash 

Version [0.0.22] - 2020-12-09
- added 'More...' to playback configuration to open sync menu
- fixed hanging sync (feedback required)
- fixed error on error string creation

Version [0.0.21] - 2020-12-08
- added ping to check server version
- fixed duplicate check AmpacheError
- fixed crash on display HttpError
- fixed potential cause of onStream exception (Subsonic)
- added donate link to menu: https://www.paypal.com/donate?hosted_button_id=HBUU64LT3QWA4

Version [0.0.20] - 2020-12-02
- fixed progressbar - only count songs that are not yet local
- fixed crash on sync empty playlist (progress divide by 0)
- fixed initial Sync setup (removed deprecated methods)
- fixed crashes on Error handling
- fixed hot reloading of settings
- refactor of menus
- added last sync time record
- added support for descentmk2 devices

Version [0.0.19] - 2020-11-20
- refactor of sync engine
- fixed stack overflow error (rare case)
- fixed progress bar during sync
- improved error handling and reporting 

Version [0.0.18] - 2020-11-03
- fixed updating settings with Subsonic API
- fixed possible crash on received null values

Version [0.0.17] - 2020-10-18
- added dynamic limit for response size (Ampache API)
- added handling 'session expired' error (Ampache API)
- fixed progressbar during sync (remote playlists do not count)
- fixed order of playlists, locals always first
- fixed some crashes
- added support for D2 Air, Sq. Music

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