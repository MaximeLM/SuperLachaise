//
//  PLMonument+ext.h
//  PereLachaise
//
//  Created by Maxime Le Moine on 22/03/2014.
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

#import "PLMonument.h"

// Personnalisation de la classe générée PLMonument
@interface PLMonument (ext)

#pragma mark - Propriétés dérivées

// Renvoie la personnalité associée au monument si elle est unique
@property (nonatomic, weak, readonly) PLPersonnalite *uniquePersonnalite;

#pragma mark - Méthodes statiques

// Renvoie la première lettre en majuscule et sans accent de la chaîne indiquée
+ (NSString *)upperCaseFirstLetterOfString:(NSString *)string;

// Renvoie le nombre de personnalités associées au monument
+ (unsigned long)personnalitesCountForMonument:(PLMonument *)monument;

@end
