#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

typedef NS_ENUM(NSInteger, NetType) {
    NONet,
    WiFiNet,
    OtherNet,
};

static NSInteger const customErrorCode = 0;

static NSString *const customErrorInfoKey = @"customErrorInfoKey";

@interface NSErrorHelper : NSObject

+ (NSString *)handleErrorMessage:(NSError *)error;

+ (NSError *)createErrorWithErrorInfo:(NSString *)customErrorInfo;

+ (NSError *)createErrorWithDomain:(NSString *)domain code:(NSInteger)code;

+ (NSError *)createErrorWithErrorInfo:(NSString *)customErrorInfo domain:(NSString *)domain;

+ (NSError *)createErrorWithErrorInfo:(NSString *)customErrorInfo domain:(NSString *)domain code:(NSInteger)code;

+ (NSError *)createErrorWithUserInfo:(NSDictionary *)userInfo;

+ (NSError *)createErrorWithUserInfo:(NSDictionary *)userInfo domain:(NSString *)domain;

+ (NSError *)createErrorWithUserInfo:(NSDictionary *)userInfo domain:(NSString *)domain code:(NSInteger)code;

@end

@interface AFNetWorkUtils : NSObject

@property(nonatomic, assign) NSInteger netType;

@property(nonatomic, strong) NSString *netTypeString;

+ (AFNetWorkUtils *)sharedAFNetWorkUtils;

- (void)startMonitoring;

- (RACSignal *)startMonitoringNet;

+ (RACSignal *)racPOSTWthURL:(NSString *)url params:(NSDictionary *)params;

+ (RACSignal *)racPOSTWithURL:(NSString *)url params:(NSDictionary *)params class:(Class)clazz;

+ (RACSignal *)racGETUNJSONWthURL:(NSString *)url;

+ (RACSignal *)racGETWthURL:(NSString *)url;

+ (RACSignal *)racGETWithURL:(NSString *)url class:(Class)clazz;

@end
