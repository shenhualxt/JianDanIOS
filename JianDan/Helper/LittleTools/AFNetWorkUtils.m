#import "AFNetWorkUtils.h"
#import "AFNetWorking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "MJExtension.h"

NSString *const netWorkUtilsDomain = @"http://AFNetWorkUtils";

NSString *const operationInfoKey = @"operationInfoKey";

NSString *const errorHelperDomain = @"http://NSErrorHelper";

@implementation NSErrorHelper

+ (NSString *)handleErrorMessage:(NSError *)error {
    NSString * result = nil;
    switch (error.code) {
        case customErrorCode://0 自定义错误
            result = error.userInfo[customErrorInfoKey];
            break;
        case kCFURLErrorTimedOut://-1001
            result = @"服务器连接超时";
            break;
        case kCFURLErrorBadServerResponse://-1011
            result = @"请求无效";
            break;
        case kCFURLErrorNotConnectedToInternet: //-1009 @"似乎已断开与互联网的连接。"
        case kCFURLErrorCannotDecodeContentData://-1016 cmcc 解析数据失败
            result = @"网络好像断开了...";
            break;
        case kCFURLErrorCannotFindHost: //-1003 @"未能找到使用指定主机名的服务器。"
            result = @"服务器内部错误";
            break;
        case kCFURLErrorNetworkConnectionLost: //-1005
            result = @"网络连接已中断";
            break;
        default:
            result = @"其他错误";
            NSLog(@"其他错误 error:%@", error);
            break;
    }
    
    return result;
}

+ (NSError *)createErrorWithErrorInfo:(NSString *)customErrorInfo {
    return [NSError errorWithDomain:errorHelperDomain code:customErrorCode userInfo:@{customErrorInfoKey : customErrorInfo}];
}

+ (NSError *)createErrorWithErrorInfo:(NSString *)customErrorInfo domain:(NSString *)domain {
    return [NSError errorWithDomain:domain code:customErrorCode userInfo:@{customErrorInfoKey : customErrorInfo}];
}

+ (NSError *)createErrorWithErrorInfo:(NSString *)customErrorInfo domain:(NSString *)domain code:(NSInteger)code {
    return [NSError errorWithDomain:domain code:code userInfo:@{customErrorInfoKey : customErrorInfo}];
}

+ (NSError *)createErrorWithDomain:(NSString *)domain code:(NSInteger)code {
    return [NSError errorWithDomain:domain code:code userInfo:nil];
}

+ (NSError *)createErrorWithUserInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:errorHelperDomain code:customErrorCode userInfo:userInfo];
}

+ (NSError *)createErrorWithUserInfo:(NSDictionary *)userInfo domain:(NSString *)domain {
    return [NSError errorWithDomain:domain code:customErrorCode userInfo:userInfo];
}

+ (NSError *)createErrorWithUserInfo:(NSDictionary *)userInfo domain:(NSString *)domain code:(NSInteger)code {
    return [NSError errorWithDomain:domain code:code userInfo:userInfo];
}

@end

@implementation AFNetWorkUtils

static AFNetWorkUtils *sharedAFNetWorkUtils = nil;
static dispatch_once_t pred;

+ (AFNetWorkUtils *)sharedAFNetWorkUtils {
    dispatch_once(&pred, ^{
        sharedAFNetWorkUtils = [[super allocWithZone:NULL] init];
        if ([sharedAFNetWorkUtils respondsToSelector:@selector(setUp)]) {
        [sharedAFNetWorkUtils setUp];
        }
    });
    return sharedAFNetWorkUtils;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedAFNetWorkUtils];
}

- (id)copyWithZone:(NSZone *)zone {
   return self;
}

- (void)setUp {
    self.netType = WiFiNet;
    self.netTypeString = @"WIFI";
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
        NSMutableSet *acceptableContentTypes = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
        [acceptableContentTypes addObject:@"text/plain"];
        [acceptableContentTypes addObject:@"text/html"];
        manager.responseSerializer.acceptableContentTypes = acceptableContentTypes;
    });
    return manager;
}

- (void)startMonitoring {
    [[self startMonitoringNet] subscribeNext:^(id x) {
    }];
}

- (RACSignal *)startMonitoringNet {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr startMonitoring];
    __weak __typeof(&*self) ws = self;
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
         AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
        [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    ws.netType = WiFiNet;
                    self.netType = WiFiNet;
                    self.netTypeString = @"WIFI";
                    break;

                case AFNetworkReachabilityStatusReachableViaWWAN:
                    ws.netType = OtherNet;
                    ws.netTypeString = @"2G/3G/4G";
                    break;

                case AFNetworkReachabilityStatusNotReachable:
                    ws.netType = NONet;
                    ws.netTypeString = @"网络已断开";
                    break;

                case AFNetworkReachabilityStatusUnknown:
                    ws.netType = NONet;
                    ws.netTypeString = @"其他情况";
                    break;
                default:
                    break;
            }
            [subscriber sendNext:ws.netTypeString];
            //            [subscriber sendCompleted];
        }];
        return nil;
    }] setNameWithFormat:@"<%@: %p> -startMonitoringNet", self.class, self];
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
+ (RACSignal *)racPOSTWthURL:(NSString *)url params:(NSDictionary *)params {
    if ([AFNetWorkUtils sharedAFNetWorkUtils].netType == NONet) {
        return [self getNoNetSignal];
    }
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

        AFHTTPRequestOperationManager *manager = [self sharedHTTPOperationManager];
        AFHTTPRequestOperation *operation = [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self handleResultWithSubscriber:(id <RACSubscriber>) subscriber operation:operation responseObject:responseObject];
        }                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handleErrorResultWithSubscriber:(id <RACSubscriber>) subscriber operation:operation error:error];
        }];
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }] setNameWithFormat:@"<%@: %p> -post2racWthURL: %@, params: %@", self.class, self, url, params];
}

