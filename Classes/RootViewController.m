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

@implementation RootViewController

@synthesize tlist, refreshLock;
@synthesize privateBtn, helpBtn, privacyObj, addBtn, editBtn, flexibleSpaceButtonItem, initialPrefsLoad,stashedPriv, readingFile, stashedTIDs;
//openUrlLock, inputURL,

#pragma mark -
#pragma mark core object methods and support

- (void)dealloc {
	
	DBGLog(@"rvc dealloc");
	self.tlist = nil;
	[tlist release];
	//[privateBtn release]; // saved to change image
    self.addBtn = nil;
    [addBtn release];
    self.editBtn = nil;
    [editBtn release];
    self.stashedPriv=nil;
    [stashedPriv release];
    //self.inputURL = nil;
    //[inputURL release];
    self.stashedTIDs = nil;
    [stashedTIDs release];
    
    [super dealloc];
}

/*
- (void)applicationWillTerminate:(NSNotification *)notification {
	DBGLog(@"rvc: app will terminate");
	// close trackerList
	
}
*/

#pragma mark -
#pragma mark load CSV files waiting for input

static int csvLoadCount;
static int plistLoadCount;
static int csvReadCount;
static int plistReadCount;
static BOOL InstallSamples;

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
    [parser release];
    DBGLog(@"csv parser done %@",to.trackerName);
    
    //[to reloadVOtable];
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
        [rTracker_resource alert:@"No timestamp column" msg:[NSString stringWithFormat:@"The file %@ has been rejected by the CSV loader as it does not have 'timestamp' as the first column.",fname]];
    } else if (to.csvReadFlags & CSVNOREADDATE) {
        [rTracker_resource alert:@"Date format problem" msg:[NSString stringWithFormat:@"Some records in the file %@ were ignored because timestamp dates like %@ are not compatible with your device's calendar settings.  Please modify the file or change your international locale preferences in System Settings and try again.",fname,to.csvProblem]];
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

    [self jumpMaxPriv];
    
    while ((file = [dirEnum nextObject])) {
        trackerObj *to = nil;
        NSString *fname = [file lastPathComponent];
        NSString *tname = nil;
        NSRange inmatch;
        BOOL validMatch=NO;
        NSString *loadObj;
        
        if ([[file pathExtension] isEqualToString: @"csv"]) {
            loadObj = @"csv";
            inmatch = [fname rangeOfString:@"_in.csv" options:NSBackwardsSearch|NSAnchoredSearch];
            //DBGLog(@"consider input: %@",fname);
            
            if ((inmatch.location != NSNotFound) && (inmatch.length == 7)) {  // matched all 7 chars of _in.csv at end of file name  (must test not _out.csv)
                validMatch=YES;
            }
            
        } else if ([[file pathExtension] isEqualToString: @"rtcsv"]) {
            rtcsv=YES;
            loadObj = @"rtcsv";
            
            inmatch = [fname rangeOfString:@".rtcsv" options:NSBackwardsSearch|NSAnchoredSearch];
            //DBGLog(@"consider input: %@",fname);
            
            if ((inmatch.location != NSNotFound) && (inmatch.length == 6)) {  // matched all 6 chars of .rtcsv at end of file name  (unlikely to fail but need inmatch to get tname)
                validMatch=YES;
            }
        }

        if (validMatch) {
            DBGLog(@"%@ load input: %@ as %@",loadObj,fname,tname);

            tname = [fname substringToIndex:inmatch.location];
            int tid = [self.tlist getTIDfromName:tname];
            if (tid) {
                to = [[trackerObj alloc]init:tid];
                DBGLog(@" found existing tracker tid %d with matching name",tid);
            } else if (rtcsv) {
                to = [[trackerObj alloc] init];
                to.trackerName = tname;
                to.toid = [self.tlist getUnique];
                [to saveConfig];
                [self.tlist addToTopLayoutTable:to];
                newRtcsvTracker = YES;
                DBGLog(@"created new tracker for rtcsv, id= %d",to.toid);
            }

            if (nil != to) {
                [self performSelectorOnMainThread:@selector(startLoadActivityIndicator:) withObject:[NSString stringWithFormat:@"loading %@ %@",tname,loadObj] waitUntilDone:NO];

                NSString *target = [docsDir stringByAppendingPathComponent:file];
                NSString *csvString = [NSString stringWithContentsOfFile:target encoding:NSUTF8StringEncoding error:NULL];
                
                [rTracker_resource stashProgressBarMax:[rTracker_resource countLines:csvString]];

                if (csvString)
                {
                    [UIApplication sharedApplication].idleTimerDisabled = YES;
                    [self doCSVLoad:csvString to:to fname:fname];
                    [UIApplication sharedApplication].idleTimerDisabled = NO;

                    [rTracker_resource deleteFileAtPath:target];
                }
                
                [to release];
                [rTracker_resource finishActivityIndicator:self.view navItem:nil disable:NO];
            }
            
        }
        
    }
    
    [self restorePriv];
    
    if (newRtcsvTracker) {
        [self refreshViewPart2];
    }
}


