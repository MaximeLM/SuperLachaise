//
//  PLRestKitConfigurationTestCase.m
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
#import "PLConfiguration.h"

// Classe de tests de la classe PLRestKitConfiguration
@interface PLRestKitConfigurationTestCase : XCTestCase

@end

@implementation PLRestKitConfigurationTestCase

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [RKTestFactory tearDown];
    [super tearDown];
}

#pragma mark - Configuration du TestCase

// Vérifie que l'instance partagée de RKObjectManager est supprimée après chaque test
- (void)testTearDown
{
    // Création de l'instance partagée
    [PLRestKitConfiguration configureObjectManager];
    XCTAssertNotNil([RKObjectManager sharedManager], @"");
    
    // Méthode teardown
    [self tearDown];
    XCTAssertNil([RKObjectManager sharedManager], @"");
}

#pragma mark - configureObjectManager

// Vérifie que la méthode configureObjectManager créée l'instance partagée de RKObjectManager
- (void)testConfigureObjectManagerCreation
{
    [PLRestKitConfiguration configureObjectManager];
    
    XCTAssertNotNil([RKObjectManager sharedManager], @"");
}

// Vérifie que des appels successifs à la méthode configureObjectManager ne modifient pas l'instance partagée
- (void)testConfigureObjectManagerAppelsMultiples
{
    // Création et récupération de l'instance partagée
    [PLRestKitConfiguration configureObjectManager];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    XCTAssertNotNil(objectManager, @"");
    
    // Nouvel appel à la méthode
    [PLRestKitConfiguration configureObjectManager];
    
    // Vérifie que l'instance partagée est toujours la même
    XCTAssertEqualObjects(objectManager, [RKObjectManager sharedManager], @"");
}

// Vérifie que l'instance partagée de RKObjectManager est correctement construite
- (void)testConfigureObjectManagerAttributs
{
    // Création et récupération de l'instance partagée
    [PLRestKitConfiguration configureObjectManager];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    XCTAssertNotNil(objectManager, @"");
    
    // Base URL
    NSString *baseURLFromConfiguration = (NSString *)[PLConfiguration valueForKeyPath:@"URL Web Service - dev"];
    XCTAssertEqualObjects([NSURL URLWithString:baseURLFromConfiguration], objectManager.baseURL, @"");
    
    // Managed object store
    XCTAssertNotNil(objectManager.managedObjectStore, @"");
}

@end
