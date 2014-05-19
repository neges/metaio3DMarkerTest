//
//  ViewController.m
//  Template
//
//  Created by Mac on 30.04.13.
//  Copyright (c) 2013 itm. All rights reserved.
//


//-------------------
//Template für metaio5.5beta
//-------------------


#import "ViewController.h"



@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Documents Ornder abfragen
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    
    trackingFolder = @"Assets/tdPipeFull";
    
       
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Logging

-(void)logging

{

    //TrackingValues Abfragen
        metaio::TrackingValues currentTrackingValues = m_metaioSDK->getTrackingValues(1);

            //Translation  und Rotation abfragen
            metaio::Vector3d markerTranslation = currentTrackingValues.translation;
            metaio::Vector3d markerRotation = currentTrackingValues.rotation.getEulerAngleDegrees();
    
            //Werte in GUI schreiben
            [transX setText:[NSString stringWithFormat:@"%1.3f",  markerTranslation.x]];
            [transY setText:[NSString stringWithFormat:@"%1.3f",  markerTranslation.y]];
            [transZ setText:[NSString stringWithFormat:@"%1.3f",  markerTranslation.z]];
    
            [rotX setText:[NSString stringWithFormat:@"%1.3f",  markerRotation.x]];
            [rotY setText:[NSString stringWithFormat:@"%1.3f",  markerRotation.y]];
            [rotZ setText:[NSString stringWithFormat:@"%1.3f",  markerRotation.z]];
    
            if (currentTrackingValues.quality>0)
                [label setBackgroundColor:[UIColor greenColor]];
            else
                [label setBackgroundColor:[UIColor redColor]];
    

}

-(IBAction)takeScreenshot:(id)sender
{

	NSDate *date = [[NSDate alloc] init];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH_mm_ss__ddMMyy"];
    NSString* logDate = [formatter stringFromDate:date];
    
	NSString *screenShotFilename = [NSString stringWithFormat:@"%@.jpg",logDate];;
	
	m_metaioSDK->requestScreenshot([[documentsDirectory stringByAppendingPathComponent:screenShotFilename] UTF8String],glView->defaultFramebuffer, glView->colorRenderbuffer);

}

- (IBAction)changeTrackingData:(id)sender
{
    
    UISegmentedControl *segControl = sender;
    
    
    if (segControl.selectedSegmentIndex == 0)
    {
        trackingFolder = @"Assets/1";
    }
    else if (segControl.selectedSegmentIndex == 1)
    {
        trackingFolder = @"Assets/2";
    }
    else if (segControl.selectedSegmentIndex == 2)
    {
        trackingFolder = @"Assets/3";
    }
	else if (segControl.selectedSegmentIndex == 3)
    {
        trackingFolder = @"Assets/4";
    }
	else if (segControl.selectedSegmentIndex == 4)
    {
        trackingFolder = @"Assets/5";
    }
	else if (segControl.selectedSegmentIndex == 5)
    {
        trackingFolder = @"Assets/6";
    }

    
    [self setTrackingDate];
    
}

-(void) setTrackingDate
{
    
    // load our tracking configuration
    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"Tracking" ofType:@"xml" inDirectory:trackingFolder];
	if(trackingDataFile)
	{
		bool success = m_metaioSDK->setTrackingConfiguration([trackingDataFile UTF8String]);
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}
    
    [self setInitModel];
    
}

-(void) setInitModel
{
    
    //unload old initModel
    if( initModel )
    {
        m_metaioSDK->unloadGeometry(initModel);
        initModel = nil;
        
    }
    
    
    // load content
    NSString* objModel = [[NSBundle mainBundle] pathForResource:@"SurfaceModel" ofType:@"obj" inDirectory:trackingFolder];
    initModel = m_metaioSDK->createGeometry([objModel UTF8String]);
    
    if( initModel )
    {
        
        initModel->setCoordinateSystemID(2);
        
        initModel->setVisible(true);
        
        initModel->setTransparency(0.3);
        
        
    }
    else
    {
        NSLog(@"error, could not load initModel");
        
    }
    
}

-(void) setVisualisationModel
{
    // load content
    
    NSString* objModel = [[NSBundle mainBundle] pathForResource:@"system_box" ofType:@"obj" inDirectory:@"Assets"];
    visModel = m_metaioSDK->createGeometry([objModel UTF8String]);
    
    if( visModel )
    {
        
        visModel->setCoordinateSystemID(1);
        
        visModel->setVisible(true);
        
        visModel->setTransparency(0.5);
        
        
    }
    else
    {
        NSLog(@"error, could not load Visualisation Model");
        
    }
    
}


#pragma mark - @protocol metaioSDKDelegate

- (void) drawFrame
{
    [super drawFrame];
    
    [self logging];
    

}

- (void) onSDKReady
{
    NSLog(@"The SDK is ready");
    
    [self setVisualisationModel];
    
    [self setTrackingDate];
    

	
}

- (void) onAnimationEnd: (metaio::IGeometry*) geometry  andName:(NSString*) animationName
{
    NSLog(@"animation ended %@", animationName);
}


- (void) onMovieEnd: (metaio::IGeometry*) geometry  andName:(NSString*) movieName
{
	NSLog(@"movie ended %@", movieName);
	
}

- (void) onNewCameraFrame:(metaio::ImageStruct *)cameraFrame
{
    NSLog(@"a new camera frame image is delivered %f", cameraFrame->timestamp);
}

- (void) onCameraImageSaved:(NSString *)filepath
{
    NSLog(@"a new camera frame image is saved to %@", filepath);
}

-(void) onScreenshotImage:(metaio::ImageStruct *)image
{
    
    NSLog(@"screenshot image is received %f", image->timestamp);
}

- (void) onScreenshotImageIOS:(UIImage *)image
{
    NSLog(@"screenshot image is received %@", [image description]);
}

-(void) onScreenshot:(NSString *)filepath
{
    NSLog(@"screenshot is saved to %@", filepath);
}

- (void) onTrackingEvent:(const metaio::stlcompat::Vector<metaio::TrackingValues>&)trackingValues
{
    NSLog(@"The tracking time is: %f", trackingValues[0].timeElapsed);
}

- (void) onInstantTrackingEvent:(bool)success file:(NSString*)file
{
    if (success)
    {
        NSLog(@"Instant 3D tracking is successful");
    }
}

- (void) onVisualSearchResult:(bool)success error:(NSString *)errorMsg response:(std::vector<metaio::VisualSearchResponse>)response
{
    if (success)
    {
        NSLog(@"Visual search is successful");
    }
}

- (void) onVisualSearchStatusChanged:(metaio::EVISUAL_SEARCH_STATE)state
{
    if (state == metaio::EVSS_SERVER_COMMUNICATION)
    {
        NSLog(@"Visual search is currently communicating with the server");
    }
}


@end
