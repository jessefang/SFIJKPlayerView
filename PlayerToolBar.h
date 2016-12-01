//
//  PlayerToolBar.h
//  SFIJKPlayer
//
//  Created by 方世峰 on 16/12/1.
//  Copyright © 2016年 richinginfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IJKMediaPlayback;

@interface PlayerToolBar : UIControl

@property (weak, nonatomic)id<IJKMediaPlayback>delegatePlayer;
@property (strong,nonatomic)UIButton *playButton;
@property (strong,nonatomic)UIButton *stopButton;
@property (strong,nonatomic)UILabel *timeLable;
@property (strong,nonatomic)UIButton *fullScreenButton;
@property (strong,nonatomic)UIButton *normalScreenButton;
@property (strong,nonatomic)UISlider *progressSlider;
@property (strong,nonatomic)UIView *bottomView;
@property (strong, nonatomic) UIActivityIndicatorView* indicator;

- (void)refreshPlayerContrl;
- (void)showNoFade;
- (void)showAndFade;
- (void)hideToolBar;

- (void)beginDragProgressSlider;
- (void)endDragProgressSlider;
- (void)continueDragProgressSlider;

@end
