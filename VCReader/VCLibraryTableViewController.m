//
//  VCLibraryTableViewController.m
//  VCReader
//
//  Created by victor on 2/27/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCLibraryTableViewController.h"
#import "VCPageViewController.h"
#import "AppDelegate.h"

@interface VCLibraryTableViewController ()

@end

@implementation VCLibraryTableViewController {
    
    NSString *_documentPath;
    BOOL _isUpdatingBook;

}
@synthesize jsonResponse = _jsonResponse;
@synthesize bookArray = _bookArray;
@synthesize bootTobeRead = _bootTobeRead;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _isUpdatingBook = NO;
    
    _documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // setup navigation bar
    self.navigationController.navigationBar.topItem.title = @"书架";
    [self.navigationController.navigationBar setTranslucent:NO];
    
    //show tab bar
    self.tabBarController.tabBar.hidden = NO;
    
    self.jsonResponse = nil;
    self.bookArray = nil;

    // table view
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 45, 0);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor redColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(updateAllBooksOfCurrentUser) forControlEvents:UIControlEventValueChanged];
    

    NSString *nameOfLastReadBook = [VCTool getObjectWithKey:@"nameOfTheLastReadBook"];
    
    if (nameOfLastReadBook) {
        UIStoryboard*  storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        VCPageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"VCPageViewController"];
        VCBook *book = [[VCBook alloc] initWithBookName:nameOfLastReadBook contentFilename:nil]; // assume if you have read it. no need to split chapters again.
        if (book) {
            vc.book = book;
            [self.navigationController pushViewController:vc animated:NO];
        }
        return;
    }
    
    _bookArray = [[VCCoreDataCenter sharedInstance] getForCurrentUserAllBooks];
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"书架";
    
    
    [self updateAllBooksOfCurrentUserAndShowErrorMessage:NO];
    
}

-(void)updateAllBooksOfCurrentUser {
    [self updateAllBooksOfCurrentUserAndShowErrorMessage:YES];
}

