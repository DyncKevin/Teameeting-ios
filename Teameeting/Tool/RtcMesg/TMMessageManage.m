//
//  TMMessageManage.m
//  Room
//
//  Created by yangyang on 16/1/5.
//  Copyright © 2016年 zjq. All rights reserved.
//

#import "TMMessageManage.h"
#import "Message.h"
#import "Rooms.h"
#import "SvUDIDTools.h"
#import "ServerVisit.h"
@interface TMMessageManage() <MsgClientProtocol>


@property(nonatomic,strong)TMMsgSender *msg;
@property(nonatomic,strong)NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong)NSManagedObjectModel *managedObjectModel;
@property(nonatomic,strong)NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(nonatomic,strong)NSMutableArray *messageListeners;
- (void)saveCoreData;
- (NSURL *)applicationDocumentsDirectory;
- (void)deleteDataFromMessageTableWithKey:(NSString *)key;
@end

@implementation TMMessageManage

+ (TMMessageManage *)sharedManager
{
    static TMMessageManage *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    
    if (self = [super init]) {
        
        _msg = [[TMMsgSender alloc] init];
        _messageListeners = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    
    [_msg tMUint];
}

- (void)inintTMMessage {
    
    [_msg tMInitMsgProtocol:self uid:[SvUDIDTools UDID] token:[ServerVisit shead].authorization server:@"192.168.7.39" port:9210];
}

- (void)registerMessageListener:(id<tmMessageReceive>)listener {
    
    if (![self.messageListeners containsObject:listener]) {
        
        [self.messageListeners addObject:listener];
    }
}

#pragma CoreDataAction

- (void)saveCoreData {
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {

        }
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TMessage" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TMessage.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
      
    }
    return _persistentStoreCoordinator;
}

- (void)insertMeeageDataWtihBelog:(NSString *)belong content:(NSString *)content messageTime:(NSString *)time
{
    NSManagedObjectContext *context = [self managedObjectContext];
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    message.belong = belong;
    message.content = content;
    message.time = [NSString stringWithFormat:@"%@",time];
    NSError *error;
    if(![context save:&error])
    {
       NSLog(@"不能保存：%@",[error localizedDescription]);
    }
}

- (void)insertRoomDataWithKey:(NSString *)key {

    NSManagedObjectContext *context = [self managedObjectContext];
    Rooms *room = [NSEntityDescription insertNewObjectForEntityForName:@"Rooms" inManagedObjectContext:context];
    room.name = key;
    NSError *error;
    if(![context save:&error])
    {
        NSLog(@"不能保存：%@",[error localizedDescription]);
    }
    
}

- (NSUInteger)getUnreadCountByRoomKey:(NSString *)key lasetTime:(NSString **)time{
    
    NSMutableArray *messages = [NSMutableArray array];
    NSArray *searchResult = [self selectDataFromMessageTableWithKey:key pageSize:20 currentPage:0];
    [messages addObjectsFromArray:searchResult];
    int index = 0;
    while ([searchResult count] != 0) {
        
        index ++;
        searchResult = [self selectDataFromMessageTableWithKey:key pageSize:20 currentPage:[searchResult count]];
        [messages addObjectsFromArray:searchResult];
    }
    Message *lastMessage = [messages lastObject];
    *time = lastMessage.time;
    return [messages count];
}

- (NSDictionary *)getUnreadCountByRoomKeys:(NSString *)key, ... {
    
    NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
    va_list args;
    va_start(args, key);
    NSString *lastTime = nil;
    NSUInteger count = [self getUnreadCountByRoomKey:key lasetTime:&lastTime];

    [messageDic setObject:[NSArray arrayWithObjects:[NSNumber numberWithInteger:count], lastTime,nil] forKey:key];
    
    if (key)
    {
        NSString *otherString;
        while ((otherString = va_arg(args, NSString *)))
        {
            NSUInteger count = [self getUnreadCountByRoomKey:otherString lasetTime:&lastTime];
            [messageDic setObject:[NSArray arrayWithObjects:[NSNumber numberWithInteger:count], lastTime,nil] forKey:otherString];
        }
    }
    va_end(args);
    return messageDic;
}

- (NSMutableArray*)selectDataFromMessageTableWithKey:(NSString *)key pageSize:(NSUInteger)size currentPage:(NSInteger)page
{

    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSString *searchSql = [NSString stringWithFormat:@"belong BEGINSWITH[cd]  '%@'",key];
    NSPredicate * qcondition= [NSPredicate predicateWithFormat:searchSql];
    [fetchRequest setPredicate:qcondition];
    [fetchRequest setFetchLimit:size];
    [fetchRequest setFetchOffset:page];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (Message *item in fetchedObjects) {
        
        [resultArray addObject:item];
    }
    return resultArray;
}

- (NSMutableArray *)selectDataFromRoomTableWithKey:(NSString *)key pageSize:(NSUInteger)size currentPage:(NSInteger)page {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSString *searchSql = [NSString stringWithFormat:@"name BEGINSWITH[cd]  '%@'",key];
    NSPredicate * qcondition= [NSPredicate predicateWithFormat:searchSql];
    [fetchRequest setPredicate:qcondition];
    [fetchRequest setFetchLimit:size];
    [fetchRequest setFetchOffset:page];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Rooms" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (Rooms *item in fetchedObjects) {
        
        [resultArray addObject:item];
    }
    return resultArray;
}

