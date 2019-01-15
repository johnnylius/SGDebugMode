//
//  SGDebugModeManager.m
//  SGDebugMode
//
//  Created by liuhuan on 2018/5/14.
//  Copyright © 2018年 Sogou. All rights reserved.
//

#import "SGDebugModeManager.h"

static NSString * const kEnableDebugMode = @"kEnableDebugMode";

SGDebugModeGroup const SGDebugModeGroupWebURL = @"网页链接地址";
SGDebugModeGroup const SGDebugModeGroupWebAPI = @"网络接口地址";
SGDebugModeGroup const SGDebugModeGroupConfig = @"功能配置项";

@interface SGDebugModeManager ()

@property (nonatomic, strong) NSMutableDictionary *normalModeDict;
@property (nonatomic, strong) NSMutableDictionary *configBlockDict;

@end

@implementation SGDebugModeManager

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.deviceInfoText =
        _deviceInfoText = ^NSString *(void) {
            return @"";
        };
        _appInfoText = ^NSString *(void) {
            return @"";
        };
        _userInfoText = ^NSString *(void) {
            return @"";
        };
    }
    return self;
}


#pragma mark - Public Method
+ (instancetype)sharedInstance {
    static SGDebugModeManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (BOOL)isEnableDebugMode {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kEnableDebugMode] boolValue];
}

- (void)enableDebugMode:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setObject:@(enable) forKey:kEnableDebugMode];
    
    [self.configBlockDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        void (^configChangedBlock)(void) = obj;
        if (configChangedBlock) {
            configChangedBlock();
        }
    }];
}

- (NSDictionary *)allConfigWithGroup:(NSString *)group {
    if (group == nil) {
        NSMutableDictionary *configDict = [NSMutableDictionary dictionary];
        [self.normalModeDict.allKeys enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [configDict addEntriesFromDictionary:self.normalModeDict[obj]];
        }];
        return configDict;
    } else {
        return self.normalModeDict[group];
    }
}

- (void)setConfigChangedBlock:(void (^)(void))block title:(NSString *)title {
    self.configBlockDict[title] = block;
}

- (void)setConfig:(NSObject *)config title:(NSString *)title debug:(BOOL)debug group:(SGDebugModeGroup)group {
    // debug为YES设置调试配置，为NO设置正式配置
    NSMutableDictionary *groupDict = self.normalModeDict[group];
    if (debug) {
        id normalConfig = groupDict[title];
        BOOL equal = NO;
        if ([config isKindOfClass:[NSString class]]) {
            NSString *debugConfig = (NSString *)config;
            equal = [debugConfig isEqualToString:normalConfig] || debugConfig.description.length == 0;
        } else if ([config isKindOfClass:[NSNumber class]]) {
            NSNumber *debugConfig = (NSNumber *)config;
            equal = [debugConfig isEqualToNumber:normalConfig];
        }
        
        if (equal) {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:title];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:config forKey:title];
        }
    } else {
        groupDict[title] = config;
    }
    
    void (^configChangedBlock)(void) = self.configBlockDict[title];
    if (configChangedBlock) {
        configChangedBlock();
    }
}

- (NSObject *)configWithTitle:(NSString *)title defaultConfig:(NSString *)defaultConfig {
    // 1、当前是调试模式，先取调试配置，不存在取正式配置
    // 2、当前不是调试模式，直接取正式配置
    NSObject *config = nil;
    if ([self isEnableDebugMode]) {
        config = [[NSUserDefaults standardUserDefaults] objectForKey:title];
    }
    
    if (config.description.length == 0) {
        NSDictionary *configDict = [self allConfigWithGroup:nil];
        config = configDict[title];
    }
    
    if (config.description.length == 0) {
        config = defaultConfig;
    }
    return config;
}

- (NSObject *)configWithTitle:(NSString *)title {
    return [self configWithTitle:title defaultConfig:nil];
}

- (BOOL)isConfigModifiedWithTitle:(NSString *)title {
    NSObject *config = [[NSUserDefaults standardUserDefaults] objectForKey:title];
    BOOL modified = (config.description.length != 0);
    return modified;
}

#pragma mark - Private Method

#pragma mark - Getter and Setter
- (NSMutableDictionary *)normalModeDict {
    if (_normalModeDict == nil) {
        _normalModeDict = [NSMutableDictionary dictionary];
        _normalModeDict[SGDebugModeGroupWebURL] = [NSMutableDictionary dictionary];
        _normalModeDict[SGDebugModeGroupWebAPI] = [NSMutableDictionary dictionary];
        _normalModeDict[SGDebugModeGroupConfig] = [NSMutableDictionary dictionary];
    }
    return _normalModeDict;
}

- (NSMutableDictionary *)configBlockDict {
    if (_configBlockDict == nil) {
        _configBlockDict = [NSMutableDictionary dictionary];
    }
    return _configBlockDict;
}

@end
