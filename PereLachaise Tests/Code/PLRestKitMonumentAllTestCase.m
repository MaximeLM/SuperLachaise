//
//  PLRestKitMonumentAllTestCase.m
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

#import <XCTest/XCTest.h>

#import "RestKit.h"
#import "Testing.h"

#import "PLRestKitConfiguration.h"
#import "PLRestKitMonumentAll.h"
#import "PLNodeOSM.h"
#import "PLPersonnalite.h"
#import "PLMonument.h"
#import "PLImageCommons.h"
#import "PLConfiguration.h"

// Classe de tests de la classe PLRestKitMonumentAll
@interface PLRestKitMonumentAllTestCase : XCTestCase

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation PLRestKitMonumentAllTestCase

- (void)setUp
{
    [super setUp];
    
    [RKTestFixture setFixtureBundle:[NSBundle bundleForClass:[self class]]];
    [RKTestFactory setUp];
    
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [self.dateFormatter setTimeZone:gmt];
}

- (void)tearDown
{
    [RKTestFactory tearDown];
    [super tearDown];
}

#pragma mark - Configuration du TestCase

// Vérifie que la méthode teardown supprime les objets stockés
- (void)testTearDown
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // On vérifie que les entités ont été insérées
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Teardown
    [self tearDown];
    
    // On vérifie que toutes les entités ont été supprimées
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
}

// Vérifie que les ressources du bundle de test sont accessibles
- (void)testBundle
{
    XCTAssertNotNil([RKTestFixture fixtureBundle],@"");
    
    // Read the contents of a fixture as a string
    NSString *JSONString = [RKTestFixture stringWithContentsOfFixture:@"nodeOSM1.json"];
    
    XCTAssertNotNil(JSONString, @"");
}

#pragma mark -

// Vérifie que les méthodes de fabrication d'objets renvoient un résultat
- (void)testFactoryMethodsNotNil
{
    XCTAssertNotNil([PLRestKitMonumentAll nodeOSMMapping], @"");
    XCTAssertNotNil([PLRestKitMonumentAll personnaliteMapping], @"");
    XCTAssertNotNil([PLRestKitMonumentAll monumentMapping], @"");
    XCTAssertNotNil([PLRestKitMonumentAll responseDescriptor], @"");
    XCTAssertNotNil([PLRestKitMonumentAll imageCommonsMapping], @"");
}

// Vérifie que le path pattern renvoie le résultat attendu
- (void)testPathPattern
{
    XCTAssertEqualObjects(@"monument/all/", [PLRestKitMonumentAll pathPattern], @"");
}

#pragma mark - nodeOSMMapping

// Vérifie que le mapping d'un node OSM donne le résultat attendu et l'enregistre
- (void)testNodeOSMMappingCreate1
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"nodeOSM1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll nodeOSMMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLNodeOSM *result = [mappingTest destinationObject];
    
    // Contrôle du résultat
    XCTAssertEqualObjects(@(2663325709), result.id, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"48.8601980"], result.latitude, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"2.3952770"], result.longitude, @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    
    // Récupération de l'objet enregistré
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLNodeOSM"];
    PLNodeOSM *fetchedObject = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    
    // Vérification que les objets correspondent
    XCTAssertEqualObjects(fetchedObject, result, @"");
}

// Vérifie que le mapping de 2 nodes OSM donne le résultat attendu et les enregistre
- (void)testNodeOSMMappingCreate2
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture 1
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"nodeOSM1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll nodeOSMMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLNodeOSM *result1 = [mappingTest destinationObject];
    
    // Chargement de la fixture 2
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"nodeOSM2.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll nodeOSMMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLNodeOSM *result2 = [mappingTest destinationObject];
    
    // Contrôle du résultat 1
    XCTAssertEqualObjects(@(2663325709), result1.id, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"48.8601980"], result1.latitude, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"2.3952770"], result1.longitude, @"");
    
    // Contrôle du résultat 2
    XCTAssertEqualObjects(@(1915793663), result2.id, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"48.8592676"], result2.latitude, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"2.3937520"], result2.longitude, @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    
    // Récupération de l'objet enregistré
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLNodeOSM"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]]];
    
    // Vérification que les objets correspondent
    PLNodeOSM *fetchedObject1 = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    XCTAssertEqualObjects(fetchedObject1, result1, @"");
    PLNodeOSM *fetchedObject2 = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:1];
    XCTAssertEqualObjects(fetchedObject2, result2, @"");
}

// Vérifie que le création puis la mise à jour d'un node OSM donne le résultat attendu
- (void)testNodeOSMMappingUpdate1
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture 1
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"nodeOSM1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll nodeOSMMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Chargement de la mise à jour de la fixture 1
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"nodeOSM1_update.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll nodeOSMMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLNodeOSM *result1_update = [mappingTest destinationObject];
    
    // Contrôle du résultat de la mise à jour
    XCTAssertEqualObjects(@(2663325709), result1_update.id, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"42.4"], result1_update.latitude, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"-42.4"], result1_update.longitude, @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    
    // Récupération de l'objet enregistré
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLNodeOSM"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]]];
    
    // Vérification que les objets correspondent
    PLNodeOSM *fetchedObject = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    XCTAssertEqualObjects(fetchedObject, result1_update, @"");
}

// Vérifie que la création de 2 nodes OSM puis la mise à jour du 2e donne le résultat attendu
- (void)testNodeOSMMappingUpdate2
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture 1
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"nodeOSM1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll nodeOSMMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLNodeOSM *result1 = [mappingTest destinationObject];
    
    // Chargement de la fixture 2
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"nodeOSM2.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll nodeOSMMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Chargement de la mise à jour de la fixture 2
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"nodeOSM2_update.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll nodeOSMMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLNodeOSM *result2_update = [mappingTest destinationObject];
    
    // Contrôle du résultat 1
    XCTAssertEqualObjects(@(2663325709), result1.id, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"48.8601980"], result1.latitude, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"2.3952770"], result1.longitude, @"");
    
    // Contrôle du résultat 2
    XCTAssertEqualObjects(@(1915793663), result2_update.id, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"42.48"], result2_update.latitude, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"0.0"], result2_update.longitude, @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    
    // Récupération de l'objet enregistré
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLNodeOSM"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]]];
    
    // Vérification que les objets correspondent
    PLNodeOSM *fetchedObject1 = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    XCTAssertEqualObjects(fetchedObject1, result1, @"");
    PLNodeOSM *fetchedObject2 = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:1];
    XCTAssertEqualObjects(fetchedObject2, result2_update, @"");
}

#pragma mark - personnaliteMapping

// Vérifie que le mapping d'une peronnalité donne le résultat attendu et l'enregistre
- (void)testPersonnaliteMappingCreate1
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"personnalite1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll personnaliteMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLPersonnalite *result = [mappingTest destinationObject];
    
    // Contrôle du résultat
    XCTAssertEqualObjects(@(120), result.id, @"");
    XCTAssertEqualObjects(@"Jim Morrison", result.nom, @"");
    XCTAssertEqualObjects(@"Jim Morrison", result.codeWikipedia, @"");
    XCTAssertEqualObjects(@"chanteur des Doors", result.activite, @"");
    XCTAssertEqualObjects(@"<p><dfn>Jim Morrison</dfn> (né <b>James Douglas Morrison</b> le <a href=\"/wiki/8_d%C3%A9cembre\">8</a>&#160;<a href=\"/wiki/D%C3%A9cembre_1943\">décembre</a>&#160;<a href=\"/wiki/1943_en_musique\">1943</a> à <a href=\"/wiki/Melbourne_(Floride)\">Melbourne</a> (<a href=\"/wiki/Floride\">Floride</a>) aux <a href=\"/wiki/%C3%89tats-Unis\">États-Unis</a>, et mort le <a href=\"/wiki/3_juillet\">3</a>&#160;<a href=\"/wiki/Juillet_1971\">juillet</a>&#160;<a href=\"/wiki/1971_en_musique\">1971</a> à <a href=\"/wiki/Paris\">Paris</a>, en <a href=\"/wiki/France\">France</a>) est un <a href=\"/wiki/Chanteur\">chanteur</a>, <a href=\"/wiki/Cin%C3%A9aste\">cinéaste</a> et <a href=\"/wiki/Po%C3%A8te\">poète</a> <a href=\"/wiki/%C3%89tats-Unis\">américain</a>, cofondateur du groupe de <a href=\"/wiki/Rock\">rock</a> américain <a href=\"/wiki/The_Doors\">The Doors</a>, dont il fut membre de 1965 à sa mort.</p>\n<p><a href=\"/wiki/Sex-symbol\">Sex-symbol</a> provocant au comportement volontairement excessif, devenu une véritable idole de la <a href=\"/wiki/Musique_rock\">musique rock</a>, mais aussi intellectuel engagé dans le mouvement du <a href=\"/wiki/Protest_song\">protest song</a>, en particulier contre la <a href=\"/wiki/Guerre_du_Vi%C3%AAt_Nam\">guerre du Viêt Nam</a>, attiré par le <a href=\"/wiki/Chamanisme\">chamanisme</a>, on lui attribue une réputation de «&#160;<a href=\"/wiki/Po%C3%A8te_maudit\">poète maudit</a>&#160;» que sa mort prématurée, à Paris, dans des circonstances mal élucidées, transforme en légende, notamment fondatrice de ce qui est connu sous le nom de <a href=\"/wiki/Club_des_27\">Club des 27</a>.</p>\n<p>Le culte que lui vouent ses fans éclipse cependant une œuvre poétique d'une grande richesse que Morrison lui-même a pu considérer comme sa principale activité, au moins à partir de l'été 1968.</p>", result.resume, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1943-12-08"], result.dateNaissance, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1971-07-03"], result.dateDeces, @"");
    XCTAssertEqualObjects(@"J", result.dateNaissancePrecision, @"");
    XCTAssertEqualObjects(@"J", result.dateDecesPrecision, @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    
    // Récupération de l'objet enregistré
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLPersonnalite"];
    PLPersonnalite *fetchedObject = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    
    // Vérification que les objets correspondent
    XCTAssertEqualObjects(fetchedObject, result, @"");
}

// Vérifie que le mapping de 2 personnalités donne le résultat attendu et les enregistre
- (void)testPersonnaliteMappingCreate2
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture 1
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"personnalite1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll personnaliteMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLPersonnalite *result1 = [mappingTest destinationObject];
    
    // Chargement de la fixture 2
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"personnalite2.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll personnaliteMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLPersonnalite *result2 = [mappingTest destinationObject];
    
    // Contrôle du résultat 1
    XCTAssertEqualObjects(@(120), result1.id, @"");
    XCTAssertEqualObjects(@"Jim Morrison", result1.nom, @"");
    XCTAssertEqualObjects(@"Jim Morrison", result1.codeWikipedia, @"");
    XCTAssertEqualObjects(@"chanteur des Doors", result1.activite, @"");
    XCTAssertEqualObjects(@"<p><dfn>Jim Morrison</dfn> (né <b>James Douglas Morrison</b> le <a href=\"/wiki/8_d%C3%A9cembre\">8</a>&#160;<a href=\"/wiki/D%C3%A9cembre_1943\">décembre</a>&#160;<a href=\"/wiki/1943_en_musique\">1943</a> à <a href=\"/wiki/Melbourne_(Floride)\">Melbourne</a> (<a href=\"/wiki/Floride\">Floride</a>) aux <a href=\"/wiki/%C3%89tats-Unis\">États-Unis</a>, et mort le <a href=\"/wiki/3_juillet\">3</a>&#160;<a href=\"/wiki/Juillet_1971\">juillet</a>&#160;<a href=\"/wiki/1971_en_musique\">1971</a> à <a href=\"/wiki/Paris\">Paris</a>, en <a href=\"/wiki/France\">France</a>) est un <a href=\"/wiki/Chanteur\">chanteur</a>, <a href=\"/wiki/Cin%C3%A9aste\">cinéaste</a> et <a href=\"/wiki/Po%C3%A8te\">poète</a> <a href=\"/wiki/%C3%89tats-Unis\">américain</a>, cofondateur du groupe de <a href=\"/wiki/Rock\">rock</a> américain <a href=\"/wiki/The_Doors\">The Doors</a>, dont il fut membre de 1965 à sa mort.</p>\n<p><a href=\"/wiki/Sex-symbol\">Sex-symbol</a> provocant au comportement volontairement excessif, devenu une véritable idole de la <a href=\"/wiki/Musique_rock\">musique rock</a>, mais aussi intellectuel engagé dans le mouvement du <a href=\"/wiki/Protest_song\">protest song</a>, en particulier contre la <a href=\"/wiki/Guerre_du_Vi%C3%AAt_Nam\">guerre du Viêt Nam</a>, attiré par le <a href=\"/wiki/Chamanisme\">chamanisme</a>, on lui attribue une réputation de «&#160;<a href=\"/wiki/Po%C3%A8te_maudit\">poète maudit</a>&#160;» que sa mort prématurée, à Paris, dans des circonstances mal élucidées, transforme en légende, notamment fondatrice de ce qui est connu sous le nom de <a href=\"/wiki/Club_des_27\">Club des 27</a>.</p>\n<p>Le culte que lui vouent ses fans éclipse cependant une œuvre poétique d'une grande richesse que Morrison lui-même a pu considérer comme sa principale activité, au moins à partir de l'été 1968.</p>", result1.resume, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1943-12-08"], result1.dateNaissance, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1971-07-03"], result1.dateDeces, @"");
    XCTAssertEqualObjects(@"J", result1.dateNaissancePrecision, @"");
    XCTAssertEqualObjects(@"J", result1.dateDecesPrecision, @"");
    
    // Contrôle du résultat 2
    XCTAssertEqualObjects(@(194), result2.id, @"");
    XCTAssertEqualObjects(@"Téo Hernandez", result2.nom, @"");
    XCTAssertEqualObjects(@"", result2.codeWikipedia, @"");
    XCTAssertEqualObjects(@"", result2.activite, @"");
    XCTAssertEqualObjects(@"", result2.resume, @"");
    XCTAssertEqualObjects(nil, result2.dateNaissance, @"");
    XCTAssertEqualObjects(nil, result2.dateDeces, @"");
    XCTAssertEqualObjects(@"J", result2.dateNaissancePrecision, @"");
    XCTAssertEqualObjects(@"A", result2.dateDecesPrecision, @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    
    // Récupération de l'objet enregistré
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLPersonnalite"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]]];
    
    // Vérification que les objets correspondent
    PLPersonnalite *fetchedObject1 = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    XCTAssertEqualObjects(fetchedObject1, result1, @"");
    PLPersonnalite *fetchedObject2 = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:1];
    XCTAssertEqualObjects(fetchedObject2, result2, @"");
}

