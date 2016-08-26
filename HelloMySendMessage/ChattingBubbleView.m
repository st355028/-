//
//  ChattingBubbleView.m
//  HelloMySendMessage
//
//  Created by MinYeh on 2016/6/23.
//  Copyright © 2016年 MINYEH. All rights reserved.
//

#import "ChattingBubbleView.h"


//Constants of UI layout
#define SIDE_PADDING_RATE       0.02//每個泡泡跟螢幕的邊緣距離,0.02是代表2%的比例
#define MAX_BUBBLE_WIDTH_RATE   0.7 //對話框最寬就佔螢幕70%
#define CONTENT_MARGIN          10.0//對話框內的文字跟框距離10px
#define BUBBLE_TALE_WIDTH       10.0//定義泡泡框的尾巴跟螢幕框距離
#define TEXT_FONT_SIZE          16.0//文字的字體大小
@interface ChattingBubbleView(){
    //Subviews
    UIImageView * chattingImageView;
    UILabel * chattingLabel;
    UIImageView * backgroundImageView;
}
@end


@implementation ChattingBubbleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithItem:(ChattingItem*) item offsetY:(CGFloat) offsetY{
    
    //step1: Caculate a basic frame
    self = [super initWithFrame:CGRectZero];
    self.frame = [self calculateBasicFrame:item.type offsetY:offsetY];
    //step2: Caculate with Image
    CGFloat currentY = 0.0;
    
    UIImage *image = item.image;
    if(image != nil){
        CGFloat x = CONTENT_MARGIN;
        CGFloat y = CONTENT_MARGIN;
        
        if(item.type == fromMe){
            x += BUBBLE_TALE_WIDTH;
        }
        
        //決定圖片顯示的寬 MIN(兩個數值比，誰比較小就選誰)
        CGFloat displayWidth = MIN(image.size.width,self.frame.size.width - 2* CONTENT_MARGIN - BUBBLE_TALE_WIDTH);
        //先算出寬的照片實際比例
        CGFloat displayRatio = displayWidth / image.size.width;
        
        CGFloat displayHeight = image.size.height * displayRatio;
        
       
        
        CGRect displayFrame = CGRectMake(x, y, displayWidth, displayHeight);
        
        //Prepare chattingImageView
        chattingImageView = [[UIImageView alloc] initWithFrame:displayFrame];
        
        chattingImageView.image = image;
        chattingImageView.layer.cornerRadius = 5.0;
        //有東西超出對話框圓角的話會切掉
        chattingImageView.layer.masksToBounds = true;
        
        [self addSubview:chattingImageView];
        
        currentY = CGRectGetMaxY(displayFrame);
    }
    //step3: Caculate with Text
    NSString *text = item.text;
    if(text != nil){
        CGFloat x = CONTENT_MARGIN;
        CGFloat y = currentY + TEXT_FONT_SIZE/2;
        if(item.type == fromOthers){
            x += BUBBLE_TALE_WIDTH;
        }
        
        CGRect displayFrame = CGRectMake(x, y, self.frame.size.width -2 * CONTENT_MARGIN - BUBBLE_TALE_WIDTH, TEXT_FONT_SIZE);
        //Create Lable
        chattingLabel = [[UILabel alloc] initWithFrame:displayFrame];
        
        chattingLabel.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
        //自動調整高度
        chattingLabel.numberOfLines = 0;
        chattingLabel.text = text;
        [chattingLabel sizeToFit];
        
        [self addSubview:chattingLabel];
        
        currentY = CGRectGetMaxY(chattingLabel.frame);
    }
    //step4: Caculate bubble view size
    CGFloat finalHeight = currentY + CONTENT_MARGIN;
    CGFloat finalWidth = 0.0;
    if(chattingImageView != nil){
        finalWidth = CGRectGetMaxX(chattingImageView.frame) + CONTENT_MARGIN +BUBBLE_TALE_WIDTH;
    }else{
        //fromOthers
        finalWidth = CGRectGetMaxX(chattingImageView.frame) + CONTENT_MARGIN;
    }
    
    if(chattingLabel != nil){
      CGFloat labelWidth = 0;
        if(item.type == fromMe){
            labelWidth = CGRectGetMaxX(chattingLabel.frame) + CONTENT_MARGIN +BUBBLE_TALE_WIDTH;
        }else{
        //fromOthers
            labelWidth = CGRectGetMaxX(chattingLabel.frame) + CONTENT_MARGIN;
        }
        finalWidth = MAX(finalWidth,labelWidth);
    }
    
    CGRect selfFrame = self.frame;
    
    if(item.type == fromMe && chattingImageView == nil){
        selfFrame.origin.x += selfFrame.size.width - finalWidth;
    }
    
    selfFrame.size.width = finalWidth;
    selfFrame.size.height = finalHeight;
    self.frame = selfFrame;

    //step5: Handle background display
    [self prepareBackgroundImageView:item.type];
    
    return self;
}
-(void) prepareBackgroundImageView:(ChattingItemType) type{
    CGRect bgImageViewFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    backgroundImageView = [[UIImageView alloc]initWithFrame:bgImageViewFrame];
    
    if(type == fromMe){
        UIImage * image = [UIImage imageNamed:@"fromMe.png"];
        //resizableImageWithCapInsets重複延伸圖片（連續圖效果）
        //UIEdgeInsetsMake 定義上左下右的邊界固定，這樣就只會有中間，然後就會從那開始延伸
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 17, 28) ];
        backgroundImageView.image = image;
    }else{
        UIImage *image = [UIImage imageNamed:@"fromOthers.png"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(14, 22, 17, 20) ];
        backgroundImageView.image = image;
    }
    [self addSubview:backgroundImageView];
    //讓背景圖跑到最下層
    [self sendSubviewToBack:backgroundImageView];
}
-(CGRect) calculateBasicFrame:(ChattingItemType)type offsetY:(CGFloat)offsetY{
    //拿螢幕的框（假設聊天室框跟螢幕一樣框的前提下是正確的）
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    //算出泡泡框距離螢幕實際距離
    CGFloat sidePadding = screenWidth * SIDE_PADDING_RATE;
    //算出泡泡框的最大寬是多少
    CGFloat MaxWidth = screenWidth * MAX_BUBBLE_WIDTH_RATE;
    
    CGFloat offsetX;
    
    if(type == fromMe){
        offsetX = screenWidth - sidePadding - MaxWidth;
    }else{
        //fromOthers
        offsetX = sidePadding;
    }
    
    return CGRectMake(offsetX, offsetY, MaxWidth, 10);
}
@end
