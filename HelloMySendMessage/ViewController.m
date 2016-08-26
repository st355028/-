//
//  ViewController.m
//  HelloMySendMessage
//
//  Created by MinYeh on 2016/6/17.
//  Copyright © 2016年 MINYEH. All rights reserved.
//

#import "ViewController.h"
#import "Communucator.h"
#import "AppDelegate.h"
#import "ChattingView.h"
#import <MobileCoreServices/MobileCoreServices.h>  //UTT格式要加
#import "ChatLogManager.h"

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate> //使用ImagePicker要加這兩個協定
{
    Communucator *comm;
    NSMutableArray *incomingMessages; //緩衝區
    NSInteger lastMessageID; //計算最後一筆訊息用
    ChatLogManager *logManager;
    
    BOOL isRefreshing;
    BOOL shouldRefreshAgain;
}
@property (weak, nonatomic) IBOutlet ChattingView *chattingView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    comm = [Communucator sharedInstance];
    incomingMessages = [NSMutableArray new];
    logManager = [ChatLogManager new];
    //Listen to the Notification DID_RECEIVED_REMOTE_NOTIFICATION
    //這段是加入“監聽者”這角色，直到程式結束才會停止監聽
    //object 我只監聽某個物件所發出得通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doRefresh) name:DID_RECEIVED_REMOTE_NOTIFICATION object:nil];
    
    //Load lastMessageID from NSUserDefault
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    lastMessageID = [defaults integerForKey:LAST_MESSAGE_ID_KEY];
    if(lastMessageID == 0){
        lastMessageID =1;
    }
    //測試用
    //lastMessageID = 1;
    
    
   }

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //Show latest log
    NSInteger totalCount = [logManager gettoTalCount];
    NSInteger startIndex = totalCount - 20; //先show 最新20筆
    if(startIndex < 0){
        startIndex = 0;
    }
    for(NSInteger i = startIndex;i<totalCount;i++){
        NSDictionary *tmpMessage = [logManager getMessageByIndex:i];
        [incomingMessages addObject:tmpMessage];
    }
    [self handleIncomingMessages:false];
    //Download when VC is launched 當viewController一載進來就下載
    [self doRefresh];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendTextBtnPressed:(UIButton *)sender {
    //先檢查使用者有沒有輸入內容
    if(_inputTextField.text.length == 0){
        return;
    }
    [_inputTextField resignFirstResponder]; //把鍵盤收起來
    [comm sendTextMessage:_inputTextField.text completion:^(NSError *error, id result) {
        if(error){
            NSLog(@"* Error occur:%@",error);
        }else{
            //Download and Refresh message
            [self doRefresh];
        }
    }];
}

-(void)doRefresh{
    //解決訊息重複發送
    if(isRefreshing == false){
        isRefreshing = true;
    }else{
        shouldRefreshAgain = true;
        return;
    }
    
    
    [comm retriveMessageWithLastMessageID:lastMessageID completion:^(NSError *error, id result) {
        if(error){
            NSLog(@"* Error occur:%@",error);
            isRefreshing = false;
        }else{
           // Handle incoming message
            NSArray *messages = result[MESSAGES_KEY];
            
            if(messages.count == 0){
                //如果裡面沒資料時 代表裡面沒有新資料
                NSLog(@"No new Message");
                isRefreshing = false;
                return ;
            }
            
            //keep lastMessageID
            NSDictionary * lastMessage = messages.lastObject;
            lastMessageID = [lastMessage[ID_KEY] integerValue];
            
            //save lastMessageID to NSUserDefault
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:lastMessageID forKey:LAST_MESSAGE_ID_KEY];
            [defaults synchronize];
            
            [incomingMessages addObjectsFromArray:messages];
            
            [self handleIncomingMessages:true];
        }

    }];
}

