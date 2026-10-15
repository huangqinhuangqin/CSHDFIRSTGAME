//
//  CSHDFIRSTGAMEGameScene.m
//  CSHDFIRSTGAME iOS
//
//  Created by apple on 2026/9/3.
//

#import "CSHDFIRSTGAMEGameScene.h"
#import "CSHDFIRSTGAMEDataManager.h"
#import "CSHDFIRSTGAMEAudioManager.h"
#import "CSHDFIRSTGAMEVictoryScene.h"
#import "CSHDFIRSTGAMEFailScene.h"

static CGFloat const CSHDFIRSTGAMEMaxAngle = 10.0;
static CGFloat const CSHDFIRSTGAMEGravity = -9.8;
static CGFloat const CSHDFIRSTGAMELaunchSpeed = 1500.0;
static CGFloat const CSHDFIRSTGAMESettleMinTime = 0.18;
static CGFloat const CSHDFIRSTGAMESettleMaxTime = 0.30;
static CGFloat const CSHDFIRSTGAMEFruitScale = 0.25;
static CGFloat const CSHDFIRSTGAMEFruitBoundaryY = 158.5;
static CGFloat const CSHDFIRSTGAMEFruitGravity = -9.8;
static CGFloat const CSHDFIRSTGAMEFruitGravityScale = 30.0;
static CGFloat const CSHDFIRSTGAMEFruitSpawnMinDelay = 0.48;
static CGFloat const CSHDFIRSTGAMEFruitSpawnMaxDelay = 0.78;
static CGFloat const CSHDFIRSTGAMEFruitSpawnLevelStep = 0.025;
static CGFloat const CSHDFIRSTGAMEDurianBaseChance = 0.06;
static CGFloat const CSHDFIRSTGAMEDurianLevelStep = 0.015;
static NSInteger const CSHDFIRSTGAMEFruitScore = 50;

static NSInteger CSHDFIRSTGAMELevelTargetScore(NSInteger level) {
    static const NSInteger targets[] = { 300, 400, 500, 600, 700, 800, 900, 1000, 1100 };
    NSInteger index = MIN(8, MAX(0, level - 1));
    return targets[index];
}

typedef NS_OPTIONS(uint32_t, CSHDFIRSTGAMEPhysicsType) {
    CSHDFIRSTGAMEPhysicsBoard = 1 << 0,
    CSHDFIRSTGAMEPhysicsLeftPet = 1 << 1,
    CSHDFIRSTGAMEPhysicsRightPet = 1 << 2,
    CSHDFIRSTGAMEPhysicsBase = 1 << 3,
    CSHDFIRSTGAMEPhysicsFruit = 1 << 4,
    CSHDFIRSTGAMEPhysicsDurian = 1 << 5
};

@interface CSHDFIRSTGAMEGameScene () <SKPhysicsContactDelegate>
@end

@implementation CSHDFIRSTGAMEGameScene
{
    SKSpriteNode *CSHDFIRSTGAMEBoard;
    SKSpriteNode *CSHDFIRSTGAMEBase;
    SKSpriteNode *CSHDFIRSTGAMELeftPetNode;
    SKSpriteNode *CSHDFIRSTGAMERightPetNode;
    SKPhysicsJointPin *CSHDFIRSTGAMEPivot;
    CGFloat CSHDFIRSTGAMEMinBaseX;
    CGFloat CSHDFIRSTGAMEMaxBaseX;
    CGFloat CSHDFIRSTGAMELastTouchX;
    CGFloat CSHDFIRSTGAMEBaseY;
    CGFloat CSHDFIRSTGAMEPetX;
    BOOL CSHDFIRSTGAMEIsDragging;
    BOOL CSHDFIRSTGAMEPhysicsReady;
    BOOL CSHDFIRSTGAMELeftFlying;
    BOOL CSHDFIRSTGAMERightFlying;
    BOOL CSHDFIRSTGAMELeftSettling;
    BOOL CSHDFIRSTGAMERightSettling;
    NSInteger CSHDFIRSTGAMEExpectedPet;
    NSTimeInterval CSHDFIRSTGAMEContactReadyAt;
    NSTimeInterval CSHDFIRSTGAMECurrentTime;
    NSTimeInterval CSHDFIRSTGAMELeftSettleStart;
    NSTimeInterval CSHDFIRSTGAMERightSettleStart;
    NSTimeInterval CSHDFIRSTGAMELeftSettleTime;
    NSTimeInterval CSHDFIRSTGAMERightSettleTime;
    CGPoint CSHDFIRSTGAMELeftSettlePosition;
    CGPoint CSHDFIRSTGAMERightSettlePosition;
    NSMutableArray<SKSpriteNode *> *CSHDFIRSTGAMEFruits;
    CGFloat CSHDFIRSTGAMEBoundaryY;
    NSTimeInterval CSHDFIRSTGAMEFruitSpawnElapsed;
    NSTimeInterval CSHDFIRSTGAMEFruitSpawnDelay;
    NSTimeInterval CSHDFIRSTGAMEPreviousUpdateTime;
    NSTimeInterval CSHDFIRSTGAMECurrentDelta;
    NSInteger CSHDFIRSTGAMESessionScore;
    NSInteger CSHDFIRSTGAMELevel;
    BOOL CSHDFIRSTGAMEGameOver;
}

