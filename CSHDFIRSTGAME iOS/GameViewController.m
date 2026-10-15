//
//  GameViewController.m
//  CSHDFIRSTGAME iOS
//
//  Created by apple on 2026/8/30.
//

#import "GameViewController.h"
#import "CSHDFIRSTGAMEHomeScene.h"


@interface GameViewController ()

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GKScene *scene = [GKScene sceneWithFileNamed:@"CSHDFIRSTGAMEHomeScene"];
    CSHDFIRSTGAMEHomeScene *sceneNode = (CSHDFIRSTGAMEHomeScene *)scene.rootNode;
    sceneNode.scaleMode = SKSceneScaleModeAspectFit;
    SKView *skView = (SKView *)self.view;
    skView.ignoresSiblingOrder = YES;
    skView.multipleTouchEnabled = YES;
    [skView presentScene:sceneNode];
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}





@end
