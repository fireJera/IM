//
//  CTMSGDataBaseManager.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGDataBaseManager.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "CTMSGIMClient.h"
//#import <sqlite3.h>
//#import "CTMSGMessageModel.h"
#import "CTMSGMessage.h"
#import "CTMSGMessageContent.h"
#import "CTMSGUserInfo.h"
//#import "CTMSGConversationModel.h"
#import "CTMSGConversation.h"
#import "CTMSGTextMessage.h"
#import "CTMSGVoiceMessage.h"
#import "CTMSGImageMessage.h"
#import "CTMSGVideoMessage.h"
#import "CTMSGLocationMessage.h"
#import "CTMSGUnknownMessage.h"
#import "CTMSGInformationNotificationMessage.h"

//#import "CTMSGDHttpTool.h"
//#import "CTMSGDUserInfo.h"
//#import "RCDUtilities.h"

@interface CTMSGDataBaseManager ()

@property(nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation CTMSGDataBaseManager

static NSString *const conversationTable = @"CTMSG_CONVERSATION";
static NSString *const messageTable = @"CTMSG_MESSAGE";
static NSString *const userTable = @"CTMSG_USER";
static NSString *const syncTable = @"CTMSG_SYNC";
static NSString *const versionTable = @"CTMSG_VERSION";
static NSString *const blackTable = @"CTMSG_BLACK";
//static NSString *const lockTableName = @"LOCKTABLE";

+ (instancetype)shareInstance {
    static CTMSGDataBaseManager *_instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [[super allocWithZone:NULL] init];
        [_instance dbQueue];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance];
}

- (id)copy {
    return [[self class] shareInstance];
}

- (id)mutableCopy {
    return [[self class] shareInstance];
}
//
//- (void)moveFile:(NSString *)fileName fromPath:(NSString *)fromPath toPath:(NSString *)toPath {
//    if (![[NSFileManager defaultManager] fileExistsAtPath:toPath]) {
//        [[NSFileManager defaultManager] createDirectoryAtPath:toPath
//                                  withIntermediateDirectories:YES
//                                                   attributes:nil
//                                                        error:nil];
//    }
//    NSString *srcPath = [fromPath stringByAppendingPathComponent:fileName];
//    NSString *dstPath = [toPath stringByAppendingPathComponent:fileName];
//    [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:dstPath error:nil];
//}
//
//- (void)moveDBFile {
//    NSString *const rongIMDemoDBString = @"CTMSGIMDB";
//    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask,
//                                                                 YES)[0] stringByAppendingPathComponent:@"ChatMessage"];
//    NSArray<NSString *> *subPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentPath error:nil];
//    [subPaths enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
//        if ([obj hasPrefix:rongIMDemoDBString]) {
//            [self moveFile:obj fromPath:documentPath toPath:libraryPath];
//        }
//    }];
//}

- (FMDatabaseQueue *)dbQueue {
    if ([CTMSGIMClient sharedCTMSGIMClient].currentUserInfo.userId == nil) {
        return nil;
    }
    NSString *userid = [CTMSGIMClient sharedCTMSGIMClient].currentUserInfo.userId;
    NSParameterAssert(userid);
    if (!userid) return nil;
    
    if (!_dbQueue) {
//        [self moveDBFile];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *const roungCloud = @"ChatMessage";
        NSString *library = [[paths objectAtIndex:0] stringByAppendingPathComponent:roungCloud];
        NSString *temp = [library stringByAppendingPathComponent:userid];
        NSString *dbPath = [temp stringByAppendingPathComponent:@"CTMSGIMDB"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:temp]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:temp withIntermediateDirectories:YES attributes:nil error:nil];
        }
//        if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
//            [[NSFileManager defaultManager] createFileAtPath:dbPath contents:nil attributes:nil];
//        }
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        if (_dbQueue) {
            [self p_ctmsg_createTableIfNeed];
        }
    }
    return _dbQueue;
}

