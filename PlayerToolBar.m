//
//  PlayerToolBar.m
//  SFIJKPlayer
//
//  Created by 方世峰 on 16/12/1.
//  Copyright © 2016年 richinginfo. All rights reserved.
//

#import "PlayerToolBar.h"
#import <IJKMediaFramework/IJKMediaFramework.h>

static const CGFloat playerToolBarHeight = 40;

@interface PlayerToolBar (){
    
    BOOL isProgressSliderDragged;
}
@end

@implementation PlayerToolBar
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
        [self addSubview:self.bottomView];
        [self.bottomView addSubview:self.playButton];
        [self.bottomView addSubview:self.stopButton];
        [self.bottomView addSubview:self.timeLable];
        [self.bottomView addSubview:self.fullScreenButton];
        [self.bottomView addSubview:self.normalScreenButton];
        [self.bottomView addSubview:self.progressSlider];
        self.normalScreenButton.hidden = YES;
        self.playButton.hidden = YES;
        self.progressSlider.hidden = NO;
    }
    return self;
}

- (void)layoutSubviews{
    self.bottomView.frame = CGRectMake(CGRectGetMinX(self.bounds), 0, CGRectGetWidth(self.bounds), playerToolBarHeight);
    self.playButton.frame = CGRectMake(CGRectGetMinX(self.bottomView.bounds), CGRectGetHeight(self.bottomView.bounds) / 2 - CGRectGetHeight(self.playButton.bounds) / 2, CGRectGetWidth(self.playButton.bounds), playerToolBarHeight);
    self.stopButton.frame = self.playButton.frame;
    self.fullScreenButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.bottomView.bounds) / 2 - CGRectGetHeight(self.fullScreenButton.bounds) / 2, CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.fullScreenButton.bounds));
    self.normalScreenButton.frame = self.fullScreenButton.frame;
    self.progressSlider.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame), CGRectGetHeight(self.bottomView.bounds)/2 - CGRectGetHeight(self.progressSlider.bounds)/2, CGRectGetMinX(self.fullScreenButton.frame) - CGRectGetMaxX(self.playButton.frame), CGRectGetHeight(self.progressSlider.bounds));
    
    self.timeLable.frame = CGRectMake(CGRectGetMidX(self.progressSlider.frame), CGRectGetHeight(self.bottomView.bounds) - CGRectGetHeight(self.timeLable.bounds) - 2.0, CGRectGetWidth(self.progressSlider.bounds)/2, CGRectGetHeight(self.timeLable.bounds));
}

- (void)showNoFade{
    self.bottomView.hidden = NO;
    [self refreshPlayerContrl];
}

- (void)showAndFade{
    [self showNoFade];
    [self performSelector:@selector(hideToolBar) withObject:nil afterDelay:5];
}

- (void)hideToolBar{
    self.bottomView.hidden = YES;
    [self cancelDelayHideToolBar];
}

- (void)cancelDelayHideToolBar {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToolBar) object:nil];
}

- (void)beginDragProgressSlider{
    isProgressSliderDragged = YES;
}

- (void)endDragProgressSlider{
    isProgressSliderDragged = NO;
}

- (void)continueDragProgressSlider{
    [self refreshPlayerContrl];
}

- (void)refreshPlayerContrl{
    NSTimeInterval duration = self.delegatePlayer.duration;
    NSInteger intDuration = duration + 0.5;
    if (intDuration > 0) {
        self.progressSlider.maximumValue = duration;
    }else{
        self.progressSlider.maximumValue = 1.0f;
        self.timeLable.text = @"--:--";
    }
    
    NSTimeInterval position;
    if (isProgressSliderDragged) {
        position = self.progressSlider.value;
    }else{
        position = self.delegatePlayer.currentPlaybackTime;
    }
    NSInteger intPosition = position + 0.5;
    if (intPosition > 0) {
        self.progressSlider.value = position;
    }else{
        self.progressSlider.value = 0.0;
    }
    self.timeLable.text = [NSString stringWithFormat:@"%02d:%02d/%02d:%02d",(int)(intPosition / 60), (int)(intPosition % 60), (int)intDuration / 60, (int)intDuration % 60];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshPlayerContrl) object:nil];
    if (!self.bottomView.hidden) {
        [self performSelector:@selector(refreshPlayerContrl) withObject:nil afterDelay:0.5];
    }
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _bottomView;
}

- (UIButton *)playButton{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"player-play"] forState:UIControlStateNormal];
        _playButton.bounds = CGRectMake(0, 0, playerToolBarHeight, playerToolBarHeight);
    }
    return _playButton;
}

- (UIButton *)stopButton{
    if (!_stopButton) {
        _stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stopButton setImage:[UIImage imageNamed:@"player-stop"] forState:UIControlStateNormal];
        _stopButton.bounds = CGRectMake(0, 0, playerToolBarHeight, playerToolBarHeight);
    }
    return _stopButton;
}

- (UISlider *)progressSlider{
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc]init];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"player-point"] forState:UIControlStateNormal];
        [_progressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
        [_progressSlider setMaximumTrackTintColor:[UIColor grayColor]];
        _progressSlider.value = 0.f;
    }
    return _progressSlider;
}

- (UIButton *)fullScreenButton{
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:[UIImage imageNamed:@"player-fullscreen"] forState:UIControlStateNormal];
        _fullScreenButton.bounds = CGRectMake(0, 0, playerToolBarHeight, playerToolBarHeight);
    }
    return _fullScreenButton;
}

- (UIButton *)normalScreenButton{
    if (!_normalScreenButton) {
        _normalScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_normalScreenButton setImage:[UIImage imageNamed:@"player-normalscreen"] forState:UIControlStateNormal];
        _normalScreenButton.bounds = CGRectMake(0, 0, playerToolBarHeight, playerToolBarHeight);
    }
    return _normalScreenButton;
}

- (UILabel *)timeLable{
    if (!_timeLable) {
        _timeLable = [[UILabel alloc]init];
        _timeLable.backgroundColor = [UIColor clearColor];
        _timeLable.font = [UIFont systemFontOfSize:10];
        _timeLable.textColor = [UIColor whiteColor];
        _timeLable.textAlignment = NSTextAlignmentRight;
        _timeLable.bounds = CGRectMake(0, 0, 10, 10);
    }
    return _timeLable;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
