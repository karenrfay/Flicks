//
//  TrailerCell.m
//  Flicks
//
//  Created by Karen Fay on 9/13/16.
//  Copyright © 2016 yahoo. All rights reserved.
//

#import "TrailerCell.h"
#import "YTPlayerView.h"

@interface TrailerCell()
@property (weak, nonatomic) IBOutlet YTPlayerView *playerView;
@property (strong, nonatomic) NSDictionary *trailer;

@end

@implementation TrailerCell

- (void)setTrailer:(NSDictionary *)trailer {
    [self.playerView loadWithVideoId:trailer[@"key"]];
}

@end
