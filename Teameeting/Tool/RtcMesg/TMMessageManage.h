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

- (void)messageDidReceiveWithContent:(NSString *)content messageTime:(NSString *)time;
- (BOOL)receiveMessageEnable;
@end


@interface TMMessageManage : NSObject


+ (TMMessageManage *)sharedManager;
- (void)inintTMMessage;
- (void)OnMsgServerConnected;
- (int)sendMsgUserid:(NSString*) userid
               pass:(NSString*) pass
             roomid:(NSString*) roomid
                msg:(NSString*) msg;
- (int)tmRoomCmd:(MCMeetCmd) cmd
          Userid:(NSString*) userid
            pass:(NSString*) pass
          roomid:(NSString*) roomid
          remain:(NSString*) remain;
- (void)registerMessageListener:(id<tmMessageReceive>)listener;
#pragma CoreDataAction
- (void)insertMeeageDataWtihBelog:(NSString *)belong content:(NSString *)content;
- (void)insertRoomDataWithKey:(NSString *)key;
- (NSMutableArray*)selectDataFromMessageTableWithKey:(NSString *)key pageSize:(NSUInteger)size currentPage:(NSInteger)page;
- (NSMutableArray*)selectDataFromRoomTableWithKey:(NSString *)key pageSize:(NSUInteger)size currentPage:(NSInteger)page;
- (void)deleteDataFromRoomTableWithKey:(NSString *)key;
- (void)updateMessageTableDataWithKey:(NSString *)key data:(NSString *)data;

@end
