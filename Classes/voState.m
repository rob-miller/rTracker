//
//  voState.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voState.h"
#import "rTracker-constants.h"
#import "configTVObjVC.h"
#import "rTracker-resource.h"

#import "vogd.h"

#import "dbg-defs.h"

@implementation voState

@synthesize vo=_vo,vosFrame=_vosFrame;

- (id) init {
	return [self initWithVO:nil];
}

- (id) initWithVO:(valueObj *)valo {
	if ((self = [super init])) {
		self.vo = valo;
        self.vo.useVO=YES;
	}
	return self;
}


- (int) getValCap {  // NSMutableString size for value
    return 10;
}

- (NSString*) update:(NSString*)instr {   // place holder so fn can update on access; also confirm textfield updated
                                        // added return "" if disabled 30.vii.13
    if (self.vo.useVO) {
        return instr;
    } else {
        return @"";
    }
}

- (void) loadConfig {
}


- (void) setOptDictDflts {
    
    if (nil == (self.vo.optDict)[@"graph"]) 
        (self.vo.optDict)[@"graph"] = (GRAPHDFLT ? @"1" : @"0");
    if (nil == (self.vo.optDict)[@"privacy"]) 
        (self.vo.optDict)[@"privacy"] = [NSString stringWithFormat:@"%d",PRIVDFLT];
    
}

- (BOOL) cleanOptDictDflts:(NSString*)key {
    
    NSString *val = (self.vo.optDict)[key];
    if (nil == val) 
        return YES;
    
    if (([key isEqualToString:@"graph"] && [val isEqualToString:(GRAPHDFLT ? @"1" : @"0")])
        ||
        ([key isEqualToString:@"privacy"] && ([val intValue] == PRIVDFLT))) {
        [self.vo.optDict removeObjectForKey:key];
        return YES;
    }
    
    return NO;
    
    //if ( 
        //([key isEqualToString:@"autoscale"] && [val isEqualToString:(AUTOSCALEDFLT ? @"1" : @"0")])
        //||
        //([key isEqualToString:@"shrinkb"] && [val isEqualToString:(SHRINKBDFLT ? @"1" : @"0")])
        //||
        //([key isEqualToString:@"tbnl"] && [val isEqualToString:(TBNLDFLT ? @"1" : @"0")])
        //||
        //([key isEqualToString:@"tbni"] && [val isEqualToString:(TBNIDFLT ? @"1" : @"0")])
        //||
        //([key isEqualToString:@"tbhi"] && [val isEqualToString:(TBHIDFLT ? @"1" : @"0")])
        //||
        //([key isEqualToString:@"graph"] && [val isEqualToString:(GRAPHDFLT ? @"1" : @"0")])
        //||
        //([key isEqualToString:@"nswl"] && [val isEqualToString:(NSWLDFLT ? @"1" : @"0")])
        //||
        //([key isEqualToString:@"func"] && [val isEqualToString:@""])
        //||
        //([key isEqualToString:@"smin"] && ([val floatValue] == f(SLIDRMINDFLT)))
        //||
        //([key isEqualToString:@"smax"] && ([val floatValue] == f(SLIDRMAXDFLT)))
        //||
        //([key isEqualToString:@"sdflt"] && ([val floatValue] == f(SLIDRDFLTDFLT)))
        //||
        //([key isEqualToString:@"frep0"] && ([val intValue] == FREPDFLT))
        //||
        //([key isEqualToString:@"frep1"] && ([val intValue] == FREPDFLT))
        //||
        //([key isEqualToString:@"fnddp"] && ([val intValue] == FDDPDFLT))
        //||
        //([key isEqualToString:@"privacy"] && ([val intValue] == PRIVDFLT))
     //   ) {
    //}
    
    //return [self.vos cleanOptDictDflts:key];
}


