//
//  CSVParser.h
//  CSVImporter
//
//  Created by Matt Gallagher on 2009/11/30.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

//#import <Cocoa/Cocoa.h>

@interface CSVParser : NSObject

{
	NSString *csvString;
	NSString *separator;
	NSScanner *scanner;
	BOOL hasHeader;
	NSMutableArray *fieldNames;
	id receiver;
	SEL receiverSelector;
	NSCharacterSet *endTextCharacterSet;
	BOOL separatorIsSingleChar;
}

- (id)initWithString:(NSString *)aCSVString
    separator:(NSString *)aSeparatorString
    hasHeader:(BOOL)header
    fieldNames:(NSArray *)names;

- (NSArray *)arrayOfParsedRows;
- (void)parseRowsForReceiver:(id)aReceiver selector:(SEL)aSelector;

- (NSArray *)parseFile;
- (NSMutableArray *)parseHeader;
- (NSDictionary *)parseRecord;
- (NSString *)parseName;
- (NSString *)parseField;
- (NSString *)parseEscaped;
- (NSString *)parseNonEscaped;
- (NSString *)parseDoubleQuote;
- (NSString *)parseSeparator;
- (NSString *)parseLineSeparator;
- (NSString *)parseTwoDoubleQuotes;
- (NSString *)parseTextData;

@end
