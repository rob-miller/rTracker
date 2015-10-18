//
//  rTrackerUITests.m
//  rTrackerUITests
//
//  Created by Rob Miller on 29/09/2015.
//  Copyright © 2015 Robert T. Miller. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface rTrackerUITests : XCTestCase

@end

@implementation rTrackerUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.navigationBars[@"rTracker"].buttons[@"Add"] tap];
    
    XCUIElementQuery *tablesQuery = app.tables;
    [tablesQuery.textFields[@"Name this Tracker"] tap];
    [[[[tablesQuery childrenMatchingType:XCUIElementTypeCell] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeTextField].element typeText:@"Newt"];
    [tablesQuery.staticTexts[@"Add an item or value to track"] tap];
    
    XCUIElement *textField = [[[[[[[[[app childrenMatchingType:XCUIElementTypeWindow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:1] childrenMatchingType:XCUIElementTypeTextField].element;
    [textField tap];
    [textField typeText:@"n"];
    [app.keys[@"more, numbers"] tap];
    [textField typeText:@"1"];
    [app typeText:@"\n"];
    [app.pickerWheels[@"1 of 12"] swipeUp];
    [app.pickerWheels[@"dots, 1 of 4"] swipeUp];
    
    XCUIElement *saveButton = [app.navigationBars matchingIdentifier:@"Configure Item"].buttons[@"Save"];
    [saveButton tap];
    [tablesQuery.staticTexts[@"add another thing to track"] tap];
    [app.pickerWheels[@"number, 1 of 8"] pressForDuration:1.1];
    [textField tap];
    [textField typeText:@"t1"];
    [app typeText:@"\n"];
    
    XCUIElementQuery *toolbarsQuery = app.toolbars;
    [toolbarsQuery.buttons[@"\U2699"] tap];
    [app.buttons[@"checked"] tap];
    [toolbarsQuery.buttons[@"\U2611"] tap];
    [saveButton tap];
    [app.navigationBars[@"Add tracker"].buttons[@"Save"] tap];
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end
