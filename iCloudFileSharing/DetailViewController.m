//
//  DetailViewController.m
//  iCloudFileSharing
//
//  Created by Yoshida Yuichi on 11/12/28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

#import "FileInfo.h"

@implementation DetailViewController

@synthesize textView = _textView;
@synthesize info = _info;

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
	}
	if (self.info.ubiquitousURL) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
		[self.navigationController setToolbarHidden:NO animated:YES];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	self.title = self.info.title;
	if (self.info.path) {
		self.navigationItem.rightBarButtonItem.enabled = YES;
		self.textView.text = [NSString stringWithContentsOfFile:self.info.path encoding:NSUTF8StringEncoding error:nil];
	}
	if (self.info.ubiquitousURL) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
		self.textView.text = [NSString stringWithContentsOfURL:self.info.ubiquitousURL encoding:NSUTF8StringEncoding error:nil];
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
