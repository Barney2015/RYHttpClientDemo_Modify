//
//  RYBaseAPICmd.swift
//  SwiftRYHttpClientDemo
//
//  Created by wwt on 16/4/29.
//  Copyright © 2016年 rongyu. All rights reserved.
//

import UIKit

@objc
public enum RYBaseAPICmdRequestType: Int {
    
    case RYBaseAPICmdRequestTypeGet
    case RYBaseAPICmdRequestTypePost
    case RYBaseAPICmdRequestTypeGetNormal
    case RYBaseAPICmdRequestTypePostNormal
    case RYBaseAPICmdRequestTypeUpload
    case RYBaseAPICmdRequestTypeDownLoad
    
}

//请求参数设置方式
@objc
public enum RYBaseAPICmdParametersType: Int {
    
    case RYBaseAPICmdParametersTypeNone     //无请求参数
    case RYBaseAPICmdParametersTypeURL      //请求参数以&方式拼接在请求URL中
    case RYBaseAPICmdParametersTypeParam     //请求参数以参数值的方式请求
    
}

@objc
public enum RYBaseAPICmdErrorType: Int {
    
    case RYBaseAPICmdErrorTypeDefault       //没有产生过API请求，这个是manager的默认状态。
    case RYBaseAPICmdErrorTypeTimeout       //请求超时。设置的是20秒超时。
    case RYBaseAPICmdErrorTypeNoNetWork     //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
    case RYAPIManagerErrorTypeNoContent     //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
}

/*************************************************************************************************/
 /*                                         RTAPIManager                                          */
 /*************************************************************************************************/
 /*
 RYBaseAPICmd的派生类必须符合这些protocal
 */

@objc
public protocol RYBaseAPICmdDelegate {
    
    func requestType()    -> RYBaseAPICmdRequestType
    func parametersType() -> RYBaseAPICmdParametersType
    
    optional func apiCmdDescription() -> String
    optional func methodName()        -> String
    optional func serviceType()       -> String
    optional func isCacelRequest()    -> Bool
    optional func isRequestHook()     -> Bool
    //验证返回的数据格式是否正确
    optional func jsonValidator()     -> AnyObject
}

@objc
public protocol APICmdApiCallBackDelegate {
    
    func apiCmdDidSuccess(baseAPICmd: RYBaseAPICmd,responseData: AnyObject) -> Void
    func apiCmdUploadProcess(baseAPICmd: RYBaseAPICmd, progress: NSProgress) -> Void
    func apiCmdDidFailed(baseAPICmd: RYBaseAPICmd, error: NSError) -> Void
    
    optional func apiCmdDidSuccess(baseAPICmd: RYBaseAPICmd, response: RYURLResponse) -> Void
    optional func apiCmdDidFailed(baseAPICmd: RYBaseAPICmd, errorType: RYBaseAPICmdErrorType) -> Void
    
}

@objc
public protocol APICmdParamSourceDelegate {
    
    func paramsForApi(apiCmd: RYBaseAPICmd) -> Dictionary<String, AnyObject>
    
}

/*************************************************************************************************/
 /*                                    APIManagerInterceptor                                      */
 /*************************************************************************************************/
 /*
 APIBaseManager的派生类必须符合这些protocal
 拦截器
 
 */

@objc
public protocol APICmdInterceptor {
    
    optional func apiCmdStartLoadData(apiCmd: RYBaseAPICmd) -> Void
    optional func apiCmd(apiCmd: RYBaseAPICmd, beforePerformSuccessWithResponse response: RYURLResponse) -> Void
    optional func apiCmd(apiCmd: RYBaseAPICmd, afterPerformSuccessWithResponse response: RYURLResponse) -> Void
    optional func apiCmd(apiCmd: RYBaseAPICmd, beforePerformFailWithResponse response: RYURLResponse) -> Void
    optional func apiCmd(apiCmd: RYBaseAPICmd, afterPerformFailWithResponse response: RYURLResponse) -> Void
    optional func apiCmd(apiCmd: RYBaseAPICmd, shouldCallAPIWithParams params: Dictionary<String, AnyObject>) -> Void
    optional func apiCmd(apiCmd: RYBaseAPICmd, afterCallingAPIWithParams params: Dictionary<String, AnyObject>) -> Void
    
}

/*************************************************************************************************/
 /*                               FYAPIManagerCallbackDataReformer                                */
 /*************************************************************************************************/
 // 拦截器

@objc
public protocol APICmdAspect {
    
    optional func apiCmd(apiCmd: RYBaseAPICmd, request: NSMutableURLRequest) -> Void
    
}

public class RYBaseAPICmd: NSObject {
    
    public weak var delegate: APICmdApiCallBackDelegate?
    public weak var interceptor: APICmdInterceptor?
    public weak var paramSource: APICmdParamSourceDelegate?
    public weak var aspect: APICmdAspect?

    /** GET & POST's Parameters */
    
    public var reformParams: AnyObject?
    public var path: String?
    /// 查询当前是否loading
    public var isLoading: Bool?
    
    private var requestId: Int?
    private var absouteUrlString: String?
    private var cookie: String?
    private var serviceIdentifier: String?
    
    public override init()
    {
        super.init()
    }
    
    deinit {
    }
    
    /// 开始请求数据
    @objc public func loadData() -> Void {
        
    }
    
    /// 取消当前的请求
    @objc public func cancelRequest() -> Void {
        
    }
    
}
