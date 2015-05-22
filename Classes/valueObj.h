//
//  valueObj.h
//  rTracker
//
//  Created by Robert Miller on 12/05/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#import "trackerObj.h"
@class trackerObj;
@class voState;
@class vogd;

// supported valueObj types ; note these defns tied to Resource: rt-types.plist
#define VOT_NUMBER	0
#define VOT_TEXT	1
#define VOT_TEXTB	2
#define VOT_SLIDER	3
#define VOT_CHOICE	4
#define VOT_BOOLEAN	5
#define VOT_FUNC	6
#define VOT_INFO    7

#define VOT_MAX		7

// image not yet
// #define VOT_IMAGE	7

// max number of choices for VOT_CHOICE
#define CHOICES 6
#define CHOICEARR @[ @(0), @(1), @(2), @(3), @(4), @(5) ]

// supported graphs ; tied to valueObj:mapGraphType
#define VOG_DOTS		0
#define VOG_BAR			1
#define VOG_LINE		2
#define VOG_DOTSLINE	3
#define VOG_PIE			4
//histogram...
#define VOG_NONE		5
#define VOG_MAX			5

// supported colors ; tied to trackerObj:colorSet
// not used
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

// vo config checkbutton default states
#define AUTOSCALEDFLT   YES
#define ASFROMZERODFLT  YES
#define SHRINKBDFLT     NO 
#define EXPORTVALBDFLT  NO
#define INTEGERSTEPSBDFLT  NO
#define DEFAULTENABLEDBDFLT  NO
#define TBNLDFLT        NO
#define TBNIDFLT        YES
#define TBHIDFLT        NO
#define GRAPHDFLT	    YES
#define NSWLDFLT        NO
#define GRAPHLASTDFLT   YES
#define SETSTRACKERDATEDFLT NO

// vo config textfield default values
#define SLIDRMINDFLT	0.0
#define SLIDRMAXDFLT	100.0
#define SLIDRDFLTDFLT	50.0
//#define PRIVDFLT		0
#define FREPDFLT		-1
#define FDDPDFLT		2
#define BOOLVALDFLT     1.0
#define BOOLVALDFLTSTR  @"1"
#define BOOLBTNCOLRDFLTSTR @"1"
#define INFOVALDFLT     1.0
#define INFOVALDFLTSTR  @"1.0"
#define INFOURLDFLTSTR  @""

#define NUMDDPDFLT		-1


@protocol voProtocol
- (int) getValCap;
- (NSString*) update:(NSString*)instr;
- (UIView*) voDisplay:(CGRect)bounds;
- (UITableViewCell*) voTVCell:(UITableView *)tableView;
- (CGFloat) voTVCellHeight;
- (NSArray*) voGraphSet;
- (void) voDrawOptions:(id)ctvovc;
- (void) loadConfig;
- (void) setOptDictDflts;
- (BOOL) cleanOptDictDflts:(NSString*)key;
- (void) updateVORefs:(NSInteger)newVID old:(NSInteger)oldVID;
- (void) dataEditVDidLoad:(UIViewController*)vc;
- (void) dataEditVWAppear:(UIViewController*)vc;
- (void) dataEditVWDisappear:(UIViewController*)vc;
//- (void) dataEditVDidUnload;
//- (void) dataEditFinished;
//- (void) transformVO:(NSMutableArray *)xdat ydat:(NSMutableArray *)ydat dscale:(double)dscale height:(CGFloat)height border:(float)border firstDate:(int)firstDate;
- (void) dealloc;
- (id) newVOGD;
//- (void) recalculate;
-(void) setFnVals:(int)tDate;
-(void) doTrimFnVals;
- (void) resetData;
- (NSString*) mapValue2Csv;
- (NSString*) mapCsv2Value:(NSString*)inCsv;

@end


@interface valueObj : NSObject <UITextFieldDelegate>
/*{
	NSInteger vid;   
	NSInteger vtype;
	NSInteger vpriv;
	NSString *valueName;
	NSMutableString *value;
	NSInteger vcolor;
	NSInteger vGraphType;
	UIView *display;
	BOOL useVO;
	//BOOL retrievedData;
	NSMutableDictionary *optDict;
	id parentTracker;
	id <voProtocol> vos;
	id vogd;
	UIButton *checkButtonUseVO;
}*/

//+ (NSArray *) votArray;

@property (nonatomic) NSInteger vid;
@property (nonatomic) NSInteger vtype;
@property (nonatomic) NSInteger vpriv;
@property (nonatomic,strong) NSString *valueName;
@property (nonatomic,strong) NSMutableString *value;
@property (nonatomic) NSInteger vcolor;
@property (nonatomic) NSInteger vGraphType;
@property (nonatomic,strong) NSMutableDictionary *optDict;
@property (nonatomic,strong) voState <voProtocol> *vos;
@property (nonatomic,strong) vogd <voProtocol> *vogd;

@property (nonatomic, strong) UIView *display;
@property (nonatomic) BOOL useVO;
//@property (nonatomic) BOOL retrievedData;
@property (nonatomic,unsafe_unretained) id parentTracker;

@property (nonatomic,strong) UIButton *checkButtonUseVO;

- (id) initWithData:(id)parentTO 
			 in_vid:(NSInteger)in_vid 
		   in_vtype:(NSInteger)in_vtype 
		   in_vname:(NSString *)in_vname 
		  in_vcolor:(NSInteger)in_vcolor 
	  in_vgraphtype:(NSInteger)in_vgraphtype
           in_vpriv:(NSInteger)in_vpriv;

- (id) initWithDict:(id)parentTO dict:(NSDictionary*)dict;

- (id) initFromDB:(id)parentTO
           in_vid:(NSInteger)in_vid;

- (id) initWithParentOnly:(trackerObj*)parentTO;

//- (id) init :(NSInteger)in_vid in_vtype:(NSInteger) in_vtype in_vname:(NSString *) in_vname;
//- (id) init:(id*)parentTO in_vid:(NSInteger)in_vid in_vtype:(NSInteger)in_vtype in_vname:(NSString *)in_vname in_vcolor:(NSInteger)in_vcolor in_vgraphtype:(NSInteger)in_vgraphtype;

- (void) describe:(BOOL)od;
- (UIView *) display:(CGRect)bounds;
-(void) setTrackerDateToNow;

- (void) enableVO;
- (void) disableVO;
- (void)checkAction:(id)sender;

- (void) resetData;
- (void) validate;

- (CGSize) getLabelSize;
- (CGSize) getLongTitleSize;

//+ (NSArray *) graphsForVOT:(NSInteger)vot;
//- (NSArray *) graphsForVOT:(NSInteger)vot;
+ (NSArray*) allGraphs;
+ (NSInteger) mapGraphType:(NSString *)gts;

- (NSDictionary*) dictFromVO;

//- (void) txtDTF:(BOOL)num;

- (NSString*) csvValue;
- (int) getChoiceIndexForValue:(NSString *)val;

@end
