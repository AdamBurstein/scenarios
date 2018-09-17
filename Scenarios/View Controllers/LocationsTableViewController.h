//
//  LocationsTableViewController.h
//  Scenarios
//
//  Created by Adam Burstein on 6/20/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationsTableViewController : UITableViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) NSDictionary *dataDictionary;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end
