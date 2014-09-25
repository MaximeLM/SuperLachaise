//
//  PLConfiguration.m
//  PereLachaise
//
//  Created by Maxime Le Moine on 16/03/2014.
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

#import "PLConfiguration.h"

// Dictionnaire partagé
static NSDictionary *_dictionary;

@implementation PLConfiguration

+ (NSDictionary *)sharedDictionary
{
    PLTraceIn(@"");
    
    // Construction du dictionnaire au premier appel
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        // Récupération du bundle de l'application
        NSBundle *mainBundle = [NSBundle mainBundle];
        
        // Récupération du chemin d'accès au fichier de configuration de la carte
        NSString *mapConfigurationFile = [mainBundle pathForResource:@"Configuration" ofType:@"plist"];
        
        // Chargement du contenu du fichier dans le dictionnaire
        _dictionary = [[NSDictionary alloc] initWithContentsOfFile:mapConfigurationFile];
    });
    
    NSAssert(_dictionary, nil);
    PLTraceOut(@"result: %@",_dictionary);
    return _dictionary;
}

+ (NSObject *)valueForKeyPath:(NSString *)keyPath
{
    PLTraceIn(@"");
    
    // Récupération du ditionnaire
    NSDictionary *dictionary = [PLConfiguration sharedDictionary];
    
    // Récupération de la valeur demandée
    NSObject *result = [dictionary valueForKeyPath:keyPath];
    
    PLTraceOut(@"result: %@", result);
    return result;
}

@end
