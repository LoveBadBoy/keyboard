//
//  keyboardViewController.m
//  keyboard
//
//  Created by 赵宏 on 16/8/23.
//  Copyright © 2016年 赵宏. All rights reserved.
//

#import "keyboardViewController.h"
#import "HPGrowingTextView.h"
//#import "ZYQAssetPickerController.h"
@interface keyboardViewController ()
@property (weak, nonatomic) IBOutlet UIView *chatView;
@property (weak, nonatomic) IBOutlet UIImageView *addImgBtn;
- (IBAction)faceBtn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *faceBtn;
@property (assign,nonatomic)BOOL isSender;
@property (assign,nonatomic)BOOL isSendimg;
@property(strong,nonatomic)UIView *addImgView;

@property(strong,nonatomic)HPGrowingTextView *chatTextField;
@property(strong,nonatomic)UIView *faceView;
@property (strong, nonatomic)NSMutableArray *chatcontentArray;
@property(strong,nonatomic)UIScrollView* scrollView;
@property(strong,nonatomic)UIImageView *imgFromAlbumBtn;
@property(strong,nonatomic)UIImageView *imgFromCameraBtn;
@end
#define mainScreenWidth             [UIScreen mainScreen].bounds.size.width
#define mainScreenheight            [UIScreen mainScreen].bounds.size.height
@implementation keyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    _faceView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, mainScreenWidth, 170)];
    _scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, mainScreenWidth, 140)];
    for (int i=0; i<3; i++) {
        UIView* face=[[UIView alloc] initWithFrame:CGRectMake(mainScreenWidth*i, 0,mainScreenWidth, 140)];
        for (int j=0; j<3; j++) {
            //column numer
            for (int k=0; k<7; k++) {
                UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
                
                button.tag=j*7+k+(i*21)+1;
                NSString *imageName;
                if(button.tag==21||button.tag==42||button.tag==63)
                {
                    [button setImage:[UIImage imageNamed:@"emoji_delete.png"] forState:UIControlStateNormal];
                    [button setFrame:CGRectMake(0+k*mainScreenWidth/7, 0+j*45, 45, 45)];
                }
                else
                {
                    imageName=[NSString stringWithFormat:@"%zd.png",button.tag];
                    [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
                    [button setFrame:CGRectMake(10+k*mainScreenWidth/7, 10+j*45, 25, 25)];
                }
                [button setBackgroundColor:[UIColor clearColor]];
                [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
                face.backgroundColor=[UIColor whiteColor];
                [face addSubview:button];
            }
        }
        [_scrollView addSubview:face];
    }
    _scrollView.contentSize=CGSizeMake(mainScreenWidth*3, 140);
    _scrollView.delegate=self;
    _scrollView.pagingEnabled=YES;
    _scrollView.bounces=NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _faceView.backgroundColor = [UIColor colorWithRed:228/255.0 green:227/255.0 blue:220/255.0 alpha:1.0];
    [_faceView addSubview:_scrollView];
    UIButton* sendBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    sendBtn.frame=CGRectMake(mainScreenWidth-50-10, 143, 50, 25);
    [sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    
    sendBtn.titleLabel.font=[UIFont systemFontOfSize:12];
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"input_circle_bg.png"] forState:UIControlStateNormal];
    [_faceView addSubview:sendBtn];
    [self.view addSubview:_faceView];
    _faceView.hidden=YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    _chatTextField=[[HPGrowingTextView alloc] initWithFrame:CGRectMake(70, 6, mainScreenWidth - 108, _chatView.frame.size.height - 12)];
    _chatTextField.isScrollable = YES;
    _chatTextField.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    _chatTextField.backgroundColor=[UIColor colorWithRed:228/255.0 green:227/255.0 blue:220/255.0 alpha:1.0];
    _chatTextField.minNumberOfLines = 1;
    _chatTextField.maxNumberOfLines = 3;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    _chatTextField.returnKeyType = UIReturnKeyDone; //just as an example
    _chatTextField.font = [UIFont systemFontOfSize:15.0f];
    _chatTextField.delegate = self;
    _chatTextField.layer.cornerRadius=6.0;
    _chatTextField.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    [self.chatView addSubview:_chatTextField];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chatAddImage)];
    [self.addImgBtn setUserInteractionEnabled:YES];
    [self.addImgBtn addGestureRecognizer:gesture];
    _addImgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainScreenWidth, 170)];
    _addImgView.backgroundColor = [UIColor whiteColor];
    _imgFromAlbumBtn = [[UIImageView alloc] initWithFrame:CGRectMake(mainScreenWidth/4 - 30, 50, 40, 40)];
    _imgFromCameraBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0.75*mainScreenWidth-30, 50, 40, 40)];
    
    UILabel *albumLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainScreenWidth/4 - 30, 95, 40, 15)];
    UILabel *cameraLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.75*mainScreenWidth - 30, 95, 40, 15)];
    [albumLabel setText:@"相册"];
    albumLabel.textAlignment = NSTextAlignmentCenter;
    [albumLabel setTextColor:[UIColor darkGrayColor]];
    [albumLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [cameraLabel setText:@"拍照"];
    [cameraLabel setFont:[UIFont systemFontOfSize:15.0f]];
    cameraLabel.textAlignment = NSTextAlignmentCenter;
    [cameraLabel setTextColor:[UIColor darkGrayColor]];
    UITapGestureRecognizer *ablumGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getChatImgFromAlbum)];
    UITapGestureRecognizer *cameraGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getChatImgFromCamera)];
    
    [_imgFromAlbumBtn setUserInteractionEnabled:YES];
    [_imgFromCameraBtn setUserInteractionEnabled:YES];
    [_imgFromCameraBtn addGestureRecognizer:cameraGesture];
    [_imgFromAlbumBtn addGestureRecognizer:ablumGesture];
    [_imgFromAlbumBtn setImage:[UIImage imageNamed:@"手机照片"]];
    [_imgFromCameraBtn setImage:[UIImage imageNamed:@"相机拍照"]];
    [_addImgView addSubview:_imgFromCameraBtn];
    [_addImgView addSubview:_imgFromAlbumBtn];
    [_addImgView addSubview:albumLabel];
    [_addImgView addSubview:cameraLabel];
    
    [self.view addSubview:_addImgView];
    [_addImgView setHidden:YES];
}
// 私信添加图片
-(void)chatAddImage{
    _isSendimg = !_isSendimg;
    _faceView.hidden = YES;
    _isSender = NO;
    if( _addImgView.hidden )
    {
        [_chatTextField resignFirstResponder];
        _faceView.hidden = YES;
        _addImgView.hidden = NO;
        CGRect r = _chatView.frame;
        r.origin.y = mainScreenheight - 170 - r.size.height;
        _chatView.frame = r;
        [_addImgView setFrame:CGRectMake(0, mainScreenheight-170,mainScreenWidth, 170)];
        

        if(_chatcontentArray.count!=0)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.chatcontentArray count] - 1 inSection:0];
        }
        return;
    }
    else
    {
        _addImgView.hidden = YES;
        [_chatTextField becomeFirstResponder];
    }
}
// 从相册选择
-(void)getChatImgFromAlbum{
//    
    ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
    picker.maximumNumberOfSelection = 1;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.showEmptyGroups=NO;
    picker.delegate = self;
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
            NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
            return duration >= 5;
        } else {
            return YES;
        }
    }];
    [self presentViewController:picker animated:YES completion:NULL];
    NSLog(@"相册选取");
}
// 拍照上传
-(void)getChatImgFromCamera{
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    [imgPicker setAllowsEditing:YES];
    [imgPicker setDelegate:self];
    [imgPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
//    [self.navigationController presentViewController:imgPicker animated:YES completion:nil];
    [self presentModalViewController:imgPicker animated:YES];//进入照相界面

    NSLog(@"拍照上传");

}
#pragma mark - ZYQAssetPickerControllerDelegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
//    for (NSInteger i = 0; i < assets.count; i++) {
//        ALAsset *asset = assets[i];
//        UIImage *tempImg = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
//        // 从相册得到图片
//        [self sendImageMsg:tempImg];
//    }
    NSLog(@"相册成功");
}
#pragma mark - UIImagePickerDelegate
// 成功获得相片还是视频后的回调 UIImagePickerController
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
//    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
//    {
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//    }
    [picker dismissViewControllerAnimated:YES completion:nil];
