//
//  JianDanTests.m
//  JianDanTests
//
//  Created by 刘献亭 on 15/8/28.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CommonUtils.h"

@interface JianDanTests : XCTestCase

@end

@implementation JianDanTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    XCTAssertEqual([CommonUtils convertToInt:@"i'm a 苹果。..."], 15,@"统计错误");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
