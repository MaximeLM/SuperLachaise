//
//  PLPersonnaliteTestCase.m
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

#import "PLRestKitMonumentAll.h"
#import "PLMonument.h"
#import "PLNodeOSM.h"
#import "PLPersonnalite+ext.h"

// Classe de tests de la classe PLNodeOSM
@interface PLPersonnaliteTestCase : XCTestCase

@end

@implementation PLPersonnaliteTestCase

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

#pragma mark - hasDates et hasAllDates

// Vérifie que les méthodes hasDates et hasAllDates renvoient des résultats conformes
- (void)testHasDates
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"personnalite1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll personnaliteMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résutat
    PLPersonnalite *personnalite = [mappingTest destinationObject];
    
    // Si les 2 dates sont renseignées
    XCTAssertNotNil(personnalite.dateNaissance, @"");
    XCTAssertNotNil(personnalite.dateDeces, @"");
    XCTAssertTrue(personnalite.hasAllDates, @"");
    XCTAssertTrue(personnalite.hasDate, @"");
    
    // Si une des deux dates est renseignée
    
    NSDate *dateBkp = personnalite.dateDeces;
    personnalite.dateDeces = nil;
    XCTAssertFalse(personnalite.hasAllDates, @"");
    XCTAssertTrue(personnalite.hasDate, @"");
    personnalite.dateDeces = dateBkp;
    
    personnalite.dateNaissance = nil;
    XCTAssertFalse(personnalite.hasAllDates, @"");
    XCTAssertTrue(personnalite.hasDate, @"");
    
    // Si aucune date n'est renseignée
    personnalite.dateNaissance = nil;
    personnalite.dateDeces = nil;
    XCTAssertFalse(personnalite.hasAllDates, @"");
    XCTAssertFalse(personnalite.hasDate, @"");
}

#pragma mark - Formats de date

// Vérifie que les formatteurs de date renvoient des résultats conformes
- (void)testDatesFormatters
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"personnalite1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll personnaliteMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résutat
    PLPersonnalite *personnalite = [mappingTest destinationObject];
    
    // Récupération des formatteurs de date
    NSDateFormatter *anneeDateFormatter = [PLPersonnalite anneeDateFormatter];
    NSDateFormatter *moisDateFormatter = [PLPersonnalite moisDateFormatter];
    NSDateFormatter *jourDateFormatter = [PLPersonnalite jourDateFormatter];
    
    XCTAssertNotNil(anneeDateFormatter, @"");
    XCTAssertNotNil(moisDateFormatter, @"");
    XCTAssertNotNil(jourDateFormatter, @"");
    
    // Utilisation de la locale FR-fr pour les tests
    anneeDateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"FR-fr"];
    moisDateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"FR-fr"];
    jourDateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"FR-fr"];
    
    NSString *dateString;
    
    // Vérification du format année
    dateString = [anneeDateFormatter stringFromDate:personnalite.dateNaissance];
    XCTAssertEqualObjects(@"1943", dateString, @"");
    
    // Vérification du format mois + année
    dateString = [moisDateFormatter stringFromDate:personnalite.dateDeces];
    XCTAssertEqualObjects(@"juillet 1971", dateString, @"");
    
    // Vérification du format jour + mois + année
    dateString = [jourDateFormatter stringFromDate:personnalite.dateNaissance];
    XCTAssertEqualObjects(@"8 décembre 1943", dateString, @"");
}

// Vérifie que les méthodes dateNaissanceCourte et dateDecesCourte renvoient des valeurs conformes
- (void)testFormeDateCourte
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"personnalite1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll personnaliteMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résutat
    PLPersonnalite *personnalite = [mappingTest destinationObject];
    
    // Utilisation de la locale FR-fr pour les tests
    [PLPersonnalite anneeDateFormatter].locale = [NSLocale localeWithLocaleIdentifier:@"FR-fr"];
    [PLPersonnalite moisDateFormatter].locale = [NSLocale localeWithLocaleIdentifier:@"FR-fr"];
    [PLPersonnalite jourDateFormatter].locale = [NSLocale localeWithLocaleIdentifier:@"FR-fr"];
    
    // Vérification des formes courtes
    XCTAssertEqualObjects(@"1943", personnalite.dateNaissanceCourte, @"");
    XCTAssertEqualObjects(@"1971", personnalite.dateDecesCourte, @"");
}

