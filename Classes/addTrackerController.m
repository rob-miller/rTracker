//
//  addTrackerController.m
//  rTracker
//
//  Created by Robert Miller on 15/04/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "addTrackerController.h"
#import "valueObj.h"
#import "addValObjController.h"
#import "configTVObjVC.h"
#import "rTracker-constants.h"
#import "rTracker-resource.h"
#import "dbg-defs.h"

#import "voState.h"

@implementation addTrackerController 

@synthesize tlist=_tlist;
@synthesize tempTrackerObj=_tempTrackerObj;
@synthesize table=_table;
@synthesize nameField=_nameField;
@synthesize copyBtn=_copyBtn;
@synthesize saving=_saving;
@synthesize deleteIndexPath=_deleteIndexPath;
@synthesize deleteVOs=_deleteVOs;


#pragma mark -
#pragma mark core object methods and support

- (void) dealloc {
	DBGLog(@"atc: dealloc");
    
    
	
}

# pragma mark -
# pragma mark view support


- (void) viewDidLoad {

	DBGLog(@"atc: vdl tlist dbname= %@",_tlist.dbName); // use backing ivar because don't want dbg msg to instantiate
	
	// cancel / save buttons on top nav bar

	UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
							   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
							   target:self
							   action:@selector(btnCancel)];
	self.navigationItem.leftBarButtonItem = cancelBtn;
	
	
	UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc]
							   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
							   target:self
							   action:@selector(btnSave)];
	self.navigationItem.rightBarButtonItem = saveBtn;

	// list manage / configure segmented control on bottom toolbar
	[self configureToolbarItems];
	
	if (! self.tempTrackerObj) {
		// the temporary tracker obj we work with
        trackerObj *tto = [[trackerObj alloc] init];
		self.tempTrackerObj = tto;
		//tempTrackerObj.trackerName = @"";
		//[self.tempTrackerObj init];
		self.tempTrackerObj.toid = [self.tlist getUnique];
		//[self.tempTrackerObj release];  // rtm 05 feb 2012 +1 alloc/init +1 retained self.tempTrackerObj
		self.title = @"Add tracker";
	} else {
			self.title = @"Modify tracker";
	}
	
	[self.table setEditing:YES animated:YES];
	self.table.allowsSelection = NO;  

    // set graph paper background
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkgnd2-320-460.png"]];
    self.table.backgroundView = bg;
    
    //UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkgnd2-320-460.png"]];
    [self.view addSubview:bg];
    [self.view sendSubviewToBack:bg];

	self.saving=FALSE;
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	
	DBGLog(@"atc: viewWillAppear, valObjTable count= %d", [self.tempTrackerObj.valObjTable count]);
	
	[self.table reloadData];
	if (self.navigationController.toolbarHidden)
		[self.navigationController setToolbarHidden:NO animated:YES];
	
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	
	//tempTrackerObj.colorSet = nil;
	self.tempTrackerObj.votArray = nil;
	
}

- (void)viewWillDisappear:(BOOL)animated {
	DBGLog(@"atc: viewWillDisappear, tracker name = %@",self.tempTrackerObj.trackerName);
	
	[super viewWillDisappear:animated];
}


/*
- (void) viewDidUnload {
	DBGLog(@"atc: viewdidunload");
	self.nameField = nil;
	self.tlist = nil;
	self.tempTrackerObj = nil;
	self.table = nil;
	
	self.title = nil;
	
	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.leftBarButtonItem = nil;
	[self setToolbarItems:nil
				 animated:NO];
	
    self.deleteVOs=nil;
	
	[super viewDidUnload];
}
*/
# pragma mark -
# pragma mark toolbar support

- (void) btnCopy {
    DBGLog(@"copy!");
    
    valueObj *lastVO = [self.tempTrackerObj.valObjTable lastObject];
    valueObj *newVO = [[valueObj alloc] initWithDict:self.tempTrackerObj dict:[lastVO dictFromVO]];
    newVO.vid = [self.tempTrackerObj getUnique];
    [self.tempTrackerObj addValObj:newVO];
    [self.table reloadData];
    
}

- (UIBarButtonItem *) copyBtn {
    if (nil == _copyBtn) {
        
        UIButton *cBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        NSString *title = @"Copy";
        cBtn.frame = CGRectMake(0, 0, [title sizeWithFont:cBtn.titleLabel.font].width +3, [title sizeWithFont:cBtn.titleLabel.font].height +2);
        
        [cBtn setTitle:@"Copy" forState:UIControlStateNormal];
        [cBtn addTarget:self action:@selector(btnCopy) forControlEvents:UIControlEventTouchUpInside];
        _copyBtn = [[UIBarButtonItem alloc] initWithCustomView:cBtn];
    }
    
    return _copyBtn;
}


