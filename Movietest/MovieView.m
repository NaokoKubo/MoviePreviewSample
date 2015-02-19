//
//  MovieView.m
//  Movietest
//
//  Created by kubo naoko on 2013/08/19.
//  Copyright (c) 2013年 kubo naoko. All rights reserved.
//

#import "MovieView.h"

#define TIME_OVSERVER_INTERVAL  0.25f

@interface MovieView()
{
    bool _is_playing;     //ムービーが再生中である事を示す
}

@property (nonatomic,retain) AVPlayerItem* playerItem;
@property (nonatomic,retain) AVPlayer*     player;
@property (nonatomic,assign) id  playTimeObserver;

@end

@implementation MovieView

#pragma mark -
#pragma mark class method

//自身のレイヤーを動画再生用レイヤーを返すようにオーバライド
+ (Class)layerClass
{
    return [AVPlayerLayer class];
}


#pragma mark -
#pragma mark instance management

-(void)dealloc
{
    _delegate = nil;
    
    [self clear];
    
    [_playerItem release];
    [_player release];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _is_playing = false;
        _repeat = TRUE;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark property method

-(Float64)movieDuration
{
    if (self.playerItem)
    {
        Float64 duration = CMTimeGetSeconds( [self.player.currentItem duration] );
        return duration;
    } else {
        return 0;
    }
}



#pragma mark -
#pragma mark movie control

-(void)playMovie:(NSURL*)url
{
    //再生用アイテムを生成
    if (_playerItem)
    {
        //前回追加したムービー終了の通知を外す
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
        
        self.playerItem = nil;
    }
    self.playerItem = [[[AVPlayerItem alloc] initWithURL:url] autorelease];
    
    
    //Itemにムービー終了の通知を設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    
    Float64 movieDuration = CMTimeGetSeconds( self.playerItem.duration );
    
    if (self.player)
    {
        
        //アイテムの切り替え
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
        
        [_delegate movieView:self movieWillPlayItem:self.playerItem duration:movieDuration];
        
    } else {
        
        //AVPlayerを生成
        self.player = [[[AVPlayer alloc] initWithPlayerItem:self.playerItem] autorelease];
        AVPlayerLayer* layer = ( AVPlayerLayer* )self.layer;
        layer.videoGravity = AVLayerVideoGravityResizeAspect;
        layer.player       = self.player;
        
        //delegate呼び出し
        [_delegate movieView:self movieWillPlayItem:self.playerItem duration:movieDuration];
        
        // 再生時間とシークバー位置を連動させるためのタイマーを設定
        __block MovieView* weakSelf = self;
        const CMTime intervaltime     = CMTimeMakeWithSeconds( TIME_OVSERVER_INTERVAL, NSEC_PER_SEC );
        self.playTimeObserver = [self.player addPeriodicTimeObserverForInterval:intervaltime
                                                                          queue:NULL
                                                                     usingBlock:^( CMTime time ) {
                                                                         //再生時になにか動作させるのであればここで。
                                                                         [weakSelf moviePlaying:time];
                                                                     }];
    }
    
    [self playMovie];
}




-(void)playMovie
{
    if (self.player)
    {
        [self.player play];
        _is_playing = true;
    }
}

-(void)pauseMovie
{
    if (_is_playing)
    {
        [self.player pause];
        _is_playing = false;
    }
    
}

-(void)seekToSeconds:(Float64)seconds
{
    if (self.player)
    {
        [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC )];
    }
}



//再生中のムービーを停止し、プレイヤーなどをクリアする
- (void)clear
{
    if (self.player)
    {
        [self.player removeTimeObserver:self.playTimeObserver];
        [self.player pause];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        
        AVPlayerLayer* layer = ( AVPlayerLayer* )self.layer;
        layer.player  = nil;
        
        self.player = nil;
        self.playerItem = nil;
        self.playTimeObserver = nil;
    }
    
}

#pragma mark -
#pragma mark movie events

//　TIME_OVSERVER_INTERVALで指定された間隔で実行される
-(void)moviePlaying:(CMTime)time
{
    Float64 duration = CMTimeGetSeconds( [self.player.currentItem duration] );
    Float64 time1    = CMTimeGetSeconds(time);
    
    if (_delegate){
        
        [_delegate movieView:self moviePlayAtTime:time1 duration:duration];
        
    }
    
}

//　ムービー完了時に実行される
- (void) playerDidPlayToEndTime:(NSNotification*)notfication
{
    
    if (self.player)
    {
        if (self.repeat)
        {
            //リピート再生
            [self.player seekToTime:kCMTimeZero];
            [self.player play];
        }
    }
}


@end