//
//  CSHDFIRSTGAMEFailScene.m
//  CSHDFIRSTGAME iOS
//
//  Created by apple on 2026/9/3.
//

#import "CSHDFIRSTGAMEFailScene.h"
#import "CSHDFIRSTGAMEAudioManager.h"

@implementation CSHDFIRSTGAMEFailScene

- (void)didMoveToView:(SKView *)view {
    self.scaleMode = SKSceneScaleModeAspectFit;
    [[CSHDFIRSTGAMEAudioManager sharedManager] refreshMusic];
    if (self.CSHDFIRSTGAMELevel == 0) self.CSHDFIRSTGAMELevel = [self.userData[@"CSHDFIRSTGAMELevel"] integerValue];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSString *name = [self nodeAtPoint:[[touches anyObject] locationInNode:self]].name;
    if ([name isEqualToString:@"Home"]) {
        [[CSHDFIRSTGAMEAudioManager sharedManager] playButtonFeedback];
        SKScene *home = [SKScene nodeWithFileNamed:@"CSHDFIRSTGAMEHomeScene"]; home.scaleMode = SKSceneScaleModeAspectFit;
        [self.view presentScene:home transition:[SKTransition fadeWithDuration:0.2]];
    } else if ([name isEqualToString:@"RETRY"]) {
        [[CSHDFIRSTGAMEAudioManager sharedManager] playButtonFeedback];
        SKScene *game = [SKScene nodeWithFileNamed:@"CSHDFIRSTGAMEGameScene"]; game.scaleMode = SKSceneScaleModeAspectFit;
        game.userData = [@{@"CSHDFIRSTGAMELevel": @(MAX(1, self.CSHDFIRSTGAMELevel))} mutableCopy];
        [self.view presentScene:game transition:[SKTransition fadeWithDuration:0.2]];
    }
}

@end