// Vérifie que la méthodes dateNaissanceLongue renvoie des valeurs conformes
- (void)testFormeDateNaissanceLongue
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"personnalite1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll personnaliteMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résutat
    PLPersonnalite *personnalite = [mappingTest destinationObject];
    
    // Utilisation de la locale FR-fr pour les tests
    [PLPersonnalite anneeDateFormatter].locale = [NSLocale localeWithLocaleIdentifier:@"FR-fr"];
    [PLPersonnalite moisDateFormatter].locale = [NSLocale localeWithLocaleIdentifier:@"FR-fr"];
    [PLPersonnalite jourDateFormatter].locale = [NSLocale localeWithLocaleIdentifier:@"FR-fr"];
    
    // Vérification des formats
    
    // Cas 1 : précision de la date au jour
    XCTAssertEqualObjects(@"J", personnalite.dateNaissancePrecision, @"");
    XCTAssertEqualObjects(@"8 décembre 1943", personnalite.dateNaissanceLongue, @"");
    
    // Cas 2 : précision de la date au mois
    personnalite.dateNaissancePrecision = @"M";
    XCTAssertEqualObjects(@"décembre 1943", personnalite.dateNaissanceLongue, @"");
    
    // Cas 3 : précision de la date à l'année
    personnalite.dateNaissancePrecision = @"A";
    XCTAssertEqualObjects(@"1943", personnalite.dateNaissanceLongue, @"");
    
    // Cas 4 : date nulle
    personnalite.dateNaissance = nil;
    XCTAssertNil(personnalite.dateNaissanceLongue, @"");
    
    // Cas 5 : précision inconnue
    personnalite.dateNaissancePrecision = @"K";
    XCTAssertThrows(personnalite.dateNaissanceLongue, @"");
}

