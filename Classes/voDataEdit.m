//
//  voDataEdit.m
//  rTracker
//
//  Created by Robert Miller on 10/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

// implements textbox editor

#import "voDataEdit.h"
#import "dbg-defs.h"
#import "rTracker-resource.h"
#import "voTextBox.h"

@implementation voDataEdit

@synthesize vo=_vo, textView=_textView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
    CGRect f = self.view.frame;
    f.size.width = [rTracker_resource getKeyWindowWidth];
    self.view.frame = f;
    
    if (self.vo) {
        // valueObj data edit - voTextBox, voImage
        DBGLog(@"vde view did load");
        self.title = self.vo.valueName;
        [self.vo.vos dataEditVDidLoad:self];
        self.textView = ((voTextBox*)self.vo.vos).textView;
    } else {
        // generic text editor
        self.textView = [[UITextView alloc] initWithFrame:self.view.frame];
        self.textView.textColor = [UIColor blackColor];
        self.textView.font = PrefBodyFont; // [UIFont fontWithName:@"Arial" size:18];
        self.textView.delegate = self;
        self.textView.backgroundColor = [UIColor whiteColor];
        
        //self.textView.text = self.vo.value;
        self.textView.returnKeyType = UIReturnKeyDefault;
        self.textView.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
        self.textView.scrollEnabled = YES;
        self.textView.userInteractionEnabled = YES;
        
        // this will cause automatic vertical resize when the table is resized
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        self.textView.text = self.text;
        
        // note: for UITextView, if you don't like autocompletion while typing use:
        // myTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        
        [self.view addSubview: self.textView];
        
        keyboardIsShown = NO;
        
        [self.textView becomeFirstResponder];
        
        
    }
	
}

- (void) viewWillAppear:(BOOL)animated {
    if (self.vo) {
        [self.vo.vos dataEditVWAppear:self];
    }
    
    keyboardIsShown = NO;
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillChangeFrameNotification //UIKeyboardWillShowNotification
         //object:self.textView];    //.devc.view.window];
                                                object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
         //object:self.textView];    //.devc.view.window];
                                                   object:self.view.window];
        

    //[self.navigationController setToolbarHidden:NO animated:NO];

    [super viewWillAppear:animated];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    if (self.vo) {
        [self.vo.vos dataEditVWDisappear:self];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification // UIKeyboardWillShowNotification
                                                  object:nil];
    //--object:self.textView];    // nil]; //self.devc.view.window];
    //object:self.devc.view.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    //object:self.textView];    // nil];   // self.devc.view.window];
    //object:self.devc.view.window];
    

    [super viewWillDisappear:animated];
}

+ (CGRect) getInitTVF:(UIViewController*)vc {
    CGRect frame = vc.view.frame;
    CGRect frame2 = vc.navigationController.navigationBar.frame;
    DBGLog(@"nvb rect: %f %f %f %f",frame2.origin.x,frame2.origin.y,frame2.size.width,frame2.size.height);
    CGRect frame3 = vc.navigationController.toolbar.frame;
    DBGLog(@"tb rect: %f %f %f %f",frame3.origin.x,frame3.origin.y,frame3.size.width,frame3.size.height);
    
    frame.origin.y += frame2.size.height +frame2.origin.y;
    frame.size.height -= frame.origin.y + frame3.size.height;
    
    DBGLog(@"initTVF rect: %f %f %f %f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
    return frame;
}


- (void)keyboardWillShow:(NSNotification *)aNotification
{
    DBGLog(@"votb keyboardwillshow");
    
    if (keyboardIsShown)
        return;
    
    // the keyboard is showing so resize the table's height
    //self.saveFrame = self.textView.frame;
    CGRect keyboardRect = [[aNotification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    DBGLog(@"keyboard rect: %f %f %f %f",keyboardRect.origin.x,keyboardRect.origin.y,keyboardRect.size.width,keyboardRect.size.height);
    /*
    if (self.vo) {
        keyboardRect = [self.vo.vos.vc.view convertRect:keyboardRect fromView:nil];
    } else {
        keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    }
    */
    DBGLog(@"keyboard rect conv: %f %f %f %f",keyboardRect.origin.x,keyboardRect.origin.y,keyboardRect.size.width,keyboardRect.size.height);
    
    NSTimeInterval animationDuration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = [voDataEdit getInitTVF:self];
    frame.size.height -= keyboardRect.size.height;
    //UIView *iav = ((voTextBox*)self.vo.vos).textView.inputAccessoryView;
    //CGRect avframe = iav.frame;
    CGRect avframe = self.textView.inputAccessoryView.frame;
    //DBGLog(@"acc view frame rect: %f %f %f %f",avframe.origin.x,avframe.origin.y,avframe.size.width,avframe.size.height);
    
    frame.size.height += avframe.size.height;
    
    DBGLog(@"keyboard TVF: %f %f %f %f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);

    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    self.textView.frame = frame;
    [self.textView scrollRangeToVisible:self.textView.selectedRange];

    [UIView commitAnimations];
    
    keyboardIsShown = YES;
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    DBGLog(@"votb keyboardwillhide");
    
    // the keyboard is hiding reset the table's height
    //CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //CGRect frame = self.devc.view.frame;
    //frame.size.height += keyboardRect.size.height;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.textView.frame = [voDataEdit getInitTVF:self];
    [UIView commitAnimations];
    
    
    keyboardIsShown = NO;
}

- (void) saveAction:(id)sender {
    DBGLog(@"save me");
    //[self.saveClass performSelector:self.saveSelector withObject:@"FOOOO" afterDelay:(NSTimeInterval)0];
    [self.saveClass performSelector:self.saveSelector withObject:self.textView.text afterDelay:(NSTimeInterval)0];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // provide my own Save button to dismiss the keyboard
    UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                              target:self action:@selector(saveAction:)];
    self.navigationItem.rightBarButtonItem = saveItem;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
    
    /*
     You can create the accessory view programmatically (in code), in the same nib file as the view controller's main view, or from a separate nib file. This example illustrates the latter; it means the accessory view is loaded lazily -- only if it is required.
     */
    /*
    if (self.textView.inputAccessoryView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"voTBacc" owner:self options:nil];
        // Loading the AccessoryView nib file sets the accessoryView outlet.
        self.textView.inputAccessoryView = self.accessoryView;
        // After setting the accessory view for the text view, we no longer need a reference to the accessory view.
        self.accessoryView = nil;
        self.addButton.hidden = YES;
        CGFloat fsize = 20.0;
        [self.segControl setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fsize]} forState:UIControlStateNormal];
        [self.setSearchSeg setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fsize]} forState:UIControlStateNormal];
    }
    */
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
    [aTextView resignFirstResponder];
    return YES;
}

/*
 // needs more work to adjust text box size / display point as rotated view is very short
 
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

/*
- (void)viewDidUnload {
	DBGLog(@"vde view did unload");
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[self.vo.vos dataEditVDidUnload];
	self.vo = nil;
}
*/

- (void)dealloc {
	
	//DBGLog(@"vde dealloc");
    if (self.vo) {
        self.vo = nil;
    }
	//[vo release];

}


@end
