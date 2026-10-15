#import "CSHDFIRSTGAMEDataManager.h"

NSString * const CSHDFIRSTGAMEFruitHLG = @"HLGPoss";
NSString * const CSHDFIRSTGAMEFruitLI = @"LIPoss";
NSString * const CSHDFIRSTGAMEFruitPineapple = @"BoLuoPoss";
NSString * const CSHDFIRSTGAMEFruitBlueberry = @"LanMeiPoss";
NSString * const CSHDFIRSTGAMEFruitWatermelon = @"XiGuaPoss";
NSString * const CSHDFIRSTGAMEFruitPeach = @"TaoZiPoss";
NSString * const CSHDFIRSTGAMEFruitOrange = @"JuZiPoss";
NSString * const CSHDFIRSTGAMEFruitGrape = @"PuTaoPoss";
NSString * const CSHDFIRSTGAMEFruitCherry = @"YingTaoPoss";
NSString * const CSHDFIRSTGAMEFruitStrawberry = @"CaoMeiPoss";
NSString * const CSHDFIRSTGAMEFruitApple = @"PingGuoPoss";
NSString * const CSHDFIRSTGAMEFruitBanana = @"XiangJiaoPOss";
NSString * const CSHDFIRSTGAMEFruitDurian = @"LiuLianPoss";

static NSString * const CSHDFIRSTGAMEScoreKey = @"CSHDFIRSTGAME.score";
static NSString * const CSHDFIRSTGAMELevelKey = @"CSHDFIRSTGAME.highestLevel";
static NSString * const CSHDFIRSTGAMEPetKey = @"CSHDFIRSTGAME.selectedPet";
static NSString * const CSHDFIRSTGAMELeftPetKey = @"CSHDFIRSTGAME.leftPet.v2";
static NSString * const CSHDFIRSTGAMERightPetKey = @"CSHDFIRSTGAME.rightPet.v2";
static NSString * const CSHDFIRSTGAMEPetSelectionInitializedKey = @"CSHDFIRSTGAME.petSelectionInitialized";
static NSString * const CSHDFIRSTGAMEUnlockedPetsKey = @"CSHDFIRSTGAME.unlockedPets";
static NSString * const CSHDFIRSTGAMEFruitKey = @"CSHDFIRSTGAME.fruits";
static NSString * const CSHDFIRSTGAMEMusicKey = @"CSHDFIRSTGAME.music";
static NSString * const CSHDFIRSTGAMESoundKey = @"CSHDFIRSTGAME.sound";
static NSString * const CSHDFIRSTGAMEVibrationKey = @"CSHDFIRSTGAME.vibration";

@interface CSHDFIRSTGAMEDataManager ()
@property (nonatomic, strong) NSUserDefaults *CSHDFIRSTGAMEDefaults;
@end

@implementation CSHDFIRSTGAMEDataManager

