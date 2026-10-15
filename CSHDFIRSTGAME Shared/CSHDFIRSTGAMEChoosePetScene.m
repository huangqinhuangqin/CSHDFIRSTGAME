//
//  CSHDFIRSTGAMEChoosePetScene.m
//  CSHDFIRSTGAME iOS
//
//  Created by apple on 2026/9/3.
//

#import "CSHDFIRSTGAMEChoosePetScene.h"
#import "CSHDFIRSTGAMEDataManager.h"
#import "CSHDFIRSTGAMEAudioManager.h"

@implementation CSHDFIRSTGAMEChoosePetScene
{
    NSString *CSHDFIRSTGAMELeftDraft;
    NSString *CSHDFIRSTGAMERightDraft;
    NSString *CSHDFIRSTGAMEPendingUnlockPet;
    NSString *CSHDFIRSTGAMEPendingSelectionPet;
    NSInteger CSHDFIRSTGAMEEditingSlot;
    SKNode *CSHDFIRSTGAMEDialog;
}

- (void)didMoveToView:(SKView *)view {
    self.scaleMode = SKSceneScaleModeAspectFit;
    [[CSHDFIRSTGAMEAudioManager sharedManager] refreshMusic];
    [self CSHDFIRSTGAMERefreshPets];
}

- (NSString *)CSHDFIRSTGAMEImageForPet:(NSString *)pet {
    NSDictionary *images = @{
        @"Panda": @"熊猫", @"Dog": @"小狗2", @"Mouse": @"仓鼠",
        @"Rabbit": @"兔子", @"Fox": @"狐狸", @"KeJi": @"小狗"
    };
    return images[pet] ?: @"熊猫";
}

- (NSString *)CSHDFIRSTGAMEDisplayNameForPet:(NSString *)pet {
    NSDictionary *names = @{
        @"Panda": @"PANDA", @"Dog": @"DOG", @"Mouse": @"HAMSTER",
        @"Rabbit": @"RABBIT", @"Fox": @"FOX", @"KeJi": @"CORGI"
    };
    return names[pet] ?: @"PET";
}

- (void)CSHDFIRSTGAMESetPet:(NSString *)pet onNode:(SKSpriteNode *)node {
    if (![node isKindOfClass:[SKSpriteNode class]] || pet.length == 0) return;
    SKTexture *texture = [SKTexture textureWithImageNamed:[self CSHDFIRSTGAMEImageForPet:pet]];
    CGSize sourceSize = texture.size;
    CGSize slotSize = CGSizeMake(135.0, 180.0);
    if (sourceSize.width > 0.0 && sourceSize.height > 0.0) {
        CGFloat scale = MIN(slotSize.width / sourceSize.width, slotSize.height / sourceSize.height);
        node.size = CGSizeMake(sourceSize.width * scale, sourceSize.height * scale);
    }
    node.texture = texture;
}

- (void)CSHDFIRSTGAMERefreshPoints {
    CSHDFIRSTGAMEDataManager *data = [CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager];
    SKShapeNode *badge = (SKShapeNode *)[self childNodeWithName:@"CSHDFIRSTGAMEPointsBadge"];
    if (![badge isKindOfClass:[SKShapeNode class]]) {
        badge = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(215.0, 58.0) cornerRadius:18.0];
        badge.name = @"CSHDFIRSTGAMEPointsBadge";
        badge.position = CGPointMake(230.0, 575.0);
        badge.fillColor = [SKColor colorWithRed:0.24 green:0.11 blue:0.04 alpha:0.90];
        badge.strokeColor = [SKColor colorWithRed:1.0 green:0.78 blue:0.20 alpha:1.0];
        badge.lineWidth = 3.0;
        badge.zPosition = 40.0;
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Bold"];
        label.name = @"CSHDFIRSTGAMEPointsLabel";
        label.fontSize = 22.0;
        label.fontColor = [SKColor whiteColor];
        label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [badge addChild:label];
        [self addChild:badge];
    }
    SKLabelNode *label = (SKLabelNode *)[badge childNodeWithName:@"CSHDFIRSTGAMEPointsLabel"];
    label.text = [NSString stringWithFormat:@"POINTS: %ld", (long)data.CSHDFIRSTGAMEScore];
}

