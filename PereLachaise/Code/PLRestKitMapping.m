//
//  PLRestKitMonumentAll.m
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

#import "PLRestKitMapping.h"

@implementation PLRestKitMapping

#pragma mark - Mappings

+ (RKEntityMapping *)nodeOSMMapping
{
    PLTraceIn(@"");
    NSAssert([RKObjectManager sharedManager], @"");
    
    // Mapping Node OSM
    RKEntityMapping *nodeOSMMapping = [RKEntityMapping mappingForEntityForName:@"PLNodeOSM" inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    [nodeOSMMapping addAttributeMappingsFromDictionary:@{@"id": @"id",
                                                         @"latitude": @"latitude",
                                                         @"longitude": @"longitude"
                                                         }];
    nodeOSMMapping.identificationAttributes = @[@"id"];
    
    PLTraceOut(@"result: %@", nodeOSMMapping);
    NSAssert(nodeOSMMapping, @"");
    return nodeOSMMapping;
}

+ (RKEntityMapping *)imageCommonsMapping
{
    PLTraceIn(@"");
    NSAssert([RKObjectManager sharedManager], @"");
    
    // Mapping Image Commons
    RKEntityMapping *imageCommonsMapping = [RKEntityMapping mappingForEntityForName:@"PLImageCommons" inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    [imageCommonsMapping addAttributeMappingsFromDictionary:@{@"id": @"id",
                                                              @"nom": @"nom",
                                                              @"auteur": @"auteur",
                                                              @"licence": @"licence",
                                                              @"url_original": @"urlOriginal"
                                                         }];
    imageCommonsMapping.identificationAttributes = @[@"id"];
    
    PLTraceOut(@"result: %@", imageCommonsMapping);
    NSAssert(imageCommonsMapping, @"");
    return imageCommonsMapping;
}

+ (RKEntityMapping *)personnaliteMapping
{
    PLTraceIn(@"");
    NSAssert([RKObjectManager sharedManager], @"");
    
    // Mapping Personnalite
    RKEntityMapping *personnaliteMapping = [RKEntityMapping mappingForEntityForName:@"PLPersonnalite" inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    [personnaliteMapping addAttributeMappingsFromDictionary:@{@"id": @"id",
                                                              @"nom": @"nom",
                                                              @"code_wikipedia": @"codeWikipedia",
                                                              @"activite": @"activite",
                                                              @"resume": @"resume",
                                                              @"date_naissance": @"dateNaissance",
                                                              @"date_naissance_precision": @"dateNaissancePrecision",
                                                              @"date_deces": @"dateDeces",
                                                              @"date_deces_precision": @"dateDecesPrecision"
                                                              }];
    personnaliteMapping.identificationAttributes = @[@"id"];
    
    PLTraceOut(@"result: %@", personnaliteMapping);
    NSAssert(personnaliteMapping, @"");
    return personnaliteMapping;
}

+ (RKEntityMapping *)monumentMapping
{
    PLTraceIn(@"");
    NSAssert([RKObjectManager sharedManager], @"");
    
    // Mapping Monument
    RKEntityMapping *monumentMapping = [RKEntityMapping mappingForEntityForName:@"PLMonument" inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    [monumentMapping addAttributeMappingsFromDictionary:@{@"id": @"id",
                                                          @"nom": @"nom",
                                                          @"nom_pour_tri": @"nomPourTri",
                                                          @"code_wikipedia": @"codeWikipedia",
                                                          @"resume": @"resume"
                                                          }];
    monumentMapping.identificationAttributes = @[@"id"];
    
    // Relation monument / node OSM
    RKRelationshipMapping *nodeOSMRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"node_osm" toKeyPath:@"nodeOSM" withMapping:[PLRestKitMapping nodeOSMMapping]];
    nodeOSMRelationshipMapping.assignmentPolicy = RKReplaceAssignmentPolicy;
    [monumentMapping addPropertyMapping:nodeOSMRelationshipMapping];
    
    // Relation monument / image Commons
    RKRelationshipMapping *imageCommonsRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"image_principale" toKeyPath:@"imagePrincipale" withMapping:[PLRestKitMapping imageCommonsMapping]];
    imageCommonsRelationshipMapping.assignmentPolicy = RKReplaceAssignmentPolicy;
    [monumentMapping addPropertyMapping:imageCommonsRelationshipMapping];
    
    // Relation monument / personnalités
    RKRelationshipMapping *personnaliteRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"personnalites" toKeyPath:@"personnalites" withMapping:[PLRestKitMapping personnaliteMapping]];
    personnaliteRelationshipMapping.assignmentPolicy = RKReplaceAssignmentPolicy;
    [monumentMapping addPropertyMapping:personnaliteRelationshipMapping];
    
    PLTraceOut(@"result: %@", monumentMapping);
    NSAssert(monumentMapping, @"");
    return monumentMapping;
}

@end
