//
//  RKTestFactory+PLTest.m
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

#import "RKTestFactory+PLTest.h"

#import "PLConfiguration.h"

@implementation RKTestFactory (PLTest)

// Méthode appelée au premier chargement de la classe
+ (void)load
{
    // URL du web service de test
    NSString *urlFixtures = (NSString *)[PLConfiguration valueForKeyPath:@"URL Web Service - fixture"];
    [RKTestFactory setBaseURL:[NSURL URLWithString:urlFixtures]];
    
    // Ajout de traitement de setup
    [RKTestFactory setSetupBlock:^{
        // Configuration managed object store et shared object manager
        [[RKTestFactory objectManager] setManagedObjectStore:[RKTestFactory managedObjectStore]];
        [RKObjectManager setSharedManager:[RKTestFactory objectManager]];
    }];
    
    // Ajout de traitement de teardown
    [RKTestFactory setTearDownBlock:^{
        // Suppression de toutes les entités enregistrées
        [[RKTestFactory managedObjectStore] resetPersistentStores:nil];
    }];
    
    // Remplace le constructeur par défaut du RKObjectManager pour récupérer le managed object model
    [RKTestFactory defineFactory:RKTestFactoryDefaultNamesManagedObjectStore withBlock:^id {
        NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:RKTestFactoryDefaultStoreFilename];
        
        // Récupération du managed object model dans le bundle principal
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:@[bundle]];
        
        RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
        NSError *error;
        NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
        if (persistentStore) {
            BOOL success = [managedObjectStore resetPersistentStores:&error];
            if (! success) {
                RKLogError(@"Failed to reset persistent store: %@", error);
            }
        }
        
        return managedObjectStore;
    }];
    
}

@end
