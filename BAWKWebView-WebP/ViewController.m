//
//  ViewController.m
//  BAWKWebView-WebP
//
//  Created by 海洋唐 on 2017/8/2.
//  Copyright © 2017年 boai. All rights reserved.
//

/*!
 *  获取屏幕宽度和高度
 */
#define BAKit_SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)

#define BAKit_SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

#import "ViewController.h"
#import "BAWebpController.h"

static NSString * const kURL2 = @"http://onzbjws3p.bkt.clouddn.com/testForwebpSrc/webpForhtml.html";
static NSString * const kURL3 = @"https://isparta.github.io/compare-webp/index_a.html#12"; // webp动图测试

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *baTableView;
@property (nonatomic,strong)NSMutableArray *dataArray;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationItem.title = @"BAWebP";
    [self.view addSubview:self.baTableView];
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithObjects:@"webp静态图片",@"webp动图待完善", nil];
    }
    return _dataArray;
}

- (UITableView *)baTableView {
    if (!_baTableView) {
        _baTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, BAKit_SCREEN_WIDTH, BAKit_SCREEN_HEIGHT-64)];
        _baTableView.delegate = self;
        _baTableView.dataSource = self;
    }
    return _baTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BAWebpController *webpVC = [[BAWebpController alloc]init];
    if (indexPath.row == 0) {
        webpVC.urlString = kURL2;
    }
    else if (indexPath.row == 1){
        webpVC.urlString = kURL3;
    }
    [self.navigationController pushViewController:webpVC animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