-(void)updateAllBooksOfCurrentUserAndShowErrorMessage:(BOOL)showErrorMessage {
    
    if (_isUpdatingBook == YES) return;
    
    VCLOG();
    
    _isUpdatingBook = YES;
    
    NSString *token = [VCTool getObjectWithKey:@"token"];
    
    VCLOG(@"callAPI");
    [[VCReaderAPIClient sharedClient] callAPI:@"book_get_list" params:@{@"token" : token} showErrorMessage:showErrorMessage success:^(NSURLSessionDataTask *task, id responseObject) {
        
        self.jsonResponse = responseObject;
        
        [[VCCoreDataCenter sharedInstance] clearAllBooksForCurrentUser];
        
        for (NSDictionary *dict in _jsonResponse) {
            
            [[VCCoreDataCenter sharedInstance] addForCurrentUserBookNamed:dict[@"book_name"] contentFilePath:dict[@"content_filename"] coverImageFilePath:dict[@"cover_image_filename"] timestamp:dict[@"timestamp"]];
            
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        

        
    } completion:^(BOOL finished) {
        
        // End the refreshing
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
        NSString *title = [NSString stringWithFormat:@"最近更新: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
        
        _bookArray = [[VCCoreDataCenter sharedInstance] getForCurrentUserAllBooks];
        [self.tableView reloadData];
        
        _isUpdatingBook = NO;

    }];
    
}

-(void) showActivityView {

    [VCTool showActivityView];

}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([identifier isEqualToString:@"showBookContent"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        [VCTool showActivityView];
        VCBook *book = [[VCBook alloc] initWithBookName:((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name contentFilename:((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).contentFilePath];
        [VCTool hideActivityView];
        if (!book) {
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            return NO;
        }

    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showBookContent"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        if (!_bootTobeRead) {
            
            [VCTool showActivityView];
            _bootTobeRead = [[VCBook alloc] initWithBookName:((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name contentFilename:((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).contentFilePath];
            [VCTool hideActivityView];
        }

        
        VCPageViewController *viewController = segue.destinationViewController;
        viewController.book = _bootTobeRead;
        _bootTobeRead = nil;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (_bookArray.count > 0) {
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
        return 1;

    } else {
        
        CGFloat padding = 4.0;
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, self.view.bounds.size.width - 2 * padding, self.view.bounds.size.height)];
        
        messageLabel.text = @"目前您的书架没有书，请尝试下拉刷新书架或是到书库选择新书";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
//        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _bookArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VCLibraryTableViewCell *cell = (VCLibraryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *bookNameString = ((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name;

    [cell.bookNameLabel setText:bookNameString];
    
    NSString *numberOfWordsString = [VCTool getDatafromBook:bookNameString withField:@"numberOfWords"];
    long numberOfWords = [numberOfWordsString intValue];

    VCReadingStatusMO *status = [[VCCoreDataCenter sharedInstance] getReadingStatusForBook:bookNameString];
    int chapterNumber = status.chapterNumber;
    NSString *wordCountOfTheBookForTheFirstWordInTheChapter = [[VCTool getDatafromBook:bookNameString withField:@"wordCountOfTheBookForTheFirstWordInChapters"] objectAtIndex:chapterNumber];
    long currentReadWordPosition = [wordCountOfTheBookForTheFirstWordInTheChapter intValue] + status.wordNumber;
    
    if (numberOfWords > 0 && currentReadWordPosition > 0) {
        
        float progress = (float)currentReadWordPosition / (float)numberOfWords * 100.0f;
        
        [cell.readingProgressLabel setText:[NSString stringWithFormat:@"已读 %3.1f%%", progress]];
    } else {
        [cell.readingProgressLabel setText:[NSString stringWithFormat:@"未读"]];
    }
    
    // download image for the cover of the book
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString  *path = [NSString stringWithFormat:@"%@/%@", kVCReaderBaseURLString, ((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).coverImageFilePath];
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.png", _documentPath, ((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name]]) {

        [cell.imageDownloadProgressIndicator startAnimating];
        manager.responseSerializer = [AFImageResponseSerializer serializer];
        [manager GET:encodedPath parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            
            UIImage *image = responseObject;
            [VCTool saveImage:image withName:((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name];
            
            [cell.bookCoverImage setImage:image];
            [cell.imageDownloadProgressIndicator stopAnimating];
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {

            [cell.imageDownloadProgressIndicator stopAnimating];

            VCLOG(@"Failure: %@", error.debugDescription);
            
        }];
    } else {
        
        UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", _documentPath, ((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name]];
        [cell.bookCoverImage setImage:image];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 90.0;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * bookName = ((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name;
    
    UITableViewRowAction *reload = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *fullBookDirectoryPath = [VCTool createDirectory:bookName  atFilePath:documentsPath];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:fullBookDirectoryPath]) { // Directory exists
            NSArray *listOfFiles = [fileManager contentsOfDirectoryAtPath:fullBookDirectoryPath error:nil];
            if (listOfFiles.count > 0) {
                NSError *error = nil;
                [fileManager removeItemAtPath:fullBookDirectoryPath error:&error];
                VCLOG(@"Error:%@", error.description);
            }
        }
        
        // hide the action in cell
        [self.tableView setEditing:NO animated:YES];
        // remove book from the current usr in core data
        [[VCCoreDataCenter sharedInstance] removeForCurrentUserBookNamed:((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name];
        // remove book info store in users default
        [VCTool removeFromBook:bookName withField:@"numberOfChapters"];
        [VCTool removeFromBook:bookName withField:@"titleOfChaptersArray"];
        [VCTool removeFromBook:bookName withField:@"wordCountOfTheBookForTheFirstWordInChapters"];
        [VCTool removeFromBook:bookName withField:@"numberOfWords"];

        _bookArray = [[VCCoreDataCenter sharedInstance] getForCurrentUserAllBooks];

        [self.tableView reloadData];
        
        VCLOG(@"callAPI");
        [[VCReaderAPIClient sharedClient] callAPI:@"user_remove_book" params:@{@"token" : [VCTool getObjectWithKey:@"token"], @"book_name" : bookName} showErrorMessage:YES success:^(NSURLSessionDataTask *task, id responseObject) {
            VCLOG(@"success in removing a book for the current user in the cloud db");
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            VCLOG(@"Failed:%@", error.debugDescription);
        } completion:nil];
        
    }];
    
    
    reload.backgroundColor = [UIColor redColor];
    
    return @[reload];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
