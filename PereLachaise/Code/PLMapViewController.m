//
//  PLMapViewController.m
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

#import <CoreData/CoreData.h>

#import "RestKit.h"
#import "MapBox.h"

#import "PLMapViewController.h"
#import "PLAppDelegate.h"
#import "PLSearchViewController.h"
#import "PLDetailMonumentViewController.h"
#import "PLConfiguration.h"
#import "PLMonumentView.h"
#import "PLNodeOSM+ext.h"
#import "PLPersonnalite+ext.h"
#import "PLAProposViewController.h"
#import "PLInfoBoxView.h"
#import "PLRectangularRegion.h"

@interface PLMapViewController () <NSFetchedResultsControllerDelegate, RMMapViewDelegate, UIActionSheetDelegate> {
    BOOL _leftPanelVisible;
}

#pragma mark - Eléments d'interface

// La vue affichant la carte
@property (nonatomic, weak) RMMapView *mapView;

// La contrainte de position horizontale du panneau de gauche (iPad)
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftPanelLeadingConstraint;

// La contrainte de position verticale du bouton de recherche
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchButtonBottomConstraint;

// La contrainte de position horizontale du bouton de circuit
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *circuitButtonHorizontalConstraint;

// Construit la vue affichant la carte
- (RMMapView *)makeMapView;

// Construit la source de tuiles de la carte à partir du fichier de configuration
- (RMMapboxSource *)makeMapBoxSourceWithMapConfiguration:(NSDictionary *)mapConfiguration;

// Récupère les données du fichier de configuration adaptées à la configuration actuelle
- (NSDictionary *)getMapConfiguration;

// Configure les boutons
- (void)configureButtons;

// Ajoute une ombre à un bouton
- (void)addShadowToButton:(UIButton *)button;

// Affiche ou cache le bouton de circuit
- (void)updateCircuitButtonPosition;

@property (nonatomic) RMUserTrackingMode previousTrackingMode;

#pragma mark - Sélection des monuments

// Surcharge avec écriture de selectedMonument
@property (nonatomic, weak) PLMonument *selectedMonument;

// La vue détaillant le monument sélectionné
@property (nonatomic, weak) PLMonumentView *monumentView;

// La contrainte de position verticale de la vue monumentView quand elle est cachée
@property (nonatomic, strong) NSLayoutConstraint *monumentViewVerticalHiddenConstraint;

// La contrainte de position verticale de la vue monumentView quand elle est visible
@property (nonatomic, strong) NSLayoutConstraint *monumentViewVerticalVisibleConstraint;

// Construit la vue détaillant le monument sélectionné
- (void)makeMonumentView;

// Essaye de sélectionner un monument ou déplace la carte si l'annotation layer correspondante n'est plus en mémoire
- (void)trySelectMonument:(PLMonument *)monument forcePosition:(BOOL)forcePosition;

@property (nonatomic, strong) NSArray *annotationsForActionSheet;

#pragma mark - Chargement des monuments

// Le controleur de récupération des monuments courant
@property (nonatomic, strong) NSFetchedResultsController *monumentFetchedResultsController;

// Le controleur de récupération des monuments du circuit
@property (nonatomic, strong) NSFetchedResultsController *circuitFetchedResultsController;

#pragma mark - Affichage de la liste des monuments

// Bascule de l'affichage du panneau de gauche (iPad)
- (IBAction)toggleLeftPanel:(id)sender;

#pragma mark - Annotations

// La liste des annotations actuellement affichées, indexée par monument
@property (nonatomic, strong) NSMutableDictionary *annotations;

// Créée une nouvelle annotation
- (RMAnnotation *)makeAnnotationForMonument:(PLMonument *)monument;

// Insère ou met à jour une annotation
- (void)createOrUpdateAnnotationForMonument:(PLMonument *)monument;

// Supprime une annotation
- (void)deleteAnnotationForMonument:(PLMonument *)monument;

#pragma mark - Chargement des monuments

// Construit le controleur de récupération des monuments
- (NSFetchedResultsController *)makeMonumentFetchedResultController;

// Construit le controleur de récupération des monuments du circuit
- (NSFetchedResultsController *)makeCircuitFetchedResultController;

#pragma mark - Gestion des évènements

// Le bouton d'affichage du détail d'un monument a été pressé
- (void)detailButtonPressed:(id)sender;

// Le bouton d'ajout/retrait du circuit a été pressé
- (void)circuitButtonPressed:(id)sender;

// Repositionne si besoin la carte lors de la sélection d'une annotation
- (void)scrollAnnotationToVisible:(RMAnnotation *)annotation;

- (CGRect)visibleRectForMonument:(PLMonument *)monument;

- (void)centerOnMonument:(PLMonument *)monument;

// Indique si le bouton de filtrage est activé
@property (nonatomic) BOOL filtreButtonEnabled;

// La région visible de la carte
@property (nonatomic, strong) PLRectangularRegion *monitoredRegion;

// Statut du bouton de localisation
@property (nonatomic) BOOL localisationButtonStatus;

// Indique si la vue doit disparaître à la fin de l'animation
@property (nonatomic) BOOL monumentViewShouldDisappear;

#pragma mark - Message d'information

// La vue affichant le message d'information
@property (nonatomic, weak) IBOutlet PLInfoBoxView *infoBoxView;

// La contrainte de position verticale du message d'information
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *infoBoxViewTopConstraint;

// Le timer utilisé pour cacher le message après un intervalle
@property (nonatomic, weak) NSTimer *infoBoxTimer;

// Modifie le message d'information et l'affiche
- (void)showMessage:(NSString *)message forDuration:(NSTimeInterval)seconds;

// Affiche le message d'information
- (void)showInfoBox;

// Cache le message d'information
- (void)hideInfoBox;

// Indique si la vue doit disparaître à la fin de l'animation
@property (nonatomic) BOOL infoBoxShouldDisappear;

@end

#pragma mark -

@implementation PLMapViewController

- (NSString *)description
{
    return [NSString stringWithFormat:@"<PLMapViewController>"];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    PLTraceIn(@"");
    
    [super viewDidLoad];
    
    // Configuration des boutons
    [self configureButtons];
    
    // Création de la vue
    self.mapView = [self makeMapView];
    
    // Création du controleur de récupération des monuments
    self.monumentFetchedResultsController = [self makeMonumentFetchedResultController];
    
    // Création du controleur de récupération des monuments du circuit
    self.circuitFetchedResultsController = [self makeCircuitFetchedResultController];
    
    // Mise à jour de la position du bouton de circuit
    [self updateCircuitButtonPosition];
    
    // Initialisation des monuments
    PLInfo(@"%d monuments à l'initialisation",[[self.monumentFetchedResultsController fetchedObjects] count]);
    
    // Initialisation et ajout des annotations
    self.annotations = [[NSMutableDictionary alloc] initWithCapacity:[[self.monumentFetchedResultsController fetchedObjects] count]];
    for (PLMonument *monument in [self.monumentFetchedResultsController fetchedObjects]) {
        RMAnnotation *annotation = [self makeAnnotationForMonument:monument];
        
        [self.annotations setObject:annotation forKey:monument.id];
    }
    [self.mapView addAnnotations:[self.annotations allValues]];
    
    // Initialisation du message d'information
    self.infoBoxView.hidden = YES;
    self.infoBoxView.message = self.infoBoxView.messageLabel.text;
    
    // Ajout de la vue en arrière-plan
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    
    PLTraceOut(@"");
}

