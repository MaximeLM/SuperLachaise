//
//  PLMonument+ext.m
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

#import "PLMonument+ext.h"

@implementation PLMonument (ext)

#pragma mark - Propriétés dérivées

- (PLPersonnalite *)uniquePersonnalite {
    PLTraceIn(@"");
    
    PLPersonnalite *result = nil;
    
    if ([self.personnalitesCount intValue] == 1) {
        PLTrace(@"Personnalité unique");
        result = [self.personnalites objectAtIndex:0];
    }
    
    PLTraceOut(@"result: %@", result);
    return result;
}

#pragma mark - Méthodes statiques

+ (NSString *)upperCaseFirstLetterOfString:(NSString *)string
{
    PLTraceIn(@"string: %@", string);
    NSAssert(string && [string length] > 0, nil);
    
    // Récupération de la première lettre du nom (support UTF-16)
    NSString *premiereLettreNom = [string substringWithRange:[string rangeOfComposedCharacterSequenceAtIndex:0]];
    
    // Conversion des accents, par exemple É->E
    premiereLettreNom = [[NSString alloc] initWithData:[premiereLettreNom dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] encoding:NSASCIIStringEncoding];
    
    // Conversion en majuscule
    NSString *result = [premiereLettreNom uppercaseString];
    
    PLTraceOut(@"result: %@", result);
    return result;
}

+ (unsigned long)personnalitesCountForMonument:(PLMonument *)monument
{
    PLTraceIn(@"monument: %@", monument);
    
    unsigned long result = [monument.personnalites count];
    
    PLTraceOut(@"result: %d", result);
    return result;
}

#pragma mark - NSManagedObject

// Méthode de sauvegarde surchargée pour mettre à jour les propriétés dérivées
- (void)willSave
{
    PLTraceIn(@"");
    
    // Nom pour tri
    
    // Récupération du nom pour tri
    NSString *nomPourTri = [self primitiveValueForKey:@"nomPourTri"];
    NSAssert(nomPourTri && [nomPourTri length] > 0, nil);
    
    // Récupération de la première lettre en majuscule et sans accent
    NSString *upperCaseFirstLetter = [PLMonument upperCaseFirstLetterOfString:nomPourTri];
    
    // Mise à jour
    [self setPrimitiveValue:upperCaseFirstLetter forKey:@"premiereLettreNomPourTri"];
    
    // Nombre de personnalités
    
    // Récupération du nombre de personnalités
    unsigned long personnalitesCount = [PLMonument personnalitesCountForMonument:self];
    
    // Mise à jour
    [self setPrimitiveValue:[NSNumber numberWithUnsignedLong:personnalitesCount] forKey:@"personnalitesCount"];
    
    PLTraceOut(@"");
    [super willSave];
}

#pragma mark - Accesseurs to-many

// Crash Core Date avec NSOrderedSet, besoin de réécrire les accesseurs
// http://stackoverflow.com/a/9556747

static NSString *const kItemsKey = @"personnalites";

- (void)insertObject:(PLPersonnalite *)value inPersonnalitesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)removeObjectFromPersonnalitesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)insertPersonnalites:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet insertObjects:values atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)removePersonnalitesAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)replaceObjectInPersonnalitesAtIndex:(NSUInteger)idx withObject:(PLPersonnalite *)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)replacePersonnalitesAtIndexes:(NSIndexSet *)indexes withPersonnalites:(NSArray *)values {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)addPersonnalitesObject:(PLPersonnalite *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
    [tmpOrderedSet addObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)removePersonnalitesObject:(PLPersonnalite *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
    if (idx != NSNotFound) {
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
        [tmpOrderedSet removeObject:value];
        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
    }
}

- (void)addPersonnalites:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tmpOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    if (valuesCount > 0) {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
        [tmpOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
    }
}

- (void)removePersonnalites:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (id value in values) {
        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
        if (idx != NSNotFound) {
            [indexes addIndex:idx];
        }
    }
    if ([indexes count] > 0) {
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
        [tmpOrderedSet removeObjectsAtIndexes:indexes];
        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
    }
}

@end
