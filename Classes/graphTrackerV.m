//
//  graphTrackerV.m
//  rTracker
//
//  Created by Robert Miller on 28/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "graphTrackerV.h"


@implementation graphTrackerV

@synthesize tracker;
@synthesize context;

@synthesize firstDate,lastDate,myFont;


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

#define MoveTo(x,y) CGContextMoveToPoint(self.context,(x),(y))
#define AddLineTo(x,y) CGContextAddLineToPoint(self.context,(x),(y))
#define AddCircle(x,y) CGContextAddEllipseInRect(self.context, (CGRect) {{(x),(y)},{4.0f,4.0f}})

#define DevPt(x,y) CGContextConvertPointToUserSpace(self.context,(CGPoint){(x),(y)})
#define Stroke CGContextStrokePath(self.context)

#define f(x) ((CGFloat) (x))
#define d(x) ((double) (x))

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

		NSDate *sd = [NSDate dateWithTimeIntervalSince1970:date];
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
	
	sd = [NSDate dateWithTimeIntervalSince1970:self.lastDate];
	datestr = [NSDateFormatter localizedStringFromDate:sd dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
	dta = [datestr componentsSeparatedByString:@" "];
	/*
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

- (void) transformVO_num:(valueObj *) vo xdat:(NSMutableArray *)xdat ydat:(NSMutableArray *) ydat
{
	double dscale = d(self.bounds.size.width - (2.0f*BORDER)) / d(self.lastDate - self.firstDate);

	tracker.sql = [NSString stringWithFormat:@"select min(val collate CMPSTRDBL) from voData where id=%d;",vo.vid];
	double minVal = [tracker toQry2Double];
		
	tracker.sql = [NSString stringWithFormat:@"select max(val collate CMPSTRDBL) from voData where id=%d;",vo.vid];
	double maxVal = [tracker toQry2Double];
	if (minVal == maxVal) {
		minVal = 0.0f;
	}
	if (minVal == maxVal) {
		minVal = 1.0f;
	}
	
	double vscale = d(self.bounds.size.height - (2.0f*BORDER)) / (maxVal - minVal);
		
	NSMutableArray *i1 = [[NSMutableArray alloc] init];
	NSMutableArray *d1 = [[NSMutableArray alloc] init];
	tracker.sql = [NSString stringWithFormat:@"select date,val from voData where id=%d order by date;",vo.vid];
	[tracker toQry2AryID:i1 d1:d1];
	tracker.sql=nil;
	
	NSEnumerator *e = [d1 objectEnumerator];
	
	for (NSNumber *ni in i1) {

		NSNumber *nd = [e nextObject];
		
		NSLog(@"i: %@  f: %@",ni,nd);
		double d = [ni doubleValue];		// date as int secs cast to float
		double v = [nd doubleValue] ;		// val as float
		
		d -= (double) self.firstDate;
		d *= dscale;
		v -= minVal;
		v *= vscale;
		
		d+= BORDER;
		v+= BORDER;

		NSLog(@"num final: %f %f",d,v);
		[xdat addObject:[NSNumber numberWithDouble:d]];
		[ydat addObject:[NSNumber numberWithDouble:v]];
		
	}
	
	[i1 release];
	[d1 release];
}

- (void) transformVO_note:(valueObj *) vo xdat:(NSMutableArray *)xdat ydat:(NSMutableArray *) ydat
{
	double dscale = d(self.bounds.size.width - (2.0f*BORDER)) / d(self.lastDate - self.firstDate);

	NSMutableArray *i1 = [[NSMutableArray alloc] init];
	tracker.sql = [NSString stringWithFormat:@"select date from voData where id=%d and val not NULL order by date;",vo.vid];
	[tracker toQry2AryI:i1];
	tracker.sql=nil;
	
	for (NSNumber *ni in i1) {

		NSLog(@"i: %@  ",ni);
		double d = [ni doubleValue];		// date as int secs cast to float
		
		d -= (double) self.firstDate;
		d *= dscale;
		d+= BORDER;

		[xdat addObject:[NSNumber numberWithDouble:d]];
		[ydat addObject:[NSNumber numberWithFloat:DEFAULT_PT]];
		
	}
	[i1 release];
}

- (void) transformVO_bool:(valueObj *) vo xdat:(NSMutableArray *)xdat ydat:(NSMutableArray *) ydat
{
	double dscale = d(self.bounds.size.width - (2.0f*BORDER)) / d(self.lastDate - self.firstDate);
	
	NSMutableArray *i1 = [[NSMutableArray alloc] init];
	tracker.sql = [NSString stringWithFormat:@"select date from voData where id=%d and val='1' order by date;",vo.vid];
	[tracker toQry2AryI:i1];
	tracker.sql=nil;
	
	for (NSNumber *ni in i1) {
		
		NSLog(@"i: %@  ",ni);
		double d = [ni doubleValue];		// date as int secs cast to float
		
		d -= (double) self.firstDate;
		d *= dscale;
		d+= BORDER;
		
		[xdat addObject:[NSNumber numberWithDouble:d]];
		[ydat addObject:[NSNumber numberWithFloat:DEFAULT_PT]];
		
	}
	[i1 release];
}


- (void) transformVO:(valueObj *) vo xdat:(NSMutableArray *)xdat ydat:(NSMutableArray *) ydat
{
	switch (vo.vtype) {
		case VOT_NUMBER:
		case VOT_SLIDER:
			[self transformVO_num:vo xdat:xdat ydat:ydat];
			break;
		case VOT_TEXT:
		case VOT_TEXTB:
		case VOT_IMAGE:
			[self transformVO_note:vo xdat:xdat ydat:ydat];
			break;
		case VOT_BOOLEAN:
			[self transformVO_bool:vo xdat:xdat ydat:ydat];
		case VOT_PICK:
			NSLog(@"transform for mult choice not done yet");
			break;
		case VOT_FUNC:
			NSLog(@"transform for function not done yet");
			break;
		default:
			NSLog(@"transformVO: vtype %d not recognised",vo.vtype);
			break;
	}
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
			NSLog(@"addline %f %f",x,y);
			AddLineTo(x,y);
		} else {
			NSLog(@"moveto %f %f",x,y);
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
			NSLog(@"addline %f %f",x,y);
			AddLineTo(x,y);
			AddCircle(x,y);
		} else {
			NSLog(@"moveto %f %f",x,y);
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

		NSLog(@"moveto %f %f",x,y);
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

		NSLog(@"bar to %f %f",x,y);
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
			NSLog(@"pie chart not yet supported");
			break;
		default:
			NSLog(@"plotVO: vGraphType %d not recognised",vo.vGraphType);
			break;
	}
}

- (void) drawGraph
{

	for (valueObj *vo in tracker.valObjTable) {
		NSMutableArray *xdat = [[NSMutableArray alloc] init];
		NSMutableArray *ydat = [[NSMutableArray alloc] init];
		
		[self transformVO:vo xdat:xdat ydat:ydat];
		[self plotVO:vo xdat:xdat ydat:ydat];
		
		[xdat release];
		[ydat release];
	}
		
}

#pragma mark -
#pragma mark drawRect

- (void)drawRect:(CGRect)rect {

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


@end
