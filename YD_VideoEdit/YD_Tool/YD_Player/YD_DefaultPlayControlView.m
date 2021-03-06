//
//  YD_DefaultPlayControlView.m
//  YD_VideoEidtManager
//
//  Created by mac on 2019/6/26.
//  Copyright © 2019 mac. All rights reserved.
//

#import "YD_DefaultPlayControlView.h"
#import "YD_Slider.h"

@interface YD_DefaultPlayControlView ()

@property (nonatomic, weak) UIButton *bigPlayBtn;

@property (nonatomic, weak) UIView *containView;
@property (nonatomic, weak) YD_Slider *slider;
@property (nonatomic, weak) UILabel *timeLbl;
@property (nonatomic, weak) UIButton *playBtn;

@end

@implementation YD_DefaultPlayControlView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self yd_layoutSubViews];
        [self yd_layoutConstraints];
    }
    return self;
}

- (void)yd_layoutSubViews {
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(yd_tapGesture)]];
    
    {

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.bigPlayBtn = button;
        [button setImage:[UIImage yd_imageWithName:@"yd_big_pause@3x"] forState:UIControlStateNormal];
        [button setImage:[UIImage yd_imageWithName:@"yd_big_play@3x"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(yd_playBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    {
        UIView *view = [UIView new];
        self.containView = view;
        [self addSubview:view];
    }
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.playBtn = button;
        button.imageEdgeInsets = UIEdgeInsetsMake(1, 0, -1, 0);
        [button setImage:[UIImage yd_imageWithName:@"yd_pause@3x"] forState:UIControlStateNormal];
        [button setImage:[UIImage yd_imageWithName:@"yd_play@3x"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(yd_playBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.containView addSubview:button];
    }
    {
        UILabel *label = [UILabel new];
        self.timeLbl = label;
        label.textAlignment = 1;
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:12];
        label.text = @"0:00/0:00";
        [self.containView addSubview:label];
    }
    {
        YD_Slider *slider = [YD_Slider new];
        self.slider = slider;
        slider.left_offset = 5;
        slider.right_offset = 4;
        slider.minimumValue = 0;
        slider.maximumValue = 1;
        [slider setThumbImage:[UIImage yd_imageWithName:@"yd_slider_2@3x"] forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        slider.maximumTrackTintColor = [UIColor colorWithHexString:@"#999999"];
        [self.containView addSubview:slider];
    }
}

- (void)yd_layoutConstraints {
    [self.bigPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(50);
    }];
    
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.inset(0);
        make.height.mas_equalTo(44);
    }];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.top.bottom.inset(0);
        make.left.inset(3);
    }];
    
    [self.timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.inset(14);
        make.top.bottom.inset(0);
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.inset(0);
        make.right.equalTo(self.timeLbl.mas_left).inset(12);
        make.left.equalTo(self.playBtn.mas_right).inset(2);
    }];
}

#pragma mark - setter
- (void)setThemeColor:(UIColor *)themeColor {
    self.slider.minimumTrackTintColor = themeColor;
}

- (void)setYd_hiddenBar:(BOOL)yd_hiddenBar {
    _yd_hiddenBar = yd_hiddenBar;
    self.containView.hidden = YES;
}

#pragma mark - UI事件
- (void)yd_tapGesture {
    if (_yd_hiddenBar) {
        self.containView.hidden = YES;
    }else {
        self.containView.hidden = !self.containView.hidden;
    }
    self.bigPlayBtn.hidden = !self.bigPlayBtn.hidden;
}

- (void)yd_playBtnAction {
    if (self.player.yd_playStatus == YD_PlayStatusPlay) {
        [self.player yd_pause];
    }else {
        [self.player yd_play];
    }
}

- (void)sliderAction:(UISlider *)slider {
    [self.player yd_seekToTime:slider.value];
}

#pragma mark - YD_PlayerViewDelegate
- (void)yd_player:(YD_PlayerView *_Nonnull)player currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    
    self.slider.value = currentTime / totalTime;
    
    NSString *current_time = [NSString timeToString:currentTime format:@"%zd:%02zd"];
    NSString *total_time = [NSString timeToString:totalTime format:@"%zd:%02zd"];
    
    self.timeLbl.text = [NSString stringWithFormat:@"%@/%@",current_time, total_time];
}

- (void)yd_player:(YD_PlayerView *_Nonnull)player playStateChanged:(YD_PlayStatus)status {
    if (status == YD_PlayStatusFinish) {
        [self.player yd_replay];
    }else {
        BOOL isPlay = status == YD_PlayStatusPlay;
        self.bigPlayBtn.selected = isPlay;
        self.playBtn.selected = isPlay;
    }
}

@end
