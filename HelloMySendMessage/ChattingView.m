//
//  ChattingView.m
//  HelloMySendMessage
//
//  Created by MinYeh on 2016/6/23.
//  Copyright © 2016年 MINYEH. All rights reserved.
//

#import "ChattingView.h"
#import "ChattingBubbleView.h"
//定義對話框間的距離
#define Y_PADDING 20

@interface ChattingView ()
{
    CGFloat lastChattingBubbleViewY; //用來計算目前對話框的Ｙ軸位置
    NSMutableArray * allChattingItems;
}

@end
@implementation ChattingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)addChattingItem:(ChattingItem *)item{
    
    if(!allChattingItems){
        allChattingItems = [NSMutableArray new];
    }
    
    
    //告訴該顯示什麼內容 及 從哪個點開始
    ChattingBubbleView * bubbleView = [[ChattingBubbleView alloc]initWithItem:item offsetY:lastChattingBubbleViewY + Y_PADDING ];
    [self addSubview:bubbleView];
    
    //更新Y軸位置
    //CGRectGetMaxY可以知道Ｙ軸位置在哪
    lastChattingBubbleViewY = CGRectGetMaxY(bubbleView.frame);
    
    //有多少內容   self.frame.size.width是聊天室的框
    self.contentSize = CGSizeMake(self.frame.size.width,lastChattingBubbleViewY);
    
    //scroll to bottom 捲到最下面
    //scrollRectToVisible 會讓scrollView捲到可以完全顯示你設定的區塊的位置
    //CGRectMake(0, lastChattingBubbleViewY-1, 1, 1) 生成位置在最右下角長出一個1x1的矩形
    [self scrollRectToVisible:CGRectMake(0, lastChattingBubbleViewY-1, 1, 1) animated:true];
    
    //keep the item 備份一份
    [allChattingItems addObject:item];
    
}
@end