+ (instancetype)sharedCSHDFIRSTGAMEDataManager {
    static CSHDFIRSTGAMEDataManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ manager = [[self alloc] init]; });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _CSHDFIRSTGAMEDefaults = [NSUserDefaults standardUserDefaults];
        if ([_CSHDFIRSTGAMEDefaults objectForKey:CSHDFIRSTGAMELevelKey] == nil) {
            [_CSHDFIRSTGAMEDefaults setInteger:1 forKey:CSHDFIRSTGAMELevelKey];
        }
        if ([_CSHDFIRSTGAMEDefaults objectForKey:CSHDFIRSTGAMEUnlockedPetsKey] == nil) {
            [_CSHDFIRSTGAMEDefaults setObject:@[@"Panda", @"Mouse"] forKey:CSHDFIRSTGAMEUnlockedPetsKey];
        }
        if ([_CSHDFIRSTGAMEDefaults objectForKey:CSHDFIRSTGAMEPetSelectionInitializedKey] == nil) {
            if ([_CSHDFIRSTGAMEDefaults objectForKey:CSHDFIRSTGAMELeftPetKey] == nil &&
                [_CSHDFIRSTGAMEDefaults objectForKey:CSHDFIRSTGAMERightPetKey] == nil) {
                [_CSHDFIRSTGAMEDefaults setObject:@"Panda" forKey:CSHDFIRSTGAMELeftPetKey];
                [_CSHDFIRSTGAMEDefaults setObject:@"Mouse" forKey:CSHDFIRSTGAMERightPetKey];
                [_CSHDFIRSTGAMEDefaults setObject:@"Panda" forKey:CSHDFIRSTGAMEPetKey];
            }
            [_CSHDFIRSTGAMEDefaults setBool:YES forKey:CSHDFIRSTGAMEPetSelectionInitializedKey];
        }
        if ([_CSHDFIRSTGAMEDefaults objectForKey:CSHDFIRSTGAMEMusicKey] == nil) {
            [_CSHDFIRSTGAMEDefaults setBool:YES forKey:CSHDFIRSTGAMEMusicKey];
            [_CSHDFIRSTGAMEDefaults setBool:YES forKey:CSHDFIRSTGAMESoundKey];
            [_CSHDFIRSTGAMEDefaults setBool:YES forKey:CSHDFIRSTGAMEVibrationKey];
        }
        [_CSHDFIRSTGAMEDefaults synchronize];
    }
    return self;
}

- (NSInteger)CSHDFIRSTGAMEScore { return [self.CSHDFIRSTGAMEDefaults integerForKey:CSHDFIRSTGAMEScoreKey]; }
- (NSInteger)CSHDFIRSTGAMEHighestLevel { return MAX(1, [self.CSHDFIRSTGAMEDefaults integerForKey:CSHDFIRSTGAMELevelKey]); }
- (NSString *)CSHDFIRSTGAMESelectedPet { return self.CSHDFIRSTGAMELeftPet; }
- (void)setCSHDFIRSTGAMESelectedPet:(NSString *)pet {
    self.CSHDFIRSTGAMELeftPet = pet;
}
- (NSString *)CSHDFIRSTGAMELeftPet { return [self.CSHDFIRSTGAMEDefaults stringForKey:CSHDFIRSTGAMELeftPetKey]; }
- (NSString *)CSHDFIRSTGAMERightPet { return [self.CSHDFIRSTGAMEDefaults stringForKey:CSHDFIRSTGAMERightPetKey]; }
- (NSArray<NSString *> *)CSHDFIRSTGAMESelectedPets {
    NSMutableArray *pets = [NSMutableArray array];
    if (self.CSHDFIRSTGAMELeftPet.length > 0) [pets addObject:self.CSHDFIRSTGAMELeftPet];
    if (self.CSHDFIRSTGAMERightPet.length > 0) [pets addObject:self.CSHDFIRSTGAMERightPet];
    return pets;
}
- (void)setCSHDFIRSTGAMELeftPet:(NSString *)pet {
    if (pet.length == 0) { [self CSHDFIRSTGAMEClearLeftPet]; return; }
    if (![self CSHDFIRSTGAMEIsPetUnlocked:pet]) return;
    if ([pet isEqualToString:self.CSHDFIRSTGAMERightPet]) {
        [self.CSHDFIRSTGAMEDefaults removeObjectForKey:CSHDFIRSTGAMERightPetKey];
    }
    [self.CSHDFIRSTGAMEDefaults setObject:pet forKey:CSHDFIRSTGAMELeftPetKey];
    [self.CSHDFIRSTGAMEDefaults setObject:pet forKey:CSHDFIRSTGAMEPetKey];
    [self.CSHDFIRSTGAMEDefaults setBool:YES forKey:CSHDFIRSTGAMEPetSelectionInitializedKey];
    [self.CSHDFIRSTGAMEDefaults synchronize];
}
- (void)setCSHDFIRSTGAMERightPet:(NSString *)pet {
    if (pet.length == 0) { [self CSHDFIRSTGAMEClearRightPet]; return; }
    if (![self CSHDFIRSTGAMEIsPetUnlocked:pet]) return;
    if ([pet isEqualToString:self.CSHDFIRSTGAMELeftPet]) {
        [self.CSHDFIRSTGAMEDefaults removeObjectForKey:CSHDFIRSTGAMELeftPetKey];
        [self.CSHDFIRSTGAMEDefaults removeObjectForKey:CSHDFIRSTGAMEPetKey];
    }
    [self.CSHDFIRSTGAMEDefaults setObject:pet forKey:CSHDFIRSTGAMERightPetKey];
    [self.CSHDFIRSTGAMEDefaults setBool:YES forKey:CSHDFIRSTGAMEPetSelectionInitializedKey];
    [self.CSHDFIRSTGAMEDefaults synchronize];
}
- (void)CSHDFIRSTGAMEClearLeftPet {
    [self.CSHDFIRSTGAMEDefaults removeObjectForKey:CSHDFIRSTGAMELeftPetKey];
    [self.CSHDFIRSTGAMEDefaults removeObjectForKey:CSHDFIRSTGAMEPetKey];
    [self.CSHDFIRSTGAMEDefaults setBool:YES forKey:CSHDFIRSTGAMEPetSelectionInitializedKey];
    [self.CSHDFIRSTGAMEDefaults synchronize];
}
- (void)CSHDFIRSTGAMEClearRightPet {
    [self.CSHDFIRSTGAMEDefaults removeObjectForKey:CSHDFIRSTGAMERightPetKey];
    [self.CSHDFIRSTGAMEDefaults setBool:YES forKey:CSHDFIRSTGAMEPetSelectionInitializedKey];
    [self.CSHDFIRSTGAMEDefaults synchronize];
}

