//
//  CSHDFIRSTGAMEFuritCollectScene.m
//  CSHDFIRSTGAME iOS
//
//  Created by apple on 2026/9/3.
//

#import "CSHDFIRSTGAMEFuritCollectScene.h"
#import "CSHDFIRSTGAMEDataManager.h"
#import "CSHDFIRSTGAMEAudioManager.h"

@implementation CSHDFIRSTGAMEFuritCollectScene

- (void)didMoveToView:(SKView *)view {
    self.scaleMode = SKSceneScaleModeAspectFit;
    [[CSHDFIRSTGAMEAudioManager sharedManager] refreshMusic];
    [self CSHDFIRSTGAMERefreshFruits];
}

- (void)CSHDFIRSTGAMERefreshFruits {
    CSHDFIRSTGAMEDataManager *data = [CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager];
    NSArray *keys = @[CSHDFIRSTGAMEFruitHLG, CSHDFIRSTGAMEFruitLI, CSHDFIRSTGAMEFruitPineapple, CSHDFIRSTGAMEFruitBlueberry,CSHDFIRSTGAMEFruitWatermelon, CSHDFIRSTGAMEFruitPeach, CSHDFIRSTGAMEFruitOrange, CSHDFIRSTGAMEFruitGrape,CSHDFIRSTGAMEFruitCherry, CSHDFIRSTGAMEFruitStrawberry, CSHDFIRSTGAMEFruitApple, CSHDFIRSTGAMEFruitBanana, CSHDFIRSTGAMEFruitDurian];
    for (NSString *key in keys) {
        SKLabelNode *label = (SKLabelNode *)[self childNodeWithName:key];
        if ([label isKindOfClass:[SKLabelNode class]]) label.text = [NSString stringWithFormat:@"%ld/100", (long)[data CSHDFIRSTGAMEFruitCountForKey:key]];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    if (![node.name isEqualToString:@"back"]) return;
    [[CSHDFIRSTGAMEAudioManager sharedManager] playButtonFeedback];
    SKScene *home = [SKScene nodeWithFileNamed:@"CSHDFIRSTGAMEHomeScene"]; home.scaleMode = SKSceneScaleModeAspectFit;
    [self.view presentScene:home transition:[SKTransition fadeWithDuration:0.2]];
}

@end
