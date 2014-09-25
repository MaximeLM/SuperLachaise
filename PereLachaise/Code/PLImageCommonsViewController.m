//
//  PLImageCommonsViewController.m
//  PereLachaise
//
//  Created by Maxime Le Moine on 21/04/2014.
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

#import "PLImageCommonsViewController.h"

@interface PLImageCommonsViewController ()

@end

@implementation PLImageCommonsViewController

- (void)viewDidLoad
{
    PLTraceIn(@"");
    
    [super viewDidLoad];
    
    [self setImage:self.imageCommons.image];
    
    UITapGestureRecognizer *gestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    gestureRecogniser.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer:gestureRecogniser];
    
    PLTraceOut(@"");
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    PLTraceIn(@"");
    
    CGSize screenSize = self.view.bounds.size;
    UIImage *image = self.imageViewContainer.image;
    
    // Taille de l'image, en prenant en compte sa double précision
    CGSize imageSize = CGSizeMake(image.size.width / 2.0, image.size.height / 2.0);
    
    // Inversion des tailles pour anticiper la rotation
    self.imageViewWidthConstraint.constant = MAX(imageSize.width, screenSize.height);
    self.imageViewHeightConstraint.constant = MAX(imageSize.height, screenSize.width);
    
    // Centrage de l'image si besoin
    CGPoint contentOffset = CGPointMake(0.0, 0.0);
    if (imageSize.width > screenSize.height) {
        contentOffset.x = (imageSize.width - screenSize.height) / 2.0;
    }
    if (imageSize.height > screenSize.width) {
        contentOffset.y = (imageSize.height - screenSize.width) / 2.0;
    }
    
    self.scrollView.contentOffset = contentOffset;
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    PLTraceOut(@"");
}

- (void)viewWillAppear:(BOOL)animated
{
    PLTraceIn(@"");
    
    [self setImage:self.imageViewContainer.image];
    
    [super viewWillAppear:animated];
    PLTraceOut(@"");
}

- (void)setImage:(UIImage *)image
{
    PLTraceIn(@"");
    
    self.imageViewContainer.image = image;
    
    PLInfo(@"%f - %f", image.size.width, image.size.height);
    
    CGSize screenSize = self.view.bounds.size;
    
    // Taille de l'image, en prenant en compte sa double précision
    CGSize imageSize = CGSizeMake(image.size.width / 2.0, image.size.height / 2.0);
    
    self.imageViewWidthConstraint.constant = MAX(imageSize.width, screenSize.width);
    self.imageViewHeightConstraint.constant = MAX(imageSize.height, screenSize.height);
    
    // Centrage de l'image si besoin
    CGPoint contentOffset = CGPointMake(0.0, 0.0);
    if (imageSize.width > screenSize.width) {
        contentOffset.x = (imageSize.width - screenSize.width) / 2.0;
    }
    if (imageSize.height > screenSize.height) {
        contentOffset.y = (imageSize.height - screenSize.height) / 2.0;
    }
    
    self.scrollView.contentOffset = contentOffset;
    
    PLInfo(@"self.scrollView.zoomScale: %f", self.scrollView.zoomScale);
    
    PLTraceOut(@"");
}

- (void)handleTap:(UIGestureRecognizer*)tap {
    PLTraceIn(@"");
    
    [self.detailMonumentViewController dismissViewControllerAnimated:YES completion:nil];
    
    PLTraceOut(@"");
}

@end
