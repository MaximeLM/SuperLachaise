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

@interface PLAProposNavigationController ()

@end

@implementation PLAProposNavigationController

- (void)viewDidLoad
{
    PLTraceIn(@"");
    [super viewDidLoad];
    
    // Gestion de la taille du pop-over sur iPad
    self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, 680.0);
    
    PLTraceOut(@"");
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
