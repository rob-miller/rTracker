/***************
 RootViewController.m
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

//
//  RootViewController.m
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright Robert T. Miller 2010. All rights reserved.
//

#import <libkern/OSAtomic.h>

#import "RootViewController.h"
#import "rTrackerAppDelegate.h"
#import "addTrackerController.h"
#import "configTlistController.h"
#import "useTrackerController.h"
#import "rTracker-resource.h"
#import "privacyV.h"
#import "rTracker-constants.h"
#import "rTracker-resource.h"

#import "CSVParser.h"

#import "dbg-defs.h"

#if ADVERSION
#import "adSupport.h"
#import "rt_IAPHelper.h"
#endif

@implementation RootViewController

@synthesize tableView=_tableView;
@synthesize tlist=_tlist, refreshLock=_refreshLock;
@synthesize privateBtn=_privateBtn, helpBtn=_helpBtn, privacyObj=_privacyObj, addBtn=_addBtn, editBtn=_editBtn, flexibleSpaceButtonItem=_flexibleSpaceButtonItem, initialPrefsLoad=_initialPrefsLoad, readingFile=_readingFile, stashedTIDs=_stashedTIDs, scheduledReminderCounts=_scheduledReminderCounts;

#if ADVERSION
@synthesize adSupport=_adSupport;
#endif

//openUrlLock, inputURL,

#pragma mark -
#pragma mark core object methods and support

- (void)dealloc {
	DBGLog(@"rvc dealloc");
}



#pragma mark -
#pragma mark load CSV files waiting for input

static int csvLoadCount;
static int plistLoadCount;
static int csvReadCount;
static int plistReadCount;
static BOOL InstallSamples;
static BOOL InstallDemos;

//
// original code:
//-------------------
//  Created by Matt Gallagher on 2009/11/30.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//-------------------

-(void) doCSVLoad:(NSString*)csvString to:(trackerObj*)to fname:(NSString*)fname {
    
    DBGLog(@"start csv parser %@",to.trackerName);
    CSVParser *parser = [[CSVParser alloc] initWithString:csvString separator:@"," hasHeader:YES fieldNames:nil];
    to.csvProblem=nil;
    to.csvReadFlags=0;
    [parser parseRowsForReceiver:to selector:@selector(receiveRecord:)]; // receiveRecord in trackerObj.m
    DBGLog(@"csv parser done %@",to.trackerName);
    
    [to loadConfig];
    
    if (to.csvReadFlags & (CSVCREATEDVO | CSVCONFIGVO | CSVLOADRECORD)) {
        
        to.goRecalculate=YES;
        [to recalculateFns];    // updates fn vals in database
        to.goRecalculate=NO;
        DBGLog(@"functions recalculated %@",to.trackerName);
        
        [to saveChoiceConfigs]; // in case csv data had unrecognised choices
        
        DBGLog(@"csv loaded:");
#if DEBUGLOG
        [to describe];
#endif
    }
    if (to.csvReadFlags & CSVNOTIMESTAMP) {
        [rTracker_resource alert:@"No timestamp column" msg:[NSString stringWithFormat:@"The file %@ has been rejected by the CSV loader as it does not have '%@' as the first column.",fname,TIMESTAMP_LABEL] vc:self];
        //[rTracker_resource finishActivityIndicator:self.view navItem:nil disable:NO];
        return;
    } else if (to.csvReadFlags & CSVNOREADDATE) {
        [rTracker_resource alert:@"Date format problem" msg:[NSString stringWithFormat:@"Some records in the file %@ were ignored because timestamp dates like '%@' are not compatible with your device's calendar settings (%@).  Please modify the file or change your international locale preferences in System Settings and try again.",fname,to.csvProblem,[to.dateFormatter stringFromDate:[NSDate date] ]] vc:self];
        //[rTracker_resource finishActivityIndicator:self.view navItem:nil disable:NO];
        return;
    }

    [rTracker_resource setProgressVal:(((float)csvReadCount)/((float)csvLoadCount))];

    csvReadCount++;
    
    
}
-(void) startLoadActivityIndicator:(NSString*)str {
    [rTracker_resource startActivityIndicator:self.view navItem:nil disable:NO str:str];
}

- (void) loadTrackerCsvFiles {
    //DBGLog(@"loadTrackerCsvFiles");
    NSString *docsDir = [rTracker_resource ioFilePath:nil access:YES];
    NSFileManager *localFileManager=[NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:docsDir];
    BOOL newRtcsvTracker=NO;
    BOOL rtcsv=NO;
    
    NSString *file;

    [privacyV jumpMaxPriv];
    while ((file = [dirEnum nextObject])) {
        trackerObj *to = nil;
        NSString *fname = [file lastPathComponent];
        NSString *tname = nil;
        NSRange inmatch;
        BOOL validMatch=NO;
#if DEBUGLOG
        NSString *loadObj;
#endif
        
        if ([[file pathExtension] isEqualToString: @"csv"]) {
#if DEBUGLOG
            loadObj = @"csv";
#endif
            inmatch = [fname rangeOfString:@"_in.csv" options:NSBackwardsSearch|NSAnchoredSearch];
            //DBGLog(@"consider input: %@",fname);
            
            if ((inmatch.location != NSNotFound) && (inmatch.length == 7)) {  // matched all 7 chars of _in.csv at end of file name  (must test not _out.csv)
                validMatch=YES;
            }
            
        } else if ([[file pathExtension] isEqualToString: @"rtcsv"]) {
            rtcsv=YES;
#if DEBUGLOG
            loadObj = @"rtcsv";
#endif
            inmatch = [fname rangeOfString:@".rtcsv" options:NSBackwardsSearch|NSAnchoredSearch];
            //DBGLog(@"consider input: %@",fname);
            
            if ((inmatch.location != NSNotFound) && (inmatch.length == 6)) {  // matched all 6 chars of .rtcsv at end of file name  (unlikely to fail but need inmatch to get tname)
                validMatch=YES;
            }
        }

        if (validMatch) {
            tname = [fname substringToIndex:inmatch.location];
            DBGLog(@"%@ load input: %@ as %@",loadObj,fname,tname);
            //[rTracker_resource startActivityIndicator:self.view navItem:nil disable:NO str:@"loading data..."];
            //safeDispatchSync(^{
            //    [rTracker_resource startActivityIndicator:self.view navItem:nil disable:NO str:[NSString stringWithFormat:@"loading %@...", tname]];
            //});
            
            NSInteger tid = [self.tlist getTIDfromName:tname];
            if (tid) {
                to = [[trackerObj alloc]init:tid];
                DBGLog(@" found existing tracker tid %ld with matching name",(long)tid);
            } else if (rtcsv) {
                to = [[trackerObj alloc] init];
                to.trackerName = tname;
                to.toid = [self.tlist getUnique];
                [to saveConfig];
                [self.tlist addToTopLayoutTable:to];
                newRtcsvTracker = YES;
                DBGLog(@"created new tracker for rtcsv, id= %ld",(long)to.toid);
            }

            if (nil != to) {
                safeDispatchSync(^{
                    [rTracker_resource startActivityIndicator:self.view navItem:nil disable:NO str:[NSString stringWithFormat:@"loading %@...", tname]];
                });

                NSString *target = [docsDir stringByAppendingPathComponent:file];
                NSString *csvString = [NSString stringWithContentsOfFile:target encoding:NSUTF8StringEncoding error:NULL];
                
                //[rTracker_resource stashProgressBarMax:(int)[rTracker_resource countLines:csvString]];

                if (csvString)
                {
                    safeDispatchSync(^{
                        [UIApplication sharedApplication].idleTimerDisabled = YES;
                        [self doCSVLoad:csvString to:to fname:fname];
                        [UIApplication sharedApplication].idleTimerDisabled = NO;
                    });
                    [rTracker_resource deleteFileAtPath:target];
                }
                
                safeDispatchSync(^{
                    [rTracker_resource finishActivityIndicator:self.view navItem:nil disable:NO];
                });
            }
            
        }
        
    }
    
    [privacyV restorePriv];
    
    if (newRtcsvTracker) {
        [self refreshViewPart2];
    }
}


// load a tracker from NSDictionary generated by trackerObj:dictFromTO()
//    [consists of tid, optDict and valObjTable]
//    if trackerName match
//      if different tid
//         change tid of existing to input new
//      merge new trackerObj:
//         update vids as needed
//         add valObjs as needed
//    else
//      if existing tid match
//         move existing to new tid
//      add new tracker
//
//  added nov 2012
//
- (int) loadTrackerDict:(NSDictionary*)tdict tname:(NSString*)tname {
    
    // get input tid
    NSNumber *newTID = tdict[@"tid"];
    DBGLog(@"load input: %@ tid %@",tname, newTID);
    
    int newTIDi = [newTID intValue];
    int matchTID = -1;
    NSArray *tida = [self.tlist getTIDFromNameDb:tname];
    
    // find tracker with same name and tid, or just same name
    for (NSNumber *tid in tida) {
        if ((-1 == matchTID) || ([tid isEqualToNumber:newTID])) // first tid with same name, or tid for matching name if exists
            matchTID = [tid intValue];
    }
    
    DBGLog(@"matchTID= %d",matchTID);
    
    trackerObj *inputTO;
    if (-1 != matchTID) {  // found tracker with same name and maybe same tid
        if (!loadingDemos) {
            [rTracker_resource stashTracker:matchTID];                            // make copy of current tracker so can reject newTID later
        }
        [self.tlist updateTID:matchTID new:newTIDi];                          // change existing tracker tid to match new (restore if we discard later)

        inputTO = [[trackerObj alloc] init:newTIDi];                          // load up existing tracker config
        
        [inputTO confirmTOdict:tdict];                                        // merge valObjs
        inputTO.prevTID = matchTID;
        [inputTO saveConfig];                                                 // write to db -- probably redundant as confirmTOdict writes to db as well
        
        DBGLog(@"updated %@",tname);
        
        //DBGLog(@"skip load plist file as already have %@",tname);
    } else {              // new tracker coming in
        [self.tlist fixDictTID:tdict];                                        // move any existing TIDs out of way
        inputTO = [[trackerObj alloc] initWithDict:tdict];                    // create new tracker with input data
        inputTO.prevTID = matchTID;
        [inputTO saveConfig];                                                 // write to db
        [self.tlist addToTopLayoutTable:inputTO];                             // insert in top list
        DBGLog(@"loaded new %@",tname);        
    }
    
    
    return newTIDi;
}

#pragma mark -
#pragma mark load .plists and .rtrks for input trackers

- (int) handleOpenFileURL:(NSURL*)url tname:(NSString*)tname {
    NSDictionary *tdict = nil;
    NSDictionary *dataDict = nil;
    int tid;
    
    DBGLog(@"open url %@",url);

    [privacyV jumpMaxPriv];
    if (nil != tname) {  // if tname set it is just a plist
        tdict = [NSDictionary dictionaryWithContentsOfURL:url];
    } else {  // else is an rtrk
        NSDictionary *rtdict = [NSDictionary dictionaryWithContentsOfURL:url];
        tname = rtdict[@"trackerName"];
        tdict = rtdict[@"configDict"];
        dataDict = rtdict[@"dataDict"];
        if (loadingDemos) {
            [self.tlist deleteTrackerAllTID:[tdict objectForKey:@"tid"] name:tname];  // wipe old demo tracker otherwise starts to look ugly
        }
    }

    //DBGLog(@"ltd enter dict= %lu",(unsigned long)[tdict count]);
    tid = [self loadTrackerDict:tdict tname:tname];

    if (nil != dataDict) {
        trackerObj *to = [[trackerObj alloc] init:tid];
        
        [to loadDataDict:dataDict];  // vids ok because confirmTOdict updated as needed
        to.goRecalculate=YES;
        [to recalculateFns];    // updates fn vals in database
        to.goRecalculate=NO;
        [to saveChoiceConfigs]; // in case input data had unrecognised choices
        
        DBGLog(@"datadict loaded for open file url:");
#if DEBUGLOG
        [to describe];
#endif
    }

    DBGLog(@"ltd/ldd finish");
    
    [privacyV restorePriv];
    DBGLog(@"removing file %@",[url path]);
    [rTracker_resource deleteFileAtPath:[url path]];
    
    return tid;
}


- (BOOL) loadTrackerPlistFiles {
    // called on refresh, loads any _in.plist files as trackers
    // also called if any .rtrk files exist
    DBGLog(@"loadTrackerPlistFiles");
    __block int rtrkTid=0;
    
    NSString *docsDir = [rTracker_resource ioFilePath:nil access:YES];
    NSFileManager *localFileManager= [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:docsDir];
    
    NSString *file;
    
    NSMutableArray *filesToProcess = [[NSMutableArray alloc] init];
    while ((file = [dirEnum nextObject])) {
        NSString *fname = [file lastPathComponent];
        if ([[file pathExtension] isEqualToString: @"plist"]) {
            NSRange inmatch = [fname rangeOfString:@"_in.plist" options:NSBackwardsSearch|NSAnchoredSearch];
            //DBGLog(@"consider input: %@",fname);
            if ((inmatch.location != NSNotFound) && (inmatch.length == 9)) {  // matched all 9 chars of _in.plist at end of file name
                [filesToProcess addObject:file];
            }
        } else if ([[file pathExtension] isEqualToString: @"rtrk"]) {
            [filesToProcess addObject:file];
        }
    }
    
    for (file in filesToProcess) {
        NSString *target;
        NSString *newTarget;
        __block BOOL plistFile=NO;
        
        NSString *fname = [file lastPathComponent];
        DBGLog(@"process input: %@",fname);

        target = [docsDir stringByAppendingPathComponent:file];
        
        newTarget = [[target stringByAppendingString:@"_reading"] stringByReplacingOccurrencesOfString:@"Documents/Inbox/" withString:@"Documents/"];
        
        NSError *err;
        if ([localFileManager moveItemAtPath:target toPath:newTarget error:&err] != YES)
            DBGErr(@"Error on move %@ to %@: %@",target, newTarget, err);

        self.readingFile=YES;

        NSRange inmatch = [fname rangeOfString:@"_in.plist" options:NSBackwardsSearch|NSAnchoredSearch];

        safeDispatchSync(^{
            [UIApplication sharedApplication].idleTimerDisabled = YES;

            if ((inmatch.location != NSNotFound) && (inmatch.length == 9)) {  // matched all 9 chars of _in.plist at end of file name
                rtrkTid = [self handleOpenFileURL:[NSURL fileURLWithPath:newTarget] tname:[fname substringToIndex:inmatch.location]];
                plistFile = YES;
            } else {   // .rtrk file
                rtrkTid = [self handleOpenFileURL:[NSURL fileURLWithPath:newTarget] tname:nil];
            }

            [UIApplication sharedApplication].idleTimerDisabled = NO;
        });
        
        if (plistFile) {
            [rTracker_resource rmStashedTracker:0];  // 0 means rm last stashed tracker, in this case the one stashed by handleOpenFileURL
        } else {
            [self.stashedTIDs addObject:@(rtrkTid)];
        }
        
        self.readingFile=NO;
    
        [rTracker_resource setProgressVal:(((float)plistReadCount)/((float)plistLoadCount))];
        plistReadCount++;

    }

    return(rtrkTid);
}

BOOL loadingCsvFiles=NO;

- (void) doLoadCsvFiles {
    if (loadingCsvFiles) return;
    loadingCsvFiles=YES;
    @autoreleasepool {
    
        [self loadTrackerCsvFiles];
        safeDispatchSync(^{
            // csv file load done, close activity indicators
            [rTracker_resource finishProgressBar:self.view navItem:self.navigationItem disable:YES];
            [rTracker_resource finishActivityIndicator:self.view navItem:self.navigationItem disable:NO];
        });

        // give up lock
        self.refreshLock = 0;
        loadingCsvFiles=NO;
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self refreshToolBar:YES];
        });
        DBGLog(@"csv data loaded, UI enabled, CSV lock off stashedTIDs= %@",self.stashedTIDs);
        
        if (0< [self.stashedTIDs count]) {
            [self doRejectableTracker];
        }
    }
    
    // thread finished
}

- (void) refreshViewPart2 {
    //DBGLog(@"entry");
    [self.tlist confirmToplevelTIDs];
    [self.tlist loadTopLayoutTable];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.tableView reloadData];
        [self refreshEditBtn];
        [self refreshToolBar:YES];
        [self.view setNeedsDisplay];
    });
    // no effect [self.tableView setNeedsDisplay];
}

BOOL loadingInputFiles=NO;
- (void) doLoadInputfiles {
    if (loadingInputFiles) return;
    if (loadingCsvFiles) return;
    loadingInputFiles=YES;
    @autoreleasepool {
    
        if (InstallDemos) {
            [self loadDemos:YES];
            InstallDemos = NO;
        }
        
        if (InstallSamples) {
            [self loadSamples:YES];
            InstallSamples = NO;
        }
        
        if ([self loadTrackerPlistFiles]) {
            // this thread now completes updating rvc display of trackerList as next step is load csv data and trackerlist won't change (unless rtrk files)
            [self.tlist loadTopLayoutTable];  // called again in refreshviewpart2, but need for re-order to set ranks
            [self.tlist reorderFromTLT];
        };
        
        safeDispatchSync(^{
            //[rTracker_resource finishProgressBar:self.view navItem:self.navigationItem disable:YES];
            if (csvLoadCount) {
                [rTracker_resource finishActivityIndicator:self.view navItem:nil disable:NO];  // finish 'loading trackers' spinner
                //[rTracker_resource startActivityIndicator:self.view navItem:nil disable:NO str:@"loading data..."];
            }
        });
        [self refreshViewPart2];

        [NSThread detachNewThreadSelector:@selector(doLoadCsvFiles) toTarget:self withObject:nil];
        
        loadingInputFiles=NO;
        DBGLog(@"load plist thread finished, lock off, UI enabled, dispatched CSV load");
    }
    // end of this thread, refreshLock still on, userInteraction disabled, activityIndicator still spinning and doLoadCsvFiles is in charge
}

- (int) countInputFiles:(NSString*)targ_ext {
    int retval = 0;
    
    NSString *docsDir = [rTracker_resource ioFilePath:nil access:YES];
    NSFileManager *localFileManager=[NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:docsDir];
        
    NSString *file;
        
    while (file = [dirEnum nextObject]) {
        NSString *fname = [file lastPathComponent];
        //DBGLog(@"consider input file %@",fname);
        NSRange inmatch = [fname rangeOfString:targ_ext options:NSBackwardsSearch|NSAnchoredSearch];
        if (inmatch.location != NSNotFound) {
            DBGLog(@"existsInputFiles: match on %@",fname);
            retval++;
        }
    }

    return retval;
}

- (void) loadInputFiles {
    if (loadingInputFiles) return;
    if (loadingCsvFiles) return;
    //if (!self.openUrlLock) {
        csvLoadCount = [self countInputFiles:@"_in.csv"];
        plistLoadCount = [self countInputFiles:@"_in.plist"];
        int rtrkLoadCount = [self countInputFiles:@".rtrk"];
        csvLoadCount += [self countInputFiles:@".rtcsv"];
        
        // handle rtrks as plist + csv, just faster if only has data or only has tracker def
        csvLoadCount += rtrkLoadCount;
        plistLoadCount += rtrkLoadCount;
        
        if (InstallSamples)
            plistLoadCount += [self loadSamples:NO];
        if (InstallDemos)
            plistLoadCount += [self loadDemos:NO];
    
        // set rvc:static numerators for progress bars
        csvReadCount=1;
        plistReadCount=1;
        
        if ( 0 < (plistLoadCount + csvLoadCount) ) {
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];  // ScrollToTop so can see bars
            [rTracker_resource startActivityIndicator:self.view navItem:nil disable:NO str:@"loading trackers..."];
            [rTracker_resource startProgressBar:self.view navItem:self.navigationItem disable:YES  yloc:0.0f];

            [NSThread detachNewThreadSelector:@selector(doLoadInputfiles) toTarget:self withObject:nil];
            // lock stays on, userInteraction disabled, activityIndicator spinning,   give up and doLoadInputFiles() is in charge
            
            DBGLog(@"returning main thread, lock on, UI disabled, activity spinning,  files to load");
            return;
        }
    //}

    // if here (did not return above), no files to load, this thread set the lock and refresh is done now

    [self refreshViewPart2];
    self.refreshLock = 0;
    DBGLog(@"finished, no files to load - lock off");
    
    return;
}

#define SUPPLY_DEMOS 0
#define SUPPLY_SAMPLES 1

-(int) loadSuppliedTrackers:(BOOL)doLoad set:(NSInteger)set {
    NSBundle *bundle = [NSBundle mainBundle];
    NSArray *paths;
    if (SUPPLY_DEMOS == set) {
        paths = [bundle pathsForResourcesOfType:@"plist" inDirectory:@"demoTrackers"];
    } else {
        paths = [bundle pathsForResourcesOfType:@"plist" inDirectory:@"sampleTrackers"];
    }
    int count=0;
    
    /* copy plists over version
     NSString *docsDir = [rTracker_resource ioFilePath:nil access:YES];
     NSFileManager *dfltManager = [NSFileManager defaultManager];
     */
    
    //DBGLog(@"paths %@",paths  );
    
    
    for (NSString *p in paths) {
        
        if (doLoad) {
            // load now into trackerObj - needs progressBar
            NSDictionary *tdict = [NSDictionary dictionaryWithContentsOfFile:p];
            [self.tlist fixDictTID:tdict];
            trackerObj *newTracker = [[trackerObj alloc] initWithDict:tdict];
            
            [self.tlist deConflict:newTracker];  // add _n to trackerName so we don't overwrite user's existing if any .. could just merge now?
            
            [newTracker saveConfig];
            [self.tlist addToTopLayoutTable:newTracker];
            
            [rTracker_resource setProgressVal:(((float)plistReadCount)/((float)plistLoadCount))];
            plistReadCount++;
            
            DBGLog(@"finished loadSample on %@",p);
        }
        count++;
    }
    
    if (doLoad) {
        NSString *sql;
        if (SUPPLY_DEMOS == set) {
            sql = [NSString stringWithFormat:@"insert or replace into info (val, name) values (%i,'demos_version')",DEMOS_VERSION];
        } else {
            sql = [NSString stringWithFormat:@"insert or replace into info (val, name) values (%i,'samples_version')",SAMPLES_VERSION];
        }
        [self.tlist toExecSql:sql];
    }
    
    return(count);
    
}

