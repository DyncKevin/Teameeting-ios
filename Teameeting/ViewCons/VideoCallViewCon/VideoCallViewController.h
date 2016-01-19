//
//  VideoCallViewController.h
//  Room
//
//  Created by yangyang on 15/11/17.
//  Copyright © 2015年 yangyangwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomVO.h"
#import "ASBadgeView.h"

@interface UINavigationController (Orientations)


@end

@interface VideoCallViewController : UIViewController

@property (nonatomic, strong) RoomItem *roomItem;
@property(nonatomic,strong)ASBadgeView *badgeView;
- (BOOL)isVertical;
@end
