//
//  SGDebugTextViewController.h
//  SGDebugMode
//
//  Created by liuhuan on 2018/5/16.
//  Copyright © 2018年 Sogou. All rights reserved.
//

#import "SGDebugTextViewController.h"

@interface SGDebugTextViewController ()

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIButton *copybutton;
@property (nonatomic, strong) UITextView *textView;

@end

@implementation SGDebugTextViewController

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        _text = text;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view addSubview:self.copybutton];
    [self.view addSubview:self.textView];
}

- (void)viewDidLayoutSubviews {
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    self.copybutton.frame = CGRectMake((width - 40) / 2, 10, 40, 20);
    self.textView.frame = CGRectMake(10, 40, width - 20, height - 10 - 40);
}

#pragma mark - Event Response
- (void)copyButtonClicked:(UIButton *)sender {
    [UIPasteboard generalPasteboard].string = self.textView.text;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"已复制" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Private Method

#pragma mark - Getter and Setter
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

- (UITextView *)textView {
    if (_textView == nil) {
        _textView = [[UITextView alloc] init];
        _textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _textView.layer.borderWidth = 1.0;
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.text = self.text;
        _textView.editable = NO;
    }
    return _textView;
}

@end
