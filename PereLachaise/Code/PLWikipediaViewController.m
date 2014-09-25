//
//  PLWikipediaViewController.m
//  PereLachaise
//
//  Created by Maxime Le Moine on 02/01/2014.
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

#import "PLWikipediaViewController.h"

@interface PLWikipediaViewController () <UIActionSheetDelegate> {
    // Indique si les modifications de titre doivent être ignorées
    BOOL _ignoreTitleChange;
}

@end

#pragma mark -

@implementation PLWikipediaViewController

+ (NSURL *)baseURL
{
    NSURL *baseURL = [NSURL URLWithString:@"http://fr.m.wikipedia.org/wiki/"];
    
    return baseURL;
}

#pragma mark - UIViewController

- (void)viewDidDisappear:(BOOL)animated {
    PLTraceIn(@"");
    
    // Annulation de la requête de chargement
    [self.webView stopLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [super viewWillDisappear:animated];
    
    PLTraceOut(@"");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Chargement de la page Wikipedia
    NSURLRequest *request = [NSURLRequest requestWithURL:self.urlToLoad];
    [self.webView loadRequest:request];
}

#pragma mark - Eléments d'interface

- (IBAction)safariButtonAction:(id)sender {
    PLTraceIn(@"sender: %@", sender);
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [actionSheet addButtonWithTitle:@"Ouvrir dans Safari"];
    
    [actionSheet addButtonWithTitle:@"Annuler"];
    actionSheet.cancelButtonIndex = [actionSheet numberOfButtons] - 1;
    
    [actionSheet showFromBarButtonItem:sender animated:YES];
    
    PLTraceOut(@"");
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    PLTraceIn(@"_ignoreTitleChange: %d",_ignoreTitleChange);
    
    if (!_ignoreTitleChange) {
        // Mise à jour du titre
        self.navigationItem.title = @"Chargement...";
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    PLTraceOut(@"");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    PLTraceIn(@"_ignoreTitleChange: %d",_ignoreTitleChange);
    
    if (!_ignoreTitleChange) {
        // Mise à jour du titre
        NSString *title = self.navigationTitle;
        
        if (!title) {
            // Construction du titre à partir de la page chargée
            title = [self.urlToLoad.absoluteString stringByReplacingOccurrencesOfString:[PLWikipediaViewController baseURL].absoluteString withString:@""];
            title = [title stringByReplacingOccurrencesOfString:@"_" withString:@" "];
            title = [title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        self.navigationItem.title = title;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    PLTraceOut(@"");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    PLTraceIn(@"_ignoreTitleChange: %d",_ignoreTitleChange);
    
    if (!_ignoreTitleChange) {
        // Mise à jour du titre
        self.navigationItem.title = @"Erreur de chargement";
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        _ignoreTitleChange = YES;
    }
    
    PLTraceOut(@"");
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        self.urlToLoad = request.URL;
    }
    
    return YES;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    PLTraceIn(@"");
    
    if (buttonIndex == 0) {
         NSURL *url = self.webView.request.URL;
         PLTrace(@"url: %@", url);
         
         [[UIApplication sharedApplication] openURL:url];
    }
    
    PLTraceOut(@"");
}

@end
