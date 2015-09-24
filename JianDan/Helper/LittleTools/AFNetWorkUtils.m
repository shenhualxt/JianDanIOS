#import "AFNetWorkUtils.h"
#import "AFNetWorking.h"

NSString * const customDomain=@"http://jandan.net";
NSString * const RAFNetworkingErrorKey = @"AFHTTPRequestOperation";
NSString * const RAFNetworkingErrorInfoKey = @"AFHTTPRequestErrorInfo";
typedef NS_ENUM(NSInteger, AFNetWorkUtilsResponseType) {
  AFNetWorkUtilsResponseError,
  AFNetWorkUtilsResponsePending,
};

@implementation AFNetWorkUtils

SYNTHESIZE_SINGLETON_FOR_CLASS(AFNetWorkUtils)

/**
* 创建网络请求管理类单例对象
*/
+ (AFHTTPRequestOperationManager *)sharedHTTPOperationManager {
  static AFHTTPRequestOperationManager *manager = nil;
  static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer new];
        manager.requestSerializer.timeoutInterval = 30.f;//超时时间为30s
        NSMutableSet *acceptableContentTypes=[NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
        [acceptableContentTypes addObject:@"text/plain"];
        [acceptableContentTypes addObject:@"text/html"];
        manager.responseSerializer.acceptableContentTypes=acceptableContentTypes;
    });
    return manager;
}

-(void)startMonitoring {
    _netType=WiFiNet;
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
    [mgr startMonitoring];
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
    if ([AFNetWorkUtils sharedAFNetWorkUtils].netType==NONet) {
        return [self getNoNetSignal];
    }
  return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    AFHTTPRequestOperationManager *manager = [self sharedHTTPOperationManager];
    AFHTTPRequestOperation *operation= [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * operation, id responseObject) {
      [self handleResultWithSubscriber:(id<RACSubscriber>)subscriber operation:operation responseObject:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
        return [clazz objectWithKeyValues:responseObject];
    }] replayLazily];
}

+ (RACSignal *)racGETWithURL:(NSString *)url class:(Class)clazz {
    if ([AFNetWorkUtils sharedAFNetWorkUtils].netType==NONet) {
        return [self getNoNetSignal];
    }
  //有网络
  return [[[self get2racWthURL:url] map:^id(id responseObject) {
    return [clazz objectWithKeyValues:responseObject];
  }] replayLazily];
}

+(RACSignal *)getNoNetSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error=[NSError errorWithDomain:customDomain code:kCFURLErrorNotConnectedToInternet userInfo:nil];
        [subscriber sendError:error];
        return nil;
    }];
}

+ (void)handleErrorResultWithSubscriber:(id<RACSubscriber>)subscriber operation:(AFHTTPRequestOperation *)operation error:(NSError *)error {
  NSMutableDictionary *userInfo = [error.userInfo mutableCopy] ?: [NSMutableDictionary dictionary];
  userInfo[RAFNetworkingErrorKey] = operation;
  userInfo[RAFNetworkingErrorInfoKey] = [self handleErrorMessage:error];
  [subscriber sendError:[NSError errorWithDomain:error.domain code:error.code userInfo:userInfo]];
}

+ (NSString *)handleErrorMessage:(NSError *)error {
  NSString *result = nil;
  switch (error.code) {
    case kCFURLErrorTimedOut://-1001
      result = @"服务器连接超时";
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
      result =@"其他错误";
      LogBlue(@"其他错误 error:%@", error);
      break;
  }

  return result;
}


/*
 {
 "status": "ok",
 "id": 2774402,
 }

 {
 "status": "error",
 "error": "Post ID '61355' not found."
 }
 status:ok error pending
 仅适用于本项目
 */
+ (void)handleResultWithSubscriber:(id<RACSubscriber>)subscriber operation:(AFHTTPRequestOperation *)operation responseObject:(NSDictionary *)responseObject{
  NSString *status=[responseObject objectForKey:@"status"];
  if ([status isEqualToString:@"ok"]) {
    //  [subscriber sendNext:RACTuplePack(operation,responseObject)];
    [subscriber sendNext:responseObject];
    [subscriber sendCompleted];
  }else {//正确返回，带有错误信息
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    BOOL isError=[status isEqualToString:@"error"];
    userInfo[RAFNetworkingErrorInfoKey] =isError?[responseObject objectForKey:@"error"]:@"请求没有得到处理";
    userInfo[RAFNetworkingErrorKey] = operation;
    NSError *error=[NSError errorWithDomain:customDomain code:isError?AFNetWorkUtilsResponseError
                                                  :AFNetWorkUtilsResponsePending userInfo:userInfo];
    [subscriber sendError:error];
  }
}


@end