// Vérifie que le création puis la mise à jour d'une personnalité donne le résultat attendu
- (void)testPersonnaliteMappingUpdate1
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture 1
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"personnalite1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll personnaliteMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Chargement de la mise à jour de la fixture 1
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"personnalite1_update.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll personnaliteMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLPersonnalite *result1_update = [mappingTest destinationObject];
    
    // Contrôle du résultat de la mise à jour
    XCTAssertEqualObjects(@(120), result1_update.id, @"");
    XCTAssertEqualObjects(@"Jim Morrison ü", result1_update.nom, @"");
    XCTAssertEqualObjects(@"Jim Morrison", result1_update.codeWikipedia, @"");
    XCTAssertEqualObjects(@"Activité", result1_update.activite, @"");
    XCTAssertEqualObjects(@"Résumé çê", result1_update.resume, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1943-12-08"], result1_update.dateNaissance, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1971-07-03"], result1_update.dateDeces, @"");
    XCTAssertEqualObjects(@"J", result1_update.dateNaissancePrecision, @"");
    XCTAssertEqualObjects(@"J", result1_update.dateDecesPrecision, @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    
    // Récupération de l'objet enregistré
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLPersonnalite"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]]];
    
    // Vérification que les objets correspondent
    PLPersonnalite *fetchedObject = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    XCTAssertEqualObjects(fetchedObject, result1_update, @"");
}

// Vérifie que la création de 2 personnalités puis la mise à jour de la 2e donne le résultat attendu
- (void)testPersonnaliteMappingUpdate2
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture 1
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"personnalite1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll personnaliteMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLPersonnalite *result1 = [mappingTest destinationObject];
    
    // Chargement de la fixture 2
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"personnalite2.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll personnaliteMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Chargement de la mise à jour de la fixture 2
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"personnalite2_update.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll personnaliteMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLPersonnalite *result2_update = [mappingTest destinationObject];
    
    // Contrôle du résultat 1
    XCTAssertEqualObjects(@(120), result1.id, @"");
    XCTAssertEqualObjects(@"Jim Morrison", result1.nom, @"");
    XCTAssertEqualObjects(@"Jim Morrison", result1.codeWikipedia, @"");
    XCTAssertEqualObjects(@"chanteur des Doors", result1.activite, @"");
    XCTAssertEqualObjects(@"<p><dfn>Jim Morrison</dfn> (né <b>James Douglas Morrison</b> le <a href=\"/wiki/8_d%C3%A9cembre\">8</a>&#160;<a href=\"/wiki/D%C3%A9cembre_1943\">décembre</a>&#160;<a href=\"/wiki/1943_en_musique\">1943</a> à <a href=\"/wiki/Melbourne_(Floride)\">Melbourne</a> (<a href=\"/wiki/Floride\">Floride</a>) aux <a href=\"/wiki/%C3%89tats-Unis\">États-Unis</a>, et mort le <a href=\"/wiki/3_juillet\">3</a>&#160;<a href=\"/wiki/Juillet_1971\">juillet</a>&#160;<a href=\"/wiki/1971_en_musique\">1971</a> à <a href=\"/wiki/Paris\">Paris</a>, en <a href=\"/wiki/France\">France</a>) est un <a href=\"/wiki/Chanteur\">chanteur</a>, <a href=\"/wiki/Cin%C3%A9aste\">cinéaste</a> et <a href=\"/wiki/Po%C3%A8te\">poète</a> <a href=\"/wiki/%C3%89tats-Unis\">américain</a>, cofondateur du groupe de <a href=\"/wiki/Rock\">rock</a> américain <a href=\"/wiki/The_Doors\">The Doors</a>, dont il fut membre de 1965 à sa mort.</p>\n<p><a href=\"/wiki/Sex-symbol\">Sex-symbol</a> provocant au comportement volontairement excessif, devenu une véritable idole de la <a href=\"/wiki/Musique_rock\">musique rock</a>, mais aussi intellectuel engagé dans le mouvement du <a href=\"/wiki/Protest_song\">protest song</a>, en particulier contre la <a href=\"/wiki/Guerre_du_Vi%C3%AAt_Nam\">guerre du Viêt Nam</a>, attiré par le <a href=\"/wiki/Chamanisme\">chamanisme</a>, on lui attribue une réputation de «&#160;<a href=\"/wiki/Po%C3%A8te_maudit\">poète maudit</a>&#160;» que sa mort prématurée, à Paris, dans des circonstances mal élucidées, transforme en légende, notamment fondatrice de ce qui est connu sous le nom de <a href=\"/wiki/Club_des_27\">Club des 27</a>.</p>\n<p>Le culte que lui vouent ses fans éclipse cependant une œuvre poétique d'une grande richesse que Morrison lui-même a pu considérer comme sa principale activité, au moins à partir de l'été 1968.</p>", result1.resume, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1943-12-08"], result1.dateNaissance, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1971-07-03"], result1.dateDeces, @"");
    XCTAssertEqualObjects(@"J", result1.dateNaissancePrecision, @"");
    XCTAssertEqualObjects(@"J", result1.dateDecesPrecision, @"");
    
    // Contrôle du résultat 2
    XCTAssertEqualObjects(@(194), result2_update.id, @"");
    XCTAssertEqualObjects(@"Téo Hernandez", result2_update.nom, @"");
    XCTAssertEqualObjects(@"", result2_update.codeWikipedia, @"");
    XCTAssertEqualObjects(@"cinéaste", result2_update.activite, @"");
    XCTAssertEqualObjects(@"", result2_update.resume, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1939-12-23"], result2_update.dateNaissance, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1992-01-01"], result2_update.dateDeces, @"");
    XCTAssertEqualObjects(@"J", result2_update.dateNaissancePrecision, @"");
    XCTAssertEqualObjects(@"A", result2_update.dateDecesPrecision, @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    
    // Récupération de l'objet enregistré
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLPersonnalite"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]]];
    
    // Vérification que les objets correspondent
    PLPersonnalite *fetchedObject1 = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    XCTAssertEqualObjects(fetchedObject1, result1, @"");
    PLPersonnalite *fetchedObject2 = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:1];
    XCTAssertEqualObjects(fetchedObject2, result2_update, @"");
}

#pragma mark - monumentMapping

// Vérifie que le mapping d'un monument donne le résultat attendu et l'enregistre
- (void)testMonumentMappingCreate1
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Commit pour obtenir les propriétés dérivées
    [managedObjectContext save:nil];
    
    // Récupération du résultat
    PLMonument *monument = [mappingTest destinationObject];
    
    // Contrôle du résultat
    XCTAssertEqualObjects(@(164), monument.id, @"");
    XCTAssertEqualObjects(@"Mur des Fédérés", monument.nom, @"");
    XCTAssertEqualObjects(@"Mur des Fédérés", monument.nomPourTri, @"");
    XCTAssertEqualObjects(@"M", monument.premiereLettreNomPourTri, @"");
    XCTAssertEqualObjects(@"Mur des Fédérés", monument.codeWikipedia, @"");
    XCTAssertEqualObjects(@"<p>Le <b>mur des Fédérés</b> est une partie de l'enceinte du <a href=\"/wiki/Cimeti%C3%A8re_du_P%C3%A8re-Lachaise\">cimetière du Père-Lachaise</a>, à <a href=\"/wiki/Paris\">Paris</a>, devant laquelle, le <a href=\"/wiki/28_mai\">28</a>&#160;<a href=\"/wiki/Mai_1871\">mai</a>&#160;<a href=\"/wiki/1871\">1871</a>, cent quarante-sept Fédérés, combattants de la <a href=\"/wiki/Commune_de_Paris_(1871)\">Commune</a>, ont été fusillés et jetés dans une fosse ouverte au pied du mur par les Versaillais. Depuis lors, il symbolise la lutte pour la liberté et les idéaux des <a href=\"/wiki/Communard\">communards</a>, <a href=\"/wiki/Autogestion\">autogestionnaires</a>.</p>\n<p>Le mur est à l'angle sud-est du cimetière.</p>", monument.resume, @"");
    
    // Récupération du node OSM
    PLNodeOSM *nodeOSM = monument.nodeOSM;
    XCTAssertNotNil(nodeOSM, @"");
    
    // Contrôle du node OSM
    XCTAssertEqualObjects(@(1152422864), nodeOSM.id, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"48.8597013"], nodeOSM.latitude, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"2.4000175"], nodeOSM.longitude, @"");
    
    // Récupération de l'image Commons
    PLImageCommons *imageCommons = monument.imagePrincipale;
    XCTAssertNotNil(imageCommons, @"");
    
    // Contrôle de l'image principale
    XCTAssertEqualObjects(@(200), imageCommons.id, @"");
    XCTAssertEqualObjects(@"Dayofmayofday", imageCommons.auteur, @"");
    XCTAssertEqualObjects(@"CC0", imageCommons.licence, @"");
    XCTAssertEqualObjects(@"http://upload.wikimedia.org/wikipedia/commons/a/ab/Commune2011.jpg", imageCommons.urlOriginal, @"");
    
    // Récupération des personnalités
    NSOrderedSet *personnalites = monument.personnalites;
    XCTAssertEqual(1, [personnalites count], @"");
    PLPersonnalite *personnalite1 = [personnalites objectAtIndex:0];
    XCTAssertNotNil(personnalite1, @"");
    
    // Contrôle de la personnalité
    XCTAssertEqualObjects(@(207), personnalite1.id, @"");
    XCTAssertEqualObjects(@"Alain Bashung", personnalite1.nom, @"");
    XCTAssertEqualObjects(@"Alain Bashung", personnalite1.codeWikipedia, @"");
    XCTAssertEqualObjects(@"chanteur français", personnalite1.activite, @"");
    XCTAssertEqualObjects(@"<p><b>Alain Bashung</b>, né <b>Alain Baschung</b> (Paris,&#160;<a href=\"/wiki/1er_d%C3%A9cembre\">1<sup>er</sup></a>&#160;<a href=\"/wiki/D%C3%A9cembre_1947\">décembre</a>&#160;<a href=\"/wiki/1947\">1947</a> – Paris,&#160;<a href=\"/wiki/14_mars\">14</a>&#160;<a href=\"/wiki/Mars_2009\">mars</a>&#160;<a href=\"/wiki/2009\">2009</a>), est un <a href=\"/wiki/Auteur-compositeur-interpr%C3%A8te\">auteur-compositeur-interprète</a> et comédien <a href=\"/wiki/France\">français</a>. Il est devenu une figure importante de la <a href=\"/wiki/Chanson_fran%C3%A7aise\">chanson</a> et du <a href=\"/wiki/Rock_fran%C3%A7ais\">rock français</a> à partir du début des <a href=\"/wiki/Ann%C3%A9es_1980\">années 1980</a> et a influencé un grand nombre de chanteurs de la nouvelle scène française. Il est le chanteur le plus primé aux <a href=\"/wiki/Victoires_de_la_musique\">Victoires de la musique</a> avec 12 victoires obtenues tout au long de sa carrière.</p>", personnalite1.resume, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1947-12-01"], personnalite1.dateNaissance, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"2009-03-14"], personnalite1.dateDeces, @"");
    XCTAssertEqualObjects(@"J", personnalite1.dateNaissancePrecision, @"");
    XCTAssertEqualObjects(@"J", personnalite1.dateDecesPrecision, @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    PLMonument *fetchedMonument = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLNodeOSM"];
    PLNodeOSM *fetchedNodeOSM = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLPersonnalite"];
    PLPersonnalite *fetchedPersonnalite = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLImageCommons"];
    PLImageCommons *fetchedImageCommons = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    
    // Vérification que les objets correspondent
    XCTAssertEqualObjects(fetchedMonument, monument, @"");
    XCTAssertEqualObjects(fetchedNodeOSM, nodeOSM, @"");
    XCTAssertEqualObjects(fetchedPersonnalite, personnalite1, @"");
    XCTAssertEqualObjects(fetchedImageCommons, imageCommons, @"");
}

// Vérifie que le création puis la mise à jour d'un monument donne le résultat attendu
- (void)testMonumentMappingUpdate1
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture 1
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Chargement de la mise à jour de la fixture 1
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument1_update.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Commit pour obtenir les propriétés dérivées
    [managedObjectContext save:nil];
    
    // Récupération du résultat
    PLMonument *monument1_update = [mappingTest destinationObject];
    
    // Contrôle du résultat de la mise à jour
    XCTAssertEqualObjects(@(164), monument1_update.id, @"");
    XCTAssertEqualObjects(@"Mur des Fédérés", monument1_update.nom, @"");
    XCTAssertEqualObjects(@"Mur des Fédérés", monument1_update.nomPourTri, @"");
    XCTAssertEqualObjects(@"M", monument1_update.premiereLettreNomPourTri, @"");
    XCTAssertEqualObjects(@"Mur des Fédérés", monument1_update.codeWikipedia, @"");
    XCTAssertEqualObjects(@"<p>Le <b>mur des Fédérés</b> est une partie de l'enceinte du <a href=\"/wiki/Cimeti%C3%A8re_du_P%C3%A8re-Lachaise\">cimetière du Père-Lachaise</a>, à <a href=\"/wiki/Paris\">Paris</a>, devant laquelle, le <a href=\"/wiki/28_mai\">28</a>&#160;<a href=\"/wiki/Mai_1871\">mai</a>&#160;<a href=\"/wiki/1871\">1871</a>, cent quarante-sept Fédérés, combattants de la <a href=\"/wiki/Commune_de_Paris_(1871)\">Commune</a>, ont été fusillés et jetés dans une fosse ouverte au pied du mur par les Versaillais. Depuis lors, il symbolise la lutte pour la liberté et les idéaux des <a href=\"/wiki/Communard\">communards</a>, <a href=\"/wiki/Autogestion\">autogestionnaires</a>.</p>\n<p>Le mur est à l'angle sud-est du cimetière.</p>", monument1_update.resume, @"");
    
    // Récupération du node OSM
    PLNodeOSM *nodeOSM = monument1_update.nodeOSM;
    XCTAssertNotNil(nodeOSM, @"");
    
    // Contrôle du node OSM
    XCTAssertEqualObjects(@(1152422864), nodeOSM.id, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"42.4"], nodeOSM.latitude, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"-42.4"], nodeOSM.longitude, @"");
    
    // Vérification de l'absence d'image principale
    XCTAssertNil(monument1_update.imagePrincipale, @"");
    
    // Récupération des personnalités
    NSOrderedSet *personnalites = monument1_update.personnalites;
    XCTAssertEqual(1, [personnalites count], @"");
    PLPersonnalite *personnalite1 = [personnalites objectAtIndex:0];
    XCTAssertNotNil(personnalite1, @"");
    
    // Contrôle de la personnalité
    XCTAssertEqualObjects(@(76), personnalite1.id, @"");
    XCTAssertEqualObjects(@"Georges Courteline", personnalite1.nom, @"");
    XCTAssertEqualObjects(@"Georges Courteline", personnalite1.codeWikipedia, @"");
    XCTAssertEqualObjects(@"Dramaturge français", personnalite1.activite, @"");
    XCTAssertEqualObjects(@"<p><b>Georges Courteline</b>, nom de plume de <b>Georges Victor Marcel Moinaux</b> ou <b>Moineau</b>, est un <a href=\"/wiki/Roman_(litt%C3%A9rature)\">romancier</a> et <a href=\"/wiki/Dramaturge\">dramaturge</a> français, né le <a href=\"/wiki/25_juin\">25</a>&#160;<a href=\"/wiki/Juin_1858\">juin</a>&#160;<a href=\"/wiki/1858\">1858</a> à <a href=\"/wiki/Tours\">Tours</a>, mort le <a href=\"/wiki/25_juin\">25</a>&#160;<a href=\"/wiki/Juin_1929\">juin</a>&#160;<a href=\"/wiki/1929\">1929</a> à <a href=\"/wiki/Paris\">Paris</a>.</p>", personnalite1.resume, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1858-06-25"], personnalite1.dateNaissance, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1929-06-25"], personnalite1.dateDeces, @"");
    XCTAssertEqualObjects(@"J", personnalite1.dateNaissancePrecision, @"");
    XCTAssertEqualObjects(@"J", personnalite1.dateDecesPrecision, @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    PLMonument *fetchedMonument = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLNodeOSM"];
    PLNodeOSM *fetchedNodeOSM = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLPersonnalite"];
    PLPersonnalite *fetchedPersonnalite = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    
    // Vérification que les objets correspondent
    XCTAssertEqualObjects(fetchedMonument, monument1_update, @"");
    XCTAssertEqualObjects(fetchedNodeOSM, nodeOSM, @"");
    XCTAssertEqualObjects(fetchedPersonnalite, personnalite1, @"");
}

