#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CSHDFIRSTGAMEPet) {
    CSHDFIRSTGAMEPetPanda,
    CSHDFIRSTGAMEPetDog,
    CSHDFIRSTGAMEPetMouse,
    CSHDFIRSTGAMEPetRabbit,
    CSHDFIRSTGAMEPetFox,
    CSHDFIRSTGAMEPetKeJi
};

FOUNDATION_EXPORT NSString * const CSHDFIRSTGAMEFruitHLG;
FOUNDATION_EXPORT NSString * const CSHDFIRSTGAMEFruitLI;
FOUNDATION_EXPORT NSString * const CSHDFIRSTGAMEFruitPineapple;
FOUNDATION_EXPORT NSString * const CSHDFIRSTGAMEFruitBlueberry;
FOUNDATION_EXPORT NSString * const CSHDFIRSTGAMEFruitWatermelon;
FOUNDATION_EXPORT NSString * const CSHDFIRSTGAMEFruitPeach;
FOUNDATION_EXPORT NSString * const CSHDFIRSTGAMEFruitOrange;
FOUNDATION_EXPORT NSString * const CSHDFIRSTGAMEFruitGrape;
FOUNDATION_EXPORT NSString * const CSHDFIRSTGAMEFruitCherry;
FOUNDATION_EXPORT NSString * const CSHDFIRSTGAMEFruitStrawberry;
FOUNDATION_EXPORT NSString * const CSHDFIRSTGAMEFruitApple;
FOUNDATION_EXPORT NSString * const CSHDFIRSTGAMEFruitBanana;
FOUNDATION_EXPORT NSString * const CSHDFIRSTGAMEFruitDurian;

@interface CSHDFIRSTGAMEDataManager : NSObject

+ (instancetype)sharedCSHDFIRSTGAMEDataManager;

@property (nonatomic, readonly) NSInteger CSHDFIRSTGAMEScore;
@property (nonatomic, readonly) NSInteger CSHDFIRSTGAMEHighestLevel;
@property (nonatomic, copy, nullable) NSString *CSHDFIRSTGAMESelectedPet;
@property (nonatomic, copy, nullable) NSString *CSHDFIRSTGAMELeftPet;
@property (nonatomic, copy, nullable) NSString *CSHDFIRSTGAMERightPet;
@property (nonatomic, readonly) NSArray<NSString *> *CSHDFIRSTGAMESelectedPets;

- (void)CSHDFIRSTGAMEClearLeftPet;
- (void)CSHDFIRSTGAMEClearRightPet;

- (BOOL)CSHDFIRSTGAMEIsLevelUnlocked:(NSInteger)level;
- (void)CSHDFIRSTGAMECompleteLevel:(NSInteger)level;

- (NSInteger)CSHDFIRSTGAMEFruitCountForKey:(NSString *)key;
- (NSDictionary<NSString *, NSNumber *> *)CSHDFIRSTGAMEAllFruitCounts;
- (void)CSHDFIRSTGAMEAddFruitCount:(NSInteger)count forKey:(NSString *)key;

- (void)CSHDFIRSTGAMEAddScore:(NSInteger)score;
- (BOOL)CSHDFIRSTGAMEIsPetUnlocked:(NSString *)pet;
- (BOOL)CSHDFIRSTGAMETryUnlockPet:(NSString *)pet;
- (void)CSHDFIRSTGAMEUnlockPet:(NSString *)pet withCost:(NSInteger)cost;
- (NSInteger)CSHDFIRSTGAMEUnlockCostForPet:(NSString *)pet;

- (BOOL)CSHDFIRSTGAMEMusicEnabled;
- (void)CSHDFIRSTGAMESetMusicEnabled:(BOOL)enabled;
- (BOOL)CSHDFIRSTGAMESoundEnabled;
- (void)CSHDFIRSTGAMESetSoundEnabled:(BOOL)enabled;
- (BOOL)CSHDFIRSTGAMEVibrationEnabled;
- (void)CSHDFIRSTGAMESetVibrationEnabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
