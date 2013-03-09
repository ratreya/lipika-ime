_LipikaIME_, a user-configurable, phonetic, Input Method Engine for Mac OS X.

> Copyright (C) 2013 Ranganath Atreya

```
This program is free software: you can redistribute it and/or modify it under the terms of the GNU 
General Public License as published by the Free Software Foundation; either version 3 of the License, 
or (at your option) any later version.

This program comes with ABSOLUTELY NO WARRANTY; see LICENSE file.
```

Lipika IME is a many-to-many, user configurable, phonetic, input method engine. Originally, designed to type Sanskrit using Devanagari on a Mac. It can be configured to work with any other Indo-European language of similar structure.


### 3/09/2013: RELEASE NOTES FOR VERSION 1.0 ###
* Ability to configure log level; default is warning
* Configurable backspace behavior: delete mapping, delete ouput
* Configurable onUnfocus behavior: commit inflight, discard inflight, restore inflight onFocus
* Open sourcing the code on github


### 3/02/2013: RELEASE NOTES FOR VERSION 0.97 ###
* ITRANS version 5.30 using classes for maintainability
* Backspace now deletes single output character at a time
* Various bug fixes including fix for #11


### 2/25/2013: RELEASE NOTES FOR VERSION 0.95 ###
* Ability to choose from list of available schemes
* User preferences with ability to configure candidate window
* Functionality to automatically persist user preferrences
* Added ITRANS.scm for Indian languages TRANSliteration
* Various bug fixes


### 2/17/2013: RELEASE NOTES FOR VERSION 0.90 ###
This first release is a minimal credible product with the following features:

* User configurable IME mapping in Google IME cannonical scheme format.
* Single candidate in cadidate window showing the current word being worked on.
