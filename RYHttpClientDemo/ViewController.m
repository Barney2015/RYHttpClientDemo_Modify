//
//  ViewController.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/7/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "ViewController.h"
#import "ItemListAPICmd.h"
#import "LoginAPICmd.h"
#import "UploadAPICmd.h"

@interface ViewController ()<APICmdApiCallBackDelegate,APICmdParamSourceDelegate,APICmdParamSourceDelegate,APICmdAspect>

@property (nonatomic,strong) ItemListAPICmd *itemListAPICmd;
//测试
@property (nonatomic,strong) LoginAPICmd *loginAPICmd;
@property (nonatomic,strong) UploadAPICmd *uploadAPICmd;

@property (weak, nonatomic) IBOutlet UITextField *cityPinyin;
@property (weak, nonatomic) IBOutlet UITextView  *responseResult;

- (IBAction)beginRequestAction:(id)sender;


@end

@implementation ViewController

#pragma mark - Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //上传测试
    UIImage *image = [UIImage imageNamed:@"upload.jpg"];
    NSData  *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    [imageData writeToFile:[filePath stringByAppendingString:@"/upload.jpg"] atomically:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - APICmdApiCallBackDelegate

- (void)apiCmdDidSuccess:(RYBaseAPICmd *)baseAPICmd responseData:(id)responseData {
    
}

- (void)apiCmdUploadProcess:(RYBaseAPICmd *)baseAPICmd progress:(NSProgress *)progress {
    NSLog(@"%ld %ld",(long)progress.totalUnitCount,(long)progress.completedUnitCount);
}

- (void)apiCmdDidFailed:(RYBaseAPICmd *)baseAPICmd error:(NSError *)error {
    
}

//@optional
- (void)apiCmdDidSuccess:(RYBaseAPICmd *)baseAPICmd response:(RYURLResponse *)response
{
    //self.responseResult.text = response.contentString;
    
    if (self.uploadAPICmd == baseAPICmd) {
        if (response.content) {
            NSDictionary *contentDict = (NSDictionary *)response.content;
            if (1 == [contentDict[@"Status"] intValue]) {
                NSLog(@"success = %@",contentDict);
            }
        }
    }else {
        //(UPLOAD)
        [self.uploadAPICmd loadData];
    }
    
}

- (void)apiCmdDidFailed:(RYBaseAPICmd *)baseAPICmd errorType:(RYBaseAPICmdErrorType)errorType
{
    
}
#pragma mark APICmdParamSourceDelegate
- (NSDictionary *)paramsForApi:(RYBaseAPICmd *)apiCmd
{
    if (self.loginAPICmd == apiCmd) {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"13312345678",@"userName",@"11",@"password", nil];
    }
    /*
    if (self.itemListAPICmd == apiCmd) {
        return @{@"city":self.cityPinyin.text};
    }
     */
    return nil;
}
#pragma mark APICmdAspect
- (void)apiCmd:(RYBaseAPICmd *)apiCmd request:(NSMutableURLRequest *)request
{
    
}

#pragma mark - event responses
- (IBAction)beginRequestAction:(id)sender {
    if (self.cityPinyin.text.length != 0) {
        //(GET)
        [self.itemListAPICmd loadData];
        //(POST)
        [self.loginAPICmd    loadData];
    }
}
 
#pragma mark - getters

- (ItemListAPICmd *)itemListAPICmd
{
    if (!_itemListAPICmd) {
        _itemListAPICmd = [[ItemListAPICmd alloc] init];
        _itemListAPICmd.delegate    = self;
        _itemListAPICmd.paramSource = self;
        _itemListAPICmd.aspect      = self;
    }
    return _itemListAPICmd;
}

- (LoginAPICmd *)loginAPICmd {
    if (!_loginAPICmd) {
        _loginAPICmd = [[LoginAPICmd alloc] init];
        _loginAPICmd.delegate     = self;
        _loginAPICmd.paramSource  = self;
    }
    return _loginAPICmd;
}

- (UploadAPICmd *)uploadAPICmd {
    if (!_uploadAPICmd) {
        _uploadAPICmd = [[UploadAPICmd alloc] init];
        _uploadAPICmd.delegate     = self;
        _uploadAPICmd.paramSource  = self;
        _uploadAPICmd.mimeType     = @"image/jpeg";
        _uploadAPICmd.suffixName   = @"jpg";
        _uploadAPICmd.fileURL      = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingString:@"/upload.jpg"];
    }
    return _uploadAPICmd;
}

@end