- (int) loadSamples:(BOOL)doLoad {
    // called when handlePrefs decides is needed, copies plist files to documents dir
    // also called with doLoad=NO to just count
    // returns count
    
    int count = [self loadSuppliedTrackers:doLoad set:SUPPLY_SAMPLES];
 
    return count;
}

- (int) loadDemos:(BOOL)doLoad {
    
    //return [self loadSuppliedTrackers:doLoad set:SUPPLY_DEMOS];
    NSString *newp;
    NSError *err;
    NSBundle *bundle = [NSBundle mainBundle];
    NSArray *paths = [bundle pathsForResourcesOfType:@"rtrk" inDirectory:@"demoTrackers"];
    int count=0;
    
    loadingDemos=YES;
    for (NSString *p in paths) {
        if (doLoad) {
            NSString *file = [p lastPathComponent];
            //newp = [rTracker_resource ioFilePath:[NSString stringWithFormat:@"Inbox/%@",file] access:YES];
            newp = [rTracker_resource ioFilePath:[NSString stringWithFormat:@"%@",file] access:YES];
            if  (![[NSFileManager defaultManager] copyItemAtPath:p toPath:newp error:&err] ) {
                DBGErr(@"Error copying file: %@ to %@ error: %@", p, newp,  err);
                count--;
            } else {
                [self handleOpenFileURL:[NSURL fileURLWithPath:newp] tname:nil];
                //DBGLog(@"stashedTIDs= %@",self.stashedTIDs);
            }
        }
        count++;
    }
    if (doLoad && count) {
        NSString *sql;
        sql = [NSString stringWithFormat:@"insert or replace into info (val, name) values (%i,'demos_version')",DEMOS_VERSION];
        [self.tlist toExecSql:sql];
    }
    loadingDemos=NO;
    return count;
}


