//
//  PLAProposNavigationController.m
//  PereLachaise
//
//  Created by Maxime Le Moine on 11/04/2014.
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

#import "PLAProposNavigationController.h"

#import "PLWikipediaViewController.h"

@interface PLAProposNavigationController ()

@end

@implementation PLAProposNavigationController

- (void)viewDidLoad
{
    PLTraceIn(@"");
    [super viewDidLoad];
    
    self.delegate = self;
    
    PLTraceOut(@"");
}

- (void)viewWillDisappear:(BOOL)animated
{
    PLTraceIn(@"");
    [super viewWillDisappear:animated];
    
    self.delegate = nil;
    
    PLTraceOut(@"");
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    PLTraceIn(@"");
    
    [self updateSizeForViewController:viewController];
    
    PLTraceOut(@"");
}

- (void)updateSizeForViewController:(UIViewController *)viewController
{
    PLTraceIn(@"viewController: %@", viewController);
    
    // Gestion de la taille du pop-over sur iPad (aucun effet sur iPhone)
    if ([viewController isKindOfClass:[PLWikipediaViewController class]]) {
        self.preferredContentSize = CGSizeMake(self.presentingViewController.view.frame.size.width, self.presentingViewController.view.frame.size.height);
    } else {
        self.preferredContentSize = CGSizeMake(375.0, 680.0);
    }
    
    PLTraceOut(@"");
}

@end
