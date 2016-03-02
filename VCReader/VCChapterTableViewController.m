//
//  VCChapterTableViewController.m
//  VCReader
//
//  Created by victor on 2/29/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCChapterTableViewController.h"
#import "VCHelperClass.h"

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
    
    [VCHelperClass storeIntoBook:_book.bookName withField:@"savedPageNumber" andData:@"0"];
    [VCHelperClass storeIntoBook:_book.bookName withField:@"savedChapterNumber" andData:@(indexPath.row).stringValue];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
