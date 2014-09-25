//
//  PLPersonnalite+ext.h
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

#import "PLPersonnalite.h"

// Personnalisation de la classe générée PLPersonnalite
@interface PLPersonnalite (ext)

#pragma mark - Propriétés dérivées

// Renvoie la date de naissance au format court
@property (nonatomic, weak, readonly) NSString *dateNaissanceCourte;

// Renvoie la date de décès au format court
@property (nonatomic, weak, readonly) NSString *dateDecesCourte;

// Renvoie la date de naissance au format long
@property (nonatomic, weak, readonly) NSString *dateNaissanceLongue;

// Renvoie la date de décès au format long
@property (nonatomic, weak, readonly) NSString *dateDecesLongue;

// Indique si les dates de naissance et de décès de la personnalité sont renseignées
@property (nonatomic, readonly) BOOL hasAllDates;

// Indique si la dates de naissance ou de décès de la personnalité est renseignée
@property (nonatomic, readonly) BOOL hasDate;

#pragma mark - Formatteurs de dates

// Un formatteur de date qui affiche l'année
+ (NSDateFormatter *)anneeDateFormatter;

// Un formatteur de date qui affiche le mois et l'année
+ (NSDateFormatter *)moisDateFormatter;

// Un formatteur de date qui affiche le jour, le mois et l'année
+ (NSDateFormatter *)jourDateFormatter;

@end
