//
//  InstructionViewController.m
//  Scenarios
//
//  Created by Adam Burstein on 2/6/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#import "InstructionViewController.h"

@interface InstructionViewController ()

@end

@implementation InstructionViewController

@synthesize name;
@synthesize directoryName;
@synthesize fullName;
@synthesize instructionsArray;
@synthesize tview;
@synthesize checkBoxes;

NSMutableCharacterSet *nonAlphaNums;

#pragma mark -

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    nonAlphaNums = [[NSMutableCharacterSet alloc] init];
    [nonAlphaNums formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
    [nonAlphaNums removeCharactersInString:@" "];
    [nonAlphaNums removeCharactersInString:@"_"];
    [nonAlphaNums removeCharactersInString:@"-"];
    NSString *newString = [[name componentsSeparatedByCharactersInSet:nonAlphaNums] componentsJoinedByString:@""];
    newString = [newString stringByAppendingFormat:@"~%@", directoryName];
    [self setName:newString];

    self.navigationItem.title = @"Details";
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    UIImage *bgImage = [UIImage imageNamed:@"WHMO AppLaunch-06 BLUE 3x.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bgImage];
    imageView.alpha = 0.15;
    [self.tableView setBackgroundView:imageView];

    checkBoxes = [[NSMutableDictionary alloc] init];
    [self readFromFile];

    tview = ((UITableView *)self.view);
    tview.rowHeight = UITableViewAutomaticDimension;
    tview.estimatedRowHeight = 44;
    tview.layoutMargins = UIEdgeInsetsZero;
    tview.separatorInset = UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [instructionsArray count];
}

-(UITableViewCellAccessoryType)getAccessoryType:(NSIndexPath *)indexPath
{
    NSString *currentValue = [self getCheckboxValue:indexPath.row];
    if ([currentValue isEqualToString:@"Yes"])
        return UITableViewCellAccessoryCheckmark;
    return UITableViewCellAccessoryNone;
}

- (NSString *)getCheckboxValue:(long) indexPath
{
    NSString *isChecked = @"No";
    @try
    {
        isChecked = [checkBoxes valueForKey:[NSString stringWithFormat:@"%ld", indexPath]];
    }
    @catch (NSException *exception)
    {
        
    }
    @finally
    {
        return isChecked;
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:16]];
    NSString *headerText = fullName;
    [label setText:headerText];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor clearColor]];
    
    return view;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *currentValue = [self getCheckboxValue:indexPath.row];
    if ([currentValue isEqualToString:@"Yes"])
        [checkBoxes setValue:@"No" forKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
    else
        [checkBoxes setValue:@"Yes" forKey:[NSString stringWithFormat:@"%ld", indexPath.row]];

    [self WriteToStringFile];
    [tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    }
    
    UIFont *font = [UIFont systemFontOfSize:18];
    cell.layoutMargins = UIEdgeInsetsZero;
    [[cell textLabel] setNumberOfLines:10];
    [[cell textLabel] setFont:font];
    [[cell textLabel] setText:[instructionsArray objectAtIndex:indexPath.row]];
    [cell setAccessoryType:[self getAccessoryType:indexPath]];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

-(NSString *)formatName:(NSString *)name
{
    NSString *returnValue = [NSString stringWithString:name];
    returnValue = [returnValue stringByReplacingOccurrencesOfString:@" " withString:@""];
    returnValue = [returnValue stringByReplacingOccurrencesOfString:@"/" withString:@""];
    returnValue = [returnValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
    returnValue = [returnValue stringByReplacingOccurrencesOfString:@"_" withString:@""];
    return returnValue;
}

-(void)WriteToStringFile
{
    NSString *filepath = [[NSString alloc] init];
    NSError *err;
    
    filepath = [self.GetDocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_set.txt", [self formatName:name]]];
    
    NSString *textToWrite = [[NSString alloc] init];
    for (id key in checkBoxes)
    {
        textToWrite = [textToWrite stringByAppendingFormat:@"%@=%@\n", key, [checkBoxes valueForKey:key]];
    }
    
    BOOL ok = [textToWrite writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:&err];
    
    if (!ok) {
        NSLog(@"Error writing file at %@\n%@",
              filepath, [err localizedFailureReason]);
    }
    
}

-(NSString *)GetDocumentDirectory{
    NSString *homeDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    return homeDir;
}

-(NSString *) readFromFile
{
    NSString *filepath = [[NSString alloc] init];
    NSError *error;
    filepath = [self.GetDocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_set.txt", [self formatName:name]]];
    NSString *txtInFile = [[NSString alloc] initWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    NSArray *array = [txtInFile componentsSeparatedByString:@"\n"];
    for (int i = 0; i < [array count]; ++i)
    {
        NSString *tmp = [array objectAtIndex:i];
        if ([tmp containsString:@"="])
        {
            NSArray *keyVal = [tmp componentsSeparatedByString:@"="];
            [checkBoxes setValue:[keyVal objectAtIndex:1] forKey:[keyVal objectAtIndex:0]];
        }
    }
    
    return txtInFile;
}
@end