- (void)didReceiveMemoryWarning
{
    PLTraceIn(@"");
    
    [super didReceiveMemoryWarning];
    
    // Suppression de la vue du monument sélectionné si elle est cachée
    if (self.monumentView.hidden) {
        [self.monumentView.circuitButton removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        [self.monumentView.detailButton removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
        
        self.monumentViewVerticalVisibleConstraint = nil;
        self.monumentViewVerticalHiddenConstraint = nil;
        [self.monumentView removeFromSuperview];
        
        // Rétablissement de la contrainte initiale des boutons
        self.searchButtonBottomConstraint =[NSLayoutConstraint
                                            constraintWithItem:self.view
                                            attribute:NSLayoutAttributeBottom
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:self.searchButton
                                            attribute:NSLayoutAttributeBottom
                                            multiplier:1.0
                                            constant:10.0];
        [self.view addConstraint:self.searchButtonBottomConstraint];
    }
    
    PLTraceOut(@"");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PLTraceIn(@"");
    
    self.mapView.userTrackingMode = RMUserTrackingModeNone;
    
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *topViewController = [segue.destinationViewController topViewController];
        
        if ([topViewController isKindOfClass:[PLSearchViewController class]]) {
            PLSearchViewController *searchViewController = (PLSearchViewController *)[segue.destinationViewController topViewController];
            searchViewController.mapViewController = self;
        } else if ([topViewController isKindOfClass:[PLAProposViewController class]]) {
            PLAProposViewController *aProposViewController = (PLAProposViewController *)[segue.destinationViewController topViewController];
            aProposViewController.mapViewController = self;
        }
    }
    
    PLTraceOut(@"");
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    PLTraceIn(@"toInterfaceOrientation: %d", toInterfaceOrientation);
    
    // Retour au mode de localisation normal pour éviter un bug de freeze du scrolling
    if (self.mapView.userTrackingMode == RMUserTrackingModeFollowWithHeading) {
        self.mapView.userTrackingMode = RMUserTrackingModeNone;
    }
    
    [self.mapView frameAnimationWillStart];
    
    PLTraceOut(@"");
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    PLTraceIn(@"fromInterfaceOrientation: %d", fromInterfaceOrientation);
    
    [self.mapView frameAnimationDidFinish];
    
    PLTraceOut(@"");
}

- (void)viewDidAppear:(BOOL)animated
{
    PLTraceIn(@"Sélection old: %@ new: %@", self.mapView.selectedAnnotation.userInfo, self.selectedMonument);
    
    if (self.mapView.selectedAnnotation.userInfo != self.selectedMonument) {
        // Si la sélection a changé quand le pop-up se ferme (iPhone)
        
        PLInfo(@"Changement de sélection");
        
        [self trySelectMonument:self.selectedMonument forcePosition:NO];
    }
    
    PLTraceOut(@"");
}

#pragma mark - Eléments d'interface

// Construit l'instance de RMMapView utilisée par l'application
- (RMMapView *)makeMapView
{
    PLTraceIn(@"");
    
    // Construction de la vue
    RMMapView *mapView = [[RMMapView alloc] initWithFrame:self.view.bounds];
    
    // Configuration du layout
    [mapView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    
    // Récupération de la configuration de la carte
    NSDictionary *mapConfiguration = [self getMapConfiguration];
    
    // Construction de la source cartographique
    mapView.tileSource = [self makeMapBoxSourceWithMapConfiguration:mapConfiguration];
    
    // Limites de position
    NSNumber *latitudeMin = (NSNumber *)[mapConfiguration objectForKey:@"latitude min"];
    NSNumber *latitudeMax = (NSNumber *)[mapConfiguration objectForKey:@"latitude max"];
    NSNumber *longitudeMin = (NSNumber *)[mapConfiguration objectForKey:@"longitude min"];
    NSNumber *longitudeMax = (NSNumber *)[mapConfiguration objectForKey:@"longitude max"];
    
    // Construction de la région monitorée
    CLLocationCoordinate2D limiteSudOuest = CLLocationCoordinate2DMake([latitudeMin floatValue], [longitudeMin floatValue]);
    CLLocationCoordinate2D limiteNordEst = CLLocationCoordinate2DMake([latitudeMax floatValue], [longitudeMax floatValue]);
    self.monitoredRegion = [[PLRectangularRegion alloc] initWithLimiteSudOuest:limiteSudOuest etNordEst:limiteNordEst];
    
    [mapView setConstraintsSouthWest:self.monitoredRegion.limiteSudOuest northEast:self.monitoredRegion.limiteNordEst];
    
    // Zoom initial de la carte
    NSNumber *initialZoom = (NSNumber *)[mapConfiguration objectForKey:@"Zoom initial"];
    [mapView setZoom:[initialZoom floatValue]];
    
    // Zoom minimum de la carte
    NSNumber *minimumZoom = (NSNumber *)[mapConfiguration objectForKey:@"Zoom minimum"];
    [mapView setMinZoom:[minimumZoom floatValue]];
    
    // Position initiale de la carte
    NSNumber *initialLatitude = (NSNumber *)[mapConfiguration objectForKey:@"Latitude initiale"];
    NSNumber *initialLongitude = (NSNumber *)[mapConfiguration objectForKey:@"Longitude initiale"];
    [mapView setCenterCoordinate:CLLocationCoordinate2DMake([initialLatitude doubleValue], [initialLongitude doubleValue])];
    
    // Autres propriétés
    mapView.hideAttribution = YES;
    mapView.showsUserLocation = YES;
    mapView.adjustTilesForRetinaDisplay = NO;
    
    // Décalage du logo MapBox
    mapView.bottomConstraintOffset = 54;
    
    mapView.delegate = self;
    
    PLTraceOut(@"return: %@", mapView);
    return mapView;
}

- (RMMapboxSource *)makeMapBoxSourceWithMapConfiguration:(NSDictionary *)mapConfiguration {
    PLTraceIn(@"");
    
#if TARGET_IPHONE_SIMULATOR
    PLInfo(@"target simulator");
    
    // Construction à partir d'un exemple (dev)
    RMMapboxSource *mapBoxSource = [[RMMapboxSource alloc] init];
#else
    PLInfo(@"target int/prod");
    // Construction à partir du tileJSON
    RMMapboxSource *mapBoxSource = [[RMMapboxSource alloc] initWithTileJSON:[mapConfiguration objectForKey:@"tileJSON"]];
#endif
    
    NSAssert(mapBoxSource, nil);
    PLTraceOut(@"return: %@",mapBoxSource);
    return mapBoxSource;
}

// Renvoie la configuration de la carte en fonction de l'orientation et du type d'appareil
- (NSDictionary *)getMapConfiguration
{
    PLTraceIn(@"");
    
    NSDictionary *configuration = (NSDictionary *)[PLConfiguration sharedDictionary];
    
    // Récupération de la configuration spécifique à l'appareil (iPhone ou iPad)
    NSDictionary *deviceConfiguration = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // iPhone
        PLInfo(@"deviceConfiguration iPhone");
        deviceConfiguration = [configuration objectForKey:@"iPhone"];
    } else {
        // iPad
        PLInfo(@"deviceConfiguration iPad");
        deviceConfiguration = [configuration objectForKey:@"iPad"];
    }
    
    // Récupération de la configuration spécifique à l'orientation initiale de l'appareil (portrait ou paysage)
    NSDictionary *orientationConfiguration = nil;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        PLInfo(@"orientationConfiguration portrait");
        // Portrait
        orientationConfiguration = [deviceConfiguration objectForKey:@"Portrait"];
    } else {
        PLInfo(@"orientationConfiguration paysage");
        // Paysage
        orientationConfiguration = [deviceConfiguration objectForKey:@"Paysage"];
    }
    
    // Récupération du Map ID correspondant à la définition de l'écran
    NSString *mapID;
    NSString *tileJSONFile;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale > 1.0)) {
        PLInfo(@"Retina display");
        mapID = [configuration objectForKey:@"Map ID - retina"];
        tileJSONFile = [configuration objectForKey:@"tileJSON - retina"];
    } else {
        PLInfo(@"non-Retina display");
        mapID = [configuration objectForKey:@"Map ID - non retina"];
        tileJSONFile = [configuration objectForKey:@"tileJSON - non retina"];
    }
    
    // Récupération du bundle de l'application
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    // Récupération du chemin d'accès au fichier de configuration tileJSON
    NSString *tileJSONPath = [mainBundle pathForResource:tileJSONFile ofType:nil];
    
    // Récupération du contenu du fichier
    NSError *error;
    NSString *tileJSON = [NSString stringWithContentsOfFile:tileJSONPath encoding:NSUTF8StringEncoding error:&error];
    PLInfo(@"%@", tileJSONPath);
    NSAssert(!error, @"%@", error.description);
    
    // Construction du dictionnaire contenant les résultats spécifiques
    NSDictionary *mapConfiguration = @{@"Latitude initiale": [orientationConfiguration objectForKey:@"Latitude initiale"],
                                       @"Longitude initiale": [orientationConfiguration objectForKey:@"Longitude initiale"],
                                       @"Zoom initial": [deviceConfiguration objectForKey:@"Zoom initial"],
                                       @"Zoom minimum": [deviceConfiguration objectForKey:@"Zoom minimum"],
                                       @"Zoom maximum": [deviceConfiguration objectForKey:@"Zoom maximum"],
                                       @"Map ID": mapID,
                                       @"tileJSON": tileJSON,
                                       @"latitude min": [configuration objectForKey:@"latitude min"],
                                       @"latitude max": [configuration objectForKey:@"latitude max"],
                                       @"longitude min": [configuration objectForKey:@"longitude min"],
                                       @"longitude max": [configuration objectForKey:@"longitude max"]
                                       };
    
    NSAssert(mapConfiguration, nil);
    PLTraceOut(@"return: %@", mapConfiguration);
    return mapConfiguration;
}

