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

static SvUDIDTools *uuidTool = nil;

+ (SvUDIDTools*)shead
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         uuidTool = [[SvUDIDTools alloc] init];
    });
    return uuidTool;
}

- (id)init
{
    self = [super init];
    if (self) {
        _UUID = [SSKeychain passwordForService:@"com.dync.teameeting"account:@"userUDIDS"];
       self.notFirstStart = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isUpateNickName"] boolValue];
        
        if (!_UUID) {
            CFUUIDRef uuid = CFUUIDCreate(NULL);
            assert(uuid != NULL);
            CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
            _UUID = [[NSString stringWithFormat:@"%@",uuidStr] lowercaseString];
            _UUID = [_UUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
            NSError *error;
            [SSKeychain setPassword: _UUID
                         forService:@"com.dync.teameeting"account:@"userUDIDS" error:&error];
           
            if (error) {
                NSLog(@"SSKeychain Faile");
            }
        }
        NSLog(@"UUID：%@",_UUID);
    }
    return self;
}
- (void)setNotFirstStart:(BOOL)notFirstStart
{
    
    _notFirstStart = notFirstStart;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:notFirstStart] forKey:@"isUpateNickName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
