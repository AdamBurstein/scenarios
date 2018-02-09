//
//  FileViewController.h
//  Scenarios
//
//  Created by Adam Burstein on 2/7/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PDFKit/PDFKit.h>

@interface FileViewController : UIPageViewController

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *fileName;

@end
