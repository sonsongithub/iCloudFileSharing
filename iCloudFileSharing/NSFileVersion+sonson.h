//
//  NSFileVersion+sonson.h
//  iCloudFileSharing
//
//  Created by Yoshida Yuichi on 12/01/09.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileVersion(sonson)

+ (void)dumpAllVersionsAtURL:(NSURL*)URL;
- (void)dump;

@end
