//
//  Communucator.m
//  HelloMySendMessage
//
//  Created by MinYeh on 2016/6/17.
//  Copyright © 2016年 MINYEH. All rights reserved.
//

#import "Communucator.h"
#import <AFNetworking.h>

#define BASE_URL @"http://class.softarts.cc/PushMessage"

#define SENDMESSAGE_URL [BASE_URL stringByAppendingPathComponent:@"sendMessage.php"]

#define SENDPHOTOMESSAGE_URL [BASE_URL stringByAppendingPathComponent:@"sendPhotoMessage.php"]

#define RETRIVEMESSAGES_URL [BASE_URL stringByAppendingPathComponent:@"retriveMessages2.php"]

#define UPDATEDEVICETOKEN_URL [BASE_URL stringByAppendingPathComponent:@"updateDeviceToken.php"]

#define PHOTOS_BASE_URL [BASE_URL stringByAppendingPathComponent:@"photos/"]


@implementation Communucator

static Communucator *_singletonCommunicator = nil;

+(instancetype) sharedInstance{
    
    if(_singletonCommunicator == nil){
        _singletonCommunicator = [Communucator new];
    }
    
    return _singletonCommunicator;
}


-(void) updateDeviceToken:(NSString*) deviceToken completion:(DoneHandler) doneHandler{
    NSDictionary *jsonObj = @{USER_NAME_KEY:MY_NAME,DEVICETOKEN_KEY:deviceToken,GROUP_NAME_KEY:GROUP_NAME};
    
    [self doPost:UPDATEDEVICETOKEN_URL parameters:jsonObj completion:doneHandler];
    
    
}

-(void) sendTextMessage:(NSString*) message completion:(DoneHandler) doneHandler{
    NSDictionary *jsonObj = @{USER_NAME_KEY:MY_NAME,MESSAGE_KEY:message,GROUP_NAME_KEY:GROUP_NAME};
    
    [self doPost:SENDMESSAGE_URL parameters:jsonObj completion:doneHandler];
}
-(void) retriveMessageWithLastMessageID:(NSInteger)lastMessageID completion:(DoneHandler) doneHandler{
    NSDictionary *jsonObj = @{LAST_MESSAGE_ID_KEY:@(lastMessageID),GROUP_NAME_KEY:GROUP_NAME};
    //@()裡面是放NSNumber ex: @(lastMessageID) 等同於 [NSNumber numberWithInt:lastMessageID];
    [self doPost:RETRIVEMESSAGES_URL parameters:jsonObj completion:doneHandler];

}
-(void) downloadPhotoWithFileName:(NSString*) fileName completion:(DoneHandler) doneHandler{
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    //用來處理server端respone的機制
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //必須限定支援哪些格式的回傳
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"image/jpeg"];
    //下載圖片所在的網址
    NSString * finalPhotoURLString = [PHOTOS_BASE_URL stringByAppendingPathComponent:fileName];
    
    //    [manager GET:finalPhotoURLString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    //        //downloadProgress用來掌握目前下載的進度
    //        不需要就直接向下面一樣用nil
    //    }
    [manager GET:finalPhotoURLString parameters:nil progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             //成功下載時會帶回結果
             NSLog(@"Download OK: %ld bytes",[responseObject length]);
             doneHandler(nil,responseObject);
             
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             //失敗...
             NSLog(@"Download Fail: %@",error);
             doneHandler(error,nil);
         }];
}
#pragma mark -- Shared Methods
-(void) doPost:(NSString*) urlString
    parameters:(NSDictionary*)parameters
    completion:(DoneHandler) doneHandle{
    
    
    
    
    
    //AFNetwork使用框架
    //parameters 把dictionary內容包成json
    //progress 查看進度用
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //加工一下parameters內容 change parameters to formate: "data=..."
    //NSJSONWritingPrettyPrinted 讓內容易讀 但會增加傳輸速度
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString * jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *finalParameters = @{DATA_KEY:jsonString};
    
    //配合目前使用的server的content-type ，如果不支援會錯誤
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:urlString parameters:finalParameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doPOST ok result:%@",responseObject);
        doneHandle(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"doPOST Error: %@",error);
        doneHandle(error,nil);
        
    }];
    
    
    
    
    
}

-(void) sendPhotoMessageWithData:(NSData *)data completion:(DoneHandler) doneHandler{
    NSDictionary *jsonObj = @{USER_NAME_KEY:MY_NAME,GROUP_NAME_KEY:GROUP_NAME};
    [self doPost:SENDPHOTOMESSAGE_URL parameters:jsonObj data:data completion:doneHandler];
    
}

-(void) doPost:(NSString*) urlString
    parameters:(NSDictionary*)parameters
          data:(NSData*) data
    completion:(DoneHandler) doneHandle{

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //加工一下parameters內容 change parameters to formate: "data=..."
    //NSJSONWritingPrettyPrinted 讓內容易讀 但會增加傳輸速度
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString * jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *finalParameters = @{DATA_KEY:jsonString};
    
    //配合目前使用的server的content-type ，如果不支援會錯誤
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //constructingBodyWithBlock可以透過這方法決定上傳的形式
    [manager POST:urlString parameters:finalParameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data
                                    name:@"fileToUpload"
                                fileName:@".image.jpg"
                                mimeType:@"image/jpg"];
        
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doUpload photo ok result:%@",responseObject);
        doneHandle(nil,responseObject);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doUpload Error: %@",error);
        doneHandle(error,nil);
    }];

}
@end
