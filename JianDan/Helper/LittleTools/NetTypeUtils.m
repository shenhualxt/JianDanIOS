//
//  NetTypeUtils.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/6.
//  Copyright (c) 2015 刘献亭. All rights reserved.
//

#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "NetTypeUtils.h"
#define WS(weakSelf)  __weak __typeof(&*self) weakSelf = self;

@implementation NetTypeUtils

DEFINE_SINGLETON_IMPLEMENTATION(NetTypeUtils)

- (void)startMonitoring {
    AFNetworkReachabilityManager *mgr =[AFNetworkReachabilityManager sharedManager];
    WS(ws)
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                ws.netType=WiFiNet;
                break;

            case AFNetworkReachabilityStatusReachableViaWWAN:
                ws.netType=OtherNet;
                break;

            case AFNetworkReachabilityStatusNotReachable:
                ws.netType=NONet;
                break;

            case AFNetworkReachabilityStatusUnknown:
                ws.netType=NONet;
                break;
            default:
                break;
        }
    }];
    // 开始监控
    [mgr startMonitoring];
}

@end
