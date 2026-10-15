//
//  CSHDFIRSTGAMEGradScene.m
//  CSHDFIRSTGAME iOS
//
//  Created by apple on 2026/9/3.
//

#import "CSHDFIRSTGAMEGradScene.h"
#import "CSHDFIRSTGAMEDataManager.h"
#import "CSHDFIRSTGAMEAudioManager.h"

@implementation CSHDFIRSTGAMEGradScene

- (void)didMoveToView:(SKView *)view {
    self.scaleMode = SKSceneScaleModeAspectFit;
    [[CSHDFIRSTGAMEAudioManager sharedManager] refreshMusic];
    [self CSHDFIRSTGAMERefreshLevels];
}

- (void)CSHDFIRSTGAMERefreshLevels {
    CSHDFIRSTGAMEDataManager *data = [CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager];
    for (NSInteger level = 1; level <= 9; level++) {
        SKSpriteNode *node = (SKSpriteNode *)[self childNodeWithName:[NSString stringWithFormat:@"%ld", (long)level]];
        if (![node isKindOfClass:[SKSpriteNode class]]) continue;
        BOOL unlocked = [data CSHDFIRSTGAMEIsLevelUnlocked:level];
//        node.alpha = unlocked ? 1.0 : 0.35;
        node.color = unlocked ? [SKColor whiteColor] : [SKColor grayColor];
        node.colorBlendFactor = unlocked ? 0.0 : 0.55;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    if ([node.name isEqualToString:@"back"]) {
        [[CSHDFIRSTGAMEAudioManager sharedManager] playButtonFeedback];
        SKScene *home = [SKScene nodeWithFileNamed:@"CSHDFIRSTGAMEHomeScene"]; home.scaleMode = SKSceneScaleModeAspectFit;
        [self.view presentScene:home transition:[SKTransition fadeWithDuration:0.2]]; return;
    }
    NSInteger level = node.name.integerValue;
    if (level < 1 || level > 9 || ![[CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager] CSHDFIRSTGAMEIsLevelUnlocked:level]) return;
    [[CSHDFIRSTGAMEAudioManager sharedManager] playButtonFeedback];
    SKScene *game = [SKScene nodeWithFileNamed:@"CSHDFIRSTGAMEGameScene"];
    game.scaleMode = SKSceneScaleModeAspectFit;
    game.userData = [@{ @"CSHDFIRSTGAMELevel": @(level) } mutableCopy];
    [self.view presentScene:game transition:[SKTransition fadeWithDuration:0.2]];
}

@end
