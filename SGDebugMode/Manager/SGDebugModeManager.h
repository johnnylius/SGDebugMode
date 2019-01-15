//
//  SGDebugModeManager.h
//  SGDebugMode
//
//  Created by liuhuan on 2018/5/14.
//  Copyright © 2018年 Sogou. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 调试模式使用说明：
 1、使用SetDebugModeConfig来添加调试配置，兼容任意类型，但只有BOOL类型内部保存为NSNumber，其它以NSString保存，
 这样做的目的主要是用它来显示Switch样式的Cell。
 使用SetDebugModeConfigAndBlock来添加调试配置和配置改变block，block会保留住其中变量，使用需要特别注意
 2、使用GetDebugModeConfig来获得调试配置，这个值会根据是否开启调试模式，是否进行修改等情况来获得你想要的值，
 所以外部直接使用就可以了。这个返回值是NSString类型，需要根据实际转成自己想要的类型。
 3、保存BOOL类型会在列表中显示带Switch的Cell样式，保存其它类型会显示字符串的Cell样式。
 4、不支持保存空字符串作为配置的值，当置空保存时会得到初始设置的默认值。
 
 举例说明：
 SetDebugModeConfig(@"value", @"显示标题，同时也是保存Key", SGDebugModeGroupConfig);
 NSString *stringConfig = GetDebugModeConfig(@"显示标题，同时也是保存Key", @"defaultValue");
 
 SetDebugModeConfig(123, @"保存整型配置", SGDebugModeGroupConfig);
 NSInteger intValue = GetDebugModeConfig(@"保存整型配置", @"123").integerValue;
 
 SetDebugModeConfig(123.456, @"保存浮点型配置", SGDebugModeGroupConfig);
 float floatValue = GetDebugModeConfig(@"保存浮点型配置", @"123.456").floatValue;
 
 SetDebugModeConfig(YES, @"保存BOOL型配置也行", SGDebugModeGroupConfig);
 BOOL boolValue = GetDebugModeConfig(@"保存BOOL型配置也行", (@YES).stringValue).boolValue;
 
 SetDebugModeConfigAndBlock(YES, @"网络接口线上环境", SGDebugModeGroupConfig, ^{
    BOOL online = GetDebugModeConfig(@"网络接口线上环境", (@YES).stringValue).boolValue;
    NSLog(@"%@", online ? @"线上环境" : @"线下环境");
 });
 需要注意的是，第一次调用SetDebugModeConfigAndBlock时，block就会被调用，
 所以需要配置的内容直接写到block里可以了，会在里面直接被初始化，就不用在外面再设置了
 */

#define DebugModeManager ([SGDebugModeManager sharedInstance])

// 设置调试模式配置，title参数是配置菜单显示标题，同时也是保存配置的Key，group参数是配置分组，主要用于配置菜单分组显示
#define SetDebugModeConfig(_config, _title, _group) \
SetDebugModeConfigAndBlock(_config, _title, _group, nil)

// 设置调试模式配置和配置改变block，注意block会保留住其中变量，不要在其中添加controller等
#define SetDebugModeConfigAndBlock(_config, _title, _group, _block) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored\"-Wformat\"") \
{ \
    /* 保存配置改变block */ \
    [DebugModeManager setConfigChangedBlock:_block title:_title]; \
    NSString *type = [NSString stringWithCString:@encode(typeof(_config)) encoding:NSUTF8StringEncoding]; \
    if ([type isEqualToString:@"B"]) { \
        /* 如果是BOOL型 */ \
        NSString *value = [NSString stringWithFormat:@"%d", _config]; \
        NSNumber *number = [NSNumber numberWithBool:value.boolValue]; \
        [DebugModeManager setConfig:number title:_title debug:NO group:_group]; \
    } else if ([type isEqualToString:@"c"] || \
               [type isEqualToString:@"i"] || \
               [type isEqualToString:@"s"] || \
               [type isEqualToString:@"l"] || \
               [type isEqualToString:@"q"] || \
               [type isEqualToString:@"C"] || \
               [type isEqualToString:@"I"] || \
               [type isEqualToString:@"S"] || \
               [type isEqualToString:@"L"] || \
               [type isEqualToString:@"Q"]) { \
        /* 如果是整型 */ \
        NSString *value = [NSString stringWithFormat:@"%d", _config]; \
        [DebugModeManager setConfig:value title:_title debug:NO group:_group]; \
    } else if ([type isEqualToString:@"f"] || \
               [type isEqualToString:@"d"]) { \
        /* 如果是浮点型 */ \
        NSString *value = [NSString stringWithFormat:@"%f", _config]; \
        [DebugModeManager setConfig:value title:_title debug:NO group:_group]; \
    } else if ([type isEqualToString:@"@"]) { \
        /* 如果是OC对象 */ \
        NSString *value = [NSString stringWithFormat:@"%@", _config]; \
        [DebugModeManager setConfig:value title:_title debug:NO group:_group]; \
    } \
} \
_Pragma("clang diagnostic pop") \

// 得到调试模式配置，defaultConfig参数是配置为空时的返回值
#define GetDebugModeConfig(_title, _defalutConfig) \
([NSString stringWithFormat:@"%@", [DebugModeManager configWithTitle:_title defaultConfig:_defalutConfig]])

typedef NSString * SGDebugModeGroup;
extern SGDebugModeGroup const SGDebugModeGroupWebURL; // 网页链接地址
extern SGDebugModeGroup const SGDebugModeGroupWebAPI; // 网络接口地址
extern SGDebugModeGroup const SGDebugModeGroupConfig; // 功能配置项

@interface SGDebugModeManager : NSObject

@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, copy) NSString *(^deviceInfoText)(void);
@property (nonatomic, copy) NSString *(^appInfoText)(void);
@property (nonatomic, copy) NSString *(^userInfoText)(void);

+ (instancetype)sharedInstance;
- (BOOL)isEnableDebugMode;
- (void)enableDebugMode:(BOOL)enable;
- (void)setConfigChangedBlock:(void (^)(void))block title:(NSString *)title;
- (void)setConfig:(NSObject *)config title:(NSString *)title debug:(BOOL)debug group:(SGDebugModeGroup)group;
- (NSDictionary *)allConfigWithGroup:(NSString *)group;
- (NSObject *)configWithTitle:(NSString *)title defaultConfig:(NSString *)defaultConfig;
- (BOOL)isConfigModifiedWithTitle:(NSString *)title;

@end
