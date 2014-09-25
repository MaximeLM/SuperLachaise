//
//  PLDetailNomCell.m
//  PereLachaise
//
//  Created by Maxime Le Moine on 04/04/2014.
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

#import "PLDetailNomCell.h"
#import "PLPersonnalite+ext.h"
#import "NSString+compatibility.h"

@implementation PLDetailNomCell

#pragma mark - Eléments d'interface

+ (CGFloat)heightForWidth:(CGFloat)width andMonument:(PLMonument *)monument
{
    NSAssert(monument, nil);
    
    // Largeur disponible pour l'affichage des labels
    // = largeur de la vue moins les marges
    CGFloat largeurPourLabels = width - 40;
    
    // Constante de hauteur séparant 2 labels
    CGFloat verticalSpacing = 8.0;
    
    CGSize maxSize;
    
    CGFloat result = 1.0;
    
    // Hauteur label nom
    maxSize = CGSizeMake(largeurPourLabels, NSUIntegerMax);
    CGSize size = [monument.nom compatibilitySizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:maxSize];
    result += verticalSpacing + ceil(size.height);
    
    // Hauteur finale
    result += verticalSpacing;
    
    return result;
}

// Surchargé pour adapter la vue lors du changement de monument
- (void)setMonument:(PLMonument *)monument
{
    PLTraceIn(@"monument: %@", monument);
    NSAssert(monument, nil);
    
    // Affectation du monument
    [self willChangeValueForKey:@"monument"];
    _monument = monument;
    [self didChangeValueForKey:@"monument"];
    
    // Mise à jour du contenu des labels
    [self updateLabels];
    
    // Demande de mise à jour de l'affichage
    [self setNeedsLayout];
    
    NSAssert(self.monument, nil);
    PLTraceOut(@"");
}

#pragma mark - Mise à jour de l'affichage

- (void)updateLabels
{
    PLTraceIn(@"");
    
    // Récupération de la personnalité unique du monument si elle existe
    PLPersonnalite *uniquePersonnalite = self.monument.uniquePersonnalite;
    
    if (uniquePersonnalite) {
        PLTrace(@"Personnalité unique");
        // Affichage des informations liées à la personnalité
        
        self.nomLabel.text = uniquePersonnalite.nom;
        
    } else {
        PLTrace(@"Personnalité non unique");
        // Affichage du nom du monument
        
        self.nomLabel.text = self.monument.nom;
    }
    
    PLTraceOut(@"");
}

#pragma mark - UIView

- (void)layoutSubviews
{
    PLTraceIn(@"");
    
    // Mise à jour des labels
    [self updateLabels];
    
    // Demande de mise à jour des contraintes
    if (PLPostVersion7) {
        [self setNeedsUpdateConstraints];
    } else {
        [self updateConstraints];
    }
    
    [super layoutSubviews];
    
    PLTraceOut(@"");
}

- (void)updateConstraints
{
    PLTraceIn(@"");
    
    // Largeur disponible pour l'affichage des labels
    // = largeur de la vue moins les marges
    CGFloat largeurPourLabels = self.contentView.frame.size.width - 40;
    
    CGSize maxSize;
    
    // Hauteur label nom
    maxSize = CGSizeMake(largeurPourLabels, NSUIntegerMax);
    CGSize size = [self.nomLabel.text compatibilitySizeWithFont:self.nomLabel.font constrainedToSize:maxSize];
    self.nomLabelHeigthConstraint.constant = ceil(size.height);
    
    PLTrace(@"nomLabelHeigthConstraint: %f", self.nomLabelHeigthConstraint.constant);
    
    [super updateConstraints];
    PLTraceOut(@"");
}

@end