- (void)didMoveToView:(SKView *)view {
    self.scaleMode = SKSceneScaleModeAspectFit;
    [[CSHDFIRSTGAMEAudioManager sharedManager] refreshMusic];
    [self CSHDFIRSTGAMESetUpScene];
}

- (void)CSHDFIRSTGAMESetUpScene {
    CSHDFIRSTGAMEBoard = (SKSpriteNode *)[self childNodeWithName:@"//翘翘板"];
    if (![CSHDFIRSTGAMEBoard isKindOfClass:[SKSpriteNode class]]) return;
    CSHDFIRSTGAMEBase = (SKSpriteNode *)[self childNodeWithName:@"//底座"];
    CSHDFIRSTGAMELeftPetNode = (SKSpriteNode *)[CSHDFIRSTGAMEBoard childNodeWithName:@"PetLeft"];
    CSHDFIRSTGAMERightPetNode = (SKSpriteNode *)[CSHDFIRSTGAMEBoard childNodeWithName:@"PetRight"];
    [self CSHDFIRSTGAMENormalizeNodes];
    CSHDFIRSTGAMELevel = MAX(1, [self.userData[@"CSHDFIRSTGAMELevel"] integerValue]);
    CSHDFIRSTGAMESessionScore = 0;
    [self CSHDFIRSTGAMEApplyGameData];
    [self CSHDFIRSTGAMECreatePhysics];
    CSHDFIRSTGAMEFruits = [NSMutableArray array];
    SKNode *boundary = [self childNodeWithName:@"//分界线"];
    CSHDFIRSTGAMEBoundaryY = boundary ? [boundary.parent convertPoint:boundary.position toNode:self].y : CSHDFIRSTGAMEFruitBoundaryY;
    CSHDFIRSTGAMEFruitSpawnDelay = [self CSHDFIRSTGAMEFruitRandomDelay];
    [self CSHDFIRSTGAMEStartPhysics];
}

- (NSTimeInterval)CSHDFIRSTGAMEFruitRandomDelay {
    NSInteger levelIndex = MIN(8, MAX(0, CSHDFIRSTGAMELevel - 1));
    NSTimeInterval minimum = MAX(0.28, CSHDFIRSTGAMEFruitSpawnMinDelay - levelIndex * CSHDFIRSTGAMEFruitSpawnLevelStep);
    NSTimeInterval maximum = MAX(minimum + 0.18, CSHDFIRSTGAMEFruitSpawnMaxDelay - levelIndex * CSHDFIRSTGAMEFruitSpawnLevelStep);
    return minimum + ((CGFloat)arc4random() / UINT32_MAX) * (maximum - minimum);
}

- (CGFloat)CSHDFIRSTGAMEDurianChance {
    NSInteger levelIndex = MIN(8, MAX(0, CSHDFIRSTGAMELevel - 1));
    return CSHDFIRSTGAMEDurianBaseChance + levelIndex * CSHDFIRSTGAMEDurianLevelStep;
}

- (NSString *)CSHDFIRSTGAMEFruitKeyForAsset:(NSString *)asset {
    NSDictionary *keys = @{
        @"BL": CSHDFIRSTGAMEFruitPineapple,
        @"CM": CSHDFIRSTGAMEFruitStrawberry,
        @"JZ": CSHDFIRSTGAMEFruitOrange,
        @"LL": CSHDFIRSTGAMEFruitDurian,
        @"LM": CSHDFIRSTGAMEFruitBlueberry,
        @"PG": CSHDFIRSTGAMEFruitApple,
        @"PT": CSHDFIRSTGAMEFruitGrape,
        @"TZ": CSHDFIRSTGAMEFruitPeach,
        @"XG": CSHDFIRSTGAMEFruitWatermelon,
        @"XJ": CSHDFIRSTGAMEFruitBanana,
        @"YT": CSHDFIRSTGAMEFruitCherry
    };
    return keys[asset];
}

