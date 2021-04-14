/***************
 voChoice.m
 Copyright 2010-2021 Robert T. Miller
 
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

@synthesize ctvovcp=_ctvovcp,segmentedControl=_segmentedControl,processingTfDone=_processingTfDone,processingTfvDone=_processingTfvDone;

- (id) initWithVO:(valueObj *)valo {
	if ((self = [super initWithVO:valo])) {
		self.processingTfDone=NO;
        self.vo.useVO=NO;
	}
	return self;
}

- (void) resetData {
    self.vo.useVO=NO;
}


- (int) getValCap {  // NSMutableString size for value
    return 1;
}

- (UITableViewCell*) voTVCell:(UITableView *)tableView {
	return [super voTVEnabledCell:tableView];
	//return [super voTVCell:tableView];
}

-(CGFloat)voTVCellHeight {
    //return CELL_HEIGHT_TALL;
    return self.segmentedControl.frame.size.height + (3*MARGIN) + [self.vo getLabelSize].height + [self.vo getLongTitleSize].height;
    
}


- (NSString*) getValueForSegmentChoice {
    //int i;
    NSString *rslt = @"";
    NSUInteger segNdx = [self.segmentedControl selectedSegmentIndex];
    if (UISegmentedControlNoSegment != segNdx) {

        NSString *val = (self.vo.optDict)[[NSString stringWithFormat:@"cv%lu",(unsigned long)segNdx]];
        if (nil == val) {
            rslt = [NSString stringWithFormat:@"%lu",(unsigned long)segNdx+1];
        } else {
            rslt = val;
        }
#if DEBUGLOG
        NSString *chTitle = [self.segmentedControl titleForSegmentAtIndex:segNdx];
        DBGLog(@"get v for seg title %@ ndx %lu rslt %@",chTitle,(unsigned long)segNdx,rslt);  // why tf not just return fn on segNdx?
#endif
/*
        for (i=0; i<CHOICES;i++) {
            NSString *key = [NSString stringWithFormat:@"c%d",i];
            NSString *val = [self.vo.optDict objectForKey:key];
            if ([val isEqualToString:chTitle]) {
                rslt = [NSString stringWithFormat:@"%d",i+1];  // disabled = 0 = no selection; all else gives value
                break;
            }
        }
        dbgNSAssert(i<CHOICES,@"segmentAction: failed to identify choice!");
*/
    }
    
    return rslt;
}


