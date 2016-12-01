//
//  SFIJKPlayerView.m
//  SFIJKPlayer
//
//  Created by 方世峰 on 16/11/29.
//  Copyright © 2016年 richinginfo. All rights reserved.
//

#import "SFIJKPlayerView.h"
#import "PlayerToolBar.h"

@interface SFIJKPlayerView(){
    BOOL isToolBarHidden;
    NSTimer *timer;
    BOOL isFullScreen;
    CGRect normalScreenFrame;

}

@property (strong, atomic)NSURL *url;
@property (strong, atomic)id <IJKMediaPlayback> mediaPlayer;
@property (strong, nonatomic)PlayerToolBar *playToolBar;
@property (strong,nonatomic)UIActivityIndicatorView *indicatorView;

@end

@implementation SFIJKPlayerView


- (instancetype)initWithUrl:(NSURL *)url WithFrame:(CGRect)frame{
    self = [super init];
    if (self) {
        self.url = url;
        self.frame = frame;
        isToolBarHidden = NO;
        [self setupPlayer];
        [self.mediaPlayer.view addSubview:self.playToolBar];
        [self configToolBarAction];
        [self addSubview:self.mediaPlayer.view];
        [self addSubview:self.indicatorView];
        [self addIJKNotificationObservers];
        [self listenDeviceRotating];
        [self.indicatorView startAnimating];
        self.playToolBar.hidden = NO;
        [self.playToolBar showAndFade];
        [self.mediaPlayer prepareToPlay];
    }
    return self;
}

- (void)setupPlayer{
    self.backgroundColor = [UIColor lightGrayColor];
    normalScreenFrame = self.frame;
    
    IJKFFOptions *options;
    [options setCodecOptionIntValue:IJK_AVDISCARD_DEFAULT
                             forKey:@"skip_loop_filter"];
    [options setCodecOptionIntValue:IJK_AVDISCARD_DEFAULT
                             forKey:@"skip_frame"];
    [options setPlayerOptionIntValue:1 forKey:@"videotoolbox"];
    [options setPlayerOptionIntValue:8 forKey:@"framedrop"];
    
    if (!self.mediaPlayer) {
        self.mediaPlayer = [[IJKFFMoviePlayerController alloc]initWithContentURL:self.url withOptions:options];
        self.mediaPlayer.view.frame = self.bounds;
        self.mediaPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        [self.mediaPlayer setScalingMode:IJKMPMovieScalingModeAspectFill];
    }
}

- (void)configToolBarAction{
    [self.playToolBar.playButton addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.playToolBar.stopButton addTarget:self action:@selector(stopBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.playToolBar.fullScreenButton addTarget:self action:@selector(fullScreenBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.playToolBar.normalScreenButton addTarget:self action:@selector(normalScreenBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.playToolBar.progressSlider addTarget:self action:@selector(sliderTouchBegan) forControlEvents:UIControlEventTouchDown];
    [self.playToolBar.progressSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.playToolBar.progressSlider addTarget:self action:@selector(sliderTouchEndedInside) forControlEvents:UIControlEventTouchUpInside];
    [self.playToolBar.progressSlider addTarget:self action:@selector(sliderTouchEndedOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.playToolBar.progressSlider addTarget:self action:@selector(sliderTouchCancel) forControlEvents:UIControlEventTouchCancel];
}

- (void)playBtnClick{
    [self.mediaPlayer play];
    self.playToolBar.playButton.hidden = YES;
    self.playToolBar.stopButton.hidden = NO;
}

- (void)stopBtnClick{
    [self.mediaPlayer pause];
    self.playToolBar.playButton.hidden = NO;
    self.playToolBar.stopButton.hidden = YES;
}

- (void)fullScreenBtnClick{
    if (isFullScreen) {
        return;
    }
    [self fullScreenForRight];
}

- (void)normalScreenBtnClick{
    if (!isFullScreen) {
        return;
    }
    [self ScreenForNormal];
}

- (void)sliderTouchBegan{
    [self.playToolBar beginDragProgressSlider];
}

- (void)sliderValueChanged{
    [self.playToolBar continueDragProgressSlider];
}

- (void)sliderTouchEndedInside{
    self.mediaPlayer.currentPlaybackTime = self.playToolBar.progressSlider.value;
    [self.playToolBar endDragProgressSlider];
}

- (void)sliderTouchEndedOutside{
    [self.playToolBar endDragProgressSlider];
}

- (void)sliderTouchCancel{
    [self.playToolBar endDragProgressSlider];
}

- (void)addIJKNotificationObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:self.mediaPlayer];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:self.mediaPlayer];
}

- (void)loadStateDidChange:(NSNotification*)notification{
    [self.indicatorView startAnimating];
    
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    IJKMPMovieLoadState loadState = self.mediaPlayer.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        [self.indicatorView startAnimating];
        
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);

            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);

            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification {
    NSLog(@"mediaIsPrepareToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward
    
    switch (self.mediaPlayer.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)self.mediaPlayer.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)self.mediaPlayer.playbackState);
            
            [self.indicatorView stopAnimating];
            
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)self.mediaPlayer.playbackState);
            [self.indicatorView stopAnimating];
            
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)self.mediaPlayer.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)self.mediaPlayer.playbackState);
            [self.indicatorView startAnimating];
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)self.mediaPlayer.playbackState);
            break;
        }
    }
}

