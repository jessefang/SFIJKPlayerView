# SFIJKPlayerView
simple mediaPlayer based by IJKPlayer
# before
first,first u should add the IJKMediaFramework.framework (cause it too big for commit to git)
here is [IJKPlayer](https://github.com/Bilibili/ijkplayer)
# usage
    SFIJKPlayerView *playerView = [[SFIJKPlayerView alloc]initWithUrl:url WithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.width * (9.0 / 16.0))];
    [self.view addSubview:playerView];