- (void) voDrawOptions:(configTVObjVC*)ctvovc {
	CGRect frame = {MARGIN,ctvovc.lasty,0.0,0.0};
	
	CGRect labframe = [ctvovc configLabel:@"Draw graph:" frame:frame key:@"ggLab" addsv:YES];
	
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	
	//-- draw graphs button
	
	[ctvovc configCheckButton:frame 
                          key:@"ggBtn" 
                        state:(![(self.vo.optDict)[@"graph"] isEqualToString:@"0"])  // default = @"1"
                        addsv:YES
     ];
	
	//-- privacy level label
	
	frame.origin.x += frame.size.width + MARGIN + SPACE;
	//frame.origin.y += MARGIN + frame.size.height;
	labframe = [ctvovc configLabel:@"Privacy level:" frame:frame key:@"gpLab" addsv:YES];
	
	//-- privacy level textfield
	
	frame.origin.x += labframe.size.width + SPACE;
    CGFloat tfWidth = [@"9999" sizeWithAttributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]}].width;
	frame.size.width = tfWidth;
	frame.size.height = ctvovc.LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
	[ctvovc configTextField:frame 
						key:@"gpTF" 
					 target:nil 
					 action:nil
						num:YES 
					  place:[NSString stringWithFormat:@"%d",PRIVDFLT] 
					   text:(self.vo.optDict)[@"privacy"]
					  addsv:YES ];
	
	
}

- (UIView*) voDisplay:(CGRect)bounds {
    dbgNSAssert(0,@"viDisplay failed to dispatch");
	return nil;
}


#define LMARGIN 60.0f
#define RMARGIN 10.0f
#define BMARGIN  7.0f


- (UITableViewCell*) voTVEnabledCell:(UITableView *)tableView {
	
	CGRect bounds;
	UITableViewCell *cell;
	CGSize maxLabel = ((trackerObj*)self.vo.parentTracker).maxLabel;
	DBGLog(@"votvenabledcell maxlabel= w= %f h= %f",maxLabel.width,maxLabel.height);
    
	static NSString *CellIdentifier = @"Cell1";
	
	cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor=nil;
	} else {
		// the cell is being recycled, remove old embedded controls
		UIView *viewToRemove = nil;
		while ((viewToRemove = [cell.contentView viewWithTag:kViewTag]))
			[viewToRemove removeFromSuperview];
	}
	
	
	//cell.accessoryType = UITableViewCellAccessoryCheckmark;
	
	// checkButton top row left
	
	UIImage *checkImage = [UIImage imageNamed:@"checked.png"];
	
	bounds.origin.x = MARGIN;
	bounds.origin.y = MARGIN;
    /* changed to constant 30x30 7.iv.2013
	bounds.size.width = checkImage.size.width ; //CHECKBOX_WIDTH; // cell.frame.size.width;
	bounds.size.height = checkImage.size.height ; //self.tracker.maxLabel.height + 2*BMARGIN; //CELL_HEIGHT_TALL/2.0; //self.tracker.maxLabel.height + BMARGIN;
     */
    bounds.size.width = 30.0f;  // for checkbox
    bounds.size.height = 30.0f;
	

	self.vo.checkButtonUseVO.frame = bounds;
	self.vo.checkButtonUseVO.tag = kViewTag;
	self.vo.checkButtonUseVO.backgroundColor = cell.backgroundColor;
	
	//if (! self.vo.retrievedData) {  // only show enable checkbox if this is data entry mode (not show historical)  
		// 26 mar 2011 -- why not show for historical ?
        // 30 mar 2011 -- seems like checkbuttonusevo should be correct state if use enablevo everywhere; else don't use it
		UIImage *image = (self.vo.useVO) ? checkImage : [UIImage imageNamed:@"unchecked.png"];
		UIImage *newImage = [image stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		[self.vo.checkButtonUseVO setImage:newImage forState:UIControlStateNormal];
		[cell.contentView addSubview:self.vo.checkButtonUseVO];
	//}
	
    cell.backgroundColor = [UIColor clearColor];

    // cell label top row right
	
	bounds.origin.x += checkImage.size.width + MARGIN;
    
    // [rTracker_resource getKeyWindowWidth] - maxLabel.width - LMARGIN - RMARGIN;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    bounds.size.width =  screenSize.width - checkImage.size.width - (2.0*MARGIN); //cell.frame.size.width - checkImage.size.width - (2.0*MARGIN);
	bounds.size.height = maxLabel.height + MARGIN; //CELL_HEIGHT_TALL/2.0; //self.tracker.maxLabel.height + BMARGIN;
	

    NSArray *splitStrArr = [self.vo.valueName componentsSeparatedByString:@"|"];
    if (1<[splitStrArr count]) {
        bounds.size.width /= 2.0;
    }
	UILabel *label = [[UILabel alloc] initWithFrame:bounds];
	label.tag=kViewTag;
	//label.font = [UIFont boldSystemFontOfSize:18.0];
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    label.textColor = [UIColor blackColor];
    label.alpha = 1.0;
    label.backgroundColor = [UIColor clearColor];
    //label.textColor = [UIColor blackColor];
    
    label.textAlignment = NSTextAlignmentLeft;  // ios6 UITextAlignmentLeft;
	//don't use - messes up for loarger displays -- label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin; // | UIViewAutoresizingFlexibleHeight;
    label.contentMode = UIViewContentModeTopLeft;
    label.text = splitStrArr[0]; //self.vo.valueName;
    //label.enabled = YES;
    DBGLog(@"enabled text= %@",label.text);


	[cell.contentView addSubview:label];

    if (1<[splitStrArr count]) {
        bounds.origin.x += bounds.size.width;
        bounds.size.width -= (2.0*MARGIN);
        label = [[UILabel alloc] initWithFrame:bounds];
        label.tag=kViewTag;
        //label.font = [UIFont boldSystemFontOfSize:18.0];
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        label.textColor = [UIColor blackColor];
        label.alpha = 1.0;
        label.backgroundColor = [UIColor clearColor];
        //label.textColor = [UIColor blackColor];
        
        label.textAlignment = NSTextAlignmentRight;  // ios6 UITextAlignmentLeft;
        // don't use - see above -- label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin; // | UIViewAutoresizingFlexibleHeight;
        label.contentMode = UIViewContentModeTopRight;
        label.text = splitStrArr[1]; //self.vo.valueName;

        //label.enabled = YES;
        DBGLog(@"enabled text2= %@",label.text);
        
        [cell.contentView addSubview:label];
    }
  
	bounds.origin.y = maxLabel.height + (3.0*MARGIN); //CELL_HEIGHT_TALL/2.0 + MARGIN; // 38.0f; //bounds.size.height; // + BMARGIN;
	bounds.size.height = /*CELL_HEIGHT_TALL/2.0 ; // */ maxLabel.height + (1.5*MARGIN);
	
	bounds.size.width = screenSize.width - (2.0f * MARGIN); // cell.frame.size.width - (2.0f * MARGIN);
	bounds.origin.x = MARGIN; // 0.0f ;  //= bounds.origin.x + RMARGIN;
	
    //DBGLog(@"votvenabledcell adding subview");
	[cell.contentView addSubview:[self.vo display:bounds]];
    return cell;
	
}