/*
 frame.size.width = [label sizeWithFont:button.titleLabel.font].width + 4*SPACE;
if (frame.origin.x == -1.0f) {
    frame.origin.x = self.view.frame.size.width - (frame.size.width + MARGIN); // right justify
}
button.frame = frame;
*/

- (void) btnSetup {
	configTVObjVC *ctvovc = [[configTVObjVC alloc] init];
	ctvovc.to = self.tempTrackerObj;
	ctvovc.vo = nil;
	ctvovc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	//io6 [self presentModalViewController:ctvovc animated:YES];
    [self presentViewController:ctvovc animated:YES completion:NULL];
	  // rtm 05 feb 2012 
}

static int editMode;

- (void)configureToolbarItems {
	UIBarButtonItem *flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
												initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
												target:nil action:nil];
	
	// Create and configure the segmented control
	UISegmentedControl *editToggle = [[UISegmentedControl alloc]
									  initWithItems:@[@"Edit tracker",
													 @"Edit items"]];
	editToggle.segmentedControlStyle = UISegmentedControlStyleBar;
	editToggle.selectedSegmentIndex = 0;
	editMode = 0;
	[editToggle addTarget:self action:@selector(toggleEdit:)
		 forControlEvents:UIControlEventValueChanged];
	
	// Create the bar button item for the segmented control
	UIBarButtonItem *editToggleButtonItem = [[UIBarButtonItem alloc]
											 initWithCustomView:editToggle];

    //UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [infoBtn setTitle:@"⚙" forState:UIControlStateNormal];
    infoBtn.titleLabel.font = [UIFont systemFontOfSize:28.0];
    
    [infoBtn addTarget:self action:@selector(btnSetup) forControlEvents:UIControlEventTouchUpInside];
    infoBtn.frame = CGRectMake(0, 0, 44, 44);
    UIBarButtonItem *setupBtnItem = [[UIBarButtonItem alloc] initWithCustomView:infoBtn];
    
    /*
	UIBarButtonItem *setupBtnItem = [[UIBarButtonItem alloc]
								 initWithTitle:@"Setup"
								 style:UIBarButtonItemStyleBordered
								 target:self
								 action:@selector(btnSetup)];
	*/
	
	// Set our toolbar items
    
	self.toolbarItems = @[setupBtnItem,
                         flexibleSpaceButtonItem,
                         editToggleButtonItem,
                         flexibleSpaceButtonItem,
                         //[self.copyBtn autorelease], // analyze wants this but crashes later!
                         self.copyBtn];
    
    //self.copyBtn = nil;  // this stops crash, but lose control in toggleEdit() below
    //[copyBtn release];

}

