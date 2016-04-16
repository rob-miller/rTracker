/***************
 voInfo.m
 Copyright 2014-2016 Robert T. Miller
 
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
//  voInfo.m
//  rTracker
//
//  Created by Robert Miller on 18/02/2014.
//  Copyright 2014 Robert T. Miller. All rights reserved.
//

#import "voInfo.h"
#import "dbg-defs.h"
#import "rTracker-resource.h"

@implementation voInfo

//@synthesize imageButton;


// 25.i.14 allow assigned values so use default (10) size
//- (int) getValCap {  // NSMutableString size for value
//    return 1;
//}
/*
- (UIImage *) boolBtnImage {
	// default is not checked
	return ( [self.vo.value isEqualToString:@""] ? [UIImage imageNamed:@"unchecked.png"] : [UIImage imageNamed:@"checked.png"] );
}

- (void)boolBtnAction:(UIButton *)imageButton
{  // default is unchecked or nil // 25.i.14 use assigned val // was "so only certain is if =1" ?
	if ([self.vo.value isEqualToString:@""]) {
        NSString *bv = [self.vo.optDict objectForKey:@"boolval"];
        //if (nil == bv) {
            //bv = BOOLVALDFLTSTR;
            //[self.vo.optDict setObject:bv forKey:@"boolval"];
        //}
		[self.vo.value setString:bv];
		[self.imageButton setImage:[UIImage imageNamed:@"checked.png"] forState: UIControlStateNormal];
	} else {
		[self.vo.value setString:@""];
		[self.imageButton setImage:[UIImage imageNamed:@"unchecked.png"] forState: UIControlStateNormal];
	}

	//self.vo.display = nil; // so will redraw this cell only
	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}

- (UIButton*) imageButton {
	if (nil == imageButton) {
        imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        imageButton.frame = self.vosFrame; //CGRectZero;
        imageButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        imageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; //Center;
        [imageButton addTarget:self action:@selector(boolBtnAction:) forControlEvents:UIControlEventTouchDown];		
        imageButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
        [imageButton retain];  // rtm 06 feb 2012
	}
    return imageButton;
}
*/

- (UIView*) voDisplay:(CGRect)bounds {
/*    self.vosFrame = bounds;
	[self.imageButton setImage:[self boolBtnImage] forState: UIControlStateNormal];
    
    DBGLog(@"bool voDisplay: %d", ([self.imageButton imageForState:UIControlStateNormal] == [UIImage imageNamed:@"checked.png"] ? 1 : 0) );
    DBGLog(@"bool data= %@",self.vo.value);
	return self.imageButton;
 */
    return nil;
}

- (NSArray*) voGraphSet {
	return nil; //[NSArray arrayWithObjects:@"dots", @"bar", nil];
}

#pragma mark -
#pragma mark graph display
/*
- (void) transformVO:(NSMutableArray *)xdat ydat:(NSMutableArray *)ydat dscale:(double)dscale height:(CGFloat)height border:(float)border firstDate:(int)firstDate {
    
    [self transformVO_bool:xdat ydat:ydat dscale:dscale height:height border:border firstDate:firstDate];
    
}
*/

- (id) newVOGD {
    return [[vogd alloc] initAsNum:self.vo];
}



#pragma mark -
#pragma mark options page

- (void) setOptDictDflts {
    if (nil == (self.vo.optDict)[@"infoval"])
        (self.vo.optDict)[@"infoval"] = INFOVALDFLTSTR;

    if (nil == (self.vo.optDict)[@"infourl"])
        (self.vo.optDict)[@"infourl"] = INFOURLDFLTSTR;

    if (nil == (self.vo.optDict)[@"infosave"])
        (self.vo.optDict)[@"infosave"] = (INFOSAVEDFLT ? @"1" : @"0");
    
    (self.vo.optDict)[@"graph"] = @"0";
    (self.vo.optDict)[@"privacy"] = [NSString stringWithFormat:@"%d",PRIVDFLT];
    
    return [super setOptDictDflts];
}