- (void)configureButtons
{
    PLTraceIn(@"");
    
    // Ajout des ombres sur les boutons
    [self addShadowToButton:self.searchButton];
    [self addShadowToButton:self.circuitButton];
    [self addShadowToButton:self.infoButton];
    [self addShadowToButton:self.localisationButton];
    
    // Désactivation initiale du bouton de localisation
    self.localisationButtonStatus = NO;
    self.localisationButton.alpha = 0.5;
    
    PLTraceOut(@"");
}

- (void)addShadowToButton:(UIButton *)button
{
    PLTraceIn(@"");
    
    CGFloat borderWidth;
    if (PLPostVersion7) {
        borderWidth = 0.5;
    } else {
        borderWidth = 1.0;
    }
    
    button.layer.cornerRadius = 4.0f;
    button.layer.masksToBounds = NO;
    button.layer.borderWidth = borderWidth;
    
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOpacity = 0.8;
    button.layer.shadowRadius = 4;
    button.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    
    PLTraceOut(@"");
}

- (void)updateCircuitButtonPosition
{
    PLTraceIn(@"");
    
    float alpha;
    if ([self.circuitFetchedResultsController.fetchedObjects count] == 0) {
        self.filtreButtonEnabled = NO;
        alpha = 0.5;
    } else {
        self.filtreButtonEnabled = YES;
        alpha = 1;
    }
    
    // Animation du changement d'état du bouton
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.circuitButton.alpha = alpha;
    }completion:nil];
    
    PLTraceOut(@"");
}

- (void)setFiltreCircuit:(BOOL)filtreCircuit
{
    [self willChangeValueForKey:@"filtreCircuit"];
    _filtreCircuit = filtreCircuit;
    [self didChangeValueForKey:@"filtreCircuit"];
    
    self.circuitButton.selected = self.filtreCircuit;
    self.circuitButton.userInteractionEnabled = NO;
    
    // Traitement un peu plus tard pour ne pas figer le bouton
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.filtreCircuit) {
            
            self.monumentFetchedResultsController.fetchRequest.predicate = self.circuitFetchedResultsController.fetchRequest.predicate;
            
            // Récupération des monuments à cacher (hors circuit)
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(circuit = %@)", @NO];
            
            NSError *error;
            NSManagedObjectContext *moc = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
            NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
            NSAssert(!error, nil);
            
            NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:[fetchedObjects count]];
            for (PLMonument *monument in fetchedObjects) {
                RMAnnotation *annotation = [self.annotations objectForKey:monument.id];
                [annotations addObject:annotation];
                [self.annotations removeObjectForKey:monument.id];
                
                if ([self.selectedMonument.id intValue] == [monument.id intValue]) {
                    [self.mapView deselectAnnotation:annotation animated:NO];
                }
            }
            
            [self.mapView removeAnnotations:annotations];
        } else {
            self.monumentFetchedResultsController.fetchRequest.predicate = nil;
            
            // Récupération des monuments à réafficher (hors circuit)
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(circuit = %@)", @NO];
            
            NSError *error;
            NSManagedObjectContext *moc = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
            NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
            NSAssert(!error, nil);
            
            // Initialisation et ajout des annotations
            NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:[fetchedObjects count]];
            for (PLMonument *monument in fetchedObjects) {
                RMAnnotation *annotation = [self makeAnnotationForMonument:monument];
                
                [annotations addObject:annotation];
                [self.annotations setObject:annotation forKey:monument.id];
            }
            [self.mapView addAnnotations:annotations];
        }
        
        NSError *error;
        [self.monumentFetchedResultsController performFetch:&error];
        NSAssert(!error, nil);
        
        self.circuitButton.userInteractionEnabled = YES;
    });
}

