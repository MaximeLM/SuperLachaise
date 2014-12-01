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

// Monument sélectionné par défaut (conservé entre plusieurs affichages de l'écran)
static __weak PLMonument *_initialSelectedMonument;

@interface PLIPadSplitViewController ()

#pragma mark - Eléments d'interface

// Prépare l'affichage de la vue de recherche
- (void)makeSearchView;

// Prépare l'affichage de la vue de détail + web
- (void)makeDetailView;

// Contrainte à gauche visible de la vue recherche
@property (nonatomic, strong) NSLayoutConstraint *searchViewLeadingVisibleConstraint;

#pragma mark - Données

// Renvoie le dernier élément sélectionné ou le premier élément de la liste si aucun n'est sélectionné
// Conservé entre 2 affichage du menu
@property (nonatomic, weak) PLMonument *initialSelectedMonument;

@end

@implementation PLIPadSplitViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    PLTraceIn(@"");
    [super viewDidLoad];
    
    // Initialisation de la vue de recherche
    [self makeSearchView];
    
    // Initialisation de la vue de détail
    [self makeDetailView];
    
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
    
    self.searchNavigationController = navigationController;
    self.searchViewController = searchViewController;
    
    // Personnalisation des vues
    
    // Inversion de la position du boutons de fermeture de l'écran
    self.searchViewController.navigationItem.leftBarButtonItem = self.searchViewController.navigationItem.rightBarButtonItem;
    self.searchViewController.navigationItem.rightBarButtonItem = nil;
    
    PLTraceOut(@"");
}

- (void)makeDetailView
{
    PLTraceIn(@"");
    
    // Création du détail view controller
    PLDetailMonumentViewController *detailMonumentViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"DetailMonument"];
    
    // Vue d'un monument par défaut
    detailMonumentViewController.monument = self.initialSelectedMonument;
    
    // Création du NavigationViewController
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:detailMonumentViewController];
    detailMonumentViewController.mapViewController = self.mapViewController;
    
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
    
    // Contrainte à gauche
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint
                                             constraintWithItem:navigationController.view
                                             attribute:NSLayoutAttributeLeading
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:self.searchNavigationController.view
                                             attribute:NSLayoutAttributeTrailing
                                             multiplier:1.0
                                             constant:0.0];
    [self.view addConstraint:leadingConstraint];
    
    // Contrainte à gauche visible (active à l'init)
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint
                                              constraintWithItem:navigationController.view
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                              toItem:self.view
                                              attribute:NSLayoutAttributeTrailing
                                              multiplier:1.0
                                              constant:0.0];
    [self.view addConstraint:trailingConstraint];
    
    // Envoi de l'évènement d'ajout
    [navigationController didMoveToParentViewController:self];
    
    self.detailNavigationController = navigationController;
    self.detailMonumentViewController = detailMonumentViewController;
    
    PLTraceOut(@"");
}

#pragma mark - Position

- (void)setShowSearchView:(BOOL)show
{
    PLTraceIn(@"");
    
    if (show == (self.searchViewLeadingVisibleConstraint.priority == UILayoutPriorityDefaultHigh)) {
        // Pas de modification si déjà à la bonne position
        return;
    }
    
    if (show) {
        self.searchViewLeadingVisibleConstraint.priority = UILayoutPriorityDefaultHigh;
    } else {
        self.searchViewLeadingVisibleConstraint.priority = UILayoutPriorityDefaultLow;
    }
    
    // Animation du changement de contraintes
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view layoutIfNeeded];
    }completion:nil];
    
    PLTraceOut(@"");
}

#pragma mark - Sélection

- (void)showMonumentInDetailView:(PLMonument *)monument
{
    PLTraceIn(@"monument: %@", monument);
    
    // Retour à l'écran monument si l'écran personnalité était sélectionné
    [self.detailNavigationController popToRootViewControllerAnimated:YES];
    
    // Modification du monument
    self.detailMonumentViewController.monument = monument;
    
    // Scroll jusqu'en haut de l'écran
    [self.detailMonumentViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    self.initialSelectedMonument = monument;
    
    PLTraceOut(@"");
}

#pragma mark - Données

- (PLMonument *)initialSelectedMonument
{
    PLTraceIn(@"");
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _initialSelectedMonument = [self.searchViewController.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    });
    
    PLMonument *result = _initialSelectedMonument;
    
    NSAssert(result, @"");
    PLTraceOut(@"result: %@", result);
    return result;
}

- (void)setInitialSelectedMonument:(PLMonument *)initialSelectedMonument
{
    PLTraceIn(@"initialSelectedMonument: %@", initialSelectedMonument);
    
    _initialSelectedMonument = initialSelectedMonument;
    
    PLTraceOut(@"");
}

@end
