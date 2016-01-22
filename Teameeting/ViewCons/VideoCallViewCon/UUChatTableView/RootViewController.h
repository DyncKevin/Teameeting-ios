//
//  RootViewController.h
//  UUChatTableView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMMessageManage.h"
#import "VideoCallViewController.h"
#import "VideoViewController.h"

@interface RootViewController : UIViewController<tmMessageReceive>


//@property(nonatomic,assign)VideoCallViewController *parentViewCon;
@property (nonatomic, strong)void(^closeRootViewBlock)(void);
@property (nonatomic, assign)VideoViewController *parentViewCon;
- (void)resetInputFrame:(CGRect)rect;
- (void)hidenInput;
- (void)resginKeyBord;
- (void)setReceiveMessageEnable:(BOOL)enable;
@end
