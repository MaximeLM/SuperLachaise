//
//  PLPersonnalite+ext.m
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

#import "PLPersonnalite+ext.h"

static NSDateFormatter *anneeDateFormatter = nil;
static NSDateFormatter *moisDateFormatter = nil;
static NSDateFormatter *jourDateFormatter = nil;

@implementation PLPersonnalite (ext)

#pragma mark - Propriétés dérivées

- (NSString *)dateNaissanceCourte
{
    PLTraceIn(@"");
    NSString *result = [[PLPersonnalite anneeDateFormatter] stringFromDate:self.dateNaissance];
    
    PLTraceOut(@"result: %@", result);
    return result;
}

- (NSString *)dateDecesCourte
{
    PLTraceIn(@"");
    NSString *result = [[PLPersonnalite anneeDateFormatter] stringFromDate:self.dateDeces];
    
    PLTraceOut(@"result: %@", result);
    return result;
}

- (NSString *)dateNaissanceLongue
{
    PLTraceIn(@"précision: %@", self.dateNaissancePrecision);
    
    NSString *result;
    if ([self.dateNaissancePrecision isEqualToString:@"A"]) {
        PLTrace(@"précision à l'année");
        result = [[PLPersonnalite anneeDateFormatter] stringFromDate:self.dateNaissance];
    } else if ([self.dateNaissancePrecision isEqualToString:@"M"]) {
        PLTrace(@"précision au mois");
        result = [[PLPersonnalite moisDateFormatter] stringFromDate:self.dateNaissance];
    } else if ([self.dateNaissancePrecision isEqualToString:@"J"]) {
        PLTrace(@"précision au jour");
        result = [[PLPersonnalite jourDateFormatter] stringFromDate:self.dateNaissance];
    } else {
        NSAssert(NO, @"");
    }
    
    PLTraceOut(@"result: %@", result);
    return result;
}

- (NSString *)dateDecesLongue
{
    PLTraceIn(@"précision: %@", self.dateDecesPrecision);
    
    NSString *result;
    if ([self.dateDecesPrecision isEqualToString:@"A"]) {
        PLTrace(@"précision à l'année");
        result = [[PLPersonnalite anneeDateFormatter] stringFromDate:self.dateDeces];
    } else if ([self.dateDecesPrecision isEqualToString:@"M"]) {
        PLTrace(@"précision au mois");
        result = [[PLPersonnalite moisDateFormatter] stringFromDate:self.dateDeces];
    } else if ([self.dateDecesPrecision isEqualToString:@"J"]) {
        PLTrace(@"précision au jour");
        result = [[PLPersonnalite jourDateFormatter] stringFromDate:self.dateDeces];
    } else {
        NSAssert(NO, @"");
    }
    
    PLTraceOut(@"result: %@", result);
    return result;
}

- (BOOL)hasAllDates
{
    PLTraceIn(@"");
    BOOL result = self.dateNaissance && self.dateDeces;
    
    PLTraceOut(@"result: %d", result);
    return result;
}

- (BOOL)hasDate
{
    PLTraceIn(@"");
    BOOL result = self.dateNaissance || self.dateDeces;
    
    PLTraceOut(@"result: %d", result);
    return result;
}

#pragma mark - Formatteurs de dates

+ (NSDateFormatter *)anneeDateFormatter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        anneeDateFormatter = [[NSDateFormatter alloc] init];
        anneeDateFormatter.dateFormat = @"yyyy";
    });
    
    return anneeDateFormatter;
}

+ (NSDateFormatter *)moisDateFormatter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        moisDateFormatter = [[NSDateFormatter alloc] init];
        moisDateFormatter.dateFormat = @"MMMM yyyy";
    });
    
    return moisDateFormatter;
}

+ (NSDateFormatter *)jourDateFormatter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jourDateFormatter = [[NSDateFormatter alloc] init];
        jourDateFormatter.dateStyle = NSDateFormatterLongStyle;
    });
    
    return jourDateFormatter;
}

@end