/*

if ([[file pathExtension] isEqualToString: @"csv"]) {
 
    inmatch = [fname rangeOfString:@"_in.csv" options:NSBackwardsSearch|NSAnchoredSearch];
    //DBGLog(@"consider input: %@",fname);
 
    if ((inmatch.location != NSNotFound) && (inmatch.length == 7)) {  // matched all 7 chars of _in.csv at end of file name
        validMatch=YES;
 
        tname = [fname substringToIndex:inmatch.location];
        DBGLog(@"csv load input: %@ as %@",fname,tname);
        //int ndx=0;
        
        for (NSString *tracker in self.tlist.topLayoutNames) {
            if ([tracker isEqualToString:tname]) {
                DBGLog(@"match to: %@",tracker);
                to = [[trackerObj alloc] init:[self.tlist getTIDfromName:tname]];  // accept will take first if multiple with same name
                
                NSString *target = [docsDir stringByAppendingPathComponent:file];
                NSString *csvString = [NSString stringWithContentsOfFile:target encoding:NSUTF8StringEncoding error:NULL];
                
                [rTracker_resource stashProgressBarMax:[rTracker_resource countLines:csvString]];
                
                if (csvString)
                {
                    [self doCSVLoad:csvString to:to fname:fname];
                    [rTracker_resource deleteFileAtPath:target];
                    
                }
                
                [to release];
                
                //ndx++;
            }
        }
    }
} else if ([[file pathExtension] isEqualToString: @"rtcsv"]) {
    rtcsv=YES;
    inmatch = [fname rangeOfString:@".rtcsv" options:NSBackwardsSearch|NSAnchoredSearch];
    //DBGLog(@"consider input: %@",fname);
    
    if ((inmatch.location != NSNotFound) && (inmatch.length == 6)) {  // matched all 6 chars of .rtcsv at end of file name  (unlikely to fail)
        validMatch=YES;
        
        NSString *tname = [fname substringToIndex:inmatch.location];
        
        
        
        [self performSelectorOnMainThread:@selector(startLoadCsvActivityIndicator:) withObject:tname waitUntilDone:NO];
        
        DBGLog(@"rtcsv load input: %@ as %@",fname,tname);
        trackerObj *to;
        int tid = [self.tlist getTIDfromName:tname];
        if (tid) {
            to = [[trackerObj alloc]init:tid];
            DBGLog(@" found existing tracker tid %d with matching name",tid);
        } else {
            to = [[trackerObj alloc] init];
            to.trackerName = tname;
            to.toid = [self.tlist getUnique];
            [to saveConfig];
            [self.tlist addToTopLayoutTable:to];
            newRtcsvTracker = YES;
        }
        
        NSString *target = [docsDir stringByAppendingPathComponent:file];
        
        NSString *csvString = [NSString stringWithContentsOfFile:target encoding:NSUTF8StringEncoding error:NULL];
        
        [rTracker_resource stashProgressBarMax:[rTracker_resource countLines:csvString]];
        
        if (csvString)
        {
            [self doCSVLoad:csvString to:to fname:fname];
            [rTracker_resource deleteFileAtPath:target];
            
        }
        
        [to release];
        
        [rTracker_resource finishActivityIndicator:self.view navItem:nil disable:NO];
        
        
    }
}
}
*/







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
    NSNumber *newTID = [tdict objectForKey:@"tid"];
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
        [rTracker_resource stashTracker:matchTID];                            // make copy of current tracker so can reject newTID later
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
    
    [inputTO release];
    
    return newTIDi;
}

#pragma mark load .plists and .rtrks for input trackers

- (int) handleOpenFileURL:(NSURL*)url tname:(NSString*)tname {
    NSDictionary *tdict = nil;
    NSDictionary *dataDict = nil;
    int tid;
    NSString *objName;
    
    DBGLog(@"open url %@",url);
    /*
     // was needed when called for arbitrary url
    if ([@"rtcsv" isEqualToString:[url pathExtension]]) {
        [self loadTrackerCsvFiles];
        return 0;
    }
    */
    
    [self jumpMaxPriv];
    
    if (nil != tname) {  // if tname set it is just a plist
        tdict = [NSDictionary dictionaryWithContentsOfURL:url];
        objName = @"plist";
    } else {  // else is an rtrk
        NSDictionary *rtdict = [NSDictionary dictionaryWithContentsOfURL:url];
        tname = [rtdict objectForKey:@"trackerName"];
        tdict = [rtdict objectForKey:@"configDict"];
        dataDict = [rtdict objectForKey:@"dataDict"];
        objName = @"rtrk";
    }

    int c = [(NSArray *)[tdict objectForKey:@"valObjTable"] count];
    int c2 = (nil == dataDict ? 0 : [dataDict count]);
    if ((c>20) || (c2>20))
        [self performSelectorOnMainThread:@selector(startLoadActivityIndicator:) withObject:[NSString stringWithFormat:@"loading %@ %@",tname,objName] waitUntilDone:NO];
    
    DBGLog(@"ltd enter dict= %d",[tdict count]);
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
        [to release];
    }

    DBGLog(@"ltd/ldd finish");
    
    //[self.privacyObj setPrivacyValue:currPriv];                           // restore after jump to max
    [self restorePriv];
    
    [rTracker_resource deleteFileAtPath:[url path]];
    //if ((c>20) || (c2>20))
        [rTracker_resource finishActivityIndicator:self.view navItem:nil disable:NO];
    
    
    return tid;
}


