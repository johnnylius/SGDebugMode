//
//  ViewController.m
//  SGDebugMode
//
//  Created by liuhuan on 2019/1/12.
//  Copyright © 2019年 Sogou. All rights reserved.
//

#import "ViewController.h"
#import "SGDebugModeManager.h"
#import "SGDebugModeViewController.h"
#import <AdSupport/AdSupport.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setDebugModeConfig];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDebugModeConfig {
    // 设备信息
    DebugModeManager.deviceInfoText = ^NSString *{
        UIDevice *device = [UIDevice currentDevice];
        CGSize size = [UIScreen mainScreen].currentMode.size;
        NSString *resolution = [NSString stringWithFormat:@"%.f*%.f", size.width, size.height];
        NSString *text = [NSString stringWithFormat:
                          @"deviceName: \n%@\n\n"\
                          @"deviceModel: \n%@\n\n"\
                          @"systemName: \n%@\n\n"\
                          @"systemVersion: \n%@\n\n"\
                          @"machineModel: \n%@\n\n"\
                          @"resolution: \n%@",
                          device.name,
                          device.model,
                          device.systemName,
                          device.systemVersion,
                          @"iPhone9,2",
                          resolution];
        return text;
    };
    
    // 应用信息
    DebugModeManager.appInfoText = ^NSString *{
        NSString *bundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *udid = @"B3E3756A-7776-4943-B10E-F85DD4C27432";
        NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        NSString *pushToken = @"734aae1fd4e2fb4d4d5bcbcd44f6fd8b9dd3a66dca9e29ef9bda06ce216d9bc2";
        NSString *appleID = @"1256338755";
        NSString *text = [NSString stringWithFormat:
                          @"bundleID: \n%@\n\n"\
                          @"version: \n%@\n\n"\
                          @"udid: \n%@\n\n"\
                          @"idfa: \n%@\n\n"\
                          @"pushToken: \n%@\n\n"\
                          @"appleID: \n%@",
                          bundleID,
                          version,
                          udid,
                          idfa,
                          pushToken,
                          appleID];
        return text;
    };
    
    // 用户信息
    DebugModeManager.userInfoText = ^NSString *{
        NSString *text = [NSString stringWithFormat:
                          @"userid: \n%@\n\n"\
                          @"username: \n%@\n\n"\
                          @"telephone: \n%@\n\n"\
                          @"age: \n%@\n\n"\
                          @"avatar: \n%@",
                          @"123456789",
                          @"Johnny",
                          @"13888888888",
                          @"30",
                          @"https://www.sogou.com/avatar.png"];
        return text;
    };
    
    // 网页链接地址
    NSString *webURL1 = @"https://www.sogou.com/test1.html";
    SetDebugModeConfig(webURL1, @"测试网页1链接地址", SGDebugModeGroupWebURL);
    
    NSString *webURL2 = @"https://www.sogou.com/test2.html";
    SetDebugModeConfig(webURL2, @"测试网页2链接地址", SGDebugModeGroupWebURL);
    
    NSString *webURL3 = @"https://www.sogou.com/test3.html";
    SetDebugModeConfig(webURL3, @"测试网页3链接地址", SGDebugModeGroupWebURL);
    
    // 网络接口地址
    void (^configChangedBlock)(void) = ^{
        BOOL online = GetDebugModeConfig(@"网络接口线上环境", (@YES).stringValue).boolValue;
        NSLog(@"%@", online ? @"网络接口线上环境" : @"网络接口线下环境");
        
        NSString *baseURL1 = online ? @"https://test1.sogou.com/" : @"http://192.168.1.1/";
        SetDebugModeConfig(baseURL1, @"测试接口1地址", SGDebugModeGroupWebAPI);
        
        NSString *baseURL2 = online ? @"https://test2.sogou.com/" : @"http://192.168.1.2/";
        SetDebugModeConfig(baseURL2, @"测试接口2地址", SGDebugModeGroupWebAPI);
        
        NSString *baseURL3 = online ? @"https://test3.sogou.com/" : @"http://192.168.1.3/";
        SetDebugModeConfig(baseURL3, @"测试接口3地址", SGDebugModeGroupWebAPI);
    };
    SetDebugModeConfigAndBlock(YES, @"网络接口线上环境", SGDebugModeGroupConfig, configChangedBlock);
    
    // 功能配置项
    SetDebugModeConfig(@"test", @"测试配置", SGDebugModeGroupConfig);
    SetDebugModeConfig(YES, @"测试开关", SGDebugModeGroupConfig);
}

- (void)getDebugModeConfig {
    NSString *webURL1 = @"https://www.sogou.com/test1.html";
    webURL1 = GetDebugModeConfig(@"测试网页1链接地址", webURL1);
    NSString *webURL2 = @"https://www.sogou.com/test2.html";
    webURL2 = GetDebugModeConfig(@"测试网页2链接地址", webURL1);
    NSString *webURL3 = @"https://www.sogou.com/test3.html";
    webURL3 = GetDebugModeConfig(@"测试网页3链接地址", webURL1);
    
    NSString *baseURL1 = GetDebugModeConfig(@"测试接口1地址", nil);
    NSString *baseURL2 = GetDebugModeConfig(@"测试接口2地址", nil);
    NSString *baseURL3 = GetDebugModeConfig(@"测试接口3地址", nil);
    
    NSString *config = [NSString stringWithFormat:
                        @"%@\n%@\n%@\n\n"\
                        @"%@\n%@\n%@",
                        webURL1, webURL2, webURL3,
                        baseURL1, baseURL2, baseURL3];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:config preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)enableDebugMode:(id)sender {
    [DebugModeManager enableDebugMode:YES];
    SGDebugModeViewController *controller = [[SGDebugModeViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)disableDebugMode:(id)sender {
    [DebugModeManager enableDebugMode:NO];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"关闭调试模式" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)debugModeConfig:(id)sender {
    [self getDebugModeConfig];
}

@end
