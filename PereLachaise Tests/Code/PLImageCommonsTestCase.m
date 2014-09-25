//
//  PLImageCommonsTestCase.m
//  PereLachaise
//
//  Created by Maxime Le Moine on 24/08/2014.
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

#import "PLRestKitMonumentAll.h"
#import "PLImageCommons+ext.h"
#import "PLMonument.h"
#import "PLNodeOSM.h"
#import "PLPersonnalite.h"

// Classe de tests de la classe PLImageCommons
@interface PLImageCommonsTestCase : XCTestCase

@end

@implementation PLImageCommonsTestCase

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

#pragma mark - image

// Vérifie que la méthode image renvoie le résultat attendu quand l'image existe
- (void)testImageExists
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"imageCommons1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll imageCommonsMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLImageCommons *imageCommons = [mappingTest destinationObject];
    
    // Récupération de l'image calculée
    UIImage *image = [imageCommons image];
    
    // Vérification qu'une image a été renvoyée
    XCTAssertNotNil(image, @"");
}

// Vérifie que la méthode image renvoie le résultat attendu quand l'image n'existe pas
- (void)testImageNotExists
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"imageCommons1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll imageCommonsMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLImageCommons *imageCommons = [mappingTest destinationObject];
    
    // Modification du nom de l'image
    imageCommons.nom = @"not_exist.jpg";
    
    // Récupération de l'image calculée
    UIImage *image = [imageCommons image];
    
    // Vérification qu'une image a été renvoyée
    XCTAssertNil(image, @"");
}

#pragma mark - attribution

// Vérifie que la méthode attribution renvoie le résultat attendu
- (void)testAttribution
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"imageCommons1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll imageCommonsMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLImageCommons *imageCommons = [mappingTest destinationObject];
    
    // Récupération de l'attribution calculée
    NSString *attribution = [imageCommons attribution];
    
    // Vérification que l'attribution est conforme
    XCTAssertEqualObjects(@"Touron66 / Wikimedia Commons / CC-BY-SA-3.0", attribution, @"");
    
    // Modification des propriétés de l'image
    imageCommons.auteur = @"auteur";
    imageCommons.licence = @"licence";
    
    // Récupération de l'attribution calculée
    attribution = [imageCommons attribution];
    
    // Vérification que l'attribution est conforme
    XCTAssertEqualObjects(@"auteur / Wikimedia Commons / licence", attribution, @"");
}

#pragma mark - commonsURL

// Vérifie que la méthode commonsURL renvoie le résultat attendu
- (void)testCommonsURL
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"imageCommons2.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll imageCommonsMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLImageCommons *imageCommons = [mappingTest destinationObject];
    
    // Récupération de l'URL Commons calculée
    NSURL *urlCommons = [imageCommons commonsURL];
    
    // Vérification que l'URL est conforme
    NSString *expectedString = [[@"http://commons.wikimedia.org/wiki/File:Tombe_de_Jim_Morrison_-_Père_Lachaise.jpg" stringByReplacingOccurrencesOfString:@"_" withString:@" "] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    XCTAssertEqualObjects(expectedString, [urlCommons absoluteString], @"");
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
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
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
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    PLImageCommons *imageCommons = monument.imagePrincipale;
    
    // Suppression du champ
    imageCommons.id = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas nom
- (void)testContraintesNom
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    PLImageCommons *imageCommons = monument.imagePrincipale;
    
    // Suppression du champ
    imageCommons.nom = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
    
    // Mise à blanc du champ
    imageCommons.nom = @"";
    
    // Vérification que la sauvegarde échoue
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1670, error.code, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas auteur
- (void)testContraintesAuteur
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    PLImageCommons *imageCommons = monument.imagePrincipale;
    
    // Suppression du champ
    imageCommons.auteur = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
    
    // Mise à blanc du champ
    imageCommons.auteur = @"";
    
    // Vérification que la sauvegarde échoue
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1670, error.code, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas licence
- (void)testContraintesLicence
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    PLImageCommons *imageCommons = monument.imagePrincipale;
    
    // Suppression du champ
    imageCommons.licence = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
    
    // Mise à blanc du champ
    imageCommons.licence = @"";
    
    // Vérification que la sauvegarde échoue
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1670, error.code, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas urlOriginal
- (void)testContraintesUrlOriginal
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    PLImageCommons *imageCommons = monument.imagePrincipale;
    
    // Suppression du champ
    imageCommons.urlOriginal = nil;
    
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
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"imageCommons1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll imageCommonsMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
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
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    PLImageCommons *imageCommons = monument.imagePrincipale;
    
    // Suppression de l'image Commons
    [managedObjectContext deleteObject:imageCommons];
    
    // Vérification que la sauvegarde échoue (delete rule = Deny)
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1550, error.code, @"");
}

@end
