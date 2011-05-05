//
//  graphTrackerV.m
//  rTracker
//
//  Created by Robert Miller on 28/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "graphTrackerV.h"
#import "gfx.h"
#import "dbg-defs.h"

//#define DEBUGLOG 1

@implementation graphTrackerV

@synthesize tracker;
@synthesize context;

@synthesize firstDate,lastDate,myFont, doDrawGraph;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
	self.context=nil;
	self.tracker = nil;
	self.myFont = nil;
	
	[tracker release];
	[myFont release];
    [super dealloc];
}

#pragma mark -
#pragma mark drawing routines

- (void) drawBackground 
{
	[[UIColor blackColor] set];
	CGContextFillRect(self.context,self.bounds);
	
}

#define BORDER 30.0f
#define XTICKS 10.0f
#define YTICKS 7.0f
#define TICKLEN 5.0f

#define DEFAULT_PT (BORDER + 5.0f)

#define STD_LINE_WIDTH 1.0f
#define BAR_LINE_WIDTH 6.0f
#define STD_ALPHA 1.0f
#define BAR_ALPHA 0.5f

#define FONTNAME "Helvetica-Bold"
#define FONTSIZE 10


- (void) flipCTM 
{
	CGAffineTransform tm = { 1.0f , 0.0f, 0.0f, -1.0f, 0.0f, self.bounds.size.height };
	CGContextConcatCTM(self.context,tm);
}

- (void) drawTitle
{
	//const char *tstr = [self.tracker.trackerName UTF8String];
	//CGContextShowTextAtPoint (self.context, self.bounds.size.width/2.0f, self.bounds.size.height - (BORDER/2.0f), tstr, strlen(tstr));

	CGSize tsize = [self.tracker.trackerName sizeWithFont:myFont];
	CGPoint tpos = { (self.bounds.size.width - tsize.width)/2.0f , /*self.bounds.size.height - */((BORDER - tsize.height)/2.0f) };
	if (tpos.x < 0) 
		tpos.x=0;
	if (tpos.y > self.bounds.size.height)
		tpos.y = self.bounds.size.height;

	[self flipCTM];
	[self.tracker.trackerName drawAtPoint:tpos withFont:myFont];
	[self flipCTM];
		
}

- (void) drawYAxis 
{
	int i;
	CGFloat len = self.bounds.size.height - (CGFloat) (2*BORDER);
	CGFloat step = len / YTICKS;
	
	for (i=1; i<=YTICKS; i++) {
		CGFloat y = BORDER + (f(i) * step);
		MoveTo(BORDER,y);
		AddLineTo(BORDER-TICKLEN,y);
	}
	Stroke;
}

- (void) drawXAxis
{
	int i;
	int dateInterval = self.lastDate - self.firstDate;
	CGFloat dateStep = f(dateInterval) / XTICKS;
	
	CGFloat len = self.bounds.size.width - (CGFloat) (2*BORDER);
	CGFloat step = len / XTICKS;

	[self flipCTM];
	
	for (i=0; i<= XTICKS; i++) {
		CGFloat x = BORDER + (f(i) * step);
		CGFloat y = self.bounds.size.height - BORDER;
		MoveTo(x,y);
		y += TICKLEN;
		if (i>0)
			AddLineTo(x,y);
		y += 1.0f;
		int date = self.firstDate + (int) ((f(i) * dateStep) +0.5f);

		NSDate *sd = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) date];
		NSString *datestr = [NSDateFormatter localizedStringFromDate:sd 
														   dateStyle:(NSDateFormatterStyle)NSDateFormatterShortStyle 
														   timeStyle:(NSDateFormatterStyle)NSDateFormatterShortStyle];
		NSArray *dta = [datestr componentsSeparatedByString:@" "];

		NSString *ds = (NSString *) [dta objectAtIndex:0];
		NSString *ts = (NSString *) [dta objectAtIndex:1];

		CGSize tsize = [ds sizeWithFont:myFont];
		x-= 10.0f;
		if (i == 0
			||
			dateStep < 24*60*60
			||
			i == XTICKS) 
			[ts drawAtPoint:(CGPoint) {x,y} withFont:myFont];
		
		y += tsize.height; // + 1.0f;
		if (i == 0
			||
			dateStep >= 24*60*60
			||
			i == XTICKS) 
			[ds drawAtPoint:(CGPoint) {x,y} withFont:myFont];
		
	}

	Stroke;
	
	/*
	const char *ds = [(NSString *) [dta objectAtIndex:0] UTF8String];
	const char *ts = [(NSString *) [dta objectAtIndex:1] UTF8String];
	
	CGContextShowTextAtPoint (self.context, BORDER, 0, ds, strlen(ds));
	CGContextShowTextAtPoint (self.context, BORDER, BORDER/2.0f, ts, strlen(ts));
	 * /
	
	
	CGPoint tpos1,tpos2;
	tpos1.x = BORDER;
	tpos2.x = BORDER;
	tpos1.y = self.bounds.size.height - BORDER + (BORDER - (2*tsize.height));
	tpos2.y = self.bounds.size.height - BORDER + (BORDER - tsize.height);
	
	tsize = [ts sizeWithFont:myFont];
	[ts drawAtPoint:tpos2 withFont:myFont];
	
	sd = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)self.lastDate];
	datestr = [NSDateFormatter localizedStringFromDate:sd dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
	dta = [datestr componentsSeparatedByString:@" "];
	/ *
	ds = [(NSString *) [dta objectAtIndex:0] UTF8String];
	ts = [(NSString *) [dta objectAtIndex:1] UTF8String];
	
	CGContextShowTextAtPoint (self.context, self.bounds.size.width-(2.0f*BORDER), 0, ds, strlen(ds));
	CGContextShowTextAtPoint (self.context, self.bounds.size.width-(2.0f*BORDER), BORDER/2.0f, ts, strlen(ts));
	 * /

	ds = (NSString *) [dta objectAtIndex:0];
	ts = (NSString *) [dta objectAtIndex:1];

	tpos1.x = self.bounds.size.width-(2.0f*BORDER);
	tpos2.x = self.bounds.size.width-(2.0f*BORDER);
	
	[ds drawAtPoint:tpos1 withFont:myFont];
	[ts drawAtPoint:tpos2 withFont:myFont];

	 */
	
	[self flipCTM];
	
}