- (void)listenDeviceRotating{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deviceOrientationChange{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationUnknown:
            NSLog(@"未知方向");
            break;
        case UIInterfaceOrientationLandscapeLeft:
            NSLog(@"Home键在左");
            [self fullScreenForLeft];
            break;
        case UIInterfaceOrientationLandscapeRight:
            NSLog(@"Home键在右");
            [self fullScreenForRight];
            break;
        case UIInterfaceOrientationPortrait:
            NSLog(@"Home键在下");
            [self ScreenForNormal];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            NSLog(@"Home键在上");
            [self ScreenForNormal];

            break;
        default:
            break;
    }
}

- (void)fullScreenForRight{
    //0表示隐藏导航栏
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NavigationHidden" object:@"0"];
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
    self.frame = frame;
    self.mediaPlayer.view.frame = CGRectMake(0, 0, width, height);
    self.playToolBar.frame = CGRectMake(0, height - 40, width, height);
    self.indicatorView.frame = CGRectMake(width / 2 - 20, height / 2 - 20, 40, 40);
    [self.playToolBar setNeedsDisplay];
    [self.playToolBar layoutIfNeeded];
    [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    isFullScreen = YES;
    self.playToolBar.fullScreenButton.hidden = YES;
    self.playToolBar.normalScreenButton.hidden = NO;
}

- (void)fullScreenForLeft{
    //0表示隐藏导航栏
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NavigationHidden" object:@"0"];
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
    self.frame = frame;
    self.mediaPlayer.view.frame = CGRectMake(0, 0, width, height);
    self.playToolBar.frame = CGRectMake(0, height - 40, width, height);
    self.indicatorView.frame = CGRectMake(width / 2 - 20, height / 2 - 20, 40, 40);
    [self.playToolBar setNeedsDisplay];
    [self.playToolBar layoutIfNeeded];
    [self setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    isFullScreen = YES;
    self.playToolBar.fullScreenButton.hidden = YES;
    self.playToolBar.normalScreenButton.hidden = NO;
}

- (void)ScreenForNormal{
    //1表示显示导航栏
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NavigationHidden" object:@"1"];
    [self setTransform:CGAffineTransformIdentity];
    self.frame = CGRectMake(0, normalScreenFrame.origin.y, normalScreenFrame.size.width, normalScreenFrame.size.height);
    self.mediaPlayer.view.frame = CGRectMake(0, 0, normalScreenFrame.size.width, normalScreenFrame.size.height);
    self.playToolBar.frame = CGRectMake(0, normalScreenFrame.size.height - 40, normalScreenFrame.size.width, 40);
    self.indicatorView.frame = CGRectMake(normalScreenFrame.size.width / 2 - 20, normalScreenFrame.size.height / 2 - 20, 40, 40);
    isFullScreen = NO;
    self.playToolBar.fullScreenButton.hidden = NO;
    self.playToolBar.normalScreenButton.hidden = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (event.allTouches.count == 1) {
        if (isToolBarHidden) {
            [self.playToolBar hideToolBar];
            isToolBarHidden = NO;
        }else{
            [self.playToolBar showAndFade];
            isToolBarHidden = YES;
        }
    }
}

-(void)removeMovieNotificationObservers{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.mediaPlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:self.mediaPlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:self.mediaPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:self.mediaPlayer];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self removeMovieNotificationObservers];
    [self.mediaPlayer stop];
    [self.mediaPlayer shutdown];
    
}

- (UIActivityIndicatorView *)indicatorView{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.frame = CGRectMake(self.bounds.size.width / 2 - 20, self.bounds.size.height / 2 - 20, 40, 40);
    }
    return _indicatorView;
}

- (PlayerToolBar *)playToolBar{
    if (!_playToolBar) {
        _playToolBar = [[PlayerToolBar alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 40, self.frame.size.width, 40)];
        _playToolBar.delegatePlayer = _mediaPlayer;
    }
    return _playToolBar;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
