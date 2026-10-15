//
//  CSHDFIRSTGAMESettingScene.m
//  CSHDFIRSTGAME iOS
//
//  Created by apple on 2026/9/3.
//

#import "CSHDFIRSTGAMESettingScene.h"
#import "CSHDFIRSTGAMEDataManager.h"
#import "CSHDFIRSTGAMEAudioManager.h"

@implementation CSHDFIRSTGAMESettingScene

- (void)didMoveToView:(SKView *)view {
    self.scaleMode = SKSceneScaleModeAspectFit;
    [[CSHDFIRSTGAMEAudioManager sharedManager] refreshMusic];
    [self CSHDFIRSTGAMERefreshSettings];
}

- (void)CSHDFIRSTGAMERefreshSettings {
    CSHDFIRSTGAMEDataManager *data = [CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager];
    NSDictionary *states = @{@"MUSIC": @(data.CSHDFIRSTGAMEMusicEnabled), @"SOUND": @(data.CSHDFIRSTGAMESoundEnabled), @"ViBRATION": @(data.CSHDFIRSTGAMEVibrationEnabled)};
    NSDictionary *on = @{@"MUSIC": @"K1", @"SOUND": @"K2", @"ViBRATION": @"K3"};
    NSDictionary *off = @{@"MUSIC": @"K1-1", @"SOUND": @"K2-1", @"ViBRATION": @"K3-1"};
    for (NSString *name in states) {
        SKSpriteNode *node = (SKSpriteNode *)[self childNodeWithName:name];
        if ([node isKindOfClass:[SKSpriteNode class]]) node.texture = [SKTexture textureWithImageNamed:([(NSNumber *)states[name] boolValue] ? on[name] : off[name])];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    CSHDFIRSTGAMEDataManager *data = [CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager];
    if ([node.name isEqualToString:@"back"]) {
        [[CSHDFIRSTGAMEAudioManager sharedManager] playButtonFeedback];
        SKScene *home = [SKScene nodeWithFileNamed:@"CSHDFIRSTGAMEHomeScene"]; home.scaleMode = SKSceneScaleModeAspectFit;
        [self.view presentScene:home transition:[SKTransition fadeWithDuration:0.2]]; return;
    }
    if ([node.name isEqualToString:@"MUSIC"] || [node.name isEqualToString:@"SOUND"] || [node.name isEqualToString:@"ViBRATION"]) {
        [[CSHDFIRSTGAMEAudioManager sharedManager] playButtonFeedback];
    }
    if ([node.name isEqualToString:@"MUSIC"]) [data CSHDFIRSTGAMESetMusicEnabled:!data.CSHDFIRSTGAMEMusicEnabled];
    else if ([node.name isEqualToString:@"SOUND"]) [data CSHDFIRSTGAMESetSoundEnabled:!data.CSHDFIRSTGAMESoundEnabled];
    else if ([node.name isEqualToString:@"ViBRATION"]) [data CSHDFIRSTGAMESetVibrationEnabled:!data.CSHDFIRSTGAMEVibrationEnabled];
    [[CSHDFIRSTGAMEAudioManager sharedManager] refreshMusic];
    [self CSHDFIRSTGAMERefreshSettings];
}

@end
