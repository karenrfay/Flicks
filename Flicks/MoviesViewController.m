//
//  ViewController.m
//  Flicks
//
//  Created by Karen Fay on 9/12/16.
//  Copyright © 2016 yahoo. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieTableCell.h"
#import "MovieCollectionCell.h"
#import "MovieDetailViewController.h"
#import "MBProgressHUD.h"

@interface MoviesViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) NSArray *movies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (strong, nonatomic) UIRefreshControl* tableRefreshControl;
@property (strong, nonatomic) UIRefreshControl* collectionRefreshControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewSegmentedControl;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // set up the collection view
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    // set up the table view
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // set up the refresh controls
    self.tableRefreshControl = [[UIRefreshControl alloc] init];
    self.tableRefreshControl.tintColor = [UIColor whiteColor];
    [self.tableRefreshControl addTarget:self action:@selector(loadMovieData:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.tableRefreshControl atIndex:0];

    self.collectionRefreshControl = [[UIRefreshControl alloc] init];
    self.collectionRefreshControl.tintColor = [UIColor whiteColor];
    [self.collectionRefreshControl addTarget:self action:@selector(loadMovieData:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView insertSubview:self.collectionRefreshControl atIndex:0];

    [self loadMovieData:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieTableCell"];
    NSDictionary *movie = [self.movies objectAtIndex:indexPath.row];
    [cell setMovie:movie];
    return cell;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell"  forIndexPath:indexPath];
    NSDictionary *movie = [self.movies objectAtIndex:indexPath.row];
    [cell setMovie:movie];
    return cell;
}


// called every time we're about to do a transition to another view
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath;
    if ([segue.identifier isEqualToString:@"tableDetailSegue"]) {
        indexPath = [self.tableView indexPathForCell:sender];
    } else if ([segue.identifier isEqualToString:@"collectionDetailSegue"]) {
        indexPath = [self.collectionView indexPathForCell:sender];
    }
    if (indexPath != nil) {
        MovieDetailViewController *vc = segue.destinationViewController;
        vc.movie = [self.movies objectAtIndex:indexPath.row];
    }
}

- (void) viewDidLayoutSubviews {

}

- (IBAction)onViewChanged:(id)sender {
    int view = self.viewSegmentedControl.selectedSegmentIndex;
    if (view == 0) {
        self.tableView.hidden = NO;
        self.collectionView.hidden = YES;
    } else {
        self.tableView.hidden = YES;
        self.collectionView.hidden = NO;
    }
}

// Load a new set of movie data
- (void) loadMovieData:(UIRefreshControl *)refreshControl {
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@", self.endpoint, apiKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                             delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    if (refreshControl == nil) {
        [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    }
    self.errorView.hidden = YES;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                          completionHandler:^(NSData * _Nullable data,
                                                              NSURLResponse * _Nullable response,
                                                              NSError * _Nullable error) {
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:kNilOptions
                                                                    error:&jsonError];
            self.movies = responseDictionary[@"results"];
            [self.collectionView reloadData];
            [self.tableView reloadData];
        } else {
            self.errorView.hidden = NO;
            NSLog(@"An error occurred: %@", error.description);
        }

        if (refreshControl != nil) {
            [refreshControl endRefreshing];
        } else {
            [MBProgressHUD hideHUDForView:self.tableView animated:YES];
        }
    }];
    
    [task resume];
}

@end