#pragma mark - Sélection des monuments

- (void)selectMonument:(PLMonument *)monument
{
    PLTraceIn(@"monument: %@", monument);
    
    self.selectedMonument = monument;
    
    if (self.view.window) {
        PLInfo(@"Carte affichée");
        [self trySelectMonument:monument forcePosition:NO];
    } else {
        PLInfo(@"Carte cachée");
        // La sélection sera tentée dans le méthode viewDidAppear
    }
    
    PLTraceOut(@"");
}

- (void)trySelectMonument:(PLMonument *)monument forcePosition:(BOOL)forcePosition
{
    PLTraceIn(@"monument: %@ forcePosition: %d", monument, forcePosition);
    
    if (self.filtreCircuit && !monument.circuit.boolValue) {
        monument.circuit = @YES;
        
        NSError *error;
        [monument.managedObjectContext saveToPersistentStore:&error];
        NSAssert(!error, nil);
    }
    
    RMAnnotation *annotationToSelect = [self.annotations objectForKey:monument.id];
    
    if (annotationToSelect.layer) {
        PLInfo(@"annotation.layer présent");
        [self.mapView selectAnnotation:annotationToSelect animated:YES];
    }
    
    if (!forcePosition) {
        [self centerOnMonument:monument];
    }
    
    PLTraceOut(@"");
}

- (void)makeMonumentView
{
    PLTraceIn(@"");
    
    // Chargement et ajout de la vue
    self.monumentView = [[[NSBundle mainBundle] loadNibNamed:@"PLMonumentView" owner:self options:nil] objectAtIndex:0];
    
    [self.view addSubview:self.monumentView];
    
    // Définition des contraintes de position à l'écran
    
    // Contrainte à gauche
    NSLayoutConstraint *leadingConstraint =[NSLayoutConstraint
                                            constraintWithItem:self.monumentView
                                            attribute:NSLayoutAttributeLeading
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:self.monumentView.superview
                                            attribute:NSLayoutAttributeLeading
                                            multiplier:1.0
                                            constant:0.0];
    [self.view addConstraint:leadingConstraint];
    
    // Contrainte à droite
    NSLayoutConstraint *trailingConstraint =[NSLayoutConstraint
                                             constraintWithItem:self.monumentView
                                             attribute:NSLayoutAttributeTrailing
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:self.monumentView.superview
                                             attribute:NSLayoutAttributeTrailing
                                             multiplier:1.0
                                             constant:0.0];
    [self.view addConstraint:trailingConstraint];
    
    // Création des contraintes de position verticale alternatives
    
    self.monumentViewVerticalHiddenConstraint = [NSLayoutConstraint
                                      constraintWithItem:self.monumentView
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self.monumentView.superview
                                      attribute:NSLayoutAttributeBottom
                                      multiplier:1.0
                                      constant:0.0];
    
    self.monumentViewVerticalVisibleConstraint = [NSLayoutConstraint
                                         constraintWithItem:self.monumentView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.monumentView.superview
                                         attribute:NSLayoutAttributeBottom
                                         multiplier:1.0
                                         constant:0.0];
    
    // Redéfinition de la contrainte de position verticale des boutons
    [self.view removeConstraint:self.searchButtonBottomConstraint];
    self.searchButtonBottomConstraint =[NSLayoutConstraint
                                        constraintWithItem:self.monumentView
                                        attribute:NSLayoutAttributeTop
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self.searchButton
                                        attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                        constant:10.0];
    [self.view addConstraint:self.searchButtonBottomConstraint];
    
    // Ajout des évènements sur les boutons
    [self.monumentView.detailButton addTarget:self action:@selector(detailButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.monumentView.circuitButton addTarget:self action:@selector(circuitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // A l'initialisation : position cachée
    [self.view addConstraint:self.monumentViewVerticalHiddenConstraint];
    self.monumentView.hidden = YES;
    self.monumentView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.monumentView.frame.size.height);
    
    PLTraceOut(@"");
}

- (IBAction)filterButtonAction:(id)sender
{
    PLTraceIn(@"");
    
    if (self.filtreButtonEnabled) {
        self.filtreCircuit = !self.filtreCircuit;
    } else {
        NSString *message = @"Vous devez d'abord ajouter des tombes à votre circuit.";
        [self showMessage:message forDuration:4.0];
    }
    
    PLTraceOut(@"");
}

#pragma mark - Affichage de la liste des monuments

- (void)closeListeMonuments
{
    PLTraceIn(@"");
    
    if (self.leftPanel) {
        PLInfo(@"iPad");
        [self toggleLeftPanel:self];
    } else {
        PLInfo(@"iPhone");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    PLTraceOut(@"");
}

- (IBAction)toggleLeftPanel:(id)sender
{
    PLTraceIn(@"");
    
    if (!_leftPanelVisible) {
        CGFloat newConstraint = 0.0;
        PLInfo(@"Affichage, leftPanelLeadingConstraint.constant old: %f new: %f", self.leftPanelLeadingConstraint.constant, newConstraint);
        
        _leftPanelVisible = YES;
        self.leftPanel.hidden = NO;
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.leftPanelLeadingConstraint.constant = newConstraint;
            [self.view layoutIfNeeded];
        }completion:^(BOOL finished){
            self.leftPanel.hidden = NO;
            
            PLInfo(@"Fin affichage finished:%d hidden:%d constraint:%f", finished, self.leftPanel.hidden, self.leftPanelLeadingConstraint.constant);
        }];
    } else {
        CGFloat newConstraint = -self.leftPanel.frame.size.width;
        PLInfo(@"Retrait, leftPanelLeadingConstraint.constant old: %f new: %f", self.leftPanelLeadingConstraint.constant, newConstraint);
        
        _leftPanelVisible = NO;
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.leftPanelLeadingConstraint.constant = newConstraint;
            [self.view layoutIfNeeded];
        }completion:^(BOOL finished){
            self.leftPanel.hidden = YES;
            
            PLInfo(@"Fin retrait finished:%d hidden:%d constraint:%f",finished,self.leftPanel.hidden,self.leftPanelLeadingConstraint.constant);
        }];
    }
    
    PLTraceOut(@"");
}

