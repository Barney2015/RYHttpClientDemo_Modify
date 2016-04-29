//
//  UploadAPICmd.m
//  RYHttpClientDemo
//
//  Created by wwt on 16/4/29.
//  Copyright © 2016年 RongYu100. All rights reserved.
//

#import "UploadAPICmd.h"


@implementation UploadAPICmd

- (RYBaseAPICmdRequestType)requestType
{
    return RYBaseAPICmdRequestTypeUpload;
}

- (RYBaseAPICmdParametersType)parametersType {
    
    return RYBaseAPICmdParametersTypeNone;
    
}

- (NSString *)methodName
{
    return @"api_v2/CreditApplicationAttachment/UploadFile";
}

- (BOOL)isRequestHook
{
    return YES;
}

@end
