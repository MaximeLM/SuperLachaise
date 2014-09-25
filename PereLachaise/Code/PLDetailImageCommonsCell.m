//
//  PLDetailImageCommonsCell.m
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

#import "PLDetailImageCommonsCell.h"

#import "PLImageCommons+ext.h"
#import "NSString+compatibility.h"

@implementation PLDetailImageCommonsCell

#pragma mark - Eléments d'interface

static float kMinDimensionImage = 320.0;

- (void)prepareForReuse
{
    _monument = nil;
    
    [super prepareForReuse];
}

+ (CGFloat)heightForWidth:(CGFloat)width andMonument:(PLMonument *)monument
{
    NSAssert(monument.imagePrincipale, nil);
    
    CGFloat result = 1.0;
    
    CGSize maxSize;
    CGFloat largeurPourLabels = width - 40;
    
    // Constante de hauteur séparant 2 labels
    CGFloat verticalSpacing = 8.0;
    
    UIImage *image = monument.imagePrincipale.image;
    
    // Hauteur image
    CGFloat imageRatio = image.size.height / image.size.width;
    
    // Aspect fit
    CGFloat hauteurImage = MIN(kMinDimensionImage, ceil(width * imageRatio));
    
    PLInfo(@"hauteurImage: %f", hauteurImage);
    
    result += hauteurImage;
    
    // Hauteur label attribution
    maxSize = CGSizeMake(largeurPourLabels, NSUIntegerMax);
    CGSize size = [monument.imagePrincipale.attribution compatibilitySizeWithFont:[UIFont italicSystemFontOfSize:9] constrainedToSize:maxSize];
    result += verticalSpacing + ceil(size.height);
    
    // Hauteur finale
    result += verticalSpacing;
    
    return result;
}

// Surchargé pour adapter la vue lors du changement de monument
- (void)setMonument:(PLMonument *)monument
{
    PLTraceIn(@"monument: %@", monument);
    NSAssert(monument.imagePrincipale, nil);
    
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
    
    // Mise à jour de l'image
    self.imageContainerView.image = self.monument.imagePrincipale.image;
    
    // Affichage de l'attribution
    self.attributionLabel.text = self.monument.imagePrincipale.attribution;
    
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
    
    // Hauteur imageContainerView
    UIImage *image = self.imageContainerView.image;
    
    // Hauteur image
    CGFloat imageRatio = image.size.height / image.size.width;
    CGFloat width = self.contentView.frame.size.width;
    
    // Aspect fit
    CGFloat hauteurImage = MIN(kMinDimensionImage, ceil(width * imageRatio));
    
    self.imageContainerViewHeigthConstraint.constant = hauteurImage;
    
    // Hauteur label nom
    maxSize = CGSizeMake(largeurPourLabels, NSUIntegerMax);
    CGSize size = [self.attributionLabel.text compatibilitySizeWithFont:self.attributionLabel.font constrainedToSize:maxSize];
    self.attributionLabelHeigthConstraint.constant = ceil(size.height);
    
    PLTrace(@"attributionLabelHeigthConstraint: %f", self.attributionLabelHeigthConstraint.constant);
    
    [super updateConstraints];
    PLTraceOut(@"");
}

@end
