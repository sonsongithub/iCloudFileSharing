/*
 * iCloud File Sharing
 * FileIndexViewController.m
 *
 * Copyright (c) Yuichi YOSHIDA, 11/12/27.
 * All rights reserved.
 * 
 * BSD License
 *
 * Redistribution and use in source and binary forms, with or without modification, are 
 * permitted provided that the following conditions are met:
 * - Redistributions of source code must retain the above copyright notice, this list of
 *  conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this list
 *  of conditions and the following disclaimer in the documentation and/or other materia
 * ls provided with the distribution.
 * - Neither the name of the "Yuichi Yoshida" nor the names of its contributors may be u
 * sed to endorse or promote products derived from this software without specific prior 
 * written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY E
 * XPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES O
 * F MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SH
 * ALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENT
 * AL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROC
 * UREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS I
 * NTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRI
 * CT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF T
 * HE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "FileIndexViewController.h"

#import "FileInfo.h"
#import "FileCell.h"
#import "DetailViewController.h"

@implementation FileIndexViewController

@synthesize localFiles = _localFiles;
@synthesize ubicuitousFiles = _ubicuitousFiles;
@synthesize query = _query;

#pragma mark - IBAction

- (IBAction)reload:(id)sender {
	[self reloadLocalFiles];
	[self.query startQuery];
}

#pragma mark - Instance method

- (void)reloadLocalFiles {
	[self.localFiles removeAllObjects];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSArray *array = [[NSFileManager defaultManager] subpathsAtPath:documentsDirectory];
	for (NSString *subpath in array) {
		NSLog(@"%@", subpath);
		
		NSString *fullpath = [documentsDirectory stringByAppendingPathComponent:subpath];
		
		FileInfo *info = [[[FileInfo alloc] init] autorelease];
		info.URL = [NSURL fileURLWithPath:fullpath];
		
		[self.localFiles addObject:info];
	}
	[self.tableView reloadData];
}

- (void)updateQuery {
	
	[self.ubicuitousFiles removeAllObjects];
	for (int i = 0; i < self.query.resultCount; i++) {
		NSMetadataItem *item = [self.query resultAtIndex:i];
		NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
		NSLog(@"%@", url);
		
		FileInfo *info = [[[FileInfo alloc] init] autorelease];
		info.URL = url;
		info.metadataItem = item;
		[self.ubicuitousFiles addObject:info];
		
		
		NSNumber *downloadedKey = [info.metadataItem valueForAttribute:NSMetadataUbiquitousItemIsDownloadedKey];
		NSNumber *downloadingKey = [info.metadataItem valueForAttribute:NSMetadataUbiquitousItemIsDownloadingKey];
		
		if ([downloadedKey boolValue]) {
			NSLog(@"Already downloaded.");
		}
		else {
			if ([downloadingKey boolValue]) {
				NSLog(@"Still downloading.");
			}
			else {
				NSLog(@"Not yet.");
				NSError *error = nil;
				[[NSFileManager defaultManager] startDownloadingUbiquitousItemAtURL:info.URL error:&error];
				if (error)
					NSLog(@"Can't start downloading - %@", [error localizedDescription]);
				else {
					NSLog(@"Start downloading");
				}
			}
		}
	}
	[self reloadLocalFiles];
}

#pragma mark - NSNotification

- (void)queryDidUpdate:(NSNotification*)notification {
	NSLog(@"queryDidUpdate:");
	[self updateQuery];
	[self.tableView reloadData];
}

- (void)queryDidFinishGatheringForDocument:(NSNotification *)notification {
	NSLog(@"queryDidFinishGatheringForDocument:");
	[self.query stopQuery];
	[self.query disableUpdates];
	[self updateQuery];
	[self.query enableUpdates];
	[self.tableView reloadData];
}

#pragma mark - View lifecycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"DetailViewController"]) {
		if ([segue.destinationViewController isKindOfClass:[DetailViewController class]]) {
			DetailViewController *con = segue.destinationViewController;
			con.info =((FileCell*)sender).info;
		}
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];	
	self.localFiles = [NSMutableArray arrayWithCapacity:10];
	self.ubicuitousFiles = [NSMutableArray arrayWithCapacity:10];
	
	NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
	if (ubiq) {
		NSLog(@"Search a file from iCloud.");
		self.query = [[[NSMetadataQuery alloc] init] autorelease];
		[self.query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
		NSPredicate *pred = [NSPredicate predicateWithFormat: @"%K like '*'", NSMetadataItemFSNameKey];
		[self.query setPredicate:pred];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDidFinishGatheringForDocument:) name:NSMetadataQueryDidFinishGatheringNotification object:self.query];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(queryDidUpdate:)
													 name:NSMetadataQueryDidUpdateNotification
												   object:self.query];
		[self.query startQuery];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIApplicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)UIApplicationDidEnterBackgroundNotification:(NSNotification*)notification {
	[self.query disableUpdates];
	[self.query stopQuery];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self reloadLocalFiles];
	[self.query startQuery];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	[self.query stopQuery];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSMutableArray* fileList = nil;
		
		if (indexPath.section == 0) {
			fileList = self.localFiles; 
		}   
		else {        
			fileList = self.ubicuitousFiles; 
		}
		
		FileInfo* info = [fileList objectAtIndex:indexPath.row];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
			NSFileCoordinator* fileCoordinator = [[[NSFileCoordinator alloc] initWithFilePresenter:nil] autorelease];
			[fileCoordinator coordinateWritingItemAtURL:info.URL
												options:NSFileCoordinatorWritingForDeleting
												  error:nil
											  byAccessor:^(NSURL* writingURL) {
												  NSError *error = nil;
												  NSFileManager* fileManager = [[[NSFileManager alloc] init] autorelease];
												  [fileManager removeItemAtURL:writingURL error:&error];
												  if (error)
													  NSLog(@"%@", [error localizedDescription]);
											  }];
		});
		
		[fileList removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
		return [self.localFiles count];
	if (section == 1)
		return [self.ubicuitousFiles count];
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0)
		return NSLocalizedString(@"Local", nil);
	if (section == 1)
		return NSLocalizedString(@"iCloud", nil);
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FileCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	FileInfo *info = nil;
	
	if (indexPath.section == 0) {
		info = [self.localFiles objectAtIndex:indexPath.row];
	}
	else {
		info = [self.ubicuitousFiles objectAtIndex:indexPath.row];
	}
    
    // Configure the cell...
	if ([cell isKindOfClass:[FileCell class]]) {
		FileCell *fileCell = (FileCell*)cell;
		fileCell.info = info;
		
		cell.textLabel.text = info.title;
		
		if (info.metadataItem) {
			NSNumber *downloadedKey = [info.metadataItem valueForAttribute:NSMetadataUbiquitousItemIsDownloadedKey];
			NSNumber *downloadingKey = [info.metadataItem valueForAttribute:NSMetadataUbiquitousItemIsDownloadingKey];
			
			if ([downloadedKey boolValue]) {
				NSLog(@"Already downloaded.");
				fileCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				fileCell.indicator.hidden = YES;
				[fileCell.indicator stopAnimating];
			}
			else {
				if ([downloadingKey boolValue]) {
					fileCell.accessoryType = UITableViewCellAccessoryNone;
					fileCell.indicator.hidden = NO;
					[fileCell.indicator startAnimating];
				}
				else {
					fileCell.accessoryType = UITableViewCellAccessoryNone;
					fileCell.indicator.hidden = YES;
					[fileCell.indicator startAnimating];
				}
			}
		}
		else {
			fileCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			fileCell.indicator.hidden = YES;
		}
	}
    
    return cell;
}

#pragma mark - dealloc

- (void)dealloc {
	self.query = nil;
    self.localFiles = nil;
	self.ubicuitousFiles = nil;
    [super dealloc];
}

@end
