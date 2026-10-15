//
//  CSHDFIRSTGAMEHomeScene.m
//  CSHDFIRSTGAME Shared
//
//  Created by apple on 2026/8/30.
//

#import "CSHDFIRSTGAMEHomeScene.h"
#import "CSHDFIRSTGAMEAudioManager.h"

@implementation CSHDFIRSTGAMEHomeScene {
}

+ (CSHDFIRSTGAMEHomeScene *)NewCSHDFIRSTGAMEHomeScene {
    CSHDFIRSTGAMEHomeScene *scene = (CSHDFIRSTGAMEHomeScene *)[SKScene nodeWithFileNamed:@"CSHDFIRSTGAMEHomeScene"];
    if (!scene) {
        NSLog(@"Failed to load CSHDFIRSTGAMEHomeScene.sks");
        abort();
    }
    scene.scaleMode = SKSceneScaleModeAspectFit;

    return scene;
}

- (void)CSHDFIRSTGAMESetUpScene {
    for (SKNode *child in self.children) {
        if ([child isKindOfClass:[SKSpriteNode class]] && child.name.length == 0 && child != self.children.firstObject) {
            SKSpriteNode *sprite = (SKSpriteNode *)child;
            if (sprite.texture && sprite.position.x > 0) sprite.name = @"FruitCollection";
        }
    }
}

- (void)didMoveToView:(SKView *)view {
    [[CSHDFIRSTGAMEAudioManager sharedManager] refreshMusic];
    [self CSHDFIRSTGAMESetUpScene];
}

-(void)update:(CFTimeInterval)currentTime {
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:point];
    NSString *name = node.name;
    NSString *file = nil;
    if ([name isEqualToString:@"Pets"]) file = @"CSHDFIRSTGAMEChoosePetScene";
    else if ([name isEqualToString:@"Setting"]) file = @"CSHDFIRSTGAMESettingScene";
    else if ([name isEqualToString:@"Play"]) file = @"CSHDFIRSTGAMEGradScene";
    else if ([name isEqualToString:@"FruitCollection"]) file = @"CSHDFIRSTGAMEFuritCollectScene";
    if (file.length == 0) return;
    [[CSHDFIRSTGAMEAudioManager sharedManager] playButtonFeedback];
    SKScene *next = [SKScene nodeWithFileNamed:file];
    next.scaleMode = SKSceneScaleModeAspectFit;
    [self.view presentScene:next transition:[SKTransition fadeWithDuration:0.2]];
}

@end
