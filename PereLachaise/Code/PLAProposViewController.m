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

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *webViewHeightConstraint;

@property (nonatomic, strong) NSString *webContent;

@end

@implementation PLAProposViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Récupération du bundle de l'application
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    // Récupération du chemin d'accès au fichier de configuration de la carte
    NSString *cssFile = [mainBundle pathForResource:@"a_propos" ofType:@"css"];
    
    NSString *cssString = [NSString stringWithContentsOfFile:cssFile encoding:NSUTF8StringEncoding error:nil];
    
    NSString *javaScriptString = @"<script type=\"text/javascript\">window.onload = function() {window.location.href = \"ready://\" + document.body.offsetHeight;}</script>";
    javaScriptString = @"";
    NSString *htmlFile = [mainBundle pathForResource:@"a_propos" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    
    self.webContent = [NSString stringWithFormat:@"%@\n%@\n%@", javaScriptString, cssString, htmlString];
    
    self.webView.delegate = self;
    
    [self.webView loadHTMLString:self.webContent baseURL:[PLWikipediaViewController baseURL]];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = [indexPath indexAtPosition:1];
    
    if (YES) {
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
            
            self.webViewHeightConstraint.constant = contentHeight + 16.0;
            
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
