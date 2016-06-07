//
//  VCBookContent.m
//  VCReader
//
//  Created by victor on 1/27/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCBook.h"

@implementation VCBook {
    NSString *_fullBookDirectoryPath;
    NSMutableArray *_chapterTitleStringArray;
    NSMutableArray *_chapterContentRangeStringArray;
    NSMutableArray *_wordCountOfTheBookForTheFirstWordInChapters;
    NSString *_contentString;
    NSString *_documentPath;

}

@synthesize bookName = _bookName;
@synthesize contentFilename = _contentFilename;
@synthesize totalNumberOfChapters = _totalNumberOfChapters;

-(instancetype) initWithBookName:(NSString *)bookName contentFilename:(NSString *)contentFilename {
    self = [super init];
    if (self) {
        _bookName = bookName;
        _contentFilename = contentFilename;
        _documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

        if (![self setup])
            return nil;
    }
    return self;
}


-(BOOL) setup {
    
    _chapterTitleStringArray = [NSMutableArray new];
    _chapterContentRangeStringArray = [NSMutableArray new];
    _wordCountOfTheBookForTheFirstWordInChapters = [NSMutableArray new];
    
    _totalNumberOfChapters = 0;
    
    _fullBookDirectoryPath = [self createDirectory:_bookName atFilePath:_documentPath];
    
    BOOL isBookLoaded = NO;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_fullBookDirectoryPath]) { // Directory exists
        NSArray *listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_fullBookDirectoryPath error:nil];
        isBookLoaded = listOfFiles.count > 0 ? YES : NO;
    }
    
    if (!isBookLoaded) {
        
        [VCTool showActivityView];
        if (![self loadContent])
            return NO;
        
        [self splitChapters];
        
        for (int i = 0; i < _chapterTitleStringArray.count; i++) {
            [self writeContentOfChapter:i];
        }
        [VCTool hideActivityView];
    }
    
    _totalNumberOfChapters = [[VCTool getDatafromBook:_bookName withField:@"numberOfChapters"] intValue];
    return YES;
}

-(BOOL)loadContent{

    NSString *path = [NSString stringWithFormat:@"%@/%@", kVCReaderBaseURLString, _contentFilename];
    NSString *encodePath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    VCLOG(@"%@", encodePath);
    NSURL  *url = [NSURL URLWithString:encodePath];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
   
    NSString *zipFilePath = nil;
    if (urlData) {
        
        NSString *bookName = [[_contentFilename componentsSeparatedByString:@"/"] lastObject];
        zipFilePath = [NSString stringWithFormat:@"%@/%@", _documentPath,bookName];
        [urlData writeToFile:zipFilePath atomically:YES];
        
    } else {
        VCLOG(@"fail to download compressed file of the book");
    }
    [self createDirectory:@"temp" atFilePath:_documentPath];
    NSString *unzipFilePath = [_documentPath stringByAppendingPathComponent:@"temp"];
    
    if (![SSZipArchive unzipFileAtPath:zipFilePath toDestination:unzipFilePath]) {
        VCLOG(@"unzip fail");
        [VCTool toastMessage:@"无法下载书籍"];
        return NO;
    };
    NSError *error = nil;

    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:unzipFilePath error:&error];
    if (error) {
        
        VCLOG(@"Error: %@", error.debugDescription);
        abort();
        
    } else {
        
        if ([directoryContent count] == 0) {

        }
        NSString *path = [NSString stringWithFormat:@"%@/%@", unzipFilePath, [directoryContent lastObject]];
        VCLOG(@"path = %@", path);
        _contentString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        VCLOG(@"number of words:%lu", (unsigned long)_contentString.length);
        [VCTool storeIntoBook:_bookName withField:@"numberOfWords" andData:@(_contentString.length).stringValue];
        
        if (error) {
            
            VCLOG(@"Error: %@", error.debugDescription);
            
        } else {
            
            [[NSFileManager defaultManager] removeItemAtPath:unzipFilePath error:&error];
            if (error) {
                VCLOG(@"Error: %@", error.debugDescription);
                abort();
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:&error];
            if (error) {
                VCLOG(@"Error: %@", error.debugDescription);
                abort();
            }
        }
    }
    return YES;
}

