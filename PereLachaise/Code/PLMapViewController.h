//
//  PLMapViewController.h
//  PereLachaise
//
//  Created by Maxime Le Moine on 01/11/2013.
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

@interface PLMapViewController : UIViewController

#pragma mark - Eléments d'interface

// Le panneau gauche contenant la liste des monuments (iPad)
@property (nonatomic, weak) IBOutlet UIView *leftPanel;

// La barre d'outils
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;

// Le bouton de recherche
@property (nonatomic, weak) IBOutlet UIButton *searchButton;

// Le bouton de circuits
@property (nonatomic, weak) IBOutlet UIButton *circuitButton;

// Le bouton d'informations
@property (nonatomic, weak) IBOutlet UIButton *infoButton;

// Le bouton de localisation
@property (nonatomic, weak) IBOutlet UIButton *localisationButton;

#pragma mark - Chargement des monuments

@property (nonatomic) BOOL filtreCircuit;

#pragma mark - Sélection des monuments

// Le monument actuellement sélectionnée sur la carte
@property (nonatomic, readonly, weak) PLMonument *selectedMonument;

// Modifie le monument actuellement sélectionné sur la carte
- (void)selectMonument:(PLMonument *)monument;

- (IBAction)filterButtonAction:(id)sender;

#pragma mark - Affichage de la liste des tombes

// Fermeture de la liste des monuments
- (void)closeListeMonuments;

#pragma mark - Déplacement

- (IBAction)trackingButtonAction:(id)sender;

@end
