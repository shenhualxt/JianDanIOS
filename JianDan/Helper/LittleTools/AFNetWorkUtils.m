#import "AFNetWorkUtils.h"
#import "AFNetWorking.h"
#import "AFNetworkActivityIndicatorManager.h"

NSString * const netWorkUtilsDomain=@"http://AFNetWorkUtils";

NSString * const operationInfoKey = @"operationInfoKey";

@implementation AFNetWorkUtils

DEFINE_SINGLETON_IMPLEMENTATION(AFNetWorkUtils)

-(void)setUp{
    self.netType=WiFiNet;
    self.netTypeString=@"WIFI";
}

/**
 * 创建网络请求管理类单例对象
 */
+ (AFHTTPRequestOperationManager *)sharedHTTPOperationManager {
    static AFHTTPRequestOperationManager *manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer new];
        manager.requestSerializer.timeoutInterval = 20.f;//超时时间为20s
        NSMutableSet *acceptableContentTypes=[NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
        [acceptableContentTypes addObject:@"text/plain"];
        [acceptableContentTypes addObject:@"text/html"];
        manager.responseSerializer.acceptableContentTypes=acceptableContentTypes;
    });
    return manager;
}

-(void)startMonitoring{
    [[self startMonitoringNet] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

-(RACSignal *)excuting{
    return RACObserve([AFNetworkActivityIndicatorManager sharedManager], isNetworkActivityIndicatorVisible);
}

-(RACSignal *)startMonitoringNet {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    AFNetworkReachabilityManager *mgr =[AFNetworkReachabilityManager sharedManager];
    [mgr startMonitoring];
    WS(ws)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    ws.netType=WiFiNet;
                    self.netType=WiFiNet;
                    self.netTypeString=@"WIFI";
                    break;
                    
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    ws.netType=OtherNet;
                    ws.netTypeString=@"2G/3G/4G";
                    break;
                    
                case AFNetworkReachabilityStatusNotReachable:
                    ws.netType=NONet;
                    ws.netTypeString=@"网络已断开";
                    break;
                    
                case AFNetworkReachabilityStatusUnknown:
                    ws.netType=NONet;
                    ws.netTypeString=@"其他情况";
                    break;
                default:
                    break;
            }
            [subscriber sendNext:ws.netTypeString];
            //            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

#pragma mark -RAC

/**
 *  转换成响应式请求 可重用
 *
 *  @param url   请求地址
 *  @param params 请求参数
 *
 *  @return 带请求结果（字典）的信号
 */
+ (RACSignal *)post2racWthURL:(NSString *)url params:(NSDictionary *)params {
    if ([AFNetWorkUtils sharedAFNetWorkUtils].netType==NONet) {
        return [self getNoNetSignal];
    }
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        AFHTTPRequestOperationManager *manager = [self sharedHTTPOperationManager];
        AFHTTPRequestOperation *operation= [manager POST:url parameters:params success:^(AFHTTPRequestOperation * operation, id responseObject) {
            [self handleResultWithSubscriber:(id<RACSubscriber>)subscriber operation:operation responseObject:responseObject];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handleErrorResultWithSubscriber:(id<RACSubscriber>)subscriber operation:operation error:error];
        }];
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }];
}

+ (RACSignal *)get2racWthURL:(NSString *)url{
    return [self get2racWthURL:url isJSON:YES];
}

+ (RACSignal *)get2racUNJSONWthURL:(NSString *)url{
    return [self get2racWthURL:url isJSON:NO];
}

