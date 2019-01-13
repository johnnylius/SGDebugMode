//
//  SGDebugCustomEditView.h
//  SGDebugMode
//
//  Created by liuhuan on 2018/5/14.
//  Copyright © 2018年 Sogou. All rights reserved.
//

#import "SGDebugCustomEditView.h"

@interface SGDebugCustomEditView ()

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIButton *copybutton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, copy) void (^editBlock)(NSString *text);

@end

@implementation SGDebugCustomEditView

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 120);
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Public Method
- (void)showWithText:(NSString *)text block:(void(^)(NSString *))block {
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.maskView.alpha = 0.5;
        CGRect frame = self.frame;
        frame.origin.y -= self.frame.size.height;
        self.frame = frame;
    }];
    
    self.textField.text = text;
    self.editBlock = block;
}

- (void)layoutSubviews {
    CGFloat width = self.frame.size.width;
    CGFloat right = self.frame.origin.x + self.frame.size.width;
    self.okButton.frame = CGRectMake(right - 10 - 40, 10, 40, 20);
    self.copybutton.frame = CGRectMake((width - 40) / 2, 10, 40, 20);
    self.cancelButton.frame = CGRectMake(10, 10, 40, 20);
    self.textField.frame = CGRectMake(10, 40, width - 20, 50);
}

#pragma mark - Event Response
- (void)okButtonClicked:(UIButton *)sender {
    if (self.editBlock != nil) {
        self.editBlock(self.textField.text);
    }
    
    [self cancelButtonClicked:nil];
}

- (void)copyButtonClicked:(UIButton *)sender {
    [UIPasteboard generalPasteboard].string = self.textField.text;
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"已复制" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [controller presentViewController:alert animated:YES completion:nil];
}

- (void)cancelButtonClicked:(UIButton *)sender {
    [self.textField resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.frame;
        frame.origin.y += self.frame.size.height;
        self.frame = frame;
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
        [self removeFromSuperview];
    }];
    
    self.editBlock = nil;
}

- (void)maskViewClicked:(UIView *)maskView {
    [self cancelButtonClicked:nil];
}

#pragma mark - Private Method
- (void)setupSubviews {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.okButton];
    [self addSubview:self.copybutton];
    [self addSubview:self.cancelButton];
    [self addSubview:self.textField];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive ||
        self.window == nil) {
        // 不在前台，或者不在当前页
        return;
    }
    [self keyboardWillChange:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive ||
        self.window == nil) {
        // 不在前台，或者不在当前页
        return;
    }
    [self keyboardWillChange:notification];
}

- (void)keyboardWillChange:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect frame = self.frame;
    frame.origin.y = endFrame.origin.y - frame.size.height;
    self.frame = frame;
}

#pragma mark - Getter and Setter
- (UIView *)maskView {
    if (_maskView == nil) {
        UIControl *maskView = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.alpha = 0.0;
        [maskView addTarget:self action:@selector(maskViewClicked:) forControlEvents:UIControlEventTouchUpInside];
        _maskView = maskView;
    }
    return _maskView;
}

- (UIButton *)okButton {
    if (_okButton == nil) {
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _okButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _okButton.titleLabel.textAlignment = NSTextAlignmentRight;
        [_okButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1] forState:UIControlStateNormal];
        [_okButton setTitle:@"确定" forState:UIControlStateNormal];
        [_okButton addTarget:self action:@selector(okButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _okButton;
}

- (UIButton *)copybutton {
    if (_copybutton == nil) {
        _copybutton = [UIButton buttonWithType:UIButtonTypeCustom];
        _copybutton.titleLabel.font = [UIFont systemFontOfSize:16];
        _copybutton.titleLabel.textAlignment = NSTextAlignmentRight;
        [_copybutton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1] forState:UIControlStateNormal];
        [_copybutton setTitle:@"复制" forState:UIControlStateNormal];
        [_copybutton addTarget:self action:@selector(copyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _copybutton;
}

- (UIButton *)cancelButton {
    if (_cancelButton == nil) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _cancelButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_cancelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UITextField *)textField {
    if (_textField == nil) {
        _textField = [[UITextField alloc] init];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.clearButtonMode = UITextFieldViewModeAlways;
        _textField.placeholder = @"请输入内容";
    }
    return _textField;
}

@end
