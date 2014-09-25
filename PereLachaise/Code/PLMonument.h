//
//  PLMonument.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PLImageCommons, PLNodeOSM, PLPersonnalite;

@interface PLMonument : NSManagedObject

@property (nonatomic, retain) NSNumber * circuit;
@property (nonatomic, retain) NSString * codeWikipedia;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * nom;
@property (nonatomic, retain) NSString * nomPourTri;
@property (nonatomic, retain) NSNumber * personnalitesCount;
@property (nonatomic, retain) NSString * premiereLettreNomPourTri;
@property (nonatomic, retain) NSString * resume;
@property (nonatomic, retain) PLImageCommons *imagePrincipale;
@property (nonatomic, retain) PLNodeOSM *nodeOSM;
@property (nonatomic, retain) NSOrderedSet *personnalites;
@end

@interface PLMonument (CoreDataGeneratedAccessors)

- (void)insertObject:(PLPersonnalite *)value inPersonnalitesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPersonnalitesAtIndex:(NSUInteger)idx;
- (void)insertPersonnalites:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePersonnalitesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPersonnalitesAtIndex:(NSUInteger)idx withObject:(PLPersonnalite *)value;
- (void)replacePersonnalitesAtIndexes:(NSIndexSet *)indexes withPersonnalites:(NSArray *)values;
- (void)addPersonnalitesObject:(PLPersonnalite *)value;
- (void)removePersonnalitesObject:(PLPersonnalite *)value;
- (void)addPersonnalites:(NSOrderedSet *)values;
- (void)removePersonnalites:(NSOrderedSet *)values;
@end
