//
//  PLIPadSplitViewController.h
//  PereLachaise
//
//  Created by Maxime Le Moine on 16/11/2014.
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

#import "PLSearchViewController.h"
#import "PLMapViewController.h"
#import "PLDetailMonumentViewController.h"

@interface PLIPadSplitViewController : UIViewController

#pragma mark - Position

- (void)setShowSearchView:(BOOL)show;

#pragma mark - Sélection

- (void)showMonumentInDetailView:(PLMonument *)monument;

#pragma mark -  Autres controleurs

// Le controleur de la carte
@property (nonatomic, weak) PLMapViewController *mapViewController;

// Le controleur de la vue de navigation de recherche
@property (nonatomic, weak) UINavigationController *searchNavigationController;

// Le controleur de la vue de navigation de détail
@property (nonatomic, weak) UINavigationController *detailNavigationController;

// Le controleur de la vue de recherche
@property (nonatomic, weak) PLSearchViewController *searchViewController;

// Le controleur de la vue de détail
@property (nonatomic, weak) PLDetailMonumentViewController *detailMonumentViewController;

@end
