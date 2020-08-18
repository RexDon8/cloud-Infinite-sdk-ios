//
//  RootViewController.m
//  CIImageLoaderDemo
//
//  Created by garenwang on 2020/8/12.
//  Copyright © 2020 garenwang. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController.h"
#import "GetAveColorVC.h"
#import "CIZoomImageVC.h"
#import "CICutImageVC.h"
#import "CIFormatVC.h"
#import "CISigmaVC.h"
#import "CIQualityChangeVC.h"
#import "CIWaterMarkVC.h"
#import "CIStripImageVC.h"
#import "CISharpenVC.h"
#import "CIGifOptimizeVC.h"
#import "CIRoTateVC.h"

@interface RootViewController ()

@property (nonatomic,strong)NSArray <NSString *> * titleArray;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleArray = @[@"自适应加载",@"TPG解码",@"缩放",@"裁剪",@"GIF优化",@"格式转换",@"旋转",@"质量变换",@"高斯模糊",@"锐化",@"图片水印、文字水印",@"图片主题色",@"去除元信息"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld:%@",indexPath.row + 1,self.titleArray[indexPath.row]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc;
    
    if (indexPath.row == 0) {
        
        vc = [mainSB instantiateViewControllerWithIdentifier:@"ViewController"];
        ViewController * tempVC = (ViewController *)vc;
        tempVC.isTPG = NO;
    }
    
    if (indexPath.row == 1) {
        vc = [mainSB instantiateViewControllerWithIdentifier:@"ViewController"];
        ViewController * tempVC = (ViewController *)vc;
        tempVC.isTPG = YES;
    }
    
    if (indexPath.row == 2) {
        vc = [[CIZoomImageVC alloc]initWithNibName:@"BaseViewController" bundle:nil];
    }
    if (indexPath.row == 3) {
        vc = [[CICutImageVC alloc]initWithNibName:@"BaseViewController" bundle:nil];
    }
    
    if (indexPath.row == 4) {
        vc = [[CIGifOptimizeVC alloc]initWithNibName:@"BaseViewController" bundle:nil];
    }
    
    if (indexPath.row == 5) {
        vc = [[CIFormatVC alloc]initWithNibName:@"BaseViewController" bundle:nil];
    }
    
    if (indexPath.row == 6) {
           vc = [[CIRoTateVC alloc]initWithNibName:@"BaseViewController" bundle:nil];
       }
    
    if (indexPath.row == 7) {
        vc = [[CIQualityChangeVC alloc]initWithNibName:@"BaseViewController" bundle:nil];
    }
    
    if (indexPath.row == 8) {
        vc = [[CISigmaVC alloc]initWithNibName:@"BaseViewController" bundle:nil];
    }
    
    if (indexPath.row == 9) {
        vc = [[CISharpenVC alloc]initWithNibName:@"BaseViewController" bundle:nil];
    }
    
    if (indexPath.row == 10) {
        vc = [[CIWaterMarkVC alloc]initWithNibName:@"BaseViewController" bundle:nil];
    }
    
    if (indexPath.row == 11) {
        vc = [[GetAveColorVC alloc]initWithNibName:@"BaseViewController" bundle:nil];
    }
    
    if (indexPath.row == 12) {
        vc = [[CIStripImageVC alloc]initWithNibName:@"BaseViewController" bundle:nil];
    }
    
    vc.title = self.titleArray[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
