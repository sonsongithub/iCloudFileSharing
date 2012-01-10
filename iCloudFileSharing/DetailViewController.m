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

#import "NSFileVersion+sonson.h"

@implementation DetailViewController

@synthesize textView = _textView;
@synthesize info = _info;
@synthesize moveButton = _moveButton;
@synthesize shareButton = _shareButton;

#pragma mark - Instance method

- (void)updateTextViewRectWithKeyboardRect:(CGRect)keyboardRectInWindow {
	CGRect textview_frame = self.textView.frame;
	
	CGPoint keyboardLeftTop = [self.view convertPoint:keyboardRectInWindow.origin fromView:[[UIApplication sharedApplication] keyWindow]];
	
	float newTextViewHeight = keyboardLeftTop.y - textview_frame.origin.y;
	
	textview_frame.size.height = newTextViewHeight;
	
	self.textView.frame = textview_frame;
}

#pragma mark - Notifications

- (void)keyboardDidShow:(NSNotification*)notification {
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	[self updateTextViewRectWithKeyboardRect:keyboardRect];
}

- (void)keyboardWillHide:(NSNotification*)notification {
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	[self updateTextViewRectWithKeyboardRect:keyboardRect];
}

- (void)keyboardWillChange:(NSNotification*)notification {
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	[self updateTextViewRectWithKeyboardRect:keyboardRect];
}

#pragma mark - IBAction

- (IBAction)save:(id)sender {
	NSError *error = nil;
	NSFileCoordinator *coordinator = [[[NSFileCoordinator alloc] initWithFilePresenter:nil] autorelease];
	[coordinator coordinateWritingItemAtURL:self.info.URL options:NSFileCoordinatorWritingForReplacing
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

- (IBAction)move:(id)sender {
	NSLog(@"move");
	
	if (![self.info isUbiquitous]) {
		NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
		NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:[self.info.URL lastPathComponent]];

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{                          
			NSError *error = nil;
			if ([[NSFileManager defaultManager] setUbiquitous:YES 
													itemAtURL:self.info.URL
											   destinationURL:destinationUbiquitousURL
														error:&error]) {
				NSLog(@"Copy to iCloud storage");
			}
			else {
				NSLog(@"%@", [error localizedDescription]);
			}
		});
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (IBAction)share:(id)sender {
	if ([self.info isUbiquitous]) {
		NSDate *expirationDate = nil;
		NSError *error = nil;	
		NSURL *sharedURL = [[NSFileManager defaultManager] URLForPublishingUbiquitousItemAtURL:self.info.URL
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
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
	}
	if (buttonIndex == 1) {
		NSString *title = alertView.message;
		NSURL *URL = [NSURL URLWithString:title];
		[[UIApplication sharedApplication] openURL:URL];
	}
}

#pragma mark - dealloc

- (void)dealloc {
	self.info = nil;
    self.textView = nil;
	self.moveButton = nil;
	self.shareButton = nil;
    [super dealloc];
}

#pragma mark - Override

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSFileManager defaultManager] setDelegate:nil];	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	self.shareButton.enabled = [self.info isUbiquitous];
	self.moveButton.enabled = ![self.info isUbiquitous];
	[self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	self.title = self.info.title;
	
	NSError *error = nil;
	NSFileCoordinator *coordinator = [[[NSFileCoordinator alloc] initWithFilePresenter:nil] autorelease];
	
	[coordinator coordinateReadingItemAtURL:self.info.URL 
									options:NSFileCoordinatorReadingWithoutChanges
									  error:&error
								 byAccessor:^(NSURL *readingURL) {
									 NSError *error = nil;
									 
									 // buffer for merging
									 NSMutableString *string = [NSMutableString string];
									 
									 // fetch versions
									 NSArray *unresolvedVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:readingURL];
									 if ([unresolvedVersions count]== 0) {
										 NSLog(@"This URL has no unresolved conflict versions.");
										 self.textView.text = [NSString stringWithContentsOfURL:[[NSFileVersion currentVersionOfItemAtURL:readingURL] URL] encoding:NSUTF8StringEncoding error:nil];
										 return;
									 }
									 
									 // dump all versions
									 [NSFileVersion dumpAllVersionsAtURL:self.info.URL];
									 
									 // merge all versions.
									 for (NSFileVersion *version in unresolvedVersions) {
										 NSError *error = nil;
										 version.resolved = YES;
										 NSString *otherVersionString = [NSString stringWithContentsOfURL:[version URL] 
																								 encoding:NSUTF8StringEncoding 
																									error:&error];
										 [string appendString:otherVersionString];
									 }
									 
									 // remove all other version excepting the current version.
									 [NSFileVersion removeOtherVersionsOfItemAtURL:readingURL error:&error];
									 if (error)
										 NSLog(@"Removing other versions Error = %@", [error localizedDescription]);
									 else
										 NSLog(@"Removing other versions OK = %@", readingURL);
									 
									 // append current version's content
									 [string appendString:[NSString stringWithContentsOfURL:[[NSFileVersion currentVersionOfItemAtURL:readingURL] URL] encoding:NSUTF8StringEncoding error:nil]];
									 
									 // write the new merged file.
									 [coordinator coordinateWritingItemAtURL:self.info.URL
																	 options:NSFileCoordinatorWritingForReplacing
																	   error:&error
																  byAccessor:^(NSURL *newURL) {
																	  NSError *error = nil;
																	  NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
																	  [data writeToURL:newURL options:0 error:&error];
																	  
																	  if (error)
																		  NSLog(@"Writing Error = %@", [error localizedDescription]);
																	  else
																		  NSLog(@"Writing OK = %@", newURL);
																  }];
									 self.textView.text = string;
								 }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
