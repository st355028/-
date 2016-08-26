//
//  ChattingView.h
//  HelloMySendMessage
//
//  Created by MinYeh on 2016/6/23.
//  Copyright © 2016年 MINYEH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChattingItem.h"
@interface ChattingView : UIScrollView


-(void) addChattingItem:(ChattingItem *) item;
@end
