#import "CSHDFIRSTGAMEAudioManager.h"
#import "CSHDFIRSTGAMEDataManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>

@interface CSHDFIRSTGAMEAudioManager ()
@property (nonatomic, strong) AVAudioPlayer *musicPlayer;
@property (nonatomic, strong) UIImpactFeedbackGenerator *lightImpact;
@property (nonatomic, strong) UIImpactFeedbackGenerator *mediumImpact;
@property (nonatomic) BOOL musicRunning;
@end

@implementation CSHDFIRSTGAMEAudioManager

+ (instancetype)sharedManager {
    static CSHDFIRSTGAMEAudioManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lightImpact = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        _mediumImpact = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [_lightImpact prepare];
        [_mediumImpact prepare];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(CSHDFIRSTGAMEAudioSessionInterrupted:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)CSHDFIRSTGAMEMusicEnabled {
    return [CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager].CSHDFIRSTGAMEMusicEnabled;
}

- (BOOL)CSHDFIRSTGAMESoundEnabled {
    return [CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager].CSHDFIRSTGAMESoundEnabled;
}

- (BOOL)CSHDFIRSTGAMEVibrationEnabled {
    return [CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager].CSHDFIRSTGAMEVibrationEnabled;
}

- (void)CSHDFIRSTGAMEPrepareAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryAmbient
             withOptions:AVAudioSessionCategoryOptionMixWithOthers
                   error:nil];
    [session setActive:YES error:nil];
}

- (void)refreshMusic {
    if ([self CSHDFIRSTGAMEMusicEnabled]) {
        [self CSHDFIRSTGAMEStartMusicIfNeeded];
    } else {
        [self CSHDFIRSTGAMEStopMusic];
    }
}

- (void)CSHDFIRSTGAMEStartMusicIfNeeded {
    if (self.musicRunning && self.musicPlayer.isPlaying) return;
    [self CSHDFIRSTGAMEPrepareAudioSession];
    if (!self.musicPlayer) {
        NSURL *musicURL = [[NSBundle mainBundle] URLForResource:@"CSHDFIRSTGAMEYY" withExtension:@"wav"];
        if (!musicURL) {
            NSLog(@"CSHDFIRSTGAME background music resource not found in app bundle");
            return;
        }
        NSError *error = nil;
        self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:&error];
        if (error || !self.musicPlayer) {
            NSLog(@"CSHDFIRSTGAME background music could not load: %@", error.localizedDescription);
            self.musicPlayer = nil;
            return;
        }
        self.musicPlayer.numberOfLoops = -1;
        self.musicPlayer.volume = 0.75f;
        [self.musicPlayer prepareToPlay];
    }
    if (![self.musicPlayer play]) {
        self.musicRunning = NO;
        NSLog(@"CSHDFIRSTGAME background music could not start");
        return;
    }
    self.musicRunning = YES;
}

- (void)CSHDFIRSTGAMEStopMusic {
    [self.musicPlayer stop];
    self.musicRunning = NO;
}

- (void)playClick {
    if (![self CSHDFIRSTGAMESoundEnabled]) return;
    AudioServicesPlaySystemSound(1104);
}

- (void)playButtonFeedback {
    [self playClick];
    [self triggerVibration];
}

- (void)playSuccessFeedback {
    if ([self CSHDFIRSTGAMESoundEnabled]) AudioServicesPlaySystemSound(1057);
    if ([self CSHDFIRSTGAMEVibrationEnabled]) {
        [self.mediumImpact impactOccurred];
        [self.mediumImpact prepare];
    }
}

- (void)playFailureFeedback {
    if ([self CSHDFIRSTGAMESoundEnabled]) AudioServicesPlaySystemSound(1073);
    if ([self CSHDFIRSTGAMEVibrationEnabled]) {
        [self.mediumImpact impactOccurred];
        [self.mediumImpact prepare];
    }
}

- (void)triggerVibration {
    if (![self CSHDFIRSTGAMEVibrationEnabled]) return;
    [self.lightImpact impactOccurred];
    [self.lightImpact prepare];
}

- (void)CSHDFIRSTGAMEAudioSessionInterrupted:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeEnded && [self CSHDFIRSTGAMEMusicEnabled]) {
        [self CSHDFIRSTGAMEStartMusicIfNeeded];
    } else if (type == AVAudioSessionInterruptionTypeBegan) {
        self.musicRunning = NO;
    }
}

@end
