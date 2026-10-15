#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Centralized audio and haptic feedback for every SpriteKit scene.
/// The manager reads the user's three settings from CSHDFIRSTGAMEDataManager.
@interface CSHDFIRSTGAMEAudioManager : NSObject

+ (instancetype)sharedManager;

/// Starts or stops the looping background track to match the Music setting.
- (void)refreshMusic;

/// Plays the short UI/fruit feedback sound when Sound is enabled.
- (void)playClick;

/// Plays a click and a light haptic for an interactive control.
- (void)playButtonFeedback;

/// Plays a success/failure feedback sound and haptic for the game result.
- (void)playSuccessFeedback;
- (void)playFailureFeedback;

/// Triggers a light haptic when Vibration is enabled.
- (void)triggerVibration;

@end

NS_ASSUME_NONNULL_END
