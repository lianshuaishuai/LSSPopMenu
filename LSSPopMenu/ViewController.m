//
//  ViewController.m
//  LSSPopMenu
//
//  Created by 连帅帅 on 2020/10/24.
//

#import "ViewController.h"
#import "LSSPopMenu.h"
#import "Masonry.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(200, 130, 200, 200)];
    bgView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:bgView];
    self.view.backgroundColor = [UIColor redColor];
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    view1.backgroundColor = [UIColor orangeColor];
//    LSSPopMenu *menu = [[LSSPopMenu alloc]initWithRelyonView:bgView manger:^(LSSPopMenuManger * _Nonnull manger) {
//        manger.contentView = view1;
//    }];
    LSSPopMenu *menu = [[LSSPopMenu alloc]initWithPoint:CGPointMake(5, 88) manger:^(LSSPopMenuManger * _Nonnull manger) {
        manger.contentView = view1;
//        manger.isShowShadow = YES;
//        manger.isLayout = YES;
//        manger.contentViewRect =CGRectMake(0, 0, 100, 100);
    }];

    [menu show];
}


@end