- (void)CSHDFIRSTGAMERefreshPriceForState:(SKSpriteNode *)state pet:(NSString *)pet unlocked:(BOOL)unlocked {
    NSString *labelName = [@"CSHDFIRSTGAMEPrice_" stringByAppendingString:state.name ?: pet];
    SKLabelNode *label = (SKLabelNode *)[self childNodeWithName:labelName];
    if (![label isKindOfClass:[SKLabelNode class]]) {
        label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Bold"];
        label.name = labelName;
        label.fontSize = 17.0;
        label.fontColor = [SKColor colorWithRed:1.0 green:0.86 blue:0.25 alpha:1.0];
        label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        label.zPosition = 40.0;
        [self addChild:label];
    }
    CGPoint statePosition = [state.parent convertPoint:state.position toNode:self];
    label.position = CGPointMake(statePosition.x, statePosition.y - 29.0);
    label.text = [NSString stringWithFormat:@"%ld POINTS", (long)[[CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager] CSHDFIRSTGAMEUnlockCostForPet:pet]];
    label.hidden = unlocked;
}

- (void)CSHDFIRSTGAMERefreshPets {
    CSHDFIRSTGAMEDataManager *data = [CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager];
    NSDictionary *map = @{
        @"PandaS": @"Panda", @"DogS": @"Dog", @"MouseS": @"Mouse",
        @"TuziS": @"Rabbit", @"FoxS": @"Fox", @"KeJiS": @"KeJi"
    };
    for (NSString *nodeName in map) {
        SKSpriteNode *state = (SKSpriteNode *)[self childNodeWithName:nodeName];
        if (![state isKindOfClass:[SKSpriteNode class]]) continue;
        NSString *pet = map[nodeName];
        BOOL unlocked = [data CSHDFIRSTGAMEIsPetUnlocked:pet];
        state.texture = [SKTexture textureWithImageNamed:(unlocked ? @"unlocked" : @"Locked")];
        state.alpha = unlocked ? 1.0 : 0.9;
        [self CSHDFIRSTGAMERefreshPriceForState:state pet:pet unlocked:unlocked];
    }
    SKSpriteNode *left = (SKSpriteNode *)[self childNodeWithName:@"ChoosePetLeft"];
    SKSpriteNode *right = (SKSpriteNode *)[self childNodeWithName:@"ChoosePetRight"];
    NSString *leftPet = CSHDFIRSTGAMELeftDraft ?: data.CSHDFIRSTGAMELeftPet;
    NSString *rightPet = CSHDFIRSTGAMERightDraft ?: data.CSHDFIRSTGAMERightPet;
    if ([left isKindOfClass:[SKSpriteNode class]]) {
        left.hidden = leftPet.length == 0;
        left.alpha = CSHDFIRSTGAMEEditingSlot == 1 ? 1.0 : 0.94;
        if (leftPet.length > 0) [self CSHDFIRSTGAMESetPet:leftPet onNode:left];
    }
    if ([right isKindOfClass:[SKSpriteNode class]]) {
        right.hidden = rightPet.length == 0;
        right.alpha = CSHDFIRSTGAMEEditingSlot == 2 ? 1.0 : 0.94;
        if (rightPet.length > 0) [self CSHDFIRSTGAMESetPet:rightPet onNode:right];
    }
    SKSpriteNode *leftButton = (SKSpriteNode *)[self childNodeWithName:@"SELECTLeft"];
    SKSpriteNode *rightButton = (SKSpriteNode *)[self childNodeWithName:@"SELECTRight"];
    if ([leftButton isKindOfClass:[SKSpriteNode class]]) leftButton.texture = [SKTexture textureWithImageNamed:(data.CSHDFIRSTGAMELeftPet.length > 0 ? @"canel" : @"select")];
    if ([rightButton isKindOfClass:[SKSpriteNode class]]) rightButton.texture = [SKTexture textureWithImageNamed:(data.CSHDFIRSTGAMERightPet.length > 0 ? @"canel" : @"select")];
    [self CSHDFIRSTGAMERefreshPoints];
}