#pragma mark - Annotations

- (RMAnnotation *)makeAnnotationForMonument:(PLMonument *)monument
{
    PLTraceIn(@"monument: %@", monument);
    
    // Création de l'annotation
    CLLocationCoordinate2D annotationPosition = monument.nodeOSM.coordinates;
    RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.mapView coordinate:annotationPosition andTitle:monument.nom];
    annotation.annotationType = @"monument";
    annotation.userInfo = monument;
    
    PLPersonnalite *uniquePersonnalite = monument.uniquePersonnalite;
    if (uniquePersonnalite) {
        if (uniquePersonnalite.hasAllDates) {
            annotation.subtitle = [NSString stringWithFormat:@"%@ (%@-%@)", uniquePersonnalite.activite, uniquePersonnalite.dateNaissanceCourte, uniquePersonnalite.dateDecesCourte];
        } else {
            annotation.subtitle = uniquePersonnalite.activite;
        }
    }
    
    PLTraceOut(@"return: %@", annotation);
    return annotation;
}

- (void)createOrUpdateAnnotationForMonument:(PLMonument *)monument
{
    PLTraceIn(@"monument: %@", monument);
    
    // Récupération de l'annotation
    RMAnnotation *annotation = [self.annotations objectForKey:monument.id];
    
    if (annotation) {
        // Mise à jour de l'annotation
        annotation.title = monument.nom;
        annotation.coordinate = monument.nodeOSM.coordinates;
        
        [self.mapView removeAnnotation:annotation];
        [self.mapView addAnnotation:annotation];
        
        PLInfo(@"Mise à jour annotation: %@", annotation);
    } else {
        // Création de l'annotation
        annotation = [self makeAnnotationForMonument:monument];
        
        // Insertion de l'annotation dans le dictionnaire de valeurs
        [self.annotations setObject:annotation forKey:monument.id];
        [self.mapView addAnnotation:annotation];
        
        PLInfo(@"Insertion annotation: %@", annotation);
    }
    
    PLTraceOut(@"");
}

- (void)deleteAnnotationForMonument:(PLMonument *)monument
{
    PLTraceIn(@"monument: %@", monument);
    
    // Récupération de l'annotation
    RMAnnotation *annotation = [self.annotations objectForKey:monument.id];
    
    if (monument == self.selectedMonument) {
        [self.mapView deselectAnnotation:annotation animated:NO];
    }
    
    if (annotation) {
        PLInfo(@"Suppression annotation: %@", annotation);
        
        [self.mapView removeAnnotation:annotation];
        [self.annotations removeObjectForKey:monument.id];
    } else {
        PLWarning(@"Aucune annotation pour le monument à supprimer: %@", monument);
    }
    
    PLTraceOut(@"");
}

#pragma mark - Chargement des monuments

- (NSFetchedResultsController *)makeMonumentFetchedResultController
{
    PLTraceIn(@"");
    
    // Création de la requête
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    
    // Règles de tri
    NSSortDescriptor *descriptorNomPourTri = [NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *descriptorNom = [NSSortDescriptor sortDescriptorWithKey:@"nom" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    fetchRequest.sortDescriptors = @[descriptorNomPourTri, descriptorNom];
    
    // Création du controleur de la requête
    NSFetchedResultsController *monumentFetchedResultsController = [[NSFetchedResultsController alloc]
                                                                    initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                            sectionNameKeyPath:@"premiereLettreNomPourTri"
                                                                                        cacheName:nil];
    [monumentFetchedResultsController setDelegate:self];
    
    // Initialisation de la requête
#ifdef DEBUG
    NSError *error = nil;
    BOOL fetchSuccessful = [monumentFetchedResultsController performFetch:&error];
    NSAssert(fetchSuccessful, [error localizedDescription]);
#else
    [monumentFetchedResultsController performFetch:nil];
#endif
    
    PLTraceOut(@"return: %@", monumentFetchedResultsController);
    return monumentFetchedResultsController;
}

- (NSFetchedResultsController *)makeCircuitFetchedResultController
{
    PLTraceIn(@"");
    
    // Création de la requête
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLMonument"];
    
    // Règles de tri
    NSSortDescriptor *descriptorNomPourTri = [NSSortDescriptor sortDescriptorWithKey:@"nomPourTri" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *descriptorNom = [NSSortDescriptor sortDescriptorWithKey:@"nom" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    fetchRequest.sortDescriptors = @[descriptorNomPourTri, descriptorNom];
    
    // Création du controleur de la requête
    NSFetchedResultsController *circuitFetchedResultsController = [[NSFetchedResultsController alloc]
                                                                    initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                    sectionNameKeyPath:@"premiereLettreNomPourTri"
                                                                    cacheName:nil];
    [circuitFetchedResultsController setDelegate:self];
    
    // Ajout du predicate
    NSString *predicateFormat = @"(circuit = 1)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
    [circuitFetchedResultsController.fetchRequest setPredicate:predicate];
    
    // Initialisation de la requête
#ifdef DEBUG
    NSError *error = nil;
    BOOL fetchSuccessful = [circuitFetchedResultsController performFetch:&error];
    NSAssert(fetchSuccessful, [error localizedDescription]);
#else
    [circuitFetchedResultsController performFetch:nil];
#endif
    
    PLTraceOut(@"return: %@", circuitFetchedResultsController);
    return circuitFetchedResultsController;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    PLTraceIn(@"monument: %@ indexPath: %@ changeType: %d newIndexPath: %@", anObject, indexPath, type, newIndexPath);
    
    if (controller == self.monumentFetchedResultsController) {
        if ([anObject isKindOfClass:[PLMonument class] ]) {
            switch (type) {
                case NSFetchedResultsChangeInsert:
                case NSFetchedResultsChangeUpdate:
                    [self createOrUpdateAnnotationForMonument:anObject];
                    break;
                case NSFetchedResultsChangeDelete:
                    [self deleteAnnotationForMonument:anObject];
                    if (self.filtreCircuit && [controller.fetchedObjects count] == 0) {
                        PLInfo(@"Tous les monuments du circuits ont été retirés -> retour au mode normal");
                        self.filtreCircuit = NO;
                    }
                    break;
                    
                default:
                    break;
            }
        } else {
            NSAssert(NO, @"Type d'objet non autorisé");
        }
    }
    
    if (controller == self.circuitFetchedResultsController) {
        PLInfo(@"Circuit : %d", [controller.fetchedObjects count]);
        [self updateCircuitButtonPosition];
    }
    
    PLTraceOut(@"");
}

#pragma mark - RMMapViewDelegate

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    PLTraceIn(@"annotation: %@", annotation);
    
    RMMapLayer *mapLayer = nil;
    if (!annotation.isUserLocationAnnotation) {
        PLMonument *monument = annotation.userInfo;
        
        NSString *sizeString;
        NSString *iconString;
        NSString *colorString;
        
        if (monument.circuit.boolValue) {
            iconString = @"star";
            colorString = @"915C6F";
        } else {
            iconString = @"cemetery";
            colorString = @"5E4B6B";
        }
        
        if (monument == self.selectedMonument) {
            sizeString = @"large";
        } else {
            sizeString = @"small";
        }
        
        mapLayer = [[RMMarker alloc] initWithMapboxMarkerImage:iconString tintColorHex:colorString sizeString:sizeString];
        mapLayer.canShowCallout = NO;
        
        PLInfo(@"mapLayer: %f %f %f %f", mapLayer.frame.origin.x, mapLayer.frame.origin.y, mapLayer.frame.size.width, mapLayer.frame.size.height);
    } else {
        PLInfo(@"isUserLocationAnnotation");
    }
    
    PLTraceOut(@"return: %@", mapLayer);
    return mapLayer;
}

- (void)mapView:(RMMapView *)mapView didSelectAnnotation:(RMAnnotation *)annotation
{
    PLTraceIn(@"annotation: %@", annotation);
    
    if (annotation.isUserLocationAnnotation) {
        PLWarning(@"Sélection isUserLocationAnnotation");
        return;
    }
    
    NSAssert(annotation.layer, nil);
    
    self.selectedMonument = annotation.userInfo;
    
    // Recréation de l'annotation pour mettre à jour son affichage
    [mapView removeAnnotation:annotation];
    [mapView addAnnotation:annotation];
    
    // Création de la vue si besoin
    if (!self.monumentView) {
        [self makeMonumentView];
    }
    
    // Modification du monument sur la vue
    self.monumentView.monument = self.selectedMonument;
    
    // Redimensionnement immédiat de la vue si elle est cachée
    if (self.monumentView.hidden) {
        [self.monumentView layoutIfNeeded];
    }
    
    self.monumentView.hidden = NO;
    
    // Mise à jour de la contrainte de position verticale de la vue
    
    [self.view removeConstraint:self.monumentViewVerticalHiddenConstraint];
    [self.view removeConstraint:self.monumentViewVerticalVisibleConstraint];
    [self.view addConstraint:self.monumentViewVerticalVisibleConstraint];
    
    // Animation du changement de contraintes
    self.monumentViewShouldDisappear = NO;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished){
        PLTrace(@"Fin animation apparition");
        if (!self.infoBoxShouldDisappear) {
            self.monumentView.hidden = NO;
        }
    }];
    
    if (self.mapView.userTrackingMode == RMUserTrackingModeNone) {
        [self scrollAnnotationToVisible:annotation];
    }
    
    PLTraceOut(@"");
}

- (void)mapView:(RMMapView *)mapView didDeselectAnnotation:(RMAnnotation *)annotation
{
    PLTraceIn(@"annotation: %@", annotation);
    
    self.selectedMonument = nil;
    
    // Recréation de l'annotation pour mettre à jour son affichage
    [mapView removeAnnotation:annotation];
    [mapView addAnnotation:annotation];
    
    // Mise à jour de la contrainte de position verticale de la vue
    [self.view removeConstraint:self.monumentViewVerticalHiddenConstraint];
    [self.view removeConstraint:self.monumentViewVerticalVisibleConstraint];
    [self.view addConstraint:self.monumentViewVerticalHiddenConstraint];
    
    // Animation du changement de contraintes
    self.monumentViewShouldDisappear = YES;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished){
        PLTrace(@"Fin animation disparition: %d", finished);
        if (self.monumentViewShouldDisappear) {
            // Dissimulation de la vue si l'animation est complètement terminée
            self.monumentView.hidden = YES;
        }
    }];
    
    PLTraceOut(@"");
}

- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction
{
    PLTraceIn(@"Sélection old: %@ new: %@", self.mapView.selectedAnnotation.userInfo, self.selectedMonument);
    
    if (self.mapView.selectedAnnotation.userInfo != self.selectedMonument) {
        PLInfo(@"Changement de sélection");
        
        // forcePosition = YES au cas où l'animation de la carte a été interrompue
        [self trySelectMonument:self.selectedMonument forcePosition:YES];
    }
    
    PLTraceOut(@"");
}

- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    PLTraceIn(@"annotation: %@",annotation);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // iPhone
        UINavigationController *navigationController = [[self storyboard] instantiateViewControllerWithIdentifier:@"Navigation Controller"];
        PLSearchViewController *searchViewController = (PLSearchViewController *)[navigationController topViewController];
        searchViewController.mapViewController = self;
        
        PLDetailMonumentViewController *detailViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"DetailMonument"];
        detailViewController.monument = annotation.userInfo;
        detailViewController.mapViewController = self;
        
        [navigationController pushViewController:detailViewController animated:NO];
        [self presentViewController:navigationController animated:YES completion:nil];
    } else {
        // iPad
        UINavigationController *navigationController = [self.childViewControllers objectAtIndex:0];
        
        UIViewController *topViewController = [navigationController topViewController];
        PLDetailMonumentViewController *detailViewController;
        
        if ([topViewController isKindOfClass:[PLDetailMonumentViewController class]]) {
            detailViewController = (PLDetailMonumentViewController *)topViewController;
        } else if ([topViewController isKindOfClass:[PLSearchViewController class]]) {
            detailViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"DetailMonument"];
            detailViewController.mapViewController = self;
        } else {
            for (UIViewController *viewController in navigationController.viewControllers) {
                if ([viewController isKindOfClass:[PLDetailMonumentViewController class]]) {
                    detailViewController = (PLDetailMonumentViewController *)viewController;
                    [navigationController popToViewController:detailViewController animated:_leftPanelVisible];
                    break;
                }
            }
        }
        
        detailViewController.monument = annotation.userInfo;
        if (!_leftPanelVisible) {
            [self toggleLeftPanel:self];
        }
    }
    
    PLTraceOut(@"");
}

- (void)mapView:(RMMapView *)mapView didChangeUserTrackingMode:(RMUserTrackingMode)mode animated:(BOOL)animated
{
    PLTraceIn(@"mode: %d", mode);
    
    if (mode == RMUserTrackingModeFollow) {
        UIImage *image = [UIImage imageNamed:@"glyphicons_233_direction_selected"];
        [self.localisationButton setImage:image forState:UIControlStateNormal];
        
    } else if (mode == RMUserTrackingModeFollowWithHeading) {
        UIImage *image = [UIImage imageNamed:@"glyphicons_060_compass_selected"];
        [self.localisationButton setImage:image forState:UIControlStateNormal];
        
    } else {
        [self.mapView setConstraintsSouthWest:self.monitoredRegion.limiteSudOuest northEast:self.monitoredRegion.limiteNordEst];
        UIImage *image = [UIImage imageNamed:@"glyphicons_233_direction"];
        [self.localisationButton setImage:image forState:UIControlStateNormal];
        
    }
    
    self.previousTrackingMode = mode;
    
    PLTraceOut(@"");
}

