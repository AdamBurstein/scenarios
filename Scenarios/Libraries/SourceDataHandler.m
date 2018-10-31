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

@synthesize dictData;
@synthesize scenariosArray;
@synthesize scenariosDict;
@synthesize mstrXMLString;
@synthesize scenarioDict;
@synthesize questionsArray;
@synthesize questionsDict;
@synthesize supportingLinks;
@synthesize supportingLinksDict;
@synthesize linkDict;
@synthesize questionDict;
@synthesize instructionsArray;
@synthesize instructionsDict;
@synthesize emergencyContactDict;
@synthesize fileDictionary;
@synthesize versionDict;
@synthesize locationsDict;
@synthesize sublocationsArray;
@synthesize sublocationsDict;
@synthesize sublocation;
@synthesize location;
@synthesize contactDict;

NSFileManager *fileMgr;
NSString *homeDir;
NSString *filename;
NSString *filepath;
NSString *xmlString;
NSString *remoteURL = @"http://192.168.1.210/scenarioData.xml";
NSString *locationName;
NSString *locationDescription;
NSString *locationLatitude;
NSString *locationLongitude;
NSString *sublocationName;
NSString *sublocationDescription;
NSString *sublocationLatitude;
NSString *sublocationLongitude;

BOOL isInLocationsList = NO;
BOOL isInLocation = NO;
BOOL isInSublocation = NO;
BOOL retrieveFiles = NO;
BOOL isInContact = NO;
BOOL isInEmergencyContact = NO;

