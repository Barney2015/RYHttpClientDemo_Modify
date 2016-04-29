//
//  RYCookieManager.h
//  RYHttpClientDemo
//
//  Created by wwt on 16/4/29.
//  Copyright © 2016年 RongYu100. All rights reserved.
//

#import <Foundation/Foundation.h>

//清除Cookie方式
typedef NS_ENUM(NSUInteger, RYClearCookieType) {
    RYClearCookieTypeClearCache,    //清除缓存Cookie
    RYClearCookieTypeClearLocal     //清除本地Cookie
};

//Cookie管理类
@interface RYCookieManager : NSObject

+ (instancetype)manager;

//本地存储cookies
- (void)storeCookies:(NSArray *)cookies;
//清除cookies
- (void)clearCookiesWithType:(RYClearCookieType)clearCookieType;
//数据请求设置cookies
- (void)setCookies;


@end
