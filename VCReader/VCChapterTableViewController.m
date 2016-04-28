//
//  VCChapterTableViewController.m
//  VCReader
//
//  Created by victor on 2/29/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCChapterTableViewController.h"
#import "VCHelperClass.h"
#import "VCReaderAPIClient.h"

@interface VCChapterTableViewController ()

@end

@implementation VCChapterTableViewController

@synthesize book = _book;
@synthesize chapterNumber = _chapterNumber;
@synthesize pageNumber = _pageNumber;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21.0]}];
    
    self.title = NSLocalizedString(@"chapters", nil);
    
    [self performSelector:@selector(scrollToCell) withObject:nil afterDelay:0.1];
}

- (void) scrollToCell
{
    [self.tableView reloadData];
    NSIndexPath *scrollToPath = [NSIndexPath indexPathForRow:_chapterNumber inSection:0];
//    [self.tableView scrollToRowAtIndexPath:scrollToPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    [self.tableView selectRowAtIndexPath:scrollToPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _book.totalNumberOfChapters;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [_book getChapterTitleStringFromChapterNumber:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

//    [VCHelperClass saveReadingStatusForBook:_book.bookName andUserID:@"tester" chapterNumber:(int)indexPath.row wordNumber:0 inViewController:self];
    
//    VCReadingStatusMO *readingStatus = [VCHelperClass getReadingStatusForBook:_book.bookName andUserID:@"tester" inViewController:self];
    
//    [[VCReaderAPIClient sharedClient] saveReadingStatusForBookNamed:readingStatus.bookName chapterNumber:readingStatus.chapterNumber wordNumber:readingStatus.wordNumber timestamp:readingStatus.timestamp success:^(NSURLSessionDataTask *task, id responseObject) {
//        
//        [self.navigationController popViewControllerAnimated:YES];
//        
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        
//        [VCHelperClass showErrorAlertViewWithTitle:@"Web Error" andMessage:error.debugDescription];
//
//        NSLog(@"%s: Failure -- %@",__PRETTY_FUNCTION__, error);
//
//    }];
}

@end