- (BOOL) loadTrackerPlistFiles {
    // called on refresh, loads any _in.plist files as trackers
    // also called if any .rtrk files exist
    DBGLog(@"loadTrackerPlistFiles");
    int rtrkTid=0;
    
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
/*
            NSRange inmatch = [fname rangeOfString:@"_out.rtrk" options:NSBackwardsSearch|NSAnchoredSearch];
            //DBGLog(@"consider input: %@",fname);
            if ((inmatch.location != NSNotFound) && (inmatch.length == 9)) {  // matched all 9 chars of _out.rtrk at end of file name
 
            } else {
*/
                [filesToProcess addObject:file];
/*
            }
*/
        }
    }
    
    for (file in filesToProcess) {
        //NSString *tname = nil;
        NSString *target;
        NSString *newTarget;
        BOOL plistFile=NO;
        
        NSString *fname = [file lastPathComponent];
        DBGLog(@"process input: %@",fname);

        target = [docsDir stringByAppendingPathComponent:file];
        
        newTarget = [[target stringByAppendingString:@"_reading"] stringByReplacingOccurrencesOfString:@"Documents/Inbox/" withString:@"Documents/"];
        
        NSError *err;
        if ([localFileManager moveItemAtPath:target toPath:newTarget error:&err] != YES)
            DBGErr(@"Error on move %@ to %@: %@",target, newTarget, err);
            //DBGLog(@"Unable to move file: %@", [err localizedDescription]);
        self.readingFile=YES;
        
        NSRange inmatch = [fname rangeOfString:@"_in.plist" options:NSBackwardsSearch|NSAnchoredSearch];

        [UIApplication sharedApplication].idleTimerDisabled = YES;

        if ((inmatch.location != NSNotFound) && (inmatch.length == 9)) {  // matched all 9 chars of _in.plist at end of file name
            rtrkTid = [self handleOpenFileURL:[NSURL fileURLWithPath:newTarget] tname:[fname substringToIndex:inmatch.location]];
            plistFile = YES;
            //TODO:need to delete stash file now!!!
            //tname = [fname substringToIndex:inmatch.location];
            //tdict = [NSDictionary dictionaryWithContentsOfFile:newTarget];
            // [rTracker_resource deleteFileAtPath:newTarget];  -- done by handleOpenFileUrl
        } else {   // .rtrk file
            rtrkTid = [self handleOpenFileURL:[NSURL fileURLWithPath:newTarget] tname:nil];
            /*
            NSDictionary *rtdict = [NSDictionary dictionaryWithContentsOfFile:newTarget];
            tname = [rtdict objectForKey:@"trackerName"];
            tdict = [rtdict objectForKey:@"configDict"];
            dataDict = [rtdict objectForKey:@"dataDict"];
             */
        }

        [UIApplication sharedApplication].idleTimerDisabled = NO;
        
        if (plistFile) {
            [rTracker_resource rmStashedTracker:0];  // 0 means rm last stashed tracker, in this case the one stashed by handleOpenFileURL
        } else {
            [self.stashedTIDs addObject:[NSNumber numberWithInt:rtrkTid]];
        }
        
        self.readingFile=NO;
    
        [rTracker_resource setProgressVal:(((float)plistReadCount)/((float)plistLoadCount))];
        plistReadCount++;

    }
/*
 old version below....
    
    while ((file = [dirEnum nextObject])) {
        if ([[file pathExtension] isEqualToString: @"plist"]) {
            NSString *fname = [file lastPathComponent];
            NSRange inmatch = [fname rangeOfString:@"_in.plist" options:NSBackwardsSearch|NSAnchoredSearch];
            DBGLog(@"consider input: %@",fname);
            
            if (inmatch.location == NSNotFound) {
                
            } else if (inmatch.length == 9) {  // matched all 9 chars of _in.plist at end of file name
                NSString *tname = [fname substringToIndex:inmatch.location];
                NSString *target = [docsDir stringByAppendingPathComponent:file];

                NSDictionary *tdict = [NSDictionary dictionaryWithContentsOfFile:target];

                // modified nov 2012 to use loadTrackerDict,
                // behaviour change is now handle matching trackerName

                [self loadTrackerDict:tdict tname:tname];
                didSomething= YES;

                [rTracker_resource setProgressVal:(((float)plistReadCount)/((float)plistLoadCount))];
                plistReadCount++;

                NSError *err;
                // apparently cannot rename in but can delete from application's Document folder
                // problem is during dirEnum ?
                BOOL rslt = [localFileManager removeItemAtPath:target error:&err];
                if (!rslt) {
                    DBGLog(@"Error: %@", err);
                }
            }
            
        } else if ([[file pathExtension] isEqualToString: @"rtrk"]) {
            NSString *target = [docsDir stringByAppendingPathComponent:file];            
            NSDictionary *rtdict = [NSDictionary dictionaryWithContentsOfFile:target];
            
        }
    }
 */
    [filesToProcess release];  // added 13 feb 2013
    // not the default manager [localFileManager release];
    return(rtrkTid);
}


- (void) doLoadCsvFiles {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self loadTrackerCsvFiles];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    // file load done, enable userInteraction
    
    [rTracker_resource finishProgressBar:self.view navItem:self.navigationItem disable:YES];
    
    // give up lock
    self.refreshLock = 0;
    
    DBGLog(@"csv data loaded, UI enabled, lock off");
    
    if (0< [self.stashedTIDs count]) {
        [self doRejectableTracker];
    }
    

    [pool drain];
    
    // thread finished
}

- (void) refreshViewPart2 {
    //DBGLog(@"entry");
	[self.tlist loadTopLayoutTable];
	[self.tableView reloadData];
    
    [self refreshEditBtn];
    [self refreshToolBar:YES];
    [self.view setNeedsDisplay];
    // no effect [self.tableView setNeedsDisplay];
}

