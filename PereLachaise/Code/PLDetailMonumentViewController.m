//
//  PLDetailMonumentViewController.m
//  PereLachaise
//
//  Created by Maxime Le Moine on 04/04/2014.
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
#import "PLDetailMonumentViewController.h"
#import "PLDetailNomCell.h"
#import "PLDetailActiviteCell.h"
#import "PLDetailCircuitCell.h"
#import "PLMonumentTableViewCell.h"
#import "PLDetailWikipediaCell.h"
#import "PLWikipediaViewController.h"
#import "PLMapViewController.h"
#import "PLDetailDatesCell.h"
#import "PLDetailResumeCell.h"
#import "PLResumeView.h"
#import "PLDetailImageCommonsCell.h"
#import "PLImageCommonsViewController.h"
#import "PLImageCommons+ext.h"

static NSString *kNomCell = @"Nom";
static NSString *kActiviteCell = @"Activité";
static NSString *kCircuitCell = @"Circuit";
static NSString *kSyntheseCell = @"Synthèse";
static NSString *kWikipediaCell = @"Wikipédia";
static NSString *kFillerCell = @"Filler";
static NSString *kDatesCell = @"Dates";
static NSString *kResumeCell = @"Résumé";
static NSString *kPersonnaliteCell = @"Personnalité";
static NSString *kImageCommonsCell = @"ImageCommons";

@interface PLDetailMonumentViewController () <UIWebViewDelegate>

// La liste des identifiants des cellules à afficher en fonction du monument
@property (nonatomic, strong) NSArray *listCells;

@property (nonatomic) BOOL selectOnClose;

@property (nonatomic, strong) PLResumeView *resumeView;

- (void)updateListCells;

- (void)updateListCellsForMonument;
- (void)updateListCellsForPersonnalite;

@end

@implementation PLDetailMonumentViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.resumeView = nil;
    [self updateListCells];
    
    [self.tableView reloadData];
    
    [super viewWillAppear:animated];
}

// Surchargé pour adapter la vue lors du changement de monument
- (void)setMonument:(PLMonument *)monument
{
    PLTraceIn(@"monument: %@", monument);
    
    // Affectation du monument
    [self willChangeValueForKey:@"monument"];
    _monument = monument;
    [self didChangeValueForKey:@"monument"];
    
    // Mise à jour du titre
    if ([monument.id intValue] != [self.mapViewController.selectedMonument.id intValue]) {
        self.navigationItem.rightBarButtonItem.title = @"Sélectionner";
        self.selectOnClose = YES;
    } else {
        self.navigationItem.rightBarButtonItem.title = @"Fermer";
        self.selectOnClose = NO;
    }
    self.navigationItem.title = monument.nom;
    
    // Mise à jour du contenu des labels
    [self updateListCells];
    [self.tableView reloadData];
    
    NSAssert(self.monument, nil);
    PLTraceOut(@"");
}

// Surchargé pour adapter la vue lors du changement de personnalité
- (void)setPersonnalite:(PLPersonnalite *)personnalite
{
    PLTraceIn(@"personnalite: %@", personnalite);
    
    // Affectation du monument
    [self willChangeValueForKey:@"personnalite"];
    _personnalite = personnalite;
    [self didChangeValueForKey:@"personnalite"];
    
    // Mise à jour du titre
    if ([personnalite.monument.id intValue] != [self.mapViewController.selectedMonument.id intValue]) {
        self.navigationItem.rightBarButtonItem.title = @"Sélectionner";
        self.selectOnClose = YES;
    } else {
        self.navigationItem.rightBarButtonItem.title = @"Fermer";
        self.selectOnClose = NO;
    }
    self.navigationItem.title = personnalite.nom;
    
    // Mise à jour du contenu des labels
    [self updateListCells];
    [self.tableView reloadData];
    
    NSAssert(self.personnalite, nil);
    PLTraceOut(@"");
}

- (void)updateListCells
{
    PLTraceIn(@"");
    
    if (self.monument) {
        [self updateListCellsForMonument];
    } else {
        [self updateListCellsForPersonnalite];
    }
    
    PLTraceOut(@"");
}

