//
//  ViewController.m
//  CIImageLoaderDemo
//
//  Created by garenwang on 2020/7/13.
//  Copyright © 2020 garenwang. All rights reserved.
//https://lns.hywly.com/a/1/8523/1.jpg

#import "ViewController.h"
#import "CIImageLoader.h"
#import <TPGImageView.h>
#import <CloudImage.h>
#import "TPGCollectionViewCell.h"
#import <SDWebImage/SDWebImage.h>
#import <TPGWebImageDownloader.h>

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong)NSArray * urlArray;
@property (weak, nonatomic) IBOutlet UICollectionView *tpgHeader;
@property (weak, nonatomic) IBOutlet TPGImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet TPGImageView *tpgImageView;
@property (weak, nonatomic) IBOutlet UILabel *labTpgTitle;
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UILabel *labTPGTime;
@property (weak, nonatomic) IBOutlet UILabel *labType;
@property (weak, nonatomic) IBOutlet UILabel *labTPGType;

@property (nonatomic,strong)TPGWebImageDownloader * downLoader;

@end








@implementation ViewController

- (NSArray *)urlArray{
    return @[
        @"https://tpg-1253653367.file.myqcloud.com/01.jpg",
        @"https://tpg-1253653367.file.myqcloud.com/02.jpg",
        @"https://tpg-1253653367.file.myqcloud.com/03.jpg",
        @"https://tpg-1253653367.file.myqcloud.com/04.jpg",
        @"https://tpg-1253653367.file.myqcloud.com/05.png",
        @"https://tpg-1253653367.file.myqcloud.com/06.png",
        @"https://tpg-1253653367.file.myqcloud.com/07.png",
        @"https://tpg-1253653367.file.myqcloud.com/08.png",
    ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self.tpgHeader registerNib:[UINib nibWithNibName:@"TPGCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"TPGCollectionViewCell"];
    
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(90, 90);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    [self.tpgHeader setCollectionViewLayout:layout];
    self.tpgHeader.delegate = self;
    self.tpgHeader.dataSource = self;
    [self.tpgHeader reloadData];
    self.tpgHeader.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    
    TPGImageView * imageView = [[TPGImageView alloc]initWithFrame: CGRectMake(0, 0, 200, 200)];
    [self.view addSubview:imageView];
    
    [self loadData:0];
    
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.urlArray.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TPGCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TPGCollectionViewCell" forIndexPath:indexPath];
    
    CloudImage * cloudImage = [CloudImage new];
    
    CITransformation * transform = [[CITransformation alloc] initWithFormat:CIImageTypeJPG options:CILoadTypeUrlFooter];
    
    [cloudImage requestWithBaseUrl:self.urlArray[indexPath.row] transform:transform request:^(CIImageLoadRequest * _Nonnull request) {
        
        [cell.imageView sd_setImageWithURL:request.url placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [self showDataSizeUrl:imageURL typeLable:nil sizeLable:cell.labTitle];
        }];
//        [[CIImageLoader shareLoader] display:cell.imageView loadRequest:request placeHolder:[UIImage imageNamed:@"placeholder"] loadComplete:^(NSData * _Nullable data, NSError * _Nullable error) {
//            cell.labTitle.text = [NSString stringWithFormat:@"大小:%.2lu KB", [data length] / 1000];
//        }];
    }];
    
    return cell;
}

-(void)showDataSizeUrl:(NSURL *)imageURL typeLable:(UILabel *)typeLable sizeLable:(UILabel *)sizeLable{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // sdwebimage 没有返回image data数据，用这个方式单独获取data，显示文件格式以及大小，正常使用时无需此步骤
        NSData * data = [NSData dataWithContentsOfURL:imageURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            typeLable.text = [NSString stringWithFormat:@"格式：%@",[self getImageType:data]];
            sizeLable.text = [NSString stringWithFormat:@"大小:%.2lu KB", [data length] / 1000];
        });
    });
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self loadData:indexPath.row];
}