#pragma mark -
#pragma mark view support

- (void)scrollState {
    if (_privacyObj && self.privacyObj.showing != PVNOSHOW) { // test backing ivar first -- don't instantiate if not there
        self.tableView.scrollEnabled = NO;
        //DBGLog(@"no");
    } else {
        self.tableView.scrollEnabled = YES;
        //DBGLog(@"yes");
    }
}

- (void) refreshToolBar:(BOOL)animated {
    //DBGLog(@"refresh tool bar, noshow= %d",(PVNOSHOW == self.privacyObj.showing));
	[self setToolbarItems:@[self.flexibleSpaceButtonItem,
                           self.helpBtn,
						   //self.payBtn, 
                           self.privateBtn] 
				 animated:animated];
}

- (void) initTitle {
    
    // set up the title 
    
    NSString *devname = [[UIDevice currentDevice] name];
    //DBGLog(@"name = %@",devname);
    NSArray *words = [devname componentsSeparatedByString:@" "];
    
    NSUInteger i=0;
    NSUInteger c = [words count];
    NSString *name=nil;
    
    for (i=0;i<c && nil == name;i++) {
        NSString *w=nil;
        if (![@"" isEqual: (w = words[i])]) {
            name = w;
        }
    }
    
    NSUInteger prodNdx=0;
    NSString *longName = words[0];
    
    for (prodNdx =0; prodNdx<c;prodNdx++) {
        if ( (NSOrderedSame == [@"iphone" caseInsensitiveCompare:words[prodNdx]])
            || (NSOrderedSame == [@"ipad" caseInsensitiveCompare:words[prodNdx]])
            || (NSOrderedSame == [@"ipod" caseInsensitiveCompare:words[prodNdx]])
            || (NSOrderedSame == [@"itouch" caseInsensitiveCompare:words[prodNdx]]) ) {
            break;
        }
    }
    if ((1 <= prodNdx) && (prodNdx < c)) {
        for (i=1;i<prodNdx;i++) {
            longName = [longName stringByAppendingFormat:@" %@",words[i]];
        }
    } else if ((0 == prodNdx) || (prodNdx >= c)) {
            longName = nil;
    }
    
    if ((nil == name)
#if RELEASE
        || ([name isEqualToString:@"iPhone"])
        || ([name isEqualToString:@"iPad"])
#endif
        || (0 == [name length])
#if NONAME
        || YES
#endif
        ){
        self.title = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]; // @"rTracker";
    } else {
        CGFloat bw1=0.0f;
        CGFloat bw2=0.0f;
        UIView *view = [self.editBtn valueForKey:@"view"];
        bw1 = view ? ([view frame].size.width + [view frame].origin.x) : (CGFloat)53.0; // hardcode after change from leftBarButton to backBarButton
        UIView *view2 = [self.addBtn valueForKey:@"view"];
        bw2 = view2 ? [view2 frame].origin.x : (CGFloat)282.0;

        if ((0.0f == bw1) || (0.0f==bw2)) {
            self.title = @"rTracker";
        } else {
            NSString *tname=nil,*tn2;

            NSRange r0 = [name rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"'`’´‘"] options:NSBackwardsSearch];
            if (NSNotFound != r0.location) {
                NSUInteger len = [name length];
                NSUInteger pos = r0.location + r0.length;
                if (pos == (len-1)) {
                    unichar c = [name characterAtIndex:pos];
                    if (('s' == c) || ('S' == c)) {
                        tname = [name stringByAppendingString:@" tracks"];
                        tn2 = [name stringByAppendingString:@"  tracks"];
                    }
                } else if (pos == len) {
                        tname = [name stringByAppendingString:@" tracks"];
                        tn2 = [name stringByAppendingString:@"  tracks"];
                }
            }
            
            if (nil == tname) {
                tname = [name stringByAppendingString:@"’s tracks"];
                tn2 = [name stringByAppendingString:@" ’s tracks"];
            }

            DBGLog(@"tname= %@",tname);
            DBGLog(@"longName= %@",longName);
            
            NSString *ltname = [longName stringByAppendingString:@" tracks"];
            NSString *ltn2 = [longName stringByAppendingString:@"  tracks"];
            
            CGFloat maxWidth = (bw2 - bw1)-8; //self.view.bounds.size.width - btnWidths;
            //DBGLog(@"view wid= %f bw1= %f bw2= %f",self.view.bounds.size.width ,bw1,bw2);

            CGSize namesize = [tn2 sizeWithAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:20.0f]}];
            CGFloat nameWidth = ceilf( namesize.width );
            
            CGSize lnamesize = [ltn2 sizeWithAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:20.0f]}];

            CGFloat lnameWidth = ceilf( lnamesize.width );
            
            //DBGLog(@"name wid= %f  maxwid= %f  name= %@",nameWidth,maxWidth,tname);
            if ((nil != longName) && (lnameWidth < maxWidth)) {
                self.title = ltname;
            } else if (nameWidth < maxWidth) {
                self.title = tname;
            } else {
                self.title = @"rTracker";
            }
        }
    }
}


