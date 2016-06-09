//
//  VCChapterTableViewController.m
//  VCReader
//
//  Created by victor on 2/29/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCChapterTableViewController.h"

@interface VCChapterTableViewController ()

@end

@implementation VCChapterTableViewController

@synthesize book = _book;
@synthesize chapterNumber = _chapterNumber;
@synthesize pageNumber = _pageNumber;

-(void) goBack {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = newBackButton;
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

    VCLOG();

    [VCTool showActivityView];
    
    VCReadingStatusMO *readingStatus = [[VCCoreDataCenter sharedInstance] updateReadingStatusForBook:_book.bookName chapterNumber:(int)indexPath.row wordNumber:0];

    NSString *chapter = [NSString stringWithFormat:@"%d", readingStatus.chapterNumber];
    NSString *word = [NSString stringWithFormat:@"%d", readingStatus.wordNumber];
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)readingStatus.timestamp];
    
    VCLOG(@"callAPI");
    [[VCReaderAPIClient sharedClient] callAPI:@"user_status_add" params:@{@"token" : [VCTool getObjectWithKey:@"token"], @"book_name" : _book.bookName, @"current_reading_chapter" : chapter, @"current_reading_word" : word, @"timestamp" : timestamp} showErrorMessage:YES success:^(NSURLSessionDataTask *task, id responseObject) {
        
        readingStatus.synced = YES;
        [[VCCoreDataCenter sharedInstance] saveContext];
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        
        readingStatus.synced = NO;
        [[VCCoreDataCenter sharedInstance] saveContext];
        
        
        VCLOG(@"Failure: %@", error.debugDescription);
        [VCTool showAlertViewWithTitle:@"web error" andMessage:error.debugDescription];
        
        
    } completion:^(BOOL finished) {
        
        [VCTool hideActivityView];
        [self.navigationController popViewControllerAnimated:YES];
    
    }];
    
}

@end
