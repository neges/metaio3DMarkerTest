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

    
    NSString *documentsDirectory;
    NSString *trackingFolder;
    
    metaio::IGeometry* initModel;
    metaio::IGeometry* visModel;
    
    
    __weak IBOutlet UITextField *transX;
    __weak IBOutlet UITextField *transY;
    __weak IBOutlet UITextField *transZ;
    
    __weak IBOutlet UITextField *rotX;
    __weak IBOutlet UITextField *rotY;
    __weak IBOutlet UITextField *rotZ;
    
    __weak IBOutlet UILabel *label;
    
}

- (IBAction)changeTrackingData:(id)sender;
- (IBAction)takeScreenshot:(id)sender;

@end
