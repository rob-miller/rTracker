//
//  graphTracker.m
//  rTracker
//
//  Created by Robert Miller on 28/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

//#import <libkern/OSAtomic.h>

#import "graphTrackerVC.h"
#import "togd.h"
#import "vogd.h"
#import "privacyV.h"

#import "graphTracker-constants.h"

#import "dbg-defs.h"
#import "rTracker-constants.h"
#import "rTracker-resource.h"

@interface graphTrackerVC (PrivateMethods)
- (CGFloat) getMaxDataLabelWidth;
- (void) nextVO;
@end


@implementation graphTrackerVC

@synthesize tracker=_tracker, currVO=_currVO, myFont=_myFont, scrollView=_scrollView,gtv=_gtv,titleView=_titleView,voNameView=_voNameView,xAV=_xAV,yAV=_yAV,dpr=_dpr,parentUTC=_parentUTC;
//,shakeLock=_shakeLock;

/*
 - (void) loadView {
    [super loadView];
     //scrollView = [[UIScrollView alloc] initWithFrame:[[self view] bounds]];
     scrollView = [[UIScrollView alloc] initWithFrame:[[self view] bounds]];
    //scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [scrollView setBackgroundColor:[UIColor magentaColor]];
    [scrollView setDelegate:self];
    [scrollView setBouncesZoom:YES];
    [[self view] addSubview:scrollView];
    [[self view] setBackgroundColor:[UIColor brownColor]];
    
}
*/

