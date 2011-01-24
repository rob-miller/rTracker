//
//  voTextBox.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <AddressBook/AddressBook.h>

#import "voTextBox.h"
#import "voDataEdit.h"

#define SEGPEOPLE	0
#define SEGHISTORY	1
#define SEGKEYBOARD	2


@implementation voTextBox

@synthesize textView,devc,saveFrame,accessoryView,addButton,segControl;
@synthesize alphaArray,peopleArray,historyArray;
//@synthesize peopleDictionary,historyDictionary;
@synthesize pv,showNdx;

BOOL keyboardIsShown;

- (id) init {
	NSLog(@"voTextBox default init");
	return [super initWithVO:nil];
}

- (id) initWithVO:(valueObj *)valo {
	NSLog(@"voTextBox init for %@",valo.valueName);
	return [super initWithVO:valo];
}

- (void) dealloc {
	NSLog(@"dealloc voTextBox");
	
	self.textView = nil;
	[textView release];
	self.addButton = nil;
	self.accessoryView = nil;
	self.segControl = nil;
	
	self.devc = nil;
	
	//self.alphaArray = nil;
	self.peopleArray = nil;
	self.historyArray = nil;
	//self.peopleDictionary = nil;
	//self.historyDictionary = nil;
	self.pv = nil;
	
	[super dealloc];
	
}

- (void) tbBtnAction:(id)sender {
	NSLog(@"tbBtn Action.");
	voDataEdit *vde = [[voDataEdit alloc] initWithNibName:@"voDataEdit" bundle:nil ];
	vde.vo = self.vo;
	self.devc = vde; // assign
	[MyTracker.vc.navigationController pushViewController:vde animated:YES];
	[vde release];
	
}

- (void) dataEditVDidLoad:(UIViewController*)vc {
	//self.devc = vc;
	
	self.textView = [[[UITextView alloc] initWithFrame:vc.view.frame] autorelease];
	self.textView.textColor = [UIColor blackColor];
	self.textView.font = [UIFont fontWithName:@"Arial" size:18];
	self.textView.delegate = self;
	self.textView.backgroundColor = [UIColor whiteColor];
	
	self.textView.text = self.vo.value;
	self.textView.returnKeyType = UIReturnKeyDefault;
	self.textView.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	self.textView.scrollEnabled = YES;
	
	// this will cause automatic vertical resize when the table is resized
	self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	
	// note: for UITextView, if you don't like autocompletion while typing use:
	// myTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	
	[vc.view addSubview: self.textView];
	
	keyboardIsShown = NO;
	
	if ([self.vo.value isEqualToString:@""]) {
		[self.textView becomeFirstResponder];
	} 
	
}


- (void) dataEditVWAppear:(UIViewController*)vc {
	//self.devc = vc;
	NSLog(@"de view will appear");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.textView];    //.devc.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.textView];    //.devc.view.window];	
}

- (void) dataEditVWDisappear {
	NSLog(@"de view will disappear");

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
												  object:self.textView];    // nil]; //self.devc.view.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:self.textView];    // nil];   // self.devc.view.window];
}

- (void) dataEditVDidUnload {
	self.devc = nil;
}

//- (void) dataEditFinished {
//	[self.vo.value setString:self.textView.text];
//}