//创建用户存储表
- (void)p_ctmsg_createTableIfNeed {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if (![self isTableOK:conversationTable withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE CTMSG_CONVERSATION ("
            @"target_id TEXT NOT NULL,"
            @"category_id SMALLINT NOT NULL,"
            @"conversation_title TEXT,"
            @"draft_message TEXT,"
            @"is_top BOOLEAN DEFAULT 0,"
            @"last_time INTEGER,"
            @"top_time INTEGER,"
            @"unread_count INTEGER DEFAULT 0,"
            @"latest_msgid INTEGER DEFAULT -1,"
            @"block_status INTEGER DEFAULT 0,"
            @"read_time INTEGER DEFAULT 0,"
            @"receipt_time INTEGER DEFAULT 0,"
            @"extrat_column1 INTEGER DEFAULT 0,"
            @"extrat_column2 INTEGER DEFAULT 0,"
            @"extrat_column3 TEXT,"
            @"extrat_column4 TEXT)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL = @"CREATE unique INDEX idx_targetid ON CTMSG_CONVERSATION(target_id);";
            [db executeUpdate:createIndexSQL];
        }
        if (![self isTableOK:messageTable withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE CTMSG_MESSAGE ("
            @"id INTEGER PRIMARY KEY AUTOINCREMENT,"
            @"target_id TEXT NOT NULL,"
            @"category_id SMALLINT,"
            @"message_direction BOOLEAN,"
            @"read_status SMALLINT DEFAULT 0,"
            @"receive_time INTEGER,"
            @"send_time INTEGER,"
            @"clazz_name TEXT,"
            @"content TEXT,"
            @"send_status BOOLEAN DEFAULT 0,"
            @"sender_id TEXT,"
            @"message_uid TEXT,"
            @"mean_content TEXT,"
            @"extra_content TEXT,"
            @"delete_time INTEGER DEFAULT 0,"
            @"source TEXT,"
            @"extrat_column1 INTEGER DEFAULT 0,"
            @"extrat_column2 INTEGER DEFAULT 0,"
            @"extrat_column3 TEXT,"
            @"extrat_column4 TEXT)";
            [db executeUpdate:createTableSQL];
            NSString *unionIndexSQL = @"CREATE unique INDEX ctmsg_union ON CTMSG_MESSAGE(target_id, send_time);";
            [db executeUpdate:unionIndexSQL];
            NSString *uidIndexSQL = @"CREATE unique INDEX ctmsg_uid ON CTMSG_MESSAGE(message_uid);";
            [db executeUpdate:uidIndexSQL];
            NSString *timeIndexSQL = @"CREATE unique INDEX ctmsg_sendtime ON CTMSG_MESSAGE(send_time);";
            [db executeUpdate:timeIndexSQL];
            
//            NSString * type = [NSString stringWithFormat:@"%d", (int)conversationType];
//            NSString * lastTime = [NSString stringWithFormat:@"%ld", (long)message.receivedTime];
//            NSString * unread = [NSString stringWithFormat:@"%d", (int)(unreadCount+1)];
//            NSString * lastMsgid = [NSString stringWithFormat:@"%ld", message.messageId];
//            NSString * title = [[message class] conversationDigest];

            NSString *insertTrigger = @"CREATE TRIGGER insert_con_after_msg AFTER INSERT ON CTMSG_MESSAGE "
            @"BEGIN "
            @"REPLACE INTO CTMSG_CONVERSATION (target_id, category_id, last_time, latest_msgid) VALUES (new.target_id, new.category_id, new.receive_time, new.id);"
            @"END;";
            [db executeUpdate:insertTrigger];
            
            NSString *unreadTri = @"CREATE TRIGGER unread_msg_insert AFTER INSERT ON CTMSG_MESSAGE "
            @"FOR EACH ROW WHEN new.read_status = '0' "
            @"BEGIN "
            @"UPDATE CTMSG_CONVERSATION SET unread_count = unread_count + 1 WHERE target_id = new.target_id;"
            @"END;";
            [db executeUpdate:unreadTri];
            NSString *readTri = @"CREATE TRIGGER read_msg_update AFTER UPDATE ON CTMSG_MESSAGE "
            @"FOR EACH ROW WHEN new.read_status = '1' "
            @"BEGIN "
            @"UPDATE CTMSG_CONVERSATION SET unread_count = 0 WHERE target_id = new.target_id;"
            @"END;";
            [db executeUpdate:readTri];
        }
        if (![self isTableOK:userTable withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE CTMSG_USER ("
            @"id INTEGER PRIMARY KEY AUTOINCREMENT,"
            @"userid TEXT NOT NULL,"
            @"name TEXT,"
            @"portraitUri TEXT,"
            @"is_vip BOOLEAN DEFAULT 0,"
            @"extrat_column1 INTEGER DEFAULT 0,"
            @"extrat_column2 TEXT)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL = @"CREATE unique INDEX idx_userid ON CTMSG_USER(userid);";
            [db executeUpdate:createIndexSQL];
        }
        if (![self isTableOK:blackTable withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE CTMSG_BLACK ("
            @"id INTEGER PRIMARY KEY AUTOINCREMENT,"
            @"userid TEXT NOT NULL)";
//            @"name TEXT,"
//            @"portraitUri TEXT)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL = @"CREATE unique INDEX idx_blackid ON CTMSG_BLACK(userid);";
            [db executeUpdate:createIndexSQL];
        }
        if (![self isTableOK:syncTable withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE CTMSG_SYNC ("
            @"user_id TEXT NOT NULL,"
            @"sync_time INTEGER,"
            @"send_time INTEGER)";
            [db executeUpdate:createTableSQL];
        }
        if (![self isTableOK:versionTable withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE CTMSG_VERSION ("
            @"database_version INTEGER NOT NULL,"
            @"kit_version TEXT NOT NULL,"
            @"create_time INTEGER)";
            [db executeUpdate:createTableSQL];
        }
        
    }];
}

- (BOOL)isTableOK:(NSString *)tableName withDB:(FMDatabase *)db {
    BOOL isOK = NO;
    
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where "
                       @"type ='table' and name = ?",
                       tableName];
    while ([rs next]) {
        NSInteger count = [rs intForColumn:@"count"];
        if (0 == count) {
            isOK = NO;
        } else {
            isOK = YES;
        }
    }
    [rs close];
    
    return isOK;
}

#pragma mark - message

- (long)insertMessageToDB:(CTMSGMessage *)message conversationType:(CTMSGConversationType)conversationType hasRead:(BOOL)hasRead {
    NSString * type = [NSString stringWithFormat:@"%d", (int)conversationType];
    NSString * direction = [NSString stringWithFormat:@"%d", (int)message.messageDirection];
    NSString * read = [NSString stringWithFormat:@"%d", hasRead];
    //    NSString * senderid;
    if (message.messageDirection == CTMSGMessageDirectionSend) {
        message.receivedTime = message.sentTime;
    } else {
        message.sentStatus = SentStatus_SENT;
        message.sentTime = message.receivedTime;
    }
    NSString *rTime = @(message.receivedTime).stringValue;
    NSString *sTime = @(message.sentTime).stringValue;
    NSString *msg = [[message.content class] getObjectName];
    NSData * data = [message.content encode];
    NSString * content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString * send = @(message.sentStatus).stringValue;
    NSString * meanContent;
    NSString *insertSql = @"INSERT INTO CTMSG_MESSAGE (target_id, category_id, message_direction, read_status, receive_time, send_time, clazz_name, content, send_status, sender_id, message_uid, mean_content, extra_content, source) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    __block long messageId;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql, message.targetId, type, direction, read, rTime, sTime, msg, content, send, message.senderUserId, message.messageUId, meanContent, message.extra, @"server"];
        messageId = [db lastInsertRowId];
    }];
    return messageId;
}

- (BOOL)updateMessageReadStatusWithTargetId:(NSString *)targetId {
    NSString *updateSql = @"UPDATE CTMSG_MESSAGE SET read_status = ? WHERE target_id = ? AND read_status = ?";
    __block BOOL success;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        success = [db executeUpdate:updateSql, @"0", targetId, @"1"];
        if (success) {
            
        } else {
            
        }
    }];
//    [self.dbQueue inDatabase:^(FMDatabase *db) {
//        [db beginTransaction];
//        success = [db executeUpdate:updateSql, @"0", targetId, @"1"];
//        if (success) {
//
//        } else {
//
//        }
//        [db commit];
//    }];
    return success;
}

- (long)searchMessagesSendTimeByMessageId:(NSString *)messageId {
    __block long sendTime;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:@"SELECT send_time from CTMSG_MESSAGE WHERE messageId = ?", messageId];
        sendTime = [rs longForColumn:@"send_time"];
    }];
    return sendTime;
}

- (NSArray<CTMSGMessage *> *)searchLatestMessagesByTargetId:(NSString *)targetId {
    return [self searchLatestMessagesByTargetId:targetId count:20];
}

- (NSArray<CTMSGMessage *> *)searchLatestMessagesByTargetId:(NSString *)targetId count:(NSInteger)count {
    __block NSMutableArray<CTMSGMessage *> *messages = [NSMutableArray array];
    NSString * countStr = [NSString stringWithFormat:@"%ld", (long)count];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM CTMSG_MESSAGE WHERE target_id=? ORDER BY send_time ASC LIMIT ? ", targetId, countStr];
        while ([rs next]) {
//            @"id INTEGER PRIMARY KEY AUTOINCREMENT,"
//            @"target_id TEXT NOT NULL,"
//            @"category_id SMALLINT,"
//            @"message_direction BOOLEAN,"
//            @"read_status SMALLINT DEFAULT 0,"
//            @"receive_time INTEGER,"
//            @"send_time INTEGER,"
//            @"clazz_name TEXT,"
//            @"content TEXT,"
//            @"send_status BOOLEAN DEFAULT 0,"
//            @"sender_id TEXT,"
//            @"message_uid TEXT,"
//            @"mean_content TEXT,"
//            @"extra_content TEXT,"
//            @"delete_time INTEGER DEFAULT 0,"
//            @"source TEXT,"
//            @"extrat_column1 INTEGER DEFAULT 0,"
//            @"extrat_column2 INTEGER DEFAULT 0,"
//            @"extrat_column3 TEXT,"
//            @"extrat_column4 TEXT)";
            
            CTMSGMessage *message = [CTMSGMessage new];
            message.conversationType = [[rs stringForColumn:@"category_id"] integerValue];
            message.targetId = [rs stringForColumn:@"target_id"];
            message.messageId = [[rs stringForColumn:@"id"] integerValue];
            message.messageDirection = [[rs stringForColumn:@"message_direction"] integerValue];
            message.senderUserId = [rs stringForColumn:@"sender_id"];
            message.receivedStatus = [[rs stringForColumn:@"read_status"] integerValue];
            message.sentStatus = [[rs stringForColumn:@"send_status"] integerValue];
            message.receivedTime = [[rs stringForColumn:@"receive_time"] longLongValue];
            message.sentTime = [[rs stringForColumn:@"send_time"] integerValue];
            message.objectName = [rs stringForColumn:@"clazz_name"];
            NSString * str = [rs stringForColumn:@"content"];
            NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
            CTMSGMessageContent * content;
            if ([message.objectName isEqualToString:CTMSGTextMessageTypeIdentifier]) {
                content = [[CTMSGTextMessage alloc] init];
                [(CTMSGTextMessage *)content decodeWithData:data];
            }
            else if ([message.objectName isEqualToString:CTMSGVoiceMessageTypeIdentifier]) {
                content = [[CTMSGVoiceMessage alloc] init];
                [(CTMSGVoiceMessage *)content decodeWithData:data];
            }
            else if ([message.objectName isEqualToString:CTMSGImageMessageTypeIdentifier]) {
                content = [[CTMSGImageMessage alloc] init];
                [(CTMSGImageMessage *)content decodeWithData:data];
            }
            else if ([message.objectName isEqualToString:CTMSGVideoMessageTypeIdentifier]) {
                content = [[CTMSGVideoMessage alloc] init];
                [(CTMSGVoiceMessage *)content decodeWithData:data];
            }
            else if ([message.objectName isEqualToString:CTMSGLocationMessageTypeIdentifier]) {
                content = [[CTMSGLocationMessage alloc] init];
                [(CTMSGLocationMessage *)content decodeWithData:data];
            }
            else if ([message.objectName isEqualToString:CTMSGUnknownMessageTypeIdentifier]) {
                content = [[CTMSGUnknownMessage alloc] init];
                [(CTMSGUnknownMessage *)content decodeWithData:data];
            }
            else if ([message.objectName isEqualToString:CTMSGInformationNotificationMessageIdentifier]) {
                content = [[CTMSGInformationNotificationMessage alloc] init];
                [(CTMSGInformationNotificationMessage *)content decodeWithData:data];
            }
            else {
                CTMSGMessageContent * content = [[CTMSGMessageContent alloc] init];
                [content decodeWithData:data];
            }
            message.content = content;
            message.extra = [rs stringForColumn:@"extrat_column3"];
            message.messageUId = [rs stringForColumn:@"message_uid"];
            
            [messages addObject:message];
        }
        [rs close];
    }];
//    [self.dbQueue inDatabase:^(FMDatabase *db) {
//    }];
    return messages;
}

