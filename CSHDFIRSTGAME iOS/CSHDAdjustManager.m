#import "CSHDAdjustManager.h"

#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <UIKit/UIKit.h>
#import <Adjust.h>
#import <ADJConfig.h>
#import <ADJLogger.h>

NSNotificationName const CSHDAdjustIDFADidUpdateNotification = @"CSHDAdjustIDFADidUpdateNotification";
NSString * const CSHDAdjustIDFAUserInfoKey = @"idfa";
NSString * const CSHDAdjustTrackingAuthorizationStatusUserInfoKey = @"trackingAuthorizationStatus";

static NSString * const CSHDAdjustAppTokenInfoKey = @"CSHDAdjustAppToken";
static NSString * const CSHDAdjustAppTokenPlaceholder = @"REPLACE_WITH_ADJUST_APP_TOKEN";

@interface CSHDAdjustManager ()

@property (atomic, copy, readwrite, nullable) NSString *idfa;
@property (atomic, assign, readwrite) NSInteger trackingAuthorizationStatus;
@property (nonatomic, assign) BOOL sdkStarted;
@property (nonatomic, assign) BOOL trackingRequestScheduled;
@property (nonatomic, assign) BOOL observingApplicationLifecycle;

- (instancetype)CSHD_init __attribute__((objc_method_family(init)));

@end


@implementation CSHDAdjustManager

+ (CSHDAdjustManager *)sharedManager {
    static CSHDAdjustManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CSHDAdjustManager alloc] CSHD_init];
    });
    return manager;
}

- (instancetype)CSHD_init {
    self = [super init];
    if (self) {
        _trackingAuthorizationStatus = ATTrackingManager.trackingAuthorizationStatus;
    }
    return self;
}

- (void)start {
    [self CSHD_beginObservingApplicationLifecycle];
    [self CSHD_startAdjustIfPossible];

    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
        [self CSHD_requestTrackingAuthorizationIfNeeded];
    }
}

- (void)CSHD_beginObservingApplicationLifecycle {
    @synchronized (self) {
        if (self.observingApplicationLifecycle) {
            return;
        }
        self.observingApplicationLifecycle = YES;
    }

    NSNotificationCenter *notificationCenter = NSNotificationCenter.defaultCenter;
    [notificationCenter addObserver:self
                           selector:@selector(CSHD_applicationDidBecomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
}

- (void)CSHD_applicationDidBecomeActive:(NSNotification *)notification {
    [self CSHD_startAdjustIfPossible];
    [self CSHD_requestTrackingAuthorizationIfNeeded];
}

- (void)CSHD_startAdjustIfPossible {
    @synchronized (self) {
        if (self.sdkStarted) {
            return;
        }

        NSString *appToken = [NSBundle.mainBundle objectForInfoDictionaryKey:CSHDAdjustAppTokenInfoKey];
        appToken = [appToken isKindOfClass:NSString.class]
            ? [appToken stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]
            : nil;
        if (appToken.length != 12 || [appToken isEqualToString:CSHDAdjustAppTokenPlaceholder]) {
            return;
        }

        NSString *environment = ADJEnvironmentSandbox;

//        NSString *environment = ADJEnvironmentProduction;

        ADJConfig *config = [[ADJConfig alloc] initWithAppToken:appToken environment:environment];
        if (config == nil) {
            return;
        }
        config.attConsentWaitingInterval = 60;

//        config.logLevel = ADJLogLevelVerbose;

//        config.logLevel = ADJLogLevelWarn;

        [Adjust initSdk:config];
        self.sdkStarted = YES;
    }
}

- (void)CSHD_requestTrackingAuthorizationIfNeeded {
    ATTrackingManagerAuthorizationStatus status = ATTrackingManager.trackingAuthorizationStatus;
    self.trackingAuthorizationStatus = status;

    if (status != ATTrackingManagerAuthorizationStatusNotDetermined) {
        [self CSHD_resolveIDFAForStatus:status];
        return;
    }

    @synchronized (self) {
        if (self.trackingRequestScheduled) {
            return;
        }
        self.trackingRequestScheduled = YES;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
            self.trackingRequestScheduled = NO;
            return;
        }

        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.trackingAuthorizationStatus = status;
                [self CSHD_resolveIDFAForStatus:status];
            });
        }];
    });
}

- (void)CSHD_resolveIDFAForStatus:(ATTrackingManagerAuthorizationStatus)status {
    if (status != ATTrackingManagerAuthorizationStatusAuthorized) {
        [self CSHD_publishIDFA:nil status:status];
        return;
    }

    if (self.sdkStarted) {
        [Adjust idfaWithCompletionHandler:^(NSString * _Nullable idfa) {
            NSString *resolvedIDFA = [self CSHD_validIDFAFromString:idfa];
            if (resolvedIDFA == nil) {
                resolvedIDFA = [self CSHD_systemIDFA];
            }
            [self CSHD_publishIDFA:resolvedIDFA status:status];
        }];
        return;
    }

    [self CSHD_publishIDFA:[self CSHD_systemIDFA] status:status];
}

- (nullable NSString *)CSHD_systemIDFA {
    return [self CSHD_validIDFAFromString:ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString];
}

- (nullable NSString *)CSHD_validIDFAFromString:(nullable NSString *)idfa {
    if (idfa.length == 0 || [idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
        return nil;
    }
    return idfa;
}

- (void)CSHD_publishIDFA:(nullable NSString *)idfa status:(ATTrackingManagerAuthorizationStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.idfa = idfa;
        self.trackingAuthorizationStatus = status;

        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(status) forKey:CSHDAdjustTrackingAuthorizationStatusUserInfoKey];
        if (idfa != nil) {
            userInfo[CSHDAdjustIDFAUserInfoKey] = idfa;
        }
        [NSNotificationCenter.defaultCenter postNotificationName:CSHDAdjustIDFADidUpdateNotification object:self userInfo:userInfo];
    });
}

@end