- (void) buildView {
    //self.shakeLock = 0;
    //if (0 != self.shakeLock) return;
    //if (self.tracker.recalcFnLock) return;
    
    self.view.backgroundColor = [UIColor blackColor];
    //[[self view] setBackgroundColor:[UIColor blueColor]];
    
    CGRect gtvRect;
    
    // get our own frame
    
    CGRect srect = [[self view] bounds];
    
    /*
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0") && SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        srect.size.width -= 5;
        srect.size.height += 20;
        self.view.bounds = srect;
    }
    */
    
    //srect.origin.y -= 50;
    
    DBGLog(@"gtvc srect: %f %f %f %f",srect.origin.x,srect.origin.y,srect.size.width,srect.size.height);
    
    CGFloat tw = srect.size.width;   // swap because landscape only implementation and view not loaded yet
    CGFloat th = srect.size.height;
    
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        th = srect.size.width;   // swap back because fixed!
        tw = srect.size.height;
    }
    srect.size.width = th;
    srect.size.height = tw;
    
    // add views for title, axes and labels
    
    self.myFont = [UIFont fontWithName:@FONTNAME size:FONTSIZE];
    CGFloat labelHeight = self.myFont.lineHeight +2.0f;
    
    // view for title
    CGRect rect;
    rect.origin.y =  0.0f;
    rect.size.height = labelHeight;
    //rect.origin.x = 60.0f;  // this works
    //rect.origin.x = 0.0f;
    rect.origin.x = G_TITLE_OFFSET;  // avoid pre-iOS 8.1.1 bleed through of status bar
    rect.size.width = srect.size.width - G_TITLE_OFFSET; // /2.0f;
    
    gtTitleV *ttv = [[gtTitleV alloc] initWithFrame:rect];
    self.titleView = ttv;
    self.titleView.tracker = self.tracker;
    self.titleView.myFont = self.myFont;
    //self.titleView.backgroundColor = [UIColor greenColor];  // debug
    
    [[self view] addSubview:self.titleView];
    
    //[self.titleView release]; // rtm 05 feb 2012 +1 alloc +1 self. retain
    
    gtvRect.origin.y = rect.size.height;
    
    // view for y axis labels
    
    rect.origin.x = 0.0f;
    rect.size.width = [self getMaxDataLabelWidth] + (2*SPACE) + TICKLEN;
    rect.origin.y = self.titleView.frame.size.height;
    rect.size.height = srect.size.height - labelHeight; // ((2*labelHeight) + (3*SPACE) + TICKLEN);
    
    DBGLog(@"gtvc yax rect: %f %f %f %f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    
    gtYAxV *tyav = [[gtYAxV alloc] initWithFrame:rect];
    self.yAV = tyav;
    //self.yAV.vogd = (vogd*) self.currVO.vogd;  // do below, not valid yet
    self.yAV.myFont = self.myFont;
    //self.yAV.backgroundColor = [UIColor yellowColor];  //debug;
    //[self.yAV setBackgroundColor:[UIColor yellowColor]];
    
    self.yAV.scaleOriginY = 0.0f;
    self.yAV.parentGTVC = (id) self;
    //[self.yAV release];  // rtm 05 feb 2012 +1 alloc +1 self.retain
    //[[self view] addSubview:self.yAV];  // do after set vogd
    
    gtvRect.origin.x = rect.size.width;
    gtvRect.size.width = srect.size.width - gtvRect.origin.x;
    
    // view for x axis labels
    rect.origin.y = srect.size.height - ((2*labelHeight) + (3*SPACE) + TICKLEN);
    rect.size.height = srect.size.height - BORDER - rect.size.width;
    rect.origin.x = rect.size.width;
    rect.size.width = srect.size.width - rect.size.width - 10;
    
    self.yAV.scaleHeightY = rect.origin.y - self.titleView.frame.size.height;   // set bottom of y scale area
    
    gtXAxV *txav = [[gtXAxV alloc] initWithFrame:rect];
    self.xAV = txav;
    self.xAV.myFont = self.myFont;
    // self.xAV.togd = self.tracker.togd;   // not valid yet
    //self.xAV.backgroundColor = [UIColor redColor];  //debug;
    self.xAV.scaleOriginX = 0.0f;
    self.xAV.scaleWidthX = rect.size.width;  // x scale area is full length of subview
    //[self.xAV release];  // rtm 05 feb 2012 +1 alloc +1 self.retain
    // [[self view] addSubview:self.xAV];  // wait for togd
    
    gtvRect.size.height = rect.origin.y - gtvRect.origin.y;
    
    // add scrollview for main graph
    UIScrollView *tsv = [[UIScrollView alloc] initWithFrame:gtvRect];
    self.scrollView = tsv;
    [self.scrollView setBackgroundColor:[UIColor blackColor]];
    //[self.scrollView setBackgroundColor:[UIColor greenColor]];
    [self.scrollView setDelegate:self];
    [self.scrollView setBouncesZoom:YES];
    
    [[self view] addSubview:self.scrollView];
    
    //[self.scrollView release];  // rtm 05 feb 2012 +1 alloc +1 self.retain
    //[[self view] setBackgroundColor:[UIColor yellowColor]];  //debug
    
    DBGLog(@"did create scrollview");
    
    self.scrollView.minimumZoomScale=1.0;
    self.scrollView.maximumZoomScale=5.0;
    self.scrollView.contentSize=CGSizeMake(gtvRect.size.width, gtvRect.size.height);
    //self.scrollView.delegate=self;
    
    gtvRect.origin.x = 0.0f;
    gtvRect.origin.y = 0.0f;
    
    // load all togd, vogd data into NSArrays etc.
    
    [self.tracker setTOGD:gtvRect];  // now we know the full gtvRect
    [self nextVO]; // initialize self.currVO
    
    self.yAV.vogd = (vogd*) self.currVO.vogd;
    self.yAV.graphSV = self.scrollView;
    
    [[self view] addSubview:self.yAV];
    //[self.yAV setBackgroundColor:[UIColor yellowColor]];
    
    self.xAV.mytogd = self.tracker.togd;
    self.xAV.graphSV = self.scrollView;
    [[self view] addSubview:self.xAV];
    
    // add main graph view
    graphTrackerV *tgtv = [[graphTrackerV alloc]initWithFrame:gtvRect];
    self.gtv = tgtv;
	self.gtv.tracker = self.tracker;
    self.gtv.gtvCurrVO = self.currVO;
    self.gtv.parentGTVC = (id) self;
    if (DPA_GOTO == self.dpr.action) {
        int targSecs = [self.dpr.date timeIntervalSince1970] - ((togd*)self.tracker.togd).firstDate;
        self.gtv.xMark = ((togd*)self.tracker.togd).firstDate + (targSecs * ((togd*)self.tracker.togd).dateScale);
    }
	
    
    [self.scrollView addSubview:self.gtv];
    
    //[self.gtv release];  // rtm 05 feb 2012 +1 alloc +1 self.retain
    //[[self view] addSubview:[[[UIView alloc]initWithFrame:srect] retain]];
    //self.view.multipleTouchEnabled = YES;
    
    //[parentUTC.view addSubview:self.view];

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    /*
    CGRect frame = self.view.frame;
    frame.size.height -= 22.0f;
    self.view.frame = frame;
     */
    [super viewDidLoad];

    //if ( SYSTEM_VERSION_LESS_THAN(@"6.0") ) {
        [self buildView];
    //}
}


 - (void) viewWillAppear:(BOOL)animated {
     [super viewWillAppear:animated];
     
     if (DPA_GOTO == self.dpr.action) {
         int targSecs = [self.dpr.date timeIntervalSince1970] - ((togd*)self.tracker.togd).firstDate;
         self.gtv.xMark = (targSecs * ((togd*)self.tracker.togd).dateScale);
     }
     
     if (nil != (self.tracker.optDict)[@"dirtyFns"]) {
         [self fireRecalculateFns];
     }
     [self fireRegenSearchMatches];
     [self.navigationController setToolbarHidden:YES animated:NO];

}

