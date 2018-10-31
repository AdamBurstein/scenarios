//
//  ScenarioHomeViewController
//  Scenarios
//
//  Created by Adam Burstein on 2/1/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#import "ScenarioHomeViewController.h"
#import "SourceDataHandler.h"
#import "QuestionViewController.h"
#import "SettingsViewController.h"
#import "LocationsTableViewController.h"
#import "ContactViewController.h"

@interface ScenarioHomeViewController ()

@end

@implementation ScenarioHomeViewController

@synthesize hostReachability;
@synthesize wifiReachability;
@synthesize internetReachability;

UIViewController *lastController;

NSMutableArray *scenariosArray;
NSMutableDictionary *scenariosDict;
NSArray *sortedKeys;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshData];
    self.title = @"Home";
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(forceRefreshData)];
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(reset)];
    UIBarButtonItem *sendLogsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose  target:self action:@selector(sendLogs)];
    UIBarButtonItem *configButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(configure)];
    NSArray *leftButtons = @[barButtonItem, configButton];
    NSArray *rightButtons = @[sendLogsButton, resetButton];
    self.navigationItem.leftBarButtonItems = leftButtons;
    self.navigationItem.rightBarButtonItems = rightButtons;
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0]];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    
    scenariosDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"scenarios"];
    sortedKeys = [[scenariosDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    [self.tableView reloadData];
}

-(void)sendLogs
{
    if ([MFMailComposeViewController canSendMail])
    {
        NSDictionary *supportDictionary = [[NSUserDefaults standardUserDefaults] valueForKey:@"versionData"];
        NSString *supportEmail = [supportDictionary valueForKey:@"supportEmail"];
        MFMailComposeViewController *mcvc = [[MFMailComposeViewController alloc] init];
        mcvc.mailComposeDelegate = self;
        [mcvc setToRecipients:[NSArray arrayWithObjects:supportEmail, nil]];
        [mcvc setSubject:@"Debug Log"];
        NSString *errorMessage = [NSString stringWithFormat:@"\n\n\nPlease feel free to add notes above this line, but do not make any changes below this point.\n\n%@\n\n\n==========\n\n\n@\%@",
                                  [[NSUserDefaults standardUserDefaults] valueForKey:@"errorXML"],
                                  [[NSUserDefaults standardUserDefaults] valueForKey:@"scenarios"]];
        [mcvc setMessageBody:errorMessage isHTML:NO];
        [mcvc setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [self presentViewController:mcvc animated:YES completion:nil];
    }
}

-(void)configure
{
    
    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    lastController = controller;
    [self.navigationController pushViewController:controller animated:YES];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *bgImage = [UIImage imageNamed:@"WHMO AppLaunch-06 BLUE 3x.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bgImage];
    imageView.alpha = 0.15;
    [self.tableView setBackgroundView:imageView];
    
    if ([lastController isKindOfClass:[SettingsViewController class]])
    {
        scenariosDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"scenarios"];
        sortedKeys = [[scenariosDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

        NSString *errorMessage = [[NSUserDefaults standardUserDefaults] valueForKey:@"errorMessage"];
        
//        if ([scenariosDict objectForKey:@"scenario0"] == nil)
        if (![errorMessage isEqualToString:@""])
        {
            UIAlertController *alertController2 = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was an error retrieving the scenario data.\n\nYour previous scenario data will remain available to you at this time.\n\nWhat would you like to do?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Continue with existing scenarios" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Try to enter a new remote address" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                        {[self configure];}];
            UIAlertAction *sendDebugAction = [UIAlertAction actionWithTitle:@"Request support" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                              {[self sendLogs];}];

            [alertController2 addAction:noAction];
            [alertController2 addAction:sendDebugAction];
            [alertController2 addAction:yesAction];
            [self presentViewController:alertController2 animated:YES completion:nil];
        }

        [self.tableView reloadData];
        lastController = nil;
    }
}

-(void) reset
{
    NSString *filepath = self.GetDocumentDirectory;
    NSError *err;
    BOOL foundOne = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:filepath error:&err];
    for (int i = 0; i < [files count]; ++i)
    {
        NSString *filename = [files objectAtIndex:i];
        if ([filename containsString:@"_set.txt"])
        {
            foundOne = YES;
            NSString *thisFile = [filepath stringByAppendingPathComponent:filename];
            BOOL success = [fileManager removeItemAtPath:thisFile error:&err];
            if (success)
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Complete" message:@"You have successfully reset all scenarios" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"Thanks" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else
            {
                UIAlertController *alertController2 = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was an error retrieving the scenario data.\n\nYour previous scenario data will remain available to you at this time.\n\nWhat would you like to do?" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Continue with existing scenarios" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Try to enter a new remote address" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                            {[self configure];}];
                UIAlertAction *sendDebugAction = [UIAlertAction actionWithTitle:@"Request support" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                  {[self sendLogs];}];
                
                [alertController2 addAction:noAction];
                [alertController2 addAction:sendDebugAction];
                [alertController2 addAction:yesAction];
                [self presentViewController:alertController2 animated:YES completion:nil];
            }

        }

    }
    if (!foundOne)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Complete" message:@"You have successfully reset all scenarios" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Thanks" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }

    
}

-(NSString *)GetDocumentDirectory{
    NSString *homeDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    return homeDir;
}

-(id)init
{
    if (self != nil)
    {
        NSString *remoteHostName = @"www.whitehouse.gov";
        self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
        [self.hostReachability startNotifier];
        
        self.internetReachability = [Reachability reachabilityForInternetConnection];
        [self.internetReachability startNotifier];
        
        self.wifiReachability = [Reachability reachabilityForLocalWiFi];
        [self.wifiReachability startNotifier];
    }
    return self;
}

-(BOOL)IsConnectionAvailable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    return !(networkStatus == NotReachable);
}

