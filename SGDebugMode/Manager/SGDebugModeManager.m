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

- (NSString *)deviceInfoText {
    NSString *text = @"";
    /*
    RNAppContext *context = [RNAppContext sharedInstance];
    NSString *text = [NSString stringWithFormat:@"deviceName: \n%@\n\n"\
                      @"deviceModel: \n%@\n\n"\
                      @"systemName: \n%@\n\n"\
                      @"systemVersion: \n%@\n\n"\
                      @"machineModel: \n%@\n\n"\
                      @"resolution: \n%@",
                      context.deviceName,
                      context.deviceModel,
                      context.systemName,
                      context.systemVersion,
                      context.machineModel,
                      context.sr];
     */
    return text;
}

- (NSString *)appInfoText {
    NSString *text = @"";
    /*
    RNAppContext *context = [RNAppContext sharedInstance];
    NSString *text = [NSString stringWithFormat:@"pkg: \n%@\n\n"\
                      @"v: \n%@\n\n"\
                      @"h: \n%@\n\n"\
                      @"omid: \n%@\n\n"\
                      @"idfa: \n%@\n\n"\
                      @"pushToken: \n%@\n\n"\
                      @"appleID: \n%@",
                      context.bundleID,
                      context.bundleVersion,
                      context.udid,
                      context.omid,
                      context.adid,
                      self.deviceToken,
                      kAppleID];
     */
    return text;
}

- (NSString *)userInfoText {
    NSString *text = @"";
    /*
    RNUserInfo *userInfo = [RNLoginManager sharedInstance].userInfo;
    NSString *text = [NSString stringWithFormat:@"ppid: \n%@\n\n"\
                      @"userid: \n%@\n\n"\
                      @"unionid: \n%@\n\n"\
                      @"userName: \n%@\n\n"\
                      @"telephone: \n%@\n\n"\
                      @"age: \n%@\n\n"\
                      @"avatar: \n%@\n\n"\
                      @"inviteCode: \n%@",
                      userInfo.ppid,
                      userInfo.userId,
                      userInfo.unionid,
                      userInfo.userName,
                      userInfo.telephone,
                      userInfo.age,
                      userInfo.avatar,
                      userInfo.inviteCode];
     */
    return text;
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
