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

}
@synthesize jsonResponse = _jsonResponse;
@synthesize bookArray = _bookArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //set status bar style
    [self setNeedsStatusBarAppearanceUpdate];
    
    //set navigation bar style
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:21.0]}];
    self.navigationController.navigationBar.topItem.title = @"书架";

    //hide tab bar
    self.tabBarController.tabBar.hidden = NO;
    
    self.jsonResponse = nil;
    self.bookArray = nil;

    NSString *nameOfLastReadBook = [VCTool getObjectWithKey:@"name of the last read book"];
    
    if (nameOfLastReadBook) {
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        VCPageViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VCPageViewController"];
        VCBook *book = [[VCBook alloc] initWithBookName:nameOfLastReadBook contentFilename:nil]; // assume if you have read it. no need to split chapters again.
        vc.book = book;
        [self.navigationController pushViewController:vc animated:NO];
    }

    
    [VCTool showActivityView];
    
    [[VCReaderAPIClient sharedClient] getBookListForUserWithID:[VCTool getObjectWithKey:@"user id"] success:^(NSURLSessionDataTask *task, id responseObject) {
        
        self.jsonResponse = responseObject;
        
        for (NSDictionary *dict in _jsonResponse) {
            
            if(![[VCCoreDataCenter sharedInstance] addBookNamed:dict[@"book_name"] contentFilePath:dict[@"content_filename"] coverImageFilePath:dict[@"cover_image_filename"] timestamp:dict[@"timestamp"]]) {
                
                [[VCCoreDataCenter sharedInstance] updateBookNamed:dict[@"book_name"] contentFilePath:dict[@"content_filename"] coverImageFilePath:dict[@"cover_image_filename"] timestamp:dict[@"timestamp"]];
            }
        }
        
        _bookArray = [[VCCoreDataCenter sharedInstance] getAllBooks];
        [self.tableView reloadData];
        [VCTool hideActivityView];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        _bookArray = [[VCCoreDataCenter sharedInstance] getAllBooks];
        [self.tableView reloadData];
        [VCTool hideActivityView];

    }];
     
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"书架";
  
}

-(UIStatusBarStyle)preferredStatusBarStyle {

    return UIStatusBarStyleLightContent;
}


-(void) showActivityView {

    [VCTool showActivityView];

}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showBookContent"])
    {

        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        [NSThread detachNewThreadSelector:@selector(showActivityView) toTarget:self withObject:nil];
        VCBook *book = [[VCBook alloc] initWithBookName:((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name contentFilename:((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).contentFilePath];
        [VCTool hideActivityView];

        VCPageViewController *viewController = segue.destinationViewController;
        viewController.book = book;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _bookArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VCLibraryTableViewCell *cell = (VCLibraryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *bookNameString = ((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).name;

//    NSLog(@"row:%ld name:%@", (long)indexPath.row, bookNameString);
   
    [cell.bookNameLabel setText:bookNameString];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString  *path = [NSString stringWithFormat:@"%@/%@", kVCReaderBaseURLString, ((VCBookMO *)[_bookArray objectAtIndex:indexPath.row]).coverImageFilePath];
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%s: encoded path = %@", __PRETTY_FUNCTION__, encodedPath);
    
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

            NSLog(@"%s --- Failure: %@", __PRETTY_FUNCTION__, error.debugDescription);
            
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
                NSLog(@"%s:%@", __PRETTY_FUNCTION__, error.description);
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