- (void)updateListCellsForMonument
{
    PLTraceIn(@"");
    
    NSMutableArray *listCells = [[NSMutableArray alloc] init];
    
    PLPersonnalite *uniquePersonnalite = self.monument.uniquePersonnalite;
    
    // Synthèse
    [listCells addObject:kSyntheseCell];
    
    // Circuit
    [listCells addObject:kCircuitCell];
    
    // Image Commons
    if (self.monument.imagePrincipale) {
        [listCells addObject:kImageCommonsCell];
    }
    
    // Wikipédia
    if (uniquePersonnalite) {
        if (![uniquePersonnalite.codeWikipedia isEqualToString:@""]) {
            [listCells addObject:kWikipediaCell];
        }
    }
    else if (![self.monument.codeWikipedia isEqualToString:@""]) {
        [listCells addObject:kWikipediaCell];
    }
    
    // Dates
    if (uniquePersonnalite && uniquePersonnalite.hasDate) {
        [listCells addObject:kDatesCell];
    }
    
    // Personnalités
    if (!uniquePersonnalite) {
        for (int i = 0; i < [self.monument.personnalites count]; i++) {
            [listCells addObject:[kPersonnaliteCell stringByAppendingFormat:@"%d", i]];
        }
    }
    
    // Résumé
    BOOL resume = NO;
    if (uniquePersonnalite) {
        if (![uniquePersonnalite.resume isEqualToString:@""]) {
            resume = YES;
        }
    }
    else if (![self.monument.resume isEqualToString:@""]) {
        resume = YES;
    }
    
    if (resume) {
        if (self.resumeView.ready) {
            self.resumeView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.resumeView.frame.size.height);
            [listCells addObject:kResumeCell];
        } else if (!self.resumeView) {
            PLResumeView *resumeView = [[PLResumeView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 10.0)];
            
            resumeView.delegate = self;
            if (uniquePersonnalite) {
                resumeView.personnalite = uniquePersonnalite;
            } else {
                resumeView.monument = self.monument;
            }
            
            self.resumeView = resumeView;
        }
    } else {
        [listCells addObject:kFillerCell];
    }
    
    self.listCells = listCells;
    
    PLTraceOut(@"");
}

- (void)updateListCellsForPersonnalite
{
    PLTraceIn(@"");
    
    NSMutableArray *listCells = [[NSMutableArray alloc] init];
    
    // Synthèse
    [listCells addObject:kSyntheseCell];
    
    // Wikipédia
    if (![self.personnalite.codeWikipedia isEqualToString:@""]) {
        [listCells addObject:kWikipediaCell];
    }
    
    // Dates
    if (self.personnalite.hasDate) {
        [listCells addObject:kDatesCell];
    }
    
    // Résumé
    BOOL resume = NO;
    if (![self.personnalite.resume isEqualToString:@""]) {
        resume = YES;
    }
    
    if (resume) {
        if (self.resumeView.ready) {
            self.resumeView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.resumeView.frame.size.height);
            [listCells addObject:kResumeCell];
        } else if (!self.resumeView) {
            PLResumeView *resumeView = [[PLResumeView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 10.0)];
            
            resumeView.delegate = self;
            resumeView.personnalite = self.personnalite;
            
            self.resumeView = resumeView;
        }
    } else {
        [listCells addObject:kFillerCell];
    }
    
    self.listCells = listCells;
    
    PLTraceOut(@"");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    PLTraceIn(@"");
    
    self.resumeView = nil;
    [self updateListCells];
    
    // Ajustement de la taille des rangées
    [self.tableView reloadData];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    PLTraceOut(@"");
}

