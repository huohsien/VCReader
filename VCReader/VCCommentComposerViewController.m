//
//  VCCommentComposerViewController.m
//  VCReader
//
//  Created by victor on 6/4/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCCommentComposerViewController.h"
#import "VCPlaintextResponseSerializer.h"


@interface VCCommentComposerViewController ()

@end

@implementation VCCommentComposerViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    [self.commentTextView becomeFirstResponder];
    [self.commentTextView setDelegate:self];
    
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    self.commentTextView.inputAccessoryView = keyboardDoneButtonView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


- (IBAction)submitButtonPressed:(id)sender {
    
    if (self.commentTextView.text.length > 200) {
        
        [VCTool showAlertViewWithMessage:@"您的建议字数超过200字限制"];
        return;
    }
    
    if ([self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length < 4) {
        
        [VCTool showAlertViewWithMessage:@"建议或问题字数太少啦，多写一点吧！"];
        return;
        
    }
    NSMutableData *errorLogData = [NSMutableData data];
    
    for (NSData *errorLogFileData in [VCTool errorLogData]) {
        
        [errorLogData appendData:errorLogFileData];
    }
    VCLOG("call showActivityView");
    [VCTool showActivityView];

    NSString *fullPath = [VCTool saveData:errorLogData toFileNamed:@"log.txt"];
    
//    NSString * errorLogString = [[NSString alloc] initWithData:errorLogData encoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.responseSerializer = [VCPlaintextResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *fullwebPath = [NSString stringWithFormat:@"%@/%@", kVCReaderBaseURLString, @"report_upload_log.php"];
    [manager POST:fullwebPath parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSURL *fileURL = [NSURL fileURLWithPath:fullPath];
        NSString *fileName = [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSince1970] * 1000)];
        
        [formData appendPartWithFileURL:fileURL name:@"upfile" fileName:fileName mimeType:@"text/plain" error:NULL];
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = responseObject;
        
        if (dict[@"error"] == nil)
            VCLOG(@"succeed to upload log file:%@", responseObject);
        [VCTool hideActivityView];
    
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        VCLOG(@"failed to upload log file:%@", error.debugDescription);
        [VCTool hideActivityView];
        
    }];
    
    VCLOG("call showActivityView");
    [VCTool showActivityView];

    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long) ([[NSDate new] timeIntervalSince1970] * 1000.0f)];
    
    VCLOG(@"callAPI");
    [[VCReaderAPIClient sharedClient] callAPI:@"report_add_comment" params:@{@"token" : [VCTool getObjectWithKey:@"token"], @"comment" : self.commentTextView.text, @"timestamp" : timestamp} showErrorMessage:YES success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = responseObject;
        
        if (dict[@"token"]) {
            
        } else if (dict[@"error"] && [dict[@"error"][@"code"] isEqualToString:@"105"]) {
            
            [VCTool showAlertViewWithTitle:@"错误" andMessage:@"资料库中使用者不存在"];
            
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

        VCLOG(@"%@", error.debugDescription);
        
        [VCTool showAlertViewWithTitle:@"web error" andMessage:error.debugDescription];

    } completion:^(BOOL finished) {
        
        [VCTool hideActivityView];
    }];

    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)tapped:(id)sender {
    
    [self.view endEditing:YES];
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data

{
    VCLOG(@"Recieved Data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
}

- (IBAction)doneClicked:(id)sender
{
    VCLOG(@"Done Clicked.");
    [self.view endEditing:YES];
}

#pragma mark - keyboard callbaks

- (void) keyboardDidShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    // If you are using Xcode 6 or iOS 7.0, you may need this line of code. There was a bug when you
    // rotated the device to landscape. It reported the keyboard as the wrong size as if it was still in portrait mode.
    //kbRect = [self.view convertRect:kbRect fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    if (!CGRectContainsPoint(aRect, self.commentTextView.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.commentTextView.frame animated:YES];
    }
}

- (void) keyboardWillBeHidden:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

@end
