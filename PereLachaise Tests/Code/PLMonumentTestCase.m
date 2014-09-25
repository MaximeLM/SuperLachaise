//
//  PLMonumentTestCase.m
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
#import "PLMonument+ext.h"
#import "PLNodeOSM.h"
#import "PLPersonnalite.h"
#import "PLImageCommons.h"

// Classe de tests de la classe PLMonument
@interface PLMonumentTestCase : XCTestCase

@end

@implementation PLMonumentTestCase

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

#pragma mark - personnalitesCountForMonument

// Vérifie que la méthode personnalitesCountForMonument renvoie le résultat attendu
// Cas : aucune personnalité
- (void)testPersonnalitesCountForMonument0
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument2.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    
    // Vérification du résultat de la méthode
    XCTAssertEqual(0, [PLMonument personnalitesCountForMonument:monument], @"");
}

// Vérifie que la méthode personnalitesCountForMonument renvoie le résultat attendu
// Cas : 1 personnalité
- (void)testPersonnalitesCountForMonument1
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
    
    // Vérification du résultat de la méthode
    XCTAssertEqual(1, [PLMonument personnalitesCountForMonument:monument], @"");
}

// Vérifie que la méthode personnalitesCountForMonument renvoie le résultat attendu
// Cas : 2 personnalités
- (void)testPersonnalitesCountForMonument2
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument2_update2.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    
    // Vérification du résultat de la méthode
    XCTAssertEqual(2, [PLMonument personnalitesCountForMonument:monument], @"");
}

#pragma mark - premiereLettreNomPourTri

// Vérifie que la méthode upperCaseFirstLetterOfString renvoie des résultats conformes
- (void)testUpperCaseFirstLetterOfString
{
    // Vérification des règles de transformation
    NSString *result;
    
    XCTAssertThrows([PLMonument upperCaseFirstLetterOfString:nil]);
    XCTAssertThrows([PLMonument upperCaseFirstLetterOfString:@""]);
    
    result = [PLMonument upperCaseFirstLetterOfString:@"E"];
    XCTAssertEqualObjects(@"E", result, @"");
    
    result = [PLMonument upperCaseFirstLetterOfString:@"Étonnant"];
    XCTAssertEqualObjects(@"E", result, @"");
    
    result = [PLMonument upperCaseFirstLetterOfString:@"à bientôt"];
    XCTAssertEqualObjects(@"A", result, @"");
    
    result = [PLMonument upperCaseFirstLetterOfString:@"ça c'est fait"];
    XCTAssertEqualObjects(@"C", result, @"");
    
    result = [PLMonument upperCaseFirstLetterOfString:@"42"];
    XCTAssertEqualObjects(@"4", result, @"");
    
    result = [PLMonument upperCaseFirstLetterOfString:@" hello"];
    XCTAssertEqualObjects(@" ", result, @"");
}

// Vérifie que la sauvegarde d'un objet affecte le champ premiereLettreNomPourTri (cas 1)
- (void)testPremiereLettreNomPourTriSave1
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
    
    // Vérification que le champ n'est pas renseigné avant sauvegarde
    XCTAssertNil(monument.premiereLettreNomPourTri, @"");
    
    // Sauvegarde des objets
    [managedObjectContext save:nil];
    
    // Vérification que le champ est renseigné
    XCTAssertNotNil(monument.premiereLettreNomPourTri, @"");
    XCTAssertEqualObjects(@"M", monument.premiereLettreNomPourTri, @"");
}

// Vérifie que la sauvegarde d'un objet affecte le champ premiereLettreNomPourTri (cas 2)
- (void)testPremiereLettreNomPourTriSave2
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument2.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    
    // Vérification que le champ n'est pas renseigné avant sauvegarde
    XCTAssertNil(monument.premiereLettreNomPourTri, @"");
    
    // Sauvegarde des objets
    [managedObjectContext save:nil];
    
    // Vérification que le champ est renseigné
    XCTAssertNotNil(monument.premiereLettreNomPourTri, @"");
    XCTAssertEqualObjects(@"M", monument.premiereLettreNomPourTri, @"");
}

// Vérifie que la sauvegarde d'un objet affecte le champ premiereLettreNomPourTri (cas 3)
- (void)testPremiereLettreNomPourTriSave3
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument3.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    
    // Vérification que le champ n'est pas renseigné avant sauvegarde
    XCTAssertNil(monument.premiereLettreNomPourTri, @"");
    
    // Sauvegarde des objets
    [managedObjectContext save:nil];
    
    // Vérification que le champ est renseigné
    XCTAssertNotNil(monument.premiereLettreNomPourTri, @"");
    XCTAssertEqualObjects(@"E", monument.premiereLettreNomPourTri, @"");
}

#pragma mark - uniquePersonnalite

// Vérifie que les méthodes liées au champ uniquePersonnalite renvoient des résultats conformes (cas 0)
- (void)testUniquePersonnalite0
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument2.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    
    // Vérification que le champ a la valeur par défaut avant sauvegarde
    XCTAssertEqualObjects(@(0), monument.personnalitesCount, @"");
    
    // Vérification que la méthode uniquePersonnalite renvoie nil avant sauvegarde
    XCTAssertNil(monument.uniquePersonnalite, @"");
    
    // Vérification que la méthode statique donne le résultat attendu
    XCTAssertEqual(0, [PLMonument personnalitesCountForMonument:monument], @"");
    
    // Sauvegarde des objets
    [managedObjectContext save:nil];
    
    // Vérification que le champ a la bonne valeur après sauvegarde
    XCTAssertEqualObjects(@(0), monument.personnalitesCount, @"");
    
    // Vérification que la méthode uniquePersonnalite renvoie la bonne valeur après sauvegarde
    XCTAssertNil(monument.uniquePersonnalite, @"");
}