- (BOOL) cleanOptDictDflts:(NSString*)key {
    
    NSString *val = (self.vo.optDict)[key];
    if (nil == val)
        return YES;
    
    if (([key isEqualToString:@"infoval"] && ([INFOVALDFLTSTR isEqualToString:val]))   // ([val floatValue] == f(INFOVALDFLT)))
        ) {
        [self.vo.optDict removeObjectForKey:key];
        return YES;
    }

    if (([key isEqualToString:@"infourl"] && ([INFOURLDFLTSTR isEqualToString:[val stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]))
        ) {
        [self.vo.optDict removeObjectForKey:key];
        return YES;
    }

    if (([key isEqualToString:@"infosave"] && [val isEqualToString:(INFOSAVEDFLT ? @"1" : @"0")])
        ) {
        [self.vo.optDict removeObjectForKey:key];
        return YES;
    }

    
    return [super cleanOptDictDflts:key];
}

- (NSString*) update:(NSString*)instr {
    NSString *retval = (self.vo.optDict)[@"infoval"];
    if (retval) return retval;
    return INFOVALDFLTSTR;
}

- (void) voDrawOptions:(configTVObjVC*)ctvovc {
    
    DBGLog(@"ctvovc frame x %f y %f w %f h %f",ctvovc.view.frame.origin.x,ctvovc.view.frame.origin.y,ctvovc.view.frame.size.width,ctvovc.view.frame.size.height );
	CGRect frame = {MARGIN,ctvovc.lasty,0.0,0.0};
	
	CGRect labframe = [ctvovc configLabel:@"reported value:" frame:frame key:@"ivLab" addsv:YES];
	
	frame.origin.x = labframe.size.width + MARGIN + SPACE;
    CGFloat tfWidth = [@"9999999999" sizeWithAttributes:@{NSFontAttributeName:PrefBodyFont}].width;
	frame.size.width = tfWidth;
	frame.size.height = ctvovc.LFHeight;
	
	frame = [ctvovc configTextField:frame
                        key:@"ivalTF"
                     target:nil
                     action:nil
                        num:YES
                      place:INFOVALDFLTSTR
                       text:(self.vo.optDict)[@"infoval"]
                      addsv:YES ];

    frame.origin.y += frame.size.height + MARGIN;
	frame.origin.x = MARGIN;

    labframe = [ctvovc configLabel:@"Write value in database and CSV" frame:frame key:@"infosaveLab" addsv:YES];
    frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
    frame = [ctvovc configCheckButton:frame
                                  key:@"infosaveBtn"
                                state:([(self.vo.optDict)[@"infosave"] isEqualToString:@"1"])  // default:0
                                addsv:YES
             ];
    frame.origin.x = MARGIN;
    frame.origin.y += MARGIN + frame.size.height;
    
    labframe = [ctvovc configLabel:@"URL:" frame:frame key:@"iurlLab" addsv:YES];

	frame.origin.x = MARGIN;
	frame.origin.y += labframe.size.height + MARGIN;
    frame.size.width = [rTracker_resource get_visible_size:ctvovc].width - 2*MARGIN; //ctvovc.view.frame.size.width - (2*MARGIN) ;
    //frame.size.width = 2 * ctvovc.view.frame.size.width ;

    CGSize tsize = [(self.vo.optDict)[@"infourl"] sizeWithAttributes:@{NSFontAttributeName: PrefBodyFont}];
    DBGLog(@"frame width %f  tsize width %f",frame.size.width,tsize.width);
    if (tsize.width > (frame.size.width - (2*MARGIN))) {
        frame.size.width = tsize.width + (4 * MARGIN);
    }
    
    frame = [ctvovc configTextField:frame
                        key:@"iurlTF"
                     target:nil
                     action:nil
                        num:NO
                      place:INFOURLDFLTSTR
                       text:(self.vo.optDict)[@"infourl"]
                      addsv:YES ];

    
	ctvovc.lasty = frame.origin.y + labframe.size.height + MARGIN + SPACE ;
    ctvovc.lastx = (ctvovc.lastx < frame.origin.x + frame.size.width + MARGIN ? frame.origin.x + frame.size.width + MARGIN : ctvovc.lastx);
    
	//[super voDrawOptions:ctvovc];
}

/* rtm here : export value option -- need to parse and match value if choice did not match
 */

- (NSString*) mapCsv2Value:(NSString*)inCsv {
    
    if ([(self.vo.optDict)[@"infoval"] doubleValue] !=  [inCsv doubleValue]) {
        (self.vo.optDict)[@"infoval"] = inCsv;
    }
    return inCsv;
}






@end