int instructionsStep = 0;
int questionStep = 0;
int scenarioStep = 0;
int sublocationStep = 0;
int contactStep = 0;

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
    [[NSUserDefaults standardUserDefaults] setObject:xmlString forKey:@"xmlString"];
    
    [xmlParser setDelegate:self];
    [xmlParser parse];
    if ([scenariosDict objectForKey:@"scenario0"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Invalid XML" forKey:@"errorMessage"];
        [[NSUserDefaults standardUserDefaults] setObject:xmlString forKey:@"errorXML"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:scenariosDict forKey:@"scenarios"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"errorMessage"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"errorXML"];
    }

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
    if ([elementName isEqualToString:@"fulldata"])
    {
        scenariosArray = [[NSMutableArray alloc] init];
        scenariosDict = [[NSMutableDictionary alloc] init];
    }
    if ([elementName isEqualToString:@"scenario"])
    {
        scenarioDict = [[NSMutableDictionary alloc] init];
    }
    else if ([elementName isEqualToString:@"questions"])
    {
        questionsArray = [[NSMutableArray alloc] init];
        questionsDict = [[NSMutableDictionary alloc] init];
        questionDict = [[NSMutableDictionary alloc] init];
    }
    else if ([elementName isEqualToString:@"version"])
    {
        versionDict = [[NSMutableDictionary alloc] init];
    }
    else if ([elementName isEqualToString:@"locationList"])
    {
        isInLocationsList = YES;
        locationsDict = [[NSMutableDictionary alloc] init];
    }
    else if ([elementName isEqualToString:@"sublocationList"])
    {
        isInSublocation = YES;
        if (sublocationsArray == nil)
        {
            sublocationsArray = [[NSMutableArray alloc] init];
            sublocationsDict = [[NSMutableDictionary alloc] init];
        }
        else
        {
            [sublocationsArray removeAllObjects];
            [sublocationsDict removeAllObjects];
        }
    }
    else if ([elementName isEqualToString:@"contact"])
    {
        contactDict = [[NSMutableDictionary alloc] init];
        isInContact = YES;
    }
    else if ([elementName isEqualToString:@"emergencyContacts"])
    {
        emergencyContactDict = [[NSMutableDictionary alloc] init];
        isInEmergencyContact = YES;
    }
    else if ([elementName isEqualToString:@"sublocation"])
    {
        sublocation = [[NSMutableDictionary alloc] init];
    }
    else if ([elementName isEqualToString:@"location"])
    {
        location = [[NSMutableDictionary alloc] init];
        isInLocation = YES;
    }
    else if ([elementName isEqualToString:@"supportingLinks"])
    {
        supportingLinks = [[NSMutableArray alloc] init];
        supportingLinksDict = [[NSMutableDictionary alloc] init];
        linkDict = [[NSMutableDictionary alloc] init];
        fileDictionary = [[NSMutableDictionary alloc] init];
    }
    else if ([elementName isEqualToString:@"instructions"])
    {
        instructionsArray = [[NSMutableArray alloc] init];
        instructionsDict = [[NSMutableDictionary alloc] init];
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
    removedWhiteSpaceString = [removedWhiteSpaceString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if ([elementName isEqualToString:@"name"])
    {
        if (isInContact)
        {
            [contactDict setValue:removedWhiteSpaceString forKey:@"name"];
        }
        else if (isInSublocation)
        {
            sublocationName = removedWhiteSpaceString;
        }
        else if (isInLocation)
        {
            locationName = removedWhiteSpaceString;
        }
        else if (isInEmergencyContact)
        {
            [emergencyContactDict setValue:removedWhiteSpaceString forKey:@"name"];
            isInEmergencyContact = NO;
        }
        else if (isInLocationsList)
        {
            [locationsDict setValue:removedWhiteSpaceString forKey:@"name"];
        }
        else
        {
            [scenarioDict setObject:removedWhiteSpaceString forKey:elementName];

        }
    }
    else if ([elementName isEqualToString:@"fulldata"])
    {
        instructionsStep = 0;
        questionStep = 0;
        scenarioStep = 0;
        sublocationStep = 0;
        contactStep = 0;
    }
    else if ([elementName isEqualToString:@"text"])
    {
        [questionDict setObject:removedWhiteSpaceString forKey:elementName];
    }
    else if ([elementName isEqualToString:@"number"])
    {
        [contactDict setObject:removedWhiteSpaceString forKey:elementName];
    }
    else if ([elementName isEqualToString:@"step"])
    {
        [instructionsArray addObject:removedWhiteSpaceString];
        [instructionsDict setValue:removedWhiteSpaceString forKey:[NSString stringWithFormat:@"step%d", instructionsStep]];
        ++instructionsStep;
    }
    else if ([elementName isEqualToString:@"scenario"])
    {
        if (questionsArray != nil)
            [scenarioDict setObject:[questionsArray copy] forKey:@"questions"];
        [scenariosArray addObject:[scenarioDict copy]];
        [scenariosDict setValue:[scenarioDict copy] forKey:[NSString stringWithFormat:@"scenario%d", scenarioStep]];
        ++scenarioStep;
        [scenarioDict removeAllObjects];
    }
    else if ([elementName isEqualToString:@"questions"])
    {
        questionStep = 0;
    }
    else if ([elementName isEqualToString:@"date"] ||
             [elementName isEqualToString:@"supportEmail"] ||
             [elementName isEqualToString:@"supportQueue"] ||
             [elementName isEqualToString:@"remoteURL"])
    {
        [versionDict setValue:removedWhiteSpaceString forKey:elementName];
    }
    else if ([elementName isEqualToString:@"instructions"])
    {
        [questionDict setObject:[instructionsDict copy] forKey:@"instructions"];
        
        instructionsStep = 0;
    }
    else if ([elementName isEqualToString:@"contact"])
    {
        [emergencyContactDict setObject:[contactDict copy] forKey:[NSString stringWithFormat:@"contact%d", contactStep]];
        ++contactStep;
        [contactDict removeAllObjects];
    }
    else if ([elementName isEqualToString:@"emergencyContacts"])
    {
        [scenariosDict setObject:[emergencyContactDict copy] forKey:@"01emergencyContacts"];
        [emergencyContactDict removeAllObjects];
        isInContact = NO;
    }
    else if ([elementName isEqualToString:@"question"])
    {
        [questionsDict setValue:[questionDict copy] forKey:[NSString stringWithFormat:@"question%d", questionStep]];
        ++questionStep;
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
    else if ([elementName isEqualToString:@"name"])
    {
        if (isInSublocation)
            sublocationName = removedWhiteSpaceString;
        else
            locationName = removedWhiteSpaceString;
    }
    else if ([elementName isEqualToString:@"description"])
    {
        if (isInSublocation)
            sublocationDescription = removedWhiteSpaceString;
        else
            locationDescription = removedWhiteSpaceString;
    }
    else if ([elementName isEqualToString:@"latitude"])
    {
        if (isInSublocation)
            sublocationLatitude = removedWhiteSpaceString;
        else
            locationLatitude = removedWhiteSpaceString;
    }
    else if ([elementName isEqualToString:@"longitude"])
    {
        if (isInSublocation)
            sublocationLongitude = removedWhiteSpaceString;
        else
            locationLongitude = removedWhiteSpaceString;
    }
    else if ([elementName isEqualToString:@"location"])
    {
        [location setObject:locationName forKey:@"name"];
        [location setObject:locationLatitude forKey:@"latitude"];
        [location setObject:locationLongitude forKey:@"longitude"];
        [location setObject:locationDescription forKey:@"description"];
//        [location setObject:[sublocationsArray copy] forKey:@"sublocations"];
        [locationsDict setObject:[location copy] forKey:locationName];
        [sublocationsArray removeAllObjects];
        [location removeAllObjects];
        isInLocation = NO;

    }
    else if ([elementName isEqualToString:@"sublocation"])
    {
        if (isInSublocation)
        {
            [sublocation setObject:sublocationName forKey:@"name"];
            [sublocation setObject:sublocationLatitude forKey:@"latitude"];
            [sublocation setObject:sublocationLongitude forKey:@"longitude"];
            [sublocation setObject:sublocationDescription forKey:@"description"];
            [sublocationsDict setValue:[sublocation copy] forKey:[NSString stringWithFormat:@"sublocation%d", sublocationStep]];
            ++sublocationStep;
            [sublocationsArray addObject: [sublocation copy]];
            [sublocation removeAllObjects];
        }
    }
    else if ([elementName isEqualToString:@"sublocationList"])
    {
        [location setObject:[sublocationsArray copy] forKey:@"sublocations"];
        sublocationStep = 1;
        isInSublocation = NO;
    }
    else if ([elementName isEqualToString:@"locationList"])
    {
        [scenariosDict setValue:[locationsDict copy] forKey:@"00locations"];
        [scenariosArray addObject:[locationsDict copy]];
        [locationsDict removeAllObjects];
        isInLocationsList = NO;
    }

    mstrXMLString = nil;
    
    if ([[versionDict allKeys] containsObject:@"remoteURL"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:versionDict forKey:@"versionData"];
        NSData *remoteURLData = [[versionDict valueForKey:@"remoteURL"] dataUsingEncoding:NSUTF8StringEncoding];
        [self WriteToFile:remoteURLData inFile:@"remoteURL.txt"]; 
    }
}

#pragma mark - Download Methods

-(NSData *)downloadFileWithString:(NSString *)remoteURL
{
    return [self downloadFile:[NSURL URLWithString:remoteURL]];
}

-(NSData *)downloadFile:(NSURL *)remoteURL
{
    __block NSData *theReturn;

    NSURLRequest *request = [NSURLRequest requestWithURL:remoteURL];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 3.0;
    config.timeoutIntervalForResource = 6.0;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        theReturn = data;
        if (!data)
        {
            NSLog(@"%@", error);
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return theReturn;
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

