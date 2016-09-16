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

// constants
const int LIST_VIEW_INDEX = 0;
const int GRID_VIEW_INDEX = 1;

@interface MoviesViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewSegmentedControl;

@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic) UIRefreshControl* tableRefreshControl;
@property (strong, nonatomic) UIRefreshControl* collectionRefreshControl;
@property (strong, nonatomic) UISearchBar *searchBar;
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

    // set up the search bar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;

    [self loadMovieData:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    UIScrollView *currentView = [self getCurrentView];
    [currentView setContentOffset:CGPointMake(0, -currentView.contentInset.top) animated:NO];
    [self loadMovieData:nil];
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
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
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
    self.tableView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, 0);
    //self.collectionView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, 0);
}

- (IBAction)onViewChanged:(id)sender {
    [self showCurrentView];
}

// Get a pointer to the current view
- (UIScrollView *) getCurrentView {
    int view = self.viewSegmentedControl.selectedSegmentIndex;
    if (view == LIST_VIEW_INDEX) {
        return self.tableView;
    } else if (view == GRID_VIEW_INDEX) {
        return self.collectionView;
    }
    return nil;
}

// Show the currently chosen view and refresh the data
- (void) showCurrentView {
    int view = self.viewSegmentedControl.selectedSegmentIndex;
    if (view == LIST_VIEW_INDEX) {
        [self.tableView reloadData];
        self.tableView.hidden = NO;
        self.collectionView.hidden = YES;
    } else if (view == GRID_VIEW_INDEX) {
        [self.collectionView reloadData];
        self.collectionView.hidden = NO;
        self.tableView.hidden = YES;
    }
}

// Load a new set of movie data
- (void) loadMovieData:(UIRefreshControl *)refreshControl {

    // Prepare the UI
    NSString *query = self.searchBar.text;
    UIView *currentView = [self getCurrentView];
    if (refreshControl == nil && query.length == 0) {
        [MBProgressHUD showHUDAddedTo:currentView animated:YES];
    }

    // Make the request
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *urlString;

    if (query.length > 1) {
        urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/search/movie?query=%@&api_key=%@", query, apiKey];
    } else {
        urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@", self.endpoint, apiKey];
    }
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                             delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    if (self.dataTask != nil) {
        [self.dataTask cancel];
    }
    self.dataTask = [session dataTaskWithRequest:request
                               completionHandler:^(NSData * _Nullable data,
                                                   NSURLResponse * _Nullable response,
                                                   NSError * _Nullable error) {
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:kNilOptions
                                                                    error:&jsonError];
            self.movies = responseDictionary[@"results"];
            [self showCurrentView];
            self.errorView.hidden = YES;
        } else {
            if (error.code != -999) { // -999 is "cancelled"
                self.errorView.hidden = NO;
            } else {
                self.errorView.hidden = YES;
            }
            NSLog(@"An error occurred: %@", error.description);
        }

        if (refreshControl != nil) {
            [refreshControl endRefreshing];
        } else {
            [MBProgressHUD hideHUDForView:currentView animated:YES];
        }
        self.dataTask = nil;
    }];
    
    [self.dataTask resume];
}

@end