// Vérifie que le mapping de 2 monuments donne le résultat attendu et les enregistre
- (void)testMonumentMappingCreate2
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
    PLMonument *monument1 = [mappingTest destinationObject];
    
    // Chargement de la fixture 2
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument2.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Commit pour obtenir les propriétés dérivées
    [managedObjectContext save:nil];
    
    // Récupération du résultat
    PLMonument *monument2 = [mappingTest destinationObject];
    
    // Contrôle du résultat 1
    XCTAssertEqualObjects(@(164), monument1.id, @"");
    XCTAssertEqualObjects(@"Mur des Fédérés", monument1.nom, @"");
    XCTAssertEqualObjects(@"Mur des Fédérés", monument1.nomPourTri, @"");
    XCTAssertEqualObjects(@"M", monument1.premiereLettreNomPourTri, @"");
    XCTAssertEqualObjects(@"Mur des Fédérés", monument1.codeWikipedia, @"");
    XCTAssertEqualObjects(@"<p>Le <b>mur des Fédérés</b> est une partie de l'enceinte du <a href=\"/wiki/Cimeti%C3%A8re_du_P%C3%A8re-Lachaise\">cimetière du Père-Lachaise</a>, à <a href=\"/wiki/Paris\">Paris</a>, devant laquelle, le <a href=\"/wiki/28_mai\">28</a>&#160;<a href=\"/wiki/Mai_1871\">mai</a>&#160;<a href=\"/wiki/1871\">1871</a>, cent quarante-sept Fédérés, combattants de la <a href=\"/wiki/Commune_de_Paris_(1871)\">Commune</a>, ont été fusillés et jetés dans une fosse ouverte au pied du mur par les Versaillais. Depuis lors, il symbolise la lutte pour la liberté et les idéaux des <a href=\"/wiki/Communard\">communards</a>, <a href=\"/wiki/Autogestion\">autogestionnaires</a>.</p>\n<p>Le mur est à l'angle sud-est du cimetière.</p>", monument1.resume, @"");
    
    // Récupération du node OSM
    PLNodeOSM *nodeOSM1 = monument1.nodeOSM;
    XCTAssertNotNil(nodeOSM1, @"");
    
    // Contrôle du node OSM
    XCTAssertEqualObjects(@(1152422864), nodeOSM1.id, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"48.8597013"], nodeOSM1.latitude, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"2.4000175"], nodeOSM1.longitude, @"");
    
    // Récupération de l'image Commons
    PLImageCommons *imageCommons1 = monument1.imagePrincipale;
    XCTAssertNotNil(imageCommons1, @"");
    
    // Contrôle de l'image Commons
    XCTAssertEqualObjects(@(200), imageCommons1.id, @"");
    XCTAssertEqualObjects(@"Dayofmayofday", imageCommons1.auteur, @"");
    XCTAssertEqualObjects(@"CC0", imageCommons1.licence, @"");
    XCTAssertEqualObjects(@"http://upload.wikimedia.org/wikipedia/commons/a/ab/Commune2011.jpg", imageCommons1.urlOriginal, @"");
    
    // Récupération des personnalités
    NSOrderedSet *personnalites1 = monument1.personnalites;
    XCTAssertEqual(1, [personnalites1 count], @"");
    PLPersonnalite *personnalite1 = [personnalites1 objectAtIndex:0];
    XCTAssertNotNil(personnalite1, @"");
    
    // Contrôle de la personnalité
    XCTAssertEqualObjects(@(207), personnalite1.id, @"");
    XCTAssertEqualObjects(@"Alain Bashung", personnalite1.nom, @"");
    XCTAssertEqualObjects(@"Alain Bashung", personnalite1.codeWikipedia, @"");
    XCTAssertEqualObjects(@"chanteur français", personnalite1.activite, @"");
    XCTAssertEqualObjects(@"<p><b>Alain Bashung</b>, né <b>Alain Baschung</b> (Paris,&#160;<a href=\"/wiki/1er_d%C3%A9cembre\">1<sup>er</sup></a>&#160;<a href=\"/wiki/D%C3%A9cembre_1947\">décembre</a>&#160;<a href=\"/wiki/1947\">1947</a> – Paris,&#160;<a href=\"/wiki/14_mars\">14</a>&#160;<a href=\"/wiki/Mars_2009\">mars</a>&#160;<a href=\"/wiki/2009\">2009</a>), est un <a href=\"/wiki/Auteur-compositeur-interpr%C3%A8te\">auteur-compositeur-interprète</a> et comédien <a href=\"/wiki/France\">français</a>. Il est devenu une figure importante de la <a href=\"/wiki/Chanson_fran%C3%A7aise\">chanson</a> et du <a href=\"/wiki/Rock_fran%C3%A7ais\">rock français</a> à partir du début des <a href=\"/wiki/Ann%C3%A9es_1980\">années 1980</a> et a influencé un grand nombre de chanteurs de la nouvelle scène française. Il est le chanteur le plus primé aux <a href=\"/wiki/Victoires_de_la_musique\">Victoires de la musique</a> avec 12 victoires obtenues tout au long de sa carrière.</p>", personnalite1.resume, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1947-12-01"], personnalite1.dateNaissance, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"2009-03-14"], personnalite1.dateDeces, @"");
    XCTAssertEqualObjects(@"J", personnalite1.dateNaissancePrecision, @"");
    XCTAssertEqualObjects(@"J", personnalite1.dateDecesPrecision, @"");
    
    // Contrôle du résultat 2
    XCTAssertEqualObjects(@(120), monument2.id, @"");
    XCTAssertEqualObjects(@"Jim Morrison", monument2.nom, @"");
    XCTAssertEqualObjects(@"Morrison", monument2.nomPourTri, @"");
    XCTAssertEqualObjects(@"M", monument2.premiereLettreNomPourTri, @"");
    XCTAssertEqualObjects(@"", monument2.codeWikipedia, @"");
    XCTAssertEqualObjects(@"", monument2.resume, @"");
    
    // Récupération du node OSM
    PLNodeOSM *nodeOSM2 = monument2.nodeOSM;
    XCTAssertNotNil(nodeOSM2, @"");
    
    // Contrôle du node OSM
    XCTAssertEqualObjects(@(1915793663), nodeOSM2.id, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"48.8592676"], nodeOSM2.latitude, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"2.3937520"], nodeOSM2.longitude, @"");
    
    // Vérification de l'absence d'image commons
    XCTAssertNil(monument2.imagePrincipale, @"");
    
    // Récupération des personnalités
    NSOrderedSet *personnalites2 = monument2.personnalites;
    XCTAssertEqual(0, [personnalites2 count], @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLNodeOSM"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]]];
    NSArray *fetchedNodeOSMs = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLPersonnalite"];
    PLPersonnalite *fetchedPersonnalite = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLImageCommons"];
    PLImageCommons *fetchedImageCommons = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    
    // Vérification que les objets correspondent
    XCTAssertEqualObjects([fetchedMonuments objectAtIndex:0], monument1, @"");
    XCTAssertEqualObjects([fetchedMonuments objectAtIndex:1], monument2, @"");
    XCTAssertEqualObjects([fetchedNodeOSMs objectAtIndex:0], nodeOSM1, @"");
    XCTAssertEqualObjects([fetchedNodeOSMs objectAtIndex:1], nodeOSM2, @"");
    XCTAssertEqualObjects(fetchedPersonnalite, personnalite1, @"");
    XCTAssertEqualObjects(fetchedImageCommons, imageCommons1, @"");
}