- (void) doLoadInputfiles {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (InstallSamples) {
        [self loadSamples:YES];
        InstallSamples = NO;
    }
    
    if ([self loadTrackerPlistFiles]) {
        // this thread now completes updating rvc display of trackerList as next step is load csv data and trackerlist won't change
        [self.tlist loadTopLayoutTable];  // called again in refreshviewpart2, but need for re-order to set ranks
        [self.tlist reorderFromTLT];
    };
    
    [self refreshViewPart2];
    
    [NSThread detachNewThreadSelector:@selector(doLoadCsvFiles) toTarget:self withObject:nil];
    
    DBGLog(@"load plist thread finished, lock still on, UI still disabled");
    [pool drain];
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
    //if (!self.openUrlLock) {
        csvLoadCount = [self countInputFiles:@"_in.csv"];
        plistLoadCount = [self countInputFiles:@"_in.plist"];
        int rtrkLoadCount = [self countInputFiles:@".rtrk"];
        csvLoadCount += [self countInputFiles:@".rtcsv"];   //TODO: rtm here
        
        /*
         #if RTRK_EXPORT
         int rtrk_out = [self countInputFiles:@"_out.rtrk"];
         rtrkLoadCount -= rtrk_out;
         #endif
         */
        // handle rtrks as plist + csv, just faster if only has data or only has tracker def
        csvLoadCount += rtrkLoadCount;
        plistLoadCount += rtrkLoadCount;
        
        if (InstallSamples)
            plistLoadCount += [self loadSamples:NO];
        
        // set rvc:static numerators for progress bars
        csvReadCount=1;
        plistReadCount=1;
        
        if ( 0 < (plistLoadCount + csvLoadCount) ) {
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];  // ScrollToTop so can see bars
            // CGRect navframe = [[self.navigationController navigationBar] frame]; // (navframe.size.height + navframe.origin.y)
            [rTracker_resource startProgressBar:self.view navItem:self.navigationItem disable:YES  yloc:0.0f];
            
            [NSThread detachNewThreadSelector:@selector(doLoadInputfiles) toTarget:self withObject:nil];
            // lock stays on, userInteraction disabled, activityIndicator spinning,   give up and doLoadInputFiles() is in charge
            
            DBGLog(@"returning main thread, lock on, UI disabled, activity spinning,  files to load");
            return;
        }
    //}
    [self refreshViewPart2];
    // if here, no files to load, this thread set the lock and refresh is done now 
    self.refreshLock = 0;
    DBGLog(@"finished, no files to load - lock off");
    
    return;
}

- (int) loadSamples:(BOOL)doLoad {
    // called when handlePrefs decides is needed, copies plist files to documents dir
    // also called with doLoad=NO to just count
    // returns count
    NSBundle *bundle = [NSBundle mainBundle];
    NSArray *paths = [bundle pathsForResourcesOfType:@"plist" inDirectory:@"sampleTrackers"];
    int count=0;
    
    /* copy plists over version
    NSString *docsDir = [rTracker_resource ioFilePath:nil access:YES];
    NSFileManager *dfltManager = [NSFileManager defaultManager];
    */
    
    //DBGLog(@"paths %@",paths  );

        
    for (NSString *p in paths) {

        if (doLoad) {
            
            /*
             // copy plists over version -- doesn't handle conflicts
             NSString *fname = [p lastPathComponent];
             NSString *dest = [docsDir stringByAppendingFormat:@"/%@",fname];
             NSError *err = [[NSError alloc] init];
             if (!([dfltManager copyItemAtPath:p toPath:dest error:&err])) {
                DBGLog(@"copy failed  src= %@  dest= %@",p,docsDir);
                DBGLog(@"err: %@ %@ ",err.domain, err.helpAnchor);
             }
             */
            // /*
            // load now into trackerObj - needs progressBar
            NSDictionary *tdict = [NSDictionary dictionaryWithContentsOfFile:p];
            [self.tlist fixDictTID:tdict];
            trackerObj *newTracker = [[trackerObj alloc] initWithDict:tdict];
        
            [self.tlist deConflict:newTracker];  // add _n to trackerName so we don't overwrite .. TODO: shouldn't we just merge now?
        
            [newTracker saveConfig];
            [self.tlist addToTopLayoutTable:newTracker];
            [newTracker release];
            
            [rTracker_resource setProgressVal:(((float)plistReadCount)/((float)plistLoadCount))];                    
            plistReadCount++;
            
            // */
            
            DBGLog(@"finished loadSample on %@",p);
        }
        count++;
    }
    
    if (doLoad) {
        self.tlist.sql = [NSString stringWithFormat:@"insert or replace into info (val, name) values (%i,'samples_version')",SAMPLES_VERSION];
        [self.tlist toExecSql];
        self.tlist.sql = nil;
    }
    
    return(count);
}


#pragma mark -
#pragma mark view support

- (void)scrollState {
    if (privacyObj && self.privacyObj.showing != PVNOSHOW) { // don't instantiate if not there
        self.tableView.scrollEnabled = NO;
        //DBGLog(@"no");
    } else {
        self.tableView.scrollEnabled = YES;
        //DBGLog(@"yes");
    }
}