#if ADVERSION

- (void)viewDidLayoutSubviews
{
    if (![rTracker_resource getPurchased]) {
        [self.adSupport layoutAnimated:self tableview:self.tableView animated:[UIView areAnimationsEnabled]];
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self.adSupport layoutAnimated:self tableview:self.tableView animated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self.adSupport layoutAnimated:self tableview:self.tableView animated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    //[self.adSupport stopTimer];
    return YES;
}

- (adSupport*) adSupport
{
    if (![rTracker_resource getPurchased]) {
        if (_adSupport == nil) {
            _adSupport = [[adSupport alloc] init];
        }
    }
    return _adSupport;
}

#endif


// handle notification while in foreground
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
        willPresentNotification:(UNNotification *)notification
        withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
   // Update the app interface directly.
    [self countScheduledReminders];  // race me
    // nice to make this work again
    //[self doQuickAlert:notification.request.content.title msg:notification.request.content.body delay:2];
    // Play a sound.
   completionHandler(UNNotificationPresentationOptionSound);
    [self.tableView reloadData];  // redundant but waiting for countScheduledReminders to complete
    [self.view setNeedsDisplay];
}

// handle notification while in background
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
          didReceiveNotificationResponse:(UNNotificationResponse *)response
          withCompletionHandler:(void (^)(void))completionHandler {
    DBGLog(@"did receive notification response while in backrgound");
   if ([response.actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier]) {
       // The user dismissed the notification without taking action.
   }
   else if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
       // The user launched the app.

       NSDictionary *userInfo = response.notification.request.content.userInfo;
       RootViewController *rootController = (self.navigationController.viewControllers)[0];
       [rootController performSelectorOnMainThread:@selector(doOpenTracker:) withObject:(userInfo)[@"tid"] waitUntilDone:NO];
   }
     
       // Else handle any custom actions. . .
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [UNUserNotificationCenter currentNotificationCenter].delegate = self;

