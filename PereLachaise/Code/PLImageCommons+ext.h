//
//  PLImageCommons+ext.h
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

#import "PLImageCommons.h"

// Personnalisation de la classe générée PLImageCommons
@interface PLImageCommons (ext)

// Génère une image à partir du nom de fichier indiqué
@property(nonatomic, readonly) UIImage *image;

// Renvoie le texte d'attribution
@property(nonatomic, readonly) NSString *attribution;

// Renvoie l'URL de la page Wikimedia Commons associée
@property(nonatomic, readonly) NSURL *commonsURL;

// Indique si le fichier image associé existe dans le bundle
- (BOOL)imageExistsInBundle;

@end
