//
//  ESApp.h
//  DownloadImageDemo
//
//  Created by wanbd on 2016/11/24.
//  Copyright © 2016年 ES. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESApp : NSObject

/**doc*/
@property (nonatomic ,copy) NSString *name;
/**<#doc#>*/
@property (nonatomic ,copy) NSString *icon;
/***/
@property (nonatomic ,copy) NSString *download;

+(instancetype)appWithDictionary:(NSDictionary *)dict;

@end
