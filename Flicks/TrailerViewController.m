//
//  TrailerViewController.m
//  Flicks
//
//  Created by Karen Fay on 9/12/16.
//  Copyright © 2016 yahoo. All rights reserved.
//

#import "TrailerViewController.h"
#import "TrailerCell.h"
#import "MBProgressHUD.h"

@interface TrailerViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl* refreshControl;
@property (strong, nonatomic) NSArray* trailers;

@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // set up the table view
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.title = @"Videos";

    // set up the refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(loadTrailers:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];

    [self loadTrailers:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.trailers.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TrailerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrailerCell"];
    NSDictionary *trailer = [self.trailers objectAtIndex:indexPath.row];
    [cell setTrailer:trailer];
    return cell;
}

- (void) loadTrailers:(UIRefreshControl *)refreshControl {
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@/videos?api_key=%@", self.movie[@"id"], apiKey];

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];

    if (refreshControl == nil) {
        [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    }

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
        completionHandler:^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:kNilOptions
                                                                                 error:&jsonError];
            self.trailers = responseDictionary[@"results"];
            [self.tableView reloadData];
        } else {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
