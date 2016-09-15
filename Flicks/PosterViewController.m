//
//  PosterViewController.m
//  Flicks
//
//  Created by Karen Fay on 9/15/16.
//  Copyright © 2016 yahoo. All rights reserved.
//

#import "PosterViewController.h"
#import "UIImageView+AFNetworking.h"

@interface PosterViewController() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;

@end

@implementation PosterViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *posterPath = self.movie[@"poster_path"];
    NSString *urlString = [@"https://image.tmdb.org/t/p/original" stringByAppendingString:posterPath];
    [self.posterView setImageWithURL:[NSURL URLWithString:urlString]];

    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 6.0;
    self.scrollView.delegate = self;
}

// Tap handler for the done button (closes the modal)
- (IBAction)onTapDoneButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Tell the scroll view which element should zoom
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.posterView;
}

@end
