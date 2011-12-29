//
//  DetailViewController.h
//  iCloudFileSharing
//
//  Created by Yoshida Yuichi on 11/12/28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FileInfo;

@interface DetailViewController : UIViewController

- (IBAction)move:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)remove:(id)sender;

@property (strong, nonatomic) FileInfo *info;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end