- (NSArray<CTMSGMessage *> *)searchLatestMessagesByTargetId:(NSString *)targetId oldestMessageId:(long)oldestMessageId count:(NSInteger)count {
    __block NSMutableArray<CTMSGMessage *> *messages = [NSMutableArray array];
    NSString * countStr = [NSString stringWithFormat:@"%ld", (long)count];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM CTMSG_MESSAGE WHERE target_id=? AND id<? ORDER BY send_time ASC LIMIT ?", targetId, oldestMessageId, countStr];
        while ([rs next]) {
            CTMSGConversationType conversationType = [[rs stringForColumn:@"category_id"] integerValue];
            NSString * targetId = [rs stringForColumn:@"target_id"];
            CTMSGMessageDirection messageDirection = [[rs stringForColumn:@"message_direction"] integerValue];
            NSString *senderUserId = [rs stringForColumn:@"sender_id"];
            NSString * str = [rs stringForColumn:@"content"];
            CTMSGMessageContent * content = [[CTMSGMessageContent alloc] init];
            [content decodeWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
            
            CTMSGMessage *message = [[CTMSGMessage alloc] initWithType:conversationType
                                                              targetId:targetId
                                                             direction:messageDirection
                                                             messageId:[senderUserId integerValue]
                                                               content:content];
            //            message.targetId = [rs stringForColumn:@"target_id"];
            //            message.messageId = [[rs stringForColumn:@"message_id"] integerValue];
            //            message.messageDirection = [[rs stringForColumn:@"message_direction"] integerValue];
            //            message.senderUserId = [rs stringForColumn:@"sender_id"];
            //            message.receivedStatus = [[rs stringForColumn:@"read_status"] integerValue];
            //            message.sentStatus = [[rs stringForColumn:@"sent_status"] integerValue];
            //            message.receivedTime = [[rs stringForColumn:@"receive_time"] longLongValue];
            //            message.sentTime = [[rs stringForColumn:@"send_time"] integerValue];
            //            message.objectName = [rs stringForColumn:@"clazz_name"];
            //            NSString * str = [rs stringForColumn:@"content"];
            //            CTMSGMessageContent * content = [[CTMSGMessageContent alloc] init];
            //            [content decodeWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
            //            message.content = content;
            //            message.extra = [rs stringForColumn:@"extra"];
            //            message.messageUId = [rs stringForColumn:@"message_uid"];
            
            [messages addObject:message];
        }
        [rs close];
    }];
    //    [self.dbQueue inDatabase:^(FMDatabase *db) {
    //    }];
    return messages;
}

