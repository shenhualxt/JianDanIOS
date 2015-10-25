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

- (void)startMonitoring;

- (RACSignal *)startMonitoringNet;

+ (RACSignal *)racPOSTWthURL:(NSString *)url params:(NSDictionary *)params;

+ (RACSignal *)racPOSTWithURL:(NSString *)url params:(NSDictionary *)params class:(Class)clazz;

+ (RACSignal *)racGETUNJSONWthURL:(NSString *)url;

+ (RACSignal *)racGETWthURL:(NSString *)url;

+ (RACSignal *)racGETWithURL:(NSString *)url class:(Class)clazz;

@end
