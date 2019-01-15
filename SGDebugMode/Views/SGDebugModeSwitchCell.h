//
//  SGDebugModeSwitchCell.h
//  SGDebugMode
//
//  Created by liuhuan on 2018/8/6.
//  Copyright © 2018年 Sogou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGDebugModeSwitchCell : UITableViewCell

@property (nonatomic, assign) BOOL value;
@property (nonatomic, copy) void(^switchChangedBlock)(BOOL on);

@end
