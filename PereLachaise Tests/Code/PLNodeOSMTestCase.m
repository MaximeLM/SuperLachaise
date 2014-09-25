//
//  PLNodeOSMTestCase.m
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

#import <XCTest/XCTest.h>

#import "RestKit.h"
#import "Testing.h"

#import "PLRestKitMapping.h"
#import "PLMonument.h"
#import "PLNodeOSM+ext.h"
#import "PLPersonnalite.h"

// Classe de tests de la classe PLNodeOSM
@interface PLNodeOSMTestCase : XCTestCase

@end

@implementation PLNodeOSMTestCase

- (void)setUp
{
    [super setUp];
    
    [RKTestFixture setFixtureBundle:[NSBundle bundleForClass:[self class]]];
    [RKTestFactory setUp];
}

- (void)tearDown
{
    [RKTestFactory tearDown];
    [super tearDown];
}

#pragma mark - coordinates

// Vérifie que la méthode coordinates renvoie le résultat attendu
- (void)testCoordinates
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"nodeOSM1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping nodeOSMMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLNodeOSM *nodeOSM = [mappingTest destinationObject];
    
    // Vérification de la valeur des coordonnées
    CLLocationCoordinate2D coordonnes_expected = CLLocationCoordinate2DMake([nodeOSM.latitude doubleValue], [nodeOSM.longitude doubleValue]);
    CLLocationCoordinate2D coordonnes_actual = nodeOSM.coordinates;
    
    XCTAssertEqual(coordonnes_expected.latitude, coordonnes_actual.latitude, @"");
    XCTAssertEqual(coordonnes_expected.longitude, coordonnes_actual.longitude, @"");
}

#pragma mark - Contraintes

// Vérifie que les contraintes de l'entité sont conformes ; cas nominal OK
- (void)testContraintesOK
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Vérification que la sauvegarde réussit
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas id
- (void)testContraintesId
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    PLNodeOSM *nodeOSM = monument.nodeOSM;
    
    // Suppression du champ
    nodeOSM.id = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas latitude
- (void)testContraintesLatitude
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    PLNodeOSM *nodeOSM = monument.nodeOSM;
    
    // Suppression du champ
    nodeOSM.latitude = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas longitude
- (void)testContraintesLongitude
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    PLNodeOSM *nodeOSM = monument.nodeOSM;
    
    // Suppression du champ
    nodeOSM.longitude = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas monument not nil
- (void)testContraintesMonumentNotNil
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture 1
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument1 = [mappingTest destinationObject];
    PLNodeOSM *nodeOSM1 = monument1.nodeOSM;
    
    // Chargement de la fixture 2
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"nodeOSM2.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping nodeOSMMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLNodeOSM *nodeOSM2 = [mappingTest destinationObject];
    
    // Affectation du node OSM 2 sur le monument 1
    monument1.nodeOSM = nodeOSM2;
    
    XCTAssertNil(nodeOSM1.monument, @"");
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas monument delete rule
- (void)testContraintesMonumentDeleteRule
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture 1
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument1 = [mappingTest destinationObject];
    PLNodeOSM *nodeOSM1 = monument1.nodeOSM;
    
    // Suppression du node OSM
    [managedObjectContext deleteObject:nodeOSM1];
    
    // Vérification que la sauvegarde échoue (delete rule = Deny)
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1550, error.code, @"");
}

@end