#if ADVERSION
#if !RELEASE
    [rTracker_resource setPurchased:NO];
#endif
    if (![rTracker_resource getPurchased]) {
#if !DISABLE_ADS
        [self.adSupport initBannerView:self];
#endif
    }
    //[self.view addSubview:self.adSupport.bannerView];
#endif
    
	//DBGLog(@"rvc: viewDidLoad privacy= %d",[privacyV getPrivacyValue]);

    self.refreshLock = 0;
    self.readingFile=NO;


    UIImage *img = [UIImage imageNamed:[rTracker_resource getLaunchImageName] ];
    //DBGLog(@"set backround image to %@",[rTracker_resource getLaunchImageName]);
    UIImageView *bg = [[UIImageView alloc] initWithImage:img];

    CGSize vsize = [rTracker_resource get_visible_size:self];
    CGFloat scal = bg.frame.size.width / vsize.width;

    UIImage *img2 = [UIImage imageWithCGImage:img.CGImage scale:scal orientation:UIImageOrientationUp];
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:img2];
    [self.navigationController.navigationBar setBackgroundImage:img2 forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.toolbar setBackgroundImage:img2 forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
     
    
    self.navigationItem.rightBarButtonItem = self.addBtn;
    self.navigationItem.leftBarButtonItem = self.editBtn;
    
    // toolbar setup
    [self refreshToolBar:NO];

    // title setup
    [self initTitle];

#if ADVERSION
    if (![rTracker_resource getPurchased]) {
#if !DISABLE_ADS
        tableFrame.size.height -= self.adSupport.bannerView.frame.size.height;
        DBGLog(@"ad h= %f  tfh= %f ",self.adSupport.bannerView.frame.size.height,tableFrame.size.height);
#endif
    }
#endif

    CGRect tableFrame;
    tableFrame.origin.x = 0.0;
    tableFrame.origin.y = 0.0;
    tableFrame.size.height = vsize.height;
    tableFrame.size.width = vsize.width;

    DBGLog(@"tvf origin x %f y %f size w %f h %f",tableFrame.origin.x,tableFrame.origin.y,tableFrame.size.width,tableFrame.size.height);
    self.tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];
    
    //self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.view addSubview:self.tableView];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        NSArray <UIApplicationShortcutItem *> *existingShortcutItems = [[UIApplication sharedApplication] shortcutItems];
        if (0 == [existingShortcutItems count] /*|| ([rTracker_resource getSCICount] != [existingShortcutItems count]) */ ) {  // can#'t set more than 4 or prefs messed up
            [self.tlist updateShortcutItems];
        }
    }
    
}

- (trackerList *) tlist {
    if (nil == _tlist) {
        trackerList *tmptlist = [[trackerList alloc] init];
        self.tlist = tmptlist;
        
        if ([self.tlist recoverOrphans]) {     // added 07.viii.13
            [rTracker_resource alert:@"Recovered files" msg:@"One or more tracker files were recovered, please delete if not needed." vc:self];
        }
        [self.tlist loadTopLayoutTable];
    }
    return _tlist;
}

- (void) refreshEditBtn {

	if ([self.tlist.topLayoutNames count] == 0) {
		if (self.navigationItem.leftBarButtonItem != nil) {
			self.navigationItem.leftBarButtonItem = nil;
		}
	} else {
		if (self.navigationItem.leftBarButtonItem == nil) {
			self.navigationItem.leftBarButtonItem = self.editBtn;
			//[editBtn release];
		}
	}
    
}

