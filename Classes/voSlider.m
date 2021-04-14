/***************
 voSlider.m
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
//  voSlider.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voSlider.h"
#import "dbg-defs.h"

@implementation voSlider

@synthesize sliderCtl=_sliderCtl,sdflt=_sdflt;

- (id) initWithVO:(valueObj *)valo {
	if ((self = [super initWithVO:valo])) {
        self.vo.useVO=NO;
	}
	return self;
}

- (void) resetData {
    self.vo.useVO=NO;
}


- (UITableViewCell*) voTVCell:(UITableView *)tableView {
	return [super voTVEnabledCell:tableView];
}

-(CGFloat)voTVCellHeight {
    //return CELL_HEIGHT_TALL;
    DBGLog(@"%f %f %f %f",self.sliderCtl.frame.size.height,(3*MARGIN),[self.vo getLabelSize].height, [self.vo getLongTitleSize].height);
    return self.sliderCtl.frame.size.height + (3*MARGIN) + [self.vo getLabelSize].height + [self.vo getLongTitleSize].height;
}

- (void)sliderAction:(UISlider *)sender
{ 
    DBGLog(@"slider action value = %f", ((UISlider *)sender).value);
    /*
	//
	//[self.vo.value setString:[NSString stringWithFormat:@"%f",sender.value]];
    DBGLog(@"sender action value: %f",sender.value);
	DBGLog(@"slider action value = %f", self.sliderCtl.value);
    DBGLog(@"prev val= %@",self.vo.value);
    DBGLog(@"tracking= %d  touchinside= %d",[sender isTracking], [sender isTouchInside]);
    //if (sender.value == 0.0f) {
    if ((![sender isTracking]) && [sender isTouchInside] && (sender.value == 0.0f)) {
        DBGLog(@"poo...");
        return;
    }
    */
    
	if (!self.vo.useVO)
		[self.vo enableVO];

    if ([(NSString*) (self.vo.optDict)[@"integerstepsb"] isEqualToString:@"1"]) {
        UISlider *slider = (UISlider *)sender;
        int ival = (int) slider.value + 0.5;        
        [slider setValue:(float) ival animated:YES];
    }
	[self.vo.value setString:[NSString stringWithFormat:@"%f",self.sliderCtl.value]];

	//DBGLog(@"slider action value = %f valstr= %@ vs dbl= %f", ((UISlider *)sender).value, self.vo.value, [self.vo.value doubleValue]);
    
	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}

/*
- (void)sliderTouchUp:(UISlider *)sender
{
    UISlider *slider = (UISlider *)sender;
    int ival = (int) slider.value + 0.5;
    
    [slider setValue:(float) ival animated:YES];
    [self.vo.value setString:[NSString stringWithFormat:@"%f",self.sliderCtl.value]];

    DBGLog(@"slider touch up value = %f", slider.value);
	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}
*/

- (void)sliderTouchUp:(UISlider *)sender
{
    ((trackerObj*)self.vo.parentTracker).swipeEnable=YES;
    DBGLog(@"*********slider up");
}
- (void)sliderTouchDown:(UISlider *)sender
{
    ((trackerObj*)self.vo.parentTracker).swipeEnable=NO;
    DBGLog(@"********slider down");
}


