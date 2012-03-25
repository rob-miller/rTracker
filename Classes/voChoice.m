//
//  voChoice.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>


#import "voChoice.h"
#import "dbg-defs.h"
#import "rTracker-resource.h"

@implementation voChoice

@synthesize ctvovcp,segmentedControl,processingTfDone;

- (id) initWithVO:(valueObj *)valo {
	if ((self = [super initWithVO:valo])) {
		self.processingTfDone=NO;
	}
	return self;
}

- (void) dealloc {
	// ctvovcp is not retained
    self.segmentedControl = nil;
    [segmentedControl release];
	[super dealloc];
}

- (int) getValCap {  // NSMutableString size for value
    return 1;
}

- (UITableViewCell*) voTVCell:(UITableView *)tableView {
	return [super voTVEnabledCell:tableView];
}

- (NSString*) getValueForSegmentChoice {
    int i;
    NSString *rslt = @"";
    NSUInteger segNdx = [self.segmentedControl selectedSegmentIndex];
    if (UISegmentedControlNoSegment != segNdx) {

        NSString *chTitle = [self.segmentedControl titleForSegmentAtIndex:segNdx];
    
        for (i=0; i<CHOICES;i++) {
            NSString *key = [NSString stringWithFormat:@"c%d",i];
            NSString *val = [self.vo.optDict objectForKey:key];
            if ([val isEqualToString:chTitle]) {
                rslt = [NSString stringWithFormat:@"%d",i+1];  // disabled = 0 = no selection; all else gives value
                break;
            }
        }
        dbgNSAssert(i<CHOICES,@"segmentAction: failed to identify choice!");    
    }
    
    return rslt;
}

- (int) getSegmentIndexForValue {
    // doesn't display if e.g only choice 6 configured
    return [self.vo.value integerValue]-1;
}


/*
 - (void) reportscwid {
    int n;
    for (n=0; n< [segmentedControl numberOfSegments]; n++) {
        DBGLog(@"width of seg %d = %f", n, [segmentedControl widthForSegmentAtIndex:n]);
    }    
}
*/

