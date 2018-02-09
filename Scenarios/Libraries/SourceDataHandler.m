//
//  SourceDataHandler.m
//  Scenarios
//
//  Created by Adam Burstein on 2/1/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SourceDataHandler.h"
#import "Reachability.h"

@interface SourceDataHandler ()

@end

@implementation SourceDataHandler

@synthesize scenariosArray;
@synthesize mstrXMLString;
@synthesize scenarioDict;
@synthesize questionsArray;
@synthesize questionDict;
@synthesize supportingLinks;
@synthesize linkDict;
@synthesize instructionsArray;
@synthesize fileDictionary;
@synthesize versionDict;

NSFileManager *fileMgr;
NSString *homeDir;
NSString *filename;
NSString *filepath;
NSString *xmlString;
NSString *remoteURL = @"http://10.17.124.192/scenarioData.xml";
BOOL retrieveFiles = NO;

#pragma mark - Methods Begin

-(BOOL)IsConnectionAvailable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    return !(networkStatus == NotReachable);
}

#pragma mark - File Handling Methods

-(NSString *)GetDocumentDirectory{
    fileMgr = [NSFileManager defaultManager];
    homeDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    return homeDir;
}

-(void)WriteToFile:(NSData *)data inFile:(NSString *)file
{
    filepath = [[NSString alloc] init];
    NSError *err;
    
    filepath = [self GetDocumentDirectory];
//    for (int i = 0; i < [path count]; ++i)
//    {
//        filepath = [filepath stringByAppendingPathComponent:[path objectAtIndex:i]];
//    }
//    if (![[NSFileManager defaultManager] fileExistsAtPath:filepath])
//    {
//        [[NSFileManager defaultManager] createDirectoryAtPath:filepath withIntermediateDirectories:YES attributes:nil error:nil];
//    }
    filepath = [filepath stringByAppendingPathComponent:file];

    BOOL ok = [data writeToFile:filepath atomically:YES];
    
    if (!ok) {
        NSLog(@"Error writing file at %@\n%@",
              filepath, [err localizedFailureReason]);
    }
    
}

-(NSString *) readFromFile:(NSString *)filename
{
    filepath = [[NSString alloc] init];
    NSError *error;
    filepath = [self.GetDocumentDirectory stringByAppendingPathComponent:filename];
    NSString *txtInFile = [[NSString alloc] initWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    return txtInFile;
}

-(void) doFileDownloads
{
    for (int i = 0; i < [scenariosArray count]; ++i)
    {
        NSDictionary *dictionary = [scenariosArray objectAtIndex:i];
        NSArray *links = [dictionary valueForKey:@"links"];
        for (int j = 0; j < [links count]; ++j)
        {
            NSDictionary *linkDict = [links objectAtIndex:j];
            if ([linkDict objectForKey:@"fileurl"] != nil)
            {
                //NSData *data = [self downloadFileWithString:[linkDict valueForKey:@"fileurl"]];
                NSString *fileName =  [linkDict valueForKey:@"fileurl"];
                fileName = [fileName stringByReplacingOccurrencesOfString:@"http://" withString:@""];
                fileName = [fileName stringByReplacingOccurrencesOfString:@"https://" withString:@""];
                fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
                NSData *data = [self downloadFileWithString:[linkDict objectForKey:@"fileurl"]];
                if (data != nil)
                {
                    [self WriteToFile:data inFile:fileName];
                }
            }
        }
    }
}

#pragma mark - XML Parsing Methods

-(void) startParsing
{
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [xmlParser setDelegate:self];
    [xmlParser parse];
    [[NSUserDefaults standardUserDefaults] setObject:scenariosArray forKey:@"scenarios"];

    if (retrieveFiles)
        [self doFileDownloads];
    
    retrieveFiles = NO;
}

- (void)forceParseXMLData
{
    NSURL *url = [self getURL];
    retrieveFiles = YES;
    NSData *data = [self downloadFile:url];
    xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self WriteToFile:data inFile:@"scenarioData.xml"];
    [self startParsing];
}