- (void) viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark handle shake event

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [self becomeFirstResponder];
}

- (void) doRecalculateFns {  // and re-create graphs 
    @autoreleasepool {
        self.tracker.goRecalculate = YES;
        [self.tracker recalculateFns];
        
        if (self.tracker.goRecalculate) {
            [self.tracker setTOGD:self.gtv.frame]; // recreate all graph data
            self.tracker.goRecalculate = NO;
        }
        
        //[rTracker_resource finishActivityIndicator:self.scrollView navItem:nil disable:NO];
        [rTracker_resource finishProgressBar:self.scrollView navItem:nil disable:NO];
        
        [self.gtv setNeedsDisplay];
        [self.yAV setNeedsDisplay];
        
        //self.shakeLock = 0; // release lock
    }
    
}

- (void) fireRecalculateFns {
    if (self.tracker.recalcFnLock) return;  // already running
    [rTracker_resource startProgressBar:self.scrollView navItem:nil disable:NO yloc:20.0f];
    [NSThread detachNewThreadSelector:@selector(doRecalculateFns) toTarget:self withObject:nil];
}

- (void) fireRegenSearchMatches {
    if (nil != self.parentUTC.searchSet) {
        NSMutableArray *xPoints = [[NSMutableArray alloc] init];
        for (NSNumber *d in self.parentUTC.searchSet) {
            if ([d floatValue] >= ((togd*)self.tracker.togd).firstDate) {
                [xPoints addObject:[NSNumber numberWithFloat:([d floatValue] - ((togd*)self.tracker.togd).firstDate) * ((togd*)self.tracker.togd).dateScale]];
            }
        }
        if (0 < [xPoints count]) {
            self.gtv.searchXpoints = [NSArray arrayWithArray:xPoints];
            return;  // success
        }
    }
    // fall through to no match default result
    self.gtv.searchXpoints = nil;
}


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventSubtypeMotionShake) {
        // It has shake d
        /*
        if (0 != OSAtomicTestAndSet(0, &(_shakeLock))) {
            // wasn't 0 before, so we didn't get lock, so leave because shake handling already in process
            return;
        }
         */
        if (self.tracker.goRecalculate) {
            // recalculate is already running
            return;
        }
        // we are first one here
        
        //[rTracker_resource startActivityIndicator:self.scrollView navItem:nil disable:NO];

        [self fireRecalculateFns];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.gtv;
}
/*
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    CGRect newFrame =  view.frame;
    DBGLog(@"sv did end zooming scale=%f",scale);
    DBGLog(@"view frame -- x:%f y:%f w:%f h:%f",newFrame.origin.x, newFrame.origin.y, newFrame.size.width, newFrame.size.height);
    newFrame =  view.bounds;
    DBGLog(@"view bounds -- x:%f y:%f w:%f h:%f",newFrame.origin.x, newFrame.origin.y, newFrame.size.width, newFrame.size.height);
    DBGLog(@"sv cOffset x:%f y:%f cSize w:%f h:%f cInset t:%f l:%f b:%f r:%f",scrollView.contentOffset.x,scrollView.contentOffset.y,
           scrollView.contentSize.width,scrollView.contentSize.height,scrollView.contentInset.top,scrollView.contentInset.left,
           scrollView.contentInset.bottom,scrollView.contentInset.right);
    
}
*/

 - (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //DBGLog(@"sv did scroll");
    //DBGLog(@"sv cOffset x:%f y:%f cSize w:%f h:%f cInset t:%f l:%f b:%f r:%f",self.scrollView.contentOffset.x,self.scrollView.contentOffset.y,
    //       self.scrollView.contentSize.width,self.scrollView.contentSize.height,self.scrollView.contentInset.top,self.scrollView.contentInset.left,
    //       self.scrollView.contentInset.bottom,self.scrollView.contentInset.right);

     [self.xAV setNeedsDisplay];
     [self.yAV setNeedsDisplay];
     
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    //DBGLog(@"sv did zoom");
    //DBGLog(@"sv cOffset x:%f y:%f cSize w:%f h:%f cInset t:%f l:%f b:%f r:%f",self.scrollView.contentOffset.x,self.scrollView.contentOffset.y,
    //       self.scrollView.contentSize.width,self.scrollView.contentSize.height,self.scrollView.contentInset.top,self.scrollView.contentInset.left,
    //       self.scrollView.contentInset.bottom,self.scrollView.contentInset.right);

    [self.xAV setNeedsDisplay];
    [self.yAV setNeedsDisplay];
    
}
/*
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    DBGLog(@"sv did end scrolling animation");
    DBGLog(@"sv cOffset x:%f y:%f cSize w:%f h:%f cInset t:%f l:%f b:%f r:%f",scrollView.contentOffset.x,scrollView.contentOffset.y,
           scrollView.contentSize.width,scrollView.contentSize.height,scrollView.contentInset.top,scrollView.contentInset.left,
           scrollView.contentInset.bottom,scrollView.contentInset.right);
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    DBGLog(@"sv did end decelerating");
    DBGLog(@"sv cOffset x:%f y:%f cSize w:%f h:%f cInset t:%f l:%f b:%f r:%f",scrollView.contentOffset.x,scrollView.contentOffset.y,
           scrollView.contentSize.width,scrollView.contentSize.height,scrollView.contentInset.top,scrollView.contentInset.left,
           scrollView.contentInset.bottom,scrollView.contentInset.right);
    
}
 */

