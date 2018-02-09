//
//  SettingsViewController.m
//  Scenarios
//
//  Created by Adam Burstein on 2/8/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#import "SettingsViewController.h"
#import "SourceDataHandler.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize appVersionLabel;
@synthesize xmlVersionLabel;
@synthesize remoteURLField;
@synthesize saveButton;
@synthesize cancelButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"versionData"];
    [xmlVersionLabel setText:[dictionary valueForKey:@"date"]];
    
    [appVersionLabel setText:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]];
    
    [remoteURLField setText:[self readFromFile]];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickSaveOrCancel:(id)sender
{
//    UIAlertController *controller;
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    if (sender == cancelButton)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (sender == saveButton)
    {
        [self WriteToStringFile];
        SourceDataHandler *sdh = [[SourceDataHandler alloc] init];
        [sdh forceParseXMLData];
        [self.navigationController popViewControllerAnimated:YES];

    }
}

-(NSString *) readFromFile
{
    NSString *filepath = [[NSString alloc] init];
    NSError *error;
    filepath = [self.GetDocumentDirectory stringByAppendingString:@"/remoteURL.txt"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        return @"";
    }
    NSString *txtInFile = [[NSString alloc] initWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    return txtInFile;
}

-(void)WriteToStringFile
{
    NSString *filepath = [[NSString alloc] init];
    NSError *err;
    
    filepath = [self.GetDocumentDirectory stringByAppendingPathComponent:@"remoteURL.txt"];
    
    BOOL ok = [[remoteURLField text] writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:&err];
    
    if (!ok) {
        NSLog(@"Error writing file at %@\n%@",
              filepath, [err localizedFailureReason]);
    }
    
}

-(NSString *)GetDocumentDirectory{
    //    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *homeDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    return homeDir;
}

-(void)viewDidAppear:(BOOL)animated
{
    [remoteURLField becomeFirstResponder];
}

/*
 
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
