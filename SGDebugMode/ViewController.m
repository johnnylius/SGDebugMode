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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enableDebugMode:(id)sender {
    [DebugModeManager enableDebugMode:YES];
    SGDebugModeViewController *controller = [[SGDebugModeViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
