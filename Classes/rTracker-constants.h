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

#define DEMOS_VERSION 2
// demos_version 1 ad hard to see colours for one graph

#define RTDB_VERSION 2
// rtdb_version 1 info table needed unique constraint on names column

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
//#define HIDERTIMESDFLT YES

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