- (BOOL)CSHDFIRSTGAMEIsLevelUnlocked:(NSInteger)level { return level >= 1 && level <= 9 && level <= self.CSHDFIRSTGAMEHighestLevel; }
- (void)CSHDFIRSTGAMECompleteLevel:(NSInteger)level {
    if (level >= 1 && level < 9 && level + 1 > self.CSHDFIRSTGAMEHighestLevel) {
        [self.CSHDFIRSTGAMEDefaults setInteger:level + 1 forKey:CSHDFIRSTGAMELevelKey];
        [self.CSHDFIRSTGAMEDefaults synchronize];
    }
}

- (NSDictionary *)CSHDFIRSTGAMEAllFruitCounts {
    return [self.CSHDFIRSTGAMEDefaults dictionaryForKey:CSHDFIRSTGAMEFruitKey] ?: @{};
}
- (NSInteger)CSHDFIRSTGAMEFruitCountForKey:(NSString *)key { return MIN(100, MAX(0, [self.CSHDFIRSTGAMEAllFruitCounts[key] integerValue])); }
- (void)CSHDFIRSTGAMEAddFruitCount:(NSInteger)count forKey:(NSString *)key {
    if (key.length == 0 || count <= 0) return;
    NSMutableDictionary *fruits = [[self CSHDFIRSTGAMEAllFruitCounts] mutableCopy];
    fruits[key] = @(MIN(100, [self CSHDFIRSTGAMEFruitCountForKey:key] + count));
    [self.CSHDFIRSTGAMEDefaults setObject:fruits forKey:CSHDFIRSTGAMEFruitKey];
    [self.CSHDFIRSTGAMEDefaults synchronize];
}

