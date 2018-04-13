//
//  ZDImagePreviewCell.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/1/5.
//

#import "ZDImagePreviewCell.h"
#import "ZDImageModel.h"
#import "UIView+ZDUtility.h"

@interface ZDImagePreviewCell ()
@property (nonatomic, weak  ) UIImageView *imageView;
@property (nonatomic, strong) ZDProgressView *progressView;
@end

@implementation ZDImagePreviewCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoPreviewCollectionViewDidScroll) name:@"photoPreviewCollectionViewDidScroll" object:nil];
    [self setupUI];
}

- (void)setupUI {
    self.backgroundColor = [UIColor blackColor];
    [self configSubviews];
}

- (void)configSubviews {
    self.previewView = [[ZDPhotoPreviewView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakTarget = self;
    [self.previewView setSingleTapGestureBlock:^{
        __strong typeof(weakTarget) self = weakTarget;
        if (self.singleTapGestureBlock) {
            self.singleTapGestureBlock();
        }
    }];
    [self.previewView setImageProgressUpdateBlock:^(double progress) {
        __strong typeof(weakTarget) self = weakTarget;
        if (self.imageProgressUpdateBlock) {
            self.imageProgressUpdateBlock(progress);
        }
    }];
    [self addSubview:self.previewView];
}

- (void)setModel:(ZDImageModel *)model {
    _model = model;
    
    self.previewView.model = model;
}

- (void)recoverSubviews {
    [self.previewView recoverSubviews];
}

- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = allowCrop;
    self.previewView.allowCrop = allowCrop;
}

- (void)setCropRect:(CGRect)cropRect {
    _cropRect = cropRect;
    _previewView.cropRect = cropRect;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.previewView.frame = self.bounds;
}

#pragma mark - Notification

- (void)photoPreviewCollectionViewDidScroll {
    //[self pausePlayerAndShowNaviBar];
}

#pragma mark - Property

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        _imageView = imageView;
    }
    return _imageView;
}

- (ZDProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[ZDProgressView alloc] init];
        _progressView.hidden = YES;
    }
    return _progressView;
}

@end


@interface ZDPhotoPreviewView ()<UIScrollViewDelegate>

@end

@implementation ZDPhotoPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setupUI];
}

- (void)setupUI {
    _scrollView = ({
        UIScrollView *view = [[UIScrollView alloc] init];
        view.bouncesZoom = YES;
        view.maximumZoomScale = 2.5;
        view.minimumZoomScale = 1.0;
        view.multipleTouchEnabled = YES;
        view.delegate = self;
        view.scrollsToTop = NO;
        view.showsHorizontalScrollIndicator = NO;
        view.showsVerticalScrollIndicator = YES;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.delaysContentTouches = NO;
        view.canCancelContentTouches = YES;
        view.alwaysBounceVertical = NO;
        view;
    });
    
    _imageContainerView = ({
        UIView *view = [[UIView alloc] init];
        view.clipsToBounds = YES;
        view.contentMode = UIViewContentModeScaleAspectFill;
        view;
    });
    
    _imageView = ({
        UIImageView *view = [[UIImageView alloc] init];
        view.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        view.contentMode = UIViewContentModeScaleAspectFill;
        view.clipsToBounds = YES;
        view;
    });
    
    [self addSubview:_scrollView];
    [_scrollView addSubview:_imageContainerView];
    [_imageContainerView addSubview:_imageView];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.numberOfTapsRequired = 2;
    [tap1 requireGestureRecognizerToFail:tap2];
    [self addGestureRecognizer:tap2];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    [self configProgressView];
}

- (void)configProgressView {
    _progressView = [[ZDProgressView alloc] init];
    _progressView.hidden = YES;
    [self addSubview:_progressView];
}

- (void)setModel:(ZDImageModel *)model {
    _model = model;
    [_scrollView setZoomScale:1.0 animated:NO];
}

- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = allowCrop;
    _scrollView.maximumZoomScale = allowCrop ? 4.0 : 2.5;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _scrollView.frame = CGRectMake(10, 0, self.width - 20, self.height);
    static CGFloat progressWH = 40;
    CGFloat progressX = (self.width - progressWH) / 2;
    CGFloat progressY = (self.height - progressWH) / 2;
    _progressView.frame = CGRectMake(progressX, progressY, progressWH, progressWH);
    
    [self recoverSubviews];
}

#pragma mark -