// Vérifie que les méthodes liées au champ uniquePersonnalite renvoient des résultats conformes (cas 1)
- (void)testUniquePersonnalite1
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
    
    // Vérification que le champ a la valeur par défaut avant sauvegarde
    XCTAssertEqualObjects(@(0), monument.personnalitesCount, @"");
    
    // Vérification que la méthode uniquePersonnalite renvoie nil avant sauvegarde
    XCTAssertNil(monument.uniquePersonnalite, @"");
    
    // Vérification que la méthode statique donne le résultat attendu
    XCTAssertEqual(1, [PLMonument personnalitesCountForMonument:monument], @"");
    
    // Sauvegarde des objets
    [managedObjectContext save:nil];
    
    // Vérification que le champ a la bonne valeur après sauvegarde
    XCTAssertEqualObjects(@(1), monument.personnalitesCount, @"");
    
    // Vérification que la méthode uniquePersonnalite renvoie la bonne valeur après sauvegarde
    XCTAssertEqualObjects([monument.personnalites objectAtIndex:0], monument.uniquePersonnalite, @"");
}

// Vérifie que les méthodes liées au champ uniquePersonnalite renvoient des résultats conformes (cas 2)
- (void)testUniquePersonnalite2
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument2_update2.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    
    // Vérification que le champ a la valeur par défaut avant sauvegarde
    XCTAssertEqualObjects(@(0), monument.personnalitesCount, @"");
    
    // Vérification que la méthode uniquePersonnalite renvoie nil avant sauvegarde
    XCTAssertNil(monument.uniquePersonnalite, @"");
    
    // Vérification que la méthode statique donne le résultat attendu
    XCTAssertEqual(2, [PLMonument personnalitesCountForMonument:monument], @"");
    
    // Sauvegarde des objets
    [managedObjectContext save:nil];
    
    // Vérification que le champ a la bonne valeur après sauvegarde
    XCTAssertEqualObjects(@(2), monument.personnalitesCount, @"");
    
    // Vérification que la méthode uniquePersonnalite renvoie la bonne valeur après sauvegarde
    XCTAssertNil(monument.uniquePersonnalite, @"");
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
    
    // Suppression du champ
    monument.id = nil;
    
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
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    
    // Suppression du champ
    monument.nom = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
    
    // Mise à blanc du champ
    monument.nom = @"";
    
    // Vérification que la sauvegarde échoue
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1670, error.code, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas nom pour tri
- (void)testContraintesNomPourTri
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
    
    // Suppression du champ
    monument.nomPourTri = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
    
    // Mise à blanc du champ
    monument.nomPourTri = @"";
    
    // Vérification que la sauvegarde échoue
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1670, error.code, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas code wikipedia
- (void)testContraintesCodeWikipedia
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
    
    // Suppression du champ
    monument.codeWikipedia = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
    
    // Mise à blanc du champ
    monument.codeWikipedia = @"";
    
    // Vérification que la sauvegarde réussit
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas résumé
- (void)testContraintesResume
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
    
    // Suppression du champ
    monument.resume = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
    
    // Mise à blanc du champ
    monument.resume = @"";
    
    // Vérification que la sauvegarde réussit
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas node OSM not nil
- (void)testContraintesNodeOSMNotNil
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
    PLMonument *monument1 = [mappingTest destinationObject];
    
    // Chargement de la fixture
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument2.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument2 = [mappingTest destinationObject];
    
    // Suppression du node OSM 2
    [managedObjectContext deleteObject:monument2.nodeOSM];
    
    // Affectation du node OSM 1 sur le monument 2
    monument1.nodeOSM.monument = monument2;
    
    XCTAssertNil(monument1.nodeOSM, @"");
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas node OSM delete rule
- (void)testContraintesNodeOSMDeleteRule
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
    
    // Vérification que le node OSM existe
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    
    // Suppression du monument
    [managedObjectContext deleteObject:monument];
    
    // Vérification que la sauvegarde réussit
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
    
    // Vérification que le node OSM a été supprimé (delete rule = Cascade)
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas personnalités vide
- (void)testContraintesPersonnalitesVide
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
    
    // Suppression des personnalites du monument
    for (PLPersonnalite *personnalite in monument.personnalites) {
        [managedObjectContext deleteObject:personnalite];
    }
    
    // Mise à nil des personnalites du monument
    monument.personnalites = nil;
    
    // Vérification que la sauvegarde réussit
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas personnalités delete rule
- (void)testContraintesPersonnalitesDeleteRule
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument2_update2.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMapping monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    
    // Vérification que les personnalités existent
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    
    // Suppression du monument
    [managedObjectContext deleteObject:monument];
    
    // Vérification que la sauvegarde réussit
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
    
    // Vérification que les personnalités ont été supprimées (delete rule = Cascade)
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas image principale nil
- (void)testContraintesImagePrincipaleNil
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
    
    // Récupération de l'image principale
    PLImageCommons *imagePrincipale = monument.imagePrincipale;
    
    // Mise à nil de l'image principale du monument
    monument.imagePrincipale = nil;
    
    // Suppression de l'image principale
    [managedObjectContext deleteObject:imagePrincipale];
    
    // Vérification que la sauvegarde réussit
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas image principale delete rule
- (void)testContraintesImagePrincipaleDeleteRule
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
    
    // Suppression du monument
    [managedObjectContext deleteObject:monument];
    
    // Vérification que la sauvegarde réussit
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
    
    // Vérification que l'image Commons a été supprimée (delete rule = Cascade)
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
}

@end
