//
//  MMScrollView.m
//  MMUIDemo
//
//  Created by Zero.D.Saber on 2017/5/5.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "ZDBannerScrollView.h"
#import <ZDToolKit/NSTimer+ZDUtility.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface MDImageCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) NSString *placeholderImageName;
@property (nonatomic, strong) NSString *urlString;
@end


@interface ZDBannerScrollView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *innerDataSource; ///< 真正的数据源（比传入的数据多2条）
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, weak  ) id<ZDBannerScrollViewDelegate> delegate;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy  ) NSString *placeholderImageName;
@end

@implementation ZDBannerScrollView

- (void)dealloc {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    NSLog(@"%@-->%@, %s", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __PRETTY_FUNCTION__);
}

#pragma mark - Public Method

- (void)pauseTimer {
    if (!_timer) return;
    self.timer.fireDate = [NSDate distantFuture];
}

- (void)resumeTimer {
    if (!_timer) return;
    self.timer.fireDate = [NSDate date];
}

+ (instancetype)scrollViewWithFrame:(CGRect)frame delegate:(id<ZDBannerScrollViewDelegate>)delegate placeholderImage:(NSString *)placeholderImageName {
    ZDBannerScrollView *view = [[self alloc] initWithFrame:frame];
    view.delegate = delegate;
    view.placeholderImageName = placeholderImageName;
    
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _innerDataSource = @[].mutableCopy;
    
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) return;
    
    __weak typeof(self)weakSelf = self;
    self.timer = [NSTimer zd_scheduledTimerWithTimeInterval:(self.interval > 0 ? self.interval : 2.5) repeats:YES block:^(NSTimer * _Nonnull timer) {
        __strong typeof(weakSelf)self = weakSelf;
        [self autoScroll];
    }];
}

- (void)autoScroll {
    CGFloat itemWidth = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize.width;
    
    NSUInteger currentIndex = (self.collectionView.contentOffset.x + itemWidth * 0.5) / itemWidth;
    NSUInteger targetIndex = currentIndex + 1;
    
    if (targetIndex >= self.innerDataSource.count) { // 越界的情况
        CGFloat contentOffsetY = self.collectionView.contentOffset.y;
        self.collectionView.contentOffset = CGPointMake(CGRectGetWidth(self.bounds), contentOffsetY);
        if (self.innerDataSource.count <= 2) return;
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
    else {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

#pragma mark - UICollectionViewDatasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.innerDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MDImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MDImageCollectionViewCell class]) forIndexPath:indexPath];
    cell.placeholderImageName = self.placeholderImageName;
    cell.urlString = [self.innerDataSource objectAtIndex:indexPath.item];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollView:didSelectItemAtIndex:)]) {
        if (self.innerDataSource.count == 3) { // 此时说明只有一条数据
            NSLog(@"点击了第%zd个", 0);
            [self.delegate scrollView:self didSelectItemAtIndex:0];
        }
        else {
            NSLog(@"点击了第%zd个", indexPath.item - 1);
            NSUInteger selectIndex = indexPath.item - 1;
            if (indexPath.item >= self.innerDataSource.count - 2) {
                selectIndex = self.innerDataSource.count - 2 - 1;
            } else if (indexPath.item < 0) {
                selectIndex = 0;
            }
            [self.delegate scrollView:self didSelectItemAtIndex:selectIndex];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat contentWidth = scrollView.contentSize.width;
    CGFloat boundsWidth = self.bounds.size.width;
    if (offsetX >= (contentWidth - boundsWidth)) {
        scrollView.contentOffset = CGPointMake(boundsWidth, scrollView.contentOffset.y);
    }
    else if (offsetX < boundsWidth) {
        // 1.3改成2的话会有bug
        scrollView.contentOffset = CGPointMake(contentWidth - boundsWidth * 1.3, scrollView.contentOffset.y);
    }
    
    NSInteger currentPage = scrollView.contentOffset.x / boundsWidth - 1;
    self.pageControl.currentPage = currentPage;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollView:didScrollToIndex:)]) {
        [self.delegate scrollView:self didScrollToIndex:currentPage];
    }
}

#pragma mark - Property

//MARK: Setter
- (void)setImageURLStrings:(NSArray<NSString *> *)imageURLStrings {
    if (!imageURLStrings || imageURLStrings.count == 0) return;
    _imageURLStrings = imageURLStrings;
    
    if (_innerDataSource.count > 0) {
        [_innerDataSource removeAllObjects];
    }
    
    // 1张图片时禁用定时器和滑动
    if (imageURLStrings.count == 1) {
        [_timer invalidate];
        _timer = nil;
    }
    self.collectionView.scrollEnabled = (imageURLStrings.count > 1);
    
    [_innerDataSource addObjectsFromArray:imageURLStrings];
    [_innerDataSource insertObject:imageURLStrings.lastObject atIndex:0];
    [_innerDataSource addObject:imageURLStrings.firstObject];
    
    self.pageControl.numberOfPages = imageURLStrings.count;
    
    [self.collectionView reloadData];
}

//MARK: Getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = ({
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
            flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            flowLayout.minimumInteritemSpacing = 0;
            flowLayout.minimumLineSpacing = 0;
            flowLayout.itemSize = self.bounds.size;
            
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView.scrollsToTop = NO;
            collectionView.pagingEnabled = YES;
            collectionView.showsHorizontalScrollIndicator = NO;
            collectionView.showsVerticalScrollIndicator = NO;
            [collectionView registerClass:[MDImageCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MDImageCollectionViewCell class])];
            collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            if (@available(iOS 11, *)) {
                collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
                        
            collectionView.contentOffset = CGPointMake(CGRectGetWidth(collectionView.frame), collectionView.contentOffset.y);
            
            collectionView;
        });
    }
    return _collectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:(CGRect){0, CGRectGetHeight(self.bounds) - 20, CGRectGetWidth(self.bounds), 20}];
        _pageControl.numberOfPages = self.imageURLStrings.count;
        _pageControl.currentPage = 0;
        _pageControl.hidesForSinglePage = YES;
        _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.57 green:0.45 blue:0.57 alpha:1.0];
    }
    return _pageControl;
}

@end

//======================================================

@interface MDImageCollectionViewCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *defaultImage;
@end

@implementation MDImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor yellowColor];
    //_defaultImage = [UIImage imageWithColor:[UIColor lightGrayColor] finalSize:self.bounds.size];
    
    [self.contentView addSubview:self.imageView];
}

#pragma mark - Property
//MARK: Setter
- (void)setUrlString:(NSString *)urlString {
    if (!urlString || urlString.length == 0) return;
    
    _urlString = urlString;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:({
        UIImage *image = nil;
        if (self.placeholderImageName.length > 0) {
            image = [UIImage imageNamed:self.placeholderImageName];
        }
        image ?: _defaultImage;
    })];
}

//MARK: Getter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = ({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
            imageView.backgroundColor = [UIColor whiteColor];
            //imageView.clipsToBounds = YES;
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            imageView;
        });
    }
    return _imageView;
}

@end