- (void) drawAxes
{
	[[UIColor whiteColor] set];

	[self drawTitle];
	
	MoveTo(BORDER,BORDER);
	AddLineTo(self.bounds.size.width - BORDER, BORDER);
	MoveTo(BORDER,BORDER);
	AddLineTo(BORDER,self.bounds.size.height - BORDER);

	[self drawYAxis];
	[self drawXAxis];

}



- (void) transformVO:(valueObj *) vo xdat:(NSMutableArray *)xdat ydat:(NSMutableArray *) ydat
{
    [vo.vos transformVO:xdat 
                   ydat:ydat 
                 dscale:( d(self.bounds.size.width - (2.0f*BORDER)) / d(self.lastDate - self.firstDate) )
                 height:self.bounds.size.height
                 border:BORDER 
              firstDate:self.firstDate];
}

- (void) plotVO_lines:(valueObj *)vo xdat:(NSArray *)xdat ydat:(NSArray *)ydat
{
	[(UIColor *) [tracker.colorSet objectAtIndex:vo.vcolor] set];
	NSEnumerator *e = [ydat objectEnumerator];
	
	BOOL going=NO;
	for (NSNumber *nx in xdat) {
		CGFloat x = [nx floatValue];
		CGFloat y = [[e nextObject] floatValue];
		if (going) {
			DBGLog2(@"addline %f %f",x,y);
			AddLineTo(x,y);
		} else {
			DBGLog2(@"moveto %f %f",x,y);
			MoveTo(x,y);
			going=1;
		}
	}
	
	Stroke;
}


- (void) plotVO_dotsline:(valueObj *)vo xdat:(NSArray *)xdat ydat:(NSArray *)ydat
{
	[(UIColor *) [tracker.colorSet objectAtIndex:vo.vcolor] set];
	NSEnumerator *e = [ydat objectEnumerator];
	
	BOOL going=NO;
	for (NSNumber *nx in xdat) {
		CGFloat x = [nx floatValue];
		CGFloat y = [[e nextObject] floatValue];
		if (going) {
			DBGLog2(@"addline %f %f",x,y);
			AddLineTo(x,y);
			AddCircle(x,y);
		} else {
			DBGLog2(@"moveto %f %f",x,y);
			MoveTo(x,y);
			AddCircle(x,y);
			going=1;
		}
	}
	
	Stroke;
}

- (void) plotVO_dots:(valueObj *)vo xdat:(NSArray *)xdat ydat:(NSArray *)ydat
{
	[(UIColor *) [tracker.colorSet objectAtIndex:vo.vcolor] set];
	NSEnumerator *e = [ydat objectEnumerator];
	
	for (NSNumber *nx in xdat) {
		CGFloat x = [nx floatValue];
		CGFloat y = [[e nextObject] floatValue];

		DBGLog2(@"moveto %f %f",x,y);
		MoveTo(x,y);
		AddCircle(x,y);
	}
	
	Stroke;
}

