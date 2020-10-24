//
//  LSSPopMenu.h
//  LSSPopMenu
//
//  Created by 连帅帅 on 2020/10/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface LSSPopMenuManger : NSObject
/**
 自定义内容又外部传入
 */
@property(nonatomic, strong)UIView *contentView;
/**
 圆角 默认5
 */
@property(nonatomic, assign)CGFloat cornerRaius;

/**
 
 背景颜色(默认白色)
 */
@property(nonatomic, strong)UIColor *backGroundCor;

/**
 是否有阴影 默认无
 */
@property(nonatomic, assign)BOOL isShowShadow;

/**
 阴影颜色 默认灰色
 */
@property(nonatomic, strong)UIColor *shadowCor;

/**
 是否是自动布局（不需要在外部设置自动布局的代码）--使用原生的自动布局 脱离masnory
 */
@property(nonatomic, assign)BOOL isLayout;

/**
 是自动布局的时候此参数必须传入
 */
@property(nonatomic, assign)CGRect contentViewRect;
@end

@interface LSSPopMenu : UIView

-(instancetype)initWithPoint:(CGPoint)point manger:(void (^) (LSSPopMenuManger *manger))mangerBlock;

-(instancetype)initWithRelyonView:(id)view manger:(void (^) (LSSPopMenuManger *manger))mangerBlock;

- (void)show;

- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
