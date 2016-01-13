//
//  TMMsgSender.h
//  MsgClientIos
//
//  Created by hp on 12/25/15.
//  Copyright (c) 2015 Dync. All rights reserved.
//

#ifndef MsgClientIos_TMClientType_h
#define MsgClientIos_TMClientType_h

typedef NS_ENUM(NSInteger, MCConnState){
    MCConnStateNOT_CONNECTED = 0,
    MCConnStateRESOLVING = 1,
    MCConnStateCONNECTTING = 2,
    MCConnStateCONNECTED = 3
};

typedef NS_ENUM(NSInteger, MCErrorType){
    MCErrorTypeOK = 0,
    MCErrorTypeINVPARAMS,
    MCErrorTypeCONNINFO,
    MCErrorTypeMODUINFO,
    MCErrorTypeNEXISTROOM,
    MCErrorTypeNEXISTMEM,
    MCErrorTypeEXISTROOM,
    MCErrorTypeEXISTMEM,
    MCErrorTypeINVALID
};

typedef NS_ENUM(NSInteger, MCMeetCmd){
    MCMeetCmdENTER=1,
    MCMeetCmdLEAVE,
    MCMeetCmdDCOMM,
    MCMeetCmdINVALID
};

typedef NS_ENUM(NSInteger, MCDcommAction){
    MCDcommActionMSEND=1,
    MCDcommActionDSETT,
    MCDcommActionSHARE,
    MCDcommActionINVALID
};

typedef NS_ENUM(NSInteger, MCSendTags){
    MCSendTagsTALK=1,
    MCSendTagsCHAT,
    MCSendTagsLVMSG,
    MCSendTagsNOTIFY,
    MCSendTagsINVALID
};

typedef NS_ENUM(NSInteger, MCMessageType){
    MCMessageTypeREQUEST=1,
    MCMessageTypeRESPONSE,
    MCMessageTypeINVALID
};

typedef NS_ENUM(NSInteger, MCGetCmd){
    MCGetCmdINVALID=1
};

#endif
