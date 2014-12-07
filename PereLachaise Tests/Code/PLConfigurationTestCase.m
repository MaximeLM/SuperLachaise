//
//  PLConfigurationTestCase.m
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

#import "PLConfiguration.h"

// Classe de tests de la classe PLConfiguration
@interface PLConfigurationTestCase : XCTestCase

@end

@implementation PLConfigurationTestCase

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - sharedDictionary

// Vérifie que la méthode sharedDictionary renvoie un résultat conforme
- (void)testsharedDictionary
{
    // Récupération du dictionnaire
    NSDictionary *dictionary = [PLConfiguration sharedDictionary];
    XCTAssertNotNil(dictionary, @"");
    
    // 2e récupération du dictionnaire
    XCTAssertEqualObjects(dictionary, [PLConfiguration sharedDictionary], @"");
}

// Vérifie que le dictionnaire renvoie les valeurs de type NSString
- (void)testsharedDictionaryNSString
{
    // Récupération du dictionnaire
    NSDictionary *dictionary = [PLConfiguration sharedDictionary];
    
    // Récupération d'une valeur
    id result = [dictionary objectForKey:@"Map ID - release"];
    XCTAssertNotNil(result, @"");
    XCTAssertTrue([result isKindOfClass:[NSString class]], @"");
}

// Vérifie que le dictionnaire renvoie les valeurs de type NSDictionary
- (void)testsharedDictionaryNSDictionary
{
    // Récupération du dictionnaire
    NSDictionary *dictionary = [PLConfiguration sharedDictionary];
    
    // Récupération d'une valeur
    id result = [dictionary objectForKey:@"iPhone"];
    XCTAssertNotNil(result, @"");
    XCTAssertTrue([result isKindOfClass:[NSDictionary class]], @"");
}

// Vérifie que le dictionnaire renvoie les valeurs de type NSNumber
- (void)testsharedDictionaryNSNumber
{
    // Récupération du dictionnaire
    NSDictionary *dictionary = [PLConfiguration sharedDictionary];
    
    // Récupération d'une valeur
    NSDictionary *subDictionary = [dictionary objectForKey:@"iPhone"];
    id result = [subDictionary objectForKey:@"Zoom initial"];
    XCTAssertNotNil(result, @"");
    XCTAssertTrue([result isKindOfClass:[NSNumber class]], @"");
}

#pragma mark - valueForKeyPath

// Vérifie que la méthode valueForKeyPath renvoie les valeurs de type NSString
- (void)testValueForKeyPathNSString
{
    // Récupération d'une valeur
    id result = [PLConfiguration valueForKeyPath:@"Map ID - release"];
    XCTAssertNotNil(result, @"");
    XCTAssertTrue([result isKindOfClass:[NSString class]], @"");
}

// Vérifie que la méthode valueForKeyPath renvoie les valeurs de type NSDictionary
- (void)testValueForKeyPathNSDictionary
{
    // Récupération d'une valeur
    id result = [PLConfiguration valueForKeyPath:@"iPhone"];
    XCTAssertNotNil(result, @"");
    XCTAssertTrue([result isKindOfClass:[NSDictionary class]], @"");
}

// Vérifie que la méthode valueForKeyPath renvoie les valeurs de type NSNumber
- (void)testValueForKeyPathNSNumber
{
    // Récupération d'une valeur
    id result = [PLConfiguration valueForKeyPath:@"iPhone.Portrait.Latitude initiale"];
    XCTAssertNotNil(result, @"");
    XCTAssertTrue([result isKindOfClass:[NSNumber class]], @"");
}

// Vérifie que la méthode valueForKeyPath ne renvoie de résultat pour une mauvaise clé
- (void)testValueForKeyPathBadKey
{
    // Récupération d'une valeur
    id result = [PLConfiguration valueForKeyPath:@"iPhone.truc.Portrait.Latitude initiale"];
    XCTAssertNil(result, @"");
}

@end
