//
//  ZDImagePreviewCell.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/1/5.
//

#import <UIKit/UIKit.h>

@class ZDImageModel, ZDPhotoPreviewView, ZDProgressView;
@interface ZDImagePreviewCell : UICollectionViewCell
@property (nonatomic, strong) ZDImageModel *model;
@property (nonatomic, copy  ) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy  ) void (^imageProgressUpdateBlock)(double progress);
@property (nonatomic, strong) ZDPhotoPreviewView *previewView;
@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;

- (void)recoverSubviews;
@end


@interface ZDPhotoPreviewView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) ZDProgressView *progressView;

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, strong) ZDImageModel *model;
//@property (nonatomic, strong) id asset;
@property (nonatomic, copy  ) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy  ) void (^imageProgressUpdateBlock)(double progress);

- (void)recoverSubviews;
@end


@interface ZDProgressView : UIView
@property (nonatomic, assign) double progress;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@end

