//
//  PLInfoBoxView.m
//  PereLachaise
//
//  Created by Maxime Le Moine on 23/08/2014.
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

#import "PLInfoBoxView.h"
#import "NSString+compatibility.h"

@implementation PLInfoBoxView

- (NSString *)description
{
    return [NSString stringWithFormat:@"<PLInfoBoxView>"];
}

#pragma mark - Eléments d'interface

// Surchargé pour adapter la vue lors du changement de monument
- (void)setMessage:(NSString *)message
{
    PLTraceIn(@"message: %@", message);
    
    // Affectation du monument
    [self willChangeValueForKey:@"message"];
    _message = message;
    [self didChangeValueForKey:@"message"];
    
    // Mise à jour du contenu des labels
    [self updateLabels];
    
    // Demande de mise à jour de l'affichage
    [self setNeedsLayout];
    
    PLTraceOut(@"");
}

#pragma mark - Mise à jour de l'affichage

- (void)updateLayers
{
    PLTraceIn(@"");
    
    if (!self.bottomBorder) {
        // Création de la bordure
        CALayer *topBorder = [CALayer layer];
        topBorder.backgroundColor = [UIColor blackColor].CGColor;
        [self.borderView.layer addSublayer:topBorder];
        self.bottomBorder = topBorder;
    }
    
    CGFloat borderWidth;
    if (PLPostVersion7) {
        borderWidth = 0.5;
    } else {
        borderWidth = 1.0;
    }
    
    // Redessin de la bordure avec la largeur actuelle de la vue
    self.bottomBorder.frame = CGRectMake(0.0f, 1.0f, self.frame.size.width, borderWidth);
    
    PLTraceOut(@"");
}

- (void)updateLabels
{
    PLTraceIn(@"");
    
    self.messageLabel.text = self.message;
    
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
    
    // Mise à jour des labels
    [self updateLabels];
    
    // Mise à jour de la bordure supérieure
    [self updateLayers];
    
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
    CGFloat largeurPourLabels = self.frame.size.width - 40;
    
    CGSize maxSize;
    
    // Hauteur label message
    maxSize = CGSizeMake(largeurPourLabels, NSUIntegerMax);
    CGSize size = [self.messageLabel.text compatibilitySizeWithFont:self.messageLabel.font constrainedToSize:maxSize];
    self.messageLabelHeigthConstraint.constant = ceil(size.height);
    
    PLTrace(@"messageLabelHeigthConstraint: %f", self.messageLabelHeigthConstraint.constant);
    
    [super updateConstraints];
    PLTraceOut(@"");
}

+ (CGFloat)heightForWidth:(CGFloat)width andMessage:(NSString *)message
{
    // Largeur disponible pour l'affichage des labels
    // = largeur de la vue moins les marges
    CGFloat largeurPourLabels = width - 20 - 20;
    
    // Constante de hauteur séparant 2 labels
    CGFloat verticalSpacing = 8.0;
    
    // Marges en haut et en bas de la partie supérieure
    CGFloat marginSpacing = 12.0;
    
    // Hauteur de la barre de statut
    CGFloat statusBarHeight = 20.0;
    
    CGSize maxSize;
    
    CGFloat result = 0.0;
    
    // Hauteur label message
    maxSize = CGSizeMake(largeurPourLabels, NSUIntegerMax);
    CGSize size = [message compatibilitySizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:maxSize];
    result += ceil(size.height);
    
    // Ajout des marges
    result += statusBarHeight + verticalSpacing + marginSpacing;
    
    return result;
}

@end