- (void)keyboardWillShow:(NSNotification *)aNotification 
{
	if (keyboardIsShown)
		return;
	
	// the keyboard is showing so resize the table's height
	self.saveFrame = self.devc.view.frame;
	CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration =
	[[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.devc.view.frame;
    frame.size.height -= keyboardRect.size.height;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.devc.view.frame = frame;
    [UIView commitAnimations];
	
    keyboardIsShown = YES;
	
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    // the keyboard is hiding reset the table's height
	//CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration =
	[[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //CGRect frame = self.devc.view.frame;
    //frame.size.height += keyboardRect.size.height;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.devc.view.frame = self.saveFrame;  // frame;
    [UIView commitAnimations];


    keyboardIsShown = NO;
}

#pragma mark -
#pragma mark UITextViewDelegate

- (IBAction) addPickerData:(id)sender {
	NSInteger row = 0;
	NSString *str = nil;
	
	if (self.showNdx) {
		row = [self.pv selectedRowInComponent:1];
	} else {
		row = [self.pv selectedRowInComponent:0];
	}
	if (SEGPEOPLE == self.segControl.selectedSegmentIndex) {
		str = [NSString stringWithFormat:@"%@\n",[(NSString*) ABRecordCopyCompositeName([self.peopleArray objectAtIndex:row])autorelease]];
	} else {
		str = [NSString stringWithFormat:@"%@\n",[self.historyArray objectAtIndex:row]];
	}
	
	//NSLog(@"add picker data %@",str);
	
	self.textView.text = [self.textView.text stringByAppendingString:str];
}

- (IBAction) segmentChanged:(id)sender {
	NSInteger ndx = [sender selectedSegmentIndex];
	NSLog(@"segment changed: %d",ndx);
	if (SEGKEYBOARD == ndx) {
		self.addButton.hidden = YES;
		self.textView.inputView = nil;
	} else {
		self.addButton.hidden = NO;
		if ((SEGPEOPLE == ndx) && ([self.vo.optDict objectForKey:@"tbni"])
			|| ((SEGHISTORY == ndx) && ([self.vo.optDict objectForKey:@"tbhi"]))
			) {
				self.showNdx = YES;
			} else {
				self.showNdx = NO;
			}
		
		if (nil == self.textView.inputView) 
			self.textView.inputView = self.pv;
	}
	
	[self.textView resignFirstResponder];
	[self.textView becomeFirstResponder];
	
}


- (void)saveAction:(id)sender
{
	// finish typing text/dismiss the keyboard by removing it as the first responder
	//
	[self.textView resignFirstResponder];
	self.devc.navigationItem.rightBarButtonItem = nil;	// this will remove the "save" button
	
	if (! [self.vo.value isEqualToString:self.textView.text]) {
		[self.vo.value setString:self.textView.text];
		[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
	}
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
	// provide my own Save button to dismiss the keyboard
	UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			  target:self action:@selector(saveAction:)];
	self.devc.navigationItem.rightBarButtonItem = saveItem;
	[saveItem release];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
    
    /*
     You can create the accessory view programmatically (in code), in the same nib file as the view controller's main view, or from a separate nib file. This example illustrates the latter; it means the accessory view is loaded lazily -- only if it is required.
     */
    
    if (textView.inputAccessoryView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"voTBacc" owner:self options:nil];
        // Loading the AccessoryView nib file sets the accessoryView outlet.
        textView.inputAccessoryView = accessoryView;    
        // After setting the accessory view for the text view, we no longer need a reference to the accessory view.
        self.accessoryView = nil;
		self.addButton.hidden = YES;
    }
	
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
    [aTextView resignFirstResponder];
    return YES;
}


#pragma mark -
#pragma mark voState display

- (UIView*) voDisplay:(CGRect)bounds {

	UIButton *tbButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	tbButton.frame = bounds; //CGRectZero;
	tbButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	tbButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	[tbButton addTarget:self action:@selector(tbBtnAction:) forControlEvents:UIControlEventTouchDown];		
	//[tbButton setImage:[self boolBtnImage] forState: UIControlStateNormal];
	if ([self.vo.value isEqualToString:@""]) {
		[tbButton setTitle:@"<add text>" forState:UIControlStateNormal];
	} else {
		[tbButton setTitle:self.vo.value forState:UIControlStateNormal];
	}
	
	tbButton.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
	
	return tbButton;
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
	
	/* TODO: support address book picker in v 2.0 */
	
	/*  TODO: support index picker component in v 2.0
	 
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + frame.size.height;
	labframe = [ctvovc configLabel:@"Names index:" frame:frame key:@"tbniLab" addsv:YES];
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	[ctvovc configCheckButton:frame 
						key:@"tbniBtn" 
					  state:[[self.vo.optDict objectForKey:@"tbni"] isEqualToString:@"1"] ]; // default:0
	
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + frame.size.height;
	labframe = [ctvovc configLabel:@"History index:" frame:frame key:@"tbhiLab" addsv:YES];
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	[ctvovc configCheckButton:frame 
						key:@"tbhiBtn" 
					  state:[[self.vo.optDict objectForKey:@"tbhi"] isEqualToString:@"1"] ]; // default:0

	 */
	
	//	frame.origin.x = MARGIN;
	//	frame.origin.y += MARGIN + frame.size.height;
	//
	//	labframe = [self configLabel:@"Other options:" frame:frame key:@"soLab" addsv:YES];
	
	ctvovc.lasty = frame.origin.y + labframe.size.height + MARGIN;

	[super voDrawOptions:ctvovc];
}

#pragma mark -
#pragma mark picker support

- (UIPickerView*) pv {
	if (nil == pv) {
		pv = [[UIPickerView alloc] initWithFrame:CGRectZero];
		pv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		pv.showsSelectionIndicator = YES;	// note this is default to NO
		// this view controller is the data source and delegate
		pv.delegate = self;
		pv.dataSource = self;
		if (self.showNdx)
			[pv selectRow:1 inComponent:0 animated:NO];
	}

	return pv;
}

/*
- (NSArray*) alphaArray {
	if (nil == alphaArray) {
		alphaArray = [[NSArray alloc] initWithObjects:@"#",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",
					  @"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
	}
	return alphaArray;
}

- (NSMutableDictionary*) peopleDictionary {
	if (nil == peopleDictionary) {
		ABAddressBookRef addressBook = ABAddressBookCreate();
		CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
		// /*
		CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(
																   kCFAllocatorDefault,
																   CFArrayGetCount(people),
																   people
																   );
		
		CFArraySortValues(
						  peopleMutable,
						  CFRangeMake(0, CFArrayGetCount(peopleMutable)),
						  (CFComparatorFunction) ABPersonComparePeopleByName,
						  (void*) ABPersonGetSortOrdering()
						  );

		CFIndex max = CFArrayGetCount(people);
		int i;
		for (i=0; i< max; i++) {
			//NSLog(@"person: %@",ABRecordCopyCompositeName([people objectAtIndex:i]));
			//NSLog(@"person: %@ %@",ABRecordCopyValue([people objectAtIndex:i],kABPersonFirstNameProperty),
			//	  ABRecordCopyValue([people objectAtIndex:i],kABPersonLastNameProperty));
			CFStringRef first,last,full;
			full = ABRecordCopyCompositeName([(NSArray*)peopleMutable objectAtIndex:i]);
			first = ABRecordCopyValue([(NSArray*)peopleMutable objectAtIndex:i],kABPersonFirstNameProperty);
			last = ABRecordCopyValue([(NSArray*)peopleMutable objectAtIndex:i],kABPersonLastNameProperty);
			NSLog(@"person: %@ -- %@ %@",full,first,last);
		}
		
		CFRelease(addressBook);
		CFRelease(people);
		CFRelease(peopleMutable);
		
	}
	return peopleDictionary;
}

- (NSMutableDictionary*) historyDictionary {
	if (nil == historyDictionary) {
		historyDictionary = [[NSMutableDictionary alloc] init];
	}
	return historyDictionary;
}
*/


- (NSArray*) peopleArray {
	if (nil == peopleArray) {
		ABAddressBookRef addressBook = ABAddressBookCreate();
		CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
		// /*
		CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(
																   kCFAllocatorDefault,
																   CFArrayGetCount(people),
																   people
																   );
		
		CFArraySortValues(
						  peopleMutable,
						  CFRangeMake(0, CFArrayGetCount(peopleMutable)),
						  (CFComparatorFunction) ABPersonComparePeopleByName,
						  (void*) ABPersonGetSortOrdering()
						  );
		/*
		CFIndex max = CFArrayGetCount(people);
		int i;
		for (i=0; i< max; i++) {
			//NSLog(@"person: %@",ABRecordCopyCompositeName([people objectAtIndex:i]));
			//NSLog(@"person: %@ %@",ABRecordCopyValue([people objectAtIndex:i],kABPersonFirstNameProperty),
			//	  ABRecordCopyValue([people objectAtIndex:i],kABPersonLastNameProperty));
			CFStringRef first,last,full;
			full = ABRecordCopyCompositeName([(NSArray*)peopleMutable objectAtIndex:i]);
			first = ABRecordCopyValue([(NSArray*)peopleMutable objectAtIndex:i],kABPersonFirstNameProperty);
			last = ABRecordCopyValue([(NSArray*)peopleMutable objectAtIndex:i],kABPersonLastNameProperty);
			NSLog(@"person: %@ -- %@ %@",full,first,last);
		}
		*/
		
		peopleArray = [[NSArray alloc] initWithArray:(NSArray*)peopleMutable];
		
		CFRelease(addressBook);
		CFRelease(people);
		CFRelease(peopleMutable);
	}
	return peopleArray;
}

- (NSArray*) historyArray {
	if (nil == historyArray) {
		//NSMutableArray *his1 = [[NSMutableArray alloc] init];
		NSMutableSet *s0 = [[NSMutableSet alloc] init];
		MyTracker.sql = [NSString stringWithFormat:@"select val from voData where id = %d;",self.vo.vid];
		NSMutableArray *his0 = [[NSMutableArray alloc] init];
		[MyTracker toQry2AryS:his0];
		for (NSString *s in his0) {
			[s0 addObjectsFromArray:[s componentsSeparatedByString:@"\n"]];
		}
		MyTracker.sql = nil;
		[s0 filterUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
		historyArray = [[[s0 allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] retain];
		
		//historyArray = [[NSArray alloc] initWithArray:his1];
		[his0 release];
		[s0 release];	
		
		//NSLog(@"his array looks like:");
		//for (NSString *s in historyArray) {
		//	NSLog(s);
		//}
	}
	return historyArray;
}

//- (void) updatePickerArrays:(NSInteger)row {
//	NSMutableDictionary *foo = self.peopleDictionary;
//}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	if (showNdx)
		return 2;
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger) component {
	if (showNdx && 0 == component) {
		return [self.alphaArray count];
	} else {
		if (SEGPEOPLE == self.segControl.selectedSegmentIndex) {
			return [self.peopleArray count];
		} else {
			return [self.historyArray count];
		}
	}

}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if (showNdx && 0 == component) {
		return [self.alphaArray objectAtIndex:row];
	} else {
		if (SEGPEOPLE == self.segControl.selectedSegmentIndex) {
			return [(NSString*) ABRecordCopyCompositeName([self.peopleArray objectAtIndex:row]) autorelease];
		} else {
			return [self.historyArray objectAtIndex:row];
		}
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{	
	//if (showNdx && 0 == component) {
	//	[self updatePickerArrays:row];
	//}
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{

    CGFloat componentWidth = 280.0;

	if ( showNdx ) {
		if (component == 0)
			componentWidth = 40.0; // first column size is narrow for letters 
		else
			componentWidth = 240.0;  // second column is max size
	}
	
    return componentWidth;
}

@end
