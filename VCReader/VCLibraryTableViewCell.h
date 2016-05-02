//
//  VCLibraryTableViewCell.h
//  VCReader
//
//  Created by victor on 3/1/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCLibraryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *bookNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bookCoverImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageDownloadProgressIndicator;

@end
