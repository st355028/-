//
//  ChatLogManager.h
//  HelloMySendMessage
//
//  Created by MinYeh on 2016/6/24.
//  Copyright © 2016年 MINYEH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ChatLogManager : NSObject

+(void) savePhotoWithFileName :(NSString*) originalFileName data:(NSData*)data;

+(UIImage*) loadPhotoWithFileName: (NSString*)originalFileName;

-(void) addChatLog:(NSDictionary *)messageDictionary;

-(NSInteger) gettoTalCount;

-(NSDictionary *) getMessageByIndex:(NSInteger)index;
@end