-(void) writeContentOfChapter:(int)chapterNumber {
    
    NSString *path = [_fullBookDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.txt", (unsigned long)chapterNumber]];
    NSString *string = [_contentString substringWithRange:NSRangeFromString([_chapterContentRangeStringArray objectAtIndex: chapterNumber])];
    [string writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(NSString *)getChapterTitleStringFromChapterNumber:(NSUInteger)chapterNumber {

    NSArray *titleOfChaptersArray = [VCTool getDatafromBook:_bookName withField:@"titleOfChaptersArray"];
    if (!titleOfChaptersArray) return nil;
    NSMutableString *str = [[NSMutableString alloc] initWithString:[titleOfChaptersArray objectAtIndex:chapterNumber]];
    return str;
}

-(NSString *) getTextContentStringFromChapterNumber:(NSUInteger)chapterNumber {

    NSString *path = [_fullBookDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.txt", (unsigned long)chapterNumber]];

    NSString *contentString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    return contentString;
}

-(void) splitChapters {
    
    if (!_contentString) {
        return;
    }
    NSError *error = NULL;
    __block int count = 0;
    __block NSString *previousChapterString = @"";
    __block NSRange previousTitleRange;
    __block long wordCount = 0;
    
    previousTitleRange = NSMakeRange(0, 0);
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"(第(一|两|二|三|四|五|六|七|八|九|十|零|百|千|[0-9])+章|序章|楔子|引子|后记).*[\\n\\r\\s]*"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    [regex enumerateMatchesInString:_contentString options:0 range:NSMakeRange(0, [_contentString length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        
        NSRange range = [match rangeAtIndex:0];
        NSString *title = [_contentString substringWithRange:range];
        
        VCLOG(@"%@",title);
        
        unichar charaterBeforeTitle;

        if (range.location != 0) {
            
            charaterBeforeTitle = [_contentString characterAtIndex:(range.location - 1)];
            if (charaterBeforeTitle != '\r' && charaterBeforeTitle != '\n' && charaterBeforeTitle != ' ') {
                if ([_chapterTitleStringArray count] > 0) {
                    VCLOG(@"might have a problem splitting chapters.\n problematic chapter title = %@ previous title = %@", title, [_chapterTitleStringArray objectAtIndex:(count-1)]);
                }
                return ;
            }
        }

        NSRange contentRange = NSMakeRange(NSMaxRange(previousTitleRange), range.location - NSMaxRange(previousTitleRange));
        

        if (previousTitleRange.length == 0) {
            
            previousChapterString = title;
            previousTitleRange = range;
            return;
            
        } else if (contentRange.length < 100) {
            
            if ([[title substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"第"]) {
                
                previousChapterString = title;
                previousTitleRange = range;

                VCLOG(@"might have a problem splitting cuz the length of the chapter is less than 100.\n Chapter =%@, count = %d", title, count);

            }

            return;
        }
        
        [_chapterTitleStringArray addObject:[self trimTitle:previousChapterString]];
        
        NSString *str = NSStringFromRange(contentRange);
        [_chapterContentRangeStringArray addObject:str];
        [_wordCountOfTheBookForTheFirstWordInChapters addObject:@(wordCount).stringValue];
        wordCount += contentRange.length;
        VCLOG(@"word count = %ld", wordCount);
        
        count++;

        VCLOG(@"title:%@ word count:%lu match number:%d",[_chapterTitleStringArray objectAtIndex:count-1], (unsigned long)(NSRangeFromString([_chapterContentRangeStringArray objectAtIndex:count-1]).length), count);

        previousChapterString = title;
        previousTitleRange = range;
    }];

    // final chapter
    
    [_chapterTitleStringArray addObject:[self trimTitle:previousChapterString]];
    
    NSRange contentRange = NSMakeRange(NSMaxRange(previousTitleRange), [_contentString length] - NSMaxRange(previousTitleRange));
    NSString *string = NSStringFromRange(contentRange);
    [_chapterContentRangeStringArray addObject:string];
    count++;

    VCLOG(@"title:%@ word count:%lu match number:%d",[_chapterTitleStringArray objectAtIndex:count-1], (unsigned long)(NSRangeFromString([_chapterContentRangeStringArray objectAtIndex:count-1]).length), count);
    
    _totalNumberOfChapters = count;
    
    [_chapterContentRangeStringArray addObject:NSStringFromRange(NSMakeRange(NSMaxRange(previousTitleRange) , _contentString.length - NSMaxRange(previousTitleRange)))];

    // save parsed info on the book into user's default
    //
    [VCTool storeIntoBook:_bookName withField:@"numberOfChapters" andData:@(count).stringValue];
    [VCTool storeIntoBook:_bookName withField:@"titleOfChaptersArray" andData:_chapterTitleStringArray];
    [VCTool storeIntoBook:_bookName withField:@"wordCountOfTheBookForTheFirstWordInChapters" andData:_wordCountOfTheBookForTheFirstWordInChapters];

}

-(NSString *) trimTitle:(NSString *)titleString {
    
    NSMutableString *str = [[NSMutableString alloc] initWithString:titleString];
    
    [str replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"\r" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    return str;
}

-(void) removeUnwantedCharacter {
    
    NSError *error = NULL;

    __block NSMutableString *content = [[NSMutableString alloc] init];
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"(\\p{script=Han}|[a-z]|[A-Z]|[0-9]|,|。|\"|·|？|!|—|\\n|\\r\\s)+"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    [regex enumerateMatchesInString:_contentString options:0 range:NSMakeRange(0, [_contentString length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        
        NSRange range = [match rangeAtIndex:0];
        [content appendString:[_contentString substringWithRange:range]];
        

    }];
//    VCLOG(@"%@", content);
    _contentString = content;
    
}

-(NSString *)getChapterStringFromString:(NSString *)string {
    
    NSError *error = NULL;

    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"第(一|两|二|三|四|五|六|七|八|九|十|零|百|[0-9])+章"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    NSRange stringRange = NSMakeRange(0, string.length);

    NSArray *matches = [regex matchesInString:string options:0 range:stringRange];
    NSString *matchedString = [string substringWithRange:[[matches lastObject] rangeAtIndex:0]];
    return matchedString;
}

-(NSString *)getChapterTitleFullStringFromString:(NSString *)string {
    
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"第(一|两|二|三|四|五|六|七|八|九|十|零|百|[0-9])+章.*$"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    NSRange stringRange = NSMakeRange(0, string.length);
    
    NSArray *matches = [regex matchesInString:string options:0 range:stringRange];
    NSString *matchedString = [string substringWithRange:[[matches lastObject] rangeAtIndex:0]];
    return matchedString;
}

-(int)getChapterNumberFromTitle:(NSString *)string {
    
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"第([0-9])+章"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    NSRange stringRange = NSMakeRange(0, string.length);
    
    NSArray *matches = [regex matchesInString:string options:0 range:stringRange];
    if (matches.count == 0) {
        return 0;
    }
    NSString *matchedString = [string substringWithRange:[[matches lastObject] rangeAtIndex:0]];
    NSRange range = {1, matchedString.length -1};
    int chapterNumber = [[matchedString substringWithRange:range] intValue];
    return chapterNumber;
}

#pragma mark file tools

-(NSString *)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath
{
    NSString *filePathAndDirectory = [filePath stringByAppendingPathComponent:directoryName];
    NSError *error;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error])
    {
//        VCLOG(@"Create directory error: %@", error);
    }
    return filePathAndDirectory;
}

@end
