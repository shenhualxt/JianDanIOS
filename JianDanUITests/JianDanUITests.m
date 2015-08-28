//
//  JianDanUITests.m
//  JianDanUITests
//
//  Created by 刘献亭 on 15/8/28.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface JianDanUITests : XCTestCase

@end

@implementation JianDanUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end
