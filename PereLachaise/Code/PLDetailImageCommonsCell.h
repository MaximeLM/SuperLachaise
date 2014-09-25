//
//  PLDetailImageCommonsCell.h
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

#import "PLMonument+ext.h"

@interface PLDetailImageCommonsCell : UITableViewCell

// Le monument représenté
@property (nonatomic, weak) PLMonument *monument;

#pragma mark - Eléments d'interface

// La vue contenant l'image
@property (nonatomic, weak) IBOutlet UIImageView *imageContainerView;

// Le label contenant l'attribution
@property (nonatomic, weak) IBOutlet UILabel *attributionLabel;

// La contrainte sur la hauteur du label nomLabel
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *attributionLabelHeigthConstraint;

// La contrainte sur la hauteur de imageContainerView
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageContainerViewHeigthConstraint;

// Calcule la hauteur de la vue pour une largeur et un monument donnés
+ (CGFloat)heightForWidth:(CGFloat)width andMonument:(PLMonument *)monument;

#pragma mark - Mise à jour de l'affichage

// Met à jour le contenu des labels en fonction du monument représenté
- (void)updateLabels;

@end
