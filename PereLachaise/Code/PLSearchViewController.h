//
//  PLSearchViewController.h
//  PereLachaise
//
//  Created by Maxime Le Moine on 06/12/2013.
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

#import "PLMapViewController.h"

@interface PLSearchViewController : UITableViewController

#pragma mark - Eléments d'interface

// Ferme ou dissimule la fenêtre
- (IBAction)doneButtonAction:(id)sender;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

// Met à jour la cellule pour le monument indiqué
- (void)updateRowForMonument:(PLMonument *)monument;

#pragma mark - Autres controleurs

@property (nonatomic, weak) PLMapViewController *mapViewController;

@end