- (NSArray<CTMSGMessage *> *)searchLatestMessagesByTargetId:(NSString *)targetId count:(NSInteger)count beforeTime:(NSInteger)time {
    __block NSMutableArray<CTMSGMessage *> *messages = [NSMutableArray array];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM CTMSG_MESSAGE WHERE target_id=? AND sent_time<? ORDER BY send_time ASC LIMIT ?", targetId, time, @"20"];
        while ([rs next]) {
            CTMSGConversationType conversationType = [[rs stringForColumn:@"category_id"] integerValue];
            NSString * targetId = [rs stringForColumn:@"target_id"];
            CTMSGMessageDirection messageDirection = [[rs stringForColumn:@"message_direction"] integerValue];
            NSString *senderUserId = [rs stringForColumn:@"sender_id"];
            NSString * str = [rs stringForColumn:@"content"];
            CTMSGMessageContent * content = [[CTMSGMessageContent alloc] init];
            [content decodeWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
            
            CTMSGMessage *message = [[CTMSGMessage alloc] initWithType:conversationType
                                                              targetId:targetId
                                                             direction:messageDirection
                                                             messageId:[senderUserId integerValue]
                                                               content:content];
//            message.targetId = [rs stringForColumn:@"target_id"];
//            message.messageId = [[rs stringForColumn:@"message_id"] integerValue];
//            message.messageDirection = [[rs stringForColumn:@"message_direction"] integerValue];
//            message.senderUserId = [rs stringForColumn:@"sender_id"];
//            message.receivedStatus = [[rs stringForColumn:@"read_status"] integerValue];
//            message.sentStatus = [[rs stringForColumn:@"sent_status"] integerValue];
//            message.receivedTime = [[rs stringForColumn:@"receive_time"] longLongValue];
//            message.sentTime = [[rs stringForColumn:@"send_time"] integerValue];
//            message.objectName = [rs stringForColumn:@"clazz_name"];
//            NSString * str = [rs stringForColumn:@"content"];
//            CTMSGMessageContent * content = [[CTMSGMessageContent alloc] init];
//            [content decodeWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
//            message.content = content;
//            message.extra = [rs stringForColumn:@"extra"];
//            message.messageUId = [rs stringForColumn:@"message_uid"];
            
            [messages addObject:message];
        }
        [rs close];
    }];
//    [self.dbQueue inDatabase:^(FMDatabase *db) {
//    }];
    return messages;
}

- (BOOL)removeMessageWithId:(NSInteger)messageId {
    __block BOOL success;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"DELETE FROM CTMSG_MESSAGE WHERE message_id=?", messageId];
    }];
    return success;
}

- (BOOL)removeMessageWithIds:(NSArray<NSString *> *)messageIds {
    __block BOOL success;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //        dispatch_apply(messageIds.count, dispatch_get_global_queue(0, 0), ^(size_t) {
        //
        //        });
        [messageIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BOOL removed = [db executeUpdate:@"DELETE FROM CTMSG_MESSAGE WHERE message_id=?", obj];
            if (!removed) {
                success = NO;
            }
        }];
    }];
    return success;
}

- (BOOL)removeMessagewithUid:(NSString *)messageUid {
    __block BOOL success;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"DELETE FROM CTMSG_MESSAGE WHERE message_uid=?", messageUid];
    }];
    return success;
}

- (BOOL)removeAllMessagewithTargetId:(NSString *)targetId {
    __block BOOL success;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"DELETE FROM CTMSG_MESSAGE WHERE target_id=?", targetId];
    }];
    return success;
}

- (CTMSGMessage *)searchMessagesByMessageId:(NSString *)messageId {
    __block CTMSGMessage *message;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM CTMSG_MESSAGE WHERE id=?", messageId];
        while ([rs next]) {
            CTMSGConversationType conversationType = [[rs stringForColumn:@"category_id"] integerValue];
            NSString * targetId = [rs stringForColumn:@"target_id"];
            CTMSGMessageDirection messageDirection = [[rs stringForColumn:@"message_direction"] integerValue];
            NSString *senderUserId = [rs stringForColumn:@"sender_id"];
            NSString * str = [rs stringForColumn:@"content"];
            CTMSGMessageContent * content = [[CTMSGMessageContent alloc] init];
            [content decodeWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
            
            message = [[CTMSGMessage alloc] initWithType:conversationType
                                                targetId:targetId
                                               direction:messageDirection
                                               messageId:[senderUserId integerValue]
                                                 content:content];
            
            break;
        }
        [rs close];
    }];
    return message;
}