// Vérifie que la création de 2 monuments puis la mise à jour du 2e donne le résultat attendu
- (void)testMonumentMappingUpdate2
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
    PLMonument *monument1 = [mappingTest destinationObject];
    
    // Chargement de la fixture 2
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument2.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Chargement de la mise à jour de la fixture 2
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument2_update1.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Commit pour obtenir les propriétés dérivées
    [managedObjectContext save:nil];
    
    // Récupération du résultat
    PLMonument *monument2_update = [mappingTest destinationObject];
    
    // Contrôle du résultat 1
    XCTAssertEqualObjects(@(164), monument1.id, @"");
    XCTAssertEqualObjects(@"Mur des Fédérés", monument1.nom, @"");
    XCTAssertEqualObjects(@"Mur des Fédérés", monument1.nomPourTri, @"");
    XCTAssertEqualObjects(@"M", monument1.premiereLettreNomPourTri, @"");
    XCTAssertEqualObjects(@"Mur des Fédérés", monument1.codeWikipedia, @"");
    XCTAssertEqualObjects(@"<p>Le <b>mur des Fédérés</b> est une partie de l'enceinte du <a href=\"/wiki/Cimeti%C3%A8re_du_P%C3%A8re-Lachaise\">cimetière du Père-Lachaise</a>, à <a href=\"/wiki/Paris\">Paris</a>, devant laquelle, le <a href=\"/wiki/28_mai\">28</a>&#160;<a href=\"/wiki/Mai_1871\">mai</a>&#160;<a href=\"/wiki/1871\">1871</a>, cent quarante-sept Fédérés, combattants de la <a href=\"/wiki/Commune_de_Paris_(1871)\">Commune</a>, ont été fusillés et jetés dans une fosse ouverte au pied du mur par les Versaillais. Depuis lors, il symbolise la lutte pour la liberté et les idéaux des <a href=\"/wiki/Communard\">communards</a>, <a href=\"/wiki/Autogestion\">autogestionnaires</a>.</p>\n<p>Le mur est à l'angle sud-est du cimetière.</p>", monument1.resume, @"");
    
    // Récupération du node OSM
    PLNodeOSM *nodeOSM1 = monument1.nodeOSM;
    XCTAssertNotNil(nodeOSM1, @"");
    
    // Contrôle du node OSM
    XCTAssertEqualObjects(@(1152422864), nodeOSM1.id, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"48.8597013"], nodeOSM1.latitude, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"2.4000175"], nodeOSM1.longitude, @"");
    
    // Récupération de l'image Commons
    PLImageCommons *imageCommons1 = monument1.imagePrincipale;
    XCTAssertNotNil(imageCommons1, @"");
    
    // Contrôle de l'image Commons
    XCTAssertEqualObjects(@(200), imageCommons1.id, @"");
    XCTAssertEqualObjects(@"Commune2011.jpg", imageCommons1.nom, @"");
    XCTAssertEqualObjects(@"Dayofmayofday", imageCommons1.auteur, @"");
    XCTAssertEqualObjects(@"CC0", imageCommons1.licence, @"");
    XCTAssertEqualObjects(@"http://upload.wikimedia.org/wikipedia/commons/a/ab/Commune2011.jpg", imageCommons1.urlOriginal, @"");
    
    // Récupération des personnalités
    NSOrderedSet *personnalites1 = monument1.personnalites;
    XCTAssertEqual(1, [personnalites1 count], @"");
    PLPersonnalite *personnalite1 = [personnalites1 objectAtIndex:0];
    XCTAssertNotNil(personnalite1, @"");
    
    // Contrôle de la personnalité
    XCTAssertEqualObjects(@(207), personnalite1.id, @"");
    XCTAssertEqualObjects(@"Alain Bashung", personnalite1.nom, @"");
    XCTAssertEqualObjects(@"Alain Bashung", personnalite1.codeWikipedia, @"");
    XCTAssertEqualObjects(@"chanteur français", personnalite1.activite, @"");
    XCTAssertEqualObjects(@"<p><b>Alain Bashung</b>, né <b>Alain Baschung</b> (Paris,&#160;<a href=\"/wiki/1er_d%C3%A9cembre\">1<sup>er</sup></a>&#160;<a href=\"/wiki/D%C3%A9cembre_1947\">décembre</a>&#160;<a href=\"/wiki/1947\">1947</a> – Paris,&#160;<a href=\"/wiki/14_mars\">14</a>&#160;<a href=\"/wiki/Mars_2009\">mars</a>&#160;<a href=\"/wiki/2009\">2009</a>), est un <a href=\"/wiki/Auteur-compositeur-interpr%C3%A8te\">auteur-compositeur-interprète</a> et comédien <a href=\"/wiki/France\">français</a>. Il est devenu une figure importante de la <a href=\"/wiki/Chanson_fran%C3%A7aise\">chanson</a> et du <a href=\"/wiki/Rock_fran%C3%A7ais\">rock français</a> à partir du début des <a href=\"/wiki/Ann%C3%A9es_1980\">années 1980</a> et a influencé un grand nombre de chanteurs de la nouvelle scène française. Il est le chanteur le plus primé aux <a href=\"/wiki/Victoires_de_la_musique\">Victoires de la musique</a> avec 12 victoires obtenues tout au long de sa carrière.</p>", personnalite1.resume, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1947-12-01"], personnalite1.dateNaissance, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"2009-03-14"], personnalite1.dateDeces, @"");
    XCTAssertEqualObjects(@"J", personnalite1.dateNaissancePrecision, @"");
    XCTAssertEqualObjects(@"J", personnalite1.dateDecesPrecision, @"");
    
    // Contrôle du résultat 2
    XCTAssertEqualObjects(@(120), monument2_update.id, @"");
    XCTAssertEqualObjects(@"Jim Morrison", monument2_update.nom, @"");
    XCTAssertEqualObjects(@"Morrison", monument2_update.nomPourTri, @"");
    XCTAssertEqualObjects(@"M", monument2_update.premiereLettreNomPourTri, @"");
    XCTAssertEqualObjects(@"", monument2_update.codeWikipedia, @"");
    XCTAssertEqualObjects(@"", monument2_update.resume, @"");
    
    // Récupération du node OSM
    PLNodeOSM *nodeOSM2 = monument2_update.nodeOSM;
    XCTAssertNotNil(nodeOSM2, @"");
    
    // Contrôle du node OSM
    XCTAssertEqualObjects(@(2661217171), nodeOSM2.id, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"48.8605650"], nodeOSM2.latitude, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"2.3950620"], nodeOSM2.longitude, @"");
    
    // Récupération de l'image Commons
    PLImageCommons *imageCommons2 = monument2_update.imagePrincipale;
    XCTAssertNotNil(imageCommons2, @"");
    
    // Contrôle de l'image Commons
    XCTAssertEqualObjects(@(129), imageCommons2.id, @"");
    XCTAssertEqualObjects(@"test_nom", imageCommons2.nom, @"");
    XCTAssertEqualObjects(@"test_auteur", imageCommons2.auteur, @"");
    XCTAssertEqualObjects(@"test_licence", imageCommons2.licence, @"");
    XCTAssertEqualObjects(@"test_url_original", imageCommons2.urlOriginal, @"");
    
    // Récupération des personnalités
    NSOrderedSet *personnalites2 = monument2_update.personnalites;
    XCTAssertEqual(1, [personnalites2 count], @"");
    PLPersonnalite *personnalite2 = [personnalites2 objectAtIndex:0];
    XCTAssertNotNil(personnalite2, @"");
    
    // Contrôle de la personnalité
    XCTAssertEqualObjects(@(120), personnalite2.id, @"");
    XCTAssertEqualObjects(@"Jim Morrison", personnalite2.nom, @"");
    XCTAssertEqualObjects(@"Jim Morrison", personnalite2.codeWikipedia, @"");
    XCTAssertEqualObjects(@"chanteur des Doors", personnalite2.activite, @"");
    XCTAssertEqualObjects(@"<p><dfn>Jim Morrison</dfn> (né <b>James Douglas Morrison</b> le <a href=\"/wiki/8_d%C3%A9cembre\">8</a>&#160;<a href=\"/wiki/D%C3%A9cembre_1943\">décembre</a>&#160;<a href=\"/wiki/1943_en_musique\">1943</a> à <a href=\"/wiki/Melbourne_(Floride)\">Melbourne</a> (<a href=\"/wiki/Floride\">Floride</a>) aux <a href=\"/wiki/%C3%89tats-Unis\">États-Unis</a>, et mort le <a href=\"/wiki/3_juillet\">3</a>&#160;<a href=\"/wiki/Juillet_1971\">juillet</a>&#160;<a href=\"/wiki/1971_en_musique\">1971</a> à <a href=\"/wiki/Paris\">Paris</a>, en <a href=\"/wiki/France\">France</a>) est un <a href=\"/wiki/Chanteur\">chanteur</a>, <a href=\"/wiki/Cin%C3%A9aste\">cinéaste</a> et <a href=\"/wiki/Po%C3%A8te\">poète</a> <a href=\"/wiki/%C3%89tats-Unis\">américain</a>, cofondateur du groupe de <a href=\"/wiki/Rock\">rock</a> américain <a href=\"/wiki/The_Doors\">The Doors</a>, dont il fut membre de 1965 à sa mort.</p>\n<p><a href=\"/wiki/Sex-symbol\">Sex-symbol</a> provocant au comportement volontairement excessif, devenu une véritable idole de la <a href=\"/wiki/Musique_rock\">musique rock</a>, mais aussi intellectuel engagé dans le mouvement du <a href=\"/wiki/Protest_song\">protest song</a>, en particulier contre la <a href=\"/wiki/Guerre_du_Vi%C3%AAt_Nam\">guerre du Viêt Nam</a>, attiré par le <a href=\"/wiki/Chamanisme\">chamanisme</a>, on lui attribue une réputation de «&#160;<a href=\"/wiki/Po%C3%A8te_maudit\">poète maudit</a>&#160;» que sa mort prématurée, à Paris, dans des circonstances mal élucidées, transforme en légende, notamment fondatrice de ce qui est connu sous le nom de <a href=\"/wiki/Club_des_27\">Club des 27</a>.</p>\n<p>Le culte que lui vouent ses fans éclipse cependant une œuvre poétique d'une grande richesse que Morrison lui-même a pu considérer comme sa principale activité, au moins à partir de l'été 1968.</p>", personnalite2.resume, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1943-12-08"], personnalite2.dateNaissance, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1971-07-03"], personnalite2.dateDeces, @"");
    XCTAssertEqualObjects(@"J", personnalite2.dateNaissancePrecision, @"");
    XCTAssertEqualObjects(@"J", personnalite2.dateDecesPrecision, @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLNodeOSM"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]]];
    NSArray *fetchedNodeOSMs = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLPersonnalite"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]]];
    NSArray *fetchedPersonnalites = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLImageCommons"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]]];
    NSArray *fetchedImagesCommons = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    // Vérification que les objets correspondent
    XCTAssertEqualObjects([fetchedMonuments objectAtIndex:0], monument1, @"");
    XCTAssertEqualObjects([fetchedMonuments objectAtIndex:1], monument2_update, @"");
    XCTAssertEqualObjects([fetchedNodeOSMs objectAtIndex:0], nodeOSM1, @"");
    XCTAssertEqualObjects([fetchedNodeOSMs objectAtIndex:1], nodeOSM2, @"");
    XCTAssertEqualObjects([fetchedMonuments objectAtIndex:1], monument2_update, @"");
    XCTAssertEqualObjects([fetchedPersonnalites objectAtIndex:0], personnalite1, @"");
    XCTAssertEqualObjects([fetchedPersonnalites objectAtIndex:1], personnalite2, @"");
    XCTAssertEqualObjects([fetchedImagesCommons objectAtIndex:0], imageCommons1, @"");
    XCTAssertEqualObjects([fetchedImagesCommons objectAtIndex:1], imageCommons2, @"");
}

