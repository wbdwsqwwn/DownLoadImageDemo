//
//  ESApp.m
//  DownloadImageDemo
//
//  Created by wanbd on 2016/11/24.
//  Copyright © 2016年 ES. All rights reserved.
//

#import "ESApp.h"

@implementation ESApp

+ (instancetype)appWithDictionary:(NSDictionary *)dict {
    ESApp *appM = [[ESApp alloc] init];
    [appM setValuesForKeysWithDictionary:dict];
    return appM;
}

@end