// Vérifie que la méthodes dateDecesLongue renvoie des valeurs conformes
- (void)testFormeDateDecesLongue
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"personnalite1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll personnaliteMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résutat
    PLPersonnalite *personnalite = [mappingTest destinationObject];
    
    // Utilisation de la locale FR-fr pour les tests
    [PLPersonnalite anneeDateFormatter].locale = [NSLocale localeWithLocaleIdentifier:@"FR-fr"];
    [PLPersonnalite moisDateFormatter].locale = [NSLocale localeWithLocaleIdentifier:@"FR-fr"];
    [PLPersonnalite jourDateFormatter].locale = [NSLocale localeWithLocaleIdentifier:@"FR-fr"];
    
    // Vérification des formats
    
    // Cas 1 : précision de la date au jour
    XCTAssertEqualObjects(@"J", personnalite.dateDecesPrecision, @"");
    XCTAssertEqualObjects(@"3 juillet 1971", personnalite.dateDecesLongue, @"");
    
    // Cas 2 : précision de la date au mois
    personnalite.dateDecesPrecision = @"M";
    XCTAssertEqualObjects(@"juillet 1971", personnalite.dateDecesLongue, @"");
    
    // Cas 3 : précision de la date à l'année
    personnalite.dateDecesPrecision = @"A";
    XCTAssertEqualObjects(@"1971", personnalite.dateDecesLongue, @"");
    
    // Cas 4 : date nulle
    personnalite.dateDeces = nil;
    XCTAssertNil(personnalite.dateDecesLongue, @"");
    
    // Cas 5 : précision inconnue
    personnalite.dateDecesPrecision = @"K";
    XCTAssertThrows(personnalite.dateDecesLongue, @"");
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
    PLPersonnalite *personnalite = [monument.personnalites objectAtIndex:0];
    
    // Suppression du champ
    personnalite.id = nil;
    
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
    PLPersonnalite *personnalite = [monument.personnalites objectAtIndex:0];
    
    // Suppression du champ
    personnalite.nom = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
    
    // Mise à blanc du champ
    personnalite.nom = @"";
    
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
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    PLPersonnalite *personnalite = [monument.personnalites objectAtIndex:0];
    
    // Suppression du champ
    personnalite.codeWikipedia = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
    
    // Mise à blanc du champ
    personnalite.codeWikipedia = @"";
    
    // Vérification que la sauvegarde réussit
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas activité
- (void)testContraintesActivite
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
    PLPersonnalite *personnalite = [monument.personnalites objectAtIndex:0];
    
    // Suppression du champ
    personnalite.activite = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
    
    // Mise à blanc du champ
    personnalite.activite = @"";
    
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
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    PLPersonnalite *personnalite = [monument.personnalites objectAtIndex:0];
    
    // Suppression du champ
    personnalite.resume = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
    
    // Mise à blanc du champ
    personnalite.resume = @"";
    
    // Vérification que la sauvegarde réussit
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas date de naissance
- (void)testContraintesDateNaissance
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
    PLPersonnalite *personnalite = [monument.personnalites objectAtIndex:0];
    
    // Suppression du champ
    personnalite.dateNaissance = nil;
    
    // Vérification que la sauvegarde réussit
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas date de décès
- (void)testContraintesDateDeces
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
    PLPersonnalite *personnalite = [monument.personnalites objectAtIndex:0];
    
    // Suppression du champ
    personnalite.dateDeces = nil;
    
    // Vérification que la sauvegarde réussit
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas précision date de naissance
- (void)testContraintesDateNaissancePrecision
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
    PLPersonnalite *personnalite = [monument.personnalites objectAtIndex:0];
    
    // Suppression du champ
    personnalite.dateNaissancePrecision = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
    
    // Modification du champ
    personnalite.dateNaissancePrecision = @"";
    
    // Vérification que la sauvegarde échoue
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1680, error.code, @"");
    
    // Modification du champ
    personnalite.dateNaissancePrecision = @"DD";
    
    // Vérification que la sauvegarde échoue
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1680, error.code, @"");
    
    // Modification du champ
    personnalite.dateNaissancePrecision = @"K";
    
    // Vérification que la sauvegarde échoue
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1680, error.code, @"");
    
    // Modification du champ
    personnalite.dateNaissancePrecision = @"J";
    
    // Vérification que la sauvegarde réussit
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
    
    // Modification du champ
    personnalite.dateNaissancePrecision = @"M";
    
    // Vérification que la sauvegarde réussit
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
    
    // Modification du champ
    personnalite.dateNaissancePrecision = @"A";
    
    // Vérification que la sauvegarde réussit
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas précision date de décès
- (void)testContraintesDateDecesPrecision
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
    PLPersonnalite *personnalite = [monument.personnalites objectAtIndex:0];
    
    // Suppression du champ
    personnalite.dateDecesPrecision = nil;
    
    // Vérification que la sauvegarde échoue
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1570, error.code, @"");
    
    // Modification du champ
    personnalite.dateDecesPrecision = @"";
    
    // Vérification que la sauvegarde échoue
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1680, error.code, @"");
    
    // Modification du champ
    personnalite.dateDecesPrecision = @"DD";
    
    // Vérification que la sauvegarde échoue
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1680, error.code, @"");
    
    // Modification du champ
    personnalite.dateDecesPrecision = @"K";
    
    // Vérification que la sauvegarde échoue
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNotNil(error, @"");
    XCTAssertEqual(1680, error.code, @"");
    
    // Modification du champ
    personnalite.dateDecesPrecision = @"J";
    
    // Vérification que la sauvegarde réussit
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
    
    // Modification du champ
    personnalite.dateDecesPrecision = @"M";
    
    // Vérification que la sauvegarde réussit
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
    
    // Modification du champ
    personnalite.dateDecesPrecision = @"A";
    
    // Vérification que la sauvegarde réussit
    error = nil;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
}

// Vérifie que les contraintes de l'entité sont conformes ; cas monument not nil
- (void)testContraintesMonumentNotNil
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture 1
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    PLPersonnalite *personnalite = [monument.personnalites objectAtIndex:0];
    
    // Retrait de la personnalité du monument
    [monument removePersonnalitesObject:personnalite];
    
    XCTAssertNil(personnalite.monument, @"");
    
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
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument2_update2.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    PLPersonnalite *personnalite1 = [monument.personnalites objectAtIndex:0];
    PLPersonnalite *personnalite2 = [monument.personnalites objectAtIndex:1];
    
    // Suppression de la personnalité 1
    [managedObjectContext deleteObject:personnalite1];
    
    // Vérification que la sauvegarde réussit
    NSError *error;
    [managedObjectContext save:&error];
    XCTAssertNil(error, @"");
    
    // Vérification que la personnalité n'apparaît plus sur le monument (delete rule = Nullify)
    XCTAssertEqual(1, [monument.personnalites count], @"");
    XCTAssertEqualObjects(personnalite2, [monument.personnalites objectAtIndex:0], @"");
}

@end