- (UITableViewCell*) voTVCell:(UITableView *)tableView {
	
	CGRect bounds;
	UITableViewCell *cell;
    
	CGSize maxLabel = ((trackerObj*)self.vo.parentTracker).maxLabel;
	//DBGLog(@"votvcell maxlabel= w= %f h= %f",maxLabel.width,maxLabel.height);
	
	static NSString *CellIdentifier = @"Cell2";
	
	cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell.backgroundColor=nil;
        //ell.backgroundColor = [UIColor clearColor];
        //cell.backgroundColor = [UIColor blueColor];
        //DBGLog(@"new cell");
	} else {
		// the cell is being recycled, remove old embedded controls
        /*
        NSArray *subviews = [cell.contentView subviews];
        for (UIView *sv in subviews) {
            [sv removeFromSuperview];
        }
        */
        
		UIView *viewToRemove = nil;
		while ((viewToRemove = [cell.contentView viewWithTag:kViewTag])) {
            //DBGLog(@"removing");
			[viewToRemove removeFromSuperview];
        }
        
        // removes too much [cell.contentView removeFromSuperview];
        
        //DBGLog(@"recycled cell");
	}
#if DEBUGLOG
    CGFloat cellWidth = cell.bounds.size.width;
#endif
    
    DBGLog(@"cell width= %f",cellWidth);
    DBGLog(@"kw width= %f",[rTracker_resource getKeyWindowWidth]);
    
	cell.textLabel.text = self.vo.valueName;
    //DBGLog(@"text= %@",cell.textLabel.text);
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
	//cell.textLabel.tag = kViewTag;
    
    
    //TODO: re-work here to put vo field right-justified in any size cell
    
    //CGSize screenSize = [[UIScreen mainScreen] bounds].size;
	bounds.origin.x = cell.frame.origin.x + maxLabel.width + LMARGIN;
    //bounds.origin.x = cell.frame.origin.x + (cell.frame.size.width )
	bounds.origin.y = maxLabel.height - (MARGIN);
	bounds.size.width = [rTracker_resource getKeyWindowWidth] - maxLabel.width - LMARGIN - RMARGIN;// cell.frame.size.width - maxLabel.width - LMARGIN - RMARGIN;
    //bounds.size.width = screenSize.width - maxLabel.width - LMARGIN - RMARGIN;
	bounds.size.height = maxLabel.height + MARGIN;
	
	//DBGLog(@"maxLabel: % f %f",self.tracker.maxLabel.width, self.tracker.maxLabel.height);
	//bounds.origin.y = bounds.size.height;// - BMARGIN;
	
	//DBGLog(@"bounds= %f %f %f %f",bounds.origin.x,bounds.origin.y,bounds.size.width, bounds.size.height)	;
	[cell.contentView addSubview:[self.vo display:bounds]];
	return cell;
}