#pragma mark -
#pragma mark close up code

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
/*
- (void)viewDidUnload {
	self.tracker = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
*/

- (void)dealloc {
    DBGLog(@"deallocating graphTrackerVC");
    
}

#pragma mark -
# pragma mark view rotation methods

/* pre ios6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (0 != self.shakeLock)
        return NO;
    // Return YES for supported orientations
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog(@"gt should rotate to interface orientation portrait?");
            if ( SYSTEM_VERSION_LESS_THAN(@"5.0") ) { //if not 5
                [self.parentUTC returnFromGraph];
            }

			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			DBGLog(@"gt should rotate to interface orientation portrait upside down?");
			break;
		case UIInterfaceOrientationLandscapeLeft:
			DBGLog(@"gt should rotate to interface orientation landscape left?");
            //[self doGT];
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"gt should rotate to interface orientation landscape right?");
            //[self doGT];
			break;
		default:
			DBGWarn(@"utc rotation query but can't tell to where?");
			break;			
	}
	
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown );
}
*/


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
	switch (fromInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog(@"gt did rotate from interface orientation portrait");
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			DBGLog(@"gt did rotate from interface orientation portrait upside down");
			break;
		case UIInterfaceOrientationLandscapeLeft:
			DBGLog(@"gt did rotate from interface orientation landscape left");
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"gt did rotate from interface orientation landscape right");
			break;
		default:
			DBGLog(@"gt did rotate but can't tell from where");
			break;			
	}

    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0") ) {// if 5.0
        if ((self.interfaceOrientation ==  UIInterfaceOrientationPortrait) || (self.interfaceOrientation ==  UIInterfaceOrientationPortraitUpsideDown)) {
            [self.parentUTC returnFromGraph];
        }
    }

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //rtm dbg self.gtv.doDrawGraph=FALSE;
    self.gtv.doDrawGraph=TRUE;
    
	switch (toInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog(@"gt will rotate to interface orientation portrait duration: %f sec",duration);
            self.tracker.goRecalculate=NO; // stop!!!!
            break;
		case UIInterfaceOrientationPortraitUpsideDown:
			DBGLog(@"gt will rotate to interface orientation portrait upside down duration: %f sec", duration);
            self.tracker.goRecalculate=NO; // stop!!!!
            break;
		case UIInterfaceOrientationLandscapeLeft:
			DBGLog(@"gt will rotate to interface orientation landscape left duration: %f sec", duration);
            self.gtv.doDrawGraph=TRUE;
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"gt will rotate to interface orientation landscape right duration: %f sec", duration);
            self.gtv.doDrawGraph=TRUE;
			break;
		default:
			DBGErr(@"gt will rotate but can't tell to where duration: %f sec", duration);
			break;			
	}
}



- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog(@"gt will animate rotation to interface orientation portrait duration: %f sec",duration);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			DBGLog(@"gt will animate rotation to interface orientation portrait upside down duration: %f sec", duration);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			DBGLog(@"gt will animate rotation to interface orientation landscape left duration: %f sec", duration);
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"gt will animate rotation to interface orientation landscape right duration: %f sec", duration);
			break;
		default:
			DBGErr(@"gt will animate rotation but can't tell to where duration: %f sec", duration);
			break;			
	}
}


 

#pragma mark -
#pragma mark touch support
/*
- (NSString*) touchReport:(NSSet*)touches {
    
#if DEBUGLOG
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self.view];
	return [NSString stringWithFormat:@"touch at %f, %f.  taps= %d  numTouches= %d",
            touchPoint.x, touchPoint.y, [touch tapCount], [touches count]];
#endif
    return @"";
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"gvc touches began: %@", [self touchReport:touches]);
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"gvc touches cancelled: %@", [self touchReport:touches]);
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"gvc touches ended: %@", [self touchReport:touches]);
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    DBGLog(@"gvc touches moved: %@", [self touchReport:touches]);
}

*/

/*
- (valueObj*) currVO {
    if (nil == currVO) {
        [self nextVO];
    }
    return currVO;
}
*/

#pragma mark -
#pragma mark handle taps in subviews

- (void) yavTap {
    //if (0 != self.shakeLock) return;
    if (self.tracker.recalcFnLock) return;
    //DBGLog(@"yav tapped!");
    [self nextVO];
    self.yAV.vogd = (vogd*) self.currVO.vogd;
    [self.yAV setNeedsDisplay];
    self.gtv.gtvCurrVO = self.currVO;  // double line width
    [self.gtv setNeedsDisplay];
}

- (void) gtvTap:(NSSet *)touches {
    //if (0 != self.shakeLock) return;
    if (self.tracker.recalcFnLock) return;
    //DBGLog(@"gtv tapped!");
    //int xMarkSecs;
    UITouch *touch = [touches anyObject];
    
    if ((1 == [touch tapCount]) && (1 == [touches count])) {
        CGPoint touchPoint = [touch locationInView:self.gtv];  // sv=> full zoomed content size ; gtv => gtv frame but zoom/scroll mapped
        //DBGLog(@"gtv tap at %f, %f.  taps= %d  numTouches= %d",touchPoint.x, touchPoint.y, [touch tapCount],[touches count]);
        
        NSInteger nearDate = ((togd*)self.tracker.togd).firstDate + (touchPoint.x * ((togd*)self.tracker.togd).dateScaleInv );
        NSInteger newDate = [self.tracker dateNearest:nearDate];
        self.dpr.date = [NSDate dateWithTimeIntervalSince1970:newDate];
        self.dpr.action = DPA_GOTO;        
        //self.gtv.xMark = touchPoint.x;
        self.gtv.xMark = (newDate - ((togd*)self.tracker.togd).firstDate) * ((togd*)self.tracker.togd).dateScale;
    } else if ((2 == [touch tapCount]) && (1 == [touches count])) {
        DBGLog(@"gtvTap: cancel");
        self.gtv.xMark = NOXMARK;
        self.dpr.action = DPA_GOTO;
        self.dpr.date = nil;  
    } else {
        DBGLog(@"gtvTap: null event");
    }
    
    [self.gtv setNeedsDisplay];
}

