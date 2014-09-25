//
//  PLAppDelegate.m
//  PereLachaise
//
//  Created by Maxime Le Moine on 01/11/2013.
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

#import "RestKit.h"

#import "PLAppDelegate.h"
#import "PLRestKitConfiguration.h"

@implementation PLAppDelegate

- (NSString *)description
{
    return [NSString stringWithFormat:@"<PLAppDelegate>"];
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    PLTraceIn(@"");
    
    [PLRestKitConfiguration configureObjectManager];
    
#ifdef RESTKIT_GENERATE_SEED_DB
    // Création de la base de données seed
    [PLRestKitConfiguration createSeedDatabase];
#endif
    
    PLTraceOut(@"");
    return YES;
}

# pragma mark - RestKit

- (void)refreshMonuments
{
    PLTraceIn(@"");
    // GET tombe/
    [[RKObjectManager sharedManager] getObjectsAtPath:@"monument/all/" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        PLInfo(@"La requête a réussi.");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        PLWarning(@"La requête a échoué : %@", [error localizedDescription]);
        
#if TARGET_IPHONE_SIMULATOR
        // Affichage d'un pop-up d'erreur
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An Error Has Occurred" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
#endif
    }];
    PLTraceOut(@"");
}

@end