- (void) toggleEdit:(id) sender {
	editMode = [sender selectedSegmentIndex];
	//[table reloadData];
	if (editMode == 0) {
		[self.table setEditing:YES animated:YES];
        self.copyBtn.enabled = YES;
	} else {
		[self.table setEditing:NO animated:YES];
        self.copyBtn.enabled = NO;
	}
	
	//[table reloadRowsAtIndexPaths:[table indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
	
	[self.table reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
	
}


# pragma mark -
# pragma mark button press handlers
/*
- (IBAction)btnAddValue {
DBGLog(@"btnAddValue was pressed!");
}
*/
- (IBAction)btnCancel {
    self.deleteVOs=nil;
	
	[self.navigationController popViewControllerAnimated:YES];
    //[rTracker_resource myNavPopTransition:self.navigationController animOpt:UIViewAnimationOptionTransitionCurlDown];
    
}

- (void) delVOdb:(NSInteger)vid 
{
	self.tempTrackerObj.sql = [NSString stringWithFormat:@"delete from voData where id=%d;",vid];
	[self.tempTrackerObj toExecSql];
	self.tempTrackerObj.sql = [NSString stringWithFormat:@"delete from voConfig where id=%d;",vid];
	[self.tempTrackerObj toExecSql];
}


-(void) btnSaveSlowPart {
    @autoreleasepool {
    //[self.spinner performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];

        [self.tempTrackerObj saveConfig];
        
        [self.tlist addToTopLayoutTable:self.tempTrackerObj];
        //[self.tlist confirmTopLayoutEntry:tempTrackerObj];
        [self.tlist loadTopLayoutTable];
        
        [rTracker_resource finishActivityIndicator:self.view navItem:self.navigationItem disable:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
        //[rTracker_resource myNavPopTransition:self.navigationController animOpt:UIViewAnimationOptionTransitionCurlDown];

        self.saving = FALSE;
    }
    
}
- (IBAction)btnSave {
	DBGLog(@"btnSave was pressed! tempTrackerObj name= %@ toid= %d tlist= %x",_tempTrackerObj.trackerName, _tempTrackerObj.toid, (unsigned int) _tlist);
    
    if (self.saving) {
        return;
    }
    
    self.saving = TRUE;
    
	if (self.deleteVOs != nil) {
		for (valueObj *vo in self.deleteVOs) {
			[self delVOdb:vo.vid];
		}
		self.deleteVOs = nil;
	}
	
    [self.nameField resignFirstResponder];
    
	if ([self.nameField.text length] > 0) {
		self.tempTrackerObj.trackerName = self.nameField.text;

		if (! self.tempTrackerObj.toid) {
			self.tempTrackerObj.toid = [self.tlist getUnique];
		}
        if (8 < [self.tempTrackerObj.valObjTable count]) {
            [rTracker_resource startActivityIndicator:self.view navItem:self.navigationItem disable:YES str:@"Saving..."];
        }
        //self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        //self.spinner.hidesWhenStopped = YES;
        //[self.spinner startAnimating];
        
        [NSThread detachNewThreadSelector:@selector(btnSaveSlowPart) toTarget:self withObject:nil];
        
        
	} else {
        self.saving = FALSE;
        [rTracker_resource alert:@"save Tracker" msg:@"Please set a name for this tracker to save"];
	}
}

# pragma mark -
# pragma mark nameField, privField support Methods

- (IBAction) nameFieldDone:(id)sender {
	[sender resignFirstResponder];
	if (self.nameField.text) {
		self.tempTrackerObj.trackerName = self.nameField.text;
	}
}

/*
- (IBAction) privFieldDone:(id)sender {
	[sender resignFirstResponder];
	self.tempTrackerObj.privacy = [nameField.text integerValue];
}
*/

#pragma mark -
#pragma mark UIActionSheet methods

- (void) delVOlocal:(NSUInteger) row
{
	[self.tempTrackerObj.valObjTable removeObjectAtIndex:row];
	[self.table deleteRowsAtIndexPaths:@[self.deleteIndexPath]
						   withRowAnimation:UITableViewRowAnimationFade];
}

- (void) addDelVO:(valueObj*)vo {
		if (self.deleteVOs == nil) {
			_deleteVOs = [[NSMutableArray alloc] init];
		}
		[self.deleteVOs addObject:vo];
}

- (void)actionSheet:(UIActionSheet *)checkValObjDelete clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	//DBGLog(@"checkValObjDelete buttonIndex= %d",buttonIndex);
	
	if (buttonIndex == checkValObjDelete.destructiveButtonIndex) {
		NSUInteger row = [self.deleteIndexPath row];
		valueObj *vo = (self.tempTrackerObj.valObjTable)[row];
		DBGLog(@"checkValObjDelete: will delete row %d name %@ id %d",row, vo.valueName,vo.vid);
		//[self delVOdb:vo.vid];
        [self addDelVO:vo];
		[self delVOlocal:row];
	} else {
		//DBGLog(@"check valobjdelete cancelled");
        [self.table reloadRowsAtIndexPaths:@[self.deleteIndexPath] withRowAnimation:UITableViewRowAnimationRight];
	}
	self.deleteIndexPath=nil;
}


# pragma mark -
# pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return (NSInteger) 1;
	} else {
		int rval = [self.tempTrackerObj.valObjTable count];
		if (editMode == 0) {
			rval++;
		}
		return rval;
	}

}

//- (NSInteger)tableView:(UITableView *)tableView numberOfSections: (UITableView *) tableView {
- (NSInteger)numberOfSectionsInTableView: (UITableView *) tableView {
		return (NSInteger) 2;
}

