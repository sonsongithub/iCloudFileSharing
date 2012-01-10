//
//  NSFileVersion+sonson.m
//  iCloudFileSharing
//
//  Created by Yoshida Yuichi on 12/01/09.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSFileVersion+sonson.h"

@implementation NSFileVersion(sonson)

+ (void)dumpAllVersionsAtURL:(NSURL*)URL {
	NSFileVersion *currentVersion = [NSFileVersion currentVersionOfItemAtURL:URL];
	[currentVersion dump];
	
	NSArray *unresolvedVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:URL];
	for (NSFileVersion *version in unresolvedVersions) {
		[version dump];
	}
}

- (void)dump {
	NSLog(@"---------------------------------");
	NSLog(@" URL								= %@", [self URL]);
	NSLog(@" Localized name						= %@", [self localizedName]);
	NSLog(@" Localized name(Saving computer)	= %@", [self localizedNameOfSavingComputer]);
	NSLog(@" Modification date					= %@", [self modificationDate]);
	NSLog(@" Persistent identifier				= %@", [self persistentIdentifier]);
	if (self.conflict)
		NSLog(@" Conflicted");
	if (self.resolved)
		NSLog(@" Not resolved");
}

@end