- (BOOL) samplesNeeded {
    NSString *sql = @"select val from info where name = 'samples_version'";
    int rslt = [self.tlist toQry2Int:sql];
    DBGLog(@"samplesNeeded if %d != %d",SAMPLES_VERSION,rslt);
    return (SAMPLES_VERSION != rslt);
}

- (BOOL) demosNeeded {
    NSString *sql = @"select val from info where name = 'demos_version'";
    int rslt = [self.tlist toQry2Int:sql];
    DBGLog(@"demosNeeded if %d != %d",DEMOS_VERSION,rslt);
#if !RELEASE
    //rslt=0;
    if (0 == rslt) {
        DBGLog(@"forcing demosNeeded");
    }
#endif
    return (DEMOS_VERSION != rslt);
}

- (void) handlePrefs {
    
    NSUserDefaults *sud = [NSUserDefaults standardUserDefaults];
    [sud synchronize];

    BOOL resetPassPref = [sud boolForKey:@"reset_password_pref"];
    BOOL reloadSamplesPref = [sud boolForKey:@"reload_sample_trackers_pref"];
    
    [rTracker_resource setSeparateDateTimePicker:[sud boolForKey:@"separate_date_time_pref"]];
    [rTracker_resource setRtcsvOutput:[sud boolForKey:@"rtcsv_out_pref"]];
    [rTracker_resource setSavePrivate:[sud boolForKey:@"save_priv_pref"]];

    //[rTracker_resource setHideRTimes:[sud boolForKey:@"hide_rtimes_pref"]];
    //[rTracker_resource setSCICount:(NSUInteger)[sud integerForKey:@"shortcut_count_pref"]];
    
    [rTracker_resource setToldAboutSwipe:[sud boolForKey:@"toldAboutSwipe"]];
    [rTracker_resource setToldAboutNotifications:[sud boolForKey:@"toldAboutNotifications"]];
    [rTracker_resource setAcceptLicense:[sud boolForKey:@"acceptLicense"]];
    
    //DBGLog(@"entry prefs-- resetPass: %d  reloadsamples: %d",resetPassPref,reloadSamplesPref);

    if (resetPassPref) [self.privacyObj resetPw];
    
    InstallSamples = NO;
    InstallDemos = NO;
    if (reloadSamplesPref) {
        InstallSamples = YES;
        InstallDemos = YES;
    } else {
        if ([self samplesNeeded]) {
            InstallSamples = YES;
        }
        if ([self demosNeeded]) {
            //[self deleteDemos];
            InstallDemos = YES;
        }
    }

    DBGLog(@"InstallSamples %d  InstallDemos %d",InstallSamples,InstallDemos);
    
    if (resetPassPref)
        [sud setBool:NO forKey:@"reset_password_pref"];
    if (reloadSamplesPref)
        [sud setBool:NO forKey:@"reload_sample_trackers_pref"];
    
    self.initialPrefsLoad = NO;
    
    [sud synchronize];
/*
#if DEBUGLOG
    resetPassPref = [sud boolForKey:@"reset_password_pref"];
    reloadSamplesPref = [sud boolForKey:@"reload_sample_trackers_pref"];
    
    DBGLog(@"exit prefs-- resetPass: %d  reloadsamples: %d",resetPassPref,reloadSamplesPref);
#endif
*/
}

/*
 refreshView:
   loadInputFiles:
     if files to load
        thread:
          load demos, samples, plist files
          refreshViewPart2
          thread:
            load csv files
            if rtcsv (might add trackers)
               refreshViewPart2
     else
        refreshViesPart2
  */
- (void) refreshView {
    
    if (0 != OSAtomicTestAndSet(0, &(_refreshLock))) {
        // wasn't 0 before, so we didn't get lock, so leave because refresh already in process
        return;
    }
            
    //DBGLog(@"refreshView");
	[self scrollState];

    [self handlePrefs];
    
    [self loadInputFiles];  // do this here as restarts are infrequent and prv change may enable to read more files -- calls refreshViewPart2
    
    [self countScheduledReminders];
    
}

#if ADVERSION
// handle rtPurchasedNotification
- (void) updatePurchased:(NSNotification*)n {
    if (n) {
        [rTracker_resource doQuickAlert:@"Purchase Successful" msg:@"Thank you!" delay:2 vc:self];
    }

    if (nil != _adSupport) {
        if ([self.adSupport.bannerView isDescendantOfView:self.view]) {
            [self.adSupport.bannerView removeFromSuperview];
        }
        self.adSupport = nil;
    }
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[rTracker_resource getLaunchImageName]]];
    CGRect tableFrame = bg.frame;
    tableFrame.size.height = [rTracker_resource get_visible_size:self].height;// - ( 2 * statusBarHeight ) ;
    [self.tableView setFrame:tableFrame];
    self.tableView.backgroundView = bg;
    [self.tableView setNeedsDisplay];
    //[self.tableView reloadData];
}
#endif

- (void)viewWillAppear:(BOOL)animated {
    
    DBGLog(@"rvc: viewWillAppear privacy= %d", [privacyV getPrivacyValue]);
    [self countScheduledReminders];
    
    [privacyV restorePriv];
    
    [self.navigationController setToolbarHidden:NO animated:NO];

#if ADVERSION
    if (![rTracker_resource getPurchased]) {
#if !DISABLE_ADS
        [self.adSupport initBannerView:self];
        [self.view addSubview:self.adSupport.bannerView];
#endif
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updatePurchased:)
                                                     name:rtPurchasedNotification
                                                   object:nil];
    } else if (_adSupport) {
        [self updatePurchased:nil];
    }
#endif

    [super viewWillAppear:animated];
}

BOOL stashAnimated;

- (void) fixFileProblem:(NSInteger)choice {
    NSString *docsDir = [rTracker_resource ioFilePath:nil access:YES];
    
    NSFileManager *localFileManager=[NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:docsDir];
    
    NSString *file;
    
    while ((file = [dirEnum nextObject])) {
        if ([[file pathExtension] isEqualToString: @"rtrk_reading"]) {
            NSError *err;
            NSString *target;
            target = [docsDir stringByAppendingPathComponent:file];
            
            if (0 == choice) {   // delete it
                [rTracker_resource deleteFileAtPath:target];
            } else {                  // try again -- rename from .rtrk_reading to .rtrk
                NSString *newTarget;
                newTarget = [target stringByReplacingOccurrencesOfString:@"rtrk_reading" withString:@"rtrk"];
                if ([localFileManager moveItemAtPath:target toPath:newTarget error:&err] != YES) {
                    DBGLog(@"Error on move %@ to %@: %@",target, newTarget, err);
                    //DBGLog(@"Unable to move file: %@", [err localizedDescription]);
                }
            }
        }
    }
    
    [self viewDidAppearRestart];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self fixFileProblem:buttonIndex];
}

- (void) viewDidAppearRestart {
	[self refreshView];

#if ADVERSION
    if (![rTracker_resource getPurchased]) {
#if !DISABLE_ADS
        [self.adSupport layoutAnimated:self tableview:self.tableView animated:NO];
#endif
    }
#endif
   
    [super viewDidAppear:stashAnimated];
}

