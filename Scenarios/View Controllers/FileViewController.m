//
//  FileViewController.m
//  Scenarios
//
//  Created by Adam Burstein on 2/7/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#import "FileViewController.h"

@implementation FileViewController

@synthesize fileName;
@synthesize filePath;

#pragma mark - Methods
-(void)viewDidLoad
{
    self.navigationItem.title = fileName; 
}

-(void)viewWillAppear:(BOOL)animated
{

    
    NSString *fn = [self.GetDocumentDirectory stringByAppendingPathComponent:[self getDirectory]];
    NSData *data = [NSData dataWithContentsOfFile:fn];
    PDFDocument *pdfDocument = [[PDFDocument alloc] initWithData:data];
    PDFView *pdfView = [[PDFView alloc] initWithFrame:[self.view frame]];
    pdfView.document = pdfDocument;
    pdfView.displayMode = kPDFDisplaySinglePageContinuous;
    pdfView.autoScales = true;
    pdfView.layer.borderWidth = 2;
    pdfView.layer.borderColor = [UIColor clearColor].CGColor;
    [self.view addSubview:pdfView];
}

-(NSString *)GetDocumentDirectory
{
    NSString *homeDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    return homeDir;
}

-(NSString *)getDirectory
{
    NSString *returnValue = @"";
    filePath = [filePath stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    filePath = [filePath stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    filePath = [filePath stringByReplacingOccurrencesOfString:@"/" withString:@"_"];

    returnValue = [returnValue stringByAppendingPathComponent:filePath];
    return returnValue;
}

@end
