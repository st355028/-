//
//  ChattingItem.h
//  HelloMySendMessage
//
//  Created by MinYeh on 2016/6/23.
//  Copyright © 2016年 MINYEH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum:NSUInteger{
    fromMe,fromOthers
    
} ChattingItemType;


@interface ChattingItem : NSObject

@property(nonatomic,strong) NSString * text;
@property(nonatomic,strong) UIImage * image;
@property (nonatomic,assign) ChattingItemType type;
@end
