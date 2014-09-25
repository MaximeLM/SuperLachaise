//
//  PLRectangularRegion.h
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

#import <CoreLocation/CoreLocation.h>

// Définit une zone géographique rectangulaire
@interface PLRectangularRegion : CLRegion

// La limite sud-ouest
@property (nonatomic) CLLocationCoordinate2D limiteSudOuest;

// La limite nord-est
@property (nonatomic) CLLocationCoordinate2D limiteNordEst;

// Initialise la région à partir des coordonnées des coins SO et NE
// Renvoie nil si la région n'est pas valide
- (id)initWithLimiteSudOuest:(CLLocationCoordinate2D)limiteSudOuest etNordEst:(CLLocationCoordinate2D)limiteNordEst;

// Méthode surchargée pour éviter le warning de dépréciation
- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate;

@end