// Vérifie que la création de 2 monuments puis deux mises à jour successives du 2e donne le résultat attendu
- (void)testMonumentMappingUpdate3
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
    PLMonument *monument1 = [mappingTest destinationObject];
    
    // Chargement de la fixture 2
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument2.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Chargement de la mise à jour de la fixture 2
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument2_update1.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Chargement de la 2e mise à jour de la fixture 2
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"monument2_update2.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll monumentMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Commit pour obtenir les propriétés dérivées
    [managedObjectContext save:nil];
    
    // Récupération du résultat
    PLMonument *monument2_update2 = [mappingTest destinationObject];
    
    // Contrôle du résultat 1
    XCTAssertEqualObjects(@(164), monument1.id, @"");
    XCTAssertEqualObjects(@"Mur des Fédérés", monument1.nom, @"");
    XCTAssertEqualObjects(@"Mur des Fédérés", monument1.nomPourTri, @"");
    XCTAssertEqualObjects(@"M", monument1.premiereLettreNomPourTri, @"");
    XCTAssertEqualObjects(@"Mur des Fédérés", monument1.codeWikipedia, @"");
    XCTAssertEqualObjects(@"<p>Le <b>mur des Fédérés</b> est une partie de l'enceinte du <a href=\"/wiki/Cimeti%C3%A8re_du_P%C3%A8re-Lachaise\">cimetière du Père-Lachaise</a>, à <a href=\"/wiki/Paris\">Paris</a>, devant laquelle, le <a href=\"/wiki/28_mai\">28</a>&#160;<a href=\"/wiki/Mai_1871\">mai</a>&#160;<a href=\"/wiki/1871\">1871</a>, cent quarante-sept Fédérés, combattants de la <a href=\"/wiki/Commune_de_Paris_(1871)\">Commune</a>, ont été fusillés et jetés dans une fosse ouverte au pied du mur par les Versaillais. Depuis lors, il symbolise la lutte pour la liberté et les idéaux des <a href=\"/wiki/Communard\">communards</a>, <a href=\"/wiki/Autogestion\">autogestionnaires</a>.</p>\n<p>Le mur est à l'angle sud-est du cimetière.</p>", monument1.resume, @"");
    
    // Récupération du node OSM
    PLNodeOSM *nodeOSM1 = monument1.nodeOSM;
    XCTAssertNotNil(nodeOSM1, @"");
    
    // Contrôle du node OSM
    XCTAssertEqualObjects(@(1152422864), nodeOSM1.id, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"48.8597013"], nodeOSM1.latitude, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"2.4000175"], nodeOSM1.longitude, @"");
    
    // Récupération de l'image Commons
    PLImageCommons *imageCommons1 = monument1.imagePrincipale;
    XCTAssertNotNil(imageCommons1, @"");
    
    // Contrôle de l'image Commons
    XCTAssertEqualObjects(@(200), imageCommons1.id, @"");
    XCTAssertEqualObjects(@"Commune2011.jpg", imageCommons1.nom, @"");
    XCTAssertEqualObjects(@"Dayofmayofday", imageCommons1.auteur, @"");
    XCTAssertEqualObjects(@"CC0", imageCommons1.licence, @"");
    XCTAssertEqualObjects(@"http://upload.wikimedia.org/wikipedia/commons/a/ab/Commune2011.jpg", imageCommons1.urlOriginal, @"");
    
    // Récupération des personnalités
    NSOrderedSet *personnalites1 = monument1.personnalites;
    XCTAssertEqual(1, [personnalites1 count], @"");
    PLPersonnalite *personnalite1 = [personnalites1 objectAtIndex:0];
    XCTAssertNotNil(personnalite1, @"");
    
    // Contrôle de la personnalité 1
    XCTAssertEqualObjects(@(207), personnalite1.id, @"");
    XCTAssertEqualObjects(@"Alain Bashung", personnalite1.nom, @"");
    XCTAssertEqualObjects(@"Alain Bashung", personnalite1.codeWikipedia, @"");
    XCTAssertEqualObjects(@"chanteur français", personnalite1.activite, @"");
    XCTAssertEqualObjects(@"<p><b>Alain Bashung</b>, né <b>Alain Baschung</b> (Paris,&#160;<a href=\"/wiki/1er_d%C3%A9cembre\">1<sup>er</sup></a>&#160;<a href=\"/wiki/D%C3%A9cembre_1947\">décembre</a>&#160;<a href=\"/wiki/1947\">1947</a> – Paris,&#160;<a href=\"/wiki/14_mars\">14</a>&#160;<a href=\"/wiki/Mars_2009\">mars</a>&#160;<a href=\"/wiki/2009\">2009</a>), est un <a href=\"/wiki/Auteur-compositeur-interpr%C3%A8te\">auteur-compositeur-interprète</a> et comédien <a href=\"/wiki/France\">français</a>. Il est devenu une figure importante de la <a href=\"/wiki/Chanson_fran%C3%A7aise\">chanson</a> et du <a href=\"/wiki/Rock_fran%C3%A7ais\">rock français</a> à partir du début des <a href=\"/wiki/Ann%C3%A9es_1980\">années 1980</a> et a influencé un grand nombre de chanteurs de la nouvelle scène française. Il est le chanteur le plus primé aux <a href=\"/wiki/Victoires_de_la_musique\">Victoires de la musique</a> avec 12 victoires obtenues tout au long de sa carrière.</p>", personnalite1.resume, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1947-12-01"], personnalite1.dateNaissance, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"2009-03-14"], personnalite1.dateDeces, @"");
    XCTAssertEqualObjects(@"J", personnalite1.dateNaissancePrecision, @"");
    XCTAssertEqualObjects(@"J", personnalite1.dateDecesPrecision, @"");
    
    // Contrôle du résultat 2
    XCTAssertEqualObjects(@(120), monument2_update2.id, @"");
    XCTAssertEqualObjects(@"Jim Morrison", monument2_update2.nom, @"");
    XCTAssertEqualObjects(@"Morrison", monument2_update2.nomPourTri, @"");
    XCTAssertEqualObjects(@"M", monument2_update2.premiereLettreNomPourTri, @"");
    XCTAssertEqualObjects(@"", monument2_update2.codeWikipedia, @"");
    XCTAssertEqualObjects(@"", monument2_update2.resume, @"");
    
    // Récupération du node OSM
    PLNodeOSM *nodeOSM2 = monument2_update2.nodeOSM;
    XCTAssertNotNil(nodeOSM2, @"");
    
    // Contrôle du node OSM
    XCTAssertEqualObjects(@(1915793663), nodeOSM2.id, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"48.8592676"], nodeOSM2.latitude, @"");
    XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"2.3937520"], nodeOSM2.longitude, @"");
    
    // Récupération de l'image Commons
    PLImageCommons *imageCommons2 = monument2_update2.imagePrincipale;
    XCTAssertNotNil(imageCommons2, @"");
    
    // Contrôle de l'image Commons
    XCTAssertEqualObjects(@(148), imageCommons2.id, @"");
    XCTAssertEqualObjects(@"Tombeau d'Edith Piaf.JPG", imageCommons2.nom, @"");
    XCTAssertEqualObjects(@"PRA", imageCommons2.auteur, @"");
    XCTAssertEqualObjects(@"CC-BY-2.5", imageCommons2.licence, @"");
    XCTAssertEqualObjects(@"http://upload.wikimedia.org/wikipedia/commons/e/e7/Tombeau_d%27Edith_Piaf.JPG", imageCommons2.urlOriginal, @"");
    
    // Récupération des personnalités
    NSOrderedSet *personnalites2 = monument2_update2.personnalites;
    XCTAssertEqual(2, [personnalites2 count], @"");
    PLPersonnalite *personnalite2 = [personnalites2 objectAtIndex:0];
    XCTAssertNotNil(personnalite2, @"");
    PLPersonnalite *personnalite3 = [personnalites2 objectAtIndex:1];
    XCTAssertNotNil(personnalite3, @"");
    
    // Contrôle de la personnalité 2
    XCTAssertEqualObjects(@(120), personnalite2.id, @"");
    XCTAssertEqualObjects(@"Nouveau nom", personnalite2.nom, @"");
    XCTAssertEqualObjects(@"Jim Morrison", personnalite2.codeWikipedia, @"");
    XCTAssertEqualObjects(@"chanteur des Doors", personnalite2.activite, @"");
    XCTAssertEqualObjects(@"Nouveau résumé", personnalite2.resume, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1943-12-08"], personnalite2.dateNaissance, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1971-07-03"], personnalite2.dateDeces, @"");
    XCTAssertEqualObjects(@"J", personnalite2.dateNaissancePrecision, @"");
    XCTAssertEqualObjects(@"J", personnalite2.dateDecesPrecision, @"");
    
    // Contrôle de la personnalité 3
    XCTAssertEqualObjects(@(231), personnalite3.id, @"");
    XCTAssertEqualObjects(@"François d'Astier de La Vigerie", personnalite3.nom, @"");
    XCTAssertEqualObjects(@"François d'Astier de La Vigerie", personnalite3.codeWikipedia, @"");
    XCTAssertEqualObjects(@"militaire français, compagnon de la Libération", personnalite3.activite, @"");
    XCTAssertEqualObjects(@"<p><b>François d'Astier de La Vigerie</b> est né au <a href=\"/wiki/Le_Mans\">Mans</a> le <a href=\"/wiki/7_mars\">7</a>&#160;<a href=\"/wiki/Mars_1886\">mars</a>&#160;<a href=\"/wiki/1886\">1886</a>, décédé à <a href=\"/wiki/Paris\">Paris</a> le <a href=\"/wiki/9_octobre\">9</a>&#160;<a href=\"/wiki/Octobre_1956\">octobre</a>&#160;<a href=\"/wiki/1956\">1956</a>. Militaire de carrière, il se remarqua surtout par ses faits d'armes dans la <a href=\"/wiki/R%C3%A9sistance_int%C3%A9rieure_fran%C3%A7aise\">Résistance</a> au cours de la <a href=\"/wiki/Seconde_Guerre_mondiale\">Seconde Guerre mondiale</a> et qui lui valurent d'être fait <a href=\"/wiki/Compagnon_de_la_Lib%C3%A9ration\">Compagnon de la Libération</a>.</p>\n<p>Il est le frère d'<a href=\"/wiki/Emmanuel_d%27Astier_de_la_Vigerie\">Emmanuel d'Astier de la Vigerie</a> et d'<a href=\"/wiki/Henri_d%27Astier_de_la_Vigerie\">Henri d'Astier de la Vigerie</a>.</p>", personnalite3.resume, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1886-03-07"], personnalite3.dateNaissance, @"");
    XCTAssertEqualObjects([self.dateFormatter dateFromString:@"1956-10-09"], personnalite3.dateDeces, @"");
    XCTAssertEqualObjects(@"J", personnalite3.dateNaissancePrecision, @"");
    XCTAssertEqualObjects(@"J", personnalite3.dateDecesPrecision, @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLNodeOSM"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]]];
    NSArray *fetchedNodeOSMs = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLPersonnalite"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]]];
    NSArray *fetchedPersonnalites = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLImageCommons"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]]];
    NSArray *fetchedImageCommons = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    // Vérification que les objets correspondent
    XCTAssertEqualObjects([fetchedMonuments objectAtIndex:0], monument1, @"");
    XCTAssertEqualObjects([fetchedMonuments objectAtIndex:1], monument2_update2, @"");
    XCTAssertEqualObjects([fetchedNodeOSMs objectAtIndex:0], nodeOSM1, @"");
    XCTAssertEqualObjects([fetchedNodeOSMs objectAtIndex:1], nodeOSM2, @"");
    XCTAssertEqualObjects([fetchedMonuments objectAtIndex:1], monument2_update2, @"");
    XCTAssertEqualObjects([fetchedPersonnalites objectAtIndex:0], personnalite2, @"");
    XCTAssertEqualObjects([fetchedPersonnalites objectAtIndex:1], personnalite1, @"");
    XCTAssertEqualObjects([fetchedPersonnalites objectAtIndex:2], personnalite3, @"");
    XCTAssertEqualObjects([fetchedImageCommons objectAtIndex:0], imageCommons1, @"");
    XCTAssertEqualObjects([fetchedImageCommons objectAtIndex:1], imageCommons2, @"");
}

#pragma mark - imageCommonsMapping

// Vérifie que le mapping d'une image Commons donne le résultat attendu et l'enregistre
- (void)testImageCommonsMappingCreate1
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
    PLImageCommons *result = [mappingTest destinationObject];
    
    // Contrôle du résultat
    XCTAssertEqualObjects(@(61), result.id, @"");
    XCTAssertEqualObjects(@"Tombe de Alphonse Daudet (cimetière du Père Lachaise).JPG", result.nom, @"");
    XCTAssertEqualObjects(@"Touron66", result.auteur, @"");
    XCTAssertEqualObjects(@"CC-BY-SA-3.0", result.licence, @"");
    XCTAssertEqualObjects(@"http://upload.wikimedia.org/wikipedia/commons/4/4c/Tombe_de_Alphonse_Daudet_%28cimeti%C3%A8re_du_P%C3%A8re_Lachaise%29.JPG", result.urlOriginal, @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération de l'objet enregistré
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLImageCommons"];
    PLImageCommons *fetchedObject = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    
    // Vérification que les objets correspondent
    XCTAssertEqualObjects(fetchedObject, result, @"");
}

// Vérifie que le mapping de 2 images Commons donne le résultat attendu et les enregistre
- (void)testImageCommonsMappingCreate2
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture 1
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"imageCommons1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll imageCommonsMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLImageCommons *result1 = [mappingTest destinationObject];
    
    // Chargement de la fixture 2
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"imageCommons2.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll imageCommonsMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLImageCommons *result2 = [mappingTest destinationObject];
    
    // Contrôle du résultat 1
    XCTAssertEqualObjects(@(61), result1.id, @"");
    XCTAssertEqualObjects(@"Tombe de Alphonse Daudet (cimetière du Père Lachaise).JPG", result1.nom, @"");
    XCTAssertEqualObjects(@"Touron66", result1.auteur, @"");
    XCTAssertEqualObjects(@"CC-BY-SA-3.0", result1.licence, @"");
    XCTAssertEqualObjects(@"http://upload.wikimedia.org/wikipedia/commons/4/4c/Tombe_de_Alphonse_Daudet_%28cimeti%C3%A8re_du_P%C3%A8re_Lachaise%29.JPG", result1.urlOriginal, @"");
    
    // Contrôle du résultat 2
    XCTAssertEqualObjects(@(129), result2.id, @"");
    XCTAssertEqualObjects(@"Tombe de Jim Morrison - Père Lachaise.jpg", result2.nom, @"");
    XCTAssertEqualObjects(@"Krzysztof Mizera", result2.auteur, @"");
    XCTAssertEqualObjects(@"Public domain", result2.licence, @"");
    XCTAssertEqualObjects(@"http://upload.wikimedia.org/wikipedia/commons/9/96/Tombe_de_Jim_Morrison_-_P%C3%A8re_Lachaise.jpg", result2.urlOriginal, @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération de l'objet enregistré
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLImageCommons"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]]];
    
    // Vérification que les objets correspondent
    PLImageCommons *fetchedObject1 = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    XCTAssertEqualObjects(fetchedObject1, result1, @"");
    PLImageCommons *fetchedObject2 = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:1];
    XCTAssertEqualObjects(fetchedObject2, result2, @"");
}

// Vérifie que le création puis la mise à jour d'une image Commons donne le résultat attendu
- (void)testImageCommonsMappingUpdate1
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture 1
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"imageCommons1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll imageCommonsMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Chargement de la mise à jour de la fixture 1
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"imageCommons1_update.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll imageCommonsMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLImageCommons *result1_update = [mappingTest destinationObject];
    
    // Contrôle du résultat de la mise à jour
    XCTAssertEqualObjects(@(61), result1_update.id, @"");
    XCTAssertEqualObjects(@"nom1", result1_update.nom, @"");
    XCTAssertEqualObjects(@"auteur1", result1_update.auteur, @"");
    XCTAssertEqualObjects(@"licence1", result1_update.licence, @"");
    XCTAssertEqualObjects(@"url_original1", result1_update.urlOriginal, @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(1, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération de l'objet enregistré
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLImageCommons"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]]];
    
    // Vérification que les objets correspondent
    PLImageCommons *fetchedObject = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    XCTAssertEqualObjects(fetchedObject, result1_update, @"");
}

// Vérifie que la création de 2 images Commons puis la mise à jour de la 2e donne le résultat attendu
- (void)testImageCommonsMappingUpdate2
{
    // Récupération du managed object context
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    
    // Chargement de la fixture 1
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"imageCommons1.json"];
    
    // Création et exécution du test de mapping
    RKMappingTest *mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll imageCommonsMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLImageCommons *result1 = [mappingTest destinationObject];
    
    // Chargement de la fixture 2
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"imageCommons2.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll imageCommonsMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Chargement de la mise à jour de la fixture 2
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"imageCommons2_update.json"];
    
    // Création et exécution du test de mapping
    mappingTest = [RKMappingTest testForMapping:[PLRestKitMonumentAll imageCommonsMapping] sourceObject:parsedJSON destinationObject:nil];
    mappingTest.managedObjectContext = managedObjectContext;
    [mappingTest performMapping];
    
    // Récupération du résultat
    PLImageCommons *result2_update = [mappingTest destinationObject];
    
    // Contrôle du résultat 1
    XCTAssertEqualObjects(@(61), result1.id, @"");
    XCTAssertEqualObjects(@"Tombe de Alphonse Daudet (cimetière du Père Lachaise).JPG", result1.nom, @"");
    XCTAssertEqualObjects(@"Touron66", result1.auteur, @"");
    XCTAssertEqualObjects(@"CC-BY-SA-3.0", result1.licence, @"");
    XCTAssertEqualObjects(@"http://upload.wikimedia.org/wikipedia/commons/4/4c/Tombe_de_Alphonse_Daudet_%28cimeti%C3%A8re_du_P%C3%A8re_Lachaise%29.JPG", result1.urlOriginal, @"");
    
    // Contrôle du résultat 2
    XCTAssertEqualObjects(@(129), result2_update.id, @"");
    XCTAssertEqualObjects(@"nom2", result2_update.nom, @"");
    XCTAssertEqualObjects(@"auteur2", result2_update.auteur, @"");
    XCTAssertEqualObjects(@"licence2", result2_update.licence, @"");
    XCTAssertEqualObjects(@"url_original2", result2_update.urlOriginal, @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération de l'objet enregistré
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLImageCommons"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]]];
    
    // Vérification que les objets correspondent
    PLImageCommons *fetchedObject1 = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:0];
    XCTAssertEqualObjects(fetchedObject1, result1, @"");
    PLImageCommons *fetchedObject2 = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] objectAtIndex:1];
    XCTAssertEqualObjects(fetchedObject2, result2_update, @"");
}

