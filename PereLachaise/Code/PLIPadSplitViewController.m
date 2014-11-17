//
//  PLIPadSplitViewController.m
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

#import "PLIPadSplitViewController.h"

@interface PLIPadSplitViewController ()

#pragma mark - Eléments d'interface

// Prépare l'affichage de la vue de recherche
- (void)makeSearchView;

// Contrainte à gauche visible de la vue recherche
@property (nonatomic, strong) NSLayoutConstraint *searchViewLeadingVisibleConstraint;

@end

@implementation PLIPadSplitViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    PLTraceIn(@"");
    [super viewDidLoad];
    
    // Initialisation de la vue de recherche
    [self makeSearchView];
    
    PLTraceOut(@"");
}

#pragma mark - Eléments d'interface

- (void)makeSearchView
{
    PLTraceIn(@"");
    
    // Création du NavigationViewController
    UINavigationController *navigationController = [[self storyboard] instantiateViewControllerWithIdentifier:@"Navigation Controller"];
    PLSearchViewController *searchViewController = (PLSearchViewController *)[navigationController topViewController];
    searchViewController.mapViewController = self.mapViewController;
    
    // Ajout du ViewController et de sa vue dans la hiérarchie
    [self addChildViewController:navigationController];
    [self.view addSubview:navigationController.view];
    navigationController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Ajout des contraintes sur la vue
    
    // Contrainte en haut
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint
                                        constraintWithItem:navigationController.view
                                        attribute:NSLayoutAttributeTop
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                        attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                        constant:0.0];
    [self.view addConstraint:topConstraint];
    
    // Contrainte en bas
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint
                                            constraintWithItem:navigationController.view
                                            attribute:NSLayoutAttributeBottom
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:self.view
                                            attribute:NSLayoutAttributeBottom
                                            multiplier:1.0
                                            constant:0.0];
    [self.view addConstraint:bottomConstraint];
    
    // Contrainte de largeur
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
                                           constraintWithItem:navigationController.view
                                           attribute:NSLayoutAttributeWidth
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:nil
                                           attribute:NSLayoutAttributeNotAnAttribute
                                           multiplier:1.0
                                           constant:320.0];
    [self.view addConstraint:widthConstraint];
    
    // Contrainte à gauche visible (active à l'init)
    self.searchViewLeadingVisibleConstraint = [NSLayoutConstraint
                                               constraintWithItem:navigationController.view
                                               attribute:NSLayoutAttributeLeading
                                               relatedBy:NSLayoutRelationEqual
                                               toItem:self.view
                                               attribute:NSLayoutAttributeLeading
                                               multiplier:1.0
                                               constant:0.0];
    self.searchViewLeadingVisibleConstraint.priority = UILayoutPriorityDefaultHigh;
    [self.view addConstraint:self.searchViewLeadingVisibleConstraint];
    
    // Contrainte à droite cachée (inactive à l'init)
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint
                                              constraintWithItem:navigationController.view
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                              toItem:self.view
                                              attribute:NSLayoutAttributeLeading
                                              multiplier:1.0
                                              constant:0.0];
    trailingConstraint.priority = 500;
    [self.view addConstraint:trailingConstraint];
    
    // Envoi de l'évènement d'ajout
    [navigationController didMoveToParentViewController:self];
    
    PLTraceOut(@"");
}

@end
