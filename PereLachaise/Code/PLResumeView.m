//
//  PLResumeView.m
//  PereLachaise
//
//  Created by Maxime Le Moine on 05/04/2014.
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

#import "PLResumeView.h"
#import "PLWikipediaViewController.h"

@implementation PLResumeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView.scrollEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.suppressesIncrementalRendering = YES;
        
        self.ready = NO;
    }
    return self;
}

- (void)setMonument:(PLMonument *)monument
{
    PLTraceIn(@"monument: %@", monument);
    NSAssert(monument.resume && ![monument.resume isEqualToString:@""], nil);
    
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

- (void)setPersonnalite:(PLPersonnalite *)personnalite
{
    PLTraceIn(@"personnalite: %@", personnalite);
    NSAssert(personnalite.resume && ![personnalite.resume isEqualToString:@""], nil);
    
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
    
    // Récupération du bundle de l'application
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    // Récupération du chemin d'accès au fichier de configuration de la carte
    NSString *cssFile = [mainBundle pathForResource:@"wikipedia" ofType:@"css"];
    
    NSString *cssString = [NSString stringWithContentsOfFile:cssFile encoding:NSUTF8StringEncoding error:nil];
    
    NSString *javaScriptString = @"<script type=\"text/javascript\">window.onload = function() {window.location.href = \"ready://\" + document.body.offsetHeight;}</script>";
    
    NSString *HTMLString;
    if (self.monument) {
        HTMLString = self.monument.resume;
    } else {
        HTMLString = self.personnalite.resume;
    }
    
    NSString *contentString = [NSString stringWithFormat:@"%@\n%@\n%@", javaScriptString, cssString, HTMLString];
    
    NSURL *baseURL = [PLWikipediaViewController baseURL];
    [self loadHTMLString:contentString baseURL:baseURL];
    
    PLTraceOut(@"");
}

#pragma mark - UIView

- (void)layoutSubviews
{
    PLTraceIn(@"");
    
    // Mise à jour des labels
    [self updateLabels];
    
    [super layoutSubviews];
    
    PLTraceOut(@"");
}

@end
