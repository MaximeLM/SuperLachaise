//
//  PLRestKitConfiguration.m
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

#import "PLRestKitConfiguration.h"
#import "PLConfiguration.h"
#import "PLRestKitMapping.h"

@interface PLRestKitConfiguration ()

// Construit l'instance de la classe RKObjectManager
+ (RKObjectManager *)objectManagerForPL;

// Construit l'instance de la classe RKManagedObjectStore
+ (RKManagedObjectStore *)managedObjectStoreForPL;

@end

#pragma mark -

@implementation PLRestKitConfiguration

+ (void)configureObjectManager
{
    PLTraceIn(@"");
    
    if (![RKObjectManager sharedManager]) {
        // Construction de l'instance partagée
        [PLRestKitConfiguration objectManagerForPL];
    }
    
#ifdef DEBUG
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    PLTraceOut(@"objectManager: %@",objectManager);
    NSAssert(objectManager, @"");
#endif
    
}

+ (RKObjectManager *)objectManagerForPL
{
    PLTraceIn(@"");
    
    // Récupération de l'URL du web service
    NSString *webServiceStr = (NSString *)[PLConfiguration valueForKeyPath:@"URL Web Service - dev"];
    
    NSURL *webServiceURL = [NSURL URLWithString:webServiceStr];
    PLInfo(@"URL Web Service : %@", webServiceURL);
    
    // Création de l'object manager
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:webServiceURL];
    
    // Activation de l'indicateur d'activité
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Construction du RKManagedObjectStore
    objectManager.managedObjectStore = [PLRestKitConfiguration managedObjectStoreForPL];
    
    PLTraceOut(@"result: %@",objectManager);
    NSAssert(objectManager, @"");
    return objectManager;
}

+ (RKManagedObjectStore *)managedObjectStoreForPL
{
    // Initialisation Core Data
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    // Configuration de la base SQLite
    [managedObjectStore createPersistentStoreCoordinator];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"PLData.sqlite"];
    NSString *seedPath = [[NSBundle mainBundle] pathForResource:@"PLDataSeed" ofType:@"sqlite"];
    
    NSError *error;
#ifdef DEBUG
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:seedPath withConfiguration:nil options:nil error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
#else
    [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:seedPath withConfiguration:nil options:nil error:&error];
#endif
    
    // Fin de l'initialisation
    [managedObjectStore createManagedObjectContexts];
    
    return managedObjectStore;
}

+ (void)createSeedDatabase
{
    PLTraceIn(@"");
    
    PLInfo(@"Création de la base de données seed");
    
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelInfo);
    RKLogConfigureByName("RestKit/CoreData", RKLogLevelTrace);
    
    NSManagedObjectModel *managedObjectModel = [RKManagedObjectStore defaultStore].managedObjectModel;
    
    NSError *error = nil;
    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
    if (! success) {
        RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
    }
    NSString *seedStorePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"PLDataSeed.sqlite"];
    RKManagedObjectImporter *importer = [[RKManagedObjectImporter alloc] initWithManagedObjectModel:managedObjectModel storePath:seedStorePath];
    [importer importObjectsFromItemAtPath:[[NSBundle mainBundle] pathForResource:@"PLData" ofType:@"json"]
                              withMapping:[PLRestKitMapping monumentMapping]
                                  keyPath:nil
                                    error:&error];
    
    success = [importer finishImporting:&error];
    if (success) {
        [importer logSeedingInfo];
    } else {
        RKLogError(@"Failed to finish import and save seed database due to error: %@", error);
    }
    
    PLTraceOut(@"");
}

@end
