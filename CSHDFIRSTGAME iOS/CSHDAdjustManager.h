#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSNotificationName const CSHDAdjustIDFADidUpdateNotification;
FOUNDATION_EXPORT NSString * const CSHDAdjustIDFAUserInfoKey;
FOUNDATION_EXPORT NSString * const CSHDAdjustTrackingAuthorizationStatusUserInfoKey;

@interface CSHDAdjustManager : NSObject

@property (class, nonatomic, readonly) CSHDAdjustManager *sharedManager;
@property (atomic, copy, readonly, nullable) NSString *idfa;
@property (atomic, assign, readonly) NSInteger trackingAuthorizationStatus;

- (void)start;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
