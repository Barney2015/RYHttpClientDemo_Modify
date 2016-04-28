//
//  RYApiProxy.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "RYApiProxy.h"
#import "AFNetworking.h"
#import "RYRequestGenerator.h"
#import "RYURLResponse.h"
#import "RYAPILogger.h"
#import "RYNetworkingConfiguration.h"
#import "Aspects.h"
#import "RYBaseAPICmd.h"


#define RYCompletionHandler                                                      \
{                                                                                       \
if (storedSessionDataTask == nil) {    \
    return;   \
} else {      \
    [self.dispatchTable removeObjectForKey:requestId];\
} \
[RYAPILogger logDebugInfoWithResponse:(NSHTTPURLResponse *)response \
                        resposeString:responseObject \
                              request:request  \
                                error:error];  \
RYURLResponse *URLResponse = [[RYURLResponse alloc] initWithResponseString:responseObject requestId:requestId request:request responseData:responseObject status:RYURLResponseStatusSuccess]; \
if (error) {  \
    fail?fail(URLResponse):nil;\
}else {\
    success?success(URLResponse):nil; \
}\
}\

@interface RYApiProxy ()

@property (nonatomic, strong) NSNumber *recordedRequestId;
@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) AFHTTPSessionManager *operationManager;

@end

@implementation RYApiProxy

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static RYApiProxy *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RYApiProxy alloc] init];
    });
    return sharedInstance;
}

- (NSInteger)callGETNormalWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(RYCallback)success fail:(RYCallback)fail
{
    NSMutableURLRequest *request = [[RYRequestGenerator sharedInstance] generateNormalGETRequestWithRequestParams:params url:url serviceIdentifier:serviceIdentifier];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return requestId.integerValue;
}

- (NSInteger)callPOSTNormalWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(RYCallback)success fail:(RYCallback)fail
{
    NSMutableURLRequest *request = [[RYRequestGenerator sharedInstance] generateNormalPOSTRequestWithRequestParams:params url:url serviceIdentifier:serviceIdentifier];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return requestId.integerValue;
}


- (NSInteger)callGETWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(RYCallback)success fail:(RYCallback)fail
{
    NSMutableURLRequest *request = [[RYRequestGenerator sharedInstance] generateGETRequestWithRequestParams:params url:url serviceIdentifier:serviceIdentifier];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return requestId.integerValue;
}

- (NSInteger)callPOSTWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(RYCallback)success fail:(RYCallback)fail
{
    NSMutableURLRequest *request = [[RYRequestGenerator sharedInstance] generatePOSTRequestWithRequestParams:params url:url serviceIdentifier:serviceIdentifier];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return requestId.integerValue;
}

- (NSInteger)callUploadWithParams:(id)params url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier fileURL:(NSString *)fileURL mimeType:(NSString *)mimeType suffixName:(NSString *)suffixName success:(RYCallback)success progress:(RYUploadProgressCallBack)progress fail:(RYCallback)fail {
    
    NSMutableURLRequest *request = [[RYRequestGenerator sharedInstance] generateUploadRequestWithRequestParams:params url:url fileURL:fileURL mimeType:mimeType suffixName:suffixName serviceIdentifier:serviceIdentifier];
    NSNumber *requestId = [self callUploadAPIWithRequest:request success:success progress:progress fail:fail];
    return requestId.integerValue;
    
}

//- (NSInteger)callDownLoadWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier fileURL:(NSString *)fileURL url:(NSString *)url success:(RYCallback)success progress:(RYUploadProgressCallBack)progress fail:(RYCallback)fail {
//    
//}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID
{
    NSURLSessionDataTask *requestSessionDataTask = self.dispatchTable[requestID];
    [requestSessionDataTask cancel];
    [self.dispatchTable removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList
{
    for (NSNumber *requestId in requestIDList) {
        [self cancelRequestWithRequestID:requestId];
    }
}


#pragma mark - private methods

/** 这个函数存在的意义在于，如果将来要把AFNetworking换掉，只要修改这个函数的实现即可。 */
- (NSNumber *)callApiWithRequest:(NSMutableURLRequest *)request success:(RYCallback)success fail:(RYCallback)fail
{
    // 之所以不用getter，是因为如果放到getter里面的话，每次调用self.recordedRequestId的时候值就都变了，违背了getter的初衷
    NSNumber *requestId = [self generateRequestId];
    
    [AFHTTPSessionManager aspect_hookSelector:@selector(trustHostnames) withOptions:AspectPositionInstead usingBlock: ^(id<AspectInfo> info){
        
        NSArray *hostsArray = [@"https://192.168.253.33:452/" componentsSeparatedByString:@":"];
        NSString *hostAllowStr = [hostsArray[1] substringFromIndex:[@"//" length]];
        __autoreleasing NSArray * trustHostnames = @[hostAllowStr];
        
        NSInvocation *invocation = info.originalInvocation;
        [invocation setReturnValue:&trustHostnames];
        
    }error:NULL];
    
    NSURLSessionDataTask *httpRequestSessionDataTask = [self.operationManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSURLSessionDataTask *storedSessionDataTask = self.dispatchTable[requestId];
        
        RYCompletionHandler;
        
    }];
    
    self.dispatchTable[requestId] = httpRequestSessionDataTask;
    
    [httpRequestSessionDataTask resume];
    
    return requestId;
}

- (NSNumber *)callUploadAPIWithRequest:(NSMutableURLRequest *)request success:(RYCallback)success progress:(RYUploadProgressCallBack)progress fail:(RYCallback)fail {
    
    NSNumber *requestId = [self generateRequestId];
    
    //Default setting
    
    NSURLSessionUploadTask * uploadTask = [self.operationManager uploadTaskWithStreamedRequest:request progress:progress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSURLSessionUploadTask *storedSessionDataTask = self.dispatchTable[requestId];
        
        RYCompletionHandler;
    }];
    
    [uploadTask resume];
    
    return requestId;
}

- (NSNumber *)generateRequestId
{
    if (_recordedRequestId == nil) {
        _recordedRequestId = @(1);
    } else {
        if ([_recordedRequestId integerValue] == NSIntegerMax) {
            _recordedRequestId = @(1);
        } else {
            _recordedRequestId = @([_recordedRequestId integerValue] + 1);
        }
    }
    return _recordedRequestId;
}

#pragma mark - getters and setters
- (NSMutableDictionary *)dispatchTable
{
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

- (AFHTTPSessionManager *)operationManager
{
    if (_operationManager == nil) {
        //FIXME://暂时使用默认值，后续优化
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _operationManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        _operationManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        _operationManager.operationQueue.maxConcurrentOperationCount = 10;
        _operationManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _operationManager.requestSerializer.timeoutInterval = kNetworkingTimeoutSeconds;
    }
    return _operationManager;
}

@end
