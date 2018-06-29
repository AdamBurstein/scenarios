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

NSMutableArray *locationsArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *bgImage = [UIImage imageNamed:@"WHMO AppLaunch-06 BLUE 3x.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bgImage];
    imageView.alpha = 0.15;
    [self.tableView setBackgroundView:imageView];

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
    
    [[cell textLabel] setText:[locationsArray objectAtIndex:indexPath.row]];
    [cell setBackgroundColor:[UIColor clearColor]];

    return cell;
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
@end
