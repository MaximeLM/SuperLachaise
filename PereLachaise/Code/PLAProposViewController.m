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

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *webViewHeightConstraint1;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *webViewHeightConstraint2;

@property (nonatomic, strong) NSString *webContent1;
@property (nonatomic, strong) NSString *webContent2;

@end

@implementation PLAProposViewController

- (void)viewDidAppear:(BOOL)animated
{
    [self.osmTable deselectRowAtIndexPath:[self.osmTable indexPathForSelectedRow] animated:YES];
    
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView1.scrollView.scrollEnabled = NO;
    self.webView2.scrollView.scrollEnabled = NO;
    
    // Récupération du bundle de l'application
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    // Récupération du chemin d'accès au fichier de configuration de la carte
    NSString *cssFile = [mainBundle pathForResource:@"wikipedia" ofType:@"css"];
    
    NSString *cssString = [NSString stringWithContentsOfFile:cssFile encoding:NSUTF8StringEncoding error:nil];
    
    NSString *javaScriptString = @"<script type=\"text/javascript\">window.onload = function() {window.location.href = \"ready://\" + document.body.offsetHeight;}</script>";
    
    NSString *htmlFile1 = [mainBundle pathForResource:@"a_propos_1" ofType:@"html"];
    NSString *htmlString1 = [NSString stringWithContentsOfFile:htmlFile1 encoding:NSUTF8StringEncoding error:nil];
    
    NSString *htmlFile2 = [mainBundle pathForResource:@"a_propos_2" ofType:@"html"];
    NSString *htmlString2 = [NSString stringWithContentsOfFile:htmlFile2 encoding:NSUTF8StringEncoding error:nil];
    
    self.webContent1 = [NSString stringWithFormat:@"%@\n%@\n%@", javaScriptString, cssString, htmlString1];
    self.webContent2 = [NSString stringWithFormat:@"%@\n%@\n%@", javaScriptString, cssString, htmlString2];
    
    self.webView1.delegate = self;
    self.webView2.delegate = self;
    
    [self.webView1 loadHTMLString:self.webContent1 baseURL:[PLWikipediaViewController baseURL]];
    [self.webView2 loadHTMLString:self.webContent2 baseURL:[PLWikipediaViewController baseURL]];
}

- (IBAction)doneButtonAction:(id)sender
{
    PLTraceIn(@"");
    
    [self.mapViewController closeListeMonuments];
    
    PLTraceOut(@"");
}

- (IBAction)rateThisAppButtonAction:(id)sender
{
    PLTraceIn(@"");
    
    // Redirection vers l'App Store
    NSString *iTunesLink = @"https://itunes.apple.com/fr/app/super-lachaise/id918263934?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    
    PLTraceOut(@"");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger result;
    
    if (tableView == self.osmTable) {
        result = 3;
    } else {
        NSAssert(NO, nil);
        return 0;
    }
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLTraceIn(@"tableView: %@ indexPath: %@", tableView, indexPath);
    
	UITableViewCell *cell;
    NSInteger index = [indexPath indexAtPosition:1];
    
    if (tableView == self.osmTable) {
        if (index == 0) {
            static NSString *kSiteOSM = @"SiteOSM";
            cell = [tableView dequeueReusableCellWithIdentifier:kSiteOSM];
        } else if (index == 1) {
            static NSString *kCopyrightOSMID = @"CopyrightOSM";
            cell = [tableView dequeueReusableCellWithIdentifier:kCopyrightOSMID];
        } else if (index == 2) {
            static NSString *kCopyrightMapbox = @"CopyrightMapbox";
            cell = [tableView dequeueReusableCellWithIdentifier:kCopyrightMapbox];
        }
    }
    
    // Suppression de l'accessoire droit sur iPad
    if (PLIPad) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSAssert(cell, nil);
    PLTraceOut(@"return: %@", cell);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = [indexPath indexAtPosition:1];
    
    if (tableView == self.osmTable) {
        NSURL *url;
        NSString *title;
        
        if (index == 0) {
            url = [NSURL URLWithString:@"http://www.openstreetmap.org/about"];
            title = @"OpenStreetMap";
        } else if (index == 1) {
            url = [NSURL URLWithString:@"http://www.openstreetmap.org/copyright"];
            title = @"Licence";
        } else if (index == 2) {
            url = [NSURL URLWithString:@"http://www.mapbox.com/about/maps/"];
            title = @"Mapbox Streets";
        } else {
            NSAssert(NO, nil);
        }
        
        PLWikipediaViewController *webViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"Wikipedia"];
        webViewController.urlToLoad = url;
        webViewController.navigationTitle = title;
        
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *url = [request URL];
    PLInfo(@"URL: %@", url);
    
    if (navigationType == UIWebViewNavigationTypeOther) {
        if ([[url scheme] isEqualToString:@"ready"]) {
            float contentHeight = [[url host] floatValue];
            
            if (webView == self.webView1) {
                self.webViewHeightConstraint1.constant = contentHeight + 8.0;
            } else if (webView == self.webView2) {
                self.webViewHeightConstraint2.constant = contentHeight + 16.0;
            }
            
            // Correction de la taille du texte
            NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",
                                  100];
            [webView stringByEvaluatingJavaScriptFromString:jsString];
            
            return NO;
        }
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if ([[url scheme] isEqualToString:@"http"]) {
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