#pragma mark -
#pragma mark private methods

- (CGFloat) testStrWidth:(NSString*)testStr max:(CGFloat)max {
    CGSize tsize = [testStr sizeWithAttributes:@{NSFontAttributeName:self.myFont}];
    return (max < tsize.width ? tsize.width : max);
}

- (CGFloat) testDblWidth:(double)testVal max:(CGFloat)max {
    return [self testStrWidth:[NSString stringWithFormat:@"%f",testVal] max:max];
}

- (CGFloat) getMaxDataLabelWidth {  // TODO: can we cache this in optDict?
    
    CGFloat maxw=0.0f;
    
    for (valueObj *vo in self.tracker.valObjTable) {
        if ([@"1" isEqualToString:(vo.optDict)[@"graph"]]) {
            switch (vo.vtype) {
                case VOT_NUMBER:
                case VOT_FUNC:
                    if ([@"0" isEqualToString:(vo.optDict)[@"autoscale"]]) {
                        maxw = [self testDblWidth:[(vo.optDict)[@"gmin"] doubleValue] max:maxw];
                        maxw = [self testDblWidth:[(vo.optDict)[@"gmax"] doubleValue] max:maxw];
                    } else {
                       NSString *sql = [NSString stringWithFormat:@"select min(val collate BINARY) from voData where id=%ld;",(long)vo.vid];  // CMPSTRDBL
                        maxw = [self testDblWidth:[self.tracker toQry2Double:sql] max:maxw];
                       sql = [NSString stringWithFormat:@"select max(val collate BINARY) from voData where id=%ld;",(long)vo.vid]; // CMPSTRDBL
                        maxw = [self testDblWidth:[self.tracker toQry2Double:sql] max:maxw];
                    }
                    break;
                case VOT_SLIDER: {
                    NSNumber *nmin = (vo.optDict)[@"smin"];
                    NSNumber *nmax = (vo.optDict)[@"smax"];
                    maxw = [self testDblWidth:( nmin ? [nmin doubleValue] : d(SLIDRMINDFLT) ) max:maxw];
                    maxw = [self testDblWidth:( nmax ? [nmax doubleValue] : d(SLIDRMAXDFLT) ) max:maxw];
                    break;
                }
                case VOT_BOOLEAN: {
                    NSNumber *bval = (vo.optDict)[@"boolval"];
                    maxw = [self testDblWidth:( bval ? [bval doubleValue] : d(BOOLVALDFLT) ) max:maxw];
                    break;
                }
                case VOT_CHOICE: {
                    int i;
                    for (i=0;i<CHOICES;i++) {
                        NSString *key = [NSString stringWithFormat:@"c%d",i];
                        NSString *s = (vo.optDict)[key];
                        if ((s != nil) && (![s isEqualToString:@""])) 
                            maxw = [self testStrWidth:s max:maxw];
                    }
                    break;
                }
                default:
                    maxw = [self testDblWidth:d(99) max:maxw];
                    break;
            }
        }
        
    }
   
    //sql = nil;
    
    return maxw;
}



- (BOOL) testSetVO:(valueObj*)vo {
    if ([@"1" isEqualToString:(vo.optDict)[@"graph"]]) {
        self.currVO = vo;
        return YES;
    }
    return NO;
}

- (void) nextVO {
    if (nil == self.currVO) {
        // no currVO set, work through list and set first one that has graph enabled
        for (valueObj *vo in self.tracker.valObjTable) 
            if ([self testSetVO:vo])
                return;
    } else {
        // currVO is set, find it in list and then circle around trying to find next that has graph enabled
        NSUInteger currNdx = [self.tracker.valObjTable indexOfObject:self.currVO];
        NSUInteger ndx=currNdx+1;
        NSUInteger maxc = [self.tracker.valObjTable count];
        while (TRUE) {
            while (ndx < maxc) {
                if ([self testSetVO:(self.tracker.valObjTable)[ndx]])
                    return;
                ndx++;
            }
            if (ndx == currNdx)
                return;
            ndx=0;
            maxc=currNdx;
        }
    }
    
}



@end