- (void) segmentAction:(id) sender
{
    if ([sender selectedSegmentIndex] == [self getSegmentIndexForValue])
        return;
	DBGLog(@"segmentAction: selected segment = %d", [sender selectedSegmentIndex]);
	[self.vo.value setString:[self getValueForSegmentChoice]];   
    if (@"" == self.vo.value) {  
        [self.vo disableVO];
    } else {
    	[self.vo enableVO];
    }
        
    [[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}

- (UISegmentedControl*) segmentedControl {
    if (nil == segmentedControl) {
        //NSArray *segmentTextContent = [NSArray arrayWithObjects: @"0", @"one", @"two", @"three", @"four", nil];
        
        int i;
        NSMutableArray *segmentTextContent = [[NSMutableArray alloc] init];
        for (i=0;i<CHOICES;i++) {
            NSString *key = [NSString stringWithFormat:@"c%d",i];
            NSString *s = [self.vo.optDict objectForKey:key];
            if ((s != nil) && (![s isEqualToString:@""])) 
                [segmentTextContent addObject:s];
        }
        //[segmentTextContent addObject:nil];
        
        //CGRect frame = bounds;
        segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
        segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;  // resets segment widths to 0
        
        if ([(NSString*) [self.vo.optDict objectForKey:@"shrinkb"] isEqualToString:@"1"]) {  
            int j=0;
            for (NSString *s in segmentTextContent) {
                CGSize siz = [s sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
                [segmentedControl setWidth:siz.width forSegmentAtIndex:j];
                DBGLog(@"set width for seg %d to %f", j, siz.width);
                j++;
            }
            
            // TODO: need to center control in subview for this
        }
        [segmentTextContent release];

        segmentedControl.frame = self.vosFrame;
        [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        
        segmentedControl.tag = kViewTag;
        
//        if ([self.vo.value isEqualToString:@""]) {
//            self.segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
//            [self.vo disableVO];
//        } else {
//            self.segmentedControl.selectedSegmentIndex = [self.vo.value integerValue];
//        }
    }
    
    return segmentedControl;
}

- (UIView*) voDisplay:(CGRect)bounds {

   	
    self.vosFrame = bounds;
    //self.segmentedControl.tag = kViewTag;
    
	// set displayed segment from self.vo.value
    
    if ([self.vo.value isEqualToString:@""]) {
        if (UISegmentedControlNoSegment != self.segmentedControl.selectedSegmentIndex) {
            self.segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
            [self.vo disableVO];
        }
    } else {
        int segNdx = [self getSegmentIndexForValue];
        if (self.segmentedControl.selectedSegmentIndex != segNdx) {
            DBGLog(@"segmentedControl set value int: %d str: %@", [self.vo.value integerValue], self.vo.value);
            // during loadCSV, not matching the string will cause a new c%d dict entry, so can be > CHOICES
            if (CHOICES > segNdx) {
                // normal case
                self.segmentedControl.selectedSegmentIndex = [self getSegmentIndexForValue];
            } else {
                // data can't be shown in buttons but it is there
                // user must fix it, but it is all there to work with by save/edit csv and modify tracker
                self.segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
            }
            [self.vo enableVO];
        }
    }
    DBGLog(@"segmentedControl voDisplay: index %d", self.segmentedControl.selectedSegmentIndex);
    
	return self.segmentedControl;
}

- (NSArray*) voGraphSet {
	return [NSArray arrayWithObjects:@"dots",@"bar",/*@"pie",*/ nil];
}

- (void) ctfDone:(UITextField *)tf
{
    if (YES == self.processingTfDone)
        return;
    self.processingTfDone = YES;
    
	int i=0;
	NSString *key;
	for (key in self.ctvovcp.wDict) {
		if ([self.ctvovcp.wDict objectForKey:key] == tf) {
			const char *kstr = [key UTF8String];
			sscanf(kstr,"%dtf",&i);
			break;
		}
	}
	
	DBGLog(@"set choice %d: %@",i, tf.text);
	[self.vo.optDict setObject:tf.text forKey:[NSString stringWithFormat:@"c%d",i]];
	NSString *cc = [NSString stringWithFormat:@"cc%d",i];
	UIButton *b = [self.ctvovcp.wDict objectForKey:[NSString stringWithFormat:@"%dbtn",i]];
	if ([tf.text isEqualToString:@""]) {
		b.backgroundColor = [UIColor clearColor];
		[self.vo.optDict removeObjectForKey:cc];
		//TODO: should offer to delete any stored data
	} else {
		NSNumber *ncol = [self.vo.optDict objectForKey:cc];
		
		if (ncol == nil) {
			NSInteger col = [self.vo.parentTracker nextColor];
			[self.vo.optDict setObject:[NSNumber numberWithInteger:col] forKey:cc];
			b.backgroundColor = [[rTracker_resource colorSet] objectAtIndex:col];
		} 
	}
	if (++i<CHOICES) {
		[[self.ctvovcp.wDict objectForKey:[NSString stringWithFormat:@"%dtf",i]] becomeFirstResponder];
	} else {
		[tf resignFirstResponder];
	}
    
    self.processingTfDone = NO;
    
}

- (void) choiceColorButtonAction:(UIButton *)btn
{
	int i=0;
	
	for (NSString *key in self.ctvovcp.wDict) {
		if ([self.ctvovcp.wDict objectForKey:key] == btn) {
			const char *kstr = [key UTF8String];
			sscanf(kstr,"%dbtn",&i);
			break;
		}
	}
	
	NSString *cc = [NSString stringWithFormat:@"cc%d",i];
	NSNumber *ncol = [self.vo.optDict objectForKey:cc];
	if (ncol == nil) {
		// do nothing as no choice label set so button not active
	} else {
		NSInteger col = [ncol integerValue];
		if (++col >= [[rTracker_resource colorSet] count])
			col=0;
		[self.vo.optDict setObject:[NSNumber numberWithInteger:col] forKey:cc];
		btn.backgroundColor = [[rTracker_resource colorSet] objectAtIndex:col];
	}
	
}

#pragma mark -
#pragma mark options page 

- (void) setOptDictDflts {
    
    if (nil == [self.vo.optDict objectForKey:@"shrinkb"]) 
        [self.vo.optDict setObject:(SHRINKBDFLT ? @"1" : @"0") forKey:@"shrinkb"];

    return [super setOptDictDflts];
}

- (BOOL) cleanOptDictDflts:(NSString*)key {
    
    NSString *val = [self.vo.optDict objectForKey:key];
    if (nil == val) 
        return YES;
    if (([key isEqualToString:@"shrinkb"] && [val isEqualToString:(SHRINKBDFLT ? @"1" : @"0")])
        ) {
        [self.vo.optDict removeObjectForKey:key];
        return YES;
    }
    
    return [super cleanOptDictDflts:key];
}



- (void) voDrawOptions:(configTVObjVC*)ctvovc {
	self.ctvovcp = ctvovc;
	CGRect frame = {MARGIN,ctvovc.lasty,0.0,0.0};
	
	CGRect labframe = [ctvovc configLabel:@"Choices:" frame:frame key:@"coLab" addsv:YES ];
	
	frame.origin.x = MARGIN;
	frame.origin.y += labframe.size.height + MARGIN;
	
	CGFloat tfWidth = [[NSString stringWithString:@"9999999999"] sizeWithFont:[UIFont systemFontOfSize:18]].width;
	frame.size.width = tfWidth;
	frame.size.height = ctvovc.LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
	int i,j=1;
	for (i=0; i<CHOICES; i++) {
		
		[ctvovc configTextField:frame 
						  key:[NSString stringWithFormat:@"%dtf",i] 
					   target:self
					   action:@selector(ctfDone:) 
						  num:NO 
						place:[NSString stringWithFormat:@"choice %d",i+1]
						 text:[self.vo.optDict objectForKey:[NSString stringWithFormat:@"c%d",i]]
						addsv:YES ];
		
		frame.origin.x += MARGIN + tfWidth;
		
		//frame.size.height = 1.2* frame.size.height;
		frame.size.width = frame.size.height;
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.frame = frame;
		[[btn layer] setCornerRadius:8.0f];
		[[btn layer] setMasksToBounds:YES];
		[[btn layer] setBorderWidth:1.0f];
		NSNumber *cc = [self.vo.optDict objectForKey:[NSString stringWithFormat:@"cc%d",i]];
		if (cc == nil) {
			btn.backgroundColor = [UIColor clearColor];
		} else {
			btn.backgroundColor = [[rTracker_resource colorSet] objectAtIndex:[cc integerValue]];
		}
		
		[btn addTarget:self action:@selector(choiceColorButtonAction:) forControlEvents:UIControlEventTouchDown];
		[ctvovc.wDict setObject:btn forKey:[NSString stringWithFormat:@"%dbtn",i]];
		[ctvovc.view addSubview:btn];
		
		frame.origin.x = MARGIN + (j * (tfWidth + ctvovc.LFHeight + 2*MARGIN));
		j = ( j ? 0 : 1 ); // j toggles 0-1
		frame.origin.y += j * ((2*MARGIN) + ctvovc.LFHeight);
		frame.size.width = tfWidth;
		//frame.size.height = self.labelField.frame.size.height; // lab.frame.size.height;
	}
	
	//frame.origin.y -= MARGIN; // remove extra from end of loop, add one back for next line
	frame.origin.x = MARGIN;
	
	//-- general options label
	
	labframe = [ctvovc configLabel:@"Other options:" frame:frame key:@"goLab" addsv:YES];
	
	frame.origin.y += labframe.size.height + MARGIN;
	
	labframe = [ctvovc configLabel:@"Shrink buttons:" frame:frame key:@"csbLab" addsv:YES];
	
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	
	[ctvovc configCheckButton:frame 
						key:@"csbBtn" 
					  state:[[self.vo.optDict objectForKey:@"shrinkb"] isEqualToString:@"1"] ]; // default:0
	
	ctvovc.lasty = frame.origin.y + frame.size.height + MARGIN;
	[super voDrawOptions:ctvovc];
}	
/*
- (void) transformVO:(NSMutableArray *)xdat ydat:(NSMutableArray *)ydat dscale:(double)dscale height:(CGFloat)height border:(float)border firstDate:(int)firstDate {
    
    [self transformVO_num:xdat ydat:ydat dscale:dscale height:height border:border firstDate:firstDate];
    
}
*/

- (id) newVOGD {
    return [[vogd alloc] initAsNum:self.vo];
}

- (NSString*) mapValue2Csv {
#if DEBUGLOG
    DBGLog(@"val= %@ indexForval= %d obj= %@",
           self.vo.value,
           [self getSegmentIndexForValue],
           [self.vo.optDict objectForKey:[NSString stringWithFormat:@"c%d",[self getSegmentIndexForValue]]] );
#endif
    return [self.vo.optDict objectForKey:[NSString stringWithFormat:@"c%d",[self getSegmentIndexForValue]]];
}

- (NSString*) mapCsv2Value:(NSString*)inCsv {
    NSMutableDictionary *optDict = self.vo.optDict;
    int ndx;
    int count = [optDict count];
    int maxc=0;
    int firstBlank = -1;
    DBGLog(@"inCsv= %@",inCsv);
    for (ndx=0; ndx <count;ndx++) {
        NSString *key = [NSString stringWithFormat:@"c%d",ndx];
        NSString *val = [optDict objectForKey:key];
        if (nil != val) {
            maxc = ndx;
            if ([val isEqualToString:inCsv]) {
                DBGLog(@"matched, returning %d",ndx+1);
                return [NSString stringWithFormat:@"%d",ndx+1];    // found match, return 1-based index and be done
            } else if ((-1 == firstBlank) && ([@"" isEqualToString:val])) {
                firstBlank = ndx;
            }
        }
    }

    // did not find inCsv as an object in optDict for a c%d key.
    
    // is inCsv a digit from a pre-1.0.5 csv save file?
    // TODO: remove this because is only for upgrade to 1.0.5
    int intval = [inCsv intValue];
    if ((0<intval) && (intval < CHOICES+1)) {
        return inCsv;
    }
        
    // need to add a new object to optDict
    
    // if any blanks, put it there. using maxc as ndx now
    if (-1 != firstBlank) {
        maxc = firstBlank;  // this position available
    } else {
        maxc++;  // maxc is last one used because there were no blanks, so inc to next
    }
    
    [optDict setObject:inCsv forKey:[NSString stringWithFormat:@"c%d",maxc]];
    
    maxc++;  // +1 because value not 0-based, while c%d key is
    return [NSString stringWithFormat:@"%d",maxc];
}

@end
