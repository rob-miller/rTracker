//
//  graphTracker.m
//  rTracker
//
//  Created by Robert Miller on 28/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "graphTrackerVC.h"
#import "togd.h"
#import "vogd.h"

#import "graphTracker-constants.h"

#import "dbg-defs.h"
#import "rTracker-constants.h"

@interface graphTrackerVC (PrivateMethods)
- (CGFloat) getMaxDataLabelWidth;
- (void) nextVO;
@end


@implementation graphTrackerVC

@synthesize tracker, currVO, myFont, scrollView,gtv,titleView,voNameView,xAV,yAV;

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
    //self.view.backgroundColor = [UIColor blackColor]; 
    CGRect gtvRect;
    
    // get our own frame
    
	CGRect srect = [[self view] bounds];
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
    
    self.titleView = [[gtTitleV alloc] initWithFrame:rect];
    self.titleView.tracker = self.tracker;
    self.titleView.myFont = self.myFont;
    //self.titleView.backgroundColor = [UIColor greenColor];  // debug
    [[self view] addSubview:self.titleView];

    gtvRect.origin.y = rect.size.height;
    
    /*
     // view for voName
     rect.origin.x = srect.size.width/2.0f;
     
     self.voNameView = [[gtVONameV alloc] initWithFrame:rect];
     self.voNameView.currVO = self.currVO;
     self.voNameView.myFont = self.myFont;
     self.voNameView.voColor = (UIColor *) [self.tracker.colorSet objectAtIndex:self.currVO.vcolor];
     
     self.voNameView.backgroundColor = [UIColor orangeColor];  // debug
     [[self view] addSubview:self.voNameView];
     */
    
    
    // view for y axis labels
    
    rect.origin.x = 0.0f;
    rect.size.width = [self getMaxDataLabelWidth] + (2*SPACE) + TICKLEN;
    rect.origin.y = self.titleView.frame.size.height;
    rect.size.height = srect.size.height - labelHeight; // ((2*labelHeight) + (3*SPACE) + TICKLEN);
    
    self.yAV = [[gtYAxV alloc] initWithFrame:rect];
    //self.yAV.vogd = (vogd*) self.currVO.vogd;  // do below, not valid yet
    self.yAV.myFont = self.myFont;
    //self.yAV.backgroundColor = [UIColor blueColor];  //debug;
    self.yAV.scaleOriginY = 0.0f;
    
    //[[self view] addSubview:self.yAV];  // do after set vogd
    
    gtvRect.origin.x = rect.size.width;
    gtvRect.size.width = srect.size.width - gtvRect.origin.x;
    
    // view for x axis labels
    rect.origin.y = srect.size.height - ((2*labelHeight) + (3*SPACE) + TICKLEN);
    rect.size.height = srect.size.height - BORDER - rect.size.width;
    rect.origin.x = rect.size.width;
    rect.size.width = srect.size.width - rect.size.width;
    
    self.yAV.scaleHeightY = rect.origin.y - self.titleView.frame.size.height;   // set bottom of y scale area
    
    self.xAV = [[gtXAxV alloc] initWithFrame:rect];
    self.xAV.myFont = self.myFont;
    // self.xAV.togd = self.tracker.togd;   // not valid yet
    //self.xAV.backgroundColor = [UIColor redColor];  //debug;
    self.xAV.scaleOriginX = 0.0f;
    self.xAV.scaleWidthX = rect.size.width;  // x scale area is full length of subview
    
    // [[self view] addSubview:self.xAV];  // wait for togd
    
    gtvRect.size.height = rect.origin.y - gtvRect.origin.y;
    
    // add scrollview for main graph
    scrollView = [[UIScrollView alloc] initWithFrame:gtvRect];
    [scrollView setBackgroundColor:[UIColor blackColor]];
    [scrollView setDelegate:self];
    [scrollView setBouncesZoom:YES];
    [[self view] addSubview:scrollView];
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
    [[self view] addSubview:self.yAV];
    self.xAV.togd = self.tracker.togd;
    [[self view] addSubview:self.xAV];
    
    // add main graph view
    gtv = [[graphTrackerV alloc]initWithFrame:gtvRect];
	gtv.tracker = self.tracker;
	[self.scrollView addSubview:gtv];
    
    //[[self view] addSubview:[[[UIView alloc]initWithFrame:srect] retain]];
    //self.view.multipleTouchEnabled = YES;
    
    
}

/*
 - (void) viewWillAppear:(BOOL)animated {
    
    self.scrollView.bounds = self.view.bounds;
}
*/


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.gtv;
}


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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog(@"gt should rotate to interface orientation portrait?");
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			DBGLog(@"gt should rotate to interface orientation portrait upside down?");
			break;
		case UIInterfaceOrientationLandscapeLeft:
			DBGLog(@"gt should rotate to interface orientation landscape left?");
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"gt should rotate to interface orientation landscape right?");
			break;
		default:
			DBGLog(@"gt rotation query but can't tell to where?");
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
			break;
		case UIInterfaceOrientationLandscapeRight:
			DBGLog(@"gt did rotate from interface orientation landscape right");
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

#if (1) 
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			DBGLog(@"gt will animate rotation to interface orientation portrait duration: %f sec",duration);
			[self dismissModalViewControllerAnimated:YES];
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

#else 

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	DBGLog(@"gt will animate first half rotation to interface orientation duration: %@",duration);
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
	DBGLog(@"gt will animate second half rotation to interface orientation duration: %@",duration);
}
#endif


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
        for (valueObj *vo in self.tracker.valObjTable) 
            if ([self testSetVO:vo])
                return;
    } else {
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
