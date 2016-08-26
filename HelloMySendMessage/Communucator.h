//
//  Communucator.h
//  HelloMySendMessage
//
//  Created by MinYeh on 2016/6/17.
//  Copyright © 2016年 MINYEH. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ID_KEY    @"id"
#define USER_NAME_KEY    @"UserName"
#define MESSAGE_KEY    @"Message"
#define DEVICETOKEN_KEY    @"DeviceToken"
#define GROUP_NAME_KEY    @"GroupName"
#define LAST_MESSAGE_ID_KEY    @"LastMessageID"
#define TYPE_KEY    @"Type"
#define DATA_KEY @"data"
#define GROUP_NAME  @"AP102"
#define MESSAGES_KEY @"Messages"

#define MY_NAME @"Minyeh"

//將void(^)(NSError *error,id result) 改名成DoneHandler
typedef void (^DoneHandler)(NSError *error,id result);
@interface Communucator : NSObject


+(instancetype) sharedInstance;
//回報deviceToken（字串型態） block作用：因為送出會需要等待，需要異步執行
//-(void) updateDeviceToken:(NSString*) deviceToken completion:(void(^)(NSError *error,id result)) doneHandler;

//上面30行改寫（含24行）
-(void) updateDeviceToken:(NSString*) deviceToken completion:(DoneHandler) doneHandler;


-(void) sendTextMessage:(NSString*) message completion:(DoneHandler) doneHandler;

-(void) retriveMessageWithLastMessageID:(NSInteger)lastMessageID completion:(DoneHandler) doneHandler;
-(void) downloadPhotoWithFileName:(NSString*) fileName completion:(DoneHandler)doneHandler;

-(void) sendPhotoMessageWithData:(NSData *)data completion:(DoneHandler) doneHandler;
@end
