//
//  PLImageCommons+ext.m
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

#import "PLImageCommons+ext.h"

@implementation PLImageCommons (ext)

- (UIImage *)image
{
    PLTraceIn(@"");
    
    // Construction de l'image
    UIImage *image = [UIImage imageNamed:self.nom];
    
    if (!image) {
        PLWarning(@"Aucune image trouvée avec le nom %@", self.nom);
    }
    
    PLTraceOut(@"result: %@", image);
    return image;
}

- (NSString *)attribution
{
    PLTraceIn(@"");
    
    NSString *attribution = [NSString stringWithFormat:@"%@ / Wikimedia Commons / %@", self.auteur, self.licence];
    
    PLTraceOut(@"result: %@", attribution);
    return attribution;
}

- (NSURL *)commonsURL
{
    PLTraceIn(@"");
    
    NSString *relativeURLString = [@"http://commons.wikimedia.org/wiki/File:" stringByAppendingString:self.nom];
    
    NSURL *result = [NSURL URLWithString:[relativeURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    PLTraceOut(@"result: %@", result);
    return result;
}

@end
