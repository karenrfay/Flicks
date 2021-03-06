//
//  MovieTableCell.m
//  Flicks
//
//  Created by Karen Fay on 9/12/16.
//  Copyright © 2016 yahoo. All rights reserved.
//

#import "MovieTableCell.h"
#import "UIImageView+AFNetworking.h"

@interface MovieTableCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;

@end

@implementation MovieTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMovie:(NSDictionary *)movie {
    self.titleLabel.text = movie[@"title"];
    self.synopsisLabel.text = movie[@"overview"];

    NSString *posterPath = movie[@"poster_path"];
    if (posterPath && ![posterPath isEqual:[NSNull null]]) {
        NSString *urlString = [@"https://image.tmdb.org/t/p/w154" stringByAppendingString:posterPath];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
         
        [self.posterView setImageWithURLRequest:request placeholderImage:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                 self.posterView.contentMode = UIViewContentModeScaleAspectFit;
                 if (response != nil) {
                     self.posterView.alpha = 0.0;
                     self.posterView.image = image;
                     [UIView animateWithDuration:0.3 animations:^{
                         self.posterView.alpha = 1.0;
                     }];
                 } else {
                     self.posterView.image = image;
                 }
             }
             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                 NSLog(@"Image fetch error %@",response);
                 [self showDefaultImage];
             }
         ];
    } else {
        [self showDefaultImage];
    }
}

- (void) showDefaultImage {
    self.posterView.image = [UIImage imageNamed:@"Video"];
    self.posterView.backgroundColor = [UIColor whiteColor];
    self.posterView.contentMode = UIViewContentModeCenter;
}

@end
