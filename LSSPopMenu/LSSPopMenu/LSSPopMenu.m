//
//  LSSPopMenu.m
//  LSSPopMenu
//
//  Created by 连帅帅 on 2020/10/24.
//

#import "LSSPopMenu.h"
#define kMainWindow                [UIApplication sharedApplication].keyWindow
#define kScreenWidth               [UIScreen mainScreen].bounds.size.width
#define kScreenHeight              [UIScreen mainScreen].bounds.size.height
#define kArrowWidth          10
#define kArrowHeight         8
#define kDefaultMargin       10
#define kAnimationTime       0.25
@implementation LSSPopMenuManger
-(instancetype)init{
    if (self = [super init]) {
        self.cornerRaius = 5;
        self.shadowCor = [UIColor lightGrayColor];
        self.backGroundCor = [UIColor whiteColor];
    }
    return self;
}

@end

@interface LSSPopMenu()
{
    CGPoint          _refPoint;
    UIView          *_refView;
    CGFloat          _menuWidth;
    
    CGFloat         _arrowPosition; // 三角底部的起始点x
    CGFloat         _topMargin;
    BOOL            _isReverse; // 是否反向(默认向上 防微信聊天室的弹窗位置)
    BOOL            _needReload; //是否需要刷新
}
@property(nonatomic, strong)LSSPopMenuManger*manger;

@property(nonatomic, strong)UIView *bgView;

@end
@implementation LSSPopMenu
-(instancetype)initWithPoint:(CGPoint)point manger:(void (^)(LSSPopMenuManger * _Nonnull))mangerBlock{
    if (self = [super init]) {
        self.manger = [[LSSPopMenuManger alloc]init];
        if (mangerBlock) {
            mangerBlock(self.manger);
        }
        _refPoint = point;
        [self setUpConfig];
        [self setupSubView];
    }
    return self;
}

-(instancetype)initWithRelyonView:(id)view manger:(void (^)(LSSPopMenuManger * _Nonnull))mangerBlock{
    if (self = [super init]) {
        self.manger = [[LSSPopMenuManger alloc]init];
        if (mangerBlock) {
            mangerBlock(self.manger);
        }
        _refView = view;
        [self setUpConfig];
        [self setupSubView];
    }
    return self;
}
-(void)setUpConfig{
    self.backgroundColor = self.manger.backGroundCor;
    self.layer.cornerRadius = self.manger.cornerRaius;
}
- (void)setupSubView{
    [self addContentView];
    [self setUpArrowAndFrame];
    [self setupMaskLayer];
}
-(void)addContentView{
    [self addSubview:self.manger.contentView];
    if (self.manger.isLayout) {
        [self addConstraints:@[
            [NSLayoutConstraint constraintWithItem:self.manger.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:self.manger.contentViewRect.origin.x],
            [NSLayoutConstraint constraintWithItem:self.manger.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:self.manger.contentViewRect.size.width],
            [NSLayoutConstraint constraintWithItem:self.manger.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:self.manger.contentViewRect.origin.y],
            [NSLayoutConstraint constraintWithItem:self.manger.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:self.manger.contentViewRect.size.height]]];
    }
}
- (void)setUpArrowAndFrame{
    
    if (_refView) {
        _refPoint = [self getRefPoint];
    }
    
    CGFloat originX;
    CGFloat originY;
    CGFloat width;
    CGFloat height;
    CGFloat cornerRaius;
    width = self.manger.isLayout? self.manger.contentViewRect.size.width: self.manger.contentView.bounds.size.width;
    height = self.manger.isLayout? (self.manger.contentViewRect.size.height + kArrowHeight) :(self.manger.contentView.bounds.size.height + kArrowHeight);
    // 默认在中间
    _arrowPosition = 0.5 * width - 0.5 * kArrowWidth;
    
    // 设置出menu的x和y（默认情况）
    originX = _refPoint.x - _arrowPosition - 0.5 * kArrowWidth;
    originY = _refPoint.y;
    
    // 考虑向左右展示不全的情况，需要反向展示
    if (originX + width > kScreenWidth - 10) {
        originX = kScreenWidth - kDefaultMargin - width;
    }else if (originX < 10) {
        //向上的情况间距也至少是kDefaultMargin
        originX = kDefaultMargin;
    }

    cornerRaius = self.manger.cornerRaius;
    //设置三角形的起始点
    if ((_refPoint.x <= originX + width - cornerRaius) && (_refPoint.x >= originX + cornerRaius)) {
        _arrowPosition = _refPoint.x - originX - 0.5 * kArrowWidth;
    }else if (_refPoint.x < originX + cornerRaius) {
        _arrowPosition = cornerRaius;
    }else {
        _arrowPosition = width - cornerRaius - kArrowWidth;
    }
    
    //如果不是根据关联视图，得算一次是否反向
    if (!_refView) {
        //如果改成默认向下 就替换下面注释
        //        _isReverse = (originY + height > kScreenHeight - kDefaultMargin)?YES:NO;
        _isReverse = (originY - 44 > height + 10)?YES:NO;
    }
    
    CGPoint  anchorPoint;
    if (_isReverse) {
        originY = _refPoint.y - height;
        anchorPoint = CGPointMake(fabs(_arrowPosition) / width, 1);
        _topMargin = 0;
    }else{
        anchorPoint = CGPointMake(fabs(_arrowPosition) / width, 0);
        _topMargin = kArrowHeight;
    }
    //设置锚点
    self.layer.anchorPoint = anchorPoint;
    self.frame = CGRectMake(originX, originY, width, height);
}