-(CGFloat)voTVCellHeight {
    return CELL_HEIGHT_NORMAL;
}

- (void) dataEditVDidLoad:(UIViewController*)vc {
}
- (void) dataEditVWAppear:(UIViewController*)vc {
}
- (void) dataEditVWDisappear:(UIViewController*)vc {
}

/*
- (void) dataEditVDidUnload {
}
*/

//- (void) dataEditFinished {
//}

- (NSArray*) voGraphSet {
	return @[@"dots"];
}

+ (NSArray*) voGraphSetNum {
	return @[@"dots",@"bar",@"line", @"line+dots"];
}


- (void) updateVORefs:(NSInteger)newVID old:(NSInteger)oldVID {
	// subclass overrides if need to do anything
}

- (id) newVOGD {
    DBGErr(@"newVOGD with no handler!");
    return [[vogd alloc] initAsNum:self.vo];
}

/*
- (void) recalculate {
	// subclass overrides if need to do anything
}
*/

-(void) setFnVals:(int)tDate {
// subclass overrides if need to do anything
}

-(void) doTrimFnVals {
	// subclass overrides if need to do anything
}


- (void) resetData {
	// subclass overrides if need to do anything
    self.vo.useVO=YES;
}

- (NSString*) mapValue2Csv {
    return (NSString*) self.vo.value;  	// subclass overrides if need to do anything - specifically for choice, textbox
}

- (NSString*) mapCsv2Value:(NSString*)inCsv {
    return inCsv;        // subclass overrides if need to do anything - specifically for choice
}

