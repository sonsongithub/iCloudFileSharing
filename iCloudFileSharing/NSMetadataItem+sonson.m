//
//  NSMetadataItem+sonson.m
//  iCloudFileSharing
//
//  Created by Yoshida Yuichi on 12/01/08.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSMetadataItem+sonson.h"

@implementation NSMetadataItem(sonson)

- (void)dump {
	NSLog(@"---------------------------------");
	NSLog(@" File name		= %@", (NSString*)[self valueForAttribute:NSMetadataItemFSNameKey]);
	NSLog(@" Dispaly name	= %@", (NSString*)[self valueForAttribute:NSMetadataItemDisplayNameKey]);
	NSLog(@" URL			= %@", (NSString*)[self valueForAttribute:NSMetadataItemURLKey]);
	NSLog(@" Path			= %@", (NSString*)[self valueForAttribute:NSMetadataItemPathKey]);
	NSLog(@" Size			= %d", [(NSNumber*)[self valueForAttribute:NSMetadataItemFSSizeKey] intValue]);
	NSLog(@" Creation date	= %@", (NSDate*)[self valueForAttribute:NSMetadataItemFSCreationDateKey]);
	NSLog(@" Changed date	= %@", (NSDate*)[self valueForAttribute:NSMetadataItemFSContentChangeDateKey]);
	
	// iCloud
	if ([(NSNumber*)[self valueForAttribute:NSMetadataItemIsUbiquitousKey] boolValue])
		NSLog(@" This item is on iClound.");
	
	// download
	if ([(NSNumber*)[self valueForAttribute:NSMetadataUbiquitousItemHasUnresolvedConflictsKey] boolValue])
		NSLog(@" This item has unresolved conflicts.");
	
	if ([(NSNumber*)[self valueForAttribute:NSMetadataUbiquitousItemIsDownloadedKey] boolValue])
		NSLog(@" This item aleady has been downloaded.");
	
	if ([(NSNumber*)[self valueForAttribute:NSMetadataUbiquitousItemIsDownloadingKey] boolValue])
		 NSLog(@" This item is downloading. -- %d%%", [(NSNumber*)[self valueForAttribute:NSMetadataUbiquitousItemPercentDownloadedKey] intValue]);
	
	// upload
	if ([(NSNumber*)[self valueForAttribute:NSMetadataUbiquitousItemIsUploadedKey] boolValue])
		NSLog(@" This item aleady has been uploaded.");
	
	if ([(NSNumber*)[self valueForAttribute:NSMetadataUbiquitousItemIsUploadingKey] boolValue])
		NSLog(@" This item is uploading. -- %d%%", [(NSNumber*)[self valueForAttribute:NSMetadataUbiquitousItemPercentUploadedKey] intValue]);
}

@end