- (void)CSHDFIRSTGAMECreateFallingFruit {
    NSArray<NSString *> *assets = @[@"BL", @"CM", @"JZ",  @"LM", @"PG", @"PT", @"TZ", @"XG", @"XJ", @"YT"];
    CGFloat roll = (CGFloat)arc4random() / UINT32_MAX;
    NSString *asset = roll < [self CSHDFIRSTGAMEDurianChance]
        ? @"LL"
        : assets[arc4random_uniform((uint32_t)assets.count)];
    SKTexture *texture = [SKTexture textureWithImageNamed:asset];
    if (texture.size.width <= 0.0 || texture.size.height <= 0.0) return;
    SKSpriteNode *fruit = [SKSpriteNode spriteNodeWithTexture:texture];
    fruit.name = @"CSHDFIRSTGAMEFruit";
    fruit.userData = [@{ @"CSHDFIRSTGAMEFruitKey": [self CSHDFIRSTGAMEFruitKeyForAsset:asset] ?: @"" } mutableCopy];
    fruit.size = CGSizeMake(texture.size.width * CSHDFIRSTGAMEFruitScale,
                            texture.size.height * CSHDFIRSTGAMEFruitScale);
    CGFloat halfWidth = fruit.size.width * 0.5;
    CGFloat minX = CGRectGetMinX(self.frame) + halfWidth;
    CGFloat maxX = CGRectGetMaxX(self.frame) - halfWidth;
    CGFloat x = minX + ((CGFloat)arc4random() / UINT32_MAX) * MAX(0.0, maxX - minX);
    fruit.position = CGPointMake(x, CGRectGetMaxY(self.frame) - fruit.size.height * 0.5);
    fruit.alpha = 1.0;
    fruit.zPosition = 6.0;
    fruit.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(fruit.size.width * 0.82, fruit.size.height * 0.82)];
    fruit.physicsBody.dynamic = YES;
    fruit.physicsBody.affectedByGravity = NO;
    fruit.physicsBody.allowsRotation = YES;
    fruit.physicsBody.linearDamping = 0.0;
    fruit.physicsBody.angularDamping = 0.0;
    fruit.physicsBody.friction = 0.0;
    fruit.physicsBody.restitution = 0.0;
    fruit.physicsBody.collisionBitMask = 0;
    BOOL durian = [asset isEqualToString:@"LL"];
    fruit.physicsBody.categoryBitMask = durian ? CSHDFIRSTGAMEPhysicsDurian : CSHDFIRSTGAMEPhysicsFruit;
    fruit.physicsBody.contactTestBitMask = CSHDFIRSTGAMEPhysicsLeftPet | CSHDFIRSTGAMEPhysicsRightPet;
    [self addChild:fruit];
    [CSHDFIRSTGAMEFruits addObject:fruit];
}

- (void)CSHDFIRSTGAMEUpdateFallingFruits {
    for (SKSpriteNode *fruit in [CSHDFIRSTGAMEFruits copy]) {
        if (!fruit.parent) {
            [CSHDFIRSTGAMEFruits removeObject:fruit];
            continue;
        }
        fruit.physicsBody.velocity = CGVectorMake(fruit.physicsBody.velocity.dx,
                                                  fruit.physicsBody.velocity.dy + CSHDFIRSTGAMEFruitGravity * CSHDFIRSTGAMEFruitGravityScale * CSHDFIRSTGAMECurrentDelta);
        if (CGRectGetMinY(fruit.frame) <= CSHDFIRSTGAMEBoundaryY) {
            NSString *key = fruit.userData[@"CSHDFIRSTGAMEFruitKey"];
            if (key.length > 0) {
                [[CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager] CSHDFIRSTGAMEAddFruitCount:1 forKey:key];
            }
            [fruit removeFromParent];
            [CSHDFIRSTGAMEFruits removeObject:fruit];
        }
    }
}

- (void)CSHDFIRSTGAMERefreshScore {
    SKLabelNode *scoreNode = (SKLabelNode *)[self childNodeWithName:@"Score"];
    if ([scoreNode isKindOfClass:[SKLabelNode class]]) {
        scoreNode.text = [NSString stringWithFormat:@"%ld", (long)CSHDFIRSTGAMESessionScore];
    }
}

- (void)CSHDFIRSTGAMEEndGame:(BOOL)success {
    if (CSHDFIRSTGAMEGameOver || !self.view) return;
    CSHDFIRSTGAMEGameOver = YES;
    if (success) {
        [[CSHDFIRSTGAMEAudioManager sharedManager] playSuccessFeedback];
    } else {
        [[CSHDFIRSTGAMEAudioManager sharedManager] playFailureFeedback];
    }
    [self removeAllActions];
    for (SKSpriteNode *fruit in [CSHDFIRSTGAMEFruits copy]) [fruit removeFromParent];
    [CSHDFIRSTGAMEFruits removeAllObjects];
    if (success) {
        [[CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager] CSHDFIRSTGAMECompleteLevel:CSHDFIRSTGAMELevel];
        CSHDFIRSTGAMEVictoryScene *scene = (CSHDFIRSTGAMEVictoryScene *)[SKScene nodeWithFileNamed:@"CSHDFIRSTGAMEVictoryScene"];
        scene.scaleMode = SKSceneScaleModeAspectFit;
        scene.CSHDFIRSTGAMELevel = CSHDFIRSTGAMELevel;
        scene.CSHDFIRSTGAMEScore = CSHDFIRSTGAMESessionScore;
        [self.view presentScene:scene transition:[SKTransition fadeWithDuration:0.25]];
    } else {
        CSHDFIRSTGAMEFailScene *scene = (CSHDFIRSTGAMEFailScene *)[SKScene nodeWithFileNamed:@"CSHDFIRSTGAMEFailScene"];
        scene.scaleMode = SKSceneScaleModeAspectFit;
        scene.CSHDFIRSTGAMELevel = CSHDFIRSTGAMELevel;
        [self.view presentScene:scene transition:[SKTransition fadeWithDuration:0.25]];
    }
}

