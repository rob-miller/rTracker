# rTracker

[rTracker](http://rob-miller.github.io/rTracker/rTracker/iPhone/pages/rTracker-main.html) is a complete iOS application for creating local on-device databases ('trackers') to log data with timestamps.

Trackers can use a variety of iOS controls (number/text fields, sliders, radiobuttons, checkbuttons), and can implement limited functions on values within entries and over time.  These controls comprise the data input form, and are presented when the device is in portrait orientation; rotating the device to landscape mode will present a graph of the collected data over time.

Tracker data can be exported in CSV format, and trackers (with or without data) can be shared with other rTracker users.  CSV data can also be imported, and trackers can be created with (specially formatted) CSV files.

Trackers can have iOS local notifications which trigger on specific time and data criteria, implementing a 'reminder to track' facility.

rTracker supports URL schemes to either open the application main window (rTracker://) or a specific tracker (rTracker://tid=4).

A rudimentary privacy facility is available, such that trackers and/or their values can be hidden until a 'graphical password' is entered.

## Views

![Tracker list](http://rob-miller.github.io/rTracker/rTracker/iPhone/rTracker-main-imgs/rTracker-main-view.png)
![sample tracker](http://rob-miller.github.io/rTracker/screenShots/iphone6_tia.png)
![graph](http://rob-miller.github.io/rTracker/screenShots/iPhone6_graph.png)

## Status

rTracker is available on the [Apple App Store](https://itunes.apple.com/us/app/rtracker-track-it-all-your-way/id486541371?mt=8&uo=4 "rTracker on the App Store").  Released as open source because programming is fun, but filing company paperwork is not.

## Documentation

The original webpages for the commercial website are [here](http://rob-miller.github.io/rTracker/rTracker/iPhone/pages/rTracker-main.html)

## Dependencies / included software

Tracker reminders (iOS local notifications) can have sounds associated with them.  For the published app these have been obtained from http://www.freesfx.co.uk/ , however their licensing does not allow redistribution in this repository.  Any .caf audio file included in the top level directory and added to the project in Xcode will be placed in the bundle and offered as a reminder sound effect; see the 'readme.sounds' file for details.

The [TimesSquare calendar view](https://github.com/puls/objc-TimesSquare) is included, with modifications updating it for more recent versions of iOS and supporting coloring of individual dates.

Many other contributions from around the net (especially Matt Gallagher's CSV parser, and Peter Steinberger's ThreadGuard work) and snippets from [StackOverflow](http://stackoverflow.com/) are attributed (though often insufficiently) in the source files. 

The released application includes [Fabric/Crashlytics](https://try.crashlytics.com/) for crash reporting.  Relevant lines in the source code are enabled/disabled by '#define FABRIC' in the file dbg-defs.h.

## Development / layout

Preprocessor macros control log, warning and error level NSLog messages.  These and other project-wide devlopment controls are contained in the file dbg-defs.h.

Each tracker defines a frontend for one sqlite3 database, and the overall list of trackers is one more (so 5 trackers means 5+1 separate sqlite3 databases).

The base class for individual tracked values is valueObj and this implements an Objective C protocol called voProtocol.   The default voProtocol implementations are in voState, and subclassed in control-named classes such as voSlider.

rTrackerA is a separate build target which uses the iOS advertising platform, is limited to 8 trackers of 8 items each, and offers an in-app upgrade to remove these features.  It is being/has been removed from the App Store.

rTracker-test is a separate build target for distribution to testers through Fabric.

[GitHub contribution hints](http://www.javaworld.com/article/2113465/developer-tools-ide/git-smart-20-essential-tips-for-git-and-github-users.html)

## License

Copyright 2010-2020 Robert T. Miller

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use these files except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
