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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)submitButtonPressed:(id)sender {
    
    if (self.commentTextView.text.length > 200) {
        
        [VCTool toastMessage:@"您的建议字数超过200字限制"];
        return;
    }
    
    if ([self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length < 4) {
        
        [VCTool toastMessage:@"建议或问题字数太少啦，多写一点吧！"];
        return;
        
    }
    NSMutableData *errorLogData = [NSMutableData data];
    
    for (NSData *errorLogFileData in [VCTool errorLogData]) {
        
        [errorLogData appendData:errorLogFileData];
    }
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
        NSString *fileName = [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSinceReferenceDate] * 1000)];
        
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
    
    
    [VCTool showActivityView];

    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long) ([[NSDate new] timeIntervalSince1970] * 1000.0f)];
    
    [[VCReaderAPIClient sharedClient] callAPI:@"report_add_comment" params:@{@"token" : [VCTool getObjectWithKey:@"token"], @"comment" : self.commentTextView.text, @"timestamp" : timestamp} success:^(NSURLSessionDataTask *task, id responseObject) {
        
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


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data

{
    VCLOG(@"Recieved Data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
}

@end