- (void) refreshToolBar:(BOOL)animated {
    //DBGLog(@"refresh tool bar, noshow= %d",(PVNOSHOW == self.privacyObj.showing));
    //DBGLog(@"refresh tool bar");
	[self setToolbarItems:[NSArray arrayWithObjects: 
                           //self.addBtn,
						   self.flexibleSpaceButtonItem,
                           self.helpBtn,
						   //self.payBtn, 
                           self.privateBtn, 
                           //self.multiGraphBtn, 
						   //self.flexibleSpaceButtonItem, 
						   nil] 
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
        if (![@"" isEqual: (w = [words objectAtIndex:i])]) {
            name = w;
        }
    }
    
    NSUInteger prodNdx=0;
    NSString *longName = [words objectAtIndex:0];
    
    for (prodNdx =0; prodNdx<c;prodNdx++) {
        if ( (NSOrderedSame == [@"iphone" caseInsensitiveCompare:[words objectAtIndex:prodNdx]])
            || (NSOrderedSame == [@"ipad" caseInsensitiveCompare:[words objectAtIndex:prodNdx]])
            || (NSOrderedSame == [@"ipod" caseInsensitiveCompare:[words objectAtIndex:prodNdx]])
            || (NSOrderedSame == [@"itouch" caseInsensitiveCompare:[words objectAtIndex:prodNdx]]) ) {
            break;
        }
    }
    if ((1 <= prodNdx) && (prodNdx < c)) {
        for (i=1;i<prodNdx;i++) {
            longName = [longName stringByAppendingFormat:@" %@",[words objectAtIndex:i]];
        }
    } else if ((0 == prodNdx) || (prodNdx >= c)) {
            longName = nil;
    }
    
    //name= @"aiiiiiiiiiiiiiiiiiiiiii";
    

    if ((nil == name)
        || ([name isEqualToString:@"iPhone"])
        || ([name isEqualToString:@"iPad"])
        || (0 == [name length])
#if NONAME
        || YES
#endif
        ){
        self.title = @"rTracker";
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
            CGSize namesize = [tn2 sizeWithFont:[UIFont boldSystemFontOfSize:20.0f]]; //[tname sizeWithFont:[UIFont boldSystemFontOfSize:20.0f]];
            CGFloat nameWidth = namesize.width;
            
            CGSize lnamesize = [ltn2 sizeWithFont:[UIFont boldSystemFontOfSize:20.0f]]; //[tname sizeWithFont:[UIFont boldSystemFontOfSize:20.0f]];
            CGFloat lnameWidth = lnamesize.width;
            
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

- (void)viewDidLoad {
	//DBGLog(@"rvc: viewDidLoad privacy= %d",[privacyV getPrivacyValue]);
    InstallSamples = NO;
    self.refreshLock = 0;
    
    if (kIS_LESS_THAN_IOS7) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;  //rm for ios7
    } else {
        //self.navigationController.navigationBar.translucent = YES;  // this makes buttons appear behind navbar
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bkgnd2-320-460.png"] forBarMetrics:UIBarMetricsDefault];
    }
    self.navigationItem.rightBarButtonItem = self.addBtn;
	//[self.addBtn release];
	    
    self.navigationItem.leftBarButtonItem = self.editBtn;
    //self.navigationItem.backBarButtonItem = self.editBtn;
	//[self.editBtn release];

    [self refreshToolBar:NO];
    
    self.stashedPriv = nil;
    //self.openUrlLock = NO;
    self.readingFile=NO;
    
    //DBGLog(@"dsmv= %@",[[UIDevice currentDevice] systemVersion] );
    
    //self.navigationController.toolbar.translucent = YES;
    //if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
    if (kIS_LESS_THAN_IOS7) {
        self.navigationController.toolbar.barStyle = UIBarStyleBlack;  // rm for ios7
    } else {
        self.navigationController.toolbar.translucent = YES;
        ///*  // not really translucent -- cannot see list behind toolbar
        [self.navigationController.toolbar setBackgroundImage:[UIImage imageNamed:@"bkgnd2-320-460.png"]
                                                forToolbarPosition:0
                                                barMetrics:UIBarMetricsDefault];
         //*/
        self.navigationController.toolbar.backgroundColor =[UIColor clearColor];

    }

    [self initTitle];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkgnd2-320-460.png"]];
    self.tableView.backgroundView = bg;
    [bg release];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	//[payBtn release];
	[privateBtn release];
    [helpBtn release];
	//[multiGraphBtn release];

    trackerList *tmptlist = [[trackerList alloc] init];
	self.tlist = tmptlist;
    //DBGLog(@"ttl rc= %d  s.tl rc= %d",[tmptlist retainCount],[self.tlist retainCount]);
    [tmptlist release];
    //DBGLog(@"ttl rc= %d  s.tl rc= %d",[tmptlist retainCount],[self.tlist retainCount]);
    
    //[self.tlist release];  // rtm 05 feb 2012 +1 for alloc, +1 when put in self.tlist

    
    //[self.tlist wipeOrphans];        // added 30.vii.13
    if ([self.tlist recoverOrphans]) {     // added 07.viii.13
        [rTracker_resource alert:@"Recovered files" msg:@"One or more tracker files were recovered, please delete if not needed."];
    }
    [self.tlist loadTopLayoutTable];  // was loadinputfiles
    
	/*
	UIApplication *app = [UIApplication sharedApplication];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(applicationWillTerminate:) 
												 name:UIApplicationWillTerminateNotification
											   object:app];
	
	 */
    
	//[self scrollState];
	[super viewDidLoad];
    
    //[self.privacyObj initLocation];
	
}

- (void) refreshEditBtn {

/*
	if ([self.tlist.topLayoutNames count] == 0) {
		if (self.navigationItem.backBarButtonItem != nil) {
			self.navigationItem.backBarButtonItem = nil;
		}
	} else {
		if (self.navigationItem.backBarButtonItem == nil) {
			self.navigationItem.backBarButtonItem = self.editBtn;
			//[editBtn release];
		}
	}
*/
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
    self.tlist.sql = @"select val from info where name = 'samples_version'";
    return (SAMPLES_VERSION != [self.tlist toQry2Int]);
}

- (void) handlePrefs {
    /*
    [[NSUserDefaults standardUserDefaults] synchronize];

    BOOL resetPassPref = [[NSUserDefaults standardUserDefaults] boolForKey:@"reset_password_pref"];
    BOOL reloadSamplesPref = [[NSUserDefaults standardUserDefaults] boolForKey:@"reload_sample_trackers_pref"];
    
    DBGLog(@"entry prefs-- resetPass: %d  reloadsamples: %d",resetPassPref,reloadSamplesPref);

    if (resetPassPref) [self.privacyObj resetPw];
    if (reloadSamplesPref) [self loadSamples];
    
    if (resetPassPref) 
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"reset_password_pref"];
    if (reloadSamplesPref)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"reload_sample_trackers_pref"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    resetPassPref = [[NSUserDefaults standardUserDefaults] boolForKey:@"reset_password_pref"];
    reloadSamplesPref = [[NSUserDefaults standardUserDefaults] boolForKey:@"reload_sample_trackers_pref"];
    
    DBGLog(@"exit prefs-- resetPass: %d  reloadsamples: %d",resetPassPref,reloadSamplesPref);
     */
    
    NSUserDefaults *sud = [NSUserDefaults standardUserDefaults];
    [sud synchronize];

    BOOL resetPassPref = [sud boolForKey:@"reset_password_pref"];
    BOOL reloadSamplesPref = [sud boolForKey:@"reload_sample_trackers_pref"];
    
    [rTracker_resource setSeparateDateTimePicker:[sud boolForKey:@"separate_date_time_pref"]];
    [rTracker_resource setRtcsvOutput:[sud boolForKey:@"rtcsv_out_pref"]];
    [rTracker_resource setSavePrivate:[sud boolForKey:@"save_priv_pref"]];
    
    //DBGLog(@"entry prefs-- resetPass: %d  reloadsamples: %d",resetPassPref,reloadSamplesPref);

    if (resetPassPref) [self.privacyObj resetPw];
    
    if (reloadSamplesPref
        || 
        (self.initialPrefsLoad && [self samplesNeeded]) 
        ) { 
        InstallSamples = YES;
    } else {
        //InstallSamples = NO;
    }
    
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

- (void) refreshView {
    
    if (0 != OSAtomicTestAndSet(0, &(refreshLock))) {
        // wasn't 0 before, so we didn't get lock, so leave because refresh already in process
        return;
    }
            
    //DBGLog(@"refreshView");
	[self scrollState];

    [self handlePrefs];
    
    [self loadInputFiles];  // do this here as restarts are infrequent and prv change may enable to read more files
    
}

- (void) jumpMaxPriv {
    if (nil == self.stashedPriv) {
        self.stashedPriv = [NSNumber numberWithInt:[privacyV getPrivacyValue]];
        DBGLog(@"stashed priv %@",self.stashedPriv);
    }

    [self.privacyObj setPrivacyValue:MAXPRIV];  // temporary max privacy level so see all
    DBGLog(@"priv jump!");
}
- (void) restorePriv {
    if (nil == self.stashedPriv) {
        return;
    }
    //if (YES == self.openUrlLock) {
    //    return;
    //}
    DBGLog(@"restore priv to %@",self.stashedPriv);
    [self.privacyObj setPrivacyValue:[self.stashedPriv intValue]];  // return to privacy level
    self.stashedPriv = nil;
    
}

- (void)viewWillAppear:(BOOL)animated {

	DBGLog(@"rvc: viewWillAppear privacy= %d", [privacyV getPrivacyValue]);
    //[self loadInputFiles];  // do this here as restarts are infrequent
	//[self refreshView];

    [self restorePriv];
    //[self refreshViewPart2];

    [super viewWillAppear:animated];
}

BOOL stashAnimated;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *docsDir = [rTracker_resource ioFilePath:nil access:YES];

    NSFileManager *localFileManager=[NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:docsDir];
    
    NSString *file;
    
    while ((file = [dirEnum nextObject])) {
        if ([[file pathExtension] isEqualToString: @"rtrk_reading"]) {
            NSError *err;
            NSString *target;
            target = [docsDir stringByAppendingPathComponent:file];
            
            if (0 == buttonIndex) {   // delete it
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

- (void) viewDidAppearRestart {
	[self refreshView];
    [super viewDidAppear:stashAnimated];
}

- (void) doOpenTrackerRejectable:(NSNumber*)nsnTid {
    [self openTracker:[nsnTid intValue] rejectable:YES];
}

- (void) doOpenTracker:(NSNumber*)nsnTid {
    [self openTracker:[nsnTid intValue] rejectable:NO];
}

/*
- (void) doOpenURL:(NSURL*)url {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //if (url != nil && [url isFileURL]) {
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    int tid = [self handleOpenFileURL:url tname:nil];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    if (0 != tid) {
        // get to root view controller, else get last view on stack
        //[rootController openTracker:tid rejectable:YES];
        [self performSelectorOnMainThread:@selector(doOpenTracker:) withObject:[NSNumber numberWithInt:tid] waitUntilDone:YES];
    }
    //}
    
    [self finishRvcActivityIndicator];
    //UIViewController *topController = [self.navigationController.viewControllers lastObject];
    //[rTracker_resource startActivityIndicator:topController.view navItem:nil disable:NO];
    
    self.openUrlLock=NO;
    self.inputURL=nil;
    [pool drain];
}


- (void) openInputURL {
    
    [self startRvcActivityIndicator];
    
    //UIViewController *topController = [self.navigationController.viewControllers lastObject];
    //[rTracker_resource startActivityIndicator:topController.view navItem:nil disable:NO];
    
    [NSThread detachNewThreadSelector:@selector(doOpenURL:) toTarget:self withObject:self.inputURL];
    //[self doOpenURL:url];
}
*/

- (void) doRejectableTracker {
    NSNumber *nsntid = [self.stashedTIDs lastObject];
    [self performSelectorOnMainThread:@selector(doOpenTrackerRejectable:) withObject:nsntid waitUntilDone:YES];
    [self.stashedTIDs removeLastObject];
}
- (void) viewDidAppear:(BOOL)animated {
	//DBGLog(@"rvc: viewDidAppear privacy= %d", [privacyV getPrivacyValue]);
    /*
    if (self.inputURL && !self.openUrlLock) {
        self.openUrlLock = YES;
        [self openInputURL];
    } else
*/

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
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problem reading .rtrk file?"
                                                                    message:[ NSString stringWithFormat:@"There was a problem while loading the %@ rtrk file",rtrkName ]
                                                                   delegate:self
                                                          cancelButtonTitle:@"Delete it"
                                                          otherButtonTitles:@"Try again",nil];
                    [alert show];
                    [alert release];
                }
            }
        }
    } else {
    //if (self.readingFile) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
    stashAnimated = animated;
    [self viewDidAppearRestart];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    DBGLog(@"rvc viewWillDisappear");

    //self.privacyObj.showing = PVNOSHOW;
    [super viewWillDisappear:animated];
}
*/


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	
	DBGWarn(@"rvc didReceiveMemoryWarning");
	// Release any cached data, images, etc that aren't in use.

    [super didReceiveMemoryWarning];


}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
	
	//DBGLog(@"rvc viewDidUnload");

	self.title = nil;
	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.leftBarButtonItem = nil;
	[self setToolbarItems:nil
				 animated:NO];
	
	self.tlist = nil;
	
	//DBGLog(@"pb rc= %d  mgb rc= %d", [self.privateBtn retainCount], [self.multiGraphBtn retainCount]);
    
    [super viewDidUnload];
	
}