- (SKShapeNode *)CSHDFIRSTGAMEDialogButtonWithTitle:(NSString *)title name:(NSString *)name position:(CGPoint)position color:(SKColor *)color {
    SKShapeNode *button = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(210.0, 70.0) cornerRadius:20.0];
    button.name = name;
    button.position = position;
    button.fillColor = color;
    button.strokeColor = [SKColor colorWithRed:1.0 green:0.88 blue:0.48 alpha:1.0];
    button.lineWidth = 3.0;
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Bold"];
    label.name = name;
    label.text = title;
    label.fontSize = 24.0;
    label.fontColor = [SKColor whiteColor];
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [button addChild:label];
    return button;
}

- (void)CSHDFIRSTGAMEShowDialogTitle:(NSString *)title message:(NSString *)message detail:(NSString *)detail primaryTitle:(NSString *)primaryTitle primaryName:(NSString *)primaryName secondaryTitle:(NSString *)secondaryTitle secondaryName:(NSString *)secondaryName {
    [CSHDFIRSTGAMEDialog removeFromParent];
    CSHDFIRSTGAMEDialog = [SKNode node];
    CSHDFIRSTGAMEDialog.name = @"CSHDFIRSTGAMEDialog";
    CSHDFIRSTGAMEDialog.zPosition = 1000.0;

    SKShapeNode *backdrop = [SKShapeNode shapeNodeWithRectOfSize:self.size];
    backdrop.name = @"CSHDFIRSTGAMEDialogBackdrop";
    backdrop.fillColor = [SKColor colorWithWhite:0.0 alpha:0.62];
    backdrop.strokeColor = [SKColor clearColor];
    [CSHDFIRSTGAMEDialog addChild:backdrop];

    SKShapeNode *panel = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(590.0, 390.0) cornerRadius:28.0];
    panel.fillColor = [SKColor colorWithRed:0.25 green:0.12 blue:0.04 alpha:0.98];
    panel.strokeColor = [SKColor colorWithRed:1.0 green:0.73 blue:0.18 alpha:1.0];
    panel.lineWidth = 6.0;
    [CSHDFIRSTGAMEDialog addChild:panel];

    NSArray<NSDictionary *> *lines = @[
        @{@"text": title ?: @"", @"y": @105.0, @"size": @34.0, @"color": [SKColor colorWithRed:1.0 green:0.83 blue:0.32 alpha:1.0]},
        @{@"text": message ?: @"", @"y": @35.0, @"size": @27.0, @"color": [SKColor whiteColor]},
        @{@"text": detail ?: @"", @"y": @(-15.0), @"size": @22.0, @"color": [SKColor colorWithWhite:0.88 alpha:1.0]}
    ];
    for (NSDictionary *line in lines) {
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Bold"];
        label.text = line[@"text"];
        label.position = CGPointMake(0.0, [line[@"y"] doubleValue]);
        label.fontSize = [line[@"size"] doubleValue];
        label.fontColor = line[@"color"];
        label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [panel addChild:label];
    }

    CGFloat primaryX = secondaryTitle.length > 0 ? 125.0 : 0.0;
    [panel addChild:[self CSHDFIRSTGAMEDialogButtonWithTitle:primaryTitle name:primaryName position:CGPointMake(primaryX, -115.0) color:[SKColor colorWithRed:0.25 green:0.62 blue:0.23 alpha:1.0]]];
    if (secondaryTitle.length > 0) {
        [panel addChild:[self CSHDFIRSTGAMEDialogButtonWithTitle:secondaryTitle
                                                            name:secondaryName
                                                        position:CGPointMake(-125.0, -115.0)
                                                           color:[SKColor colorWithRed:0.72 green:0.22 blue:0.15 alpha:1.0]]];
    }
    [self addChild:CSHDFIRSTGAMEDialog];
}

