//
//  RYRequestGenerator.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "RYRequestGenerator.h"
#import "AFNetworking.h"
#import "RYBaseAPICmd.h"
#import "RYServiceFactory.h"
#import "RYAPILogger.h"
#import "NSURLRequest+RYNetworkingMethods.h"

@interface RYRequestGenerator ()

@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;

@end

@implementation RYRequestGenerator
#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static RYRequestGenerator *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RYRequestGenerator alloc] init];
    });
    return sharedInstance; 
}

- (NSMutableURLRequest *)generateGETRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier
{
    RYService *service = [[RYServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",service.apiBaseUrl,url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kNetworkingTimeoutSeconds];
    request.HTTPMethod = @"GET";
    NSDictionary *restfulHeader = [self commRESTHeadersWithService:service];
    [restfulHeader enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    request.requestParams = requestParams;
    [RYAPILogger logDebugInfoWithRequest:request apiName:url service:service requestParams:requestParams httpMethod:@"GET"];
    return request;
}
- (NSMutableURLRequest *)generatePOSTRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier
{
    RYService *service = [[RYServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",service.apiBaseUrl,url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kNetworkingTimeoutSeconds];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestParams options:NSJSONWritingPrettyPrinted error:NULL];
    NSDictionary *restfulHeader = [self commRESTHeadersWithService:service];
    [restfulHeader enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    request.requestParams = requestParams;
    [RYAPILogger logDebugInfoWithRequest:request apiName:url service:service requestParams:requestParams httpMethod:@"POST"];
    return request;
}

- (NSMutableURLRequest *)generateUploadRequestWithRequestParams:(id)requestParams url:(NSString *)url fileURL:(NSString *)fileURL mimeType:(NSString *)mimeType suffixName:(NSString *)suffixName serviceIdentifier:(NSString *)serviceIdentifier{
    
    NSMutableURLRequest *request = [self.httpRequestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:requestParams constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //suffixName 需要后缀名，否则服务器无法识别
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:fileURL] name:@"file" fileName:[NSString stringWithFormat:@"fileName.%@",suffixName] mimeType:mimeType error:nil];
    } error:nil];
    request.timeoutInterval = kNetworkingTimeoutSeconds;
    
    return request;
}

//- (NSMutableURLRequest *)generateDownloadRequestWithRequestParams:(id)requestParams fileURL:(NSString *)fileURL url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier;

- (NSMutableURLRequest *)generateNormalGETRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier
{
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"GET" URLString:url parameters:nil error:NULL];
    request.timeoutInterval = kNetworkingTimeoutSeconds;
    request.requestParams = requestParams;
    return request;
}

- (NSMutableURLRequest *)generateNormalPOSTRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier
{
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"POST" URLString:url parameters:requestParams error:NULL];
    request.timeoutInterval = kNetworkingTimeoutSeconds;
    request.requestParams = requestParams;
    return request;
}
#pragma mark - private methods
- (NSDictionary *)commRESTHeadersWithService:(RYService *)service
{
    NSMutableDictionary *headerDic = [[NSMutableDictionary alloc] init];
    if (service.cookis.count != 0) {
        //FIXME:有问题
        [headerDic addEntriesFromDictionary:service.cookis];
    }
    
//    [headerDic setValue:service.privateKey  forKey:@"apikey"];
    [headerDic setValue:@"application/json" forKey:@"Accept"];
    [headerDic setValue:@"application/json" forKey:@"Content-Type"];
    
    return headerDic;
}

#pragma mark - getters and setters
- (AFHTTPRequestSerializer *)httpRequestSerializer
{
    if (_httpRequestSerializer == nil) {
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        _httpRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return _httpRequestSerializer;
}

@end