- (void)CSHDFIRSTGAMECollectFruit:(SKSpriteNode *)fruit {
    if (!fruit || !fruit.parent || CSHDFIRSTGAMEGameOver) return;
    NSString *key = fruit.userData[@"CSHDFIRSTGAMEFruitKey"];
    if (key.length > 0) {
        [[CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager] CSHDFIRSTGAMEAddFruitCount:1 forKey:key];
    }
    [fruit removeFromParent];
    [CSHDFIRSTGAMEFruits removeObject:fruit];
    CSHDFIRSTGAMESessionScore += CSHDFIRSTGAMEFruitScore;
    [[CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager] CSHDFIRSTGAMEAddScore:CSHDFIRSTGAMEFruitScore];
    [[CSHDFIRSTGAMEAudioManager sharedManager] playButtonFeedback];
    [self CSHDFIRSTGAMERefreshScore];
    if (CSHDFIRSTGAMESessionScore >= CSHDFIRSTGAMELevelTargetScore(CSHDFIRSTGAMELevel)) {
        [self CSHDFIRSTGAMEEndGame:YES];
    }
}

- (void)CSHDFIRSTGAMENormalizeNode:(SKSpriteNode *)node {
    if (!node) return;
    CGPoint worldPosition = [node.parent convertPoint:node.position toNode:self];
    CGSize localSize = node.size;
    CGFloat scaleX = node.xScale;
    CGFloat scaleY = node.yScale;
    CGFloat rotation = node.zRotation;
    SKNode *parent = node.parent;
    while (parent && parent != self) {
        scaleX *= parent.xScale;
        scaleY *= parent.yScale;
        rotation += parent.zRotation;
        parent = parent.parent;
    }
    [node removeFromParent];
    node.position = worldPosition;
    node.size = CGSizeMake(localSize.width * fabs(scaleX), localSize.height * fabs(scaleY));
    node.xScale = scaleX < 0.0 ? -1.0 : 1.0;
    node.yScale = scaleY < 0.0 ? -1.0 : 1.0;
    node.zRotation = rotation;
    [self addChild:node];
}

- (void)CSHDFIRSTGAMENormalizeNodes {
    SKNode *gameRoot = [self childNodeWithName:@"GameRoot"];
    [self CSHDFIRSTGAMENormalizeNode:CSHDFIRSTGAMELeftPetNode];
    [self CSHDFIRSTGAMENormalizeNode:CSHDFIRSTGAMERightPetNode];
    [self CSHDFIRSTGAMENormalizeNode:CSHDFIRSTGAMEBase];
    [self CSHDFIRSTGAMENormalizeNode:CSHDFIRSTGAMEBoard];
    [gameRoot removeFromParent];
    CSHDFIRSTGAMEBase.zPosition = 3.0;
    CSHDFIRSTGAMEBoard.zPosition = 4.0;
    CSHDFIRSTGAMELeftPetNode.zPosition = 5.0;
    CSHDFIRSTGAMERightPetNode.zPosition = 5.0;
}

- (NSString *)CSHDFIRSTGAMEImageForPet:(NSString *)pet {
    NSDictionary *images = @{
        @"Panda": @"熊猫", @"Dog": @"小狗2", @"Mouse": @"仓鼠",
        @"Rabbit": @"兔子", @"Fox": @"狐狸", @"KeJi": @"小狗"
    };
    return images[pet];
}

- (void)CSHDFIRSTGAMEApplyPet:(NSString *)pet toNode:(SKSpriteNode *)node {
    NSString *imageName = [self CSHDFIRSTGAMEImageForPet:pet];
    if (imageName.length == 0 || !node) return;
    SKTexture *texture = [SKTexture textureWithImageNamed:imageName];
    CGSize sourceSize = texture.size;
    CGSize slotSize = node.size;
    if (sourceSize.width > 0.0 && sourceSize.height > 0.0) {
        CGFloat scale = MIN(slotSize.width / sourceSize.width, slotSize.height / sourceSize.height);
        node.size = CGSizeMake(sourceSize.width * scale, sourceSize.height * scale);
    }
    node.texture = texture;
}

- (void)CSHDFIRSTGAMEApplyGameData {
    CSHDFIRSTGAMEDataManager *data = [CSHDFIRSTGAMEDataManager sharedCSHDFIRSTGAMEDataManager];
    NSString *leftPet = data.CSHDFIRSTGAMELeftPet;
    NSString *rightPet = data.CSHDFIRSTGAMERightPet;
    if (leftPet.length == 0) leftPet = [rightPet isEqualToString:@"Panda"] ? @"Mouse" : @"Panda";
    if (rightPet.length == 0) rightPet = [leftPet isEqualToString:@"Mouse"] ? @"Panda" : @"Mouse";
    [self CSHDFIRSTGAMEApplyPet:leftPet toNode:CSHDFIRSTGAMELeftPetNode];
    [self CSHDFIRSTGAMEApplyPet:rightPet toNode:CSHDFIRSTGAMERightPetNode];
    NSInteger level = [self.userData[@"CSHDFIRSTGAMELevel"] integerValue];
    SKLabelNode *levelNode = (SKLabelNode *)[self childNodeWithName:@"LevelInfo"];
    if ([levelNode isKindOfClass:[SKLabelNode class]]) levelNode.text = [NSString stringWithFormat:@"LEVEL %ld", (long)MAX(1, level)];
    SKLabelNode *scoreNode = (SKLabelNode *)[self childNodeWithName:@"Score"];
    if ([scoreNode isKindOfClass:[SKLabelNode class]]) scoreNode.text = @"0";
}