-(void)deleteDataFromRoomTableWithKey:(NSString *)key
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Rooms" inManagedObjectContext:context];
    
    NSString *searchSql = [NSString stringWithFormat:@"name BEGINSWITH[cd]  '%@'",key];
    NSPredicate * qcondition= [NSPredicate predicateWithFormat:searchSql];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setIncludesPropertyValues:NO];
    [request setEntity:entity];
    [request setPredicate:qcondition];
    NSError *error = nil;
    NSArray *datas = [context executeFetchRequest:request error:&error];
    if (!error && datas && [datas count])
    {
        for (Rooms *obj in datas)
        {
            [self deleteDataFromMessageTableWithKey:obj.name];
            [context deleteObject:obj];
        }
        if (![context save:&error])
        {
            NSLog(@"error:%@",error);
        }
    }
}

- (void)deleteDataFromMessageTableWithKey:(NSString *)key {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    
    NSString *searchSql = [NSString stringWithFormat:@"belong BEGINSWITH[cd]  '%@'",key];
    NSPredicate * qcondition= [NSPredicate predicateWithFormat:searchSql];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setIncludesPropertyValues:NO];
    [request setEntity:entity];
    [request setPredicate:qcondition];
    NSError *error = nil;
    NSArray *datas = [context executeFetchRequest:request error:&error];
    if (!error && datas && [datas count])
    {
        for (NSManagedObject *obj in datas)
        {
            [context deleteObject:obj];
        }
        if (![context save:&error])
        {
            NSLog(@"error:%@",error);
        }
    }
}

- (void)updateMessageTableDataWithKey:(NSString *)key data:(NSString *)data
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"newsid like[cd] %@",key];
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    Message *item = [result firstObject];
    if ([context save:&error]) {
        
        NSLog(@"%@",item.description);
    }
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark TMessage Action


- (int)sendMsgWithRoomid:(NSString *)roomid msg:(NSString *)msg {
    
   return [self.msg tMSndMsgRoomid:roomid msg:msg];
}

- (int)tmRoomCmd:(MCMeetCmd)cmd roomid:(NSString *)roomid remain:(NSString *)remain {

    return [self.msg tMOptRoomCmd:cmd roomid:roomid remain:remain];
}

- (int)tMNotifyMsgRoomid:(NSString*)roomid withMessage:(NSString*)meg
{
    return [self.msg tMNotifyMsgRoomid:roomid msg:meg];
}

//接收消息
- (void) OnSndMsgMsg:(NSString *) msg {
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        NSDictionary *messageDic = [NSJSONSerialization JSONObjectWithData:[msg dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        if ([[messageDic objectForKey:@"cmd"] intValue] == 3) {
            
            BOOL searchTag = NO;
            for (id<tmMessageReceive> object in self.messageListeners) {
                
                if ([object respondsToSelector:@selector(messageDidReceiveWithContent:messageTime:)] && [object receiveMessageEnable]) {
                    
                    if (![[messageDic objectForKey:@"from"] isEqualToString:[SvUDIDTools UDID]]) {
                        
                        [object messageDidReceiveWithContent:[messageDic objectForKey:@"cont"] messageTime:[messageDic objectForKey:@"ntime"]];
                    }
                    
                    searchTag = YES;
                    break;
                }

            }
            if (!searchTag && ![[messageDic objectForKey:@"from"] isEqualToString:[SvUDIDTools UDID]]) {
                
                [[TMMessageManage sharedManager] insertMeeageDataWtihBelog:[messageDic objectForKey:@"room"] content:[messageDic objectForKey:@"cont"] messageTime:[messageDic objectForKey:@"ntime"]];
                for (id<tmMessageReceive> object in self.messageListeners) {
                    
                    if ([object respondsToSelector:@selector(roomListUnreadMessageChangeWithRoomID:totalCount:lastMessageTime:)] && [object receiveMessageEnable]) {
                        
                        NSString *lastMessageTime = nil;
                        NSInteger messageCount = [[TMMessageManage sharedManager] getUnreadCountByRoomKey:[messageDic objectForKey:@"room"] lasetTime:&lastMessageTime];
                        [object roomListUnreadMessageChangeWithRoomID:[messageDic objectForKey:@"room"] totalCount:messageCount lastMessageTime:lastMessageTime];
                        
                    }
                }
            }
            
        } else if ([[messageDic objectForKey:@"cmd"] intValue] == 1 || [[messageDic objectForKey:@"cmd"] intValue] == 2) {
            
            if ([[messageDic objectForKey:@"tags"] intValue] == 4 && [[messageDic objectForKey:@"cmd"] intValue] == 1) {
                
                for (id<tmMessageReceive> object in self.messageListeners) {
                    
                    if ([object respondsToSelector:@selector(videoSubscribeWith:)] && [object receiveMessageEnable]) {
                        
                        [object videoSubscribeWith:[messageDic objectForKey:@"cont"]];
                    }
                }
                return;
            }
            
            for (id<tmMessageReceive> object in self.messageListeners) {
                
                if ([object respondsToSelector:@selector(roomListMemberChangeWithRoomID:changeState:)] && [object receiveMessageEnable]) {
                    
                    if (![[messageDic objectForKey:@"from"] isEqualToString:[SvUDIDTools UDID]]) {
                        
                        [object roomListMemberChangeWithRoomID:[messageDic objectForKey:@"room"] changeState:[[messageDic objectForKey:@"cmd"] intValue]];
                    }
                    
                }
            }

        }
        
    });
}

- (BOOL)connectEnable {
    
    return [self.msg tMConnStatus] == MCConnStateCONNECTED ? YES : NO;
}

- (void) OnGetMsgMsg:(NSString*) msg {
    
    
}


- (void) OnMsgServerConnected {
    
    NSLog(@"ok");
}

- (void) OnMsgServerDisconnect {
    
    
}

- (void) OnMsgServerConnectionFailure {
    
    
}

- (void) OnMsgServerStateConnState:(MCConnState) state {
    //the connection state between client and server
    //when the state has changed, this callback will be invoked
   // NSLog(@"OnMsgServerStateConnState state:%ld", state);
}

@end
