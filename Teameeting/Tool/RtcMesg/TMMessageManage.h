//
//  TMMessageManage.h
//  Room
//
//  Created by yangyang on 16/1/5.
//  Copyright © 2016年 zjq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TMMsgSender.h"

@protocol tmMessageReceive <NSObject>

//for Chat
- (void)messageDidReceiveWithContent:(NSString *)content messageTime:(NSString *)time;

//for RoomList
- (void)roomListMemberChangeWithRoomID:(NSString *)roomID changeState:(NSInteger)state;
- (void)roomListUnreadMessageChangeWithRoomID:(NSString *)roomID totalCount:(NSInteger)count;
- (BOOL)receiveMessageEnable;
@end


@interface TMMessageManage : NSObject


+ (TMMessageManage *)sharedManager;
- (void)inintTMMessage;
- (int)sendMsgWithRoomid:(NSString*) roomid
                     msg:(NSString*) msg;
- (int)tmRoomCmd:(MCMeetCmd) cmd
          roomid:(NSString*) roomid
          remain:(NSString*) remain;

- (int)tMNotifyMsgRoomid:(NSString*)roomid
             withMessage:(NSString*)meg;

- (void)registerMessageListener:(id<tmMessageReceive>)listener;
#pragma CoreDataAction
- (NSUInteger)getUnreadCountByRoomKey:(NSString *)key;
- (void)insertMeeageDataWtihBelog:(NSString *)belong content:(NSString *)content;
- (void)insertRoomDataWithKey:(NSString *)key;
- (NSMutableArray*)selectDataFromMessageTableWithKey:(NSString *)key pageSize:(NSUInteger)size currentPage:(NSInteger)page;
- (NSMutableArray*)selectDataFromRoomTableWithKey:(NSString *)key pageSize:(NSUInteger)size currentPage:(NSInteger)page;
- (void)deleteDataFromRoomTableWithKey:(NSString *)key;
- (void)updateMessageTableDataWithKey:(NSString *)key data:(NSString *)data;

@end
