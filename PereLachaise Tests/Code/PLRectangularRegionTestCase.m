//
//  PLRectangularRegionTestCase.m
//  PereLachaise
//
//  Created by Maxime Le Moine on 28/08/2014.
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

#import "PLRectangularRegion.h"

@interface PLRectangularRegionTestCase : XCTestCase

@property (nonatomic) CLLocationDegrees latitudeMin;
@property (nonatomic) CLLocationDegrees longitudeMin;
@property (nonatomic) CLLocationDegrees latitudeMax;
@property (nonatomic) CLLocationDegrees longitudeMax;

@end

@implementation PLRectangularRegionTestCase

- (void)setUp
{
    [super setUp];
    
    self.latitudeMin = 48.851187;
    self.longitudeMin = 2.382292;
    self.latitudeMax = 48.869483;
    self.longitudeMax = 2.406339;
}

#pragma mark - initWithLimiteSudOuestetNordEst

// Cas nominal
- (void)testInitWithLimiteSudOuestetNordEst_OK
{
    CLLocationCoordinate2D limiteSudOuest = CLLocationCoordinate2DMake(self.latitudeMin, self.longitudeMin);
    CLLocationCoordinate2D limiteNordEst = CLLocationCoordinate2DMake(self.latitudeMax, self.longitudeMax);
    
    PLRectangularRegion *region = [[PLRectangularRegion alloc] initWithLimiteSudOuest:limiteSudOuest etNordEst:limiteNordEst];
    
    // Vérification : la création a réussi
    XCTAssertNotNil(region, @"");
    
    // Vérification de la valeur des limites géographiques
    XCTAssertEqual(region.limiteSudOuest.latitude, self.latitudeMin, @"");
    XCTAssertEqual(region.limiteSudOuest.longitude, self.longitudeMin, @"");
    XCTAssertEqual(region.limiteNordEst.latitude, self.latitudeMax, @"");
    XCTAssertEqual(region.limiteNordEst.longitude, self.longitudeMax, @"");
}

// Cas : latitude min > latitude max
- (void)testInitWithLimiteSudOuestetNordEst_KO1
{
    CLLocationCoordinate2D limiteSudOuest = CLLocationCoordinate2DMake(self.latitudeMax, self.longitudeMin);
    CLLocationCoordinate2D limiteNordEst = CLLocationCoordinate2DMake(self.latitudeMin, self.longitudeMax);
    
    PLRectangularRegion *region = [[PLRectangularRegion alloc] initWithLimiteSudOuest:limiteSudOuest etNordEst:limiteNordEst];
    
    // Vérification : la création a échoué
    XCTAssertNil(region, @"");
}

// Cas : longitude min > longitude max
- (void)testInitWithLimiteSudOuestetNordEst_KO2
{
    CLLocationCoordinate2D limiteSudOuest = CLLocationCoordinate2DMake(self.latitudeMin, self.longitudeMax);
    CLLocationCoordinate2D limiteNordEst = CLLocationCoordinate2DMake(self.latitudeMax, self.longitudeMin);
    
    PLRectangularRegion *region = [[PLRectangularRegion alloc] initWithLimiteSudOuest:limiteSudOuest etNordEst:limiteNordEst];
    
    // Vérification : la création a échoué
    XCTAssertNil(region, @"");
}

// Cas : latitude min > latitude max et longitude min > longitude max
- (void)testInitWithLimiteSudOuestetNordEst_KO3
{
    CLLocationCoordinate2D limiteSudOuest = CLLocationCoordinate2DMake(self.latitudeMax, self.longitudeMax);
    CLLocationCoordinate2D limiteNordEst = CLLocationCoordinate2DMake(self.latitudeMin, self.longitudeMin);
    
    PLRectangularRegion *region = [[PLRectangularRegion alloc] initWithLimiteSudOuest:limiteSudOuest etNordEst:limiteNordEst];
    
    // Vérification : la création a échoué
    XCTAssertNil(region, @"");
}

#pragma mark - containsCoordinate

// Cas nominal : point dans la région
- (void)testContainsCoordinate_OK
{
    // Création de la région
    CLLocationCoordinate2D limiteSudOuest = CLLocationCoordinate2DMake(self.latitudeMin, self.longitudeMin);
    CLLocationCoordinate2D limiteNordEst = CLLocationCoordinate2DMake(self.latitudeMax, self.longitudeMax);
    PLRectangularRegion *region = [[PLRectangularRegion alloc] initWithLimiteSudOuest:limiteSudOuest etNordEst:limiteNordEst];
    
    // Création du point
    CLLocationCoordinate2D testCoordinate = CLLocationCoordinate2DMake(48.860000, 2.400000);
    
    // Test
    XCTAssertTrue([region containsCoordinate:testCoordinate], @"");
}

// Cas KO : point au NO
- (void)testContainsCoordinate_KO1
{
    // Création de la région
    CLLocationCoordinate2D limiteSudOuest = CLLocationCoordinate2DMake(self.latitudeMin, self.longitudeMin);
    CLLocationCoordinate2D limiteNordEst = CLLocationCoordinate2DMake(self.latitudeMax, self.longitudeMax);
    PLRectangularRegion *region = [[PLRectangularRegion alloc] initWithLimiteSudOuest:limiteSudOuest etNordEst:limiteNordEst];
    
    // Création du point
    CLLocationCoordinate2D testCoordinate = CLLocationCoordinate2DMake(47.860000, 3.400000);
    
    // Test
    XCTAssertFalse([region containsCoordinate:testCoordinate], @"");
}