- (void)tapOnAnnotations:(NSArray *)annotations onMap:(RMMapView *)map
{
    PLTraceIn(@"");
    
    PLInfo(@"%d annotations", [annotations count]);
    
    NSString *title = @"Quelle tombe voulez-vous sélectionner ?";
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (RMAnnotation *annotation in annotations) {
        PLMonument *monument = annotation.userInfo;
        [actionSheet addButtonWithTitle:monument.nom];
    }
    
    [actionSheet addButtonWithTitle:@"Annuler"];
    actionSheet.cancelButtonIndex = [actionSheet numberOfButtons] - 1;
    
    self.annotationsForActionSheet = annotations;
    
    [actionSheet showInView:self.view];
    
    PLTraceOut(@"");
}

- (void)mapView:(RMMapView *)mapView didUpdateUserLocation:(RMUserLocation *)userLocation
{
    PLTraceIn(@"");
    
    if ([self.monitoredRegion containsCoordinate:userLocation.location.coordinate]) {
        self.localisationButtonStatus = YES;
    } else {
        self.localisationButtonStatus = NO;
    }
    
    PLTraceOut(@"");
}

- (void)mapViewDidStopLocatingUser:(RMMapView *)mapView
{
    PLTraceIn(@"");
    
    self.localisationButtonStatus = NO;
    
    PLTraceOut(@"");
}

#pragma mark - Gestion des évènements

- (void)detailButtonPressed:(id)sender
{
    PLTraceIn(@"");
    
    UINavigationController *navigationController = [[self storyboard] instantiateViewControllerWithIdentifier:@"Navigation Controller"];
    PLSearchViewController *searchViewController = (PLSearchViewController *)[navigationController topViewController];
    searchViewController.mapViewController = self;
    NSIndexPath *indexPath = [searchViewController.fetchedResultsController indexPathForObject:self.selectedMonument];
    [searchViewController.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    
    PLDetailMonumentViewController *detailViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"DetailMonument"];
    detailViewController.mapViewController = self;
    detailViewController.monument = self.selectedMonument;
    
    self.mapView.userTrackingMode = RMUserTrackingModeNone;
    
    [navigationController pushViewController:detailViewController animated:NO];
    [self presentViewController:navigationController animated:YES completion:nil];
    
    PLTraceOut(@"");
}

- (void)circuitButtonPressed:(id)sender
{
    PLTraceIn(@"");
    
    self.selectedMonument.circuit = [NSNumber numberWithBool:!self.selectedMonument.circuit.boolValue];
    
    NSError *error;
    [self.selectedMonument.managedObjectContext saveToPersistentStore:&error];
    NSAssert(!error, nil);
    
    PLTraceOut(@"");
}

- (IBAction)trackingButtonAction:(id)sender
{
    PLTraceIn(@"");
    
    if (self.mapView.userTrackingMode == RMUserTrackingModeNone && self.localisationButtonStatus) {
        self.mapView.userTrackingMode = RMUserTrackingModeFollow;
    } else if (self.mapView.userTrackingMode == RMUserTrackingModeFollow && self.localisationButtonStatus) {
        [self.mapView setConstraintsWithPlanetBounds];
        self.mapView.userTrackingMode = RMUserTrackingModeFollowWithHeading;
    } else {
        self.mapView.userTrackingMode = RMUserTrackingModeNone;
        
        if (!self.localisationButtonStatus) {
            if (self.mapView.showsUserLocation) {
                NSString *message = @"Vous devez être au Père-Lachaise.";
                [self showMessage:message forDuration:4.0];
            } else {
                NSString *message = @"Vous avez désactivé la localisation pour cette application.";
                [self showMessage:message forDuration:4.0];
            }
        }
    }
    
    PLTraceOut(@"");
}

- (void)scrollAnnotationToVisible:(RMAnnotation *)annotation
{
    PLTraceIn(@"");
    
    PLMonument *monument = annotation.userInfo;
    
    // Large annotation size : 35x90
    
    CGRect targetRect = [self visibleRectForMonument:monument];
    
    CGPoint annotationPosition = annotation.position;
    CGSize annotationLayerSize = CGSizeMake(35.0, 45.0);
    
    PLInfo(@"targetRect: %f %f %f %f", targetRect.origin.x, targetRect.origin.y, targetRect.size.width, targetRect.size.height);
    PLInfo(@"annotationPosition: %f %f", annotationPosition.x, annotationPosition.y);
    PLInfo(@"annotationLayerSize: %f %f", annotationLayerSize.width, annotationLayerSize.height);
    
    CGRect annotationRect;
    annotationRect.origin = CGPointMake(annotationPosition.x - ceil(annotationLayerSize.width/2.0), annotationPosition.y - annotationLayerSize.height);
    annotationRect.size = annotationLayerSize;
    
    PLInfo(@"annotationRect: %f %f %f %f", annotationRect.origin.x, annotationRect.origin.y, annotationRect.size.width, annotationRect.size.height);
    
    // Détermination du déplacement ou non
    if (!CGRectContainsRect(targetRect, annotationRect)) {
        PLInfo(@"Déplacement nécessaire");
        
        // Calcul de l'offset
        CGSize offset;
        
        // Dépassement à gauche
        offset.width = MAX(0.0, targetRect.origin.x - annotationRect.origin.x);
        PLInfo(@"offset: %f %f", offset.width, offset.height);
        
        // Dépassement à droite
        if (offset.width == 0.0) {
            offset.width = MIN(0.0, targetRect.origin.x + targetRect.size.width - annotationRect.origin.x - annotationRect.size.width);
        }
        PLInfo(@"offset: %f %f", offset.width, offset.height);
        
        // Dépassement en haut
        offset.height = MAX(0.0, targetRect.origin.y - annotationRect.origin.y);
        PLInfo(@"offset: %f %f", offset.width, offset.height);
        
        // Dépassement en bas
        if (offset.height == 0.0) {
            offset.height = MIN(0.0, targetRect.origin.y + targetRect.size.height - annotationRect.origin.y - annotationRect.size.height);
        }
        PLInfo(@"offset: %f %f", offset.width, offset.height);
        
        // Calcul du nouveau centre
        CGPoint oldCenter = self.mapView.center;
        PLInfo(@"oldCenter: %f %f", oldCenter.x, oldCenter.y);
        CGPoint newCenter = CGPointMake(oldCenter.x - offset.width, oldCenter.y - offset.height);
        PLInfo(@"newCenter: %f %f", newCenter.x, newCenter.y);
        CLLocationCoordinate2D newCenterConverted = [self.mapView pixelToCoordinate:newCenter];
        PLInfo(@"newCenterConverted: %f %f", newCenterConverted.latitude, newCenterConverted.longitude);
        [self.mapView setCenterCoordinate:newCenterConverted animated:YES];
    }

#if LOG_LEVEL == TRACE
    static UIView *testTargetView;
    
    if (testTargetView) {
        [testTargetView removeFromSuperview];
    }
    
    testTargetView = [[UIView alloc] initWithFrame:targetRect];
    testTargetView.backgroundColor = [UIColor orangeColor];
    testTargetView.alpha = 0.5;
    testTargetView.userInteractionEnabled = NO;
    
    [self.view addSubview:testTargetView];
    
    static UIView *testAnnotationView;
    
    if (testAnnotationView) {
        [testAnnotationView removeFromSuperview];
    }
    
    testAnnotationView = [[UIView alloc] initWithFrame:annotationRect];
    testAnnotationView.backgroundColor = [UIColor redColor];
    testAnnotationView.alpha = 0.5;
    testAnnotationView.userInteractionEnabled = NO;
    
    [self.view addSubview:testAnnotationView];
#endif
    
    PLTraceOut(@"");
}