- (void)CSHDFIRSTGAMEShowUnlockDialogForPet:(NSString *)pet {
    CSHDFIRSTGAMEDataManager *data = [CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager];
    NSInteger cost = [data CSHDFIRSTGAMEUnlockCostForPet:pet];
    NSString *petName = [self CSHDFIRSTGAMEDisplayNameForPet:pet];
    if (cost <= 0) return;
    if (data.CSHDFIRSTGAMEScore < cost) {
        CSHDFIRSTGAMEPendingUnlockPet = nil;
        [self CSHDFIRSTGAMEShowDialogTitle:@"NOT ENOUGH POINTS"
                                  message:[NSString stringWithFormat:@"%@ COSTS %ld", petName, (long)cost]
                                   detail:[NSString stringWithFormat:@"YOU HAVE %ld POINTS", (long)data.CSHDFIRSTGAMEScore]
                             primaryTitle:@"OK"
                              primaryName:@"CSHDFIRSTGAMEDialogDismiss"
                           secondaryTitle:nil
                            secondaryName:nil];
        return;
    }
    CSHDFIRSTGAMEPendingUnlockPet = pet;
    [self CSHDFIRSTGAMEShowDialogTitle:[NSString stringWithFormat:@"UNLOCK %@?", petName]
                              message:[NSString stringWithFormat:@"COST: %ld POINTS", (long)cost]
                               detail:[NSString stringWithFormat:@"BALANCE: %ld POINTS", (long)data.CSHDFIRSTGAMEScore]
                         primaryTitle:@"UNLOCK"
                          primaryName:@"CSHDFIRSTGAMEUnlockConfirm"
                       secondaryTitle:@"CANCEL"
                        secondaryName:@"CSHDFIRSTGAMEDialogCancel"];
}

- (void)CSHDFIRSTGAMEShowSlotDialogForPet:(NSString *)pet {
    CSHDFIRSTGAMEPendingSelectionPet = pet;
    [self CSHDFIRSTGAMEShowDialogTitle:@"CHOOSE A SIDE"
                              message:[NSString stringWithFormat:@"PLACE %@ ON", [self CSHDFIRSTGAMEDisplayNameForPet:pet]]
                               detail:@"REPLACES THE CURRENT PET"
                         primaryTitle:@"RIGHT"
                          primaryName:@"CSHDFIRSTGAMESlotRight"
                       secondaryTitle:@"LEFT"
                        secondaryName:@"CSHDFIRSTGAMESlotLeft"];
}

- (void)CSHDFIRSTGAMERemoveDialog {
    [CSHDFIRSTGAMEDialog removeFromParent];
    CSHDFIRSTGAMEDialog = nil;
}

- (void)CSHDFIRSTGAMEAssignPet:(NSString *)pet toSlot:(NSInteger)slot {
    CSHDFIRSTGAMEDataManager *data = [CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager];
    if (slot == 1 && [pet isEqualToString:data.CSHDFIRSTGAMERightPet]) {
        [self CSHDFIRSTGAMEShowDialogTitle:@"ALREADY SELECTED"
                                  message:@"THIS PET IS ON THE RIGHT"
                                   detail:@"CHOOSE A DIFFERENT PET"
                             primaryTitle:@"OK"
                              primaryName:@"CSHDFIRSTGAMEDialogDismiss"
                           secondaryTitle:nil
                            secondaryName:nil];
        return;
    }
    if (slot == 2 && [pet isEqualToString:data.CSHDFIRSTGAMELeftPet]) {
        [self CSHDFIRSTGAMEShowDialogTitle:@"ALREADY SELECTED"
                                  message:@"THIS PET IS ON THE LEFT"
                                   detail:@"CHOOSE A DIFFERENT PET"
                             primaryTitle:@"OK"
                              primaryName:@"CSHDFIRSTGAMEDialogDismiss"
                           secondaryTitle:nil
                            secondaryName:nil];
        return;
    }
    if (slot == 1) data.CSHDFIRSTGAMELeftPet = pet;
    else if (slot == 2) data.CSHDFIRSTGAMERightPet = pet;
    CSHDFIRSTGAMELeftDraft = nil;
    CSHDFIRSTGAMERightDraft = nil;
    CSHDFIRSTGAMEEditingSlot = 0;
    [self CSHDFIRSTGAMERefreshPets];
}

