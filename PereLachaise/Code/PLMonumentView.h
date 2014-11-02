//
//  PLMonumentView.h
//  PereLachaise
//
//  Created by Maxime Le Moine on 23/03/2014.
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

// Une vue détaillant le monument sélectionné sur la carte
@interface PLMonumentView : UIView

// Le monument représenté
@property (nonatomic, strong) PLMonument *monument;

#pragma mark - Eléments d'interface

// Le label contenant le nom complet
@property (nonatomic, weak) IBOutlet UILabel *nomLabel;

// Le label contenant les dates de naissance et de décès
@property (nonatomic, weak) IBOutlet UILabel *datesLabel;

// Le label contenant l'activité
@property (nonatomic, weak) IBOutlet UILabel *activiteLabel;

// Le bouton d'ajout au circuit
@property (nonatomic, weak) IBOutlet UIButton *circuitButton;

// Le bouton d'accès au détail du monument
@property (nonatomic, weak) IBOutlet UIButton *detailButton;

// La bordure supérieure de la vue
@property (nonatomic, weak) CALayer *topBorder;

// La bordure latérale de la vue (iPad)
@property (nonatomic, weak) CALayer *leftBorder;

#pragma mark - Contraintes

// La contrainte sur la hauteur du label nomLabel
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *nomLabelHeigthConstraint;

// La contrainte sur la hauteur du label datesLabel
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *datesLabelHeigthConstraint;

// La contrainte sur la hauteur séparant les labels nomLabel et datesLabel
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *nomDatesVerticalSpaceConstraint;

// La contrainte sur la hauteur du label activiteLabel
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *activiteLabelHeigthConstraint;

// La contrainte sur la hauteur séparant les labels datesLabel et activiteLabel
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *datesActiviteVerticalSpaceConstraint;

// La contrainte à droite du label nomLabel
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *nomLabelTrailingConstraint;

// La contrainte à droite du label activiteLabel
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *activiteLabelTrailingConstraint;

#pragma mark - Mise à jour de l'affichage

// Calcule la taille de la vue pour une largeur maximum et un monument donnés
+ (CGSize)sizeForMaxWidth:(CGFloat)maxWidth andMonument:(PLMonument *)monument;

@property (nonatomic) CGFloat width;

// Redessine les layers de la vue
- (void)updateLayers;

// Met à jour le contenu des labels en fonction du monument représenté
- (void)updateLabels;

@end
