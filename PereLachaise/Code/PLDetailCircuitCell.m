//
//  PLDetailCircuitCell.m
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

#import "PLDetailCircuitCell.h"

@implementation PLDetailCircuitCell

- (void)prepareForReuse
{
    [_monument removeObserver:self forKeyPath:@"circuit"];
    _monument = nil;
    
    [super prepareForReuse];
}

#pragma mark - Eléments d'interface

- (void)removeFromSuperview
{
    [_monument removeObserver:self forKeyPath:@"circuit"];
    [super removeFromSuperview];
}

+ (CGFloat)heightForWidth:(CGFloat)width andMonument:(PLMonument *)monument
{
    NSAssert(monument, nil);
    
    CGFloat result = 45.0;
    
    return result;
}

// Surchargé pour adapter la vue lors du changement de monument
- (void)setMonument:(PLMonument *)monument
{
    PLTraceIn(@"monument: %@", monument);
    NSAssert(monument, nil);
    
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

#pragma mark - Mise à jour de l'affichage

- (void)updateLabels
{
    PLTraceIn(@"");
    
    self.circuitButton.selected = self.monument.circuit.boolValue;
    
    PLTraceOut(@"");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    PLTraceIn(@"");
    
    self.circuitButton.selected = self.monument.circuit.boolValue;
    
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

@end
