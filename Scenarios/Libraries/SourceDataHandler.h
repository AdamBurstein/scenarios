//
//  SourceDataHandler.h
//  Scenarios
//
//  Created by Adam Burstein on 2/1/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#ifndef SourceDataHandler_h
#define SourceDataHandler_h

@interface SourceDataHandler : NSObject <NSXMLParserDelegate>
-(void)parseXMLData;
-(void)forceParseXMLData;

@property (nonatomic, strong) NSMutableDictionary *dictData;
@property (nonatomic, strong) NSMutableArray *scenariosArray;
@property (nonatomic, strong) NSMutableDictionary *scenariosDict;
@property (nonatomic, strong) NSMutableString *mstrXMLString;
@property (nonatomic, strong) NSMutableDictionary *scenarioDict;
@property (nonatomic, strong) NSMutableArray *questionsArray;
@property (nonatomic, strong) NSMutableDictionary *questionsDict;
@property (nonatomic, strong) NSMutableArray *supportingLinks;
@property (nonatomic, strong) NSMutableDictionary *supportingLinksDict;
@property (nonatomic, strong) NSMutableDictionary *linkDict;
@property (nonatomic, strong) NSMutableDictionary *questionDict;
@property (nonatomic, strong) NSMutableArray *instructionsArray;
@property (nonatomic, strong) NSMutableDictionary *instructionsDict;
@property (nonatomic, strong) NSMutableDictionary *fileDictionary;
@property (nonatomic, strong) NSMutableDictionary *versionDict;
@property (nonatomic, strong) NSMutableDictionary *locationsDict;
@property (nonatomic, strong) NSMutableArray *sublocationsArray;
@property (nonatomic, strong) NSMutableDictionary *sublocationsDict;
@property (nonatomic, strong) NSMutableDictionary *sublocation;
@property (nonatomic, strong) NSMutableDictionary *location;
@property (nonatomic, strong) NSMutableDictionary *contactDict;
@property (nonatomic, strong) NSMutableDictionary *emergencyContactDict;


@end

#endif /* SourceDataHandler_h */