- (void)CSHDFIRSTGAMEChoosePet:(NSString *)pet {
    CSHDFIRSTGAMEDataManager *data = [CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager];
    if ([pet isEqualToString:data.CSHDFIRSTGAMELeftPet] || [pet isEqualToString:data.CSHDFIRSTGAMERightPet]) {
        [self CSHDFIRSTGAMEShowDialogTitle:@"ALREADY SELECTED"
                                  message:[NSString stringWithFormat:@"%@ IS ALREADY IN USE", [self CSHDFIRSTGAMEDisplayNameForPet:pet]]
                                   detail:@"CHOOSE A DIFFERENT PET"
                             primaryTitle:@"OK"
                              primaryName:@"CSHDFIRSTGAMEDialogDismiss"
                           secondaryTitle:nil
                            secondaryName:nil];
        return;
    }
    if (CSHDFIRSTGAMEEditingSlot == 1 || CSHDFIRSTGAMEEditingSlot == 2) {
        [self CSHDFIRSTGAMEAssignPet:pet toSlot:CSHDFIRSTGAMEEditingSlot];
    } else if (data.CSHDFIRSTGAMELeftPet.length == 0) {
        CSHDFIRSTGAMELeftDraft = pet;
        CSHDFIRSTGAMEEditingSlot = 1;
    } else if (data.CSHDFIRSTGAMERightPet.length == 0) {
        CSHDFIRSTGAMERightDraft = pet;
        CSHDFIRSTGAMEEditingSlot = 2;
    } else {
        [self CSHDFIRSTGAMEShowSlotDialogForPet:pet];
    }
}

- (void)CSHDFIRSTGAMETapSelect:(NSString *)name {
    CSHDFIRSTGAMEDataManager *data = [CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager];
    if ([name isEqualToString:@"SELECTLeft"]) {
        if (data.CSHDFIRSTGAMELeftPet.length > 0) {
            [data CSHDFIRSTGAMEClearLeftPet];
            CSHDFIRSTGAMELeftDraft = nil;
            CSHDFIRSTGAMEEditingSlot = 1;
        } else if (CSHDFIRSTGAMELeftDraft.length > 0) {
            data.CSHDFIRSTGAMELeftPet = CSHDFIRSTGAMELeftDraft;
            CSHDFIRSTGAMELeftDraft = nil;
            CSHDFIRSTGAMEEditingSlot = 0;
        }
    } else if ([name isEqualToString:@"SELECTRight"]) {
        if (data.CSHDFIRSTGAMERightPet.length > 0) {
            [data CSHDFIRSTGAMEClearRightPet];
            CSHDFIRSTGAMERightDraft = nil;
            CSHDFIRSTGAMEEditingSlot = 2;
        } else if (CSHDFIRSTGAMERightDraft.length > 0) {
            data.CSHDFIRSTGAMERightPet = CSHDFIRSTGAMERightDraft;
            CSHDFIRSTGAMERightDraft = nil;
            CSHDFIRSTGAMEEditingSlot = 0;
        }
    }
    [self CSHDFIRSTGAMERefreshPets];
}

- (NSString *)CSHDFIRSTGAMEActionNameForNode:(SKNode *)node {
    while (node && node != self) {
        if (node.name.length > 0) return node.name;
        node = node.parent;
    }
    return nil;
}

