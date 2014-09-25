//
//  PLRestKitMonumentAll.h
//  PereLachaise
//
//  Created by Maxime Le Moine on 17/03/2014.
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

#import <Foundation/Foundation.h>

#import "RestKit.h"

// Classe de configuration de la requête monument/all/
@interface PLRestKitMonumentAll : NSObject

#pragma mark - Path patterns

// Le path pattern de la requête monument/all/
+ (NSString *)pathPattern;

#pragma mark - Mappings

// Créée le mapping des nodes OSM
+ (RKEntityMapping *)nodeOSMMapping;

// Créée le mapping des images Commons
+ (RKEntityMapping *)imageCommonsMapping;

// Créée le mapping des personnalités
+ (RKEntityMapping *)personnaliteMapping;

// Créée le mapping des monuments
+ (RKEntityMapping *)monumentMapping;

#pragma mark - Response descriptors

// Créée le descripteur de requête
+ (RKResponseDescriptor *)responseDescriptor;

#pragma mark - Fetch request blocks

// Créée le bloc à annuler/remplacer de la requête
+ (RKFetchRequestBlock)fetchRequestBlock;

@end