-(void)parseXMLData
{
    xmlString = [self readFromFile:@"scenarioData.xml"];
    if ((xmlString == nil) || ([xmlString isEqualToString:@""]))
    {
        if (![self IsConnectionAvailable])
        {
            @throw [NSException exceptionWithName:@"NoConnectionException" reason:@"No connection available" userInfo:nil];
        }
        NSURL *url = [self getURL];
        NSData *data = [self downloadFile:url];
        xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        retrieveFiles = YES;
        [self WriteToFile:data inFile:@"scenarioData.xml"];
    }
    [self startParsing];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(nonnull NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(nonnull NSDictionary<NSString *,NSString *> *)attributeDict
{
    if ([elementName isEqualToString:@"scenarios"]) {
        scenariosArray = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:@"scenario"]) {
        scenarioDict = [[NSMutableDictionary alloc] init];
    }
    else if ([elementName isEqualToString:@"questions"]) {
        questionsArray = [[NSMutableArray alloc] init];
        questionDict = [[NSMutableDictionary alloc] init];
    }
    else if ([elementName isEqualToString:@"version"])
    {
        versionDict = [[NSMutableDictionary alloc] init];
    }
    else if ([elementName isEqualToString:@"supportingLinks"]) {
        supportingLinks = [[NSMutableArray alloc] init];
        linkDict = [[NSMutableDictionary alloc] init];
        fileDictionary = [[NSMutableDictionary alloc] init];
    }
    else if ([elementName isEqualToString:@"instructions"])
    {
        instructionsArray = [[NSMutableArray alloc] init];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(nonnull NSString *)string
{
    if (!mstrXMLString) {
        mstrXMLString = [[NSMutableString alloc] initWithString:string];
    }
    else {
        [mstrXMLString appendString:string];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(nonnull NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName
{
    NSString *removedWhiteSpaceString = [mstrXMLString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    removedWhiteSpaceString = [removedWhiteSpaceString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    removedWhiteSpaceString = [removedWhiteSpaceString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if ([elementName isEqualToString:@"name"])
    {
        [scenarioDict setObject:removedWhiteSpaceString forKey:elementName];
    }
    else if ([elementName isEqualToString:@"text"])
    {
        [questionDict setObject:removedWhiteSpaceString forKey:elementName];
    }
    else if ([elementName isEqualToString:@"step"])
    {
        [instructionsArray addObject:removedWhiteSpaceString];
    }
    else if ([elementName isEqualToString:@"scenario"])
    {
        if (questionsArray != nil)
            [scenarioDict setObject:[questionsArray copy] forKey:@"questions"];
        [scenariosArray addObject:[scenarioDict copy]];
        [scenarioDict removeAllObjects];
    }
    else if ([elementName isEqualToString:@"date"] ||
             [elementName isEqualToString:@"supportEmail"] ||
             [elementName isEqualToString:@"supportQueue"])
    {
        [versionDict setValue:removedWhiteSpaceString forKey:elementName];
    }
    else if ([elementName isEqualToString:@"instructions"])
    {
        [questionDict setObject:[instructionsArray copy] forKey:@"instructions"];
    }
    else if ([elementName isEqualToString:@"question"])
    {
        [questionsArray addObject:[questionDict copy]];
        [questionDict removeAllObjects];
    }
    else if ([elementName isEqualToString:@"linktext"]
             || [elementName isEqualToString:@"url"])
    {
        [linkDict setObject:removedWhiteSpaceString forKey:elementName];
    }
    else if ([elementName isEqualToString:@"title"])
    {
        [linkDict setObject:removedWhiteSpaceString forKey:elementName];
    }
    else if ([elementName isEqualToString:@"fileurl"])
    {
        [linkDict setObject:removedWhiteSpaceString forKey:elementName];
    }
    else if ([elementName isEqualToString:@"link"])
    {
        [supportingLinks addObject:[linkDict copy]];
        [linkDict removeAllObjects];
    }
    else if ([elementName isEqualToString:@"supportingLinks"])
    {
        [scenarioDict setObject:[supportingLinks copy] forKey:@"links"];
        [supportingLinks removeAllObjects];
    }

    mstrXMLString = nil;
    [[NSUserDefaults standardUserDefaults] setObject:versionDict forKey:@"versionData"];
}

#pragma mark - Download Methods

-(NSData *)downloadFileWithString:(NSString *)remoteURL
{
    return [self downloadFile:[NSURL URLWithString:remoteURL]];
}

-(NSData *)downloadFile:(NSURL *)remoteURL
{
    NSURLResponse *urlResponse;
    NSError *error;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:remoteURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:2.0];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    return data;
}

-(NSURL *)getURL
{
    NSString *urlString = @"";
    
    urlString = [self readFromFile:@"remoteURL.txt"];
    if ((urlString == nil) || ([urlString isEqualToString:@""]))
        urlString = remoteURL;
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

@end