//TODO: tweak this to get section headers right ios7
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 6.0;
    /*
    if (section == 0)
        return 6.0;
    else return UITableViewAutomaticDimension;
     */
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	UITableViewCell *cell;
	
	NSUInteger section = [indexPath section];
	
	if (section == 0) {
		static NSString *nameCellID = @"nameCellID";
		cell = [tableView dequeueReusableCellWithIdentifier: nameCellID];
		if (cell == nil) {
			cell = [[UITableViewCell alloc]
					 initWithStyle:UITableViewCellStyleDefault
					 reuseIdentifier: nameCellID];
		} else {
			// the cell is being recycled, remove old embedded controls
			UIView *viewToRemove = nil;
			while ((viewToRemove = [cell.contentView viewWithTag:kViewTag]))
				[viewToRemove removeFromSuperview];
		}
		
		//NSInteger row = [indexPath row];
		//if (row == 0) {

			//self.nameField = nil;
            //[_nameField release];
            self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(10,10,250,25) ];
			self.nameField.clearsOnBeginEditing = NO;
			[self.nameField setDelegate:self];
			self.nameField.returnKeyType = UIReturnKeyDone;
			[self.nameField addTarget:self
						  action:@selector(nameFieldDone:)
				forControlEvents:UIControlEventEditingDidEndOnExit];
			self.nameField.tag = kViewTag;
			[cell.contentView addSubview:self.nameField];
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
			self.nameField.text = self.tempTrackerObj.trackerName;
			self.nameField.placeholder = @"Name this Tracker";
        //DBGLog(@"loaded section 0, %@ = %@",self.nameField.text , self.tempTrackerObj.trackerName);

