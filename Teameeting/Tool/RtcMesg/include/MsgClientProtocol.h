//
//  MsgClientProtocol.h
//  MsgClientIos
//
//  Created by hp on 12/25/15.
//  Copyright (c) 2015 Dync. All rights reserved.
//

#ifndef MsgClientIos_MsgClientProtocol_h
#define MsgClientIos_MsgClientProtocol_h

typedef enum _tmmeetcmd{
    TMCMD_ENTER=1,
    TMCMD_LEAVE,
    TMCMD_CREATE,
    TMCMD_DESTROY,
    TMCMD_REFRESH,
    TMCMD_DCOMM,
    TMCMD_MEETCMD_INVALID
}TMMEETCMD;

@protocol MsgClientProtocol <NSObject>

@required
- (void) OnReqLoginCode:(int) code status:(NSString*) status userid:(NSString*)userid;

- (void) OnRespLoginCode:(int) code status:(NSString*) status userid:(NSString*)userid;

- (void) OnReqSndMsgMsg:(NSString*) msg;

- (void) OnRespSndMsgMsg:(NSString*) msg;

- (void) OnReqGetMsgMsg:(NSString*) msg;

- (void) OnRespGetMsgMsg:(NSString*) msg;

- (void) OnReqLogoutCode:(int) code status:(NSString*) status userid:(NSString*)userid;

- (void) OnRespLogoutCode:(int) code status:(NSString*) status userid:(NSString*)userid;

- (void) OnMsgServerConnected;

- (void) OnMsgServerDisconnect;

- (void) OnMsgServerConnectionFailure;

@end

#endif
