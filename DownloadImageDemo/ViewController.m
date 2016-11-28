//
//  ViewController.m
//  DownloadImageDemo
//
//  Created by wanbd on 2016/11/24.
//  Copyright © 2016年 ES. All rights reserved.
//

#import "ViewController.h"
#import "ESApp.h"

@interface ViewController ()

/**app模型数组*/
@property (nonatomic ,copy) NSArray<ESApp *> *apps;
/**内存缓存字典*/
@property (nonatomic ,strong) NSMutableDictionary<NSString *,NSData *> *imageCache;
/**正在下载的任务字典*/
@property (nonatomic ,strong) NSMutableDictionary<NSString *,NSBlockOperation *> *operationCache;
/**下载队列*/
@property (nonatomic ,strong) NSOperationQueue *queue;
@end

@implementation ViewController

- (NSOperationQueue *)queue {
    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 3;
    }
    return _queue;
}

- (NSMutableDictionary<NSString *,NSBlockOperation *> *)operationCache {
    if (_operationCache == nil) {
        _operationCache = [NSMutableDictionary dictionary];
    }
    return _operationCache;
}

- (NSMutableDictionary<NSString *,NSData *> *)imageCache {
    if (_imageCache == nil) {
        _imageCache = [NSMutableDictionary dictionary];
    }
    return _imageCache;
}

- (NSArray<ESApp *> *)apps {
    if (_apps == nil) {
        NSMutableArray *m_apps = [NSMutableArray array];
        
        NSArray *appsArray = [NSArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"apps" ofType:@"plist"]];
        for (NSDictionary *dict in appsArray) {
            [m_apps addObject:[ESApp appWithDictionary:dict]];
        }
        _apps = m_apps;
    }
    return _apps;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"app";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    ESApp *appM = self.apps[indexPath.row];
    cell.textLabel.text = appM.name;
    cell.detailTextLabel.text = appM.download;
    
    // 获取沙盒路径
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    // 拼接缓存图片地址
    NSString *imageName = [appM.icon lastPathComponent];
    NSString *fullCachePath = [cachePath stringByAppendingPathComponent:imageName];
    
    __block NSData *imageData = [self.imageCache objectForKey:appM.icon];
    if (imageData) {
        // 从内存缓存中取
        cell.imageView.image = [UIImage imageWithData:imageData];
        NSLog(@"%zd-->>从内存缓存中取图片", indexPath.row);
    } else {
        // 从沙盒中取
        imageData = [NSData dataWithContentsOfFile:fullCachePath];
        if (imageData) {
            // 沙盒中存在直接设置图片
            cell.imageView.image = [UIImage imageWithData:imageData];
            NSLog(@"%zd-->>从沙盒缓存中取图片", indexPath.row);
        } else {
            // 沙盒中没有图片,需要下载
            self.queue = [[NSOperationQueue alloc] init];
            NSBlockOperation *operation = [self.operationCache objectForKey:appM.icon];
            if (operation) {
                // 任务字典中存在 该下载任务 不需要处理
            } else {
                
                // 防止下载图片缓慢的时候图片错位的问题 先清空cell原来的图片
                cell.imageView.image = nil;
                
                operation = [NSBlockOperation blockOperationWithBlock:^{
                    // 下载
                    imageData =  [NSData dataWithContentsOfURL:[NSURL URLWithString:appM.icon]];
                    NSLog(@"%zd-->>下载图片", indexPath.row);
                    if (imageData) {
                        // 下载到图片 加入内存缓存  写入沙盒
                        [self.imageCache setObject:imageData forKey:appM.icon];
                        [imageData writeToFile:fullCachePath atomically:YES];
                        // 移除任务
                        [self.operationCache removeObjectForKey:appM.icon];
                    } else {
                        // 下载失败或者网速慢等没有下载成功 移除任务 下次重新下
                        [self.operationCache removeObjectForKey:appM.icon];
                        return;
                    }
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                        cell.imageView.image = [UIImage imageWithData:imageData];
                        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    }];
                }];
                // 将下载任务存储到任务字典中
                [self.operationCache setObject:operation forKey:appM.icon];
                [self.queue addOperation:operation];
            }
            
        }

    }
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning---->>>>>%s", __FUNCTION__);
    
    [self.imageCache removeAllObjects];
    
    //取消队列中所有的操作
    [self.queue cancelAllOperations];
}


@end
