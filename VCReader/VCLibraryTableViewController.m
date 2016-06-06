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

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _isUpdatingBook = NO;
    
    _documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    

    self.navigationController.navigationBar.topItem.title = @"书架";

    //show tab bar
    self.tabBarController.tabBar.hidden = NO;
    
    self.jsonResponse = nil;
    self.bookArray = nil;

    // table view
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor redColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(updateBooksOfCurrentUser) forControlEvents:UIControlEventValueChanged];
    
    NSString *nameOfLastReadBook = [VCTool getObjectWithKey:@"name of the last read book"];
    
    if (nameOfLastReadBook) {
        UIStoryboard*  storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        VCPageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"VCPageViewController"];
        VCBook *book = [[VCBook alloc] initWithBookName:nameOfLastReadBook contentFilename:nil]; // assume if you have read it. no need to split chapters again.
        vc.book = book;
        [self.navigationController pushViewController:vc animated:NO];
        return;
    }
    
    [self updateBooksOfCurrentUser];
    
}


- (void) updateBooksOfCurrentUser {

    if (_isUpdatingBook == YES) return;
    
    VCLOG();
    
    _isUpdatingBook = YES;
    
    NSString *token = [VCTool getObjectWithKey:@"token"];
    
    if (self.refreshControl.isRefreshing == NO)
        [VCTool showActivityView];
    
    [[VCReaderAPIClient sharedClient] callAPI:@"book_get_list" params:@{@"token" : token} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        self.jsonResponse = responseObject;
        
        [[VCCoreDataCenter sharedInstance] clearAllBooksForCurrentUser];

        for (NSDictionary *dict in _jsonResponse) {
            
            if(![[VCCoreDataCenter sharedInstance] addBookNamed:dict[@"book_name"] contentFilePath:dict[@"content_filename"] coverImageFilePath:dict[@"cover_image_filename"] timestamp:dict[@"timestamp"]]) {
                
                [[VCCoreDataCenter sharedInstance] updateBookNamed:dict[@"book_name"] contentFilePath:dict[@"content_filename"] coverImageFilePath:dict[@"cover_image_filename"] timestamp:dict[@"timestamp"]];
            }
        }
        
        _bookArray = [[VCCoreDataCenter sharedInstance] getAllBooks];
        [self.tableView reloadData];
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        
        
    } completion:^(BOOL finished) {
        
        _isUpdatingBook = NO;
        [VCTool hideActivityView];
        
        // End the refreshing
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
        NSString *title = [NSString stringWithFormat:@"最近更新: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];

    }];

}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"书架";
    
    if ([[VCCoreDataCenter sharedInstance] getAllBooks].count == 0) {
        
        [self updateBooksOfCurrentUser];
        
    } else {
        
        _bookArray = [[VCCoreDataCenter sharedInstance] getAllBooks];
        [self.tableView reloadData];
    }
  
}


-(void) showActivityView {

    [VCTool showActivityView];

}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showBookContent"]) {

        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        [VCTool showActivityView];
        VCBook *book = [[VCBook alloc] initWithBookName:((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name contentFilename:((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).contentFilePath];
        [VCTool hideActivityView];

        VCPageViewController *viewController = segue.destinationViewController;
        viewController.book = book;
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
        
        messageLabel.text = @"目前您的书架没有书，可下拉刷新书架或是到书库选择新书";
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _bookArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VCLibraryTableViewCell *cell = (VCLibraryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *bookNameString = ((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name;

//    VCLOG(@"row:%ld name:%@", (long)indexPath.row, bookNameString);
   
    [cell.bookNameLabel setText:bookNameString];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString  *path = [NSString stringWithFormat:@"%@/%@", kVCReaderBaseURLString, ((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).coverImageFilePath];
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    VCLOG(@"encoded path = %@", encodedPath);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.jpg", _documentPath, ((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name]]) {

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
    
    UITableViewRowAction *reload = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"重載" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *fullBookDirectoryPath = [VCTool createDirectory:((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name  atFilePath:documentsPath];
        
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
    }];
    
    reload.backgroundColor = [UIColor redColor];
    
    return @[reload];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