- (void)CSHDFIRSTGAMEHandleDialogAction:(NSString *)name {
    if ([name isEqualToString:@"CSHDFIRSTGAMEUnlockConfirm"]) {
        NSString *pet = CSHDFIRSTGAMEPendingUnlockPet;
        CSHDFIRSTGAMEPendingUnlockPet = nil;
        [self CSHDFIRSTGAMERemoveDialog];
        CSHDFIRSTGAMEDataManager *data = [CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager];
        BOOL unlocked = pet.length > 0 && [data CSHDFIRSTGAMETryUnlockPet:pet];
        [self CSHDFIRSTGAMERefreshPets];
        [self CSHDFIRSTGAMEShowDialogTitle:(unlocked ? @"UNLOCKED!" : @"UNLOCK FAILED")
                                  message:(unlocked ? [NSString stringWithFormat:@"%@ IS READY", [self CSHDFIRSTGAMEDisplayNameForPet:pet]] : @"NOT ENOUGH POINTS")
                                   detail:[NSString stringWithFormat:@"BALANCE: %ld POINTS", (long)data.CSHDFIRSTGAMEScore]
                             primaryTitle:@"OK"
                              primaryName:@"CSHDFIRSTGAMEDialogDismiss"
                           secondaryTitle:nil
                            secondaryName:nil];
    } else if ([name isEqualToString:@"CSHDFIRSTGAMESlotLeft"] || [name isEqualToString:@"CSHDFIRSTGAMESlotRight"]) {
        NSString *pet = CSHDFIRSTGAMEPendingSelectionPet;
        NSInteger slot = [name isEqualToString:@"CSHDFIRSTGAMESlotLeft"] ? 1 : 2;
        CSHDFIRSTGAMEPendingSelectionPet = nil;
        [self CSHDFIRSTGAMERemoveDialog];
        if (pet.length > 0) [self CSHDFIRSTGAMEAssignPet:pet toSlot:slot];
    } else if ([name isEqualToString:@"CSHDFIRSTGAMEDialogCancel"] ||
               [name isEqualToString:@"CSHDFIRSTGAMEDialogDismiss"]) {
        CSHDFIRSTGAMEPendingUnlockPet = nil;
        CSHDFIRSTGAMEPendingSelectionPet = nil;
        [self CSHDFIRSTGAMERemoveDialog];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    NSString *name = [self CSHDFIRSTGAMEActionNameForNode:node];
    if (name.length > 0) [[CSHDFIRSTGAMEAudioManager sharedManager] playButtonFeedback];
    if (CSHDFIRSTGAMEDialog) {
        [self CSHDFIRSTGAMEHandleDialogAction:name];
        return;
    }
    if ([name isEqualToString:@"back"]) {
        SKScene *home = [SKScene nodeWithFileNamed:@"CSHDFIRSTGAMEHomeScene"];
        home.scaleMode = SKSceneScaleModeAspectFit;
        [self.view presentScene:home transition:[SKTransition fadeWithDuration:0.2]];
        return;
    }
    if ([name isEqualToString:@"SELECTLeft"] || [name isEqualToString:@"SELECTRight"]) {
        [self CSHDFIRSTGAMETapSelect:name];
        return;
    }
    if ([name isEqualToString:@"ChoosePetLeft"] || [name isEqualToString:@"ChoosePetRight"]) {
        CSHDFIRSTGAMEEditingSlot = [name isEqualToString:@"ChoosePetLeft"] ? 1 : 2;
        [self CSHDFIRSTGAMERefreshPets];
        return;
    }
    NSDictionary *pets = @{
        @"Panda": @"Panda", @"PandaS": @"Panda",
        @"Dog": @"Dog", @"DogS": @"Dog",
        @"Mouse": @"Mouse", @"MouseS": @"Mouse",
        @"Tuzi": @"Rabbit", @"TuziS": @"Rabbit",
        @"Fox": @"Fox", @"FoxS": @"Fox",
        @"KeJi": @"KeJi", @"KeJiS": @"KeJi"
    };
    NSString *pet = pets[name];
    if (pet.length == 0) return;
    CSHDFIRSTGAMEDataManager *data = [CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager];
    if (![data CSHDFIRSTGAMEIsPetUnlocked:pet]) {
        [self CSHDFIRSTGAMEShowUnlockDialogForPet:pet];
        return;
    }
    [self CSHDFIRSTGAMEChoosePet:pet];
    [self CSHDFIRSTGAMERefreshPets];
}

@end
