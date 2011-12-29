//
//  FileCell.h
//  iCloudFileSharing
//
//  Created by Yoshida Yuichi on 11/12/28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FileInfo;

@interface FileCell : UITableViewCell

@property (strong, nonatomic) FileInfo *info;

@end