//		} else {   // row = 1
//			cell.textLabel.text = @"privacy level:";
//			self.privField = nil;
//			privField = [[UITextField alloc] initWithFrame:CGRectMake(180,10,60,25) ];
//			self.privField.borderStyle = UITextBorderStyleRoundedRect;
//			self.privField.clearsOnBeginEditing = NO;
//			[self.privField setDelegate:self];
//			self.privField.returnKeyType = UIReturnKeyDone;
//			[self.privField addTarget:self
//						  action:@selector(privFieldDone:)
//				forControlEvents:UIControlEventEditingDidEndOnExit];
//			self.privField.tag = kViewTag;
//			[cell.contentView addSubview:privField];
//			
//			cell.selectionStyle = UITableViewCellSelectionStyleNone;
//		
//			self.privField.text = self.tempTrackerObj.trackerName;
//
//			self.privField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;	// use the number input only
//			self.privField.text = [NSString stringWithFormat:@"%d",self.tempTrackerObj.privacy];
//			self.privField.placeholder = @"num";
//			self.privField.textAlignment = UITextAlignmentRight;
//		}
		
	} else {

        static NSString *valCellID = @"valCellID";
		cell = [tableView dequeueReusableCellWithIdentifier: valCellID];
		if (cell == nil) {
			cell = [[UITableViewCell alloc]
					 initWithStyle:UITableViewCellStyleSubtitle
					 reuseIdentifier: valCellID];
		}
		NSInteger row = [indexPath row];
		if (row == [self.tempTrackerObj.valObjTable count] ) {
			if (0 == row) {
                cell.detailTextLabel.text = @"Add an item or value to track";
            } else {
                cell.detailTextLabel.text = @"add another thing to track";
            }
			cell.textLabel.text = @"";
		} else {
			valueObj *vo = (self.tempTrackerObj.valObjTable)[row];
            //DBGLog(@"starting section 1 cell for %@",vo.valueName);
			cell.textLabel.text = vo.valueName; 
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			//cell.detailTextLabel.text = [self.tempTrackerObj.votArray objectAtIndex:vo.vtype];
            if ([@"0" isEqualToString:(vo.optDict)[@"graph"]])
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - no graph", (self.tempTrackerObj.votArray)[vo.vtype]];
            else if (VOT_CHOICE == vo.vtype)  // vColor = -1
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",(self.tempTrackerObj.votArray)[vo.vtype],
                                             (vo.vos.voGraphSet)[vo.vGraphType]];
            else if (VOT_INFO == vo.vtype)  // vColor = -1, no graph
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",(self.tempTrackerObj.votArray)[vo.vtype]];
            else 
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@ - %@",(self.tempTrackerObj.votArray)[vo.vtype],
                                             (vo.vos.voGraphSet)[vo.vGraphType],
                                             [rTracker_resource colorNames][vo.vcolor]];
		}
        //DBGLog(@"loaded section 1 row %i : .%@. : .%@.",row, cell.textLabel.text, cell.detailTextLabel.text);
    }
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = [indexPath section];
	if (section == 0) {
		return NO;
	} 
	NSInteger row = [indexPath row];
	if (row >= [self.tempTrackerObj.valObjTable count]) {
		return NO;
	}
	
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *) fromIndexPath 
	  toIndexPath:(NSIndexPath *) toIndexPath {
	NSUInteger fromRow = [fromIndexPath row];
	NSUInteger toRow = [toIndexPath row];

#if DEBUGLOG	
	NSUInteger fromSection = [fromIndexPath section];
	NSUInteger toSection = [toIndexPath section];
	DBGLog(@"atc: move row from %d:%d to %d:%d",fromSection, fromRow, toSection, toRow);
#endif
    
	valueObj *vo = (self.tempTrackerObj.valObjTable)[fromRow];
	[self.tempTrackerObj.valObjTable removeObjectAtIndex:fromRow];
	if (toRow > [self.tempTrackerObj.valObjTable count])
		toRow = [self.tempTrackerObj.valObjTable count];
	[self.tempTrackerObj.valObjTable insertObject:vo atIndex:toRow];
	
	// fail [table reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableview editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = [indexPath section];
	if (section == 0) {
		return UITableViewCellEditingStyleNone;
	} else {
		NSInteger row = [indexPath row];
		if (row >= [self.tempTrackerObj.valObjTable count]) {
			return UITableViewCellEditingStyleInsert;
		} else {
			return UITableViewCellEditingStyleDelete;
		}
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	// NSUInteger section = [indexPath section];  // in theory this only called on vals section
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		DBGLog(@"atc: delete row %d ",row);
		self.deleteIndexPath = indexPath;
        
		valueObj *vo = (self.tempTrackerObj.valObjTable)[row];
		if ((! self.tempTrackerObj.tDb) // no db created yet for this tempTrackerObj
            || (! self.tempTrackerObj.toid))   // this tempTrackerObj not written to db yet at all
		{ 
            [self delVOlocal:row];
        } else if (! [self.tempTrackerObj voHasData:vo.vid]) {  // no actual values stored in db for this valObj
            [self addDelVO:vo];
            [self delVOlocal:row];
		} else {
			UIActionSheet *checkValObjDelete = [[UIActionSheet alloc] 
												initWithTitle:[NSString stringWithFormat:
															   @"Value %@ has stored data, which will be removed when you 'Save' this page.",
															   vo.valueName]
												delegate:self 
												cancelButtonTitle:@"Cancel"
												destructiveButtonTitle:@"Yes, delete"
												otherButtonTitles:nil];
			//[checkTrackerDelete showInView:self.view];
			[checkValObjDelete showFromToolbar:self.navigationController.toolbar ];
		}
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
		DBGLog(@"atc: insert row %d ",row);

        if ([self.nameField.text length] > 0) {
            self.tempTrackerObj.trackerName = self.nameField.text;
            DBGLog(@"adding val, save tf: %@ = %@",self.tempTrackerObj.trackerName,self.nameField.text);
        }
        
		addValObjController *avc;
        if (kIS_LESS_THAN_IOS7) {
            avc = [[addValObjController alloc] initWithNibName:@"addValObjController" bundle:nil ];
        } else {
            avc = [[addValObjController alloc] initWithNibName:@"addValObjController7" bundle:nil ];
        }
		avc.parentTrackerObj = self.tempTrackerObj;
		[self.navigationController pushViewController:avc animated:YES];
		
		
	} // else ??
}

- (void) addValObj:(NSUInteger) row {
	addValObjController *avc;
    if (kIS_LESS_THAN_IOS7) {
        avc = [[addValObjController alloc] initWithNibName:@"addValObjController" bundle:nil ];
    } else {
        avc = [[addValObjController alloc] initWithNibName:@"addValObjController7" bundle:nil ];
    }
	avc.parentTrackerObj = self.tempTrackerObj;
	avc.tempValObj = (self.tempTrackerObj.valObjTable)[row];
	[avc stashVals];
    
	[self.navigationController pushViewController:avc animated:YES];
}
///*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
	//NSUInteger section = [indexPath section];
	
	//DBGLog(@"selected section %d row %d ", section, row);

    [self addValObj:row];
}
//*/


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {


	NSUInteger row = [indexPath row];
	//NSUInteger section = [indexPath section];
	
	//DBGLog(@"accessory button tapped for section %d row %d ", section, row);
    
    [self addValObj:row];
	
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0) {
		return NO;
	}
	
    // Return NO if you do not want the specified item to be editable.
    if (editMode == 0) {
		return YES;
	} else {
		return NO;
	}
}

@end
