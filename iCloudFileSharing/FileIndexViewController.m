//
//  FileIndexViewController.m
//  iCloudFileSharing
//
//  Created by Yoshida Yuichi on 11/12/28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FileIndexViewController.h"

#import "FileInfo.h"
#import "FileCell.h"
#import "DetailViewController.h"

@implementation FileIndexViewController

@synthesize localFiles = _localFiles;
@synthesize ubicuitousFiles = _ubicuitousFiles;
@synthesize query = _query;

- (void)dealloc {
	self.query = nil;
    self.localFiles = nil;
	self.ubicuitousFiles = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)reloadLocalFiles {
	[self.localFiles removeAllObjects];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSArray *array = [[NSFileManager defaultManager] subpathsAtPath:documentsDirectory];
	for (NSString *subpath in array) {
		NSLog(@"%@", subpath);
		
		NSString *fullpath = [documentsDirectory stringByAppendingPathComponent:subpath];
		
		FileInfo *info = [[[FileInfo alloc] init] autorelease];
		info.path = fullpath;
		info.fileURL = [NSURL fileURLWithPath:fullpath];
		
		[self.localFiles addObject:info];
	}
	[self.tableView reloadData];
}

#pragma mark - View lifecycle

- (void)queryDidFinishGatheringForDocument:(NSNotification *)notification {
	NSLog(@"queryDidFinishGatheringForDocument:");
	[self.query stopQuery];
	
	[self.ubicuitousFiles removeAllObjects];
	for (int i = 0; i < self.query.resultCount; i++) {
		NSMetadataItem *item = [self.query resultAtIndex:i];
		NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
		NSLog(@"%@", url);
		
		FileInfo *info = [[[FileInfo alloc] init] autorelease];
		info.ubiquitousURL = url;
		[self.ubicuitousFiles addObject:info];
	}
	[self.tableView reloadData];
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
		[self.query startQuery];
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
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
		
		NSURL *URL = nil;
		
		if (info.fileURL)
			URL = info.fileURL;
		else
			URL = info.ubiquitousURL;
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
			NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
			[fileCoordinator coordinateWritingItemAtURL:URL
												options:NSFileCoordinatorWritingForDeleting
												  error:nil
											  byAccessor:^(NSURL* writingURL) {
												  NSError *error = nil;
												  NSFileManager* fileManager = [[NSFileManager alloc] init];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"DetailViewController"]) {
		if ([segue.destinationViewController isKindOfClass:[DetailViewController class]]) {
			DetailViewController *con = segue.destinationViewController;
			con.info =((FileCell*)sender).info;
		}
	}
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
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
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
		cell.textLabel.text = fileCell.info.title;
	}
    
    return cell;
}

@end
