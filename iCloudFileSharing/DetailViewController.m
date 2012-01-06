/*
 * iCloud File Sharing
 * DetailViewController.m
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

#import "DetailViewController.h"

#import "FileInfo.h"

@implementation DetailViewController

@synthesize textView = _textView;
@synthesize info = _info;
@synthesize moveButton = _moveButton;

- (void)saveFileOnLocalStorage {
	NSData *data = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
	[data writeToFile:self.info.path atomically:YES];
}

- (void)saveFileOnICloud {
	NSError *error = nil;
	NSFileCoordinator *coordinator = [[[NSFileCoordinator alloc] initWithFilePresenter:nil] autorelease];
	[coordinator coordinateWritingItemAtURL:self.info.ubiquitousURL options:NSFileCoordinatorWritingForReplacing
									  error:&error
								 byAccessor:^(NSURL *writingURL) {
									 NSError *error = nil;
									 NSData *data = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
									 [data writeToURL:writingURL options:0 error:&error];
									 
									 if (error)
										 NSLog(@"Writing Error = %@", [error localizedDescription]);
									 else
										 NSLog(@"Writing OK = %@", writingURL); 
									 
									 [self.navigationController popViewControllerAnimated:YES];
	}];
}

- (IBAction)save:(id)sender {
	BOOL isICloud =(self.info.path == nil);
	
	if (isICloud)
		[self saveFileOnICloud];
	else
		[self saveFileOnLocalStorage];
}

- (IBAction)move:(id)sender {
	NSLog(@"move");
	
	NSURL *localURL = self.info.fileURL;
	
	NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
	NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:[self.info.path lastPathComponent]];
	
	NSError *error = nil;
	if ([[NSFileManager defaultManager] setUbiquitous:YES 
											itemAtURL:localURL
									   destinationURL:destinationUbiquitousURL
												error:&error]) {
		NSLog(@"Copy to iCloud storage");
	}
	else {
		NSLog(@"%@", [error localizedDescription]);
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
	}
	if (buttonIndex == 1) {
		NSString *title = alertView.message;
		NSURL *URL = [NSURL URLWithString:title];
		[[UIApplication sharedApplication] openURL:URL];
	}
}

- (IBAction)share:(id)sender {
	NSDate *expirationDate = nil;
	NSError *error = nil;
	NSURL *sharedURL = [[NSFileManager defaultManager] URLForPublishingUbiquitousItemAtURL:self.info.ubiquitousURL
																			expirationDate:&expirationDate
																					 error:&error];
	NSLog(@"%@", sharedURL);
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Share", nil)
														message:[sharedURL absoluteString]
													   delegate:self
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:@"Open Safari", nil];
	[alertView show];
	[alertView autorelease];
}

- (void)dealloc {
	self.info = nil;
    self.textView = nil;
	self.moveButton = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSFileManager defaultManager] setDelegate:nil];	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (self.info.path) {
		self.moveButton.title = NSLocalizedString(@"Move to iCloud", nil);
	}
	if (self.info.ubiquitousURL) {
		self.moveButton.title = NSLocalizedString(@"Move to local", nil);
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	self.title = self.info.title;
	if (self.info.path) {
		self.textView.text = [NSString stringWithContentsOfFile:self.info.path encoding:NSUTF8StringEncoding error:nil];
	}
	if (self.info.ubiquitousURL) {
		NSError *error = nil;
		NSFileCoordinator *coordinator = [[[NSFileCoordinator alloc] initWithFilePresenter:nil] autorelease];
		
		[coordinator coordinateReadingItemAtURL:self.info.ubiquitousURL 
										options:NSFileCoordinatorReadingWithoutChanges
										  error:&error
									 byAccessor:^(NSURL *readingURL) {
										 NSMutableString *string = [NSMutableString string];
										 NSArray *unresolvedVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:readingURL];
										 for (NSFileVersion *version in unresolvedVersions) {
											 NSError *error = nil;
											 version.resolved = YES;
											 NSLog(@"%@", version);
											 NSString *otherVersionString = [NSString stringWithContentsOfURL:[version URL] 
																									 encoding:NSUTF8StringEncoding 
																										error:&error];
											 NSLog(@"%@", otherVersionString);
											 [string appendString:otherVersionString];
										 }
										 NSError *error = nil;
										 [NSFileVersion removeOtherVersionsOfItemAtURL:readingURL error:&error];
										 if (error) {
											 NSLog(@"Removing other versions Error = %@", [error localizedDescription]);
										 }
										 else {
											 NSLog(@"Removing other versions OK = %@", readingURL); 
										 }
										 [string appendString:[NSString stringWithContentsOfURL:self.info.ubiquitousURL encoding:NSUTF8StringEncoding error:nil]];
										 self.textView.text = string;
									 }];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