- (void) startRvcActivityIndicator {
    //[rTracker_resource startActivityIndicator:self.view navItem:nil disable:NO];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];  // ScrollToTop so can see bars
    //CGRect navframe = [[self.navigationController navigationBar] frame];
    //[rTracker_resource startProgressBar:self.view navItem:self.navigationItem disable:YES  yloc:(navframe.size.height + navframe.origin.y)];
    [rTracker_resource startProgressBar:self.view navItem:self.navigationItem disable:YES  yloc:0.0f];
}
- (void) finishRvcActivityIndicator {
    //[rTracker_resource finishActivityIndicator:self.view navItem:nil disable:NO];
    [rTracker_resource finishProgressBar:self.view navItem:self.navigationItem disable:YES];
}


#pragma mark -
#pragma mark button accessor getters

/*
 - (UIBarButtonItem *) payBtn {
	if (payBtn == nil) {
		payBtn = [[UIBarButtonItem alloc]
					  initWithTitle:@"$"
					  style:UIBarButtonItemStyleBordered
					  target:self
					  action:@selector(btnPay)];
	}
	return payBtn;
}
*/

- (void) privBtnSetImg:(UIButton*)pbtn noshow:(BOOL)noshow {
    //BOOL shwng = (self.privacyObj.showing == PVNOSHOW); 
    BOOL minprv = ( [privacyV getPrivacyValue] > MINPRIV );
    
    NSString *btnImg = ( kIS_LESS_THAN_IOS7 ?
                        ( noshow ? ( minprv ? @"shadeview-button.png" : @"closedview-button.png" )
                         : ( minprv ? @"shadeview-button-blue.png" : @"closedview-button-blue.png" ) )
                        :
                        ( noshow ? ( minprv ? @"shadeview-button-7.png" : @"closedview-button-7.png" )
                         : ( minprv ? @"shadeview-button-blue-7.png" : @"closedview-button-blue-7.png" ) )
                        )
                        ;
    
    [pbtn setImage:[UIImage imageNamed:btnImg] forState:UIControlStateNormal];
}