- (void) doOpenTrackerRejectable:(NSNumber*)nsnTid {
    [self openTracker:[nsnTid intValue] rejectable:YES];
}

- (void) doOpenTracker:(NSNumber*)nsnTid {
    [self openTracker:[nsnTid intValue] rejectable:NO];
}


- (void) doRejectableTracker {
    //DBGLog(@"stashedTIDs= %@",self.stashedTIDs);
    NSNumber *nsntid = [self.stashedTIDs lastObject];
    [self performSelectorOnMainThread:@selector(doOpenTrackerRejectable:) withObject:nsntid waitUntilDone:YES];
    [self.stashedTIDs removeLastObject];
}

- (void) viewDidAppear:(BOOL)animated {
    
    //DBGLog(@"rvc: viewDidAppear privacy= %d", [privacyV getPrivacyValue]);
    
    if (! self.readingFile) {
        if (0 < [self.stashedTIDs count]) {
            [self doRejectableTracker];
        } else {
            NSString *docsDir = [rTracker_resource ioFilePath:nil access:YES];
            NSFileManager *localFileManager=[NSFileManager defaultManager];
            NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:docsDir];
            
            NSString *file;
            
            while ((file = [dirEnum nextObject])) {
                if ([[file pathExtension] isEqualToString: @"rtrk_reading"]) {
                    NSString *fname = [file lastPathComponent];
                    NSString *rtrkName = [fname stringByDeletingPathExtension];
                    NSString *title = @"Problem reading .rtrk file?";
                    NSString *msg = [ NSString stringWithFormat:@"There was a problem while loading the %@ rtrk file",rtrkName ];
                    NSString *btn0 = @"Delete it";
                    NSString *btn1 = @"Try again";
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                                   message:msg
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:btn0 style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) { [self fixFileProblem:0]; }];
                    UIAlertAction* retryAction = [UIAlertAction actionWithTitle:btn1 style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction * action) { [self fixFileProblem:1]; }];
                    
                    [alert addAction:deleteAction];
                    [alert addAction:retryAction];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                    
                }
            }
        }
    } else {
        //if (self.readingFile) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
    stashAnimated = animated;
    [self viewDidAppearRestart];
    
    // [super viewDidApeear] called in [self viewDidAppearRestart]
}


- (void)viewWillDisappear:(BOOL)animated {
    DBGLog(@"rvc viewWillDisappear");

#if ADVERSION
    //unregister for purchase notices
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:rtPurchasedNotification
                                                    object:nil];
#endif
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = [self pendingNotificationCount];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	
	DBGWarn(@"rvc didReceiveMemoryWarning");
	// Release any cached data, images, etc that aren't in use.

    [super didReceiveMemoryWarning];


}

#pragma mark -
#pragma mark button accessor getters

- (void) privBtnSetImg:(UIButton*)pbtn noshow:(BOOL)noshow {
    //BOOL shwng = (self.privacyObj.showing == PVNOSHOW); 
    BOOL minprv = ( [privacyV getPrivacyValue] > MINPRIV );
    NSString *btnImg = (( noshow ? ( minprv ? @"shadeview-button-7.png" : @"closedview-button-7.png" )
                                 : ( minprv ? @"shadeview-button-blue-7.png" : @"closedview-button-blue-7.png" ) ));

    dispatch_async(dispatch_get_main_queue(), ^(void){
        [pbtn setImage:[UIImage imageNamed:btnImg] forState:UIControlStateNormal];
    });
}

- (UIBarButtonItem *) privateBtn {
    //
	if (_privateBtn == nil) {
        UIButton *pbtn = [[UIButton alloc] init];
        [pbtn setImage:[UIImage imageNamed:(@"closedview-button-7.png")]
              forState:UIControlStateNormal];
        pbtn.frame = CGRectMake(0, 0, ( pbtn.currentImage.size.width * 1.5 ), pbtn.currentImage.size.height);
        [pbtn addTarget:self action:@selector(btnPrivate) forControlEvents:UIControlEventTouchUpInside];
        _privateBtn = [[UIBarButtonItem alloc]
                      initWithCustomView:pbtn];
        [self privBtnSetImg:(UIButton*)_privateBtn.customView noshow:YES];
	} else {
        BOOL noshow=YES;
        if (_privacyObj)  // don't instantiate unless needed
            noshow = (PVNOSHOW == self.privacyObj.showing); 
        if ((! noshow) 
            && (PWKNOWPASS == self.privacyObj.pwState)) {
            //DBGLog(@"unlock btn");
            [(UIButton *)_privateBtn.customView
             setImage:[UIImage imageNamed:(@"fullview-button-blue-7.png")]
             forState:UIControlStateNormal];
        } else {
            //DBGLog(@"lock btn");
            [self privBtnSetImg:(UIButton *)_privateBtn.customView noshow:noshow];
        }
    }


	return _privateBtn;
}

- (UIBarButtonItem *) helpBtn {
	if (_helpBtn == nil) {
		_helpBtn = [[UIBarButtonItem alloc]
                      initWithTitle:@"Help"
                      style:UIBarButtonItemStylePlain
                      target:self
                      action:@selector(btnHelp)];
	} 
	return _helpBtn;
}


- (UIBarButtonItem *) addBtn {
	if (_addBtn == nil) {
        _addBtn = [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                  //initWithTitle:@"New tracker"
                  //style:UIBarButtonItemStylePlain 
                 target:self
                 action:@selector(btnAddTracker)];

        [_addBtn setStyle:UIBarButtonItemStyleDone];
        
	} 
	return _addBtn;
}

- (UIBarButtonItem *) editBtn {
	if (_editBtn == nil) {
        _editBtn = [[UIBarButtonItem alloc]
                   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                   //initWithTitle:@"Edit trackers"
                   //style:UIBarButtonItemStylePlain 
                   target:self
                   action:@selector(btnEdit)];
    
        [_editBtn setStyle:UIBarButtonItemStylePlain];
	}
	return _editBtn;
}


- (UIBarButtonItem *) flexibleSpaceButtonItem {
	if (_flexibleSpaceButtonItem == nil) {
		_flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                target:nil action:nil];
	} 
	return _flexibleSpaceButtonItem;
}

/*
 - (UIBarButtonItem *) multiGraphBtn {
	if (multiGraphBtn == nil) {
		multiGraphBtn = [[UIBarButtonItem alloc]
					  initWithTitle:@"Multi-Graph"
					  style:UIBarButtonItemStylePlain
					  target:self
					  action:@selector(btnMultiGraph)];
	}
	return multiGraphBtn;
}
*/

#pragma mark -

- (privacyV*) privacyObj {
	if (_privacyObj == nil) {
		_privacyObj = [[privacyV alloc] initWithParentView:self.view];
        _privacyObj.parent = self;
	}
	_privacyObj.tob = (id) self.tlist;  // not set at init
	return _privacyObj;
}

