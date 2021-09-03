//
//  ViewController.m
//  SplitScreenFilter
//
//  Created by Misaka on 2020/7/2.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import "ViewController.h"
#import "RenderView.h"
#import "FilterCell.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, assign) CGRect contentRect;
@property (nonatomic, strong) RenderView *renderView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) NSInteger imageIndex;
@property (nonatomic, assign) NSInteger filterIndex;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *shaderArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.width = self.view.frame.size.width;
    self.height = self.view.frame.size.height;
    self.contentRect = CGRectMake(0, 20, self.width, self.height - 100 - 10 - 50 - 10 - 20);
    self.imageIndex = 0;
    self.filterIndex = 0;
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.nextBtn];
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.filterIndex inSection:0] animated:NO scrollPosition:0];
    [self reRender];
}

#pragma mark - func

- (void)nextBtnClick {
    self.imageIndex ++;
    if (self.imageIndex >= self.imageArray.count) {
        self.imageIndex = 0;
    }
    [self reRender];
}

- (void)reRender {
    UIImage *image = [UIImage imageNamed:self.imageArray[self.imageIndex]];
    NSString *shaderName = self.shaderArray[self.filterIndex];
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    if (image.size.width/image.size.height >= self.contentRect.size.width/self.contentRect.size.height) {
        width = self.contentRect.size.width;
        height = width / image.size.width * image.size.height;
        x = self.contentRect.origin.x;
        y = self.contentRect.origin.y + (self.contentRect.size.height - height)/2.0;
    }else {
        height = self.contentRect.size.height;
        width = height / image.size.height * image.size.width;
        x = self.contentRect.origin.x + (self.contentRect.size.width - width)/2.0;
        y = self.contentRect.origin.y;
    }
    if (self.renderView) {
        [self.renderView freeMemory];
        [self.renderView removeFromSuperview];
        self.renderView = nil;
    }
    self.renderView = [[RenderView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [self.renderView setShader:shaderName image:image];
    [self.view addSubview:self.renderView];
}


#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    cell.title = self.dataArray[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.filterIndex == indexPath.item) {
        return;
    }
    self.filterIndex = indexPath.item;
    [self reRender];
}

#pragma mark - lazy

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, self.height - 160, self.width - 20, 50)];
        _nextBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        _nextBtn.layer.cornerRadius = 5;
        _nextBtn.clipsToBounds = YES;
        _nextBtn.backgroundColor = [UIColor orangeColor];
        [_nextBtn setTitle:@"NEXT" forState:UIControlStateNormal];
        [_nextBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        [_nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(80, 80);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.height - 100, self.width, 100) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[FilterCell class] forCellWithReuseIdentifier:@"cellID"];
    }
    return _collectionView;
}

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@"无", @"二分屏", @"三分屏", @"四分屏", @"六分屏", @"九分屏", @"十六\n分屏"];
    }
    return _dataArray;
}

- (NSArray *)shaderArray {
    if (!_shaderArray) {
        _shaderArray = @[@"shader_0",@"shader_2",@"shader_3",@"shader_4",@"shader_6",@"shader_9",@"shader_16"];
    }
    return _shaderArray;
}

- (NSArray *)imageArray {
    if (!_imageArray) {
        _imageArray = @[@"01", @"02", @"03", @"04", @"05"];
    }
    return _imageArray;
}



@end