- (CTMSGMessage *)searchMessagesByMessageUid:(NSString *)messageUid {
    __block CTMSGMessage *message;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM CTMSG_MESSAGE WHERE message_uid=?", messageUid];
        while ([rs next]) {
            CTMSGConversationType conversationType = [[rs stringForColumn:@"category_id"] integerValue];
            NSString * targetId = [rs stringForColumn:@"target_id"];
            CTMSGMessageDirection messageDirection = [[rs stringForColumn:@"message_direction"] integerValue];
            NSString *senderUserId = [rs stringForColumn:@"sender_id"];
            NSString * str = [rs stringForColumn:@"content"];
            CTMSGMessageContent * content = [[CTMSGMessageContent alloc] init];
            [content decodeWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
            
            message = [[CTMSGMessage alloc] initWithType:conversationType
                                                targetId:targetId
                                               direction:messageDirection
                                               messageId:[senderUserId integerValue]
                                                 content:content];
            
            break;
        }
        [rs close];
    }];
    return message;
}

- (NSInteger)searchMessageCountWithTargetId:(NSString *)targetId {
    __block NSInteger count = -1;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT count(*) FROM CTMSG_MESSAGE WHERE target_id=?", targetId];
        count = [rs columnCount];
    }];
    return count;
}

- (BOOL)clearMessageDB {
    __block BOOL isSuccess;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:@"DELETE FROM CTMSG_MESSAGE"];
    }];
    return isSuccess;
}

- (BOOL)compressMessageDB {
    __block BOOL isSuccess;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:@"VACUUM CTMSG_MESSAGE"];
    }];
    return isSuccess;
}

#pragma mark - conversation

- (void)insertConversationToDB:(CTMSGConversation *)conversation {
    NSString * type = [NSString stringWithFormat:@"%d", (int)conversation.conversationType];
    NSString * lastTime = [NSString stringWithFormat:@"%ld", (long)conversation.receivedTime];
    NSString * unread = [NSString stringWithFormat:@"%d", conversation.unreadMessageCount];
    NSString * lastMsgid = [NSString stringWithFormat:@"%ld", conversation.lastestMessageId];
    NSString *insertSql = @"REPLACE INTO CTMSG_CONVERSATION (target_id, category_id, conversation_title, last_time, unread_count, latest_msgid) VALUES (?, ?, ?, ?, ?, ?)";

    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql, conversation.targetId, type, conversation.conversationTitle, lastTime, unread, lastMsgid];
    }];
}

- (void)insertConversationWithSendMessage:(CTMSGMessage *)message
                         conversationType:(CTMSGConversationType)conversationType {
    if (message.messageDirection == CTMSGMessageDirectionReceive) {
        return;
    }
    NSString * type = [NSString stringWithFormat:@"%d", (int)conversationType];
    NSString * lastTime = [NSString stringWithFormat:@"%ld", (long)message.sentTime];
    NSString * lastMsgid = [NSString stringWithFormat:@"%ld", message.messageId];
    NSString * title = [[message class] conversationDigest];
    NSString *insertSql = @"REPLACE INTO CTMSG_CONVERSATION (target_id, category_id, conversation_title, last_time, latest_msgid) VALUES (?, ?, ?, ?, ?)";
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql, message.targetId, type, title, lastTime, lastMsgid];
    }];
}

- (void)insertConversationWithReceivedMessage:(CTMSGMessage *)message
                     conversationType:(CTMSGConversationType)conversationType
                          unreadCount:(NSInteger)unreadCount {
    if (message.messageDirection == CTMSGMessageDirectionSend) {
        return;
    }
    NSString * type = [NSString stringWithFormat:@"%d", (int)conversationType];
    NSString * lastTime = [NSString stringWithFormat:@"%ld", (long)message.receivedTime];
    NSString * unread = [NSString stringWithFormat:@"%d", (int)(unreadCount+1)];
    NSString * lastMsgid = [NSString stringWithFormat:@"%ld", message.messageId];
    NSString * title = [[message class] conversationDigest];
    NSString *insertSql = @"REPLACE INTO CTMSG_CONVERSATION (target_id, category_id, conversation_title, last_time, unread_count, latest_msgid) VALUES (?, ?, ?, ?, ?)";
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql, message.senderUserId, type, title, lastTime, unread, lastMsgid];
    }];
}

- (BOOL)updateConversationToDB:(CTMSGConversation *)conversation {
    return YES;
}

- (BOOL)updateConversationTop:(BOOL)isTop to:(NSString *)targetId {
    NSString *updateSql = @"UPDATE CTMSG_CONVERSATION SET is_top = ? WHERE target_id = ?";
    __block BOOL success;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:updateSql, @(isTop).stringValue, targetId];
        if (success) {
            
        } else {
            
        }
    }];
    return success;
}

- (BOOL)updateConversationDraft:(NSString *)draft to:(NSString *)targetId {
    NSString *updateSql = @"UPDATE CTMSG_CONVERSATION SET draft_message = ? WHERE target_id = ?";
    __block BOOL success;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:updateSql, draft, targetId];
        if (success) {
            
        } else {
            
        }
    }];
    return success;
}

//- (BOOL)updateConversationWithMessage:(CTMSGMessage *)message {
//    NSString * targetId = message.targetId;
//    if (message.receivedStatus = ReceivedStatus_UNREAD) {
//        <#statements#>
//    }
//    NSString *updateSql = @"UPDATE CTMSG_CONVERSATION SET conversation_title = ? last_time = ? unread_count = ? WHERE target_id = ?";
//    __block BOOL success;
//    [self.dbQueue inDatabase:^(FMDatabase *db) {
//        success = [db executeUpdate:updateSql, @(readTime).stringValue, targetId];
//        if (success) {
//
//        } else {
//
//        }
//    }];
//    return success;
//}

- (BOOL)updateConversationReadTime:(NSInteger)readTime to:(NSString *)targetId {
    NSString *updateSql = @"UPDATE CTMSG_CONVERSATION SET read_time = ? WHERE target_id = ?";
    __block BOOL success;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:updateSql, @(readTime).stringValue, targetId];
        if (success) {
            
        } else {
            
        }
    }];
    return success;
}

