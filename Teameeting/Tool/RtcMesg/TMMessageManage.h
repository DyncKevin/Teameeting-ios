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
- (void)messageDidReceiveWithContent:(NSString *)content messageTime:(NSString *)time withNickName:(NSString*)nickName;
//for VideoSubscribe
- (void)videoSubscribeWith:(NSString *)publishId action:(NSInteger)action;
//for Video Audio Setting
- (void)videoAudioSet:(NSString *)content action:(NSInteger)action;

//for RoomList
- (void)roomListMemberChangeWithRoomID:(NSString *)roomID changeState:(NSInteger)state;
- (void)roomListUnreadMessageChangeWithRoomID:(NSString *)roomID totalCount:(NSInteger)count lastMessageTime:(NSString *)time;
- (BOOL)receiveMessageEnable;
@end


@interface TMMessageManage : NSObject


+ (TMMessageManage *)sharedManager;
- (void)inintTMMessage;
- (int)sendMsgWithRoomid:(NSString*) roomid
            withRoomName:(NSString*)roomName
                     msg:(NSString*) msg;
- (int)tmRoomCmd:(MCMeetCmd) cmd
          roomid:(NSString*) roomid
    withRoomName:(NSString*)roomName
          remain:(NSString*) remain;

- (int)tMNotifyMsgRoomid:(NSString*)roomid
                withTags:(MCSendTags)tags
             withMessage:(NSString*)meg;

- (BOOL)connectEnable;

- (void)registerMessageListener:(id<tmMessageReceive>)listener;
- (void)removeMessageListener:(id<tmMessageReceive>)listener;
#pragma CoreDataAction
- (NSUInteger)getUnreadCountByRoomKey:(NSString *)key lasetTime:(NSString **)time;
- (NSDictionary *)getUnreadCountByRoomKeys:(NSString *)key,...;
- (void)clearUnreadCountByRoomKey:(NSString*)key;

- (void)insertMeeageDataWtihBelog:(NSString *)belong content:(NSString *)content messageTime:(NSString *)time;
- (void)insertRoomDataWithKey:(NSString *)key;
- (NSMutableArray*)selectDataFromMessageTableWithKey:(NSString *)key pageSize:(NSUInteger)size currentPage:(NSInteger)page;
- (NSMutableArray*)selectDataFromRoomTableWithKey:(NSString *)key pageSize:(NSUInteger)size currentPage:(NSInteger)page;
- (void)deleteDataFromRoomTableWithKey:(NSString *)key;
- (void)updateMessageTableDataWithKey:(NSString *)key data:(NSString *)data;

@end
