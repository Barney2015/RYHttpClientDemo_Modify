//
//  RYCookieManager.m
//  RYHttpClientDemo
//
//  Created by wwt on 16/4/29.
//  Copyright © 2016年 RongYu100. All rights reserved.
//

#import "RYCookieManager.h"

#define Cookie_Key            @"SessionCookies"
#define PersistanceQueue_Name "com.RYHttpClient.SavingCookieQueue"

@implementation RYCookieManager

#pragma mark - life cycle

+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    static RYCookieManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[RYCookieManager alloc] init];
    });
    return manager;
}

//本地存储cookies
- (void)storeCookies:(NSArray *)cookies {
    
    [self clearCookiesWithType:RYClearCookieTypeClearLocal];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    dispatch_queue_t persistanceQueue = dispatch_queue_create(PersistanceQueue_Name, NULL);
    
    dispatch_sync(persistanceQueue, ^(void) {
        
        NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:cookies];
        
        if (cookiesData) {
            [defaults setObject:cookiesData forKey: Cookie_Key];
            [defaults synchronize];
        }
    });
    
    [self setCookies];
}

//清除cookies
- (void)clearCookiesWithType:(RYClearCookieType)clearCookieType {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL isDeleteCacheCookie = NO;
    
    if (clearCookieType == RYClearCookieTypeClearCache) {
        isDeleteCacheCookie = YES;
    }else if (clearCookieType == RYClearCookieTypeClearLocal){
        isDeleteCacheCookie = NO;
    }
    
    if (isDeleteCacheCookie) {
        
        if ([defaults objectForKey:Cookie_Key]) {
            
            NSArray *arcCookies = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:Cookie_Key]];
            
            NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            
            for (NSHTTPCookie *cookie in arcCookies){
                [cookieStorage deleteCookie: cookie];
            }
        }
        
    }
    
    [defaults removeObjectForKey:Cookie_Key];
    [defaults synchronize];
    
}

//数据请求设置cookies
- (void)setCookies {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:Cookie_Key]) {
        
        NSArray *arcCookies = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:Cookie_Key]];
        
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        
        for (NSHTTPCookie *cookie in arcCookies){
            [cookieStorage setCookie: cookie];
        }
        
    }
    
}

@end
