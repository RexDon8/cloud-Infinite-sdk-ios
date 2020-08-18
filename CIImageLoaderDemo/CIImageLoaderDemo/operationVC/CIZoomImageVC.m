//
//  CIZoomImageVC.m
//  CIImageLoaderDemo
//
//  Created by garenwang on 2020/8/12.
//  Copyright © 2020 garenwang. All rights reserved.
//

#import "CIZoomImageVC.h"
#import "CISlider.h"

@interface CIZoomImageVC ()

@property(nonatomic,strong)UICollectionView * collectionView;

@property(nonatomic,strong)CISlider * width;

@property(nonatomic,strong)CISlider * height;

@property(nonatomic,strong)UISegmentedControl * segment;
@property(nonatomic,strong)UISegmentedControl * segmentSubType;

@end

@implementation CIZoomImageVC


- (void)viewDidLoad {
    [super viewDidLoad];
    //    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    //    layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.width / 2);
    //    layout.minimumInteritemSpacing = 0;
    //    layout.minimumLineSpacing = 0;
    //    self.collectionView = [[UICollectionView alloc]initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
    //    [self.collectionView registerNib:[UINib nibWithNibName:@"TPGCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"TPGCollectionViewCell"];
    //    self.collectionView.delegate = self;
    //    self.collectionView.dataSource = self;
    //    self.view.backgroundColor = [UIColor whiteColor];
    //    [self.collectionView reloadData];
    //    [self.view addSubview:self.collectionView];
}

-(CISlider *)createSliderAndTitle:(NSInteger)index andTitle:(NSString *) title{
    
    CISlider * slider = [CISlider new];
    slider.titleString = title;
    [self.operationView addSubview:slider];
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(16);
        make.top.equalTo(index * 60 + 130);
        make.height.equalTo(60);
        make.width.equalTo(self.operationView.mas_width);
    }];
    slider.tag = 1000 + index;
    
    return slider;
};

- (void)setCurrentImage:(UIImage *)currentImage{
    [super setCurrentImage:currentImage];
    if (self.segment.selectedSegmentIndex == 0) {
        self.width.maximumValue = 100;
        self.height.maximumValue = 100;
    }else{
        self.width.maximumValue = currentImage.size.width;
        self.height.maximumValue = currentImage.size.height;
    }
}

-(void)actionSelectZoomType:(UISegmentedControl *)segment{
    [self reset];
    if (segment == self.segment) {
        if (segment.selectedSegmentIndex == 0) {
            self.width.titleString = @"缩放百分比";
            self.width.maximumValue = 100;
            self.height.maximumValue = 100;
            self.height.hidden = YES;
        }else{
            self.width.titleString = @"宽度（为0时，即不指定）";
            self.width.maximumValue = self.currentImage.size.width;
            self.height.maximumValue = self.currentImage.size.height;
            self.height.hidden = NO;
        }
    }
}

- (void)loadImage{
    CITransformation * tran = [CITransformation new];
    if (self.segment.selectedSegmentIndex == 0) {
        if (self.segmentSubType.selectedSegmentIndex == 0) {
            [tran setZoomWithPercent:self.width.value scaleType:ScalePercentTypeOnlyWidth];
        }else if (self.segmentSubType.selectedSegmentIndex == 1){
            [tran setZoomWithPercent:self.width.value scaleType:ScalePercentTypeOnlyHeight];
        }else{
            [tran setZoomWithPercent:self.width.value scaleType:ScalePercentTypeALL];
        }
        
    }else{
        
//  [tran setZoomWithWidth:self.width.value height:self.height.value scaleType:ScaleTypeAUTOFit];
//  [tran setZoomWithWidth:self.width.value height:self.height.value scaleType:ScaleTypeAUTOFITWithMin];
//        [tran setZoomWithArea:1000];
        
        if (self.segmentSubType.selectedSegmentIndex == 0) {
            [tran setZoomWithWidth:self.width.value height:self.height.value scaleType:ScaleTypeOnlyWidth];
        }else if (self.segmentSubType.selectedSegmentIndex == 1){
            [tran setZoomWithWidth:self.width.value height:self.height.value scaleType:ScaleTypeOnlyHeight];
        }else{
            [tran setZoomWithWidth:self.width.value height:self.height.value scaleType:ScaleTypeAUTOFill];
        }
        
    }
    [self loadData:0 andTranform:tran];
}

- (void)buildOperationView{
    [super buildOperationView];
    
    UISegmentedControl * segment = [[UISegmentedControl alloc]initWithItems:@[@"百分比缩放",@"指定宽高缩放"]];
    segment.selectedSegmentIndex = 0;
    self.segment = segment;
    [segment addTarget:self  action:@selector(actionSelectZoomType:) forControlEvents:UIControlEventValueChanged];
    
    [self.operationView addSubview:segment];
    [segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(16);
        make.right.equalTo(-16);
        make.top.equalTo(self.operationView.top).offset(16);
        make.height.equalTo(35);
    }];
    
    UISegmentedControl * segmentSubType = [[UISegmentedControl alloc]initWithItems:@[@"仅缩放宽度",@"仅缩放高度",@"同时缩放"]];
    segmentSubType.selectedSegmentIndex = 0;
    self.segmentSubType = segmentSubType;
    [segmentSubType addTarget:self  action:@selector(actionSelectZoomType:) forControlEvents:UIControlEventValueChanged];
    segmentSubType.selectedSegmentIndex = 0;
    [self.operationView addSubview:segmentSubType];
    [segmentSubType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(16);
        make.right.equalTo(-16);
        make.top.equalTo(self.segment.bottom).offset(16);
        make.height.equalTo(28);
    }];
    
    self.width = [self createSliderAndTitle:0 andTitle:@"缩放百分比"];
    
    self.height = [self createSliderAndTitle:1 andTitle:@"高度（为0时，即不指定）"];
    self.height.hidden = YES;
    
    UILabel * labDesc = [UILabel new];
    [self.operationView addSubview:labDesc];
    
    labDesc.text = @"提示：更多缩放类型以及用法见文档以及代码注释";
    labDesc.font = [UIFont systemFontOfSize:14];
    [labDesc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(16);
        make.right.equalTo(-16);
        make.height.equalTo(30);
        make.top.equalTo(self.height.bottom).offset(12);
    }];
}

- (void)reset{
    self.width.value = 0;
    self.height.value = 0;
}

//-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    return 1;
//}
//
//-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    return self.urlArray.count;
//}
//
//-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    TPGCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TPGCollectionViewCell" forIndexPath:indexPath];
//    CITransformation *tran = [CITransformation new];
//    [tran setFormatWith:CIImageTypeAUTO options:CILoadTypeUrlFooter];
//
//    [cell.imageView sd_CI_setImageWithURL:[NSURL URLWithString:self.urlArray[indexPath.row]] transformation:tran];
//
//
////    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.urlArray[indexPath.row]]];
//
//    return cell;
//}
//
//- (NSArray *)urlArray{
//    return @[
//        @"https://tpg-1253653367.file.myqcloud.com/dingdang.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/gif1.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/gif2.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/gif3.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/gif4.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/gif5.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/10.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/11.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/12.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/13.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/20.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/21.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/22.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/23.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/24.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/25.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/26.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/27.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/28.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/29.gif",
//        @"https://tpg-1253653367.file.myqcloud.com/30.gif",
//    ];
//}




@end