/*
- (void) transformVO:(NSMutableArray *)xdat ydat:(NSMutableArray *)ydat dscale:(double)dscale height:(CGFloat)height border:(float)border firstDate:(int)firstDate {
    DBGErr(@"transformVO with no handler!");
}

- (void) transformVO_num:(NSMutableArray *)xdat ydat:(NSMutableArray *)ydat dscale:(double)dscale height:(CGFloat)height border:(float)border firstDate:(int)firstDate {
	//double dscale = d(self.bounds.size.width - (2.0f*BORDER)) / d(self.lastDate - self.firstDate);
	double minVal,maxVal;
    
    trackerObj *myTracker = (trackerObj*) self.vo.parentTracker;
    
	if ((self.vo.vtype == VOT_NUMBER || self.vo.vtype == VOT_FUNC) 
        && ([@"0" isEqualToString:[self.vo.optDict objectForKey:@"autoscale"]])
        ) { 
        //DBGLog(@"autoscale= %@", [self.vo.optDict objectForKey:@"autoscale"]);
		minVal = [[self.vo.optDict objectForKey:@"gmin"] doubleValue];
		maxVal = [[self.vo.optDict objectForKey:@"gmax"] doubleValue];
	} else if (self.vo.vtype == VOT_SLIDER) {
		NSNumber *nmin = [self.vo.optDict objectForKey:@"smin"];
		NSNumber *nmax = [self.vo.optDict objectForKey:@"smax"];
		minVal = ( nmin ? [nmin doubleValue] : d(SLIDRMINDFLT) );
		maxVal = ( nmax ? [nmax doubleValue] : d(SLIDRMAXDFLT) );
	} else if (self.vo.vtype == VOT_CHOICE) {
		minVal = d(0);
		maxVal = CHOICES+1;
	} else {
	sql = [NSString stringWithFormat:@"select min(val collate CMPSTRDBL) from voData where id=%d;",self.vo.vid];
		minVal = [myTracker toQry2Double:sql];
	sql = [NSString stringWithFormat:@"select max(val collate CMPSTRDBL) from voData where id=%d;",self.vo.vid];
		maxVal = [myTracker toQry2Double:sql];
	}
	
	if (minVal == maxVal) {
		minVal = 0.0f;
	}
	if (minVal == maxVal) {
		minVal = 1.0f;
	}
	
	//double vscale = d(self.bounds.size.height - (2.0f*BORDER)) / (maxVal - minVal);
    double vscale = d(height - (2.0f*border)) / (maxVal - minVal);
    
	NSMutableArray *i1 = [[NSMutableArray alloc] init];
	NSMutableArray *d1 = [[NSMutableArray alloc] init];
	myTracker.sql = [NSString stringWithFormat:@"select date,val from voData where id=%d order by date;",self.vo.vid];
	[myTracker toQry2AryID:i1 d1:d1];
	myTracker.sql=nil;
	
	NSEnumerator *e = [d1 objectEnumerator];
	
	for (NSNumber *ni in i1) {
        
		NSNumber *nd = [e nextObject];
		
		DBGLog(@"i: %@  f: %@",ni,nd);
		double d = [ni doubleValue];		// date as int secs cast to float
		double v = [nd doubleValue] ;		// val as float
		
		d -= (double) firstDate; // self.firstDate;
		d *= dscale;
		v -= minVal;
		v *= vscale;
		
		d+= border; //BORDER;
		v+= border; //BORDER;
        // done by doDrawGraph ? : why does this code run again after rotate to portrait?
		DBGLog(@"num final: %f %f",d,v);
		[xdat addObject:[NSNumber numberWithDouble:d]];
		[ydat addObject:[NSNumber numberWithDouble:v]];
		
	}
	
	[i1 release];
	[d1 release];
}

- (void) transformVO_note:(NSMutableArray *)xdat ydat:(NSMutableArray *) ydat dscale:(double)dscale height:(CGFloat)height border:(float)border firstDate:(int)firstDate {

	//double dscale = d(self.bounds.size.width - (2.0f*BORDER)) / d(self.lastDate - self.firstDate);
    trackerObj *myTracker = (trackerObj*) self.vo.parentTracker;
    
	NSMutableArray *i1 = [[NSMutableArray alloc] init];
	myTracker.sql = [NSString stringWithFormat:@"select date from voData where id=%d and val not NULL order by date;",self.vo.vid];
	[myTracker toQry2AryI:i1];
	myTracker.sql=nil;
	
	for (NSNumber *ni in i1) {
        
		DBGLog(@"i: %@  ",ni);
		double d = [ni doubleValue];		// date as int secs cast to float
		
		d -= (double) firstDate;
		d *= dscale;
		d+= border;
        
		[xdat addObject:[NSNumber numberWithDouble:d]];
		[ydat addObject:[NSNumber numberWithFloat:(border + (height/10))]];   // DEFAULT_PT=BORDER+5
		
	}
	[i1 release];
}

- (void) transformVO_bool:(NSMutableArray *)xdat ydat:(NSMutableArray *) ydat dscale:(double)dscale height:(CGFloat)height border:(float)border firstDate:(int)firstDate {
	//double dscale = d(self.bounds.size.width - (2.0f*BORDER)) / d(self.lastDate - self.firstDate);
    trackerObj *myTracker = (trackerObj*) self.vo.parentTracker;
	
	NSMutableArray *i1 = [[NSMutableArray alloc] init];
	myTracker.sql = [NSString stringWithFormat:@"select date from voData where id=%d and val='1' order by date;",self.vo.vid];
	[myTracker toQry2AryI:i1];
	myTracker.sql=nil;
	
	for (NSNumber *ni in i1) {
		
		DBGLog(@"i: %@  ",ni);
		double d = [ni doubleValue];		// date as int secs cast to float
		
		d -= (double) firstDate;
		d *= dscale;
		d+= border;
		
		[xdat addObject:[NSNumber numberWithDouble:d]];
		[ydat addObject:[NSNumber numberWithFloat:(border + (height/10))]];   // DEFAULT_PT=BORDER+5
		
	}
	[i1 release];
}
*/

@end
