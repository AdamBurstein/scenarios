//
//  SettingsViewController.h
//  Scenarios
//
//  Created by Adam Burstein on 2/8/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *appVersionLabel;
@property (nonatomic, strong) IBOutlet UILabel *xmlVersionLabel;
@property (nonatomic, strong) IBOutlet UITextField *remoteURLField;
@property (nonatomic, strong) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) IBOutlet UIButton *hideKeyboardButton;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;

-(IBAction)hideKeyboard:(id)sender;
-(IBAction)clickSaveOrCancel:(id)sender;


@end