//    // 从相机获得照片
//    [self sendImageMsg:image];
    NSLog(@"相机成功");
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    return;
}




- (BOOL)growingTextView:(HPGrowingTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if([self.chatTextField.text length] == 0){
            return NO;
        }
        self.chatTextField.text = @"";
        
        return NO;
    }
    return YES;
}
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    NSLog(@"123");
    CGRect r = _chatView.frame;
    
    if ((growingTextView.frame.size.height-r.size.height+12)!=0) {
        r.origin.y = r.origin.y - (growingTextView.frame.size.height-r.size.height+12) ;
        r.size.height = growingTextView.frame.size.height + 12;

        _chatView.frame = r;
    }else if ((growingTextView.frame.size.height-r.size.height+12)>0&&(growingTextView.frame.size.height-r.size.height+12)<20)
    {
        r.origin.y = r.origin.y-(growingTextView.frame.size.height-r.size.height+12) ;
        r.size.height = growingTextView.frame.size.height + 12;

        _chatView.frame = r;
    }

    
}

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}
// 删除的方案
-(void)selected:(UIButton*)btn
{
    NSString *str;
    NSString *path=[[NSBundle mainBundle]pathForResource:@"face.plist" ofType:nil];
    NSDictionary *dic=[[NSDictionary alloc]initWithContentsOfFile:path];
    NSArray* allKeys=[dic allKeys];
    NSString* imageStr;
    str=[NSString stringWithFormat:@"emoji_%zd.png",btn.tag];
    if(btn.tag==21||btn.tag==42||btn.tag==63)
    {
        if(self.chatTextField.text.length>0)
        {
            NSMutableString* oldStr1=[[NSMutableString alloc] initWithString:self.chatTextField.text];
            NSArray* strArr1=[oldStr1 componentsSeparatedByString:@"["];
            NSMutableArray* strArr2=[[NSMutableArray alloc] init];
            for(NSString* str in strArr1)
            {
                NSArray* arr=[str componentsSeparatedByString:@"]"];
                [strArr2 addObjectsFromArray:arr];
                for(NSString* str1 in strArr2)
                {
                    if(str1==nil||[str1 isEqual:@""])
                    {
                        [strArr2 removeObject:str1];
                    }
                }
            }
            NSString* appendStr=[NSString stringWithFormat:@"[%@]",[strArr2 lastObject]];
            int keySum=0;
            for(NSString* key in allKeys)
            {
                if([appendStr isEqualToString:key])
                {
                    keySum++;
                }
            }
            if(keySum!=0&&[self.chatTextField.text hasSuffix:@"]"])
            {
                NSString* newString=[self.chatTextField.text substringWithRange:NSMakeRange(0, self.chatTextField.text.length-appendStr.length)];
                self.chatTextField.text=newString;
            }
            else
            {
                NSString * newString = [self.chatTextField.text substringWithRange:NSMakeRange(0, [self.chatTextField.text length] - 1)];
                self.chatTextField.text=newString;
            }
        }
    }
    for(NSString* key in allKeys)
    {
        if([str isEqualToString:[dic objectForKey:key]])
        {
            imageStr=[NSString stringWithFormat:@"%@",key];
        }
    }
    if(imageStr==nil)
    {
        self.chatTextField.text = self.chatTextField.text;
    }
    else
    {
        self.chatTextField.text=[self.chatTextField.text stringByAppendingString:imageStr];
    }
}
-(void)sendBtnClick:(UIButton*)sender
{
    if([self.chatTextField.text length] == 0)
    {
        return;
    }
//    [self didSendTextMsg:self.chatTextField.text];
    self.chatTextField.text = @"";
}
#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    [_chatTextField becomeFirstResponder];
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:keyboardRect fromView:[[UIApplication sharedApplication] keyWindow]];
    // 获得键盘高度
    CGFloat keyboardHeight = keyboardFrame.size.height;
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         
                         // get a rect for the textView frame
                         CGRect containerFrame = _chatView.frame;
                         
                         containerFrame.origin.y = mainScreenheight-containerFrame.size.height-keyboardHeight;
                         _chatView.frame = containerFrame;
                         

                         

                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (_faceView.hidden == NO) {
        _faceView.hidden = YES;
    }
    if (_addImgView.hidden == NO) {
        _addImgView.hidden = YES;
    }
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         
                         CGRect containerFrame = _chatView.frame;
                         // containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
                         // _chatView.frame = containerFrame;
                         
                         // CGRect frame = self.chatView.frame;
                         containerFrame.origin.y = mainScreenheight - containerFrame.size.height;
                         self.chatView.frame = containerFrame;
                         
                         
                     }];
}
- (IBAction)down_keyboard:(id)sender {
    // CGRect containerFrame = _chatView.frame;
    // containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    // _chatView.frame = containerFrame;
    
    CGRect frame = self.chatView.frame;
    frame.origin.y = mainScreenheight - self.chatView.frame.size.height;
    self.chatView.frame = frame;
    
    if(_chatcontentArray.count!=0)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.chatcontentArray count] - 1 inSection:0];
    }
    
    _faceView.hidden=YES;
    _addImgView.hidden = YES;
    [self.chatTextField resignFirstResponder];
}
- (IBAction)faceBtn:(UIButton *)sender {
    if (_faceView.hidden) {
        [self.chatTextField resignFirstResponder];
        _addImgView.hidden = YES;
        _faceView.hidden=NO;
        CGRect r = _chatView.frame;
        r.origin.y = mainScreenheight-170-r.size.height;
        _chatView.frame = r;
        [_faceView setFrame:CGRectMake(0, mainScreenheight-170,mainScreenWidth, 170)];
    }else
    {     _faceView.hidden=YES;
        [_chatTextField becomeFirstResponder];

        
    }

    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
