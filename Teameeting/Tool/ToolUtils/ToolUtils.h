//
//  ToolUtils.h
//  Room
//
//  Created by zjq on 15/11/17.
//  Copyright © 2015年 yangyangwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToolUtils : NSObject

+(ToolUtils*)shead;

@property (nonatomic, strong) NSString *meetingID;

// 是否允许推送
+ (BOOL)isAllowedNotification;

@end