- (CGRect)visibleRectForMonument:(PLMonument *)monument
{
    PLTraceIn(@"");
    
    CGRect visibleRect = CGRectIntersection(self.mapView.bounds, self.view.bounds);
    
    // Calcul du rectangle cible
    CGFloat insetTop, insetBottom, insetLeft, insetRight;
    
    insetLeft = insetRight = 10.0;
    insetTop = 20.0;
    
    // Hauteur prévue de la vue du monument
    CGFloat monumentViewHeight = [PLMonumentView heightForWidth:visibleRect.size.width andMonument:monument];
    PLInfo(@"monumentViewHeight: %f", monumentViewHeight);
    
    insetBottom = monumentViewHeight + 44.0 + 10.0 + 10.0;
    
    CGRect targetRect;
    targetRect.origin = CGPointMake(visibleRect.origin.x + insetLeft, visibleRect.origin.y + insetTop);
    targetRect.size = CGSizeMake(visibleRect.size.width - insetLeft - insetRight, visibleRect.size.height - insetTop - insetBottom);
    
    PLTraceOut(@"targetRect: %f %f %f %f", targetRect.origin.x, targetRect.origin.y, targetRect.size.width, targetRect.size.height);
    return targetRect;
}

- (void)centerOnMonument:(PLMonument *)monument
{
    PLTraceIn(@"");
    
    CGRect targetRect = [self visibleRectForMonument:monument];
    CGRect mapRect = self.mapView.bounds;
    
    CGPoint centerTargetRect = CGPointMake(targetRect.origin.x + targetRect.size.width / 2.0, targetRect.origin.y + targetRect.size.height / 2.0);
    CGPoint centerMapRect = CGPointMake(mapRect.origin.x + mapRect.size.width / 2.0, mapRect.origin.y + mapRect.size.height / 2.0);
    
    CGSize delta = CGSizeMake(centerMapRect.x - centerTargetRect.x, centerMapRect.y - centerTargetRect.y - 25.0);
    
    CGPoint annotationPosition = [self.mapView coordinateToPixel:monument.nodeOSM.coordinates];
    CGPoint correctedPosition = CGPointMake(annotationPosition.x + delta.width, annotationPosition.y + delta.height);
    CLLocationCoordinate2D correctedCoordinates = [self.mapView pixelToCoordinate:correctedPosition];
    
    [self.mapView setCenterCoordinate:correctedCoordinates animated:YES];
    
    PLTraceOut(@"");
}

- (void)setLocalisationButtonStatus:(BOOL)localisationButtonStatus
{
    PLTraceIn(@"localisationButtonStatus: %d", localisationButtonStatus);
    
    BOOL oldStatus = self.localisationButtonStatus;
    
    [self willChangeValueForKey:@"localisationButtonStatus"];
    _localisationButtonStatus = localisationButtonStatus;
    [self didChangeValueForKey:@"localisationButtonStatus"];
    
    if (oldStatus != localisationButtonStatus) {
        if (localisationButtonStatus) {
            self.localisationButton.alpha = 1.0;
        } else {
            self.localisationButton.alpha = 0.5;
            self.mapView.userTrackingMode = RMUserTrackingModeNone;
        }
    }
    
    PLTraceOut(@"");
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    PLTraceIn(@"");
    NSAssert(self.annotationsForActionSheet, nil);
    
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        RMAnnotation *selectedAnnotation = [self.annotationsForActionSheet objectAtIndex:buttonIndex];
        [self.mapView selectAnnotation:selectedAnnotation animated:YES];
    }
    
    self.annotationsForActionSheet = nil;
    PLTraceOut(@"");
}

#pragma mark - Message d'information

- (void)showInfoBox
{
    PLTraceIn(@"");
    
    // Redimensionnement immédiat de la vue si elle est cachée
    if (self.infoBoxView.hidden) {
        [self.infoBoxView layoutIfNeeded];
    }
    
    self.infoBoxView.hidden = NO;
    
    // Mise à jour de la contrainte de position verticale de la vue
    
    self.infoBoxViewTopConstraint.priority = 900;
    
    // Animation du changement de contraintes
    self.infoBoxShouldDisappear = NO;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished){
        if (!self.infoBoxShouldDisappear) {
            self.infoBoxView.hidden = NO;
        }
        PLTrace(@"Fin animation apparition");
    }];
    
    PLTraceOut(@"");
}

- (void)hideInfoBox
{
    PLTraceIn(@"");
    
    // Mise à jour de la contrainte de position verticale de la vue
    self.infoBoxViewTopConstraint.priority = 500;
    
    // Animation du changement de contraintes
    self.infoBoxShouldDisappear = YES;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished){
        PLTrace(@"Fin animation disparition: %d", finished);
        if (self.infoBoxShouldDisappear) {
            // Dissimulation de la vue si l'animation est complètement terminée
            self.infoBoxView.hidden = YES;
        }
    }];
    
    PLTraceOut(@"");
}

- (void)showMessage:(NSString *)message forDuration:(NSTimeInterval)seconds
{
    PLTraceIn(@"message: %@ - seconds: %f", message, seconds);
    
    self.infoBoxView.message = message;
    [self showInfoBox];
    
    // Préparation du timer
    NSMethodSignature *signature = [PLMapViewController instanceMethodSignatureForSelector:@selector(hideInfoBox)];
    NSInvocation *invocation = [NSInvocation
                                   invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:@selector(hideInfoBox)];
    
    [self.infoBoxTimer invalidate];
    self.infoBoxTimer = [NSTimer scheduledTimerWithTimeInterval:seconds invocation:invocation repeats:NO];
    
    PLTraceOut(@"");
}

@end
