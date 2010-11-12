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

@implementation voState

@synthesize vo;

- (id) init {
	return [self initWithVO:nil];
}

- (id) initWithVO:(valueObj *)valo {
	if (self = [super init]) {
		self.vo = valo;
	}
	return self;
}

- (void) dealloc {

	NSLog(@"voState default dealloc");
	[super dealloc];
}

- (void) loadConfig {
}

- (void) voDrawOptions:(configTVObjVC*)ctvovc {
	CGRect frame = {MARGIN,ctvovc.lasty,0.0,0.0};
	
	CGRect labframe = [ctvovc configLabel:@"draw graph:" frame:frame key:@"ggLab" addsv:YES];
	
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	
	//-- draw graphs button
	
	[ctvovc configCheckButton:frame 
						key:@"ggBtn" 
					  state:(![[self.vo.optDict objectForKey:@"graph"] isEqualToString:@"0"]) ]; // default = @"1"
	
	//-- privacy level label
	
	frame.origin.x += frame.size.width + MARGIN + SPACE;
	//frame.origin.y += MARGIN + frame.size.height;
	labframe = [ctvovc configLabel:@"privacy level:" frame:frame key:@"gpLab" addsv:YES];
	
	//-- privacy level textfield
	
	frame.origin.x += labframe.size.width + SPACE;
	CGFloat tfWidth = [[NSString stringWithString:@"9999"] sizeWithFont:[UIFont systemFontOfSize:18]].width;
	frame.size.width = tfWidth;
	frame.size.height = ctvovc.LFHeight; // self.labelField.frame.size.height; // lab.frame.size.height;
	
	[ctvovc configTextField:frame 
						key:@"gpTF" 
					 target:nil 
					 action:nil
						num:YES 
					  place:[NSString stringWithFormat:@"%d",PRIVDFLT] 
					   text:[self.vo.optDict objectForKey:@"privacy"]
					  addsv:YES ];
	
	
}

- (UIView*) voDisplay:(CGRect)bounds {
	return nil;
}


#define LMARGIN 60.0f
#define RMARGIN 10.0f
#define BMARGIN  7.0f


- (UITableViewCell*) voTVEnabledCell:(UITableView *)tableView {
	
	CGRect bounds;
	UITableViewCell *cell;
	CGSize maxLabel = ((trackerObj*)self.vo.parentTracker).maxLabel;
	
	static NSString *CellIdentifier = @"Cell1";
	
	cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	} else {
		// the cell is being recycled, remove old embedded controls
		UIView *viewToRemove = nil;
		while (viewToRemove = [cell.contentView viewWithTag:kViewTag])
			[viewToRemove removeFromSuperview];
	}
	
	
	//cell.accessoryType = UITableViewCellAccessoryCheckmark;
	
	// checkButton top row left
	
	UIImage *checkImage = [UIImage imageNamed:@"checked.png"];
	
	bounds.origin.x = MARGIN;
	bounds.origin.y = MARGIN;
	bounds.size.width = checkImage.size.width ; //CHECKBOX_WIDTH; // cell.frame.size.width;
	bounds.size.height = checkImage.size.height ; //self.tracker.maxLabel.height + 2*BMARGIN; //CELL_HEIGHT_TALL/2.0; //self.tracker.maxLabel.height + BMARGIN;
	
	self.vo.checkButtonUseVO.frame = bounds;
	self.vo.checkButtonUseVO.tag = kViewTag;
	self.vo.checkButtonUseVO.backgroundColor = cell.backgroundColor;
	
	if (! self.vo.retrievedData) {  // only show enable checkbox if this is data entry mode (not show historical)
		
		UIImage *image = (self.vo.useVO) ? checkImage : [UIImage imageNamed:@"unchecked.png"];
		UIImage *newImage = [image stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		[self.vo.checkButtonUseVO setImage:newImage forState:UIControlStateNormal];
		[cell.contentView addSubview:self.vo.checkButtonUseVO];
	}
	
	// cell label top row right 
	
	bounds.origin.x += checkImage.size.width + MARGIN;
	bounds.size.width = cell.frame.size.width - checkImage.size.width - (2.0*MARGIN);
	bounds.size.height = maxLabel.height + MARGIN; //CELL_HEIGHT_TALL/2.0; //self.tracker.maxLabel.height + BMARGIN;
	
	UILabel *label = [[UILabel alloc] initWithFrame:bounds];
	label.tag=kViewTag;
	label.font = [UIFont boldSystemFontOfSize:18.0];
	label.textAlignment = UITextAlignmentLeft;
	label.textColor = [UIColor blackColor];
	label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin; // | UIViewAutoresizingFlexibleHeight;
	label.contentMode = UIViewContentModeTopLeft;
	label.text = vo.valueName;
	[cell.contentView addSubview:label];
	[label release];
	
	bounds.origin.y = maxLabel.height + (3.0*MARGIN); //CELL_HEIGHT_TALL/2.0 + MARGIN; // 38.0f; //bounds.size.height; // + BMARGIN;
	bounds.size.height = /*CELL_HEIGHT_TALL/2.0 ; // */ maxLabel.height + (1.5*MARGIN);
	
	bounds.size.width = cell.frame.size.width - (2.0f * MARGIN);
	bounds.origin.x = MARGIN; // 0.0f ;  //= bounds.origin.x + RMARGIN;
	
	[cell.contentView addSubview:[self.vo display:bounds]];
    return cell;
	
}

- (UITableViewCell*) voTVCell:(UITableView *)tableView {
	
	CGRect bounds;
	UITableViewCell *cell;
	CGSize maxLabel = ((trackerObj*)self.vo.parentTracker).maxLabel;
	
	static NSString *CellIdentifier = @"Cell2";
	
	cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	} else {
		// the cell is being recycled, remove old embedded controls
		UIView *viewToRemove = nil;
		while (viewToRemove = [cell.contentView viewWithTag:kViewTag])
			[viewToRemove removeFromSuperview];
	}

	cell.textLabel.text = vo.valueName;
	//cell.textLabel.tag = kViewTag;
	bounds.origin.x = cell.frame.origin.x + maxLabel.width + LMARGIN;
	bounds.origin.y = maxLabel.height - (MARGIN);
	bounds.size.width = cell.frame.size.width - maxLabel.width - LMARGIN - RMARGIN;
	bounds.size.height = maxLabel.height + MARGIN;
	
	//NSLog(@"maxLabel: % f %f",self.tracker.maxLabel.width, self.tracker.maxLabel.height);
	//bounds.origin.y = bounds.size.height;// - BMARGIN;
	
	//NSLog(@"bounds= %f %f %f %f",bounds.origin.x,bounds.origin.y,bounds.size.width, bounds.size.height)	;
	[cell.contentView addSubview:[self.vo display:bounds]];
	return cell;
}

- (void) dataEditVDidLoad:(UIViewController*)vc {
}
- (void) dataEditVWAppear:(UIViewController*)vc {
}
- (void) dataEditVWDisappear {
}

- (void) dataEditVDidUnload {
}
//- (void) dataEditFinished {
//}

- (NSArray*) voGraphSet {
	return [NSArray arrayWithObjects:@"dots", nil];
}

+ (NSArray*) voGraphSetNum {
	return [NSArray arrayWithObjects:@"dots",@"bar",@"line", @"line+dots", nil];
}


- (void) updateVORefs:(NSInteger)newVID old:(NSInteger)oldVID {
	// subclass overrides if need to do anything
}

@end
