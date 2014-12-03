//
//  PLMonumentTableViewCell.m
//  PereLachaise
//
//  Created by Maxime Le Moine on 01/04/2014.
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

#import "PLMonumentTableViewCell.h"

#import "NSString+compatibility.h"

static NSString *starPrefix = @"★ ";

@interface PLMonumentTableViewCell ()

- (void)updateLabelsForMonument;

- (void)updateLabelsForPersonnalite;

@end

@implementation PLMonumentTableViewCell

- (NSString *)description
{
    return [NSString stringWithFormat:@"<PLMonumentTableViewCell>"];
}

- (void)prepareForReuse
{
    self.selected = NO;
    _monument = nil;
    _personnalite = nil;
    _starImageView.hidden = YES;
    
    [super prepareForReuse];
}

#pragma mark - Eléments d'interface

+ (CGFloat)heightForWidth:(CGFloat)width andMonument:(PLMonument *)monument
{
    // Largeur disponible pour l'affichage des labels
    // = largeur de la vue moins les marges
    CGFloat largeurPourLabels = width - 20;
    
    // Constante de hauteur séparant 2 labels
    CGFloat verticalSpacing = 8.0;
    
    CGSize maxSize;
    
    CGFloat result = 1.0;
    
    // Hauteur label nom
    maxSize = CGSizeMake(largeurPourLabels, NSUIntegerMax);
    CGSize size = [monument.nom compatibilitySizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:maxSize];
    result += verticalSpacing + ceil(size.height);
    
    // Hauteur label dates
    PLPersonnalite *uniquePersonnalite = monument.uniquePersonnalite;
    if (uniquePersonnalite && uniquePersonnalite.hasAllDates) {
        result += verticalSpacing + 18.0;
    }
    
    // Hauteur label activité
    if (uniquePersonnalite && ![uniquePersonnalite.activite isEqualToString:@""]) {
        maxSize = CGSizeMake(largeurPourLabels, NSUIntegerMax);
        CGSize size = [uniquePersonnalite.activite compatibilitySizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:maxSize];
        
        result += verticalSpacing + ceil(size.height);
    }
    
    // Hauteur finale
    result += verticalSpacing;
    
    return result;
}

+ (CGFloat)heightForWidth:(CGFloat)width andPersonnalite:(PLPersonnalite *)personnalite
{
    // Largeur disponible pour l'affichage des labels
    // = largeur de la vue moins les marges
    CGFloat largeurPourLabels = width - 20;
    
    // Constante de hauteur séparant 2 labels
    CGFloat verticalSpacing = 8.0;
    
    CGSize maxSize;
    
    CGFloat result = 1.0;
    
    // Hauteur label nom
    maxSize = CGSizeMake(largeurPourLabels, NSUIntegerMax);
    CGSize size = [personnalite.nom compatibilitySizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:maxSize];
    result += verticalSpacing + ceil(size.height);
    
    // Hauteur label dates
    if (personnalite.hasAllDates) {
        result += verticalSpacing + 18.0;
    }
    
    // Hauteur label activité
    if (![personnalite.activite isEqualToString:@""]) {
        maxSize = CGSizeMake(largeurPourLabels, NSUIntegerMax);
        CGSize size = [personnalite.activite compatibilitySizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:maxSize];
        
        result += verticalSpacing + ceil(size.height);
    }
    
    // Hauteur finale
    result += verticalSpacing;
    
    return result;
}

+ (UIColor *)colorForSelectedCell
{
    static dispatch_once_t once;
    static UIColor *sharedColor;
    dispatch_once(&once, ^{
        sharedColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    });
    
    return sharedColor;
}

// Surchargé pour adapter la vue lors du changement de monument
- (void)setMonument:(PLMonument *)monument
{
    PLTraceIn(@"monument: %@", monument);
    
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

// Surchargé pour adapter la vue lors du changement de personnalité
- (void)setPersonnalite:(PLPersonnalite *)personnalite
{
    PLTraceIn(@"personnalite: %@", personnalite);
    
    // Affectation du monument
    [self willChangeValueForKey:@"personnalite"];
    _personnalite = personnalite;
    [self didChangeValueForKey:@"personnalite"];
    
    // Mise à jour du contenu des labels
    [self updateLabels];
    
    // Demande de mise à jour de l'affichage
    [self setNeedsLayout];
    
    NSAssert(self.personnalite, nil);
    PLTraceOut(@"");
}

#pragma mark - Mise à jour de l'affichage

- (void)updateLabels
{
    PLTraceIn(@"");
    
    if (self.monument) {
        [self updateLabelsForMonument];
    } else {
        [self updateLabelsForPersonnalite];
    }
    
    PLTraceOut(@"");
}

- (void)updateLabelsForMonument
{
    PLTraceIn(@"");
    
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
    
    // Star si sélectionné
    self.starImageView.hidden = !self.monument.circuit.boolValue;
    
    PLTraceOut(@"");
}

- (void)updateLabelsForPersonnalite
{
    PLTraceIn(@"");
    
    self.nomLabel.text = self.personnalite.nom;
    self.activiteLabel.text = self.personnalite.activite;
    
    if (self.personnalite.hasAllDates) {
        PLTrace(@"hasAllDates");
        // Affichage des dates si elles sont toutes les présentes
        self.datesLabel.text = [NSString stringWithFormat:@"%@-%@", self.personnalite.dateNaissanceCourte, self.personnalite.dateDecesCourte];
    } else {
        PLTrace(@"not hasAllDates");
        // Pas d'affichage des dates s'il en manque une ou les 2
        self.datesLabel.text = @"";
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
    CGFloat largeurPourNom = self.contentView.frame.size.width - 20 - self.nomLabelTrailingConstraint.constant;
    CGFloat largeurPourLabels = self.contentView.frame.size.width - 20 - self.activiteLabelTrailingConstraint.constant;
    
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

@end
