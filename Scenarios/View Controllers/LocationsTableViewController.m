//
//  LocationsTableViewController.m
//  Scenarios
//
//  Created by Adam Burstein on 6/20/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#import "LocationsTableViewController.h"
#import "MapViewController.h"

@interface LocationsTableViewController ()

@end

@implementation LocationsTableViewController

@synthesize dataDictionary;
@synthesize locationManager;

CLLocation *currentLocation;

NSMutableArray *locationsArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *bgImage = [UIImage imageNamed:@"WHMO AppLaunch-06 BLUE 3x.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bgImage];
    imageView.alpha = 0.15;
    [self.tableView setBackgroundView:imageView];

    locationManager = [[CLLocationManager alloc] init];

    
    [self.locationManager requestWhenInUseAuthorization];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    locationsArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *keys = [[dataDictionary allKeys] mutableCopy];
    [keys removeObject:@"name"];
    
    for (NSString *str in keys)
    {
        NSDictionary *sublocations = [[dataDictionary valueForKey:str] valueForKey:@"sublocations"];
        for (id loc in sublocations)
        {
            NSDictionary *location = (NSDictionary *)loc;
            NSString *locName = [location valueForKey:@"name"];
            [locationsArray addObject:[NSString stringWithFormat:@"%@ - %@", str, locName]];
        }
    }
    NSArray *sortedArray = [locationsArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    locationsArray = [sortedArray copy];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [locationsArray count];
}

- (NSString *) getDistanceToBase:(NSString *)baseName
{
    CLLocation *baseLocation;
    
    NSMutableArray *keys = [[dataDictionary allKeys] mutableCopy];
    [keys removeObject:@"name"];
    
    for (NSString *str in keys)
    {
        NSDictionary *sublocations = [[dataDictionary valueForKey:str] valueForKey:@"sublocations"];
        for (id loc in sublocations)
        {
            NSDictionary *location = (NSDictionary *)loc;
            NSString *locName = [location valueForKey:@"name"];
            
            NSString *tmpString = [NSString stringWithFormat:@"%@ - %@", str, locName];
            if ([tmpString isEqualToString:baseName])
            {
                baseLocation = [[CLLocation alloc]
                initWithLatitude:[[location valueForKey:@"latitude"] doubleValue]
                                longitude:[[location valueForKey:@"longitude"] doubleValue]];
            }
        }
    }
    
    if (baseLocation == nil)
        return @"???";
    if (currentLocation == nil)
        return @"???";
    
    CLLocationDistance distanceInMiles = [currentLocation distanceFromLocation:baseLocation] / 1609.344;
    
    
    return [NSString stringWithFormat:@"%0.01f mi", distanceInMiles];
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
    
    NSString *distanceToBase = [self getDistanceToBase:[locationsArray objectAtIndex:indexPath.row]];
    UIView *theCellView = [self getCellContentView:[locationsArray objectAtIndex:indexPath.row] forDistance:distanceToBase];
    [[cell.contentView viewWithTag:500] removeFromSuperview];
    [theCellView setTag:500];
    [cell.contentView addSubview:theCellView];
    [[cell textLabel] setTextColor:[UIColor clearColor]];
    
    [[cell textLabel] setText:[locationsArray objectAtIndex:indexPath.row]];
    [cell setBackgroundColor:[UIColor clearColor]];

    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0f;
}

- (UIView *)getCellContentView:(NSString *)baseName forDistance:(NSString *)distance
{
    CGRect fullRect = CGRectMake(0,0,self.view.frame.size.width, 40.0f);
    CGRect titleRect = CGRectMake(5,5,self.view.frame.size.width-80, 30.0f);
    CGRect distanceRect = CGRectMake(self.view.frame.size.width-70, 5, 60.0f, 30.0f);
    
    UIView *fullView = [[UIView alloc] initWithFrame:fullRect];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRect];
    UILabel *distanceLabel = [[UILabel alloc] initWithFrame:distanceRect];
    
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [distanceLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [distanceLabel setBackgroundColor:[UIColor clearColor]];
    
    [titleLabel setTextColor:[UIColor blackColor]];
    [distanceLabel setTextColor:[UIColor blackColor]];
    
    [titleLabel setText:baseName];
    [distanceLabel setText: distance];
    
    [fullView addSubview:titleLabel];
    [fullView addSubview:distanceLabel];
    
    return fullView;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *cellTitle = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
    NSArray *titleParts = [cellTitle componentsSeparatedByString:@" - "];
    NSDictionary *locationDict = [dataDictionary valueForKey:[titleParts objectAtIndex:0]];
    NSDictionary *sublocationDict = [locationDict valueForKey:@"sublocations"];
    for (id key in sublocationDict)
    {
        NSDictionary *subloc = (NSDictionary *)key;
        if ([[subloc valueForKey:@"name"] isEqualToString:[titleParts objectAtIndex:1]])
        {
            MapViewController *controller = [[MapViewController alloc] init];
            [controller setLocationName: [titleParts objectAtIndex:0]];
            [controller setSublocation: subloc];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma mark - Location Manager Delegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
//    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [errorAlert show];
//    NSLog(@"Error: %@",error.description);
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *crnLoc = [locations lastObject];
    currentLocation = crnLoc;
    [self.tableView reloadData];

//    latitude.text = [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.latitude];
//    longitude.text = [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.longitude];
//    altitude.text = [NSString stringWithFormat:@"%.0f m",crnLoc.altitude];
//    speed.text = [NSString stringWithFormat:@"%.1f m/s", crnLoc.speed];
}
@end
