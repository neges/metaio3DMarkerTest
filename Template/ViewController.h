//
//  ViewController.h
//  Template
//
//  Created by Mac on 30.04.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"
#import "MetaioSDKViewController.h"

@interface ViewController : MetaioSDKViewController
{

    NSString *trackingFolder;
	NSString *visModelName;
	
    
    metaio::IGeometry* initModel;
    metaio::IGeometry* visModel;
    
    
    __weak IBOutlet UILabel *label;
    
	IBOutlet UIImageView *edgesView;
}

- (IBAction)changeTrackingData:(id)sender;
- (IBAction)takeScreenshot:(id)sender;
- (IBAction)resetTracking:(id)sender;
- (IBAction)showEdges:(id)sender;
- (IBAction)changeModel:(id)sender;

@end
