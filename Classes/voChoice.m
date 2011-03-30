//
//  voChoice.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>


#import "voChoice.h"


@implementation voChoice

@synthesize ctvovcp,segmentedControl;

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
        NSAssert(i<CHOICES,@"segmentAction: failed to identify choice!");    
    }
    
    return rslt;
}

- (void) segmentAction:(id) sender
{
	NSLog(@"segmentAction: selected segment = %d", [sender selectedSegmentIndex]);
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
        
        if ([self.vo.optDict objectForKey:@"shrinkb"]) {  // default is NO, so a defined result means yes
            int j=0;
            for (NSString *s in segmentTextContent) {
                CGSize siz = [s sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
                [segmentedControl setWidth:siz.width forSegmentAtIndex:j];
                j++;
            }
        }
        [segmentTextContent release];
        
        segmentedControl.frame = self.voFrame;
        [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        
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

	self.voFrame = bounds;
    //self.segmentedControl.tag = kViewTag;
    
	// set displayed segment from self.vo.value
    
    if ([self.vo.value isEqualToString:@""]) {
        if (UISegmentedControlNoSegment != self.segmentedControl.selectedSegmentIndex) {
            self.segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
            [self.vo disableVO];
        }
    } else {
        if (self.segmentedControl.selectedSegmentIndex != [self.vo.value integerValue]) {
            self.segmentedControl.selectedSegmentIndex = [self.vo.value integerValue];
            [self.vo enableVO];
        }
    }

	return self.segmentedControl;
}

- (NSArray*) voGraphSet {
	return [NSArray arrayWithObjects:@"dots",@"pie", nil];
}

- (void) ctfDone:(UITextField *)tf
{
	int i=0;
	NSString *key;
	for (key in self.ctvovcp.wDict) {
		if ([self.ctvovcp.wDict objectForKey:key] == tf) {
			const char *kstr = [key UTF8String];
			sscanf(kstr,"%dtf",&i);
			break;
		}
	}
	
	NSLog(@"set choice %d: %@",i, tf.text);
	[self.vo.optDict setObject:tf.text forKey:[NSString stringWithFormat:@"c%d",i]];
	NSString *cc = [NSString stringWithFormat:@"cc%d",i];
	UIButton *b = [self.ctvovcp.wDict objectForKey:[NSString stringWithFormat:@"%dbtn",i]];
	if ([tf.text isEqualToString:@""]) {
		b.backgroundColor = [UIColor clearColor];
		[self.vo.optDict removeObjectForKey:cc];
		// TODO: should offer to delete any stored data
	} else {
		NSNumber *ncol = [self.vo.optDict objectForKey:cc];
		
		if (ncol == nil) {
			NSInteger col = [self.vo.parentTracker nextColor];
			[self.vo.optDict setObject:[NSNumber numberWithInteger:col] forKey:cc];
			b.backgroundColor = [((trackerObj*) self.vo.parentTracker).colorSet objectAtIndex:col];
		} 
	}
	if (++i<CHOICES) {
		[[self.ctvovcp.wDict objectForKey:[NSString stringWithFormat:@"%dtf",i]] becomeFirstResponder];
	} else {
		[tf resignFirstResponder];
	}
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
		if (++col >= [((trackerObj*) self.vo.parentTracker).colorSet count])
			col=0;
		[self.vo.optDict setObject:[NSNumber numberWithInteger:col] forKey:cc];
		btn.backgroundColor = [((trackerObj*) self.vo.parentTracker).colorSet objectAtIndex:col];
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
			btn.backgroundColor = [((trackerObj*) self.vo.parentTracker).colorSet objectAtIndex:[cc integerValue]];
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



@end
