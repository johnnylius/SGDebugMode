//
//  SGDebugModeSwitchCell.h
//  SGDebugMode
//
//  Created by liuhuan on 2018/8/6.
//  Copyright © 2018年 Sogou. All rights reserved.
//

#import "SGDebugModeSwitchCell.h"

@interface SGDebugModeSwitchCell ()

@property (nonatomic, strong) UISwitch *valueSwitch;

@end

@implementation SGDebugModeSwitchCell

#pragma mark - Life Cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = CGSizeMake(50, 30);
    CGFloat right = self.contentView.frame.size.width;
    CGFloat bottom = self.contentView.frame.size.height;
    self.valueSwitch.frame = CGRectMake(right - 15 - size.width, (bottom - size.height) / 2, size.width, size.height);
}

#pragma mark - Public Method

#pragma mark - Event Response
- (void)valueSwitchChanged:(UISwitch *)sender {
    if (self.switchChangedBlock) {
        self.switchChangedBlock(sender.on);
    }
}

#pragma mark - Private Method
- (void)setupSubViews {
    self.textLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.valueSwitch];
}

#pragma mark - Getter and Setter
- (void)setValue:(BOOL)value {
    self.valueSwitch.on = value;
}

- (UISwitch *)valueSwitch {
    if (_valueSwitch == nil) {
        _valueSwitch = [[UISwitch alloc] init];
        [_valueSwitch addTarget:self action:@selector(valueSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _valueSwitch;
}

@end
