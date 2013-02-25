_LipikaIME_, a user-configurable, phonetic, Input Method Engine for Mac OS X.

> Copyright (C) 2013 Ranganath Atreya

```
This program is free software: you can redistribute it and/or modify it under the terms of the GNU 
General Public License as published by the Free Software Foundation; either version 3 of the License, 
or (at your option) any later version.

This program comes with ABSOLUTELY NO WARRANTY; see LICENSE file.
```

Lipika IME is a many-to-many, user configurable, phonetic, input method engine. Originally, designed to type Sanskrit using Devanagari on a Mac. It can be configured to work with any other Indo-European language of similar structure.

Installation
------------
To install LipikaIME, simply copy `LipikaIME.app` to `/Library/Input Methods/` folder.

Lipika IME understands Google IME cannonical scheme format: http://www.google.com/inputtools/windows/canonical.html
Schemes are in `/Library/Input Methods/LipikaIME/Contents/Resources/Schemes` directory. Barahavat.scm for Devanagari comes built-in.


2/25/2013: RELEASE NOTES FOR VERSION 1.0
-----------------------------------------
* Ability to choose from list of available schemes
* User preferences with ability to configure candidate window
* Functionality to automatically persist user preferrences
* Added ITRANS.scm for Indian languages TRANSliteration
* Various bug fixes


2/17/2013: RELEASE NOTES FOR VERSION 0.9
-----------------------------------------
The first release is a minimal credible product with the following features:

* User configurable IME mapping in Google IME cannonical scheme format.
* Single candidate in cadidate window showing the current word being worked on.