- (void) plotVO_bar:(valueObj *)vo xdat:(NSArray *)xdat ydat:(NSArray *)ydat
{
	[(UIColor *) [tracker.colorSet objectAtIndex:vo.vcolor] set];
	CGContextSetAlpha(self.context, BAR_ALPHA);
	
	CGContextSetLineWidth(self.context, BAR_LINE_WIDTH);
	
	NSEnumerator *e = [ydat objectEnumerator];
	
	for (NSNumber *nx in xdat) {
		CGFloat x = [nx floatValue];
		CGFloat y = [[e nextObject] floatValue];

		DBGLog2(@"bar to %f %f",x,y);
		MoveTo(x,BORDER);
		AddLineTo(x,y);
		AddCircle(x,y);
	}
	
	Stroke;
	
	CGContextSetAlpha(self.context, STD_ALPHA);
	CGContextSetLineWidth(self.context, STD_LINE_WIDTH);
	
}


- (void) plotVO:(valueObj *) vo xdat:(NSArray *)xdat ydat:(NSArray *) ydat
{
	switch (vo.vGraphType) {
		case VOG_DOTS:
			[self plotVO_dots:vo xdat:xdat ydat:ydat];
			break;
		case VOG_BAR:
			[self plotVO_bar:vo xdat:xdat ydat:ydat];
			break;
		case VOG_LINE:
			[self plotVO_lines:vo xdat:xdat ydat:ydat];
			break;
		case VOG_DOTSLINE:
			[self plotVO_dotsline:vo xdat:xdat ydat:ydat];
			break;
		case VOG_PIE:
			DBGErr(@"pie chart not yet supported");
			break;
		case VOG_NONE:  // nothing to do!
			break;
		default:
			DBGErr1(@"plotVO: vGraphType %d not recognised",vo.vGraphType);
			break;
	}
}

- (void) drawGraph
{

	for (valueObj *vo in tracker.valObjTable) {
		if (![[vo.optDict objectForKey:@"graph"] isEqualToString:@"0"]) {
			
			NSMutableArray *xdat = [[NSMutableArray alloc] init];
			NSMutableArray *ydat = [[NSMutableArray alloc] init];
			
			[self transformVO:vo xdat:xdat ydat:ydat];
			[self plotVO:vo xdat:xdat ydat:ydat];
			
			[xdat release];
			[ydat release];
		}
	}
		
}

#pragma mark -
#pragma mark drawRect

- (void)drawRect:(CGRect)rect {
    
    if (self.doDrawGraph) {
        self.context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(self.context, STD_LINE_WIDTH);
        CGContextSetAlpha(self.context, STD_ALPHA);
        
        tracker.sql = @"select min(date) from voData;";
        self.firstDate = [tracker toQry2Int];
        tracker.sql = @"select max(date) from voData;";
        self.lastDate =  [tracker toQry2Int];
        tracker.sql = nil;
        
        // transform y to origin at lower left ( -y + height )
        CGAffineTransform tm = { 1.0f , 0.0f, 0.0f, -1.0f, 0.0f, self.bounds.size.height };
        // scale x to date range -- unfortunately buggered because line width is in user coords applied to both x and y
        //CGAffineTransform tm = { ((self.bounds.size.width - 2.0f*BORDER) / (lastDate - firstDate)) , 0.0f, 0.0f, -1.0f, 0.0f, self.bounds.size.height };
        CGContextConcatCTM(self.context,tm);
        // put the text back to normal ... why do they do this?
        //CGAffineTransform tm2 = { 1.0f , 0.0f, 0.0f, -1.0f, 0.0f, 0.0f };
        //CGContextSetTextMatrix(self.context, tm2);
        /*
         CGContextSelectFont (self.context, 
         "Helvetica-Bold",
         FONTSIZE,
         kCGEncodingMacRoman);
         CGContextSetCharacterSpacing (self.context, 1); 
         CGContextSetTextDrawingMode (self.context, kCGTextFill); 
         */
        self.myFont = [UIFont fontWithName:[NSString stringWithUTF8String:FONTNAME] size:FONTSIZE];
        //self.myFont = [UIFont systemFontOfSize:FONTSIZE];
        
        [self drawBackground];
        [self drawAxes];
        [self drawGraph];
    }
    
}


@end
