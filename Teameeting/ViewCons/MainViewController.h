//
//  MainViewController.h
//  Room
//
//  Created by yangyang on 15/11/16.
//  Copyright © 2015年 yangyangwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "RoomVO.h"

@interface MainViewController : BaseViewController

@property (nonatomic, strong) UITableView *roomList;

- (void)insertUserMeetingRoomWithID:(RoomItem*)item;

@end
