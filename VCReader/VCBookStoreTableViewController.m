//
//  VCBookStoreTableViewController.m
//  VCReader
//
//  Created by victor on 6/6/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCBookStoreTableViewController.h"

@implementation VCBookStoreTableViewController {
    NSString *_documentPath;
    BOOL _isUpdatingBook;
}

@synthesize jsonResponse = _jsonResponse;
@synthesize bookArray = _bookArray;

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    _isUpdatingBook = NO;
    
    _documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // setup navigation bar
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
    [self.refreshControl addTarget:self action:@selector(updateAllBooks) forControlEvents:UIControlEventValueChanged];
    
    _bookArray = [[VCCoreDataCenter sharedInstance] getAllBooks];

}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"书库";

    [self updateAllBooksAndShowErrorMessage:NO];
    
}

-(void)updateAllBooks {
    [self updateAllBooksAndShowErrorMessage:YES];
}

-(void)updateAllBooksAndShowErrorMessage:(BOOL)showErrorMessage  {
    
    if (_isUpdatingBook == YES) return;
    
    
    _isUpdatingBook = YES;
    VCLOG(@"callAPI");
    [[VCReaderAPIClient sharedClient] callAPI:@"book_get_list" params:@{@"token" : @""} showErrorMessage:showErrorMessage success:^(NSURLSessionDataTask *task, id responseObject) {
        
        self.jsonResponse = responseObject;
        
//        [[VCCoreDataCenter sharedInstance] clearAllBooks];
        
        for (NSDictionary *dict in _jsonResponse) {
            
            [[VCCoreDataCenter sharedInstance] addBookNamed:dict[@"book_name"] contentFilePath:dict[@"content_filename"] coverImageFilePath:dict[@"cover_image_filename"] timestamp:dict[@"timestamp"]];
    
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        

        
    } completion:^(BOOL finished) {
        
        _bookArray = [[VCCoreDataCenter sharedInstance] getAllBooks];
        [self.tableView reloadData];
        
        // End the refreshing
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
        NSString *title = [NSString stringWithFormat:@"最近更新: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
        _isUpdatingBook = NO;

    }];
    
}




-(void)showActivityView {
    
    [VCTool showActivityView];
    
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
        
        messageLabel.text = @"目前您的书库没有书，请尝试下拉刷新书库";
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
    
    VCBookStoreTableViewCell *cell = (VCBookStoreTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *bookNameString = ((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name;
    [cell.bookNameLabel setText:bookNameString];

    
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *bookName = ((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name;
    NSString *token = [VCTool getObjectWithKey:@"token"];
    
    VCLOG(@"callAPI");
    [[VCReaderAPIClient sharedClient] callAPI:@"user_add_book" params:@{@"token" : token, @"book_name" : bookName} showErrorMessage:YES success:^(NSURLSessionDataTask *task, id responseObject) {
      
        VCLOG(@"success");
        NSDictionary *dict = responseObject;
        
        if ([dict[@"error"][@"code"] isEqualToString:@"113"]) {
            [VCTool showAlertViewWithMessage:@"所选书籍已在您的书架收藏中"];
            return;
        }
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [VCTool toastMessage:@"所选书籍已加入您的书架"];
    
        for (UIViewController *vc in [self.tabBarController viewControllers]) {
            VCLOG(@"loop through tab view controller:%@", vc.title);
            if ([vc.title isEqualToString:@"书架"]) {
                [VCTool showActivityView];
                VCBook *book = [[VCBook alloc] initWithBookName:((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name contentFilename:((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).contentFilePath];
                [VCTool hideActivityView];
                VCLibraryTableViewController *libraryTableViewController = (VCLibraryTableViewController *)vc;
                libraryTableViewController.bootTobeRead = book;
                [self.tabBarController setSelectedViewController:libraryTableViewController];
                return;
            }
        }
    
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        VCLOG(@"error");
    } completion:nil];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
@end