- (void)setupMaskLayer{
    CAShapeLayer *layer = [self drawMaskLayer];
    self.layer.mask = layer;
}

- (CAShapeLayer *)drawMaskLayer{
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    CGFloat bottomMargin = !_isReverse?0 :kArrowHeight;
    CGFloat cornerRaius = self.manger.cornerRaius;
    // 定出四个转角点
    CGPoint topRightArcCenter = CGPointMake(self.bounds.size.width - cornerRaius, _topMargin + cornerRaius);
    CGPoint topLeftArcCenter = CGPointMake(cornerRaius, _topMargin + cornerRaius);
    CGPoint bottomRightArcCenter = CGPointMake(self.bounds.size.width - cornerRaius, self.bounds.size.height - bottomMargin - cornerRaius);
    CGPoint bottomLeftArcCenter = CGPointMake(cornerRaius, self.bounds.size.height - bottomMargin - cornerRaius);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    // 从左上倒角的下边开始画
    [path moveToPoint: CGPointMake(0, _topMargin + cornerRaius)];
    [path addLineToPoint: CGPointMake(0, bottomLeftArcCenter.y)];
    [path addArcWithCenter: bottomLeftArcCenter radius: cornerRaius startAngle: -M_PI endAngle: -M_PI-M_PI_2 clockwise: NO];
    
    if (_isReverse) {
        [path addLineToPoint: CGPointMake(_arrowPosition, self.bounds.size.height - kArrowHeight)];
        [path addLineToPoint: CGPointMake(_arrowPosition + 0.5*kArrowWidth, self.bounds.size.height)];
        [path addLineToPoint: CGPointMake(_arrowPosition + kArrowWidth, self.bounds.size.height - kArrowHeight)];
    }
    [path addLineToPoint: CGPointMake(self.bounds.size.width - cornerRaius, self.bounds.size.height - bottomMargin)];
    [path addArcWithCenter: bottomRightArcCenter radius: cornerRaius startAngle: -M_PI-M_PI_2 endAngle: -M_PI*2 clockwise: NO];
    [path addLineToPoint: CGPointMake(self.bounds.size.width, self.bounds.size.height - bottomMargin + cornerRaius)];
    [path addArcWithCenter: topRightArcCenter radius: cornerRaius startAngle: 0 endAngle: -M_PI_2 clockwise: NO];
    
    if (!_isReverse) {
        [path addLineToPoint: CGPointMake(_arrowPosition + kArrowWidth, _topMargin)];
        [path addLineToPoint: CGPointMake(_arrowPosition + 0.5 * kArrowWidth, 0)];
        [path addLineToPoint: CGPointMake(_arrowPosition, _topMargin)];
    }
    
    [path addLineToPoint: CGPointMake(cornerRaius, _topMargin)];
    [path addArcWithCenter: topLeftArcCenter radius: cornerRaius startAngle: -M_PI_2 endAngle: -M_PI clockwise: NO];
    [path closePath];
    
    maskLayer.path = path.CGPath;
    return maskLayer;
}

- (CGPoint)getRefPoint{
    CGFloat height = self.manger.contentView.bounds.size.height;
    CGRect absoluteRect = [_refView convertRect:_refView.bounds toView:kMainWindow];
    CGPoint refPoint;
    //如果改成默认向下 就替换下面if判断的内容
    //absoluteRect.origin.y + absoluteRect.size.height + height > kScreenHeight - 10
    if (absoluteRect.origin.y - 44 >  height + kArrowHeight + 10) {
        refPoint = CGPointMake(absoluteRect.origin.x + absoluteRect.size.width / 2, absoluteRect.origin.y);
        _isReverse = YES;
    }else{
        refPoint = CGPointMake(absoluteRect.origin.x + absoluteRect.size.width / 2, absoluteRect.origin.y + absoluteRect.size.height);
        _isReverse = NO;
    }
    return refPoint;
}
- (void)show{
    
    [kMainWindow addSubview: self.bgView];
    [kMainWindow addSubview: self];
    self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration: kAnimationTime animations:^{
        self.layer.affineTransform = CGAffineTransformMakeScale(1.0, 1.0);
        self.alpha = 1.0f;
        self.bgView.alpha = 1.0f;
    }];
}

- (void)dismiss{
    [UIView animateWithDuration: kAnimationTime animations:^{
        self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
        self.alpha = 0.0f;
        self.bgView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.bgView removeFromSuperview];
    }];
}
#pragma mark--getter
- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        _bgView.backgroundColor = self.manger.isShowShadow? self.manger.shadowCor : [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [_bgView addGestureRecognizer:tap];
    }
    return _bgView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
