//
//  ZDImageGroupPreviewController.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/1/5.
//

#import <UIKit/UIKit.h>

@interface ZDImageGroupPreviewController : UIViewController

@property (nonatomic, strong) NSMutableArray *models; ///< All photo models / 所有图片模型数组
@property (nonatomic, assign) NSInteger currentIndex; ///< Index of the photo user click / 用户点击的图片的索引

@end
