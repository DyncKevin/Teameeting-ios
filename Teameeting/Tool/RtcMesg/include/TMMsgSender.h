//
//  TMMsgSender.h
//  MsgClientIos
//
//  Created by hp on 12/25/15.
//  Copyright (c) 2015 Dync. All rights reserved.
//

#ifndef MsgClientIos_TMMsgSender_h
#define MsgClientIos_TMMsgSender_h
#import "MsgClientProtocol.h"

@interface TMMsgSender : NSObject

- (int) tMInitMsgProtocol:(id<MsgClientProtocol>)protocol
                   server:(NSString*) server
                    port :(int) port;
- (int) tMUint;

- (int) tMConnStatus;

- (int) tMLoginUserid:(NSString*) userid
                 pass:(NSString*) pass;

- (int) tMSndMsgUserid:(NSString*) userid
                  pass:(NSString*) pass
                roomid:(NSString*) roomid
                   msg:(NSString*) msg;

- (int) tMGetMsgUserid:(NSString*) userid
                  pass:(NSString*) pass;

- (int) tMLogoutUserid:(NSString*) userid
                  pass:(NSString*) pass;

- (int) tMOptRoomCmd:(TMMEETCMD) cmd
              Userid:(NSString*) userid
                pass:(NSString*) pass
              roomid:(NSString*) roomid
              remain:(NSString*) remain;

- (int) tMSndMsgToUserid:(NSString*) userid
                    pass:(NSString*) pass
                  roomid:(NSString*) roomid
                     msg:(NSString*) msg
                   ulist:(NSArray*) ulist;

- (int) tMNotifyMsgUserid:(NSString*) userid
                  pass:(NSString*) pass
                roomid:(NSString*) roomid
                   msg:(NSString*) msg;

@end

#endif