#pragma mark - Requête

// Vérifie qu'une requête donne le résultat attendu
- (void)testRequeteCreate
{
    // Récupération du managed object context et de l'object manager
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // Configuration de la requête monument/all/
    [objectManager addResponseDescriptor:[PLRestKitMonumentAll responseDescriptor]];
    [objectManager addFetchRequestBlock:[PLRestKitMonumentAll fetchRequestBlock]];
    
    // Construction de la requête
    NSURL *URL = [NSURL URLWithString:@"monument/all/?name=1_ok" relativeToURL:objectManager.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    RKManagedObjectRequestOperation *requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Vérification de la bonne exécution de la requête
    XCTAssertNil(requestOperation.error, @"");
    XCTAssertEqual(200, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    
    // Vérification du nombre d'objets reçus
    XCTAssertEqual(3, [requestOperation.mappingResult count], @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(4, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    PLMonument *monument1 = [fetchedMonuments objectAtIndex:0];     // Famille d'Aboville
    PLMonument *monument2 = [fetchedMonuments objectAtIndex:1];     // Jim Morrison
    PLMonument *monument3 = [fetchedMonuments objectAtIndex:2];     // Mur des Fédérés
    
    // Vérification de la correspondance du résultat
    
    // Monuments
    XCTAssertEqualObjects(@(227), monument1.id, @"");
    XCTAssertEqualObjects(@(120), monument2.id, @"");
    XCTAssertEqualObjects(@(164), monument3.id, @"");
    XCTAssertEqualObjects(@"A", monument1.premiereLettreNomPourTri, @"");
    XCTAssertEqualObjects(@"M", monument2.premiereLettreNomPourTri, @"");
    XCTAssertEqualObjects(@"M", monument3.premiereLettreNomPourTri, @"");
    
    // Nodes OSM
    XCTAssertEqualObjects(@(2649596674), monument1.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1915793663), monument2.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1152422864), monument3.nodeOSM.id, @"");
    
    // Images Commons
    XCTAssertEqualObjects(@(1), monument1.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(129), monument2.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(200), monument3.imagePrincipale.id, @"");
    
    // Personnalités
    XCTAssertEqual(3, [monument1.personnalites count], @"");
    XCTAssertEqual(1, [monument2.personnalites count], @"");
    XCTAssertEqual(0, [monument3.personnalites count], @"");
    XCTAssertEqualObjects(@(272), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:0]).id, @"");
    XCTAssertEqualObjects(@(273), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:1]).id, @"");
    XCTAssertEqualObjects(@(230), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:2]).id, @"");
    XCTAssertEqualObjects(@(120), ((PLPersonnalite *)[monument2.personnalites objectAtIndex:0]).id, @"");
}

// Vérifie qu'une requête suivie d'une mise à jour donne le résultat attendu
- (void)testRequeteUpdate
{
    // Récupération du managed object context et de l'object manager
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // Configuration de la requête monument/all/
    [objectManager addResponseDescriptor:[PLRestKitMonumentAll responseDescriptor]];
    [objectManager addFetchRequestBlock:[PLRestKitMonumentAll fetchRequestBlock]];
    
    // Construction de la requête
    NSURL *URL = [NSURL URLWithString:@"monument/all/?name=1_ok" relativeToURL:objectManager.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    RKManagedObjectRequestOperation *requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Construction de la requête de mise à jour
    URL = [NSURL URLWithString:@"monument/all/?name=2_ok" relativeToURL:objectManager.baseURL];
    request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Vérification de la bonne exécution de la requête
    XCTAssertNil(requestOperation.error, @"");
    XCTAssertEqual(200, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    
    // Vérification du nombre d'objets reçus
    XCTAssertEqual(2, [requestOperation.mappingResult count], @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(2, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    PLMonument *monument1 = [fetchedMonuments objectAtIndex:0];     // Henri Barbusse
    PLMonument *monument2 = [fetchedMonuments objectAtIndex:1];     // Jim Morrison
    
    // Vérification de la correspondance du résultat
    
    // Monuments
    XCTAssertEqualObjects(@(92), monument1.id, @"");
    XCTAssertEqualObjects(@(120), monument2.id, @"");
    XCTAssertEqualObjects(@"B", monument1.premiereLettreNomPourTri, @"");
    XCTAssertEqualObjects(@"M", monument2.premiereLettreNomPourTri, @"");
    
    // Nodes OSM
    XCTAssertEqualObjects(@(2628752275), monument1.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1915793663), monument2.nodeOSM.id, @"");
    
    // Images Commons
    XCTAssertEqualObjects(@(203), monument1.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(129), monument2.imagePrincipale.id, @"");
    
    // Personnalités
    XCTAssertEqual(1, [monument1.personnalites count], @"");
    XCTAssertEqual(1, [monument2.personnalites count], @"");
    XCTAssertEqualObjects(@(92), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:0]).id, @"");
    XCTAssertEqualObjects(@(120), ((PLPersonnalite *)[monument2.personnalites objectAtIndex:0]).id, @"");
}

// Vérifie qu'une requête suivie d'une mise à jour avec résultat vide donne le résultat attendu
- (void)testRequeteUpdateVide
{
    // Récupération du managed object context et de l'object manager
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // Configuration de la requête monument/all/
    [objectManager addResponseDescriptor:[PLRestKitMonumentAll responseDescriptor]];
    [objectManager addFetchRequestBlock:[PLRestKitMonumentAll fetchRequestBlock]];
    
    // Construction de la requête
    NSURL *URL = [NSURL URLWithString:@"monument/all/?name=1_ok" relativeToURL:objectManager.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    RKManagedObjectRequestOperation *requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Construction de la requête de mise à jour
    URL = [NSURL URLWithString:@"monument/all/?name=3_vide" relativeToURL:objectManager.baseURL];
    request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Vérification de la bonne exécution de la requête
    XCTAssertNil(requestOperation.error, @"");
    XCTAssertEqual(200, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    
    // Vérification du nombre d'objets reçus
    XCTAssertEqual(0, [requestOperation.mappingResult count], @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
}

// Vérifie qu'une requête sur un autre web service n'est pas prise en compte
- (void)testRequeteBaseURL
{
    // Récupération du managed object context et de l'object manager
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // Configuration de la requête monument/all/
    [objectManager addResponseDescriptor:[PLRestKitMonumentAll responseDescriptor]];
    [objectManager addFetchRequestBlock:[PLRestKitMonumentAll fetchRequestBlock]];
    
    // Construction de la requête
    NSURL *URL = [NSURL URLWithString:@"monument/all/?name=1_ok" relativeToURL:objectManager.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    RKManagedObjectRequestOperation *requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    XCTAssertEqual(1, [[requestOperation fetchRequestBlocks] count], @"");
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Construction de la requête sur le web service principal
    NSString *webServiceURL = (NSString *)[PLConfiguration valueForKeyPath:@"URL Web Service - dev"];
    URL = [NSURL URLWithString:@"monument/all/" relativeToURL:[NSURL URLWithString:webServiceURL]];
    
    request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Vérification que la requête a réussi mais n'a pas été prise en compte
    XCTAssertEqual(200, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    XCTAssertNotNil(requestOperation.error, @"");
    XCTAssertEqual(1001, [requestOperation.error code], @"");
    
    // Vérification du nombre d'objets reçus
    XCTAssertEqual(0, [requestOperation.mappingResult count], @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(4, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    PLMonument *monument1 = [fetchedMonuments objectAtIndex:0];     // Famille d'Aboville
    PLMonument *monument2 = [fetchedMonuments objectAtIndex:1];     // Jim Morrison
    PLMonument *monument3 = [fetchedMonuments objectAtIndex:2];     // Mur des Fédérés
    
    // Vérification de la correspondance du résultat
    
    // Monuments
    XCTAssertEqualObjects(@(227), monument1.id, @"");
    XCTAssertEqualObjects(@(120), monument2.id, @"");
    XCTAssertEqualObjects(@(164), monument3.id, @"");
    
    // Nodes OSM
    XCTAssertEqualObjects(@(2649596674), monument1.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1915793663), monument2.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1152422864), monument3.nodeOSM.id, @"");
    
    // Images Commons
    XCTAssertEqualObjects(@(1), monument1.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(129), monument2.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(200), monument3.imagePrincipale.id, @"");
    
    // Personnalités
    XCTAssertEqual(3, [monument1.personnalites count], @"");
    XCTAssertEqual(1, [monument2.personnalites count], @"");
    XCTAssertEqual(0, [monument3.personnalites count], @"");
    XCTAssertEqualObjects(@(272), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:0]).id, @"");
    XCTAssertEqualObjects(@(273), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:1]).id, @"");
    XCTAssertEqualObjects(@(230), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:2]).id, @"");
    XCTAssertEqualObjects(@(120), ((PLPersonnalite *)[monument2.personnalites objectAtIndex:0]).id, @"");
}

// Vérifie qu'une requête avec POST n'est pas prise en compte
- (void)testRequetePOST
{
    // Récupération du managed object context et de l'object manager
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // Configuration de la requête monument/all/
    [objectManager addResponseDescriptor:[PLRestKitMonumentAll responseDescriptor]];
    [objectManager addFetchRequestBlock:[PLRestKitMonumentAll fetchRequestBlock]];
    
    // Construction de la requête
    NSURL *URL = [NSURL URLWithString:@"monument/all/?name=1_ok" relativeToURL:objectManager.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    RKManagedObjectRequestOperation *requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Construction de la 2e requête
    URL = [NSURL URLWithString:@"monument/all/?name=2_ok" relativeToURL:objectManager.baseURL];
    request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Vérification que la requête a réussi mais n'a pas été prise en compte
    XCTAssertEqual(200, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    XCTAssertNotNil(requestOperation.error, @"");
    XCTAssertEqual(1001, [requestOperation.error code], @"");
    
    // Vérification du nombre d'objets reçus
    XCTAssertEqual(0, [requestOperation.mappingResult count], @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(4, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    PLMonument *monument1 = [fetchedMonuments objectAtIndex:0];     // Famille d'Aboville
    PLMonument *monument2 = [fetchedMonuments objectAtIndex:1];     // Jim Morrison
    PLMonument *monument3 = [fetchedMonuments objectAtIndex:2];     // Mur des Fédérés
    
    // Vérification de la correspondance du résultat
    
    // Monuments
    XCTAssertEqualObjects(@(227), monument1.id, @"");
    XCTAssertEqualObjects(@(120), monument2.id, @"");
    XCTAssertEqualObjects(@(164), monument3.id, @"");
    
    // Nodes OSM
    XCTAssertEqualObjects(@(2649596674), monument1.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1915793663), monument2.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1152422864), monument3.nodeOSM.id, @"");
    
    // Images Commons
    XCTAssertEqualObjects(@(1), monument1.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(129), monument2.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(200), monument3.imagePrincipale.id, @"");
    
    // Personnalités
    XCTAssertEqual(3, [monument1.personnalites count], @"");
    XCTAssertEqual(1, [monument2.personnalites count], @"");
    XCTAssertEqual(0, [monument3.personnalites count], @"");
    XCTAssertEqualObjects(@(272), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:0]).id, @"");
    XCTAssertEqualObjects(@(273), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:1]).id, @"");
    XCTAssertEqualObjects(@(230), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:2]).id, @"");
    XCTAssertEqualObjects(@(120), ((PLPersonnalite *)[monument2.personnalites objectAtIndex:0]).id, @"");
}

// Vérifie qu'une requête avec PUT n'est pas prise en compte
- (void)testRequetePUT
{
    // Récupération du managed object context et de l'object manager
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // Configuration de la requête monument/all/
    [objectManager addResponseDescriptor:[PLRestKitMonumentAll responseDescriptor]];
    [objectManager addFetchRequestBlock:[PLRestKitMonumentAll fetchRequestBlock]];
    
    // Construction de la requête
    NSURL *URL = [NSURL URLWithString:@"monument/all/?name=1_ok" relativeToURL:objectManager.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    RKManagedObjectRequestOperation *requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Construction de la 2e requête
    URL = [NSURL URLWithString:@"monument/all/?name=2_ok" relativeToURL:objectManager.baseURL];
    request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"PUT";
    requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Vérification que la requête a réussi mais n'a pas été prise en compte
    XCTAssertEqual(200, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    XCTAssertNotNil(requestOperation.error, @"");
    XCTAssertEqual(1001, [requestOperation.error code], @"");
    
    // Vérification du nombre d'objets reçus
    XCTAssertEqual(0, [requestOperation.mappingResult count], @"");

    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(4, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");

    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    PLMonument *monument1 = [fetchedMonuments objectAtIndex:0];     // Famille d'Aboville
    PLMonument *monument2 = [fetchedMonuments objectAtIndex:1];     // Jim Morrison
    PLMonument *monument3 = [fetchedMonuments objectAtIndex:2];     // Mur des Fédérés

    // Vérification de la correspondance du résultat

    // Monuments
    XCTAssertEqualObjects(@(227), monument1.id, @"");
    XCTAssertEqualObjects(@(120), monument2.id, @"");
    XCTAssertEqualObjects(@(164), monument3.id, @"");

    // Nodes OSM
    XCTAssertEqualObjects(@(2649596674), monument1.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1915793663), monument2.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1152422864), monument3.nodeOSM.id, @"");
    
    // Images Commons
    XCTAssertEqualObjects(@(1), monument1.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(129), monument2.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(200), monument3.imagePrincipale.id, @"");

    // Personnalités
    XCTAssertEqual(3, [monument1.personnalites count], @"");
    XCTAssertEqual(1, [monument2.personnalites count], @"");
    XCTAssertEqual(0, [monument3.personnalites count], @"");
    XCTAssertEqualObjects(@(272), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:0]).id, @"");
    XCTAssertEqualObjects(@(273), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:1]).id, @"");
    XCTAssertEqualObjects(@(230), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:2]).id, @"");
    XCTAssertEqualObjects(@(120), ((PLPersonnalite *)[monument2.personnalites objectAtIndex:0]).id, @"");
}

