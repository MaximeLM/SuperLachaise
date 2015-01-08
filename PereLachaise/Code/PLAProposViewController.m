//
//  PLAProposViewController.m
//  PereLachaise
//
//  Created by Maxime Le Moine on 09/04/2014.
//  Copyright (c) 2014 SuperLachaise contributors.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <MessageUI/MFMailComposeViewController.h>

#import "PLAProposViewController.h"
#import "PLWikipediaViewController.h"

@interface PLAProposViewController () <UIWebViewDelegate, MFMailComposeViewControllerDelegate>

@end

@implementation PLAProposViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (PLIPad && PLPreVersion8) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // Récupération du bundle de l'application
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *path = [mainBundle bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSString *headName = (PLIPhone) ? @"head_iphone" : @"head_ipad";
    NSString *headFile = [mainBundle pathForResource:headName ofType:@"html"];
    NSString *headString = [NSString stringWithContentsOfFile:headFile encoding:NSUTF8StringEncoding error:nil];
    
    NSString *bodyFile = [mainBundle pathForResource:@"a_propos" ofType:@"html"];
    NSString *bodyString = [NSString stringWithContentsOfFile:bodyFile encoding:NSUTF8StringEncoding error:nil];
    
    NSString *htmlString = [headString stringByAppendingString:bodyString];
    
    self.webView.delegate = self;
    
    [self.webView loadHTMLString:htmlString baseURL:baseURL];
}

- (IBAction)doneButtonAction:(id)sender
{
    PLTraceIn(@"");
    
    [self.mapViewController closeListeMonuments];
    
    PLTraceOut(@"");
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *url = [request URL];
    PLInfo(@"URL: %@", url);
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if ([[url host] isEqualToString:@"itunes.apple.com"]) {
            // Redirection vers l'App Store
            [[UIApplication sharedApplication] openURL:url];
        } else if ([[url scheme] hasPrefix:@"http"]) {
            PLWikipediaViewController *wikipediaViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"Wikipedia"];
            wikipediaViewController.urlToLoad = url;
            
            [self.navigationController pushViewController:wikipediaViewController animated:YES];
        } else if ([[url scheme] isEqualToString:@"mailto"]) {
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setToRecipients:@[url.resourceSpecifier]];
            if (controller) {
                [self presentViewController:controller animated:YES completion:nil];
            }
        }
        
        return NO;
    }
    
    return YES;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    PLTraceIn(@"");
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    PLTraceOut(@"");
}

@end