- (BOOL)updateConversationBlockStatus:(NSInteger)blockStatus to:(NSString *)targetId {
    NSString *updateSql = @"UPDATE CTMSG_CONVERSATION SET block_status = ? WHERE target_id = ?";
    __block BOOL success;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:updateSql, @(blockStatus).stringValue, targetId];
        if (success) {
            
        } else {
            
        }
    }];
    return success;
}

- (BOOL)removeConversationFromDB:(NSString *)targetId {
    NSString *removeSql = @"DELETE FROM CTMSG_CONVERSATION WHERE target_id = ?";
    __block BOOL success;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:removeSql, targetId];
        if (success) {
            
        } else {
            
        }
    }];
    return success;
}

- (NSString *)searchConverstationDraft:(NSString *)targetId {
    __block NSString * draft;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT draft_message FROM CTMSG_CONVERSATION WHERE target_id = ?", targetId];
        while ([rs next]) {
            draft = [rs stringForColumn:@"draft_message"];
        }
    }];
    return draft;
}

- (NSArray<CTMSGConversation *> *)searchConverstationList {
    __block NSMutableArray<CTMSGConversation *> *conversations = [NSMutableArray array];
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
//        FMResultSet *rs = [db executeQuery:@"SELECT target_id, category_id, sender_id, draft_message, is_top, top_time, last_time, unread_count, latest_msgid, messag_direction, read_status receive_time, send_time, clazz_name, content, send_status, sender_id, message_uid, mean_content, extra_content, source FROM CTMSG_CONVERSATION INNER JOIN CTMSG_MESSAGE ON CTMSG_CONVERSATION.latest_msgid = CTMSG_MESSAGE.latest_msgid ORDER BY last_time DESC"];
        
//        FMResultSet *rs = [db executeQuery:@"SELECT target_id, category_id, sender_id, draft_message, is_top, top_time, last_time, unread_count, latest_msgid, content FROM CTMSG_CONVERSATION INNER JOIN CTMSG_MESSAGE ON CTMSG_CONVERSATION.latest_msgid = CTMSG_MESSAGE.latest_msgid ORDER BY last_time DESC"];
        //    UNION
        //    SELECT * FROM CTMSG_CONVERSATION LEFT OUTER JOIN CTMSG_MESSAGE
        //    ON CTMSG_CONVERSATION.target_id = CTMSG_MESSAGE.target_id;
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM CTMSG_CONVERSATION ORDER BY last_time DESC"];
        while ([rs next]) {
            CTMSGConversationType conversationType = [[rs stringForColumn:@"category_id"] integerValue];
            CTMSGConversation *conversation = [CTMSGConversation new];
            conversation.targetId = [rs stringForColumn:@"target_id"];
            conversation.conversationType = conversationType;
            conversation.conversationTitle = [rs stringForColumn:@"conversation_title"];
            conversation.draft = [rs stringForColumn:@"draft_message"];
            conversation.isTop = [[rs stringForColumn:@"is_top"] boolValue];
            conversation.topTime = [[rs stringForColumn:@"top_time"] longLongValue];
            conversation.receivedTime = [[rs stringForColumn:@"last_time"] longLongValue];
            conversation.sentTime = [[rs stringForColumn:@"last_time"] integerValue];
            conversation.unreadMessageCount = [[rs stringForColumn:@"unread_count"] intValue];
            conversation.lastestMessageId = [[rs stringForColumn:@"latest_msgid"] integerValue];
//            conversation. = [rs stringForColumn:@"block_statut"];
//            conversation. = [rs stringForColumn:@"read_time"];
//            conversation.objectName = [rs stringForColumn:@"clazz_name"];
            
//            NSString * targetId = [rs stringForColumn:@"target_id"];
//            CTMSGMessageDirection messageDirection = [[rs stringForColumn:@"message_direction"] integerValue];
//            NSString *senderUserId = [rs stringForColumn:@"sender_id"];
            
//            NSString * str = [rs stringForColumn:@"content"];
//            CTMSGMessageContent * content = [[CTMSGMessageContent alloc] init];
//            [content decodeWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
            
//            CTMSGMessage *message = [[CTMSGMessage alloc] initWithType:conversationType
//                                                              targetId:targetId
//                                                             direction:messageDirection
//                                                             messageId:[senderUserId integerValue]
//                                                               content:content];
//            conversation.lastestMessage = content;
            [conversations addObject:conversation];
        }
        [rs close];
    }];
    return conversations;
}

- (NSArray<CTMSGConversation *> *)searchDefaultConverstationList {
    return [self searchConverstationListForCount:20];
}

