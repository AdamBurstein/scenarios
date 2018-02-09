//
//  InstructionViewController.h
//  Scenarios
//
//  Created by Adam Burstein on 2/6/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstructionViewController : UITableViewController

@property (nonatomic, strong) NSArray *instructionsArray;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) UITableView *tview;
@property (nonatomic, strong) NSMutableDictionary *checkBoxes;

@end

