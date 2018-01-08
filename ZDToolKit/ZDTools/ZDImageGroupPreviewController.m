//
//  ZDImageGroupPreviewController.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/1/5.
//

#import "ZDImageGroupPreviewController.h"
#import "ZDImagePreviewCell.h"
#import "ZDImageModel.h"

static NSString * const CellReuseIdentifier = @"ZDPhotoPreviewCell";

@interface ZDImageGroupPreviewController() <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSArray *_assetsTemp;
    CGFloat _offsetItemCount;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@end

@implementation ZDImageGroupPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if (_currentIndex) {
        [_collectionView setContentOffset:CGPointMake((CGRectGetWidth(self.view.bounds) + 20) * _currentIndex, 0) animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark -

- (void)setup {
    [self setupNotification];
    [self setupUI];
}

- (void)setupNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)setupUI {
    [self.view addSubview:self.collectionView];
    self.view.clipsToBounds = YES;
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _layout.itemSize = (CGSize){CGRectGetWidth(self.view.frame) + 20, CGRectGetHeight(self.view.frame)};
    _layout.minimumInteritemSpacing = 0;
    _layout.minimumLineSpacing = 0;
    _collectionView.frame = (CGRect){-10, 0, CGRectGetWidth(self.view.frame) + 20, CGRectGetHeight(self.view.frame)};
    self.collectionView.collectionViewLayout = _layout;
    
    if (_offsetItemCount > 0) {
        CGFloat offsetX = _offsetItemCount * _layout.itemSize.width;
        [_collectionView setContentOffset:CGPointMake(offsetX, 0)];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth +  ((CGRectGetWidth(self.view.frame) + 20) * 0.5);
    
    NSInteger currentIndex = offSetWidth / (CGRectGetWidth(self.view.frame) + 20);
    if (currentIndex < _models.count && _currentIndex != currentIndex) {
        _currentIndex = currentIndex;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photoPreviewCollectionViewDidScroll" object:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZDImagePreviewCell *cell = (id)[collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    
    ZDImageModel *model = _models[indexPath.row];
    cell.model = model;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[ZDImagePreviewCell class]]) {
        //[(ZDPhotoPreviewCell *)cell recoverSubviews];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[ZDImagePreviewCell class]]) {
        //[(ZDPhotoPreviewCell *)cell recoverSubviews];
    }
}

#pragma mark - UICollectionViewDelegate

#pragma mark - Events

- (void)backButtonClick {
    if (self.navigationController.childViewControllers.count < 2) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Notification

- (void)didChangeStatusBarOrientationNotification:(NSNotification *)notification {
    _offsetItemCount = _collectionView.contentOffset.x / _layout.itemSize.width;
}

#pragma mark - Property

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout = layout;
        
        UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        view.backgroundColor = [UIColor blackColor];
        view.dataSource = self;
        view.delegate = self;
        view.pagingEnabled = YES;
        view.scrollsToTop = NO;
        view.showsHorizontalScrollIndicator = NO;
        view.contentOffset = CGPointZero;
        view.contentSize = (CGSize){(CGRectGetWidth(self.view.frame) + 20) * self.models.count, 0};
        [view registerClass:[ZDImagePreviewCell class] forCellWithReuseIdentifier:CellReuseIdentifier];
        _collectionView = view;
    }
    return _collectionView;
}

@end











