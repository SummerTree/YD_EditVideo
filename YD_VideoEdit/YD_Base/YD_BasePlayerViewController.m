//
//  YD_BasePlayerViewController.m
//  YD_VideoEidtManager
//
//  Created by mac on 2019/7/1.
//  Copyright © 2019 mac. All rights reserved.
//

#import "YD_BasePlayerViewController.h"

@interface YD_BasePlayerViewController ()

@property (nonatomic, weak) YD_DefaultPlayControlView *playControl;
@property (nonatomic, weak) YD_PlayerView *player;
@property (nonatomic, weak) YD_BottomBar *bottomBar;

@property (nonatomic, strong) YD_PlayerModel *playModel;

@end

@implementation YD_BasePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.player.yd_viewControllerAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.player.yd_viewControllerAppear = NO;
}

- (void)yd_setupConfig {
    if (!self.model) {
        self.model = [YD_ConfigModel new];
    }
    
    self.playModel = [YD_PlayerModel new];
    self.playModel.asset = self.model.asset;
    self.playModel.coverImage = [self.model.asset yd_getVideoImage:0];
    
    self.title = [self yd_title];
    self.view.backgroundColor = self.model.controllerColor;
}

- (void)yd_layoutSubViews {
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 50, 18);
        button.backgroundColor = self.model.themeColor;
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 4;
        [button setTitle:@"完成" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(yd_completeItemAction) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        
        UIBarButtonItem *okItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = okItem;
    }
    {
        YD_DefaultPlayControlView *playControl = [YD_DefaultPlayControlView new];
        playControl.themeColor = self.model.themeColor;
        self.playControl = playControl;
    
        YD_PlayerView *player = [YD_PlayerView new];
        player.backgroundColor = self.model.playerBackColor;
        self.player = player;
        player.yd_model = self.playModel;
        player.yd_controlView = playControl;
        [self.view addSubview:player];
        
        [player yd_play];
    }
    {
        YD_BottomBar *bar = [YD_BottomBar addBar:[self yd_title] imgName:[self yd_barIconName]];
        self.bottomBar = bar;
        [self.view addSubview:bar];
    }
}

- (void)yd_layoutConstraints {

    CGFloat topInset = self.navigationController.navigationBar.translucent ? YD_TopBarHeight : 0;
    
    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.inset(0);
        make.top.inset(topInset);
        make.height.equalTo(self.player.mas_width);
    }];

    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.inset(0);
        make.height.mas_equalTo(YD_BottomBarH);
    }];
}

#pragma mark - 子类需要重写的方法
- (NSString *)yd_title {
    return @"";
}

- (NSString *)yd_barIconName {
    return @"";
}
/// 点击完成的处理
- (void)yd_completeItemAction {
    
}

@end

