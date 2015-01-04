//
//  PLSearchViewController.m
//  PereLachaise
//
//  Created by Maxime Le Moine on 06/12/2013.
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
#import "PLSearchViewController.h"

#import "PLMonument+ext.h"
#import "PLPersonnalite+ext.h"
#import "PLAppDelegate.h"
#import "PLDetailMonumentViewController.h"
#import "PLMonumentTableViewCell.h"
#import "PLIPadSplitViewController.h"
#import "PLDeprecatedMethods.h"

@interface PLSearchViewController () <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate>

#pragma mark - Chargement des monuments

@property (strong, nonatomic) NSFetchedResultsController *filteredFetchedResultsController;

#pragma mark - Sélection

@property (nonatomic, weak) PLMonument *selectedMonument;

#pragma mark - Controleurs de recherche

// iOS 7
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;

// iOS 8
@property (nonatomic, strong) UISearchController *mySearchController;

- (UITableView *)searchResultsTableView;

@end

#pragma mark -

@implementation PLSearchViewController

- (NSString *)description
{
    return [NSString stringWithFormat:@"<PLSearchViewController>"];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Création de la barre de recherche
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 44.0)];
    self.tableView.tableHeaderView = self.searchBar;
    
    self.mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.mySearchDisplayController.delegate = self;
    self.mySearchDisplayController.searchResultsDataSource = self;
    self.mySearchDisplayController.searchResultsDelegate = self;
    
    self.searchResultsTableView.backgroundColor = self.tableView.backgroundColor;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Corrige le bug de sélection qui reste parfois après retour de la vue détaillée
    if (PLIPhone) {
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (![self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    PLTraceIn(@"");
    
    [super didReceiveMemoryWarning];
    
    // Suppression du contrôleur de résultats filtré
    self.filteredFetchedResultsController = nil;
    
    PLTraceOut(@"");
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    PLTraceIn(@"identifier: %@", identifier);
    BOOL result = [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    
    if (PLIPad && [identifier isEqualToString:@"SearchToDetailSegue"]) {
        result = NO;
    }
    
    PLTraceOut(@"result: %d", result);
    return result;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PLTraceIn(@"");
    
    PLMonumentTableViewCell *cell = sender;
    PLMonument *monument = cell.monument;
    
    PLInfo(@"monument: %@", monument);
    
    PLDetailMonumentViewController *detailMonumentViewController = segue.destinationViewController;
    detailMonumentViewController.mapViewController = self.mapViewController;
    detailMonumentViewController.monument = monument;
    
    PLTraceOut(@"");
}

#pragma mark - Eléments d'interface

- (IBAction)doneButtonAction:(id)sender
{
    PLTraceIn(@"");
    
    [self.mapViewController closeListeMonuments];
    
    PLTraceOut(@"");
}

- (void)updateRowForMonument:(PLMonument *)monument
{
    PLTraceIn(@"");
    
    // Table non filtrée
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:monument];
    PLMonumentTableViewCell *cell = (PLMonumentTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell updateLabels];
    
    // Table filtrée
    indexPath = [self.filteredFetchedResultsController indexPathForObject:monument];
    cell = (PLMonumentTableViewCell *)[self.searchResultsTableView cellForRowAtIndexPath:indexPath];
    [cell updateLabels];
    
    PLTraceOut(@"");
}

#pragma mark - Chargement des monuments

- (NSFetchedResultsController *)fetchedResultsController
{
    PLTraceIn(@"");
    
    if (_fetchedResultsController != nil) {
        PLTraceOut(@"return 1: %@", _fetchedResultsController);
        return _fetchedResultsController;
    }
    
    PLInfo(@"Construction fetchedResultsController");
    
    // Création de la requête
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    
    NSSortDescriptor *descriptorNomPourTri = [NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *descriptorNom = [NSSortDescriptor sortDescriptorWithKey:@"nom" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    fetchRequest.sortDescriptors = @[descriptorNomPourTri, descriptorNom];
    
    // Création du controleur de la requête
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                            sectionNameKeyPath:@"premiereLettreNomPourTri"
                                                                                       cacheName:nil];
    [_fetchedResultsController setDelegate:self];
    
    // Initialisation de la requête
#ifdef DEBUG
    NSError *error = nil;
    BOOL fetchSuccessful = [_fetchedResultsController performFetch:&error];
    NSAssert(fetchSuccessful, [error localizedDescription]);
#else
    [_fetchedResultsController performFetch:nil];
#endif
    
    PLTraceOut(@"return 2: %@", _fetchedResultsController);
    return _fetchedResultsController;
}

- (NSFetchedResultsController *)filteredFetchedResultsController
{
    PLTraceIn(@"");
    
    if (_filteredFetchedResultsController != nil) {
        PLTraceOut(@"return 1: %@", _filteredFetchedResultsController);
        return _filteredFetchedResultsController;
    }
    
    PLInfo(@"Construction filteredFetchedResultsController");
    
    // Création de la requête
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    
    NSSortDescriptor *descriptorNomPourTri = [NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *descriptorNom = [NSSortDescriptor sortDescriptorWithKey:@"nom" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    fetchRequest.sortDescriptors = @[descriptorNomPourTri, descriptorNom];
    
    // Création du controleur de la requête
    _filteredFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                            sectionNameKeyPath:@"premiereLettreNomPourTri"
                                                                                       cacheName:nil];
    [_filteredFetchedResultsController setDelegate:self];
    
    // Initialisation de la requête
#ifdef DEBUG
    NSError *error = nil;
    BOOL fetchSuccessful = [_filteredFetchedResultsController performFetch:&error];
    NSAssert(fetchSuccessful, [error localizedDescription]);
#else
    [_filteredFetchedResultsController performFetch:nil];
#endif
    
    PLTraceOut(@"return 2: %@", _filteredFetchedResultsController);
    return _filteredFetchedResultsController;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    PLTraceIn(@"tableView: %@", tableView);
    
    NSInteger result;
    
    if (tableView == self.searchResultsTableView) {
        PLInfo(@"filteredFetchedResultsController");
        result = [[self.filteredFetchedResultsController sections] count];
    } else {
        PLInfo(@"fetchedResultsController");
        result = [[self.fetchedResultsController sections] count];
    }
    
    PLTraceOut(@"return: %d", result);
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PLTraceIn(@"tableView: %@ section: %d", tableView, section);
    
    NSInteger result;
    
    if (tableView == self.tableView) {
        PLInfo(@"fetchedResultsController");
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        result = [sectionInfo numberOfObjects];
    } else {
        PLInfo(@"filteredFetchedResultsController");
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.filteredFetchedResultsController sections][section];
        result = [sectionInfo numberOfObjects];
    }
    
    PLTraceOut(@"return: %d", result);
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLTraceIn(@"tableView: %@ indexPath: %@", tableView, indexPath);
    
    static NSString *kCellID = @"Monument Cell";
    
    // Dequeue a cell from self's table view.
	PLMonumentTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellID];
    
    PLMonument *monument = nil;
    
    if (tableView == self.tableView) {
        PLInfo(@"fetchedResultsController");
        monument = [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        PLInfo(@"filteredFetchedResultsController");
        monument = [self.filteredFetchedResultsController objectAtIndexPath:indexPath];
    }
    PLInfo(@"monument: %@", monument);
    
    cell.backgroundColor = [UIColor clearColor];
    if (PLIPad) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (monument == self.selectedMonument) {
            cell.backgroundColor = [PLMonumentTableViewCell colorForSelectedCell];
        }
    }
    
    cell.monument = monument;
    
    PLTraceOut(@"return: %@", cell);
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    PLTraceIn(@"tableView: %@ section: %d", tableView, section);
    
    NSString *result;
    
    if (tableView == self.tableView) {
        PLInfo(@"fetchedResultsController");
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        result = [sectionInfo name];
    } else {
        PLInfo(@"filteredFetchedResultsController");
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.filteredFetchedResultsController sections] objectAtIndex:section];
        result = [sectionInfo name];
    }
    
    PLTraceOut(@"return: %@", result);
    return result;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    PLTraceIn(@"tableView: %@", tableView);
    
    NSArray *result;
    if (tableView == self.tableView) {
        PLInfo(@"sectionIndexTitlesForTableView fetchedResultsController: %@", [self.fetchedResultsController sectionIndexTitles]);
        result = [self.fetchedResultsController sectionIndexTitles];
    } else {
        PLInfo(@"sectionIndexTitlesForTableView filteredFetchedResultsController: %@", [self.filteredFetchedResultsController sectionIndexTitles]);
        result = [self.filteredFetchedResultsController sectionIndexTitles];
    }
    
    PLTraceOut(@"return: %@", result);
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString
                                                                             *)title atIndex:(NSInteger)index {
    PLTraceIn(@"tableView: %@ title: %@ index: %d", tableView, title, index);
    
    NSInteger result;
    if (tableView == self.tableView) {
        PLInfo(@"sectionForSectionIndexTitle fetchedResultsController");
        result = [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
    } else {
        PLInfo(@"sectionForSectionIndexTitle filteredFetchedResultsController");
        result = [self.filteredFetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
    }
    
    PLTraceOut(@"return: %d", result);
    return result;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLTraceIn(@"tableView: %@ indexPath: %@", tableView, indexPath);
    // Return NO if you do not want the specified item to be editable.
    
    PLTraceOut(@"return: NO");
    return NO;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLTraceIn(@"");
    
    PLMonument *monument = nil;
    
    // Si texte coupé => augmenter offset
    // Si zone blanche sous texte => diminuer l'offet
    
    CGFloat offset;
    if (PLIPhone6p) {
        offset = 52.0;
    } else if (PLIPhone) {
        offset = 48.0;
    } else {
        offset = 68.0;
    }
    
    if (tableView == self.tableView) {
        PLInfo(@"fetchedResultsController");
        monument = [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        PLInfo(@"filteredFetchedResultsController");
        monument = [self.filteredFetchedResultsController objectAtIndexPath:indexPath];
    }
    PLInfo(@"monument: %@", monument);
    
    CGFloat result = [PLMonumentTableViewCell heightForWidth:(tableView.frame.size.width - offset) andMonument:monument];
    
    PLTraceOut(@"return: %f", result);
    return result;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLTraceIn(@"");
    
    if (PLIPhone) {
        [cell setBackgroundColor:[UIColor clearColor]];
    } else if (tableView == self.tableView) {
        PLIPadSplitViewController *iPadSplitViewController = (PLIPadSplitViewController *)self.navigationController.parentViewController;
        if (iPadSplitViewController.initialMonument) {
            NSIndexPath *indexPathForInitialMonument = [self.fetchedResultsController indexPathForObject:iPadSplitViewController.initialMonument];
            if ([indexPathForInitialMonument isEqual:indexPath]) {
                iPadSplitViewController.initialMonument = nil;
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                cell.backgroundColor = [PLMonumentTableViewCell colorForSelectedCell];
            }
        }
    }
    
    if(self.initialMonument && [indexPath row] == [tableView numberOfRowsInSection: [tableView numberOfSections] - 1] - 1){
        //end of loading
        NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:self.initialMonument];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        self.initialMonument = nil;
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    }
    
    PLTraceOut(@"");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLTraceIn(@"");
    
    PLMonument *monument = nil;
    NSIndexPath *oldIndexPath;
    if (tableView == self.tableView) {
        PLInfo(@"fetchedResultsController");
        monument = [self.fetchedResultsController objectAtIndexPath:indexPath];
        oldIndexPath = [self.fetchedResultsController indexPathForObject:self.selectedMonument];
    } else {
        PLInfo(@"filteredFetchedResultsController");
        monument = [self.filteredFetchedResultsController objectAtIndexPath:indexPath];
        oldIndexPath = [self.filteredFetchedResultsController indexPathForObject:self.selectedMonument];
    }
    PLInfo(@"monument: %@", monument);
    
    if (PLIPad) {
        PLIPadSplitViewController *iPadSplitViewController = (PLIPadSplitViewController *)self.navigationController.parentViewController;
        [iPadSplitViewController showMonumentInDetailView:monument];
        
        NSArray *tables = @[self.tableView, self.searchResultsTableView];
        NSArray *fRCs = @[self.fetchedResultsController, self.filteredFetchedResultsController];
        for (int i = 0 ; i<2 ; i++) {
            UITableView *table = [tables objectAtIndex:i];
            NSFetchedResultsController *fRC = [fRCs objectAtIndex:i];
            
            UITableViewCell *cell, *oldCell;
            if (table == tableView) {
                cell = [tableView cellForRowAtIndexPath:indexPath];
                oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
            } else {
                NSIndexPath *indexPathForTable = [fRC indexPathForObject:monument];
                cell = [table cellForRowAtIndexPath:indexPathForTable];
                
                NSIndexPath *oldIndexPathForTable = [fRC indexPathForObject:self.selectedMonument];
                oldCell = [table cellForRowAtIndexPath:oldIndexPathForTable];
            }
            
            cell.backgroundColor = [PLMonumentTableViewCell colorForSelectedCell];
            oldCell.backgroundColor = [UIColor clearColor];
        }
    }
    
    self.selectedMonument = monument;
    
    PLTraceOut(@"");
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    PLTraceIn(@"controller: %@ sectionIndex: %d changeType: %d", controller, sectionIndex, type);
    
    UITableView *tableView;
    if (controller == self.fetchedResultsController) {
        PLInfo(@"fetchedResultsController");
        tableView = self.tableView;
    } else {
        PLInfo(@"filteredFetchedResultsController");
        tableView = self.searchResultsTableView;
    }
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            PLInfo(@"NSFetchedResultsChangeInsert");
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            PLInfo(@"NSFetchedResultsChangeDelete");
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            PLInfo(@"NSFetchedResultsChangeUpdate");
            break;
            
        case NSFetchedResultsChangeMove:
            PLInfo(@"NSFetchedResultsChangeMove");
            break;
    }
        
    PLTraceOut(@"");
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    PLTraceIn(@"controller: %@ object: %@ indexPath: %@ changeType: %d newIndexPath: %@", controller, anObject, indexPath, type, newIndexPath);
    
    UITableView *tableView;
    if (controller == self.fetchedResultsController) {
        PLInfo(@"fetchedResultsController");
        tableView = self.tableView;
    } else {
        PLInfo(@"filteredFetchedResultsController");
        tableView = self.searchResultsTableView;
    }
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            PLInfo(@"NSFetchedResultsChangeInsert");
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            PLInfo(@"NSFetchedResultsChangeDelete");
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            PLInfo(@"NSFetchedResultsChangeUpdate");
            break;
            
        case NSFetchedResultsChangeMove:
            PLInfo(@"NSFetchedResultsChangeMove");
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
    PLTraceOut(@"");
}

#pragma mark - UISearchDisplayDelegate Delegate Methods

- (BOOL)searchDisplayController:(id)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    PLTraceIn(@"searchString: %@", searchString);
    
    if ([searchString isEqualToString:@""]) {
        PLInfo(@"Suppression du predicate");
        [self.filteredFetchedResultsController.fetchRequest setPredicate:nil];
    } else {
        PLInfo(@"Mise à jour du predicate");
        
        // Récupération des composants de la recherche séparés par des espaces
        NSString *searchText = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray *searchTerms = [searchText componentsSeparatedByString:@" "];
        
        // Construction du nouveau predicate
        NSString *predicateFormat = @"(nom contains[cd] %@)";
        NSPredicate *predicate;
        
        PLInfo(@"searchTerms: %@", searchTerms);
        if ([searchTerms count] == 1) {
            // Un seul terme dans la recherche
            NSString *term = [searchTerms objectAtIndex:0];
            predicate = [NSPredicate predicateWithFormat:predicateFormat, term, term];
        } else {
            NSMutableArray *subPredicates = [NSMutableArray array];
            for (NSString *term in searchTerms) {
                NSPredicate *p = [NSPredicate predicateWithFormat:predicateFormat, term, term];
                [subPredicates addObject:p];
            }
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        }
        
        [self.filteredFetchedResultsController.fetchRequest setPredicate:predicate];
    }
    
    // Initialisation de la requête
    
#ifdef DEBUG
    NSError *error = nil;
    BOOL fetchSuccessful = [_filteredFetchedResultsController performFetch:&error];
    NSAssert(fetchSuccessful, [error localizedDescription]);
#else
    [_filteredFetchedResultsController performFetch:nil];
#endif
    
    // Return YES to cause the search result table view to be reloaded.
    PLTraceOut(@"return: YES");
    return YES;
}

#pragma mark - Controleurs de recherche

- (UITableView *)searchResultsTableView
{
    PLTraceIn(@"");
    UITableView *result;
    
    result = self.mySearchDisplayController.searchResultsTableView;
    
    PLTraceOut(@"result: %@", result);
    return result;
}

@end
