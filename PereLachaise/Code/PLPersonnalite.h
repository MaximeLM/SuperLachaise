//
//  Personnalite.h
//  PereLachaise
//
//  Created by Maxime Le Moine on 16/03/2014.
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PLMonument;

@interface PLPersonnalite : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * nom;
@property (nonatomic, retain) NSString * codeWikipedia;
@property (nonatomic, retain) NSString * activite;
@property (nonatomic, retain) NSString * resume;
@property (nonatomic, retain) NSDate * dateNaissance;
@property (nonatomic, retain) NSDate * dateDeces;
@property (nonatomic, retain) NSString * dateNaissancePrecision;
@property (nonatomic, retain) NSString * dateDecesPrecision;
@property (nonatomic, retain) PLMonument *monument;

@end
