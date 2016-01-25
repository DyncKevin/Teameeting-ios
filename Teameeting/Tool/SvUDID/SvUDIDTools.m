//
//  SvUDIDTools.m
//  SvUDID
//
//  Created by  maple on 8/18/13.
//  Copyright (c) 2013 maple. All rights reserved.
//

#import "SvUDIDTools.h"
#import <Security/Security.h>
#import "SSKeychain.h"

@implementation SvUDIDTools

+ (NSString*)UDID
{
    NSString *retrieveuuid = [SSKeychain passwordForService:@"com.dync.teameeting"account:@"userUDID"];
    
    if (!retrieveuuid) {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        assert(uuid != NULL);
        CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
        retrieveuuid = [NSString stringWithFormat:@"%@",uuidStr];
        
        [SSKeychain setPassword: retrieveuuid
                     forService:@"com.dync.teameeting"account:@"userUDID"];
    }
    NSLog(@"UUID：%@",retrieveuuid);
    return [retrieveuuid lowercaseString];
}
@end
