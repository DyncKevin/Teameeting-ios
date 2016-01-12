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

@interface TMMessageManage : NSObject


+ (TMMessageManage *)sharedManager;
- (void)inintTMMessage;
- (void)OnMsgServerConnected;
- (int)sendMsgUserid:(NSString*) userid
               pass:(NSString*) pass
             roomid:(NSString*) roomid
                msg:(NSString*) msg;
- (int)tmRoomCmd:(TMMEETCMD) cmd
          Userid:(NSString*) userid
            pass:(NSString*) pass
          roomid:(NSString*) roomid
          remain:(NSString*) remain;
#pragma CoreDataAction
- (void)insertMeeageDataWtihBelog:(NSString *)belong;
- (void)insertRoomDataWithKey:(NSString *)key;
- (NSMutableArray*)selectDataFromMessageTableWithKey:(NSString *)key pageSize:(NSUInteger)size currentPage:(NSInteger)page;
- (NSMutableArray*)selectDataFromRoomTableWithKey:(NSString *)key pageSize:(NSUInteger)size currentPage:(NSInteger)page;
- (void)deleteDataFromRoomTableWithKey:(NSString *)key;
- (void)updateMessageTableDataWithKey:(NSString *)key data:(NSString *)data;

@end