+ (RACSignal *)get2racWthURL:(NSString *)url isJSON:(BOOL)isJSON{
    if ([AFNetWorkUtils sharedAFNetWorkUtils].netType==NONet) {
        return [self getNoNetSignal];
    }
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        AFHTTPRequestOperationManager *manager = [self sharedHTTPOperationManager];
        if (!isJSON) {
            manager=[AFHTTPRequestOperationManager manager];
            manager.responseSerializer=[AFHTTPResponseSerializer serializer];
        }
        AFHTTPRequestOperation *operation= [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * operation, id responseObject) {
            if (!isJSON) {
                [subscriber sendNext:responseObject];
                [subscriber sendCompleted];
                return ;
            }
            [self handleResultWithSubscriber:(id<RACSubscriber>)subscriber operation:operation responseObject:responseObject];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (!isJSON) {
                [subscriber sendNext:error];
                return ;
            }
            [self handleErrorResultWithSubscriber:(id<RACSubscriber>)subscriber operation:operation error:error];
        }];
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }];
}

/**
 *  响应式post请求 返回处理后的结果 对象类型 可重用
 *
 *  @param url   请求地址
 *  @param params 请求参数
 *  @param clazz  字典对应的对象
 *
 *  @return 带请求结果（对象）的信号
 */
+ (RACSignal *)racPOSTWithURL:(NSString *)url params:(NSDictionary *)params class:(Class)clazz {
    if ([AFNetWorkUtils sharedAFNetWorkUtils].netType==NONet) {
        return [self getNoNetSignal];
    }
    //有网络
    return [[[self post2racWthURL:url params:params] map:^id(id responseObject) {
        if([responseObject isKindOfClass:[NSArray class]]){
            return [clazz objectArrayWithKeyValuesArray:responseObject];
        }else{
            return [clazz objectWithKeyValues:responseObject];
        }
    }] replayLazily];
}



+ (RACSignal *)racGETWithURL:(NSString *)url class:(Class)clazz {
    if ([AFNetWorkUtils sharedAFNetWorkUtils].netType==NONet) {
        return [self getNoNetSignal];
    }
    //有网络
    return [[[self get2racWthURL:url] map:^id(id responseObject) {
        if([responseObject isKindOfClass:[NSArray class]]){
            return [clazz objectArrayWithKeyValuesArray:responseObject];
        }else{
            return [clazz objectWithKeyValues:responseObject];
        }
    }] replayLazily];
}

+(RACSignal *)getNoNetSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendError:[NSErrorHelper createErrorWithDomain:netWorkUtilsDomain code:kCFURLErrorNotConnectedToInternet]];
        return nil;
    }];
}

+ (void)handleErrorResultWithSubscriber:(id<RACSubscriber>)subscriber operation:(AFHTTPRequestOperation *)operation error:(NSError *)error {
    NSMutableDictionary *userInfo = [error.userInfo mutableCopy] ?: [NSMutableDictionary dictionary];
    userInfo[operationInfoKey] = operation;
    userInfo[customErrorInfoKey] = [NSErrorHelper handleErrorMessage:error];
    [subscriber sendError:[NSErrorHelper createErrorWithUserInfo:userInfo domain:netWorkUtilsDomain]];
}

+ (void)handleResultWithSubscriber:(id<RACSubscriber>)subscriber operation:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject{
    //在此根据自己应用的接口进行统一处理
    
    //示例(测试接口)
    NSInteger count=[[responseObject objectForKey:@"count"] integerValue];
    if (!count) {
        [subscriber sendNext:responseObject];
        [subscriber sendCompleted];
        return;
    }
    
    //统一格式接口
    NSString *status=[responseObject objectForKey:@"status"];
    if ([status isEqualToString:@"ok"]) {
        //  [subscriber sendNext:RACTuplePack(operation,responseObject)];
        [subscriber sendNext:responseObject];
        [subscriber sendCompleted];
    }else {//正确返回，带有错误信息
        NSMutableDictionary *userInfo =[NSMutableDictionary dictionary];
        userInfo[operationInfoKey] = operation;
        BOOL isError=[status isEqualToString:@"error"];
        NSString *errorInfo =isError?[responseObject objectForKey:@"error"]:@"请求没有得到处理";
        userInfo[customErrorInfoKey] = errorInfo;
        NSError *error=[NSErrorHelper createErrorWithUserInfo:userInfo domain:netWorkUtilsDomain];
        [subscriber sendError:error];
    }
}

@end
