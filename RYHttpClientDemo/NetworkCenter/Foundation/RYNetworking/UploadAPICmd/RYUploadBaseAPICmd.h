//
//  RYUploadBaseAPICmd.h
//  RYHttpClientDemo
//
//  Created by wwt on 16/4/29.
//  Copyright © 2016年 RongYu100. All rights reserved.
//

#import "RYBaseAPICmd.h"

@interface RYUploadBaseAPICmd : RYBaseAPICmd

/** UploadFile's Parameters */

@property (nonatomic, copy) NSString *  fileURL;
@property (nonatomic, copy, readonly) NSString *  mimeType;
@property (nonatomic, copy, readonly) NSString *  suffixName;

@end
