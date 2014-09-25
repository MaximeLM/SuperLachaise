//
//  PLRectangularRegion.m
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

#import "PLRectangularRegion.h"

@implementation PLRectangularRegion

- (NSString *)description
{
    return [NSString stringWithFormat:@"<PLRectangularRegion>"];
}

- (id)initWithLimiteSudOuest:(CLLocationCoordinate2D)limiteSudOuest etNordEst:(CLLocationCoordinate2D)limiteNordEst
{
    PLTraceIn(@"limiteSudOuest: %f %f - limiteNordEst %f %f", limiteSudOuest.latitude, limiteSudOuest.longitude, limiteNordEst.latitude, limiteNordEst.longitude);
    
    id result;
    
    if (limiteSudOuest.latitude < limiteNordEst.latitude
        && limiteSudOuest.longitude < limiteNordEst.longitude) {
        self = [super init];
        
        if (self) {
            self.limiteSudOuest = limiteSudOuest;
            self.limiteNordEst = limiteNordEst;
        }
        
        result = self;
    } else {
        PLWarning(@"limites non valides");
        result = nil;
    }
    
    PLTraceOut(@"result: %@", result);
    return result;
}

- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate
{
    PLTraceIn(@"coordinates: latitude %f - longitude %f", coordinate.latitude, coordinate.longitude);
    
    BOOL result = coordinate.latitude > self.limiteSudOuest.latitude
                && coordinate.longitude > self.limiteSudOuest.longitude
                && coordinate.latitude < self.limiteNordEst.latitude
                && coordinate.longitude < self.limiteNordEst.longitude;
    
    PLTraceOut(@"result: %d", result);
    return result;
}

@end