- (NSMutableArray*) stashedTIDs {
    if (_stashedTIDs == nil) {
        _stashedTIDs = [[NSMutableArray alloc] init];
    }
    return  _stashedTIDs;
}

- (void) countScheduledReminders {
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray *notifications) {
        [self.scheduledReminderCounts removeAllObjects];
        
        for (int i=0;
             i<[notifications count];
             i++)
        {
            UNNotificationRequest *oneEvent = notifications[i];
            NSDictionary *userInfoCurrent = oneEvent.content.userInfo;
            DBGLog(@"%d uic: %@",i,userInfoCurrent);
            NSNumber *tid =userInfoCurrent[@"tid"];
            int c = [(self.scheduledReminderCounts)[tid] intValue];
            c++;
            (self.scheduledReminderCounts)[tid] = @(c);
        }
    }];

}

- (NSMutableDictionary*) scheduledReminderCounts {
    if (nil == _scheduledReminderCounts) {
        _scheduledReminderCounts = [[NSMutableDictionary alloc]init];
    }
    return _scheduledReminderCounts;
}

#pragma mark -
#pragma mark button action methods

- (void) btnAddTracker {
    if (PVNOSHOW != self.privacyObj.showing) {
        return;
    }
#if ADVERSION
    if (![rTracker_resource getPurchased]) {
        if (ADVER_TRACKER_LIM <= [self.tlist.topLayoutIDs count]) {
            //[rTracker_resource buy_rTrackerAlert];
            [rTracker_resource replaceRtrackerA:self];
            return;
        }
    }
#endif
	addTrackerController *atc = [[addTrackerController alloc] initWithNibName:@"addTrackerController" bundle:nil ];
	atc.tlist = self.tlist;
	[self.navigationController pushViewController:atc animated:YES];
    //[rTracker_resource myNavPushTransition:self.navigationController vc:atc animOpt:UIViewAnimationOptionTransitionCurlUp];
    
}

- (IBAction)btnEdit {
    
    if (PVNOSHOW != self.privacyObj.showing) {
        return;
    }
    configTlistController *ctlc;
        ctlc = [[configTlistController alloc] initWithNibName:@"configTlistController" bundle:nil ];
	ctlc.tlist = self.tlist;
	[self.navigationController pushViewController:ctlc animated:YES];
}
	
- (void)btnMultiGraph {
	DBGLog(@"btnMultiGraph was pressed!");
}

- (void)btnPrivate {
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];  // ScrollToTop
	[self.privacyObj togglePrivacySetter ];
    if (PVNOSHOW == self.privacyObj.showing)
        [self refreshView];
}

- (void) btnHelp {
#if ADVERSION
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://rob-miller.github.io/rTracker/rTracker/iPhone/replace_rTrackerA.html"]];
#else
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://rob-miller.github.io/rTracker/rTracker/iPhone/userGuide/"]];
#endif
}

- (void)btnPay {
	DBGLog(@"btnPay was pressed!");
	
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.tlist.topLayoutNames count];
}

- (NSInteger) pendingNotificationCount {
    NSInteger erc=0,src=0;
    for (NSNumber *nsn in self.tlist.topLayoutReminderCount) {
        erc += [nsn integerValue];
    }
    for (NSNumber *tid in self.scheduledReminderCounts) {
        src += [(self.scheduledReminderCounts)[tid] integerValue];
    }
    
    return (erc > src ? erc-src : 0);
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //DBGLog(@"rvc table cell at index %d label %@",[indexPath row],[tlist.topLayoutNames objectAtIndex:[indexPath row]]);
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        cell.backgroundColor = [UIColor clearColor];
    }
    
	// Configure the cell.
	NSUInteger row = [indexPath row];
    NSNumber *tid = (self.tlist.topLayoutIDs)[row];
    NSMutableAttributedString *cellLabel = [[NSMutableAttributedString alloc] init];

    int erc = [(self.tlist.topLayoutReminderCount)[row] intValue];
    int src = [(self.scheduledReminderCounts)[tid] intValue];
    DBGLog(@"src: %d  erc:  %d  %@ (%@)",src,erc, (self.tlist.topLayoutNames)[row], tid);
    //NSString *formatString = @"%@";
    //UIColor *bg = [UIColor clearColor];
    if (erc != src) {
        //formatString = @"> %@";
        //bg = [UIColor redColor];
        [cellLabel appendAttributedString:
         [[NSAttributedString alloc] initWithString:@"➜ " attributes:@{NSForegroundColorAttributeName: [UIColor redColor],
                                                                       NSFontAttributeName: [UIFont boldSystemFontOfSize:[UIFont labelFontSize]]} ]];
        
    }
    //DBGLog(@"erc= %d  src= %d",erc,src);
    [cellLabel appendAttributedString:[[NSAttributedString alloc]initWithString:(self.tlist.topLayoutNames)[row]]];
    cell.textLabel.attributedText = cellLabel;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tn;
    NSUInteger row = [indexPath row];
    if (NSNotFound != row) {
        tn = (self.tlist.topLayoutNames)[row];
    } else {
        tn = @"Sample";
    }
    CGSize tns = [tn sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}];
    return tns.height + (2*MARGIN);
}

- (BOOL) exceedsPrivacy:(NSInteger)tid {
    return ([privacyV getPrivacyValue] < [self.tlist getPrivFromLoadedTID:tid]);
}
- (void)openTracker:(NSInteger)tid rejectable:(BOOL)rejectable {
    
    if ([self exceedsPrivacy:tid]) {
        return;
    }
    
    UIViewController *topController = [self.navigationController.viewControllers lastObject];
    SEL rtSelector = NSSelectorFromString(@"rejectTracker");
    
    if ( [topController respondsToSelector:rtSelector] ) {  // top controller is already useTrackerController, is it this tracker?
        if (tid == ((useTrackerController*)topController).tracker.toid) {
            return;
        }
    }
    
    trackerObj *to = [[trackerObj alloc] init:tid];
	[to describe];

	useTrackerController *utc = [[useTrackerController alloc] init];
    utc.tracker = to;
    utc.rejectable = rejectable;
    utc.tlist = self.tlist;  // required so reject can fix topLevel list
    utc.saveFrame = self.view.frame; // self.tableView.frame; //  view.frame;
    utc.rvcTitle = self.title;
#if ADVERSION
#if !DISABLE_ADS
    if (![rTracker_resource getPurchased]) {
        utc.adSupport = self.adSupport;
    } else {
        utc.adSupport = nil;
    }
#endif
#endif
    
    [self.navigationController pushViewController:utc animated:YES];
	
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (PVNOSHOW != self.privacyObj.showing) {
        return;
    }
    
	//NSUInteger row = [indexPath row];
	//DBGLog(@"selected row %d : %@", row, [self.tlist.topLayoutNames objectAtIndex:row]);
    [tableView cellForRowAtIndexPath:indexPath].selected=NO;
    [self openTracker:[self.tlist getTIDfromIndex:[indexPath row]] rejectable:NO];
	
}

@end

