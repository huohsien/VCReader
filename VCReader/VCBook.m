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
    NSString *_contentString;

}

@synthesize bookName = _bookName;
@synthesize totalNumberOfChapters = _totalNumberOfChapters;

-(instancetype) initWithBookName:(NSString *)bookName {
    self = [super init];
    if (self) {
        _bookName = bookName;
        
        [self setup];
    }
    return self;
}


-(void) setup {
    
    _chapterTitleStringArray = [NSMutableArray new];
    _chapterContentRangeStringArray = [NSMutableArray new];
    _totalNumberOfChapters = 0;
    
    [self loadContent];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    _fullBookDirectoryPath = [self createDirectory:_bookName atFilePath:documentsPath];
    
    BOOL isBookLoaded;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_fullBookDirectoryPath]) { // Directory exists
        NSArray *listOfFiles = [fileManager contentsOfDirectoryAtPath:_fullBookDirectoryPath error:nil];
        isBookLoaded = listOfFiles.count > 0 ? YES : NO;
    }
    
    if (!isBookLoaded) {
        [self splitChapters];
        
        for (int i = 0; i < _chapterTitleStringArray.count; i++) {
            [self writeContentOfChapter:i];
            // write title to storage
        }
    }
    
    _totalNumberOfChapters = [[VCHelperClass getDatafromBook:_bookName withField:@"numberOfChapters"] intValue];

}

-(void) loadContent {

    NSURL *textURL = [[NSBundle mainBundle] URLForResource:_bookName withExtension:@"txt"];
    NSError *error = nil;
    _contentString = [[NSString alloc] initWithContentsOfURL:textURL encoding:NSUTF8StringEncoding error:&error];
}

-(void) writeContentOfChapter:(int)chapterNumber {
    
    NSString *path = [_fullBookDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.txt", (unsigned long)chapterNumber]];
    NSString *string = [_contentString substringWithRange:NSRangeFromString([_chapterContentRangeStringArray objectAtIndex: chapterNumber])];
    NSString *processedString = [self removeExtraLinesInString:string];
    [processedString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(NSString *)getChapterTitleStringFromChapterNumber:(NSUInteger)chapterNumber {

    NSMutableString *str = [[NSMutableString alloc] initWithString:[[VCHelperClass getDatafromBook:_bookName withField:@"titleOfChaptersArray"] objectAtIndex:chapterNumber]];
    return str;
}

-(NSString *) getTextContentStringFromChapterNumber:(NSUInteger)chapterNumber {

    NSString *path = [_fullBookDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.txt", (unsigned long)chapterNumber]];

    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

-(NSString *) removeExtraLinesInString:(NSString *)contentString {
    
    NSMutableString *str = [[NSMutableString alloc] initWithString:contentString];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                                  @"(\\r|\\n)+" options:0 error:nil];
    [regex replaceMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@"\n"];
    
    [str replaceOccurrencesOfString:@"\r\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, 10)];
    [str replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, 10)];
    return str;
}

-(void) splitChapters {
    
    NSError *error = NULL;
    __block int count = 0;
    __block NSString *previousChapterString = @"";
    __block NSRange previousTitleRange;
    
    previousTitleRange = NSMakeRange(0, 0);
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"第*(一|二|三|四|五|六|七|八|九|十|零|百|[0-9])*卷*.*第(一|二|三|四|五|六|七|八|九|十|零|百|[0-9])+章.*[\\n\\r\\s]*"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    [regex enumerateMatchesInString:_contentString options:0 range:NSMakeRange(0, [_contentString length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        
        NSRange range = [match rangeAtIndex:0];
        NSString *title = [_contentString substringWithRange:range];
        
        unichar charaterBeforeTitle;

        if (range.location != 0) {
            
            charaterBeforeTitle = [_contentString characterAtIndex:(range.location - 1)];
            if (charaterBeforeTitle != '\r' && charaterBeforeTitle != '\n') {
                NSLog(@"%s: might have a problem splitting chapters. problematic chapter title = %@ previous title = %@", __PRETTY_FUNCTION__, title, [_chapterTitleStringArray objectAtIndex:count-1]);
                return ;
            }
        }

        NSRange contentRange = NSMakeRange(NSMaxRange(previousTitleRange), range.location - NSMaxRange(previousTitleRange));
        
        if (contentRange.length < 100) {
            
            NSLog(@"%s: might have a problem splitting cuz the length of the chapter is less than 100. Chapter =%@", __PRETTY_FUNCTION__, title);

            return;
        }
        
        [_chapterTitleStringArray addObject:[self trimTitle:previousChapterString]];
        
        NSString *string = NSStringFromRange(contentRange);
        [_chapterContentRangeStringArray addObject:string];
        
//        NSLog(@"title:%@ word count:%lu match number:%d",[_chapterTitleStringArray objectAtIndex:count], (unsigned long)(NSRangeFromString([_chapterContentRangeStringArray objectAtIndex:count]).length), count);

        count++;
        previousChapterString = title;
        previousTitleRange = range;
    }];

    // final chapter
    
    [_chapterTitleStringArray addObject:[self trimTitle:previousChapterString]];
    
    NSRange contentRange = NSMakeRange(NSMaxRange(previousTitleRange), [_contentString length] - NSMaxRange(previousTitleRange));
    NSString *string = NSStringFromRange(contentRange);
    [_chapterContentRangeStringArray addObject:string];
    
//    NSLog(@"title:%@ word count:%lu match number:%d",[_chapterTitleStringArray objectAtIndex:count], (unsigned long)(NSRangeFromString([_chapterContentRangeStringArray objectAtIndex:count]).length), count);
    
    count++;
    
    [_chapterContentRangeStringArray addObject:NSStringFromRange(NSMakeRange(NSMaxRange(previousTitleRange) , _contentString.length - NSMaxRange(previousTitleRange)))];
    [VCHelperClass storeIntoBook:_bookName withField:@"numberOfChapters" andData:@(count).stringValue];
    [VCHelperClass storeIntoBook:_bookName withField:@"titleOfChaptersArray" andData:_chapterTitleStringArray];


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
//    NSLog(@"%@", content);
    _contentString = content;
    
}
-(NSString *)getChapterStringFromString:(NSString *)string {
    
    NSError *error = NULL;

    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"第(一|二|三|四|五|六|七|八|九|十|零|百|[0-9])+章"
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
                                  regularExpressionWithPattern:@"第(一|二|三|四|五|六|七|八|九|十|零|百|[0-9])+章.*$"
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
//        NSLog(@"Create directory error: %@", error);
    }
    return filePathAndDirectory;
}

@end
