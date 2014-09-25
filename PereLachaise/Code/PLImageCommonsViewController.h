//
//  PLImageCommonsViewController.h
//  PereLachaise
//
//  Created by Maxime Le Moine on 21/04/2014.
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

#import "PLDetailMonumentViewController.h"

#import "PLImageCommons+ext.h"

@interface PLImageCommonsViewController : UIViewController

@property (nonatomic, weak) PLDetailMonumentViewController *detailMonumentViewController;

@property (nonatomic, weak) IBOutlet UIImageView *imageViewContainer;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageViewWidthConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

@property (nonatomic, strong) PLImageCommons *imageCommons;

@end