-(void) handleIncomingMessages:(BOOL)shouldSavaToLog{
    //沒有訊息要處理時則跳出
    if (incomingMessages.count == 0) {
        isRefreshing = false;
        
        if(shouldRefreshAgain){
            shouldRefreshAgain = false;
            [self doRefresh];
        }
        return;
    }
    
    NSDictionary * tmpMessage = incomingMessages.firstObject;
    [incomingMessages removeObjectAtIndex:0];
    
    //Add to logManager
    if(shouldSavaToLog)
        [logManager addChatLog:tmpMessage];
    
    NSInteger messageID = [tmpMessage[ID_KEY]integerValue];
    NSInteger messageType = [tmpMessage[TYPE_KEY] integerValue];
    NSString * senderName = tmpMessage[USER_NAME_KEY];
    NSString * message = tmpMessage[MESSAGE_KEY];
    if (messageType == 0) {
        //Text
        NSString * displayMessge = [NSString stringWithFormat:@"%@: %@ (%ld)",senderName,message,(long)messageID];
        
        //Decide it is
        ChattingItem * item = [ChattingItem new];
        item.text = displayMessge;
        if ([senderName isEqualToString:MY_NAME]) {
            item.type = fromMe;
        }else{
            item.type = fromOthers;
        }
        [_chattingView addChattingItem:item];
        
        //Move to next message
        [self handleIncomingMessages:shouldSavaToLog];
        
    }else{
        
        //Image
        UIImage * image = [ChatLogManager loadPhotoWithFileName:message];
        
        if(image!= nil){
            //photo is cached,use it directly. 如果本機端有cache就直接使用
            NSString * displayMessge = [NSString stringWithFormat:@"%@: %@ (%ld)",senderName,message,(long)messageID];
            
            [self addChatItemWithMessage:displayMessge image:image sender:senderName];

        }else{
            //Need to load from server.
        
        [comm downloadPhotoWithFileName:message completion:^(NSError *error, id result) {
            
            if (error) {
                NSLog(@"* Error occur: %@",error);
                //Show Error Message to User..
            }else{
                NSString * displayMessge = [NSString stringWithFormat:@"%@: %@ (%ld)",senderName,message,(long)messageID];
                

                [self addChatItemWithMessage:displayMessge image:[UIImage imageWithData:result] sender:senderName];
            }
            
            //Move to next message,等到圖片下載完成之後才去處理文字
            [self handleIncomingMessages:shouldSavaToLog];
        }];
        }
        
    }
    
}
-(void) addChatItemWithMessage:(NSString*)message image:(UIImage*) image sender:(NSString*) senderName{
    //Decide it is
    ChattingItem * item = [ChattingItem new];
    item.text = message;
    if ([senderName isEqualToString:MY_NAME]) {
        item.type = fromMe;
    }else{
        item.type = fromOthers;
    }
    item.image = image;
    [_chattingView addChattingItem:item];

}
- (IBAction)sendPhotoBtnPressed:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose Image" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self launchImahePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }];

    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self launchImahePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:camera];
    [alert addAction:library];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];
}

-(void) launchImahePickerWithSourceType:(UIImagePickerControllerSourceType) sourceType{
    
    //檢查硬體裝置是否支援相機功能
    if([UIImagePickerController isSourceTypeAvailable:sourceType] == false){
        NSLog(@"Invalid Source Type");
        return;
    }
    
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.sourceType = sourceType; //指定type
    imagePicker.mediaTypes = @[@"public.image"]; //多媒體來源的種類，目前只支援照片，若要支援影片 加 @"public.movie"
    //imagePicker.mediaTypes = @[(NSString*)kUTTypeImage]; 使用ＵＴＴ格式的寫法，意義等同於上面那段
    imagePicker.delegate = self; //指定代理人給自己
    [self presentViewController:imagePicker animated:true completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //會接收傳回來的結果，要記得加下面這段釋放拍照畫面或相簿的viewController
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if([mediaType isEqualToString:@"public.image"]){
        UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
        
        //壓縮照片
        UIImage *resizeImage = [self resizeWithImage:originalImage];
        
        
        //因為使用相機會被自動轉成UIIMAGE，所以要轉成圖檔;0.7是解析度 0最低 1最高 但檔案大小成負相關
        NSData *imageData = UIImageJPEGRepresentation(resizeImage,0.7);
        
        NSLog(@"Image Size: %f x %f,File Size: %ld",originalImage.size.width,originalImage.size.height,imageData.length);
        
        [comm sendPhotoMessageWithData:imageData completion:
          ^(NSError *error, id result) {
              if(error){
                  NSLog(@"* Error occur: %@",error);
              }else{
                  [self doRefresh];
              }
          }];
    }
    
    [picker dismissViewControllerAnimated:true completion:nil];
}

-(UIImage*) resizeWithImage:(UIImage*) srcImage{
    CGFloat maxLength = 1024.0;
    //No need to resize. use original image
    if(srcImage.size.width <= maxLength && srcImage.size.height<= maxLength){
        return srcImage;
    }
    
    
    CGSize targetSize;
    //當寬大於高時
    if(srcImage.size.width >= srcImage.size.height){
        CGFloat ratio = srcImage.size.width / maxLength; // 原始除1024的倍率
        targetSize = CGSizeMake(maxLength, srcImage.size.height/ratio);
    }else{
        if (srcImage.size.width >= srcImage.size.height) {
            CGFloat ratio = srcImage.size.width / maxLength;
            targetSize = CGSizeMake(maxLength, srcImage.size.height/ratio);
        }else{
            CGFloat ratio = srcImage.size.height / maxLength;
            targetSize = CGSizeMake(srcImage.size.width/ratio, maxLength);
        }
    }
    //Resize the srcImage as targetSize
    UIGraphicsBeginImageContext(targetSize);//系統會在記憶體產生一塊虛擬畫布
    
    //把原始圖片畫在設定為targetSize尺寸的畫布上
    [srcImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    
    //Draw Frame 為照片加入圖框（可不必寫）
    UIImage *frameImage = [UIImage imageNamed:@"frame_01.png"];
    //在呼叫drawInRect會把畫疊在上一張畫布上
    [frameImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext(); //縮圖作業完成後必須加這段，才會釋放掉記憶體畫布的記憶體
    
    return resultImage;
}

@end
