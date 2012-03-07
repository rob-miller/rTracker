//
//  graphTracker.m
//  rTracker
//
//  Created by Robert Miller on 28/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <libkern/OSAtomic.h>

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

@synthesize tracker, currVO, myFont, scrollView,gtv,titleView,voNameView,xAV,yAV,dpr,parentUTC,shakeLock;

/*
 - (void) loadView {
    [super loadView];
    scrollView = [[UIScrollView alloc] initWithFrame:[[self view] bounds]];
    //scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [scrollView setBackgroundColor:[UIColor blackColor]];
    [scrollView setDelegate:self];
    [scrollView setBouncesZoom:YES];
    [[self view] addSubview:scrollView];
    [[self view] setBackgroundColor:[UIColor blueColor]];
    
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];

    self.shakeLock = 0;
    
    //self.view.backgroundColor = [UIColor blackColor]; 
    CGRect gtvRect;
    
    // get our own frame
    
	CGRect srect = [[self view] bounds];

    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0") ) {
        srect.size.width -= 5;  
        srect.size.height += 20;
        self.view.bounds = srect;
    }
    
    CGFloat tw = srect.size.width;   // swap because landscape only implementation and view not loaded yet
    CGFloat th = srect.size.height;
    srect.size.width = th;
    srect.size.height = tw;
    
    // add views for title, axes and labels
    
    myFont = [UIFont fontWithName:[NSString stringWithUTF8String:FONTNAME] size:FONTSIZE];
    CGFloat labelHeight = myFont.lineHeight +2.0f;
    
    // view for title
    CGRect rect;
    rect.origin.y =  0.0f; 
    rect.size.height = labelHeight;
    rect.origin.x = 0.0f;
    rect.size.width = srect.size.width; // /2.0f;
    
    gtTitleV *ttv = [[gtTitleV alloc] initWithFrame:rect];
    self.titleView = ttv;
    [ttv release];
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
    
    gtYAxV *tyav = [[gtYAxV alloc] initWithFrame:rect];
    self.yAV = tyav;
    [tyav release];
    //self.yAV.vogd = (vogd*) self.currVO.vogd;  // do below, not valid yet
    self.yAV.myFont = self.myFont;
    //self.yAV.backgroundColor = [UIColor blueColor];  //debug;
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
    rect.size.width = srect.size.width - rect.size.width;
    
    self.yAV.scaleHeightY = rect.origin.y - self.titleView.frame.size.height;   // set bottom of y scale area
    
    gtXAxV *txav = [[gtXAxV alloc] initWithFrame:rect];
    self.xAV = txav;
    [txav release];
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
    [tsv release];
    [self.scrollView setBackgroundColor:[UIColor blackColor]];
    [self.scrollView setDelegate:self];
    [self.scrollView setBouncesZoom:YES];
    [[self view] addSubview:scrollView];
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
    self.xAV.mytogd = self.tracker.togd;
    self.xAV.graphSV = self.scrollView;
    [[self view] addSubview:self.xAV];
    
    // add main graph view
    graphTrackerV *tgtv = [[graphTrackerV alloc]initWithFrame:gtvRect];
    self.gtv = tgtv;
    [tgtv release];
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


 - (void) viewWillAppear:(BOOL)animated {
     if (DPA_GOTO == self.dpr.action) {
         int targSecs = [self.dpr.date timeIntervalSince1970] - ((togd*)self.tracker.togd).firstDate;
         self.gtv.xMark = (targSecs * ((togd*)self.tracker.togd).dateScale);
     }
     [super viewWillAppear:animated];
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
    [self becomeFirstResponder];
    [super viewDidAppear:animated];
}

- (void) doRecalculateFns {  // and re-create graphs 
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self.tracker recalculateFns];
    [self.tracker setTOGD:self.gtv.frame]; // recreate all graph data
    
    //[rTracker_resource finishActivityIndicator:self.scrollView navItem:nil disable:NO];
    [rTracker_resource finishProgressBar:self.scrollView navItem:nil disable:NO];
    
    [self.gtv setNeedsDisplay];
    [self.yAV setNeedsDisplay];
    
    self.shakeLock = 0; // release lock
    
    [pool drain];
    
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventSubtypeMotionShake) {
        // It has shake d
        if (0 != OSAtomicTestAndSet(0, &(shakeLock))) {
            // wasn't 0 before, so we didn't get lock, so leave because shake handling already in process
            return;
        }
        
        // we are first one here
        
        //[rTracker_resource startActivityIndicator:self.scrollView navItem:nil disable:NO];
        [rTracker_resource startProgressBar:self.scrollView navItem:nil disable:NO];

        [NSThread detachNewThreadSelector:@selector(doRecalculateFns) toTarget:self withObject:nil];
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

- (void)viewDidUnload {
	self.tracker = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    DBGLog(@"deallocating graphTrackerVC");
	self.tracker = nil;
	[tracker release];
	self.currVO = nil;
    [currVO release];
    self.scrollView = nil;
    [scrollView release];
    self.gtv = nil;
    [gtv release];
    self.titleView = nil;
    [titleView release];
    self.voNameView = nil;
    [voNameView release];
    self.xAV = nil;
    [xAV release];
    self.yAV = nil;
    [yAV release];
    
    [super dealloc];
}

#pragma mark -
# pragma mark view rotation methods

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
            if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0") ) {// if 5.0
                [self.parentUTC returnFromGraph];
            }
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"gt did rotate from interface orientation landscape right");
            if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0") ) {// if 5.0
                [self.parentUTC returnFromGraph];
            }
			break;
		default:
			DBGLog(@"gt did rotate but can't tell from where");
			break;			
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.gtv.doDrawGraph=FALSE;
    
	switch (toInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog(@"gt will rotate to interface orientation portrait duration: %f sec",duration);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			DBGLog(@"gt will rotate to interface orientation portrait upside down duration: %f sec", duration);
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
    if (0 != self.shakeLock)
        return;
    //DBGLog(@"yav tapped!");
    [self nextVO];
    self.yAV.vogd = (vogd*) self.currVO.vogd;
    [self.yAV setNeedsDisplay];
    self.gtv.gtvCurrVO = self.currVO;  // double line width
    [self.gtv setNeedsDisplay];
}

- (void) gtvTap:(NSSet *)touches {
    if (0 != self.shakeLock)
        return;
    //DBGLog(@"gtv tapped!");
    //int xMarkSecs;
    UITouch *touch = [touches anyObject];
    
    if ((1 == [touch tapCount]) && (1 == [touches count])) {
        CGPoint touchPoint = [touch locationInView:self.gtv];  // sv=> full zoomed content size ; gtv => gtv frame but zoom/scroll mapped
        //DBGLog(@"gtv tap at %f, %f.  taps= %d  numTouches= %d",touchPoint.x, touchPoint.y, [touch tapCount],[touches count]);
        
        int nearDate = ((togd*)self.tracker.togd).firstDate + (touchPoint.x * ((togd*)self.tracker.togd).dateScaleInv );
        int newDate = [self.tracker dateNearest:nearDate];
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
    CGSize tsize = [testStr sizeWithFont:self.myFont];
    return (max < tsize.width ? tsize.width : max);
}

- (CGFloat) testDblWidth:(double)testVal max:(CGFloat)max {
    return [self testStrWidth:[NSString stringWithFormat:@"%f",testVal] max:max];
}

- (CGFloat) getMaxDataLabelWidth {  // TODO: can we cache this in optDict?
    
    CGFloat maxw=0.0f;
    
    for (valueObj *vo in self.tracker.valObjTable) {
        if ([@"1" isEqualToString:[vo.optDict objectForKey:@"graph"]]) {
            switch (vo.vtype) {
                case VOT_NUMBER:
                case VOT_FUNC:
                    if ([@"0" isEqualToString:[vo.optDict objectForKey:@"autoscale"]]) {
                        maxw = [self testDblWidth:[[vo.optDict objectForKey:@"gmin"] doubleValue] max:maxw];
                        maxw = [self testDblWidth:[[vo.optDict objectForKey:@"gmax"] doubleValue] max:maxw];
                    } else {
                        self.tracker.sql = [NSString stringWithFormat:@"select min(val collate BINARY) from voData where id=%d;",vo.vid];  // CMPSTRDBL
                        maxw = [self testDblWidth:[self.tracker toQry2Double] max:maxw];
                        self.tracker.sql = [NSString stringWithFormat:@"select max(val collate BINARY) from voData where id=%d;",vo.vid]; // CMPSTRDBL
                        maxw = [self testDblWidth:[self.tracker toQry2Double] max:maxw];
                    }
                    break;
                case VOT_SLIDER: {
                    NSNumber *nmin = [vo.optDict objectForKey:@"smin"];
                    NSNumber *nmax = [vo.optDict objectForKey:@"smax"];
                    maxw = [self testDblWidth:( nmin ? [nmin doubleValue] : d(SLIDRMINDFLT) ) max:maxw];
                    maxw = [self testDblWidth:( nmax ? [nmax doubleValue] : d(SLIDRMAXDFLT) ) max:maxw];
                    break;
                }
                case VOT_CHOICE: {
                    int i;
                    for (i=0;i<CHOICES;i++) {
                        NSString *key = [NSString stringWithFormat:@"c%d",i];
                        NSString *s = [vo.optDict objectForKey:key];
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
    
    self.tracker.sql = nil;
    
    return maxw;
}



- (BOOL) testSetVO:(valueObj*)vo {
    if ([@"1" isEqualToString:[vo.optDict objectForKey:@"graph"]]) {
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
        NSUInteger currNdx = [self.tracker.valObjTable indexOfObject:currVO];
        NSUInteger ndx=currNdx+1;
        NSUInteger maxc = [self.tracker.valObjTable count];
        while (TRUE) {
            while (ndx < maxc) {
                if ([self testSetVO:[self.tracker.valObjTable objectAtIndex:ndx]])
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
