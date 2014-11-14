//
//  PLMonumentView.m
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

#import "PLMonumentView.h"
#import "PLPersonnalite+ext.h"
#import "NSString+compatibility.h"

@implementation PLMonumentView

- (NSString *)description
{
    return [NSString stringWithFormat:@"<PLMonumentView>"];
}

#pragma mark - Eléments d'interface

// Surchargé pour adapter la vue lors du changement de monument
- (void)setMonument:(PLMonument *)monument
{
    PLTraceIn(@"monument: %@", monument);
    
    [_monument removeObserver:self forKeyPath:@"circuit"];
    
    // Affectation du monument
    [self willChangeValueForKey:@"monument"];
    _monument = monument;
    [self didChangeValueForKey:@"monument"];
    
    // Mise à jour du contenu des labels
    [self updateLabels];
    
    // Demande de mise à jour de l'affichage
    [self setNeedsLayout];
    
    [monument addObserver:self forKeyPath:@"circuit" options:NSKeyValueObservingOptionNew context:nil];
    
    NSAssert(self.monument, nil);
    PLTraceOut(@"");
}

- (void)removeFromSuperview
{
    [_monument removeObserver:self forKeyPath:@"circuit"];
}

#pragma mark - Mise à jour de l'affichage

- (void)updateLayers
{
    PLTraceIn(@"");
    
    CGFloat borderWidth;
    if (PLRetina) {
        borderWidth = 0.5;
    } else {
        borderWidth = 1.0;
    }
    
    if (PLIPhone && !self.topBorder && PLIPhone) {
        // Création de la bordure supérieure
        CALayer *topBorder = [CALayer layer];
        topBorder.backgroundColor = [UIColor blackColor].CGColor;
        [self.layer addSublayer:topBorder];
        self.topBorder = topBorder;
    }
    
    if (PLIPad && !self.iPadBorderCreated) {
        // Création de la bordure
        self.layer.cornerRadius = 4.0f;
        self.layer.masksToBounds = NO;
        self.layer.borderWidth = borderWidth;
        
        self.iPadBorderCreated = YES;
    }
    
    if (PLIPhone) {
        // Redessin de la bordure avec la largeur actuelle de la vue
        self.topBorder.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width * 2, borderWidth);
    }
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 4;
    self.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    
    PLTraceOut(@"");
}

- (void)updateLabels
{
    PLTraceIn(@"");
    
    self.circuitButton.selected = self.monument.circuit.boolValue;
    
    // Récupération de la personnalité unique du monument si elle existe
    PLPersonnalite *uniquePersonnalite = self.monument.uniquePersonnalite;
    
    self.nomLabel.text = self.monument.nom;
    
    if (uniquePersonnalite) {
        PLTrace(@"Personnalité unique");
        // Affichage des informations liées à la personnalité
        
        self.activiteLabel.text = uniquePersonnalite.activite;
        
        if (uniquePersonnalite.hasAllDates) {
            PLTrace(@"hasAllDates");
            // Affichage des dates si elles sont toutes les présentes
            self.datesLabel.text = [NSString stringWithFormat:@"%@-%@", uniquePersonnalite.dateNaissanceCourte, uniquePersonnalite.dateDecesCourte];
        } else {
            PLTrace(@"not hasAllDates");
            // Pas d'affichage des dates s'il en manque une ou les 2
            self.datesLabel.text = @"";
        }
    } else {
        PLTrace(@"Personnalité non unique");
        // Affichage du nom du monument
        
        self.datesLabel.text = @"";
        self.activiteLabel.text = @"";
    }
    
    PLTraceOut(@"");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    PLTraceIn(@"");
    
    self.circuitButton.selected = self.monument.circuit.boolValue;
    
    PLTraceOut(@"");
}

#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    PLTraceIn(@"");
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Pas de conversion de l'autoresize en contraintes
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return self;
    
    PLTraceOut(@"");
}

- (void)layoutSubviews
{
    PLTraceIn(@"");
    
    // Mise à jour de la bordure supérieure
    [self updateLayers];
    
    // Mise à jour des labels
    [self updateLabels];
    
    // Demande de mise à jour des contraintes
    [self setNeedsUpdateConstraints];
    
    [super layoutSubviews];
    
    PLTraceOut(@"");
}