-(void)loadData:(NSInteger)index{
    // SDWebImageRefreshCached 在请求图片是先回将缓存中的图片显示，同时也会请求图片，为了更直观，这里直接将缓存清除
    [[SDWebImageManager sharedManager].imageCache clearWithCacheType:SDImageCacheTypeAll completion:nil];
    
    NSString * imageUrl = [self.urlArray objectAtIndex:index];
    self.labTitle.text = @"大小：";
    self.labTpgTitle.text = @"大小：";
    self.labType.text = @"格式：";
    self.labTPGType.text = @"格式：";
    self.labTime.text = @"耗时：";
    self.labTPGTime.text = @"耗时：";
    
    CloudImage * cloudImage = [CloudImage new];
    
    CITransformation * transform = [[CITransformation alloc] initWithFormat:CIImageTypeJPG options:CILoadTypeUrlFooter];
    
    CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
    [cloudImage requestWithBaseUrl:imageUrl transform:transform request:^(CIImageLoadRequest * _Nonnull request) {
        [self.imageView sd_setImageWithURL:request.url placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageRefreshCached completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
            self.labTime.text = [NSString stringWithFormat:@"耗时：%.2f s",linkTime];
            
            [self showDataSizeUrl:imageURL typeLable:self.labType sizeLable:self.labTitle];
        }];
    }];

    CITransformation * tpgtransform = [[CITransformation alloc] initWithFormat:CIImageTypeTPG options:CILoadTypeUrlFooter];
    self.tpgImageView.image = [UIImage imageNamed:@"placeholder"];
    [cloudImage requestWithBaseUrl:imageUrl transform:tpgtransform request:^(CIImageLoadRequest * _Nonnull request) {
        
        //        **************************************************************************
        
        //        CloudImage 主要功能：构建 CIImageLoadRequest 实例，CIImageLoadRequest主要包含url和header；
        //        CIImageLoadRequest 实例，可用于CImageLoader；也可以用于SDWebImage
        
        //        CIImageLoader 主要功能：使用CIImageLoadRequest实例，请求网络图并返回Data形式数据；
        
        //        TPGImage:主要功能：解码TPG并显示图片，即可用于显示普通图片，也可用于TPG图
        
        //        TPGImageSDWebImage 主要功能：SDWebImage能够显示TPG图 ：自定义imageloader和 TPGImageDecoder ，
        
        //        **************************************************************************
        
        //        加载方式1 构建出url，用三方加载 （CouldImage + SDWebimage）
        //        [self.tpgImageView sd_setImageWithURL:request.url placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
        
        //         加载方式2 直接加载普通图片 （CouldImage + CIImageLoader）
        //        [[CIImageLoader shareLoader] display:self.imageView loadRequest:request placeHolder:[UIImage imageNamed:@"placeholder"] loadComplete:^(NSData * _Nullable data, NSError * _Nullable error) {
        //
        //        }];
        
        
        //        加载方式3 直接加载TPG (CouldImage + CIImageLoader + TPGImage)
        //        [[CIImageLoader shareLoader] loadData:request loadComplete:^(NSData * _Nullable data, NSError * _Nullable error) {
        //            [self.tpgImageView setTpgImageWithData:data loadComplete:^(NSData * _Nullable data, UIImage * _Nullable image, NSError * _Nullable error) {
        //                NSLog(@"%@",error);
        //            }];
        //            self.labTpgTitle.text = [NSString stringWithFormat:@"格式：%@   大小:%.2lu KB",[self getImageType:data], [data length] / 1000];
        //        }];
        
        //        加载方式4 SDWebImage加载TPG (SDWebImage + TPGImage)
        //    completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        //        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //            // sdwebimage 没有返回image data数据，用这个方式单独获取data，显示文件格式以及大小，正常使用时无需此步骤
        //            NSData * data = [NSData dataWithContentsOfURL:imageURL];
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                self.labTpgTitle.text = [NSString stringWithFormat:@"格式：%@   大小:%.2lu KB",[self getImageType:data], [data length] / 1000];
        //            });
        //        });
        //    }
        
        // 如果header使用相同 则使用单例的方式
        // self.downLoader = [TPGWebImageDownloader shareLoader];
        // [self.downLoader setHttpHeaderField:request.header];
        
        // 如果每次header 不同则使用该构造方式；
        self.downLoader = [[TPGWebImageDownloader alloc] initWithHeader:request.header];
        
        // SDWebImageRefreshCached demo中为了准备计算请求耗时，不使用缓存，正式项目中还是使用缓存比较好
        [self.tpgImageView sd_setImageWithURL:request.url placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageRefreshCached context:@{SDWebImageContextImageLoader:self.downLoader} progress:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
            self.labTPGTime.text = [NSString stringWithFormat:@"耗时：%.2f s",linkTime];
            [self showDataSizeUrl:imageURL typeLable:self.labTPGType sizeLable:self.labTpgTitle];
        }];
    }];
}



-(NSString *)getImageType:(NSData *)data{
    uint8_t ch;
    [data getBytes:&ch length:1];
    
    if (ch == 0xFF) {
        return  @"JPG";
    }
    if (ch == 0x89) {
        return @"PNG";
    }
    
    char char1 = 0 ;char char2 =0 ;char char3 = 0;
    
    [data getBytes:&char1 range:NSMakeRange(0, 1)];
    
    
    [data getBytes:&char2 range:NSMakeRange(1, 1)];
    
    [data getBytes:&char3 range:NSMakeRange(2, 1)];
    
    
    NSString *numStr = [NSString stringWithFormat:@"%c%c%c",char1,char2,char3];
    return numStr;
}
@end


