- (void)recoverSubviews {
    [_scrollView setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    _imageContainerView.origin = CGPointZero;
    _imageContainerView.width = self.scrollView.width;
    
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > self.height / self.scrollView.width) {
        _imageContainerView.height = floor(image.size.height / (image.size.width / self.scrollView.width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.scrollView.width;
        if (height < 1 || isnan(height)) {
            height = self.height;
        }
        height = floor(height);
        _imageContainerView.height = height;
        _imageContainerView.centerY = self.height / 2.0;
    }
    
    if (_imageContainerView.height > self.height && _imageContainerView.height - self.height <= 1) {
        _imageContainerView.height = self.height;
    }
    
    CGFloat contentSizeH = MAX(_imageContainerView.height, self.height);
    _scrollView.contentSize = CGSizeMake(self.scrollView.width, contentSizeH);
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = (_imageContainerView.height <= self.height) ? NO : YES;
    _imageView.frame = _imageContainerView.bounds;
    
    [self refreshScrollViewContentSize];
}

- (void)refreshScrollViewContentSize {
    if (!_allowCrop) return;
    
    // 1.让contentSize增大(裁剪框右下角的图片部分)
    CGFloat contentWidthAdd = self.scrollView.width - CGRectGetMaxX(_cropRect);
    CGFloat contentHeightAdd = (MIN(_imageContainerView.height, self.height) - self.cropRect.size.height) / 2;
    CGFloat newSizeW = self.scrollView.contentSize.width + contentWidthAdd;
    CGFloat newSizeH = MAX(self.scrollView.contentSize.height, self.height) + contentHeightAdd;
    _scrollView.contentSize = CGSizeMake(newSizeW, newSizeH);
    _scrollView.alwaysBounceVertical = YES;
    // 2.让scrollView新增滑动区域（裁剪框左上角的图片部分）
    if (contentHeightAdd > 0 || contentWidthAdd > 0) {
        _scrollView.contentInset = UIEdgeInsetsMake(contentHeightAdd, _cropRect.origin.x, 0, 0);
    } else {
        _scrollView.contentInset = UIEdgeInsetsZero;
    }
}

#pragma mark - UITapGestureRecognizer Event

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        _scrollView.contentInset = UIEdgeInsetsZero;
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}
- (void)pan:(UIPanGestureRecognizer *)g {
    /*
    switch (g.state) {
        case UIGestureRecognizerStateBegan: {
            if (_isPresented) {
                _panGestureBeginPoint = [g locationInView:self];
            } else {
                _panGestureBeginPoint = CGPointZero;
            }
        } break;
        case UIGestureRecognizerStateChanged: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint p = [g locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            _scrollView.top = deltaY;
            
            CGFloat alphaDelta = 160;
            CGFloat alpha = (alphaDelta - fabs(deltaY) + 50) / alphaDelta;
            alpha = MIN(1, MAX(0, alpha));
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
                _blurBackground.alpha = alpha;
                _pager.alpha = alpha;
            } completion:nil];
            
        } break;
        case UIGestureRecognizerStateEnded: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint v = [g velocityInView:self];
            CGPoint p = [g locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            
            if (fabs(v.y) > 1000 || fabs(deltaY) > 120) {
                [self cancelAllImageLoad];
                _isPresented = NO;
                [[UIApplication sharedApplication] setStatusBarHidden:_fromNavigationBarHidden withAnimation:UIStatusBarAnimationFade];
                
                BOOL moveToTop = (v.y < - 50 || (v.y < 50 && deltaY < 0));
                CGFloat vy = fabs(v.y);
                if (vy < 1) vy = 1;
                CGFloat duration = (moveToTop ? _scrollView.bottom : self.height - _scrollView.top) / vy;
                duration *= 0.8;
                duration = MIN(0.3, MAX(0.05, duration));
                
                [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    _blurBackground.alpha = 0;
                    _pager.alpha = 0;
                    if (moveToTop) {
                        _scrollView.bottom = 0;
                    } else {
                        _scrollView.top = self.height;
                    }
                } completion:^(BOOL finished) {
                    [self removeFromSuperview];
                }];
                
                _background.image = _snapshotImage;
                [_background.layer __addFadeAnimationWithDuration:0.3 curve:UIViewAnimationCurveEaseInOut];
                
            } else {
                [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:v.y / 1000 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    _scrollView.top = 0;
                    _blurBackground.alpha = 1;
                    _pager.alpha = 1;
                } completion:^(BOOL finished) {
                    
                }];
            }
            
        } break;
        case UIGestureRecognizerStateCancelled : {
            _scrollView.top = 0;
            _blurBackground.alpha = 1;
        }
        default:break;
    }
     */
}
#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageContainerView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self refreshScrollViewContentSize];
}

#pragma mark - Private

- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (_scrollView.width > _scrollView.contentSize.width) ? ((_scrollView.width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scrollView.height > _scrollView.contentSize.height) ? ((_scrollView.height - _scrollView.contentSize.height) * 0.5) : 0.0;
    self.imageContainerView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}

@end


@implementation ZDProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.fillColor = [[UIColor clearColor] CGColor];
        _progressLayer.strokeColor = [[UIColor whiteColor] CGColor];
        _progressLayer.opacity = 1;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.lineWidth = 5;
        
        [_progressLayer setShadowColor:[UIColor blackColor].CGColor];
        [_progressLayer setShadowOffset:CGSizeMake(1, 1)];
        [_progressLayer setShadowOpacity:0.5];
        [_progressLayer setShadowRadius:2];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    CGFloat radius = rect.size.width / 2;
    CGFloat startA = - M_PI_2;
    CGFloat endA = - M_PI_2 + M_PI * 2 * _progress;
    _progressLayer.frame = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    _progressLayer.path =[path CGPath];
    
    [_progressLayer removeFromSuperlayer];
    [self.layer addSublayer:_progressLayer];
}

- (void)setProgress:(double)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

@end