// Cas KO : point au N
- (void)testContainsCoordinate_KO2
{
    // Création de la région
    CLLocationCoordinate2D limiteSudOuest = CLLocationCoordinate2DMake(self.latitudeMin, self.longitudeMin);
    CLLocationCoordinate2D limiteNordEst = CLLocationCoordinate2DMake(self.latitudeMax, self.longitudeMax);
    PLRectangularRegion *region = [[PLRectangularRegion alloc] initWithLimiteSudOuest:limiteSudOuest etNordEst:limiteNordEst];
    
    // Création du point
    CLLocationCoordinate2D testCoordinate = CLLocationCoordinate2DMake(48.860000, 3.400000);
    
    // Test
    XCTAssertFalse([region containsCoordinate:testCoordinate], @"");
}

// Cas KO : point au NE
- (void)testContainsCoordinate_KO3
{
    // Création de la région
    CLLocationCoordinate2D limiteSudOuest = CLLocationCoordinate2DMake(self.latitudeMin, self.longitudeMin);
    CLLocationCoordinate2D limiteNordEst = CLLocationCoordinate2DMake(self.latitudeMax, self.longitudeMax);
    PLRectangularRegion *region = [[PLRectangularRegion alloc] initWithLimiteSudOuest:limiteSudOuest etNordEst:limiteNordEst];
    
    // Création du point
    CLLocationCoordinate2D testCoordinate = CLLocationCoordinate2DMake(49.860000, 3.400000);
    
    // Test
    XCTAssertFalse([region containsCoordinate:testCoordinate], @"");
}

// Cas KO : point à l'E
- (void)testContainsCoordinate_KO4
{
    // Création de la région
    CLLocationCoordinate2D limiteSudOuest = CLLocationCoordinate2DMake(self.latitudeMin, self.longitudeMin);
    CLLocationCoordinate2D limiteNordEst = CLLocationCoordinate2DMake(self.latitudeMax, self.longitudeMax);
    PLRectangularRegion *region = [[PLRectangularRegion alloc] initWithLimiteSudOuest:limiteSudOuest etNordEst:limiteNordEst];
    
    // Création du point
    CLLocationCoordinate2D testCoordinate = CLLocationCoordinate2DMake(49.860000, 2.400000);
    
    // Test
    XCTAssertFalse([region containsCoordinate:testCoordinate], @"");
}

// Cas KO : point au SE
- (void)testContainsCoordinate_KO5
{
    // Création de la région
    CLLocationCoordinate2D limiteSudOuest = CLLocationCoordinate2DMake(self.latitudeMin, self.longitudeMin);
    CLLocationCoordinate2D limiteNordEst = CLLocationCoordinate2DMake(self.latitudeMax, self.longitudeMax);
    PLRectangularRegion *region = [[PLRectangularRegion alloc] initWithLimiteSudOuest:limiteSudOuest etNordEst:limiteNordEst];
    
    // Création du point
    CLLocationCoordinate2D testCoordinate = CLLocationCoordinate2DMake(49.860000, 1.400000);
    
    // Test
    XCTAssertFalse([region containsCoordinate:testCoordinate], @"");
}

// Cas KO : point au S
- (void)testContainsCoordinate_KO6
{
    // Création de la région
    CLLocationCoordinate2D limiteSudOuest = CLLocationCoordinate2DMake(self.latitudeMin, self.longitudeMin);
    CLLocationCoordinate2D limiteNordEst = CLLocationCoordinate2DMake(self.latitudeMax, self.longitudeMax);
    PLRectangularRegion *region = [[PLRectangularRegion alloc] initWithLimiteSudOuest:limiteSudOuest etNordEst:limiteNordEst];
    
    // Création du point
    CLLocationCoordinate2D testCoordinate = CLLocationCoordinate2DMake(48.860000, 1.400000);
    
    // Test
    XCTAssertFalse([region containsCoordinate:testCoordinate], @"");
}

// Cas KO : point au SO
- (void)testContainsCoordinate_KO7
{
    // Création de la région
    CLLocationCoordinate2D limiteSudOuest = CLLocationCoordinate2DMake(self.latitudeMin, self.longitudeMin);
    CLLocationCoordinate2D limiteNordEst = CLLocationCoordinate2DMake(self.latitudeMax, self.longitudeMax);
    PLRectangularRegion *region = [[PLRectangularRegion alloc] initWithLimiteSudOuest:limiteSudOuest etNordEst:limiteNordEst];
    
    // Création du point
    CLLocationCoordinate2D testCoordinate = CLLocationCoordinate2DMake(47.860000, 1.400000);
    
    // Test
    XCTAssertFalse([region containsCoordinate:testCoordinate], @"");
}

// Cas KO : point à l'O
- (void)testContainsCoordinate_KO8
{
    // Création de la région
    CLLocationCoordinate2D limiteSudOuest = CLLocationCoordinate2DMake(self.latitudeMin, self.longitudeMin);
    CLLocationCoordinate2D limiteNordEst = CLLocationCoordinate2DMake(self.latitudeMax, self.longitudeMax);
    PLRectangularRegion *region = [[PLRectangularRegion alloc] initWithLimiteSudOuest:limiteSudOuest etNordEst:limiteNordEst];
    
    // Création du point
    CLLocationCoordinate2D testCoordinate = CLLocationCoordinate2DMake(47.860000, 2.400000);
    
    // Test
    XCTAssertFalse([region containsCoordinate:testCoordinate], @"");
}

@end