// Vérifie qu'une requête avec DELETE n'est pas prise en compte
- (void)testRequeteDELETE
{
    // Récupération du managed object context et de l'object manager
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // Configuration de la requête monument/all/
    [objectManager addResponseDescriptor:[PLRestKitMonumentAll responseDescriptor]];
    [objectManager addFetchRequestBlock:[PLRestKitMonumentAll fetchRequestBlock]];
    
    // Construction de la requête
    NSURL *URL = [NSURL URLWithString:@"monument/all/?name=1_ok" relativeToURL:objectManager.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    RKManagedObjectRequestOperation *requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Construction de la 2e requête
    URL = [NSURL URLWithString:@"monument/all/?name=2_ok" relativeToURL:objectManager.baseURL];
    request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"DELETE";
    requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
#warning RestKit : aucun response descriptor correspondant mais pas d'erreur remontée
    XCTAssertEqual(200, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    XCTAssertNil(requestOperation.error, @"");
    
    /*
    // Vérification que la requête a réussi mais n'a pas été prise en compte
    XCTAssertEqual(200, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    XCTAssertNotNil(requestOperation.error, @"");
    XCTAssertEqual(1001, [requestOperation.error code], @"");
    */
    // Vérification du nombre d'objets reçus
    XCTAssertEqual(0, [requestOperation.mappingResult count], @"");

    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(4, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");

    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    PLMonument *monument1 = [fetchedMonuments objectAtIndex:0];     // Famille d'Aboville
    PLMonument *monument2 = [fetchedMonuments objectAtIndex:1];     // Jim Morrison
    PLMonument *monument3 = [fetchedMonuments objectAtIndex:2];     // Mur des Fédérés

    // Vérification de la correspondance du résultat

    // Monuments
    XCTAssertEqualObjects(@(227), monument1.id, @"");
    XCTAssertEqualObjects(@(120), monument2.id, @"");
    XCTAssertEqualObjects(@(164), monument3.id, @"");

    // Nodes OSM
    XCTAssertEqualObjects(@(2649596674), monument1.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1915793663), monument2.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1152422864), monument3.nodeOSM.id, @"");
    
    // Images Commons
    XCTAssertEqualObjects(@(1), monument1.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(129), monument2.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(200), monument3.imagePrincipale.id, @"");

    // Personnalités
    XCTAssertEqual(3, [monument1.personnalites count], @"");
    XCTAssertEqual(1, [monument2.personnalites count], @"");
    XCTAssertEqual(0, [monument3.personnalites count], @"");
    XCTAssertEqualObjects(@(272), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:0]).id, @"");
    XCTAssertEqualObjects(@(273), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:1]).id, @"");
    XCTAssertEqualObjects(@(230), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:2]).id, @"");
    XCTAssertEqualObjects(@(120), ((PLPersonnalite *)[monument2.personnalites objectAtIndex:0]).id, @"");
}

// Vérifie qu'une requête renvoyant un mauvais keypath (sous-clé) n'est pas prise en compte
- (void)testRequeteSousCle
{
    // Récupération du managed object context et de l'object manager
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // Configuration de la requête monument/all/
    [objectManager addResponseDescriptor:[PLRestKitMonumentAll responseDescriptor]];
    [objectManager addFetchRequestBlock:[PLRestKitMonumentAll fetchRequestBlock]];
    
    // Construction de la requête
    NSURL *URL = [NSURL URLWithString:@"monument/all/?name=1_ok" relativeToURL:objectManager.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    RKManagedObjectRequestOperation *requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Construction de la 2e requête
    URL = [NSURL URLWithString:@"monument/all/?name=4_souscle" relativeToURL:objectManager.baseURL];
    request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Vérification que la requête a réussi mais n'a pas été prise en compte
    XCTAssertEqual(200, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    XCTAssertNotNil(requestOperation.error, @"");
    XCTAssertEqual(1001, [requestOperation.error code], @"");
    
    // Vérification du nombre d'objets reçus
    XCTAssertEqual(0, [requestOperation.mappingResult count], @"");
    
#warning RestKit : pas de response descriptor correspondant mais les objets sont quand même nettoyés
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    /*
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(4, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    PLMonument *monument1 = [fetchedMonuments objectAtIndex:0];     // Famille d'Aboville
    PLMonument *monument2 = [fetchedMonuments objectAtIndex:1];     // Jim Morrison
    PLMonument *monument3 = [fetchedMonuments objectAtIndex:2];     // Mur des Fédérés
    
    // Vérification de la correspondance du résultat
    
    // Monuments
    XCTAssertEqualObjects(@(227), monument1.id, @"");
    XCTAssertEqualObjects(@(120), monument2.id, @"");
    XCTAssertEqualObjects(@(164), monument3.id, @"");
    
    // Nodes OSM
    XCTAssertEqualObjects(@(2649596674), monument1.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1915793663), monument2.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1152422864), monument3.nodeOSM.id, @"");
    
    // Personnalités
    XCTAssertEqual(3, [monument1.personnalites count], @"");
    XCTAssertEqual(1, [monument2.personnalites count], @"");
    XCTAssertEqual(0, [monument3.personnalites count], @"");
    XCTAssertEqualObjects(@(272), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:0]).id, @"");
    XCTAssertEqualObjects(@(273), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:1]).id, @"");
    XCTAssertEqualObjects(@(230), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:2]).id, @"");
    XCTAssertEqualObjects(@(120), ((PLPersonnalite *)[monument2.personnalites objectAtIndex:0]).id, @"");
     */
}

// Vérifie qu'une requête renvoyant un mauvais keypath (sur-clé) n'est pas prise en compte
- (void)testRequeteSurCle
{
    // Récupération du managed object context et de l'object manager
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // Configuration de la requête monument/all/
    [objectManager addResponseDescriptor:[PLRestKitMonumentAll responseDescriptor]];
    [objectManager addFetchRequestBlock:[PLRestKitMonumentAll fetchRequestBlock]];
    
    // Construction de la requête
    NSURL *URL = [NSURL URLWithString:@"monument/all/?name=1_ok" relativeToURL:objectManager.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    RKManagedObjectRequestOperation *requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Construction de la 2e requête
    URL = [NSURL URLWithString:@"monument/all/?name=5_surcle" relativeToURL:objectManager.baseURL];
    request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Vérification que la requête a réussi mais n'a pas été prise en compte
    XCTAssertEqual(200, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    XCTAssertNotNil(requestOperation.error, @"");
    XCTAssertEqual(1560, [requestOperation.error code], @"");
    
    // Vérification du nombre d'objets reçus
    XCTAssertEqual(0, [requestOperation.mappingResult count], @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(4, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    PLMonument *monument1 = [fetchedMonuments objectAtIndex:0];     // Famille d'Aboville
    PLMonument *monument2 = [fetchedMonuments objectAtIndex:1];     // Jim Morrison
    PLMonument *monument3 = [fetchedMonuments objectAtIndex:2];     // Mur des Fédérés
    
    // Vérification de la correspondance du résultat
    
    // Monuments
    XCTAssertEqualObjects(@(227), monument1.id, @"");
    XCTAssertEqualObjects(@(120), monument2.id, @"");
    XCTAssertEqualObjects(@(164), monument3.id, @"");
    
    // Nodes OSM
    XCTAssertEqualObjects(@(2649596674), monument1.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1915793663), monument2.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1152422864), monument3.nodeOSM.id, @"");
    
    // Images Commons
    XCTAssertEqualObjects(@(1), monument1.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(129), monument2.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(200), monument3.imagePrincipale.id, @"");
    
    // Personnalités
    XCTAssertEqual(3, [monument1.personnalites count], @"");
    XCTAssertEqual(1, [monument2.personnalites count], @"");
    XCTAssertEqual(0, [monument3.personnalites count], @"");
    XCTAssertEqualObjects(@(272), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:0]).id, @"");
    XCTAssertEqualObjects(@(273), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:1]).id, @"");
    XCTAssertEqualObjects(@(230), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:2]).id, @"");
    XCTAssertEqualObjects(@(120), ((PLPersonnalite *)[monument2.personnalites objectAtIndex:0]).id, @"");
    
}

// Vérifie qu'une requête renvoyant un mauvais keypath (double clé) n'est pas prise en compte
- (void)testRequeteDoubleCle
{
    // Récupération du managed object context et de l'object manager
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // Configuration de la requête monument/all/
    [objectManager addResponseDescriptor:[PLRestKitMonumentAll responseDescriptor]];
    [objectManager addFetchRequestBlock:[PLRestKitMonumentAll fetchRequestBlock]];
    
    // Construction de la requête
    NSURL *URL = [NSURL URLWithString:@"monument/all/?name=1_ok" relativeToURL:objectManager.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    RKManagedObjectRequestOperation *requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Construction de la 2e requête
    URL = [NSURL URLWithString:@"monument/all/?name=6_doublecle" relativeToURL:objectManager.baseURL];
    request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Vérification que la requête a réussi mais n'a pas été prise en compte
    XCTAssertEqual(200, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    XCTAssertNotNil(requestOperation.error, @"");
    XCTAssertEqual(1560, [requestOperation.error code], @"");
    
    // Vérification du nombre d'objets reçus
    XCTAssertEqual(0, [requestOperation.mappingResult count], @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(4, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    PLMonument *monument1 = [fetchedMonuments objectAtIndex:0];     // Famille d'Aboville
    PLMonument *monument2 = [fetchedMonuments objectAtIndex:1];     // Jim Morrison
    PLMonument *monument3 = [fetchedMonuments objectAtIndex:2];     // Mur des Fédérés
    
    // Vérification de la correspondance du résultat
    
    // Monuments
    XCTAssertEqualObjects(@(227), monument1.id, @"");
    XCTAssertEqualObjects(@(120), monument2.id, @"");
    XCTAssertEqualObjects(@(164), monument3.id, @"");
    
    // Nodes OSM
    XCTAssertEqualObjects(@(2649596674), monument1.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1915793663), monument2.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1152422864), monument3.nodeOSM.id, @"");
    
    // Images Commons
    XCTAssertEqualObjects(@(1), monument1.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(129), monument2.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(200), monument3.imagePrincipale.id, @"");
    
    // Personnalités
    XCTAssertEqual(3, [monument1.personnalites count], @"");
    XCTAssertEqual(1, [monument2.personnalites count], @"");
    XCTAssertEqual(0, [monument3.personnalites count], @"");
    XCTAssertEqualObjects(@(272), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:0]).id, @"");
    XCTAssertEqualObjects(@(273), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:1]).id, @"");
    XCTAssertEqualObjects(@(230), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:2]).id, @"");
    XCTAssertEqualObjects(@(120), ((PLPersonnalite *)[monument2.personnalites objectAtIndex:0]).id, @"");
}

// Vérifie qu'une requête renvoyant un mauvais keypath (autre clé) n'est pas prise en compte
- (void)testRequeteAutreCle
{
    // Récupération du managed object context et de l'object manager
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // Configuration de la requête monument/all/
    [objectManager addResponseDescriptor:[PLRestKitMonumentAll responseDescriptor]];
    [objectManager addFetchRequestBlock:[PLRestKitMonumentAll fetchRequestBlock]];
    
    // Construction de la requête
    NSURL *URL = [NSURL URLWithString:@"monument/all/?name=1_ok" relativeToURL:objectManager.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    RKManagedObjectRequestOperation *requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Construction de la 2e requête
    URL = [NSURL URLWithString:@"monument/all/?name=7_autrecle" relativeToURL:objectManager.baseURL];
    request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Vérification que la requête a réussi mais n'a pas été prise en compte
    XCTAssertEqual(200, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    XCTAssertNotNil(requestOperation.error, @"");
    XCTAssertEqual(1001, [requestOperation.error code], @"");
    
    // Vérification du nombre d'objets reçus
    XCTAssertEqual(0, [requestOperation.mappingResult count], @"");
    
#warning RestKit : pas de response descriptor correspondant mais les objets sont quand même nettoyés
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(0, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    /*
     // Vérification du nombre d'objets enregistrés
     XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
     XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
     XCTAssertEqual(4, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
     
     // Récupération des objets enregistrés
     NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
     [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES]]];
     NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
     PLMonument *monument1 = [fetchedMonuments objectAtIndex:0];     // Famille d'Aboville
     PLMonument *monument2 = [fetchedMonuments objectAtIndex:1];     // Jim Morrison
     PLMonument *monument3 = [fetchedMonuments objectAtIndex:2];     // Mur des Fédérés
     
     // Vérification de la correspondance du résultat
     
     // Monuments
     XCTAssertEqualObjects(@(227), monument1.id, @"");
     XCTAssertEqualObjects(@(120), monument2.id, @"");
     XCTAssertEqualObjects(@(164), monument3.id, @"");
     
     // Nodes OSM
     XCTAssertEqualObjects(@(2649596674), monument1.nodeOSM.id, @"");
     XCTAssertEqualObjects(@(1915793663), monument2.nodeOSM.id, @"");
     XCTAssertEqualObjects(@(1152422864), monument3.nodeOSM.id, @"");
     
     // Personnalités
     XCTAssertEqual(3, [monument1.personnalites count], @"");
     XCTAssertEqual(1, [monument2.personnalites count], @"");
     XCTAssertEqual(0, [monument3.personnalites count], @"");
     XCTAssertEqualObjects(@(272), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:0]).id, @"");
     XCTAssertEqualObjects(@(273), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:1]).id, @"");
     XCTAssertEqualObjects(@(230), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:2]).id, @"");
     XCTAssertEqualObjects(@(120), ((PLPersonnalite *)[monument2.personnalites objectAtIndex:0]).id, @"");
     */
}

// Vérifie qu'une requête avec un mauvais chemin relatif (préfixe) n'est pas prise en compte
- (void)testRequetePathPrefixe
{
    // Récupération du managed object context et de l'object manager
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // Configuration de la requête monument/all/
    [objectManager addResponseDescriptor:[PLRestKitMonumentAll responseDescriptor]];
    [objectManager addFetchRequestBlock:[PLRestKitMonumentAll fetchRequestBlock]];
    
    // Construction de la requête
    NSURL *URL = [NSURL URLWithString:@"monument/all/?name=1_ok" relativeToURL:objectManager.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    RKManagedObjectRequestOperation *requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Construction de la 2e requête
    URL = [NSURL URLWithString:@"truc/monument/all/" relativeToURL:objectManager.baseURL];
    request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Vérification que la requête a réussi mais n'a pas été prise en compte
    XCTAssertEqual(200, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    XCTAssertNotNil(requestOperation.error, @"");
    XCTAssertEqual(1001, [requestOperation.error code], @"");
    
    // Vérification du nombre d'objets reçus
    XCTAssertEqual(0, [requestOperation.mappingResult count], @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(4, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    PLMonument *monument1 = [fetchedMonuments objectAtIndex:0];     // Famille d'Aboville
    PLMonument *monument2 = [fetchedMonuments objectAtIndex:1];     // Jim Morrison
    PLMonument *monument3 = [fetchedMonuments objectAtIndex:2];     // Mur des Fédérés
    
    // Vérification de la correspondance du résultat
    
    // Monuments
    XCTAssertEqualObjects(@(227), monument1.id, @"");
    XCTAssertEqualObjects(@(120), monument2.id, @"");
    XCTAssertEqualObjects(@(164), monument3.id, @"");
    
    // Nodes OSM
    XCTAssertEqualObjects(@(2649596674), monument1.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1915793663), monument2.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1152422864), monument3.nodeOSM.id, @"");
    
    // Images Commons
    XCTAssertEqualObjects(@(1), monument1.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(129), monument2.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(200), monument3.imagePrincipale.id, @"");
    
    // Personnalités
    XCTAssertEqual(3, [monument1.personnalites count], @"");
    XCTAssertEqual(1, [monument2.personnalites count], @"");
    XCTAssertEqual(0, [monument3.personnalites count], @"");
    XCTAssertEqualObjects(@(272), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:0]).id, @"");
    XCTAssertEqualObjects(@(273), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:1]).id, @"");
    XCTAssertEqualObjects(@(230), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:2]).id, @"");
    XCTAssertEqualObjects(@(120), ((PLPersonnalite *)[monument2.personnalites objectAtIndex:0]).id, @"");
}