- (UIBarButtonItem *) privateBtn {
    //
	if (privateBtn == nil) {
        // /*
        UIButton *pbtn = [[UIButton alloc] init];
        [pbtn setImage:[UIImage imageNamed:(kIS_LESS_THAN_IOS7 ? @"closedview-button.png" : @"closedview-button-7.png")]
              forState:UIControlStateNormal];
        pbtn.frame = CGRectMake(0, 0, ( pbtn.currentImage.size.width * 1.5 ), pbtn.currentImage.size.height);
        [pbtn addTarget:self action:@selector(btnPrivate) forControlEvents:UIControlEventTouchUpInside];
        privateBtn = [[UIBarButtonItem alloc]
                      initWithCustomView:pbtn];
        [self privBtnSetImg:(UIButton*)privateBtn.customView noshow:YES];
                [pbtn release];
	} else {
        BOOL noshow=YES;
        if (privacyObj)  // don't instantiate unless needed
            noshow = (PVNOSHOW == self.privacyObj.showing); 
        if ((! noshow) 
            && (PWKNOWPASS == self.privacyObj.pwState)) {
            //DBGLog(@"unlock btn");
            [(UIButton *)privateBtn.customView 
             setImage:[UIImage imageNamed:(kIS_LESS_THAN_IOS7 ? @"fullview-button-blue.png" : @"fullview-button-blue-7.png")]
             forState:UIControlStateNormal];
        } else {
            //DBGLog(@"lock btn");
            [self privBtnSetImg:(UIButton *)privateBtn.customView noshow:noshow];
        }
    }


	return privateBtn;
}

- (UIBarButtonItem *) helpBtn {
	if (helpBtn == nil) {
		helpBtn = [[UIBarButtonItem alloc]
                      initWithTitle:@"Help"
                      style:UIBarButtonItemStyleBordered
                      target:self
                      action:@selector(btnHelp)];
	} 
	return helpBtn;
}