+ (RACSignal *)racGETWthURL:(NSString *)url {
    return [[self racGETWthURL:url isJSON:YES] setNameWithFormat:@"<%@: %p> -get2racWthURL: %@", self.class, self, url];
}

+ (RACSignal *)racGETUNJSONWthURL:(NSString *)url {
    return [[self racGETWthURL:url isJSON:NO] setNameWithFormat:@"<%@: %p> -get2racUNJSONWthURL: %@", self.class, self, url];
}

+ (RACSignal *)racGETWthURL:(NSString *)url isJSON:(BOOL)isJSON {
    if ([AFNetWorkUtils sharedAFNetWorkUtils].netType == NONet) {
        return [self getNoNetSignal];
    }
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        AFHTTPRequestOperationManager *manager = [self sharedHTTPOperationManager];
        if (!isJSON) {
            manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        }
        AFHTTPRequestOperation *operation = [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (!isJSON) {
                [subscriber sendNext:responseObject];
                [subscriber sendCompleted];
                return;
            }
            [self handleResultWithSubscriber:(id <RACSubscriber>) subscriber operation:operation responseObject:responseObject];
        }                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (!isJSON) {
                [subscriber sendNext:error];
                return;
            }
            [self handleErrorResultWithSubscriber:(id <RACSubscriber>) subscriber operation:operation error:error];
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
    if ([AFNetWorkUtils sharedAFNetWorkUtils].netType == NONet) {
        return [self getNoNetSignal];
    }
    //有网络
    return [[[[self racPOSTWthURL:url params:params] map:^id(id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            return [clazz objectArrayWithKeyValuesArray:responseObject];
        } else {
            return [clazz objectWithKeyValues:responseObject];
        }
    }] replayLazily] setNameWithFormat:@"<%@: %p> -racPOSTWithURL: %@, params: %@ class: %@", self.class, self, url, params, NSStringFromClass(clazz)];
}


+ (RACSignal *)racGETWithURL:(NSString *)url class:(Class)clazz {
    if ([AFNetWorkUtils sharedAFNetWorkUtils].netType == NONet) {
        return [self getNoNetSignal];
    }
    //有网络
    return [[[[self racGETWthURL:url] map:^id(id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            return [clazz objectArrayWithKeyValuesArray:responseObject];
        } else {
            return [clazz objectWithKeyValues:responseObject];
        }
    }] replayLazily] setNameWithFormat:@"<%@: %p> -racGETWithURL: %@,class: %@", self.class, self, url, NSStringFromClass(clazz)];
}

+ (RACSignal *)getNoNetSignal {
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        [subscriber sendError:[NSErrorHelper createErrorWithDomain:netWorkUtilsDomain code:kCFURLErrorNotConnectedToInternet]];
        return nil;
    }] setNameWithFormat:@"<%@: %p> -getNoNetSignal", self.class, self];
}

+ (void)handleErrorResultWithSubscriber:(id <RACSubscriber>)subscriber operation:(AFHTTPRequestOperation *)operation error:(NSError *)error {
    NSMutableDictionary *userInfo = [error.userInfo mutableCopy] ?: [NSMutableDictionary dictionary];
    userInfo[operationInfoKey] = operation;
    userInfo[customErrorInfoKey] = [NSErrorHelper handleErrorMessage:error];
    [subscriber sendError:[NSErrorHelper createErrorWithUserInfo:userInfo domain:netWorkUtilsDomain]];
}

+ (void)handleResultWithSubscriber:(id <RACSubscriber>)subscriber operation:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject {
    //在此根据自己应用的接口进行统一处理

    //示例(测试接口)
    NSInteger count = [[responseObject objectForKey:@"count"] integerValue];
    if (!count) {
        [subscriber sendNext:responseObject];
        [subscriber sendCompleted];
        return;
    }
   

    //统一格式接口
    NSString * status = [responseObject objectForKey:@"status"];
    if ([status isEqualToString:@"ok"]) {
        //  [subscriber sendNext:RACTuplePack(operation,responseObject)];
        [subscriber sendNext:responseObject];
        [subscriber sendCompleted];
    } else {//正确返回，带有错误信息
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[operationInfoKey] = operation;
        BOOL isError = [status isEqualToString:@"error"];
        NSString * errorInfo = isError ? [responseObject objectForKey:@"error"] : @"请求没有得到处理";
        userInfo[customErrorInfoKey] = errorInfo;
        NSError * error = [NSErrorHelper createErrorWithUserInfo:userInfo domain:netWorkUtilsDomain];
        [subscriber sendError:error];
    }
}

@end