- (UISlider*) sliderCtl {
    if (_sliderCtl && _sliderCtl.frame.size.width != self.vosFrame.size.width) _sliderCtl=nil;  // first time around thinks size is 320, handle larger devices

    if (nil == _sliderCtl) {
       // DBGLog(@"create sliderCtl");
        //CGRect frame = CGRectMake(174.0, 12.0, 120.0, kSliderHeight);
        
        _sliderCtl = [[UISlider alloc] initWithFrame:self.vosFrame];
        [_sliderCtl addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];

        [_sliderCtl addTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [_sliderCtl addTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
        [_sliderCtl addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
/*
        if ([(NSString*) [self.vo.optDict objectForKey:@"integerstepsb"] isEqualToString:@"1"]) {
            [sliderCtl addTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpInside];
            [sliderCtl addTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
        }
*/
        // in case the parent view draws with a custom color or gradient, use a transparent color
        _sliderCtl.backgroundColor = [UIColor clearColor];
        
        NSNumber *nsmin = (self.vo.optDict)[@"smin"];
        NSNumber *nsmax = (self.vo.optDict)[@"smax"];
        NSNumber *nsdflt = (self.vo.optDict)[@"sdflt"];
        
        CGFloat smin = (nsmin ? [nsmin floatValue] : SLIDRMINDFLT);
        CGFloat smax = (nsmax ? [nsmax floatValue] : SLIDRMAXDFLT);
        self.sdflt = (nsdflt ? [nsdflt floatValue] : SLIDRDFLTDFLT);
        
        _sliderCtl.minimumValue = smin;
        _sliderCtl.maximumValue = smax;
        _sliderCtl.continuous = YES;
        // Add an accessibility label that describes the slider.
        //[sliderCtl setAccessibilityLabel:NSLocalizedString(@"StandardSlider", @"")];
        [_sliderCtl setAccessibilityLabel:[NSString stringWithFormat:@"%@ slider", self.vo.valueName]];
        
        //sliderCtl.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells

        /*
        if ([self.vo.value isEqualToString:@""]) {
            self.sliderCtl.value = self.sdflt;  
            //[self.sliderCtl setValue:self.sdflt animated:NO];
        } else {
            self.sliderCtl.value = [self.vo.value floatValue];
            //[self.sliderCtl setValue:[self.vo.value floatValue] animated:NO];
        }
         */
    }
    
    return _sliderCtl;
}

- (UIView*) voDisplay:(CGRect) bounds
{
    self.vosFrame = bounds;
    
#if DEBUGLOG
    NSString *vals = self.vo.value;
    CGFloat valf = [self.vo.value floatValue];
    //trackerObj *pto = self.vo.parentTracker;
    
    DBGLog(@"voDisplay slider %@ vals= %@ valf= %f -> slider.valf= %f",self.vo.valueName,vals,valf,self.sliderCtl.value);
#endif
    
    //DBGLog(@"parent tracker date= %@",pto.trackerDate);
    if ([self.vo.value isEqualToString:@""]) {
        if ([(self.vo.optDict)[@"slidrswlb"] isEqualToString:@"1"]) {
            trackerObj *to = (trackerObj*)self.vo.parentTracker;
            NSString *sql = [NSString stringWithFormat:@"select count(*) from voData where id=%ld and date<%d",
                             (long)self.vo.vid,(int)[to.trackerDate timeIntervalSince1970]];
            int v = [to toQry2Int:sql];
            if (v>0) {
                sql = [NSString stringWithFormat:@"select val from voData where id=%ld and date<%d order by date desc limit 1;",
                       (long)self.vo.vid,(int)[to.trackerDate timeIntervalSince1970]];
                [self.sliderCtl setValue:[to toQry2Float:sql]];
            }
        } else {
            [self.sliderCtl setValue:self.sdflt animated:NO];
        }
    } else if (self.sliderCtl.value != [self.vo.value floatValue]) {
        //self.sliderCtl.value = [self.vo.value floatValue];
        [self.sliderCtl setValue:[self.vo.value floatValue] animated:NO];
    }
    DBGLog(@"sliderCtl voDisplay: %f", self.sliderCtl.value);
    //NSLog(@"sliderCtl voDisplay: %f", self.sliderCtl.value);
	return self.sliderCtl;
}

/*
- (UIView*) voDisplay:(CGRect) bounds {
    DBGLog(@"create sliderCtl");
    //CGRect frame = CGRectMake(174.0, 12.0, 120.0, kSliderHeight);
    CGRect frame = bounds;
    UISlider *sliderCtl = [[UISlider alloc] initWithFrame:frame];
    [sliderCtl addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    
    // in case the parent view draws with a custom color or gradient, use a transparent color
    sliderCtl.backgroundColor = [UIColor clearColor];
    
    NSNumber *nsmin = [self.vo.optDict objectForKey:@"smin"];
    NSNumber *nsmax = [self.vo.optDict objectForKey:@"smax"];
    NSNumber *nsdflt = [self.vo.optDict objectForKey:@"sdflt"];
    
    CGFloat smin = (nsmin ? [nsmin floatValue] : SLIDRMINDFLT);
    CGFloat smax = (nsmax ? [nsmax floatValue] : SLIDRMAXDFLT);
    CGFloat sdflt = (nsdflt ? [nsdflt floatValue] : SLIDRDFLTDFLT);
    
    sliderCtl.minimumValue = smin;
    sliderCtl.maximumValue = smax;
    sliderCtl.continuous = YES;
    // Add an accessibility label that describes the slider.
    [sliderCtl setAccessibilityLabel:NSLocalizedString(@"StandardSlider", @"")];
    
    sliderCtl.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
    
    if ([self.vo.value isEqualToString:@""]) {
        sliderCtl.value = sdflt;  
        //[self.sliderCtl setValue:self.sdflt animated:NO];
    } else {
        sliderCtl.value = [self.vo.value floatValue];
        //[self.sliderCtl setValue:[self.vo.value floatValue] animated:NO];
    }
    
    return [sliderCtl autorelease];
}
 */


- (NSArray*) voGraphSet {
	return [voState voGraphSetNum];
}


- (void) setOptDictDflts {
    if (nil == (self.vo.optDict)[@"smin"]) 
        (self.vo.optDict)[@"smin"] = [NSString stringWithFormat:@"%3.1f",SLIDRMINDFLT];
    if (nil == (self.vo.optDict)[@"smax"]) 
        (self.vo.optDict)[@"smax"] = [NSString stringWithFormat:@"%3.1f",SLIDRMAXDFLT];
    if (nil == (self.vo.optDict)[@"sdflt"]) 
        (self.vo.optDict)[@"sdflt"] = [NSString stringWithFormat:@"%3.1f",SLIDRDFLTDFLT];
    
    if (nil == (self.vo.optDict)[@"integerstepsb"])
        (self.vo.optDict)[@"integerstepsb"] = (INTEGERSTEPSBDFLT ? @"1" : @"0");
    if (nil == (self.vo.optDict)[@"defaultenabledb"])
        (self.vo.optDict)[@"defaultenabledb"] = (DEFAULTENABLEDBDFLT ? @"1" : @"0");

    if (nil == (self.vo.optDict)[@"slidrswlb"])
        (self.vo.optDict)[@"slidrswlb"] = (SLIDRSWLBDFLT ? @"1" : @"0");

    return [super setOptDictDflts];
}

- (BOOL) cleanOptDictDflts:(NSString*)key {
    
    NSString *val = (self.vo.optDict)[key];
    if (nil == val) 
        return YES;
    
    if (([key isEqualToString:@"smin"] && ([val floatValue] == f(SLIDRMINDFLT)))
        ||
        ([key isEqualToString:@"smax"] && ([val floatValue] == f(SLIDRMAXDFLT)))
        ||
        ([key isEqualToString:@"sdflt"] && ([val floatValue] == f(SLIDRDFLTDFLT)))
        ) {
        [self.vo.optDict removeObjectForKey:key];
        return YES;
    }

    if (([key isEqualToString:@"integerstepsb"] && [val isEqualToString:(INTEGERSTEPSBDFLT ? @"1" : @"0")])
        ) {
        [self.vo.optDict removeObjectForKey:key];
        return YES;
    }
    
    if (([key isEqualToString:@"defaultenabledb"] && [val isEqualToString:(DEFAULTENABLEDBDFLT ? @"1" : @"0")])
        ) {
        [self.vo.optDict removeObjectForKey:key];
        return YES;
    }

    if (([key isEqualToString:@"slidrswlb"] && [val isEqualToString:(SLIDRSWLBDFLT ? @"1" : @"0")])
        ) {
        [self.vo.optDict removeObjectForKey:key];
        return YES;
    }
    

    
    return [super cleanOptDictDflts:key];
}



- (void) voDrawOptions:(configTVObjVC*)ctvovc {
	CGRect frame = {MARGIN,ctvovc.lasty,0.0,0.0};
	
	CGRect labframe = [ctvovc configLabel:@"Slider range:" frame:frame key:@"srLab" addsv:YES];
	
	frame.origin.x = MARGIN;
	frame.origin.y += labframe.size.height + MARGIN;
	
	labframe = [ctvovc configLabel:@"min:" frame:frame key:@"sminLab" addsv:YES];
	
	frame.origin.x = labframe.size.width + MARGIN + SPACE;
    CGFloat tfWidth = [@"9999999999" sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}].width;
	frame.size.width = tfWidth;
	frame.size.height = ctvovc.LFHeight; 
	
	frame = [ctvovc configTextField:frame
					  key:@"sminTF" 
				   target:nil
				   action:nil
					  num:YES 
					place:[NSString stringWithFormat:@"%3.1f",SLIDRMINDFLT] 
					 text:(self.vo.optDict)[@"smin"] 
					addsv:YES ];
	
	frame.origin.x += tfWidth + MARGIN;
	labframe = [ctvovc configLabel:@" max:" frame:frame key:@"smaxLab" addsv:YES];
	
	frame.origin.x += labframe.size.width + SPACE;
	frame.size.width = tfWidth;
	frame.size.height = ctvovc.LFHeight; 
	
	frame = [ctvovc configTextField:frame
					  key:@"smaxTF" 
				   target:nil
				   action:nil
					  num:YES 
					place:[NSString stringWithFormat:@"%3.1f",SLIDRMAXDFLT] 
					 text:(self.vo.optDict)[@"smax"]
					addsv:YES ];
	
	frame.origin.y += frame.size.height + MARGIN;
	frame.origin.x = 8*MARGIN;
	
	labframe = [ctvovc configLabel:@"default:" frame:frame key:@"sdfltLab" addsv:YES];
	
	frame.origin.x += labframe.size.width + SPACE;
	frame.size.width = tfWidth;
	frame.size.height = ctvovc.LFHeight; 
	
	frame = [ctvovc configTextField:frame
					  key:@"sdfltTF" 
				   target:nil
				   action:nil
					  num:YES 
					place:[NSString stringWithFormat:@"%3.1f",SLIDRDFLTDFLT]
					 text:(self.vo.optDict)[@"sdflt"]
					addsv:YES ];
	
	frame.origin.y += frame.size.height + MARGIN;
	frame.origin.x = MARGIN;
	//-- title label
	
	labframe = [ctvovc configLabel:@"Other options:" frame:frame key:@"soLab" addsv:YES];

	
	frame.origin.x = MARGIN;
	frame.origin.y += labframe.size.height + MARGIN;
    
	labframe = [ctvovc configLabel:@"integer steps:" frame:frame key:@"sisLab" addsv:YES];
	
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	
	frame = [ctvovc configCheckButton:frame
                          key:@"sisBtn"
                        state:[(self.vo.optDict)[@"integerstepsb"] isEqualToString:@"1"] // default:0
                        addsv:YES
     ];

    frame.origin.x = MARGIN;
    frame.origin.y += labframe.size.height + MARGIN;
    
    labframe = [ctvovc configLabel:@"starts with last:" frame:frame key:@"sswlLab" addsv:YES];
    
    frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
    
    frame = [ctvovc configCheckButton:frame
                                  key:@"sswlBtn"
                                state:[(self.vo.optDict)[@"slidrswlb"] isEqualToString:@"1"] // default:0
                                addsv:YES
             ];
    
    
    
    /* 
     * need more thought here -- if slider is enabled by default, can't open and leave without asking to save ?
     *  /
     
    frame.origin.x = MARGIN;
	frame.origin.y += labframe.size.height + MARGIN;
    
    labframe = [ctvovc configLabel:@"default enabled:" frame:frame key:@"sdeLab" addsv:YES];
    
    frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
    
    frame = [ctvovc configCheckButton:frame
                          key:@"sdeBtn"
                        state:[(self.vo.optDict)[@"defaultenabledb"] isEqualToString:@"1"] // default:0
                        addsv:YES
     ];
    */
    
    

	ctvovc.lasty = frame.origin.y + labframe.size.height + MARGIN;
	[super voDrawOptions:ctvovc];
}

- (NSString*) update:(NSString*)instr {   // place holder so fn can update on access
    if (self.vo.useVO)
        return instr;
    return @"";
}
/*
- (void) transformVO:(NSMutableArray *)xdat ydat:(NSMutableArray *)ydat dscale:(double)dscale height:(CGFloat)height border:(float)border firstDate:(int)firstDate {
    
    [self transformVO_num:xdat ydat:ydat dscale:dscale height:height border:border firstDate:firstDate];
    
}
*/
- (id) newVOGD {
    return [[vogd alloc] initAsNum:self.vo];
}


@end
