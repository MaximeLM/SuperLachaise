//
//  PLWikipediaViewController.h
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

#import <UIKit/UIKit.h>

#import "PLMonument+ext.h"

@interface PLWikipediaViewController : UIViewController <UIWebViewDelegate>

#pragma mark - Chargement

@property (nonatomic, strong) NSURL *urlToLoad;

#pragma mark - Eléments d'interface

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@property (nonatomic, strong) NSString *navigationTitle;

- (IBAction)safariButtonAction:(id)sender;

+ (NSURL *)baseURL;

@end