- (NSArray<CTMSGConversation *> *)searchConverstationListForCount:(int)count {
    __block NSMutableArray<CTMSGConversation *> *conversations = [NSMutableArray array];
    NSString *countStr = [NSString stringWithFormat:@"%d", count];
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //        FMResultSet *rs = [db executeQuery:@"SELECT target_id, category_id, sender_id, draft_message, is_top, top_time, last_time, unread_count, latest_msgid, messag_direction, read_status receive_time, send_time, clazz_name, content, send_status, sender_id, message_uid, mean_content, extra_content, source FROM CTMSG_CONVERSATION INNER JOIN CTMSG_MESSAGE ON CTMSG_CONVERSATION.latest_msgid = CTMSG_MESSAGE.latest_msgid ORDER BY last_time DESC"];
        
        //        FMResultSet *rs = [db executeQuery:@"SELECT target_id, category_id, sender_id, draft_message, is_top, top_time, last_time, unread_count, latest_msgid, content FROM CTMSG_CONVERSATION INNER JOIN CTMSG_MESSAGE ON CTMSG_CONVERSATION.latest_msgid = CTMSG_MESSAGE.latest_msgid ORDER BY last_time DESC"];
        //    UNION
        //    SELECT * FROM CTMSG_CONVERSATION LEFT OUTER JOIN CTMSG_MESSAGE
        //    ON CTMSG_CONVERSATION.target_id = CTMSG_MESSAGE.target_id;
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM CTMSG_CONVERSATION ORDER BY last_time DESC LIMIT ?", countStr];
        while ([rs next]) {
            CTMSGConversationType conversationType = [[rs stringForColumn:@"category_id"] integerValue];
            CTMSGConversation *conversation = [CTMSGConversation new];
            conversation.targetId = [rs stringForColumn:@"target_id"];
            conversation.conversationType = conversationType;
            conversation.conversationTitle = [rs stringForColumn:@"conversation_title"];
            conversation.draft = [rs stringForColumn:@"draft_message"];
            conversation.isTop = [[rs stringForColumn:@"is_top"] boolValue];
            conversation.topTime = [[rs stringForColumn:@"top_time"] longLongValue];
            conversation.receivedTime = [[rs stringForColumn:@"last_time"] longLongValue];
            conversation.sentTime = [[rs stringForColumn:@"last_time"] integerValue];
            conversation.unreadMessageCount = [[rs stringForColumn:@"unread_count"] intValue];
            conversation.lastestMessageId = [[rs stringForColumn:@"latest_msgid"] integerValue];
            //            conversation. = [rs stringForColumn:@"block_statut"];
            //            conversation. = [rs stringForColumn:@"read_time"];
            //            conversation.objectName = [rs stringForColumn:@"clazz_name"];
            
            //            NSString * targetId = [rs stringForColumn:@"target_id"];
            //            CTMSGMessageDirection messageDirection = [[rs stringForColumn:@"message_direction"] integerValue];
            //            NSString *senderUserId = [rs stringForColumn:@"sender_id"];
            
//            NSString * str = [rs stringForColumn:@"content"];
//            CTMSGMessageContent * content = [[CTMSGMessageContent alloc] init];
//            [content decodeWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
            
            //            CTMSGMessage *message = [[CTMSGMessage alloc] initWithType:conversationType
            //                                                              targetId:targetId
            //                                                             direction:messageDirection
            //                                                             messageId:[senderUserId integerValue]
            //                                                               content:content];
//            conversation.lastestMessage = content;
            [conversations addObject:conversation];
        }
        [rs close];
    }];
    return conversations;
}

- (NSArray<CTMSGConversation *> *)searchConverstationListForCount:(int)count time:(long long)time {
    __block NSMutableArray<CTMSGConversation *> *conversations = [NSMutableArray array];
    NSString *countStr = [NSString stringWithFormat:@"%d", count];
    NSString * timeStr = [NSString stringWithFormat:@"%lld", time];
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //        FMResultSet *rs = [db executeQuery:@"SELECT target_id, category_id, sender_id, draft_message, is_top, top_time, last_time, unread_count, latest_msgid, messag_direction, read_status receive_time, send_time, clazz_name, content, send_status, sender_id, message_uid, mean_content, extra_content, source FROM CTMSG_CONVERSATION INNER JOIN CTMSG_MESSAGE ON CTMSG_CONVERSATION.latest_msgid = CTMSG_MESSAGE.latest_msgid ORDER BY last_time DESC"];
        
        //        FMResultSet *rs = [db executeQuery:@"SELECT target_id, category_id, sender_id, draft_message, is_top, top_time, last_time, unread_count, latest_msgid, content FROM CTMSG_CONVERSATION INNER JOIN CTMSG_MESSAGE ON CTMSG_CONVERSATION.latest_msgid = CTMSG_MESSAGE.latest_msgid ORDER BY last_time DESC"];
        //    UNION
        //    SELECT * FROM CTMSG_CONVERSATION LEFT OUTER JOIN CTMSG_MESSAGE
        //    ON CTMSG_CONVERSATION.target_id = CTMSG_MESSAGE.target_id;
        FMResultSet *rs;
        if (time == 0) {
            rs = [db executeQuery:@"SELECT * FROM CTMSG_CONVERSATION ORDER BY last_time DESC LIMIT ?", countStr];
        } else {
            rs = [db executeQuery:@"SELECT * FROM CTMSG_CONVERSATION last_time<? ORDER BY last_time DESC LIMIT ?", timeStr, countStr];
        }
        while ([rs next]) {
            CTMSGConversationType conversationType = [[rs stringForColumn:@"category_id"] integerValue];
            CTMSGConversation *conversation = [CTMSGConversation new];
            conversation.targetId = [rs stringForColumn:@"target_id"];
            conversation.conversationType = conversationType;
            conversation.conversationTitle = [rs stringForColumn:@"conversation_title"];
            conversation.draft = [rs stringForColumn:@"draft_message"];
            conversation.isTop = [[rs stringForColumn:@"is_top"] boolValue];
            conversation.topTime = [[rs stringForColumn:@"top_time"] longLongValue];
            conversation.receivedTime = [[rs stringForColumn:@"last_time"] longLongValue];
            conversation.sentTime = [[rs stringForColumn:@"last_time"] integerValue];
            conversation.unreadMessageCount = [[rs stringForColumn:@"unread_count"] intValue];
            conversation.lastestMessageId = [[rs stringForColumn:@"latest_msgid"] integerValue];
            //            conversation. = [rs stringForColumn:@"block_statut"];
            //            conversation. = [rs stringForColumn:@"read_time"];
            //            conversation.objectName = [rs stringForColumn:@"clazz_name"];
            
            //            NSString * targetId = [rs stringForColumn:@"target_id"];
            //            CTMSGMessageDirection messageDirection = [[rs stringForColumn:@"message_direction"] integerValue];
            //            NSString *senderUserId = [rs stringForColumn:@"sender_id"];
            
//            NSString * str = [rs stringForColumn:@"content"];
//            CTMSGMessageContent * content = [[CTMSGMessageContent alloc] init];
//            [content decodeWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
            
            //            CTMSGMessage *message = [[CTMSGMessage alloc] initWithType:conversationType
            //                                                              targetId:targetId
            //                                                             direction:messageDirection
            //                                                             messageId:[senderUserId integerValue]
            //                                                               content:content];
//            conversation.lastestMessage = content;
            [conversations addObject:conversation];
        }
        [rs close];
    }];
    return conversations;
}