// Vérifie qu'une requête avec un mauvais chemin relatif (suffixe) n'est pas prise en compte
- (void)testRequetePathSuffixe
{
    // Récupération du managed object context et de l'object manager
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // Configuration de la requête monument/all/
    [objectManager addResponseDescriptor:[PLRestKitMonumentAll responseDescriptor]];
    [objectManager addFetchRequestBlock:[PLRestKitMonumentAll fetchRequestBlock]];
    
    // Construction de la requête
    NSURL *URL = [NSURL URLWithString:@"monument/all/?name=1_ok" relativeToURL:objectManager.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    RKManagedObjectRequestOperation *requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Construction de la 2e requête
    URL = [NSURL URLWithString:@"monument/all/truc/" relativeToURL:objectManager.baseURL];
    request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Vérification que la requête a réussi mais n'a pas été prise en compte
    XCTAssertEqual(200, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    XCTAssertNotNil(requestOperation.error, @"");
    XCTAssertEqual(1001, [requestOperation.error code], @"");
    
    // Vérification du nombre d'objets reçus
    XCTAssertEqual(0, [requestOperation.mappingResult count], @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(4, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    PLMonument *monument1 = [fetchedMonuments objectAtIndex:0];     // Famille d'Aboville
    PLMonument *monument2 = [fetchedMonuments objectAtIndex:1];     // Jim Morrison
    PLMonument *monument3 = [fetchedMonuments objectAtIndex:2];     // Mur des Fédérés
    
    // Vérification de la correspondance du résultat
    
    // Monuments
    XCTAssertEqualObjects(@(227), monument1.id, @"");
    XCTAssertEqualObjects(@(120), monument2.id, @"");
    XCTAssertEqualObjects(@(164), monument3.id, @"");
    
    // Nodes OSM
    XCTAssertEqualObjects(@(2649596674), monument1.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1915793663), monument2.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1152422864), monument3.nodeOSM.id, @"");
    
    // Images Commons
    XCTAssertEqualObjects(@(1), monument1.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(129), monument2.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(200), monument3.imagePrincipale.id, @"");
    
    // Personnalités
    XCTAssertEqual(3, [monument1.personnalites count], @"");
    XCTAssertEqual(1, [monument2.personnalites count], @"");
    XCTAssertEqual(0, [monument3.personnalites count], @"");
    XCTAssertEqualObjects(@(272), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:0]).id, @"");
    XCTAssertEqualObjects(@(273), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:1]).id, @"");
    XCTAssertEqualObjects(@(230), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:2]).id, @"");
    XCTAssertEqualObjects(@(120), ((PLPersonnalite *)[monument2.personnalites objectAtIndex:0]).id, @"");
}

// Vérifie qu'une requête avec un mauvais chemin relatif (différent) n'est pas prise en compte
- (void)testRequetePathAutre
{
    // Récupération du managed object context et de l'object manager
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // Configuration de la requête monument/all/
    [objectManager addResponseDescriptor:[PLRestKitMonumentAll responseDescriptor]];
    [objectManager addFetchRequestBlock:[PLRestKitMonumentAll fetchRequestBlock]];
    
    // Construction de la requête
    NSURL *URL = [NSURL URLWithString:@"monument/all/?name=1_ok" relativeToURL:objectManager.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    RKManagedObjectRequestOperation *requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Construction de la 2e requête
    URL = [NSURL URLWithString:@"truc/" relativeToURL:objectManager.baseURL];
    request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Vérification que la requête a réussi mais n'a pas été prise en compte
    XCTAssertEqual(200, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    XCTAssertNotNil(requestOperation.error, @"");
    XCTAssertEqual(1001, [requestOperation.error code], @"");
    
    // Vérification du nombre d'objets reçus
    XCTAssertEqual(0, [requestOperation.mappingResult count], @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(4, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    PLMonument *monument1 = [fetchedMonuments objectAtIndex:0];     // Famille d'Aboville
    PLMonument *monument2 = [fetchedMonuments objectAtIndex:1];     // Jim Morrison
    PLMonument *monument3 = [fetchedMonuments objectAtIndex:2];     // Mur des Fédérés
    
    // Vérification de la correspondance du résultat
    
    // Monuments
    XCTAssertEqualObjects(@(227), monument1.id, @"");
    XCTAssertEqualObjects(@(120), monument2.id, @"");
    XCTAssertEqualObjects(@(164), monument3.id, @"");
    
    // Nodes OSM
    XCTAssertEqualObjects(@(2649596674), monument1.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1915793663), monument2.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1152422864), monument3.nodeOSM.id, @"");
    
    // Images Commons
    XCTAssertEqualObjects(@(1), monument1.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(129), monument2.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(200), monument3.imagePrincipale.id, @"");
    
    // Personnalités
    XCTAssertEqual(3, [monument1.personnalites count], @"");
    XCTAssertEqual(1, [monument2.personnalites count], @"");
    XCTAssertEqual(0, [monument3.personnalites count], @"");
    XCTAssertEqualObjects(@(272), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:0]).id, @"");
    XCTAssertEqualObjects(@(273), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:1]).id, @"");
    XCTAssertEqualObjects(@(230), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:2]).id, @"");
    XCTAssertEqualObjects(@(120), ((PLPersonnalite *)[monument2.personnalites objectAtIndex:0]).id, @"");
}

// Vérifie qu'une requête renvoyant un code d'erreur 404 n'est pas prise en compte
- (void)testRequete404
{
    // Récupération du managed object context et de l'object manager
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // Configuration de la requête monument/all/
    [objectManager addResponseDescriptor:[PLRestKitMonumentAll responseDescriptor]];
    [objectManager addFetchRequestBlock:[PLRestKitMonumentAll fetchRequestBlock]];
    
    // Construction de la requête
    NSURL *URL = [NSURL URLWithString:@"monument/all/?name=1_ok" relativeToURL:objectManager.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    RKManagedObjectRequestOperation *requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Construction de la 2e requête
    URL = [NSURL URLWithString:@"monument/all/?name=8_404" relativeToURL:objectManager.baseURL];
    request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Vérification que la requête a réussi mais n'a pas été prise en compte
    XCTAssertEqual(404, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    XCTAssertNotNil(requestOperation.error, @"");
    XCTAssertEqual(-1011, [requestOperation.error code], @"");
    
    // Vérification du nombre d'objets reçus
    XCTAssertEqual(0, [requestOperation.mappingResult count], @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(4, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    PLMonument *monument1 = [fetchedMonuments objectAtIndex:0];     // Famille d'Aboville
    PLMonument *monument2 = [fetchedMonuments objectAtIndex:1];     // Jim Morrison
    PLMonument *monument3 = [fetchedMonuments objectAtIndex:2];     // Mur des Fédérés
    
    // Vérification de la correspondance du résultat
    
    // Monuments
    XCTAssertEqualObjects(@(227), monument1.id, @"");
    XCTAssertEqualObjects(@(120), monument2.id, @"");
    XCTAssertEqualObjects(@(164), monument3.id, @"");
    
    // Nodes OSM
    XCTAssertEqualObjects(@(2649596674), monument1.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1915793663), monument2.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1152422864), monument3.nodeOSM.id, @"");
    
    // Images Commons
    XCTAssertEqualObjects(@(1), monument1.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(129), monument2.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(200), monument3.imagePrincipale.id, @"");
    
    // Personnalités
    XCTAssertEqual(3, [monument1.personnalites count], @"");
    XCTAssertEqual(1, [monument2.personnalites count], @"");
    XCTAssertEqual(0, [monument3.personnalites count], @"");
    XCTAssertEqualObjects(@(272), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:0]).id, @"");
    XCTAssertEqualObjects(@(273), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:1]).id, @"");
    XCTAssertEqualObjects(@(230), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:2]).id, @"");
    XCTAssertEqualObjects(@(120), ((PLPersonnalite *)[monument2.personnalites objectAtIndex:0]).id, @"");
}

// Vérifie qu'une requête renvoyant un code d'erreur 500 n'est pas prise en compte
- (void)testRequete500
{
    // Récupération du managed object context et de l'object manager
    NSManagedObjectContext *managedObjectContext = [[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    // Configuration de la requête monument/all/
    [objectManager addResponseDescriptor:[PLRestKitMonumentAll responseDescriptor]];
    [objectManager addFetchRequestBlock:[PLRestKitMonumentAll fetchRequestBlock]];
    
    // Construction de la requête
    NSURL *URL = [NSURL URLWithString:@"monument/all/?name=1_ok" relativeToURL:objectManager.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    RKManagedObjectRequestOperation *requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Construction de la 2e requête
    URL = [NSURL URLWithString:@"monument/all/?name=9_500" relativeToURL:objectManager.baseURL];
    request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    requestOperation = [objectManager managedObjectRequestOperationWithRequest:request managedObjectContext:[[RKTestFactory managedObjectStore] persistentStoreManagedObjectContext] success:nil failure:nil];
    
    // Exécution de la requête
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    // Vérification que la requête a réussi mais n'a pas été prise en compte
    XCTAssertEqual(500, requestOperation.HTTPRequestOperation.response.statusCode, @"");
    XCTAssertNotNil(requestOperation.error, @"");
    XCTAssertEqual(-1011, [requestOperation.error code], @"");
    
    // Vérification du nombre d'objets reçus
    XCTAssertEqual(0, [requestOperation.mappingResult count], @"");
    
    // Vérification du nombre d'objets enregistrés
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLMonument" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLNodeOSM" predicate:nil error:nil], @"");
    XCTAssertEqual(4, [managedObjectContext countForEntityForName:@"PLPersonnalite" predicate:nil error:nil], @"");
    XCTAssertEqual(3, [managedObjectContext countForEntityForName:@"PLImageCommons" predicate:nil error:nil], @"");
    
    // Récupération des objets enregistrés
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES]]];
    NSArray *fetchedMonuments = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    PLMonument *monument1 = [fetchedMonuments objectAtIndex:0];     // Famille d'Aboville
    PLMonument *monument2 = [fetchedMonuments objectAtIndex:1];     // Jim Morrison
    PLMonument *monument3 = [fetchedMonuments objectAtIndex:2];     // Mur des Fédérés
    
    // Vérification de la correspondance du résultat
    
    // Monuments
    XCTAssertEqualObjects(@(227), monument1.id, @"");
    XCTAssertEqualObjects(@(120), monument2.id, @"");
    XCTAssertEqualObjects(@(164), monument3.id, @"");
    
    // Nodes OSM
    XCTAssertEqualObjects(@(2649596674), monument1.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1915793663), monument2.nodeOSM.id, @"");
    XCTAssertEqualObjects(@(1152422864), monument3.nodeOSM.id, @"");
    
    // Images Commons
    XCTAssertEqualObjects(@(1), monument1.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(129), monument2.imagePrincipale.id, @"");
    XCTAssertEqualObjects(@(200), monument3.imagePrincipale.id, @"");
    
    // Personnalités
    XCTAssertEqual(3, [monument1.personnalites count], @"");
    XCTAssertEqual(1, [monument2.personnalites count], @"");
    XCTAssertEqual(0, [monument3.personnalites count], @"");
    XCTAssertEqualObjects(@(272), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:0]).id, @"");
    XCTAssertEqualObjects(@(273), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:1]).id, @"");
    XCTAssertEqualObjects(@(230), ((PLPersonnalite *)[monument1.personnalites objectAtIndex:2]).id, @"");
    XCTAssertEqualObjects(@(120), ((PLPersonnalite *)[monument2.personnalites objectAtIndex:0]).id, @"");
}

@end
