//
//  QuestionViewController.m
//  Scenarios
//
//  Created by Adam Burstein on 2/2/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#import "QuestionViewController.h"
#import "InstructionViewController.h"
#import "FileViewController.h"

@interface QuestionViewController ()

@end

@implementation QuestionViewController
NSMutableDictionary *checkBoxes;
@synthesize dataDictionary;

NSArray *questions;
NSArray *links;
UITableView *tView;

#pragma mark -

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = [dataDictionary valueForKey:@"name"];
    checkBoxes = [[NSMutableDictionary alloc] init];
    [self readFromFile];
    questions = [dataDictionary valueForKey:@"questions"];
    links = [dataDictionary valueForKey:@"links"];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(reset)];
    self.navigationItem.rightBarButtonItem = resetButton;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    tView = ((UITableView *)self.view);
    tView.rowHeight = UITableViewAutomaticDimension;
    tView.estimatedRowHeight = 44;
    tView.layoutMargins = UIEdgeInsetsZero;
    tView.separatorInset = UIEdgeInsetsZero;
    
}

-(NSString *) readFromFile
{
    NSString *filepath = [[NSString alloc] init];
    NSError *error;
    filepath = [self.GetDocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_set.txt", [dataDictionary valueForKey:@"name"]]];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger i = 0;
    if ([questions count] > 0)
        ++i;
    if ([links count] > 0)
        ++i;
    
    return i;


}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numSections = 0;
    BOOL hasQuestions = NO;
    BOOL hasLinks = NO;
    
    if ([questions count] > 0)
    {
        ++numSections;
        hasQuestions = YES;
    }
    if ([links count] > 0)
    {
        ++numSections;
        hasLinks = YES;
    }
    
    if (numSections == 1)
    {
        if (hasLinks)
            return [links count];
        return [questions count];
    }
    else
    {
        if (section == 0)
            return [questions count];
        return [links count];
    }
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

- (UIImage *)getCheckboxImage:(long) indexPath
{
    UIImage *theImage;
    NSString *theString = @"No";
    NSString *theRow = [NSString stringWithFormat:@"%ld", indexPath];
    @try
    {
        theString = [checkBoxes valueForKey:[NSString stringWithFormat:@"%ld", indexPath]];
        if (theString == nil)
        {
            theString = @"No";
            theImage = [UIImage imageNamed:@"Unchecked.png"];
        }
        if ([theString isEqualToString:@"Yes"])
            theImage = [UIImage imageNamed:@"Checked.png"];
        else
            theImage = [UIImage imageNamed:@"Unchecked.png"];
    }
    @catch (NSException *exception)
    {
        theString = @"No";
        theImage = [UIImage imageNamed:@"Unchecked.png"];
    }
    @finally
    {

        [checkBoxes setValue:theString forKey:theRow];
        return theImage;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    }

    int numSections = 0;
    BOOL hasQuestions = NO;
    BOOL hasLinks = NO;
    
    if ([questions count] > 0)
    {
        ++numSections;
        hasQuestions = YES;
    }
    if ([links count] > 0)
    {
        ++numSections;
        hasLinks = YES;
    }
    UIFont *font = [UIFont systemFontOfSize:14];
    cell.layoutMargins = UIEdgeInsetsZero;
    [[cell textLabel] setNumberOfLines:4];
    [[cell textLabel] setFont:font];
    [[cell textLabel] setText:[self getCellText:indexPath]];
    [[cell imageView] setImage:[self getCellImage:indexPath]];
     [cell setAccessoryType:[self getAccessoryType:indexPath]];
    return cell;
}

-(BOOL) hasInstructions:(NSIndexPath *)indexPath
{
    BOOL returnValue = NO;
    
    NSDictionary *dict = [questions objectAtIndex:indexPath.row];
    NSArray *instructions = [dict valueForKey:@"instructions"];
    if (instructions != nil)
        returnValue = YES;
    
    return returnValue;
}

-(UITableViewCellAccessoryType)getAccessoryType:(NSIndexPath *)indexPath
{
    int numSections = 0;
    BOOL hasQuestions = NO;
    BOOL hasLinks = NO;
    
    if ([questions count] > 0)
    {
        ++numSections;
        hasQuestions = YES;
    }
    if ([links count] > 0)
    {
        ++numSections;
        hasLinks = YES;
    }

    if (!hasQuestions)
        return UITableViewCellAccessoryNone;
    if (indexPath.section == 0)
    {
        if ([self hasInstructions:indexPath])
        {
            return UITableViewCellAccessoryDisclosureIndicator;
        }
        NSString *currentValue = [self getCheckboxValue:indexPath.row];
        if ([currentValue isEqualToString:@"Yes"])
            return UITableViewCellAccessoryCheckmark;
    }
    return UITableViewCellAccessoryNone;
}

-(UIImage *)getCellImage:(NSIndexPath *)indexPath
{
    NSInteger numSections = [self.tableView numberOfSections];
    UIImage *returnValue = nil;
    
    if (numSections == 1)
    {
        if ([questions count] == 0)
            return nil;
        NSDictionary *dict = [links objectAtIndex:indexPath.row];
        if ([dict objectForKey:@"fileurl"] != nil)
        {
            returnValue = [UIImage imageNamed:@"fileIcon.png"];
        }
        else if ([dict objectForKey:@"url"] != nil)
        {
            returnValue = [UIImage imageNamed:@"linkIcon.png"];
        }
    }
    else if (indexPath.section == 1)
    {
        NSDictionary *dict = [links objectAtIndex:indexPath.row];
        if ([dict objectForKey:@"fileurl"] != nil)
        {
            returnValue = [UIImage imageNamed:@"fileIcon.png"];
        }
        else if ([dict objectForKey:@"url"] != nil)
        {
            returnValue = [UIImage imageNamed:@"linkIcon.png"];
        }
    }
    
    return returnValue;
}

-(NSString *)getCellText:(NSIndexPath *)indexPath
{
    int numSections = 0;
    BOOL hasQuestions = NO;
    BOOL hasLinks = NO;
    
    if ([questions count] > 0)
    {
        ++numSections;
        hasQuestions = YES;
    }
    if ([links count] > 0)
    {
        ++numSections;
        hasLinks = YES;
    }

    NSString *returnValue = @"";
    if (numSections == 1)
    {
        NSInteger row = indexPath.row;
        if (hasQuestions)
        {
            NSDictionary *dict = [questions objectAtIndex:row];
            returnValue = [dict valueForKey:@"text"];
        }
        else
        {
            NSDictionary *dict = [links objectAtIndex:row];
            if ([dict objectForKey:@"linktext"] != nil)
            {
                returnValue = [dict valueForKey:@"linktext"];
            }
            else if ([dict objectForKey:@"fileurl"] != nil)
            {
                returnValue = [dict valueForKey:@"title"];
            }
        }
    }
    else
    {
        NSInteger row = indexPath.row;
        if (indexPath.section == 0)
        {
            NSDictionary *dict = [questions objectAtIndex:row];
            returnValue = [dict valueForKey:@"text"];
        }
        else
        {
            NSDictionary *dict = [links objectAtIndex:row];
            if ([dict objectForKey:@"linktext"] != nil)
            {
                returnValue = [dict valueForKey:@"linktext"];
            }
            else if ([dict objectForKey:@"fileurl"] != nil)
            {
                returnValue = [dict valueForKey:@"title"];
            }
        }
    }
    
    return returnValue;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 30;
    NSString *cellText = [self getCellText:indexPath];

    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize constraintSize = CGSizeMake(200, CGFLOAT_MAX);
    
    CGRect textRect = [cellText boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    CGSize size = textRect.size;
    cellHeight += size.height;
    return cellHeight;
}
 */

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([self.tableView numberOfSections] == 1)
    {
        if ([questions count] > 0)
        {
            if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
            {
                InstructionViewController *controller = [[InstructionViewController alloc] init];
                controller.fullName = cell.textLabel.text;
                controller.name = [NSString stringWithFormat:@"%@~%@", [dataDictionary valueForKey:@"name"], cell.textLabel.text];
                controller.instructionsArray = [[questions objectAtIndex:indexPath.row] valueForKey:@"instructions"];
                [self.navigationController pushViewController:controller animated:YES];
            }
            else
            {
                NSString *currentValue = [self getCheckboxValue:indexPath.row];
                if ([currentValue isEqualToString:@"Yes"])
                    [checkBoxes setValue:@"No" forKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
                else
                    [checkBoxes setValue:@"Yes" forKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
            }
        }
        else
        {
            NSDictionary *dict = [links objectAtIndex:indexPath.row];
            if ([dict objectForKey:@"linkurl"] != nil)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[dict valueForKey:@"url"]] options:@{} completionHandler:nil];
            }
            else
            {
                FileViewController *controller = [[FileViewController alloc] init];
                [controller setFileName:[dict valueForKey:@"title"]];
                [controller setFilePath:[dict valueForKey:@"fileurl"]];
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
    }
    else if (([self.tableView numberOfSections] == 2) && (indexPath.section == 0))
    {
        if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
        {
            InstructionViewController *controller = [[InstructionViewController alloc] init];
            controller.fullName = [dataDictionary valueForKey:@"name"];
            controller.name = [NSString stringWithFormat:@"%@~%@", [dataDictionary valueForKey:@"name"], cell.textLabel.text];
            controller.instructionsArray = [[questions objectAtIndex:indexPath.row] valueForKey:@"instructions"];
            [self.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            NSString *currentValue = [self getCheckboxValue:indexPath.row];
            if ([currentValue isEqualToString:@"Yes"])
                [checkBoxes setValue:@"No" forKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
            else
                [checkBoxes setValue:@"Yes" forKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
        }
    }
    else if (([self.tableView numberOfSections] == 2) && (indexPath.section == 1))
    {
        NSDictionary *dict = [links objectAtIndex:indexPath.row];
        if ([dict objectForKey:@"linkurl"] != nil)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[dict valueForKey:@"url"]] options:@{} completionHandler:nil];
        }
        else
        {
            FileViewController *controller = [[FileViewController alloc] init];
            [controller setFileName:[dict valueForKey:@"title"]];
            [controller setFilePath:[dict valueForKey:@"fileurl"]];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self WriteToStringFile];
    [self.tableView reloadData];
}

-(void) reset
{
    NSString *filepath = [[NSString alloc] init];
    NSError *err;
    BOOL foundOne = NO;
    
    filepath = self.GetDocumentDirectory;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:filepath error:&err];
    for (int i = 0; i < [files count]; ++i)
    {
        NSString *filename = [files objectAtIndex:i];
        if (([filename containsString:[NSString stringWithFormat:@"%@_set.txt", [dataDictionary valueForKey:@"name"]]]) || ([filename containsString:[NSString stringWithFormat:@"%@~", [dataDictionary valueForKey:@"name"]]]))
        {
            foundOne = YES;
            NSString *thisFile = [filepath stringByAppendingPathComponent:filename];
            //NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL success = [fileManager removeItemAtPath:thisFile error:&err];
            if (success)
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Complete" message:@"You have successfully reset this scenario" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"Thanks" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Errpr" message:@"There was an error resetting your scenarios." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        }
        
    }
    if (!foundOne)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Complete" message:@"You have successfully reset this scenario" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Thanks" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [checkBoxes removeAllObjects];
    [self readFromFile];
    [tView reloadData];
}


-(void)WriteToStringFile
{
    NSString *filepath = [[NSString alloc] init];
    NSError *err;
    
    filepath = [self.GetDocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_set.txt", [dataDictionary valueForKey:@"name"]]];

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
//    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *homeDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    return homeDir;
}

@end
