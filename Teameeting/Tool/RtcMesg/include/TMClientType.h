//
//  TMMsgSender.h
//  MsgClientIos
//
//  Created by hp on 12/25/15.
//  Copyright (c) 2015 Dync. All rights reserved.
//

#ifndef MsgClientIos_TMClientType_h
#define MsgClientIos_TMClientType_h

typedef enum _client_status{
    NOT_CONNECTED = 0,
    RESOLVING = 1,
    CONNECTTING = 2,
    CONNECTED = 3
}RTClientStatus;

typedef enum _client_type{
    code_ok = 0,
    code_invparams,
    code_errconninfo,
    code_errmoduinfo,
    code_errtojson,
    code_nexistroom,
    code_nexistmem,
    code_existroom,
    code_existmem,
    code_invalid
}RTClientType;


#endif
