//
//  ContactViewController.m
//  Scenarios
//
//  Created by Adam Burstein on 6/22/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#import "ContactViewController.h"

@interface ContactViewController ()

@end

@implementation ContactViewController

@synthesize contactDictionary;
NSMutableArray *sortedKeys2;

- (void)viewDidLoad {
    [super viewDidLoad];
    sortedKeys2 = [[[contactDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    [sortedKeys2 removeObject:@"name"];
    
    UIImage *bgImage = [UIImage imageNamed:@"WHMO AppLaunch-06 BLUE 3x.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bgImage];
    imageView.alpha = 0.15;
    [self.tableView setBackgroundView:imageView];

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger adam = [sortedKeys2 count];
    return [sortedKeys2 count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"MyIdentifier"];
    }

    NSDictionary *dict = [contactDictionary valueForKey:[sortedKeys2 objectAtIndex:indexPath.row]];
    [[cell textLabel] setText:[dict valueForKey:@"name"]];
    UIFont *font = [UIFont systemFontOfSize:18];
    cell.layoutMargins = UIEdgeInsetsZero;
    [[cell textLabel] setNumberOfLines:10];
    [[cell textLabel] setFont:font];
    [cell setBackgroundColor:[UIColor clearColor]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *dict = [contactDictionary valueForKey:[sortedKeys2 objectAtIndex:indexPath.row]];
    NSString *phoneNumber = [dict valueForKey:@"number"];
    NSString *telephoneNumber = [NSString stringWithFormat:@"telprompt:%@", phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telephoneNumber] options:@{} completionHandler:nil];

}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
