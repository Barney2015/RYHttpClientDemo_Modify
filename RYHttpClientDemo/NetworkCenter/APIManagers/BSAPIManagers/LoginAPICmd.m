//
//  LoginAPICmd.m
//  RYHttpClientDemo
//
//  Created by wwt on 16/4/29.
//  Copyright © 2016年 RongYu100. All rights reserved.
//

#import "LoginAPICmd.h"

@implementation LoginAPICmd

- (RYBaseAPICmdRequestType)requestType
{
    return RYBaseAPICmdRequestTypePost;
}

- (RYBaseAPICmdParametersType)parametersType {
    
    return RYBaseAPICmdParametersTypeParam;
    
}

- (NSString *)methodName
{
    return @"API/User/OnLogon";
}

- (BOOL)isRequestHook
{
    return YES;
}

@end
