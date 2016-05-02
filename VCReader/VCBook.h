//
//  VCBook.h
//  VCReader
//
//  Created by victor on 1/27/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kVCReaderBaseURLString;

@interface VCBook : NSObject

@property (strong, nonatomic) NSString *bookName;
@property (strong, nonatomic) NSString *contentFilename;
@property (assign) int totalNumberOfChapters;

-(instancetype) initWithBookName:(NSString *)bookName contentFilename:(NSString *)contentFilename;
-(NSString *)getTextContentStringFromChapterNumber:(NSUInteger)chapterNumber;
-(NSString *)getChapterTitleStringFromChapterNumber:(NSUInteger)chapterNumber;


@end
