//
//  FileIndexViewController.h
//  iCloudFileSharing
//
//  Created by Yoshida Yuichi on 11/12/28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileIndexViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *localFiles;
@property (strong, nonatomic) NSMutableArray *ubicuitousFiles;
@property (strong, nonatomic) NSMetadataQuery *query;

@end