- (CGPoint)CSHDFIRSTGAMEPetTarget:(SKSpriteNode *)pet atX:(CGFloat)x angle:(CGFloat)angle {
    CGFloat height = CSHDFIRSTGAMEBoard.size.height * 0.5 + pet.size.height * 0.5 - 3.0;
    CGFloat cosine = cos(angle);
    CGFloat sine = sin(angle);
    return CGPointMake(CSHDFIRSTGAMEBoard.position.x + x * cosine - height * sine,
                       CSHDFIRSTGAMEBoard.position.y + x * sine + height * cosine);
}

- (void)CSHDFIRSTGAMEPlacePet:(SKSpriteNode *)pet atX:(CGFloat)x angle:(CGFloat)angle {
    pet.position = [self CSHDFIRSTGAMEPetTarget:pet atX:x angle:angle];
    pet.zRotation = 0.0;
}

- (void)CSHDFIRSTGAMESetPet:(SKSpriteNode *)pet flying:(BOOL)flying {
    if (!pet.physicsBody) return;
    if (pet == CSHDFIRSTGAMELeftPetNode) {
        CSHDFIRSTGAMELeftFlying = flying;
        if (flying) CSHDFIRSTGAMELeftSettling = NO;
    } else if (pet == CSHDFIRSTGAMERightPetNode) {
        CSHDFIRSTGAMERightFlying = flying;
        if (flying) CSHDFIRSTGAMERightSettling = NO;
    }
    pet.physicsBody.affectedByGravity = flying;
    if (!flying) {
        pet.physicsBody.velocity = CGVectorMake(0.0, 0.0);
        pet.physicsBody.angularVelocity = 0.0;
        pet.physicsBody.collisionBitMask = 0;
        pet.physicsBody.contactTestBitMask = 0;
    }
}

- (void)CSHDFIRSTGAMEBeginSettle:(SKSpriteNode *)pet atX:(CGFloat)x {
    CGPoint startPosition = pet.position;
    CGPoint targetPosition = [self CSHDFIRSTGAMEPetTarget:pet atX:x angle:CSHDFIRSTGAMEBoard.zRotation];
    CGFloat distance = hypot(targetPosition.x - startPosition.x, targetPosition.y - startPosition.y);
    NSTimeInterval duration = MIN(CSHDFIRSTGAMESettleMaxTime,
                                  CSHDFIRSTGAMESettleMinTime + distance / 1000.0);
    [self CSHDFIRSTGAMESetPet:pet flying:NO];
    if (pet == CSHDFIRSTGAMELeftPetNode) {
        CSHDFIRSTGAMELeftSettling = YES;
        CSHDFIRSTGAMELeftSettleStart = CSHDFIRSTGAMECurrentTime;
        CSHDFIRSTGAMELeftSettleTime = duration;
        CSHDFIRSTGAMELeftSettlePosition = startPosition;
    } else {
        CSHDFIRSTGAMERightSettling = YES;
        CSHDFIRSTGAMERightSettleStart = CSHDFIRSTGAMECurrentTime;
        CSHDFIRSTGAMERightSettleTime = duration;
        CSHDFIRSTGAMERightSettlePosition = startPosition;
    }
}

- (void)CSHDFIRSTGAMESettlePet:(SKSpriteNode *)pet
                           atX:(CGFloat)x
                         start:(CGPoint)start
                     startTime:(NSTimeInterval)startTime
                      duration:(NSTimeInterval)duration
                      settling:(BOOL *)settling {
    CGPoint target = [self CSHDFIRSTGAMEPetTarget:pet atX:x angle:CSHDFIRSTGAMEBoard.zRotation];
    CGFloat progress = duration > 0.0 ? (CSHDFIRSTGAMECurrentTime - startTime) / duration : 1.0;
    progress = MIN(1.0, MAX(0.0, progress));
    CGFloat eased = 1.0 - pow(1.0 - progress, 3.0);
    pet.position = CGPointMake(start.x + (target.x - start.x) * eased,
                               start.y + (target.y - start.y) * eased);
    pet.zRotation = 0.0;
    pet.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    if (progress >= 1.0) *settling = NO;
}

