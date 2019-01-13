//
//  SGDebugCustomEditView.h
//  SGDebugMode
//
//  Created by liuhuan on 2018/5/14.
//  Copyright © 2018年 Sogou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGDebugCustomEditView : UIView

@property (nonatomic, strong) NSString *text;

- (void)showWithText:(NSString *)text block:(void(^)(NSString *text))block;

@end
