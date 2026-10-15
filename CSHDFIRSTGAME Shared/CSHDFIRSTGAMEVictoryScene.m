//
//  CSHDFIRSTGAMEVictoryScene.m
//  CSHDFIRSTGAME iOS
//
//  Created by apple on 2026/9/3.
//

#import "CSHDFIRSTGAMEVictoryScene.h"
#import "CSHDFIRSTGAMEDataManager.h"
#import "CSHDFIRSTGAMEAudioManager.h"

@implementation CSHDFIRSTGAMEVictoryScene

- (void)didMoveToView:(SKView *)view {
    self.scaleMode = SKSceneScaleModeAspectFit;
    [[CSHDFIRSTGAMEAudioManager sharedManager] refreshMusic];
    if (self.CSHDFIRSTGAMELevel == 0) self.CSHDFIRSTGAMELevel = [self.userData[@"CSHDFIRSTGAMELevel"] integerValue];
    SKLabelNode *score = (SKLabelNode *)[self childNodeWithName:@"Score"];
    if ([score isKindOfClass:[SKLabelNode class]] && self.CSHDFIRSTGAMEScore != 0) score.text = [NSString stringWithFormat:@"%ld", (long)self.CSHDFIRSTGAMEScore];
    if (self.CSHDFIRSTGAMELevel >= 9) {
        SKNode *next = [self childNodeWithName:@"NEXT"];
        next.hidden = YES;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSString *name = [self nodeAtPoint:[[touches anyObject] locationInNode:self]].name;
    if ([name isEqualToString:@"RETRY"]) {
        [[CSHDFIRSTGAMEAudioManager sharedManager] playButtonFeedback];
        SKScene *game = [SKScene nodeWithFileNamed:@"CSHDFIRSTGAMEGameScene"]; game.scaleMode = SKSceneScaleModeAspectFit;
        game.userData = [@{@"CSHDFIRSTGAMELevel": @(MAX(1, self.CSHDFIRSTGAMELevel))} mutableCopy];
        [self.view presentScene:game transition:[SKTransition fadeWithDuration:0.2]];
    } else if ([name isEqualToString:@"NEXT"]) {
        [[CSHDFIRSTGAMEAudioManager sharedManager] playButtonFeedback];
        [[CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager] CSHDFIRSTGAMECompleteLevel:self.CSHDFIRSTGAMELevel];
        NSInteger nextLevel = MIN(9, MAX(1, self.CSHDFIRSTGAMELevel + 1));
        SKScene *game = [SKScene nodeWithFileNamed:@"CSHDFIRSTGAMEGameScene"]; game.scaleMode = SKSceneScaleModeAspectFit;
        game.userData = [@{@"CSHDFIRSTGAMELevel": @(nextLevel)} mutableCopy];
        [self.view presentScene:game transition:[SKTransition fadeWithDuration:0.2]];
    }
}

@end