- (void)CSHDFIRSTGAMEAddScore:(NSInteger)score {
    if (score == 0) return;
    [self.CSHDFIRSTGAMEDefaults setInteger:MAX(0, self.CSHDFIRSTGAMEScore + score) forKey:CSHDFIRSTGAMEScoreKey];
    [self.CSHDFIRSTGAMEDefaults synchronize];
}
- (BOOL)CSHDFIRSTGAMEIsPetUnlocked:(NSString *)pet {
    NSArray *unlocked = [self.CSHDFIRSTGAMEDefaults arrayForKey:CSHDFIRSTGAMEUnlockedPetsKey];
    return [unlocked containsObject:pet];
}
- (NSInteger)CSHDFIRSTGAMEUnlockCostForPet:(NSString *)pet {
    NSDictionary *costs = @{ @"Dog": @100, @"Rabbit": @200, @"Fox": @300, @"KeJi": @400 };
    return [costs[pet] integerValue];
}
- (BOOL)CSHDFIRSTGAMETryUnlockPet:(NSString *)pet {
    if ([self CSHDFIRSTGAMEIsPetUnlocked:pet]) return YES;
    NSInteger cost = [self CSHDFIRSTGAMEUnlockCostForPet:pet];
    if (cost <= 0 || self.CSHDFIRSTGAMEScore < cost) return NO;
    NSArray *stored = [self.CSHDFIRSTGAMEDefaults arrayForKey:CSHDFIRSTGAMEUnlockedPetsKey];
    NSMutableArray *pets = [stored mutableCopy] ?: [NSMutableArray array];
    [pets addObject:pet];
    [self.CSHDFIRSTGAMEDefaults setObject:pets forKey:CSHDFIRSTGAMEUnlockedPetsKey];
    [self.CSHDFIRSTGAMEDefaults setInteger:self.CSHDFIRSTGAMEScore - cost forKey:CSHDFIRSTGAMEScoreKey];
    [self.CSHDFIRSTGAMEDefaults synchronize];
    return YES;
}
- (void)CSHDFIRSTGAMEUnlockPet:(NSString *)pet withCost:(NSInteger)cost {
    if ([self CSHDFIRSTGAMEIsPetUnlocked:pet]) return;
    if ([self CSHDFIRSTGAMEUnlockCostForPet:pet] <= 0) return;
    if (cost <= 0 || self.CSHDFIRSTGAMEScore >= cost) {
        NSArray *stored = [self.CSHDFIRSTGAMEDefaults arrayForKey:CSHDFIRSTGAMEUnlockedPetsKey];
        NSMutableArray *pets = [stored mutableCopy] ?: [NSMutableArray array];
        [pets addObject:pet];
        [self.CSHDFIRSTGAMEDefaults setObject:pets forKey:CSHDFIRSTGAMEUnlockedPetsKey];
        if (cost > 0) [self.CSHDFIRSTGAMEDefaults setInteger:self.CSHDFIRSTGAMEScore - cost forKey:CSHDFIRSTGAMEScoreKey];
        [self.CSHDFIRSTGAMEDefaults synchronize];
    }
}

- (BOOL)CSHDFIRSTGAMEMusicEnabled { return [self.CSHDFIRSTGAMEDefaults boolForKey:CSHDFIRSTGAMEMusicKey]; }
- (void)CSHDFIRSTGAMESetMusicEnabled:(BOOL)enabled { [self.CSHDFIRSTGAMEDefaults setBool:enabled forKey:CSHDFIRSTGAMEMusicKey]; [self.CSHDFIRSTGAMEDefaults synchronize]; }
- (BOOL)CSHDFIRSTGAMESoundEnabled { return [self.CSHDFIRSTGAMEDefaults boolForKey:CSHDFIRSTGAMESoundKey]; }
- (void)CSHDFIRSTGAMESetSoundEnabled:(BOOL)enabled { [self.CSHDFIRSTGAMEDefaults setBool:enabled forKey:CSHDFIRSTGAMESoundKey]; [self.CSHDFIRSTGAMEDefaults synchronize]; }
- (BOOL)CSHDFIRSTGAMEVibrationEnabled { return [self.CSHDFIRSTGAMEDefaults boolForKey:CSHDFIRSTGAMEVibrationKey]; }
- (void)CSHDFIRSTGAMESetVibrationEnabled:(BOOL)enabled { [self.CSHDFIRSTGAMEDefaults setBool:enabled forKey:CSHDFIRSTGAMEVibrationKey]; [self.CSHDFIRSTGAMEDefaults synchronize]; }

@end