- (UIBarButtonItem *) addBtn {
	if (addBtn == nil) {
        addBtn = [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                  //initWithTitle:@"New tracker"
                  //style:UIBarButtonItemStyleBordered 
                 target:self
                 action:@selector(btnAddTracker)];

        [addBtn setStyle:UIBarButtonItemStyleDone];
        
	} 
	return addBtn;
}

- (UIBarButtonItem *) editBtn {
	if (editBtn == nil) {
        editBtn = [[UIBarButtonItem alloc]
                   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                   //initWithTitle:@"Edit trackers"
                   //style:UIBarButtonItemStyleBordered 
                   target:self
                   action:@selector(btnEdit)];
    
        [editBtn setStyle:UIBarButtonItemStylePlain];
	}
	return editBtn;
}


- (UIBarButtonItem *) flexibleSpaceButtonItem {
	if (flexibleSpaceButtonItem == nil) {
		flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                target:nil action:nil];
	} 
	return flexibleSpaceButtonItem;
}

/*
 - (UIBarButtonItem *) multiGraphBtn {
	if (multiGraphBtn == nil) {
		multiGraphBtn = [[UIBarButtonItem alloc]
					  initWithTitle:@"Multi-Graph"
					  style:UIBarButtonItemStyleBordered
					  target:self
					  action:@selector(btnMultiGraph)];
	}
	return multiGraphBtn;
}
*/

- (privacyV*) privacyObj {
	if (privacyObj == nil) {
		privacyObj = [[privacyV alloc] initWithParentView:self.view];
        privacyObj.parent = (id*) self;
	}
	privacyObj.tob = (id) self.tlist;  // not set at init
	return privacyObj;
}

- (NSMutableArray*) stashedTIDs {
    if (stashedTIDs == nil) {
        stashedTIDs = [[NSMutableArray alloc] init];
    }
    return  stashedTIDs;
}

#pragma mark -
#pragma mark button action methods

- (void) btnAddTracker {
    if (PVNOSHOW != self.privacyObj.showing) {
        return;
    }
	addTrackerController *atc = [[addTrackerController alloc] initWithNibName:@"addTrackerController" bundle:nil ];
	atc.tlist = self.tlist;
	[self.navigationController pushViewController:atc animated:YES];
    //[rTracker_resource myNavPushTransition:self.navigationController vc:atc animOpt:UIViewAnimationOptionTransitionCurlUp];
    
	[atc release];
}

- (IBAction)btnEdit {
    
    if (PVNOSHOW != self.privacyObj.showing) {
        return;
    }
    configTlistController *ctlc;
    if(kIS_LESS_THAN_IOS7) {
        ctlc = [[configTlistController alloc] initWithNibName:@"configTlistController" bundle:nil ];
    } else {
        ctlc = [[configTlistController alloc] initWithNibName:@"configTlistController7" bundle:nil ];
    }
	ctlc.tlist = self.tlist;
	[self.navigationController pushViewController:ctlc animated:YES];
    
    //[rTracker_resource myNavPushTransition:self.navigationController vc:ctlc animOpt:UIViewAnimationOptionTransitionFlipFromLeft];
    
	[ctlc release];
}
	
- (void)btnMultiGraph {
	DBGLog(@"btnMultiGraph was pressed!");
}

- (void)btnPrivate {
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];  // ScrollToTop
	[self.privacyObj togglePrivacySetter ];
    /*
	if (PVNOSHOW != self.privacyObj.showing) {
		self.privateBtn.title = @"dismiss";
	} else {
		self.privateBtn.title = @"private";
		[self refreshView];
	}
     */
    if (PVNOSHOW == self.privacyObj.showing) 
        [self refreshView];
}

- (void) btnHelp {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.realidata.com/rTracker/iPhone/userGuide"]];
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


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //DBGLog(@"rvc table cell at index %d label %@",[indexPath row],[tlist.topLayoutNames objectAtIndex:[indexPath row]]);
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

        //UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkgnd-cell1-320-56.png"]]; // note needs to be @2x.png for retina
        //[cell setBackgroundView:bg];
        //[bg release];

        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	// Configure the cell.
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.tlist.topLayoutNames objectAtIndex:row]];  // gross but simplest offset option
    //cell.textLabel.backgroundColor = [UIColor clearColor];

    return cell;
}

- (void)openTracker:(int)tid rejectable:(BOOL)rejectable {
    //if (rejectable) {
    //    [self jumpMaxPriv];
    //}
    trackerObj *to = [[trackerObj alloc] init:tid];
	[to describe];

	useTrackerController *utc = [[useTrackerController alloc] initWithNibName:@"useTrackerController" bundle:nil ];
	utc.tracker = to;
    utc.rejectable = rejectable;
    utc.tlist = self.tlist;  // required so reject can fix topLevel list
    
    //if (rejectable) {
    //    [self.navigationController pushViewController:utc animated:NO];
    //} else {
        [self.navigationController pushViewController:utc animated:YES];
    //}
    //[self myNavTransition:utc animOpt:UIViewAnimationOptionTransitionFlipFromLeft];
    
	[utc release];
	
	[to release];
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (PVNOSHOW != self.privacyObj.showing) {
        return;
    }
    
	//NSUInteger row = [indexPath row];
	//DBGLog(@"selected row %d : %@", row, [self.tlist.topLayoutNames objectAtIndex:row]);
	
    [self openTracker:[self.tlist getTIDfromIndex:[indexPath row]] rejectable:NO];
	
}

@end