- (void)viewDidAppear:(BOOL)animated {
    PLTraceIn(@"");
    
    // Ajustement de la taille des rangées
    [self.tableView reloadData];
    
    [super viewDidAppear:animated];
    PLTraceOut(@"");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PLTraceIn(@"");
    
    if ([[segue destinationViewController] isKindOfClass:[PLWikipediaViewController class]]) {
        // Préparation de la transition vers la vue Wikipedia
        PLWikipediaViewController *wikipediaVC = [segue destinationViewController];
        
        if (!wikipediaVC.urlToLoad) {
            // Construction de l'URL
            NSString *codeWikipedia;
            
            if (self.monument) {
                PLPersonnalite *uniquePersonnalite = self.monument.uniquePersonnalite;
                if (uniquePersonnalite) {
                    codeWikipedia = uniquePersonnalite.codeWikipedia;
                } else {
                    codeWikipedia = self.monument.codeWikipedia;
                }
            } else {
                codeWikipedia = self.personnalite.codeWikipedia;
            }
            
            NSURL *baseURL = [PLWikipediaViewController baseURL];
            
            NSURL *url = [NSURL URLWithString:[codeWikipedia stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] relativeToURL:baseURL];
            
            wikipediaVC.urlToLoad = url;
        }
    } else if ([[segue destinationViewController] isKindOfClass:[PLImageCommonsViewController class]]) {
        PLImageCommonsViewController *imageViewController = [segue destinationViewController];
        
        imageViewController.detailMonumentViewController = self;
        imageViewController.imageCommons = self.monument.imagePrincipale;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    PLTraceIn(@"");
    
    self.resumeView.delegate = nil;
    
    [super viewWillDisappear:animated];
    PLTraceOut(@"");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PLTraceIn(@"");
    NSInteger result = [self.listCells count];
    
    PLTraceOut(@"result: %d", result);
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLTraceIn(@"");
    
    CGFloat result = 0.0;
    NSInteger index = [indexPath indexAtPosition:1];
    NSString *cellType = [self.listCells objectAtIndex:index];
    
    if ([cellType isEqualToString:kSyntheseCell]) {
        // Synthèse
        if (self.monument) {
            result = [PLMonumentTableViewCell heightForWidth:(self.tableView.frame.size.width - 20) andMonument:self.monument];
        } else {
            result = [PLMonumentTableViewCell heightForWidth:(self.tableView.frame.size.width - 20) andPersonnalite:self.personnalite];
        }
        
    } else if ([cellType isEqualToString:kCircuitCell]) {
        // Circuit
        result = [PLDetailCircuitCell heightForWidth:(self.tableView.frame.size.width) andMonument:self.monument];
        
    } else if ([cellType isEqualToString:kWikipediaCell]) {
        // Wikipédia
        if (self.monument) {
            PLPersonnalite *uniquePersonnalite = self.monument.uniquePersonnalite;
            if (uniquePersonnalite) {
                result = [PLDetailWikipediaCell heightForWidth:(self.tableView.frame.size.width) andPersonnalite:uniquePersonnalite];
            } else {
                result = [PLDetailWikipediaCell heightForWidth:(self.tableView.frame.size.width) andMonument:self.monument];
            }
        } else {
            result = [PLDetailWikipediaCell heightForWidth:(self.tableView.frame.size.width) andPersonnalite:self.personnalite];
        }
        
    }else if ([cellType hasPrefix:kPersonnaliteCell]) {
        // Personnalité
        
        NSString *strIndex = [cellType stringByReplacingOccurrencesOfString:kPersonnaliteCell withString:@""];
        NSUInteger personnaliteIndex = [strIndex integerValue];
        
        result = [PLMonumentTableViewCell heightForWidth:(self.tableView.frame.size.width - 33) andPersonnalite:[self.monument.personnalites objectAtIndex:personnaliteIndex]];
        
    } else if ([cellType isEqualToString:kDatesCell]) {
        // Dates
        if (self.monument) {
            result = [PLDetailDatesCell heightForWidth:(self.tableView.frame.size.width) andPersonnalite:self.monument.uniquePersonnalite];
        } else {
            result = [PLDetailDatesCell heightForWidth:(self.tableView.frame.size.width) andPersonnalite:self.personnalite];
        }
        
    } else if ([cellType isEqualToString:kResumeCell]) {
        // Résumé
        result = self.resumeView.frame.size.height;
        
    } else if ([cellType isEqualToString:kFillerCell]) {
        // Filler
        result = 0.0;
    } else if ([cellType isEqualToString:kImageCommonsCell]) {
        // Image Commons
        result = [PLDetailImageCommonsCell heightForWidth:self.tableView.frame.size.width andMonument:self.monument];
    }
    
    // La dernière cellule doit remplir complètement l'écran
    if (index == [self.listCells count] - 1) {
        // Hauteur de la table
        CGFloat tableHeight = self.tableView.frame.size.height - self.tableView.contentInset.top;
        
        // Hauteur totale des autres cellules
        CGFloat otherCellsHeight = 0.0;
        for (int i = 0; i < index; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            otherCellsHeight += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
        }
        
        result = MAX(result, tableHeight - otherCellsHeight);
    }
    
    PLTraceOut(@"return: %f", result);
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLTraceIn(@"tableView: %@ indexPath: %@", tableView, indexPath);
    
    UITableViewCell *cell;
    NSInteger index = [indexPath indexAtPosition:1];
    NSString *cellType = [self.listCells objectAtIndex:index];
    
    if ([cellType isEqualToString:kSyntheseCell]) {
        // Synthèse
        PLMonumentTableViewCell *syntheseCell = [self.tableView dequeueReusableCellWithIdentifier:kSyntheseCell];
        
        if (self.monument) {
            syntheseCell.monument = self.monument;
        } else {
            syntheseCell.personnalite = self.personnalite;
        }
        
        cell = syntheseCell;
    } else if ([cellType isEqualToString:kCircuitCell]) {
        // Circuit
        PLDetailCircuitCell *circuitCell = [self.tableView dequeueReusableCellWithIdentifier:kCircuitCell];
        circuitCell.monument = self.monument;
        
        // Ajout de l'observation sur le bouton
        [circuitCell.circuitButton removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [circuitCell.circuitButton addTarget:self action:@selector(circuitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        cell = circuitCell;
    } else if ([cellType isEqualToString:kWikipediaCell]) {
        // Wikipédia
        PLDetailWikipediaCell *wikipediaCell = [self.tableView dequeueReusableCellWithIdentifier:kWikipediaCell];
        
        if (self.monument) {
            PLPersonnalite *uniquePersonnalite = self.monument.uniquePersonnalite;
            if (uniquePersonnalite) {
                wikipediaCell.personnalite = uniquePersonnalite;
            } else {
                wikipediaCell.monument = self.monument;
            }
        } else {
            wikipediaCell.personnalite = self.personnalite;
        }
        
        cell = wikipediaCell;
    } else if ([cellType isEqualToString:kDatesCell]) {
        // Dates
        PLDetailDatesCell *datesCell = [self.tableView dequeueReusableCellWithIdentifier:kDatesCell];
        
        if (self.monument) {
            datesCell.personnalite = self.monument.uniquePersonnalite;
        } else {
            datesCell.personnalite = self.personnalite;
        }
        
        cell = datesCell;
    } else if ([cellType hasPrefix:kPersonnaliteCell]) {
        // Personnalité
        PLMonumentTableViewCell *personnaliteCell = [self.tableView dequeueReusableCellWithIdentifier:kPersonnaliteCell];
        
        NSString *strIndex = [cellType stringByReplacingOccurrencesOfString:kPersonnaliteCell withString:@""];
        NSUInteger personnaliteIndex = [strIndex integerValue];
        
        personnaliteCell.personnalite = [self.monument.personnalites objectAtIndex:personnaliteIndex];
        
        cell = personnaliteCell;
    } else if ([cellType isEqualToString:kResumeCell]) {
        // Résumé
        PLDetailResumeCell *resumeCell = [self.tableView dequeueReusableCellWithIdentifier:kResumeCell];
        
        [resumeCell insertWebView:self.resumeView];
        
        cell = resumeCell;
    } else if ([cellType isEqualToString:kFillerCell]) {
        // Filler
        UITableViewCell *fillerCell = [self.tableView dequeueReusableCellWithIdentifier:kFillerCell];
        
        cell = fillerCell;
    } else if ([cellType isEqualToString:kImageCommonsCell]) {
        // Image Commons
        PLDetailImageCommonsCell *imageCommonsCell = [self.tableView dequeueReusableCellWithIdentifier:kImageCommonsCell];
        imageCommonsCell.monument = self.monument;
        
        cell = imageCommonsCell;
    }
    
    NSAssert(cell, nil);
    PLTraceOut(@"return: %@", cell);
    return cell;
}

- (IBAction)doneButtonAction:(id)sender
{
    PLTraceIn(@"");

    if (self.selectOnClose) {
        if (self.monument) {
            [self.mapViewController selectMonument:self.monument];
        } else {
            [self.mapViewController selectMonument:self.personnalite.monument];
        }
    }
    
    [self.mapViewController closeListeMonuments];
    
    PLTraceOut(@"");
}

- (void)circuitButtonAction:(id)sender
{
    PLTraceIn(@"");
    
    UIButton *button = sender;
    button.selected = !button.selected;
    button.userInteractionEnabled = NO;
    
    // Traitement un peu plus tard pour ne pas figer le bouton
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.monument.circuit = [NSNumber numberWithBool:!self.monument.circuit.boolValue];
        button.userInteractionEnabled = YES;
        
        NSError *error;
        [self.monument.managedObjectContext saveToPersistentStore:&error];
        NSAssert(!error, nil);
    });
    
    PLTraceOut(@"");
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *url = [request URL];
    PLInfo(@"URL: %@", url);
    
    if (navigationType == UIWebViewNavigationTypeOther) {
        if ([[url scheme] isEqualToString:@"ready"]) {
            float contentHeight = [[url host] floatValue];
            
            CGRect frame = webView.frame;
            frame.size = CGSizeMake(webView.frame.size.width, contentHeight + 16.0);
            webView.frame = frame;
            
            self.resumeView.ready = YES;
            [self updateListCells];
            [self.tableView reloadData];
            
            return NO;
        }
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        PLWikipediaViewController *wikipediaViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"Wikipedia"];
        wikipediaViewController.urlToLoad = url;
        
        [self.navigationController pushViewController:wikipediaViewController animated:YES];
        
        return NO;
    }
    
    return YES; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = [indexPath indexAtPosition:1];
    NSString *cellType = [self.listCells objectAtIndex:index];
    
    if ([cellType hasPrefix:kPersonnaliteCell]) {
        NSString *strIndex = [cellType stringByReplacingOccurrencesOfString:kPersonnaliteCell withString:@""];
        NSUInteger personnaliteIndex = [strIndex integerValue];
        
        PLDetailMonumentViewController *detailPersonnaliteViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"DetailMonument"];
        detailPersonnaliteViewController.mapViewController = self.mapViewController;
        detailPersonnaliteViewController.personnalite = [self.monument.personnalites objectAtIndex:personnaliteIndex];
        
        [self.navigationController pushViewController:detailPersonnaliteViewController animated:YES];
    }
}

@end