- (void)CSHDFIRSTGAMESyncGroundedPets {
    CGFloat angle = CSHDFIRSTGAMEBoard.zRotation;
    if (!CSHDFIRSTGAMELeftFlying) {
        if (CSHDFIRSTGAMELeftSettling) {
            [self CSHDFIRSTGAMESettlePet:CSHDFIRSTGAMELeftPetNode
                                     atX:-CSHDFIRSTGAMEPetX
                                   start:CSHDFIRSTGAMELeftSettlePosition
                               startTime:CSHDFIRSTGAMELeftSettleStart
                                duration:CSHDFIRSTGAMELeftSettleTime
                                settling:&CSHDFIRSTGAMELeftSettling];
        } else {
            [self CSHDFIRSTGAMEPlacePet:CSHDFIRSTGAMELeftPetNode atX:-CSHDFIRSTGAMEPetX angle:angle];
            CSHDFIRSTGAMELeftPetNode.physicsBody.velocity = CGVectorMake(0.0, 0.0);
        }
    }
    if (!CSHDFIRSTGAMERightFlying) {
        if (CSHDFIRSTGAMERightSettling) {
            [self CSHDFIRSTGAMESettlePet:CSHDFIRSTGAMERightPetNode
                                     atX:CSHDFIRSTGAMEPetX
                                   start:CSHDFIRSTGAMERightSettlePosition
                               startTime:CSHDFIRSTGAMERightSettleStart
                                duration:CSHDFIRSTGAMERightSettleTime
                                settling:&CSHDFIRSTGAMERightSettling];
        } else {
            [self CSHDFIRSTGAMEPlacePet:CSHDFIRSTGAMERightPetNode atX:CSHDFIRSTGAMEPetX angle:angle];
            CSHDFIRSTGAMERightPetNode.physicsBody.velocity = CGVectorMake(0.0, 0.0);
        }
    }
}

- (SKPhysicsBody *)CSHDFIRSTGAMEPetBodyForNode:(SKSpriteNode *)node category:(uint32_t)category {
    CGSize size = CGSizeMake(node.size.width * 0.72, node.size.height * 0.88);
    SKPhysicsBody *body = [SKPhysicsBody bodyWithRectangleOfSize:size];
    body.dynamic = YES;
    body.affectedByGravity = YES;
    body.allowsRotation = NO;
    body.mass = 1.0;
    body.friction = 0.85;
    body.restitution = 0.05;
    body.linearDamping = 0.05;
    body.usesPreciseCollisionDetection = YES;
    body.categoryBitMask = category;
    body.collisionBitMask = CSHDFIRSTGAMEPhysicsBoard;
    body.contactTestBitMask = CSHDFIRSTGAMEPhysicsBoard | CSHDFIRSTGAMEPhysicsFruit | CSHDFIRSTGAMEPhysicsDurian;
    return body;
}

- (void)CSHDFIRSTGAMECreatePhysics {
    self.physicsWorld.gravity = CGVectorMake(0.0, CSHDFIRSTGAMEGravity);
    self.physicsWorld.contactDelegate = self;
    self.physicsBody = nil;
    CGFloat startAngle = 0.0;
    CSHDFIRSTGAMEBoard.zRotation = startAngle;
    CSHDFIRSTGAMEPetX = CSHDFIRSTGAMEBoard.size.width * 0.43;
    [self CSHDFIRSTGAMEPlacePet:CSHDFIRSTGAMELeftPetNode atX:-CSHDFIRSTGAMEPetX angle:startAngle];
    [self CSHDFIRSTGAMEPlacePet:CSHDFIRSTGAMERightPetNode atX:CSHDFIRSTGAMEPetX angle:startAngle];

    CSHDFIRSTGAMEBase.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CSHDFIRSTGAMEBase.size];
    CSHDFIRSTGAMEBase.physicsBody.dynamic = YES;
    CSHDFIRSTGAMEBase.physicsBody.affectedByGravity = NO;
    CSHDFIRSTGAMEBase.physicsBody.allowsRotation = NO;
    CSHDFIRSTGAMEBase.physicsBody.mass = 100000.0;
    CSHDFIRSTGAMEBase.physicsBody.linearDamping = 1.0;
    CSHDFIRSTGAMEBase.physicsBody.categoryBitMask = CSHDFIRSTGAMEPhysicsBase;
    CSHDFIRSTGAMEBase.physicsBody.collisionBitMask = 0;

    CSHDFIRSTGAMEBoard.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CSHDFIRSTGAMEBoard.size];
    CSHDFIRSTGAMEBoard.physicsBody.dynamic = YES;
    CSHDFIRSTGAMEBoard.physicsBody.affectedByGravity = YES;
    CSHDFIRSTGAMEBoard.physicsBody.mass = 3.0;
    CSHDFIRSTGAMEBoard.physicsBody.friction = 0.9;
    CSHDFIRSTGAMEBoard.physicsBody.restitution = 0.0;
    CSHDFIRSTGAMEBoard.physicsBody.angularDamping = 0.7;
    CSHDFIRSTGAMEBoard.physicsBody.linearDamping = 1.0;
    CSHDFIRSTGAMEBoard.physicsBody.categoryBitMask = CSHDFIRSTGAMEPhysicsBoard;
    CSHDFIRSTGAMEBoard.physicsBody.collisionBitMask = CSHDFIRSTGAMEPhysicsLeftPet | CSHDFIRSTGAMEPhysicsRightPet;
    CSHDFIRSTGAMEBoard.physicsBody.contactTestBitMask = CSHDFIRSTGAMEPhysicsLeftPet | CSHDFIRSTGAMEPhysicsRightPet;

    CSHDFIRSTGAMELeftPetNode.physicsBody = [self CSHDFIRSTGAMEPetBodyForNode:CSHDFIRSTGAMELeftPetNode category:CSHDFIRSTGAMEPhysicsLeftPet];
    CSHDFIRSTGAMERightPetNode.physicsBody = [self CSHDFIRSTGAMEPetBodyForNode:CSHDFIRSTGAMERightPetNode category:CSHDFIRSTGAMEPhysicsRightPet];
    [self CSHDFIRSTGAMESetPet:CSHDFIRSTGAMELeftPetNode flying:NO];
    [self CSHDFIRSTGAMESetPet:CSHDFIRSTGAMERightPetNode flying:NO];
    CSHDFIRSTGAMEPivot = [SKPhysicsJointPin jointWithBodyA:CSHDFIRSTGAMEBoard.physicsBody
                                                    bodyB:CSHDFIRSTGAMEBase.physicsBody
                                                   anchor:CSHDFIRSTGAMEBoard.position];
    CGFloat limit = CSHDFIRSTGAMEMaxAngle * M_PI / 180.0;
    CSHDFIRSTGAMEPivot.shouldEnableLimits = YES;
    CSHDFIRSTGAMEPivot.lowerAngleLimit = -limit;
    CSHDFIRSTGAMEPivot.upperAngleLimit = limit;
    [self.physicsWorld addJoint:CSHDFIRSTGAMEPivot];
    CGFloat halfWidth = CSHDFIRSTGAMEBoard.size.width * 0.5 * cos(limit) + CSHDFIRSTGAMEBoard.size.height * 0.5 * sin(limit);
    CSHDFIRSTGAMEMinBaseX = CGRectGetMinX(self.frame) + halfWidth;
    CSHDFIRSTGAMEMaxBaseX = CGRectGetMaxX(self.frame) - halfWidth;
    CSHDFIRSTGAMEBaseY = CSHDFIRSTGAMEBase.position.y;
}

