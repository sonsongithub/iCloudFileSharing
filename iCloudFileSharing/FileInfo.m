//
//  FileInfo.m
//  iCloudFileSharing
//
//  Created by Yoshida Yuichi on 11/12/28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FileInfo.h"

@implementation FileInfo

@synthesize fileURL = _fileURL;
@synthesize path = _path;
@synthesize ubiquitousURL = _ubiquitousURL;
@synthesize metadataItem = _metadataItem;

- (NSString*)title {
	if (self.ubiquitousURL)
		return [self.ubiquitousURL lastPathComponent];
	if (self.path)
		return [self.path lastPathComponent];
	if (self.fileURL)
		return [self.fileURL lastPathComponent];
	return nil;
}

- (void)dealloc {
	self.metadataItem = nil;
	self.ubiquitousURL = nil;
    self.fileURL = nil;
	self.path = nil;
    [super dealloc];
}

@end
