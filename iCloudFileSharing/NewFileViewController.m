/*
 * iCloud File Sharing
 * NewFileViewController.m
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

#import "NewFileViewController.h"

@implementation NewFileViewController

@synthesize fileNameField = _fileNameField;
@synthesize textView = _textView;

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

- (IBAction)save:(id)sender {
	NSString *fileName = self.fileNameField.text;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
	
	if ([[NSFileManager defaultManager] isReadableFileAtPath:path]) {
		NSLog(@"Alread exists");
	}
	else {
		NSData *data = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
		[data writeToFile:path atomically:YES];
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    self.fileNameField = nil;
	self.textView = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
