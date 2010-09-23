//
//  valueObj.h
//  rTracker
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


// supported valueObj types ; note these defns tied to Resource: rt-types.plist
#define VOT_NUMBER	0
#define VOT_TEXT	1
#define VOT_TEXTB	2
#define VOT_SLIDER	3
#define VOT_PICK	4
#define VOT_BOOLEAN	5
#define VOT_IMAGE	6
#define VOT_FUNC	7

#define VOT_MAX		8

// supported graphs ; tied to valueObj:mapGraphType
#define VOG_DOTS		0
#define VOG_BAR			1
#define VOG_LINE		2
#define VOG_DOTSLINE	3
#define VOG_PIE			4

#define VOG_MAX			5

// supported colors ; tied to trackerObj:colorSet
#define VOC_RED			0
#define VOC_GREEN		0
#define VOC_BLUE		0
#define VOC_CYAN		0
#define VOC_YELLOW		0
#define VOC_MAGENTA		0
#define VOC_ORANGE		0
#define VOC_PURPLE		0
#define VOC_BROWN		0
#define VOC_WHITE		0
#define VOC_LIGHTGRAY	0
#define VOC_DARK_GRAY	0

#define VOC_MAX			0



@interface valueObj : NSObject <UITextFieldDelegate> {
	NSInteger vid;
	NSInteger vtype;
	NSString *valueName;
	NSMutableString *value;
	NSInteger vcolor;
	NSInteger vGraphType;
	UIView *display;
}

//+ (NSArray *) votArray;

@property (nonatomic) NSInteger vid;
@property (nonatomic) NSInteger vtype;
@property (nonatomic,retain) NSString *valueName;
@property (nonatomic,retain) NSMutableString *value;
@property (nonatomic) NSInteger vcolor;
@property (nonatomic) NSInteger vGraphType;
@property (nonatomic, retain) UIView *display;

- (id) init;
- (void) dealloc;
//- (id) init :(NSInteger)in_vid in_vtype:(NSInteger) in_vtype in_vname:(NSString *) in_vname;
- (id) init :(NSInteger)in_vid in_vtype:(NSInteger) in_vtype in_vname:(NSString *) in_vname in_vcolor:(NSInteger) in_vcolor in_vgraphtype:(NSInteger) in_vgraphtype;

- (void) describe;
- (UIView *) display:(CGRect)bounds;

+ (NSArray *) graphsForVOTCopy:(NSInteger)vot;
+ (NSInteger) mapGraphType:(NSString *)gts;

//- (void) txtDTF:(BOOL)num;

@end
