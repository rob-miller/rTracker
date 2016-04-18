/***************
 rTracker-constants.h
 Copyright 2010-2016 Robert T. Miller
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 *****************/

/*
 *  rTracker-constants.h
 *  rTracker
 *
 *  Created by Robert Miller on 18/10/2010.
 *  Copyright 2010 Robert T. Miller. All rights reserved.
 *
 */

// 18 dec change MARGIN from 10.0f
#define MARGIN 8.0f
#define SPACE 3.0f
#define TFXTRA 2.0f;

#define rtTrackerUpdatedNotification @"rtTrackerUpdatedNotification"
#define rtValueUpdatedNotification @"rtValueUpdatedNotification"
#define rtProgressBarUpdateNotification @"rtProgressBarUpdateNotification"
#if ADVERSION
#define rtPurchasedNotification @"rtPurchasedNotification"
#endif

#define kAnimationDuration 0.3

#define kViewTag		((NSInteger) 1)
//#define kViewTag2		((NSInteger) 2)

#define TMPUNIQSTART		1000

#define TIMESTAMP_LABEL @"timestamp"
#define TIMESTAMP_KEY   @"timestamp:0"

#define MINPRIV         1
#define MAXPRIV         100
#define BIGPRIV         1000
#define PRIVDFLT		MINPRIV

#define f(x) ((CGFloat) (x))
#define d(x) ((double) (x))

#define SAMPLES_VERSION 1

#define DEMOS_VERSION 4
// demos_version 2 improve colours for one graph, wording improvements, link to getTrackers.pl, iOS settings to change text size
// demos version 3 fix link for 'tap to drop me a note'; add endpoint <none> example;
// demos version 4 change links to GitHub, remove rTrackerA URL scheme entry

#define RTDB_VERSION 2
// rtdb_version 2 info table added unique constraint on names column

#define RTFN_VERSION 1

// strings to access text field for setting constant
// lc= lastConst, could be more than 1
#define LCKEY @"fdlc"
#define CTFKEY @"fdcTF"
#define CLKEY @"fdcLab"


// add to x and y axes to improve visibility of endpoints
#define GRAPHSCALE d(0.02)

// default preference for separateDateTimePicker

#define SDTDFLT NO
#define RTCSVOUTDFLT NO
#define SAVEPRIVDFLT YES
#define ACCEPTLICENSEDFLT NO

//#define HIDERTIMESDFLT YES
#define SCICOUNTDFLT 6

#define CSVext @".csv"
#define RTRKext @".rtrk"
#define TmpTrkrData @".tdata"
#define TmpTrkrNames @".tnames"

#define CELL_HEIGHT_NORMAL ( ((trackerObj*)self.vo.parentTracker).maxLabel.height + (3.0*MARGIN))
#define CELL_HEIGHT_TALL (2.0 * CELL_HEIGHT_NORMAL)

#define ADVER_TRACKER_LIM   8
#define ADVER_ITEM_LIM      8

#define PrefBodyFont [UIFont preferredFontForTextStyle:UIFontTextStyleBody]

#define RTA_prodid @"rTrackerA_1"
