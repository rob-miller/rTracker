//
//  voTextBox.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voTextBox.h"


@implementation voTextBox

- (UIView*) voDisplay:(CGRect)bounds {
	NSLog(@"text box not implemented");
	// don't forget addressbook names picker
	return nil;
}

- (NSArray*) voGraphSet {
	if ([self.vo.optDict objectForKey:@"tbnl"]) { // default is no and thus nil, so any defined val means linecount is a num for graph
		return [voState voGraphSetNum];
	} else {
		return [super voGraphSet];
	}
}


- (void) voDrawOptions:(configTVObjVC*)ctvovc {
	CGRect frame = {MARGIN,ctvovc.lasty,0.0,0.0};
	CGRect labframe = [ctvovc configLabel:@"Text box options:" frame:frame key:@"tboLab" addsv:YES];
	frame.origin.y += labframe.size.height + MARGIN;
	labframe = [ctvovc configLabel:@"Use number of lines for graph:" frame:frame key:@"tbnlLab" addsv:YES];
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	[ctvovc configCheckButton:frame 
						key:@"tbnlBtn" 
					  state:[[self.vo.optDict objectForKey:@"tbnl"] isEqualToString:@"1"] ]; // default:0
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + frame.size.height;
	labframe = [ctvovc configLabel:@"Pick names from addressbook:" frame:frame key:@"tbabLab" addsv:YES];
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	[ctvovc configCheckButton:frame 
						key:@"tbabBtn" 
					  state:[[self.vo.optDict objectForKey:@"tbab"] isEqualToString:@"1"] ]; // default:0
	
	//	frame.origin.x = MARGIN;
	//	frame.origin.y += MARGIN + frame.size.height;
	//
	//	labframe = [self configLabel:@"Other options:" frame:frame key:@"soLab" addsv:YES];
	
	ctvovc.lasty = frame.origin.y + labframe.size.height + MARGIN;

	[super voDrawOptions:ctvovc];
}

@end
