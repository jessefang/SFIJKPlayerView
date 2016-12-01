//
//  ViewController.m
//  SFIJKPlayer
//
//  Created by 方世峰 on 16/11/29.
//  Copyright © 2016年 richinginfo. All rights reserved.
//

#import "ViewController.h"
#import "SFIJKPlayerView.h"
 
@interface ViewController (){
    BOOL isShowStatusBar;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSURL *url = [NSURL URLWithString:@"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8"];
    SFIJKPlayerView *playerView = [[SFIJKPlayerView alloc]initWithUrl:url WithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.width * (9.0 / 16.0))];

    [self.view addSubview:playerView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(navigationBarHidden:) name:@"NavigationHidden" object:nil];

}

//隐藏导航栏、状态栏
- (void)navigationBarHidden:(NSNotification *)note{
    NSString *judgeStr = [note object];
    if ([judgeStr intValue]) {
        self.navigationController.navigationBar.hidden = NO;
        isShowStatusBar = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        self.tabBarController.tabBar.hidden = NO;
    }
    else{
        self.navigationController.navigationBar.hidden = YES;
        isShowStatusBar = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        self.tabBarController.tabBar.hidden = YES;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden{
    return isShowStatusBar;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NavigationHidden" object:nil];

}
@end
