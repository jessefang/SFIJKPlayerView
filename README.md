# SFIJKPlayerView
simple mediaPlayer based by IJKPlayer


![Gif icon](https://github.com/jessefang/SFIJKPlayerView/blob/master/Untitled.gif)

# before
first u should add the IJKMediaFramework.framework (cause it too big to commit)
* 1 here is [IJKPlayer](https://github.com/Bilibili/ijkplayer)

* 2 here is a [artical](http://blog.csdn.net/levilly/article/details/52151095) to show u how to add framework to your project  

# usage
    SFIJKPlayerView *playerView = [[SFIJKPlayerView alloc]initWithUrl:url WithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.width * (9.0 / 16.0))];
    [self.view addSubview:playerView];

