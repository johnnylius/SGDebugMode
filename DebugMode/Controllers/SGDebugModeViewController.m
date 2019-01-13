//
//  SGDebugModeViewController.h
//  SGDebugMode
//
//  Created by liuhuan on 2018/5/14.
//  Copyright © 2018年 Sogou. All rights reserved.
//

#import "SGDebugModeViewController.h"
#import "SGDebugModeManager.h"
#import "SGDebugModeSwitchCell.h"
#import "SGDebugCustomEditView.h"
#import "SGDebugTextViewController.h"
#import "AppDelegate.h"

@interface SGDebugModeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation SGDebugModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"调试模式";
    [self.view addSubview:self.tableView];
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.dataSource[section] count];
    } else if (section > 0) {
        NSString *group = self.dataSource[section];
        NSDictionary *configDict = [DebugModeManager allConfigWithGroup:group];
        return configDict.allKeys.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        NSString *text = self.dataSource[indexPath.section][indexPath.row];
        cell.textLabel.text = text;
    } else if (indexPath.section < self.dataSource.count) {
        NSString *group = self.dataSource[indexPath.section];
        NSDictionary *configDict = [DebugModeManager allConfigWithGroup:group];
        NSString *title = configDict.allKeys[indexPath.row];
        NSObject *config = [DebugModeManager configWithTitle:title defaultConfig:nil];
        
        if ([config isKindOfClass:[NSString class]]) {
            NSString *value = (NSString *)config;
            cell.detailTextLabel.text = value;
        } else if ([config isKindOfClass:[NSNumber class]]) {
            NSNumber *number = (NSNumber *)config;
            SGDebugModeSwitchCell *switchCell = [self.tableView dequeueReusableCellWithIdentifier:@"switchCell" forIndexPath:indexPath];
            switchCell.value = number.boolValue;
            __weak typeof(self) weakSelf = self;
            switchCell.switchChangedBlock = ^(BOOL on) {
                NSNumber *number = [NSNumber numberWithBool:on];
                [DebugModeManager setConfig:number title:title debug:YES group:group];
                [weakSelf.tableView reloadData];
            };
            cell = switchCell;
        }
        cell.textLabel.text = title;
        
        // 如果修改过显示红色进行区别
        if ([DebugModeManager isConfigModifiedWithTitle:title]) {
            cell.textLabel.textColor = [UIColor redColor];
            cell.detailTextLabel.textColor = [UIColor redColor];
        } else {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.textColor = [UIColor blackColor];
        }
    }
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"调试信息";
    } else if (section > 0) {
        return self.dataSource[section];
    }
    return @"";
}

#pragma mark - UITableViewDataDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        NSString *text = @"";
        if (indexPath.row == 0) {
            text = [DebugModeManager deviceInfoText];
        } else if (indexPath.row == 1) {
            text = [DebugModeManager appInfoText];
        } else if (indexPath.row == 2) {
            text = [DebugModeManager userInfoText];
        }
        NSString *title = self.dataSource[indexPath.section][indexPath.row];
        SGDebugTextViewController *controller = [[SGDebugTextViewController alloc] initWithText:text];
        controller.navigationItem.title = title;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section > 0) {
        NSString *group = self.dataSource[indexPath.section];
        NSDictionary *configDict = [DebugModeManager allConfigWithGroup:group];
        NSString *title = configDict.allKeys[indexPath.row];
        NSObject *config = [DebugModeManager configWithTitle:title defaultConfig:@""];
        
        if ([config isKindOfClass:[NSString class]]) {
            NSString *value = (NSString *)config;
            [[[SGDebugCustomEditView alloc] init] showWithText:value block:^(NSString *text) {
                if (![text isEqualToString:value]) {
                    [DebugModeManager setConfig:text title:title debug:YES group:group];
                    [self.tableView reloadData];
                }
            }];
        }
    }
}

#pragma mark - Getter and Setter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [_tableView registerClass:[SGDebugModeSwitchCell class] forCellReuseIdentifier:@"switchCell"];
    }
    return _tableView;
}

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:@"设备信息"];
        [array addObject:@"应用信息"];
        [array addObject:@"用户信息"];
        [_dataSource addObject:array];
        
        array = [NSMutableArray array];
        [_dataSource addObject:SGDebugModeGroupWebURL];
        [_dataSource addObject:SGDebugModeGroupWebAPI];
        [_dataSource addObject:SGDebugModeGroupConfig];
    }
    return _dataSource;
}

@end