- (void)CSHDFIRSTGAMELaunchPet:(SKSpriteNode *)pet boardSpeed:(CGFloat)boardSpeed {
    if (!pet.physicsBody) return;
    [self CSHDFIRSTGAMESetPet:pet flying:YES];
    pet.physicsBody.collisionBitMask = 0;
    pet.physicsBody.contactTestBitMask = 0;
    pet.position = CGPointMake(pet.position.x, pet.position.y + 2.0);
    pet.physicsBody.velocity = CGVectorMake(0.0, CSHDFIRSTGAMELaunchSpeed);
    CSHDFIRSTGAMEContactReadyAt = [NSDate timeIntervalSinceReferenceDate] + 0.25;
    CSHDFIRSTGAMEBoard.physicsBody.angularVelocity = boardSpeed;
    [pet runAction:[SKAction sequence:@[
        [SKAction waitForDuration:0.08],
        [SKAction runBlock:^{
            BOOL flying = (pet == self->CSHDFIRSTGAMELeftPetNode) ? self->CSHDFIRSTGAMELeftFlying : self->CSHDFIRSTGAMERightFlying;
            if (flying) {
                pet.physicsBody.collisionBitMask = CSHDFIRSTGAMEPhysicsBoard;
                pet.physicsBody.contactTestBitMask = CSHDFIRSTGAMEPhysicsBoard;
            }
        }]
    ]] withKey:@"CSHDFIRSTGAMELaunchClearance"];
}

- (void)CSHDFIRSTGAMEStartPhysics {
    CSHDFIRSTGAMEExpectedPet = 2;
    __weak typeof(self) weakSelf = self;
    [self runAction:[SKAction sequence:@[
        [SKAction waitForDuration:0.35],
        [SKAction runBlock:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            [self CSHDFIRSTGAMELaunchPet:self->CSHDFIRSTGAMERightPetNode boardSpeed:1.1];
        }],
        [SKAction waitForDuration:0.12],
        [SKAction runBlock:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            self->CSHDFIRSTGAMEPhysicsReady = YES;
        }]
    ]] withKey:@"CSHDFIRSTGAMEInitialLaunch"];
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    if (!CSHDFIRSTGAMEPhysicsReady || CSHDFIRSTGAMEGameOver) return;
    if ([NSDate timeIntervalSinceReferenceDate] < CSHDFIRSTGAMEContactReadyAt) return;
    uint32_t category = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask;
    BOOL fruitHit = (category & CSHDFIRSTGAMEPhysicsFruit) || (category & CSHDFIRSTGAMEPhysicsDurian);
    BOOL petHit = (category & CSHDFIRSTGAMEPhysicsLeftPet) || (category & CSHDFIRSTGAMEPhysicsRightPet);
    if (fruitHit && petHit) {
        SKPhysicsBody *fruitBody = (contact.bodyA.categoryBitMask & (CSHDFIRSTGAMEPhysicsFruit | CSHDFIRSTGAMEPhysicsDurian)) ? contact.bodyA : contact.bodyB;
        SKSpriteNode *fruit = (SKSpriteNode *)fruitBody.node;
        if (category & CSHDFIRSTGAMEPhysicsDurian) {
            [self CSHDFIRSTGAMEEndGame:NO];
        } else {
            [self CSHDFIRSTGAMECollectFruit:fruit];
        }
        return;
    }
    BOOL rightHit = (category & CSHDFIRSTGAMEPhysicsBoard) && (category & CSHDFIRSTGAMEPhysicsRightPet);
    BOOL leftHit = (category & CSHDFIRSTGAMEPhysicsBoard) && (category & CSHDFIRSTGAMEPhysicsLeftPet);
    if (rightHit && CSHDFIRSTGAMEExpectedPet == 2 && CSHDFIRSTGAMERightFlying) {
        [self CSHDFIRSTGAMEBeginSettle:CSHDFIRSTGAMERightPetNode atX:CSHDFIRSTGAMEPetX];
        CSHDFIRSTGAMEExpectedPet = 1;
        [self CSHDFIRSTGAMELaunchPet:CSHDFIRSTGAMELeftPetNode boardSpeed:-1.5];
    } else if (leftHit && CSHDFIRSTGAMEExpectedPet == 1 && CSHDFIRSTGAMELeftFlying) {
        [self CSHDFIRSTGAMEBeginSettle:CSHDFIRSTGAMELeftPetNode atX:-CSHDFIRSTGAMEPetX];
        CSHDFIRSTGAMEExpectedPet = 2;
        [self CSHDFIRSTGAMELaunchPet:CSHDFIRSTGAMERightPetNode boardSpeed:1.5];
    }
}