-(void)forceRefreshData
{

    if (![self IsConnectionAvailable])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Connection" message:@"You do not have a network connection at this time, and cannot refresh your scenarios data.  Please try again later." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [self retrieveData:YES];
    
}

UIAlertController *pleaseWaitController;

-(void)showPopup
{

}

-(void)retrieveData:(BOOL)withForce
{
    SourceDataHandler *handler = [[SourceDataHandler alloc] init];
    if (withForce)
        [handler forceParseXMLData];
    else
        [handler parseXMLData];
        
        
    scenariosDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"scenarios"];
    sortedKeys = [[scenariosDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    NSString *errorMessage = [[NSUserDefaults standardUserDefaults] valueForKey:@"errorMessage"];

    //        if ([scenariosDict objectForKey:@"scenario0"] == nil)
    if (![errorMessage isEqualToString:@""])
    {
        UIAlertController *alertController2 = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was an error retrieving the scenario data.  Would you like to provide a remote address?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *sendDebugAction = [UIAlertAction actionWithTitle:@"Send Logs" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                    {[self sendLogs];}];
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                    {[self configure];}];
        [alertController2 addAction:noAction];
        [alertController2 addAction:sendDebugAction];
        [alertController2 addAction:yesAction];
        [self presentViewController:alertController2 animated:YES completion:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"errorMessage"];
    }
    [self.tableView reloadData];

}

-(void)refreshData
{
    [self retrieveData:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *theText = @"";
    if (section == 0)
        theText = @"Operational Support";
    if (section == 1)
        theText = @"Scenarios";
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 50)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15,15,headerView.frame.size.width-30,35)];
    [label setText:theText];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setFont:[UIFont boldSystemFontOfSize:22.0f]];
    [label setTextColor:[UIColor blackColor]];
    [headerView addSubview:label];
    return headerView;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 3;
    
    return ([[scenariosDict allKeys] count] - 3);
}

- (UITableViewCell *)tableView:(UITableView *)tableView
             cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier];
    }
    
    NSDictionary *dict = nil;
    dict = [scenariosDict objectForKey:[sortedKeys objectAtIndex:indexPath.row]];
    if (indexPath.section == 1)
    {
        dict = [scenariosDict objectForKey:[sortedKeys objectAtIndex:indexPath.row+3]];
    }
    
    NSString *theString = [dict valueForKey:@"name"];
    theString = [theString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    theString = [theString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    theString = [theString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    theString = [theString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    UIFont *font = [UIFont systemFontOfSize:18];
    cell.layoutMargins = UIEdgeInsetsZero;
    [[cell textLabel] setNumberOfLines:10];
    [[cell textLabel] setFont:font];

    [[cell textLabel] setText:theString];
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [scenariosDict objectForKey:[sortedKeys objectAtIndex:indexPath.row]];
    if (indexPath.section == 1)
    {
        dict = [scenariosDict objectForKey:[sortedKeys objectAtIndex:indexPath.row+3]];
    }
    
    if (indexPath.section == 0)
    {
        if ([[sortedKeys objectAtIndex:indexPath.row] isEqualToString:@"00locations"])
        {
            LocationsTableViewController *locController = [[LocationsTableViewController alloc] init];
            [locController setDataDictionary:dict];
            [locController setTitle:[dict valueForKey:@"name"]];
            [self.navigationController pushViewController:locController animated:YES];
        }
        else if ([[sortedKeys objectAtIndex:indexPath.row] isEqualToString:@"01emergencyContacts"])
        {
            ContactViewController *controller = [[ContactViewController alloc] init];
            [controller setContactDictionary:dict];
            [controller setTitle:[dict valueForKey:@"name"]];
            [self.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            QuestionViewController *nextController = [[QuestionViewController alloc] init];
            [nextController setDataDictionary:dict];
            [nextController setTitle:[dict valueForKey:@"name"]];
            [self.navigationController pushViewController:nextController animated:YES];
        }
    }
    else
    {
        QuestionViewController *nextController = [[QuestionViewController alloc] init];
        [nextController setDataDictionary:dict];
        [nextController setTitle:[dict valueForKey:@"name"]];
        [self.navigationController pushViewController:nextController animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}

#pragma mark - MFMailComposeViewControllerDelegate Methode.
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            
            break;
            
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            
            break;
            
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            
            break;
            
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@",error.description);
            
            break;
    }
    
    // Dismiss the mail compose view controller.
    [controller dismissViewControllerAnimated:true completion:nil];
    
}
@end

