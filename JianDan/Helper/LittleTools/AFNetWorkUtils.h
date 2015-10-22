#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>
#import "NSErrorHelper.h"

typedef NS_ENUM(NSInteger, NetType) {
    NONet,
    WiFiNet,
    OtherNet,
};

@interface AFNetWorkUtils : NSObject

@property(nonatomic, assign) NSInteger netType;

@property(nonatomic, strong) NSString *netTypeString;

+ (AFNetWorkUtils *)sharedAFNetWorkUtils;

@property(nonatomic, strong) RACSignal *excuting;

- (void)startMonitoring;

- (RACSignal *)startMonitoringNet;

+ (RACSignal *)post2racWthURL:(NSString *)url params:(NSDictionary *)params;

+ (RACSignal *)racPOSTWithURL:(NSString *)url params:(NSDictionary *)params class:(Class)clazz;

+ (RACSignal *)get2racWthURL:(NSString *)url;

+ (RACSignal *)get2racUNJSONWthURL:(NSString *)url;

+ (RACSignal *)racGETWithURL:(NSString *)url class:(Class)clazz;

@end
