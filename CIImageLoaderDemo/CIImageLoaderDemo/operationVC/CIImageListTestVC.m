//
//  CIZoomImageVC.m
//  CIImageLoaderDemo
//
//  Created by garenwang on 2020/8/12.
//  Copyright © 2020 garenwang. All rights reserved.
//

#import "CIImageListTestVC.h"
#import "CISlider.h"

@interface CIImageListTestVC ()

@property(nonatomic,strong)UICollectionView * collectionView;

@property(nonatomic,strong)CISlider * width;

@property(nonatomic,strong)CISlider * height;

@property(nonatomic,strong)UISegmentedControl * segment;
@property(nonatomic,strong)UISegmentedControl * segmentSubType;

@end

@implementation CIImageListTestVC


- (void)viewDidLoad {
    [super viewDidLoad];
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.width / 2);
    
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    self.collectionView = [[UICollectionView alloc]initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"TPGCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"TPGCollectionViewCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.collectionView reloadData];
    [self.view addSubview:self.collectionView];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.urlArray.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TPGCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TPGCollectionViewCell" forIndexPath:indexPath];
    CITransformation *tran = [CITransformation new];
    [tran setFormatWith:CIImageTypeWEBP options:CILoadTypeUrlFooter];
    [tran setViewBackgroudColorWithImageAveColor:YES];
//    [tran setBlurRadius:40 sigma:30];
    [[SDWebImageManager sharedManager].imageCache clearWithCacheType:SDImageCacheTypeAll completion:nil];
    [cell.imageView sd_CI_setImageWithURL:[NSURL URLWithString:self.urlArray[indexPath.row]] transformation:tran];
    //    [cell sd_CI_preloadWithAveColor:self.urlArray[indexPath.row]];
    
    //    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.urlArray[indexPath.row]]];
    
    return cell;
}

- (NSArray *)urlArray{
    return @[
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/01.gif",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default01.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default02.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default03.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default04.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default05.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default06.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default07.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default08.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/01.gif",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default01.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default02.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default03.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default04.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default05.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default06.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default07.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default08.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/01.gif",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default01.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default02.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default03.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default04.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default05.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default06.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default07.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default08.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/01.gif",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default01.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default02.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default03.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default04.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default05.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default06.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default07.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default08.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/01.gif",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default01.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default02.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default03.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default04.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default05.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default06.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default07.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default08.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/01.gif",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default01.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default02.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default03.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default04.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default05.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default06.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default07.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default08.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/01.gif",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default01.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default02.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default03.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default04.jpg",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default05.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default06.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default07.png",
        @"https://tpgdemo-1253960454.cos.ap-guangzhou.myqcloud.com/default08.png",
        
    ];
}




@end
