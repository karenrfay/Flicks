//
//  MovieDetailViewController.m
//  Flicks
//
//  Created by Karen Fay on 9/12/16.
//  Copyright © 2016 yahoo. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "TrailerViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *overviewLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImage;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageEmpty;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showMovieDetail];
    [self loadMovieDetail:nil];

    self.overviewLabel.text = self.movie[@"overview"];
    [self.overviewLabel sizeToFit];

    CGRect frame = self.infoView.frame;
    frame.size.height = self.overviewLabel.frame.size.height +
                        self.overviewLabel.frame.origin.y + 10;
    self.infoView.frame = frame;

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 60 + self.infoView.frame.origin.y + self.infoView.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showMovieDetail {

    // Title
    self.title = self.movie[@"title"];
    self.titleLabel.text = self.movie[@"title"];
    [self.titleLabel sizeToFit];

    // Release date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:self.movie[@"release_date"]];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    self.releaseDateLabel.text = [dateFormatter stringFromDate:date];

    // Rating
    float rating = [self.movie[@"vote_average"] floatValue];
    float ratingHeight = self.ratingImageEmpty.frame.size.height * (rating / 10) * 0.8; // adjust for visual star border
    self.ratingLabel.text = [NSString stringWithFormat:@"%0.1f", rating];
    self.ratingImage.clipsToBounds = YES;
    self.ratingImage.frame = CGRectMake(self.ratingImageEmpty.frame.origin.x,
                                        self.ratingImageEmpty.frame.origin.y + self.ratingImageEmpty.frame.size.height - ratingHeight,
                                        self.ratingImageEmpty.frame.size.width,
                                        ratingHeight);

    // Duration
    int duration = [self.movie[@"runtime"] intValue];
    NSUInteger h = duration / 60;
    NSUInteger m = duration % 60;
    self.durationLabel.text = [NSString stringWithFormat:@"%uh %umin", h, m];

    // Overview
    self.overviewLabel.text = self.movie[@"overview"];
    [self.overviewLabel sizeToFit];

    // Poster image
    NSString *posterPath = self.movie[@"poster_path"];
    if (posterPath && ![posterPath isEqual:[NSNull null]]) {
        // use the same image from the table view as the initial image since it should be in the cache
        NSString *smallUrlString = [@"https://image.tmdb.org/t/p/w154" stringByAppendingString:posterPath];
        [self.posterImage setImageWithURL:[NSURL URLWithString:smallUrlString]];

        // now replace it with the large image
        NSString *largeUrlString = [@"https://image.tmdb.org/t/p/original" stringByAppendingString:posterPath];
        [self.posterImage setImageWithURL:[NSURL URLWithString:largeUrlString]];
    }
}

// Load a new set of movie data
- (void) loadMovieDetail:(UIRefreshControl *)refreshControl {
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@", self.movie[@"id"], apiKey];

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:kNilOptions
                                                                                 error:&jsonError];
            self.movie = responseDictionary;
            [self showMovieDetail];
        } else {
            NSLog(@"An error occurred: %@", error.description);
        }

        if (refreshControl != nil) {
            [refreshControl endRefreshing];
        }
    }];
    
    [task resume];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
// called every time we're about to do a transition to another view
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //if ([segue.identifier isEqualToString:@"detailSegue"]) {
        TrailerViewController *vc = segue.destinationViewController;
        vc.movie = self.movie;
    //}
}

@end