- (void)updateConstraints
{
    PLTraceIn(@"");
    
    // Largeur disponible pour l'affichage des labels
    // = largeur de la vue moins les marges
    CGFloat largeurPourNom = self.frame.size.width - 20 - self.nomLabelTrailingConstraint.constant;
    CGFloat largeurPourLabels = self.frame.size.width - 20 - self.activiteLabelTrailingConstraint.constant;
    
    // Constante de hauteur séparant 2 labels
    CGFloat verticalSpacing = 8.0;
    
    CGSize maxSize;
    
    // Hauteur label nom
    maxSize = CGSizeMake(largeurPourNom, NSUIntegerMax);
    CGSize size = [self.nomLabel.text compatibilitySizeWithFont:self.nomLabel.font constrainedToSize:maxSize];
    self.nomLabelHeigthConstraint.constant = ceil(size.height);
    
    PLTrace(@"nomLabelHeigthConstraint: %f", self.nomLabelHeigthConstraint.constant);
    
    // Hauteur label dates
    if (![self.datesLabel.text isEqualToString:@""]) {
        PLTrace(@"datesLabel non vide");
        
        maxSize = CGSizeMake(largeurPourLabels, NSUIntegerMax);
        CGSize size = [self.datesLabel.text compatibilitySizeWithFont:self.datesLabel.font constrainedToSize:maxSize];
        
        self.datesLabelHeigthConstraint.constant = ceil(size.height);
        self.nomDatesVerticalSpaceConstraint.constant = verticalSpacing;
    } else {
        PLTrace(@"datesLabel vide");
        
        self.datesLabelHeigthConstraint.constant = 0;
        self.nomDatesVerticalSpaceConstraint.constant = 0;
    }
    
    PLTrace(@"datesLabelHeigthConstraint: %f", self.datesLabelHeigthConstraint.constant);
    PLTrace(@"nomDatesVerticalSpaceConstraint: %f", self.nomDatesVerticalSpaceConstraint.constant);
    
    // Hauteur label activité
    if (![self.activiteLabel.text isEqualToString:@""]) {
        PLTrace(@"activiteLabel non vide");
        
        maxSize = CGSizeMake(largeurPourLabels, NSUIntegerMax);
        CGSize size = [self.activiteLabel.text compatibilitySizeWithFont:self.activiteLabel.font constrainedToSize:maxSize];
        
        self.activiteLabelHeigthConstraint.constant = ceil(size.height);
        self.datesActiviteVerticalSpaceConstraint.constant = verticalSpacing;
    } else {
        PLTrace(@"activiteLabel vide");
        
        self.activiteLabelHeigthConstraint.constant = 0;
        self.datesActiviteVerticalSpaceConstraint.constant = 0;
    }
    
    PLTrace(@"activiteLabelHeigthConstraint: %f", self.activiteLabelHeigthConstraint.constant);
    PLTrace(@"datesActiviteVerticalSpaceConstraint: %f", self.datesActiviteVerticalSpaceConstraint.constant);
    
    [super updateConstraints];
    PLTraceOut(@"");
}

+ (CGSize)sizeForMaxWidth:(CGFloat)maxWidth andMonument:(PLMonument *)monument
{
    PLTraceIn(@"");
    
    CGFloat margins = 20 + 20;
    
    // Largeur disponible pour l'affichage des labels
    // = largeur de la vue moins les marges
    CGFloat largeurPourNom = maxWidth - 20.0 - 35.0;
    CGFloat largeurPourLabels = maxWidth - 20.0 - 20.0;
    
    // Constante de hauteur séparant 2 labels
    CGFloat verticalSpacing = 8.0;
    
    // Marges en haut et en bas de la partie supérieure
    CGFloat marginSpacing = 12.0;
    
    CGSize maxSize;
    
    CGSize result;
    
    CGFloat result_width = 280;
    CGFloat result_height = 1.0;
    
    // Taille label nom
    maxSize = CGSizeMake(largeurPourNom, NSUIntegerMax);
    CGSize size = [monument.nom compatibilitySizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:maxSize];
    result_height += marginSpacing + ceil(size.height);
    result_width = MAX(result_width, ceil(size.width) + 25.0);  // Décalage par rapport au bouton +
    // Taille label dates
    PLPersonnalite *uniquePersonnalite = monument.uniquePersonnalite;
    if (uniquePersonnalite && uniquePersonnalite.hasAllDates) {
        result_height += verticalSpacing + 18.0;
    }
    
    // Taille label activité
    if (uniquePersonnalite && ![uniquePersonnalite.activite isEqualToString:@""]) {
        maxSize = CGSizeMake(largeurPourLabels, NSUIntegerMax);
        CGSize size = [uniquePersonnalite.activite compatibilitySizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:maxSize];
        
        result_height += verticalSpacing + ceil(size.height);
        result_width = MAX(result_width, ceil(size.width));
    }
    
    // Taille bouton circuit
    result_height += marginSpacing + 44;
    result_width = MAX(result_width, 202);
    
    result.width = result_width + margins;
    result.height = result_height;
    
    PLTraceOut(@"result %f %f",result.width,result.height);
    return result;
}

@end