- (int) getSegmentIndexForValue {
    return [self.vo getChoiceIndexForValue:self.vo.value];
    /*
    // doesn't display if e.g only choice 6 configured
    // rtm change with 'specify choice values' 24.xii.2012 return [self.vo.value integerValue]-1;
    NSString *currVal = self.vo.value;
    //DBGLog(@"gsiv val=%@",currVal);
    for (int i=0; i<CHOICES; i++) {
        NSString *key = [NSString stringWithFormat:@"cv%d",i];
        NSString *tstVal = [self.vo.optDict valueForKey:key];  
        if (nil == tstVal) {
            tstVal = [NSString stringWithFormat:@"%d",i];  // added 7.iv.2013 - need default value
        }
        //DBGLog(@"gsiv test against %d: %@",i,tstVal);
        if ([tstVal isEqualToString:currVal]) {
            return i;
        }
    }
    return CHOICES;
     */
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
    if (([sender selectedSegmentIndex] == [self getSegmentIndexForValue]) && self.vo.useVO) // check useVO in case programmed value is same as index 
        return;
	DBGLog(@"segmentAction: selected segment = %ld", (long)[sender selectedSegmentIndex]);
	[self.vo.value setString:[self getValueForSegmentChoice]];
    //TODO: vo.value setter should do enable/disable ?
    if (! self.vo.useVO) {
        [self.vo enableVO];
    }
    /*
    if ([@"" isEqual: self.vo.value]) {
        [self.vo disableVO];
    } else {
    	[self.vo enableVO];
    }
    */  
    [[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}

- (UISegmentedControl*) segmentedControl {
    if (_segmentedControl && _segmentedControl.frame.size.width != self.vosFrame.size.width) _segmentedControl=nil;  // first time around thinks size is 320, handle larger devices

    if (nil == _segmentedControl) {
        //NSArray *segmentTextContent = [NSArray arrayWithObjects: @"0", @"one", @"two", @"three", @"four", nil];
        
        int i;
        NSMutableArray *segmentTextContent = [[NSMutableArray alloc] init];
        for (i=0;i<CHOICES;i++) {
            NSString *key = [NSString stringWithFormat:@"c%d",i];
            NSString *s = (self.vo.optDict)[key];
            if ((s != nil) && (![s isEqualToString:@""])) 
                [segmentTextContent addObject:s];
        }
        //[segmentTextContent addObject:nil];
        
        //CGRect frame = bounds;
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
        //_segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;  // resets segment widths to 0
        
        if ([(NSString*) (self.vo.optDict)[@"shrinkb"] isEqualToString:@"1"]) {  
            /*
            int j=0;
            for (NSString *s in segmentTextContent) {
                CGSize siz = [s sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[UIFont systemFontSize]]}];
                [_segmentedControl setWidth:siz.width forSegmentAtIndex:j];
                DBGLog(@"set width for seg %d to %f", j, siz.width);
                j++;
            }
            
            // TODO: need to center control in subview for this
            // */
            _segmentedControl.apportionsSegmentWidthsByContent=YES;
        }

        _segmentedControl.frame = self.vosFrame;
        [_segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        
        _segmentedControl.tag = kViewTag;
        
//        if ([self.vo.value isEqualToString:@""]) {
//            self.segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
//            [self.vo disableVO];
//        } else {
//            self.segmentedControl.selectedSegmentIndex = [self.vo.value integerValue];
//        }
    }
    
    return _segmentedControl;
}

- (UIView*) voDisplay:(CGRect)bounds {

   	
    self.vosFrame = bounds;

	// set displayed segment from self.vo.value
    
    if ([self.vo.value isEqualToString:@""]) {
        if (UISegmentedControlNoSegment != self.segmentedControl.selectedSegmentIndex) {
            self.segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
            [self.vo disableVO];
        }
    } else {
        int segNdx = [self getSegmentIndexForValue];
        if (self.segmentedControl.selectedSegmentIndex != segNdx) {
            DBGLog(@"segmentedControl set value int: %ld str: %@ segNdx: %d", (long)[self.vo.value integerValue], self.vo.value,segNdx);
            // during loadCSV, not matching the string will cause a new c%d dict entry, so can be > CHOICES
            if (CHOICES > segNdx) {
                // normal case
                self.segmentedControl.selectedSegmentIndex = segNdx;
                //[self.segmentedControl setSelectedSegmentIndex:[self getSegmentIndexForValue]];
            } else {
                // data can't be shown in buttons but it is there
                // user must fix it, but it is all there to work with by save/edit csv and modify tracker
                self.segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
            }
            [self.vo enableVO];
        }
    }
    //[self.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
    DBGLog(@"segmentedControl voDisplay: index %ld", (long)self.segmentedControl.selectedSegmentIndex);
    
	return self.segmentedControl;
}

- (NSArray*) voGraphSet {
	return @[@"dots",@"bar"];
}

- (void) ctfDone:(UITextField *)tf
{
    if (YES == self.processingTfDone)
        return;
    self.processingTfDone = YES;
    
	int i=0;
	NSString *key;
	for (key in self.ctvovcp.wDict) {
		if ((self.ctvovcp.wDict)[key] == tf) {
			const char *kstr = [key UTF8String];
			sscanf(kstr,"%dtf",&i);
			break;
		}
	}
	
	DBGLog(@"set choice %d: %@",i, tf.text);
    tf.text = [tf.text stringByReplacingOccurrencesOfString:@"'" withString:@""];  // these mess up sqlite -- could escape but lazy!
    tf.text = [tf.text stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    (self.vo.optDict)[[NSString stringWithFormat:@"c%d",i]] = tf.text;
    NSString *cc = [NSString stringWithFormat:@"cc%d",i];
    
	UIButton *b = (self.ctvovcp.wDict)[[NSString stringWithFormat:@"%dbtn",i]];
	if ([tf.text isEqualToString:@""]) {
		b.backgroundColor = [UIColor clearColor];
		[self.vo.optDict removeObjectForKey:cc];
		//TODO: should offer to delete any stored data
	} else {
		NSNumber *ncol = (self.vo.optDict)[cc];
		
		if (ncol == nil) {
			NSInteger col = [self.vo.parentTracker nextColor];
			(self.vo.optDict)[cc] = @(col);
			b.backgroundColor = [rTracker_resource colorSet][col];
		} 
	}
	if (++i<CHOICES) {
		[(self.ctvovcp.wDict)[[NSString stringWithFormat:@"%dtf",i]] becomeFirstResponder];
	} else {
		[tf resignFirstResponder];
	}
    
    self.processingTfDone = NO;
    
}
//TODO: merge these two?
- (void) ctfvDone:(UITextField *)tf
{
    if (YES == self.processingTfvDone)
        return;
    self.processingTfvDone = YES;
    
	int i=0;
	NSString *key;
	for (key in self.ctvovcp.wDict) {
		if ((self.ctvovcp.wDict)[key] == tf) {
			const char *kstr = [key UTF8String];
			sscanf(kstr,"%dtfv",&i);
			break;
		}
	}
	
    if (! [@"" isEqualToString:tf.text]) {
        DBGLog(@"set choice value %d: %@",i, tf.text);
        (self.vo.optDict)[[NSString stringWithFormat:@"cv%d",i]] = tf.text;
    } else {
        [self.vo.optDict removeObjectForKey:[NSString stringWithFormat:@"cv%d",i]];
    }
    
	//if (++i<CHOICES) {
		[(self.ctvovcp.wDict)[[NSString stringWithFormat:@"%dtf",i]] becomeFirstResponder];
	//} else {
	//	[tf resignFirstResponder];
	//}
    
    self.processingTfvDone = NO;
    
}

- (void) choiceColorButtonAction:(UIButton *)btn
{
	int i=0;
	
	for (NSString *key in self.ctvovcp.wDict) {
		if ((self.ctvovcp.wDict)[key] == btn) {
			const char *kstr = [key UTF8String];
			sscanf(kstr,"%dbtn",&i);
			break;
		}
	}
	
	NSString *cc = [NSString stringWithFormat:@"cc%d",i];
	NSNumber *ncol = (self.vo.optDict)[cc];
	if (ncol == nil) {
		// do nothing as no choice label set so button not active
	} else {
		NSInteger col = [ncol integerValue];
		if (++col >= [[rTracker_resource colorSet] count])
			col=0;
		(self.vo.optDict)[cc] = @(col);
		btn.backgroundColor = [rTracker_resource colorSet][col];
	}
	
}

#pragma mark -
#pragma mark options page 

- (void) setOptDictDflts {
    
    if (nil == (self.vo.optDict)[@"shrinkb"]) 
        (self.vo.optDict)[@"shrinkb"] = (SHRINKBDFLT ? @"1" : @"0");

    if (nil == (self.vo.optDict)[@"exportvalb"])
        (self.vo.optDict)[@"exportvalb"] = (EXPORTVALBDFLT ? @"1" : @"0");
    
    return [super setOptDictDflts];
}

- (BOOL) cleanOptDictDflts:(NSString*)key {
    
    NSString *val = (self.vo.optDict)[key];
    if (nil == val) 
        return YES;
    
    if (([key isEqualToString:@"shrinkb"] && [val isEqualToString:(SHRINKBDFLT ? @"1" : @"0")])
        ) {
        [self.vo.optDict removeObjectForKey:key];
        return YES;
    }

    if (([key isEqualToString:@"exportvalb"] && [val isEqualToString:(EXPORTVALBDFLT ? @"1" : @"0")])
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
	
    CGFloat tfvWidth = [@"-88 " sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}].width;
    CGFloat tfWidth = [@"888888888" sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}].width;

	frame.size.height = ctvovc.LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
	int i,j=1;
	for (i=0; i<CHOICES; i++) {
        frame.size.width = tfvWidth;

		frame = [ctvovc configTextField:frame
                            key:[NSString stringWithFormat:@"%dtfv",i]
                         target:self
                         action:@selector(ctfvDone:)
                            num:YES
                          place:[NSString stringWithFormat:@"%d",i+1]
                           text:(self.vo.optDict)[[NSString stringWithFormat:@"cv%d",i]]
                          addsv:YES ];

		frame.origin.x += MARGIN + tfvWidth;
        frame.size.width = tfWidth;

		frame = [ctvovc configTextField:frame
						  key:[NSString stringWithFormat:@"%dtf",i] 
					   target:self
					   action:@selector(ctfDone:) 
						  num:NO 
						place:[NSString stringWithFormat:@"choice %d",i+1]
						 text:(self.vo.optDict)[[NSString stringWithFormat:@"c%d",i]]
						addsv:YES ];
		
		frame.origin.x += MARGIN + tfWidth;
		
		//frame.size.height = 1.2* frame.size.height;
		frame.size.width = frame.size.height;
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.frame = frame;
		[[btn layer] setCornerRadius:8.0f];
		[[btn layer] setMasksToBounds:YES];
		[[btn layer] setBorderWidth:1.0f];
		NSNumber *cc = (self.vo.optDict)[[NSString stringWithFormat:@"cc%d",i]];
		if (cc == nil) {
			btn.backgroundColor = [UIColor clearColor];
		} else {
			btn.backgroundColor = [rTracker_resource colorSet][[cc integerValue]];
		}
        
        btn.titleLabel.font = PrefBodyFont;
        
		[btn addTarget:self action:@selector(choiceColorButtonAction:) forControlEvents:UIControlEventTouchDown];
		(ctvovc.wDict)[[NSString stringWithFormat:@"%dbtn",i]] = btn;
		//[ctvovc.view addSubview:btn];
        [ctvovc.scroll addSubview:btn];

        ctvovc.lastx = (ctvovc.lastx < frame.origin.x + frame.size.width + MARGIN ? frame.origin.x + frame.size.width + MARGIN : ctvovc.lastx);
        
		frame.origin.x = MARGIN + (j * (tfvWidth + tfWidth + ctvovc.LFHeight + 3*MARGIN));
		j = ( j ? 0 : 1 ); // j toggles 0-1
		frame.origin.y += j * ((2*MARGIN) + ctvovc.LFHeight);

		//frame.size.width = tfWidth;
		//frame.size.height = self.labelField.frame.size.height; // lab.frame.size.height;
	}
	
	//frame.origin.y -= MARGIN; // remove extra from end of loop, add one back for next line
	frame.origin.x = MARGIN;
	
	//-- general options label
	
	labframe = [ctvovc configLabel:@"Other options:" frame:frame key:@"goLab" addsv:YES];
	
	frame.origin.y += labframe.size.height + MARGIN;
	
	labframe = [ctvovc configLabel:@"Shrink buttons:" frame:frame key:@"csbLab" addsv:YES];
	
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	
	frame = [ctvovc configCheckButton:frame
                          key:@"csbBtn"
                        state:[(self.vo.optDict)[@"shrinkb"] isEqualToString:@"1"] // default:0
                        addsv:YES
     ];

    // export values option

	frame.origin.x = MARGIN;
	frame.origin.y += labframe.size.height + MARGIN;
	
	labframe = [ctvovc configLabel:@"CSV read/write values (not labels):" frame:frame key:@"cevLab" addsv:YES];
	
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	
	frame = [ctvovc configCheckButton:frame
                          key:@"cevBtn"
                        state:[(self.vo.optDict)[@"exportvalb"] isEqualToString:@"1"] // default:0
                        addsv:YES
     ];
    

    
	ctvovc.lasty = frame.origin.y + frame.size.height + MARGIN;
    ctvovc.lastx = (ctvovc.lastx < frame.origin.x + frame.size.width + MARGIN ? frame.origin.x + frame.size.width + MARGIN : ctvovc.lastx);

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

/* rtm here : export value option 
 */

- (NSString*) mapValue2Csv {
#if DEBUGLOG
    DBGLog(@"val= %@ indexForval= %d obj= %@",
           self.vo.value,
           [self getSegmentIndexForValue],
           [self.vo.optDict objectForKey:[NSString stringWithFormat:@"c%d",[self getSegmentIndexForValue]]] );
#endif
    if ([(NSString*) (self.vo.optDict)[@"exportvalb"] isEqualToString:@"1"]) {
        return (NSString*) self.vo.value;
    } else {
        return (self.vo.optDict)[[NSString stringWithFormat:@"c%d",[self getSegmentIndexForValue]]];
    }
}

/* rtm here : export value option -- need to parse and match value if choice did not match
 */

- (NSString*) mapCsv2Value:(NSString*)inCsv {
    NSMutableDictionary *optDict = self.vo.optDict;
    if ([(NSString*) optDict[@"exportvalb"] isEqualToString:@"1"]) {
        // we simply store the value, up to the user to provide a choice to match it
        return inCsv;
    }
    int ndx;
    NSUInteger count = [optDict count];
    int maxc=-1;
    int firstBlank = -1;
    NSInteger lastColor=-1;
    DBGLog(@"inCsv= %@",inCsv);
    for (ndx=0; ndx <count;ndx++) {
        NSString *key = [NSString stringWithFormat:@"c%d",ndx];
        NSString *val = optDict[key];
        if (nil != val) {
            maxc = ndx;
            lastColor = [optDict[[NSString stringWithFormat:@"cc%d",ndx]] integerValue];
            if ([val isEqualToString:inCsv]) {
                //DBGLog(@"matched, returning %d",ndx+1);
                //return [NSString stringWithFormat:@"%d",ndx+1];    // found match, return 1-based index and be done
                // change for can spec value for choice
                DBGLog(@"matched, ndx=%d",ndx);
                NSString *key = [NSString stringWithFormat:@"cv%d",ndx];
                return [optDict valueForKey:key];
            } else if ((-1 == firstBlank) && ([@"" isEqualToString:val])) {
                firstBlank = ndx;
            }
        }
    }

    // did not find inCsv as an object in optDict for a c%d key.
    
    // is inCsv a digit from a pre-1.0.5 csv save file?
    // TODO: remove this because is only for upgrade to 1.0.5
    //int intval = [inCsv intValue];
    //if ((0<intval) && (intval < CHOICES+1)) {
    //    return inCsv;
    //}
        
    // need to add a new object to optDict
    
    // if any blanks, put it there. using maxc as ndx now
    if (-1 != firstBlank) {
        maxc = firstBlank;  // this position available
    } else {
        maxc++;  // maxc is last one used because there were no blanks, so inc to next
    }
    
    optDict[[NSString stringWithFormat:@"c%d",maxc]] = inCsv;

    if (++lastColor >= [[rTracker_resource colorSet] count])
        lastColor=0;
    
    optDict[[NSString stringWithFormat:@"cc%d",maxc]] = @(lastColor);

    DBGLog(@"created choice %@ choice c%d color %ld",inCsv,maxc,(long)lastColor);
    
    maxc++;  // +1 because value not 0-based, while c%d key is
    
    // for exportvalb=false, stored value is segment index
    return [NSString stringWithFormat:@"%d",maxc];
}

@end
