//
//  FileInfo.h
//  iCloudFileSharing
//
//  Created by Yoshida Yuichi on 11/12/28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileInfo : NSObject

@property (strong, nonatomic) NSString *path;
@property (readonly, nonatomic) NSString *title;
@property (strong, nonatomic) NSURL *fileURL;
@property (strong, nonatomic) NSURL *ubiquitousURL;
@property (strong, nonatomic) NSMetadataItem *metadataItem;

@end
