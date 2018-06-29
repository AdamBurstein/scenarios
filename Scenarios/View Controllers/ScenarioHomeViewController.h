//
//  ViewController.h
//  Scenarios
//
//  Created by Adam Burstein on 2/1/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <MessageUI/MessageUI.h>

@interface ScenarioHomeViewController : UITableViewController <MFMailComposeViewControllerDelegate>

-(void)refreshData;
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;
@end