- (CGFloat)CSHDFIRSTGAMEClampedBaseX:(CGFloat)x {
    return MIN(CSHDFIRSTGAMEMaxBaseX, MAX(CSHDFIRSTGAMEMinBaseX, x));
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CSHDFIRSTGAMELastTouchX = [[touches anyObject] locationInNode:self].x;
    CSHDFIRSTGAMEIsDragging = YES;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!CSHDFIRSTGAMEIsDragging || !CSHDFIRSTGAMEBase) return;
    CGFloat x = [[touches anyObject] locationInNode:self].x;
    CGFloat targetX = CSHDFIRSTGAMEBase.position.x + x - CSHDFIRSTGAMELastTouchX;
    CGFloat clampedX = [self CSHDFIRSTGAMEClampedBaseX:targetX];
    CGFloat offset = clampedX - CSHDFIRSTGAMEBase.position.x;
    CSHDFIRSTGAMEBase.position = CGPointMake(clampedX, CSHDFIRSTGAMEBase.position.y);
    CSHDFIRSTGAMEBoard.position = CGPointMake(CSHDFIRSTGAMEBoard.position.x + offset, CSHDFIRSTGAMEBoard.position.y);
    CSHDFIRSTGAMEBoard.physicsBody.velocity = CGVectorMake(0.0, CSHDFIRSTGAMEBoard.physicsBody.velocity.dy);
    [self CSHDFIRSTGAMESyncGroundedPets];
    CSHDFIRSTGAMELastTouchX = x;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CSHDFIRSTGAMEIsDragging = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CSHDFIRSTGAMEIsDragging = NO;
}

- (void)update:(NSTimeInterval)currentTime {
    NSTimeInterval delta = CSHDFIRSTGAMEPreviousUpdateTime > 0.0 ? currentTime - CSHDFIRSTGAMEPreviousUpdateTime : 0.0;
    CSHDFIRSTGAMEPreviousUpdateTime = currentTime;
    CSHDFIRSTGAMECurrentTime = currentTime;
    delta = MIN(0.1, MAX(0.0, delta));
    CSHDFIRSTGAMECurrentDelta = delta;
    CSHDFIRSTGAMEFruitSpawnElapsed += delta;
    while (CSHDFIRSTGAMEFruitSpawnElapsed >= CSHDFIRSTGAMEFruitSpawnDelay) {
        CSHDFIRSTGAMEFruitSpawnElapsed -= CSHDFIRSTGAMEFruitSpawnDelay;
        [self CSHDFIRSTGAMECreateFallingFruit];
        CSHDFIRSTGAMEFruitSpawnDelay = [self CSHDFIRSTGAMEFruitRandomDelay];
    }
    [self CSHDFIRSTGAMEUpdateFallingFruits];
}

- (void)didSimulatePhysics {
    CSHDFIRSTGAMEBase.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    CSHDFIRSTGAMEBase.position = CGPointMake(CSHDFIRSTGAMEBase.position.x, CSHDFIRSTGAMEBaseY);
    [self CSHDFIRSTGAMESyncGroundedPets];
    if (CSHDFIRSTGAMEGameOver) return;
    CGFloat bottom = CGRectGetMinY(self.frame);
    if ((CSHDFIRSTGAMELeftFlying && CGRectGetMaxY(CSHDFIRSTGAMELeftPetNode.frame) < bottom) ||
        (CSHDFIRSTGAMERightFlying && CGRectGetMaxY(CSHDFIRSTGAMERightPetNode.frame) < bottom)) {
        [self CSHDFIRSTGAMEEndGame:NO];
    }
}

@end
