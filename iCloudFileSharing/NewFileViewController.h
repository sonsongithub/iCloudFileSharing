//
//  NewFileViewController.h
//  iCloudFileSharing
//
//  Created by Yoshida Yuichi on 11/12/28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewFileViewController : UIViewController

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *fileNameField;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end