- (BOOL)clearConversationDB {
    __block BOOL isSuccess;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:@"DELETE FROM CTMSG_CONVERSATION"];
    }];
    return isSuccess;
}

#pragma mark - user

//存储用户信息
- (void)insertUserToDB:(CTMSGUserInfo *)user {
    NSString *insertSql = @"REPLACE INTO CTMSG_USER (userid, name, portraitUri, is_vip) VALUES (?, ?, ?, ?)";
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql, user.userId, user.name, user.portraitUri, @(user.isVip).stringValue];
    }];
}

//- (void)updateUserToDB:(CTMSGUserInfo *)user {
//
//}

- (CTMSGUserInfo *)searchUserInfoWithID:(NSString *)userid {
    __block CTMSGUserInfo *model = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM CTMSG_USER where userid = ?", userid];
        while ([rs next]) {
            model = [[CTMSGUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            model.isVip = [[rs stringForColumn:@"portraitUri"] boolValue];
        }
        [rs close];
    }];
    return model;
}

- (void)removeUserFromDB:(NSString *)userid {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeQuery:@"DELETE FROM CTMSG_USER where userid=?", userid];
    }];
}

- (BOOL)clearUserDB {
    __block BOOL isSuccess;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:@"DELETE FROM CTMSG_USER"];
    }];
    return isSuccess;
}

#pragma mark - black

//- (BOOL)insertBlack:(CTMSGUserInfo *)user {
////    @"id INTEGER PRIMARY KEY AUTOINCREMENT,"
////    @"userid TEXT NOT NULL,"
////    @"name TEXT,"
////    @"portraitUri TEXT)"
//    __block BOOL isSuccess;
//    NSString * sql = @"REPLACE INTO CTMSG_BLACK (userid, name, portraitUrl) VALUES (?, ?, ?)";
//    [self.dbQueue inDatabase:^(FMDatabase *db) {
//        isSuccess = [db executeUpdate:sql, user.userId, user.name, user.portraitUri];
//    }];
//    return isSuccess;
//}

- (BOOL)insertBlackTargetId:(NSString *)targetId {
    __block BOOL isSuccess;
    NSString * sql = @"REPLACE INTO CTMSG_BLACK (userid) VALUES (?)";
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:sql, targetId];
    }];
    return isSuccess;
}

- (BOOL)removeBlackTargetId:(NSString *)targetId {
    __block BOOL isSuccess;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:@"DELETE FROM CTMSG_BLACK WHERE useri = ?", targetId];
    }];
    return isSuccess;
}

- (BOOL)isBlackInTable:(NSString *)targetId {
    __block BOOL isIn;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:@"SELECT * FROM CTMSG_BLACK WHERE userid = ?", targetId];
        isIn = [rs columnCount];
    }];
    return isIn;
}

- (BOOL)clearBlackDB {
    __block BOOL isSuccess;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:@"DELETE FROM CTMSG_BLACK"];
    }];
    return isSuccess;
}

#pragma mark - sync

- (void)insertSycnWithUserid:(NSString *)userid syncTime:(NSInteger)syncTime sendTime:(NSInteger)sendTime {
    NSString * insertSql = [NSString stringWithFormat:@"REPLACE INTO CTMSG_SYNC (userid, sync_time, send_time) VALUES (?,?,?)"];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeQuery:insertSql, userid, syncTime, sendTime];
    }];
}

- (BOOL)clearSyncDB {
    __block BOOL isSuccess;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:@"DELETE FROM CTMSG_SYNC"];
    }];
    return isSuccess;
}

#pragma mark - version

- (void)updateVersion:(NSString *)version kitVersion:(NSString *)kitVersion creatTime:(NSInteger)creatTime {
    NSString * insertSql = [NSString stringWithFormat:@"REPLACE INTO CTMSG_VERSION (database_version, kit_version, create_time) VALUES (?,?,?)"];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeQuery:insertSql, version, kitVersion, creatTime];
    }];
}

- (BOOL)clearVersionDB {
    __block BOOL isSuccess;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:@"DELETE FROM CTMSG_VERSION"];
    }];
    return isSuccess;
}

//#pragma mark -- 更新 锁定 相关信息
//- (void)insertLockInfoToDB:(NSString *)userId lockStatus:(NSUInteger)lockStatus {
//    NSString *insertSql = @"replace into LOCKTABLE (userid, lockStatus) values (?, ?)";
//    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
//        [db executeUpdate:insertSql, userId, @(lockStatus).stringValue];
//    }];
//}
//
//- (NSInteger)getLockStatusByUserID:(NSString *)userID {
//    __block NSInteger lockStatus = -1; // -1 表示没有
//    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
//        FMResultSet *rs = [db executeQuery:@"SELECT * FROM LOCKTABLE where userid = ?", userID];
//        while ([rs next]) {
//            NSString * result = [rs stringForColumn:@"lockStatus"];
//            lockStatus = [result INTEGERValue]; // 0 未回复，1 锁，2 已解锁
//        }
//        [rs close];
//    }];
//    return lockStatus;
//}

#pragma mark - clear db
- (BOOL)clearAllDB {
    BOOL isSuccess = [self clearMessageDB];
    if (!isSuccess) return NO;
    isSuccess = [self clearConversationDB];
    if (!isSuccess) return NO;
    isSuccess = [self clearBlackDB];
    if (!isSuccess) return NO;
    isSuccess = [self clearUserDB];
    return isSuccess;
//    [self clearSyncDB];
//    [self clearVersionDB];
}

#pragma mark - unread

- (int)searchTotalUnreadCount {
    __block int unread = 0;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:@"SELECT SUM(unread_count) FROM CTMSG_CONVERSATION"];
        while ([rs next]) {
            unread = [[rs stringForColumn:@"unread_count"] intValue];
        }
        [rs close];
    }];
    return unread;
}

- (int)searchUnreadCountWithTargetId:(NSString *)targetId {
    __block int unread = 0;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:@"SELECT unread_count FROM CTMSG_CONVERSATION WHERE target_id = ?", targetId];
        while ([rs next]) {
            unread = [[rs stringForColumn:@"unread_count"] intValue];
        }
        [rs close];
    }];
    return unread;
}

@end
