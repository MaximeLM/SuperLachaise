//
//  PLNodeOSM+ext.m
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

#import "PLNodeOSM+ext.h"

@implementation PLNodeOSM (ext)

- (CLLocationCoordinate2D)coordinates
{
    PLTraceIn(@"");
    
    CLLocationCoordinate2D result = CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
    
    PLTraceOut(@"result: %f %f", result.latitude, result.longitude);
    return result;
}

@end
