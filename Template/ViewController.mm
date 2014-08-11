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
    

	visModelName = @"system_box";
    trackingFolder = @"Assets/1";
    
       
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
    
            if (currentTrackingValues.quality>0)
			{
                [label setBackgroundColor:[UIColor greenColor]];
				[edgesView setHidden:true];
			}
			else
			{
                [label setBackgroundColor:[UIColor redColor]];
				
			}

}

-(IBAction)takeScreenshot:(id)sender
{

	m_metaioSDK->requestScreenshot(glView->defaultFramebuffer, glView->colorRenderbuffer);
}

- (IBAction)showEdges:(id)sender
{
	
	if (edgesView.isHidden)
	{
		[edgesView setHidden:false];
	}else
	{
		[edgesView setHidden:true];
	}
	
}

-(IBAction)resetTracking:(id)sender
{
	 [self setTrackingData];
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

    
    [self setTrackingData];
    
}

- (IBAction)changeModel:(id)sender
{
    
    UISegmentedControl *segControl = sender;
    
    
    if (segControl.selectedSegmentIndex == 0)
    {
        visModelName = @"system_box";
    }
    else if (segControl.selectedSegmentIndex == 1)
    {
        visModelName = @"system_front";
    }
    else if (segControl.selectedSegmentIndex == 2)
    {
        visModelName = @"system_back";
    }
	    
    [self setVisualisationModel];
    
}

-(void) setTrackingData
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
	
	NSString* edgesPicFile = [[NSBundle mainBundle] pathForResource:@"ScreenShot1" ofType:@"png" inDirectory:trackingFolder];
	UIImage* edgesImage = [[UIImage alloc] initWithContentsOfFile:edgesPicFile];
	
	edgesImage = [self imageWithImage:edgesImage scaledTo:2048 / edgesImage.size.width];
	
				
	[edgesView setImage:edgesImage];
	[edgesView setHidden:true];
	
    
}

- (UIImage *)imageWithImage:(UIImage *)image scaledTo:(CGFloat)scaleFactor {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
	CGSize newSize = CGSizeMake(image.size.width*scaleFactor, image.size.height*scaleFactor);

	
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
		
	
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
	
	//unload old initModel
    if( visModel )
    {
        m_metaioSDK->unloadGeometry(visModel);
        visModel = nil;
        
    }
	
	
    // load content
    
    NSString* objModel = [[NSBundle mainBundle] pathForResource:visModelName ofType:@"obj" inDirectory:@"Assets"];
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

-(void)initLight
{
	
    metaio::ILight*		m_pLight;
    
    m_pLight = m_metaioSDK->createLight();
    m_pLight->setType(metaio::ELIGHT_TYPE_DIRECTIONAL);
    
    m_metaioSDK->setAmbientLight(metaio::Vector3d(0.05f));
    m_pLight->setDiffuseColor(metaio::Vector3d(1, 1, 1)); // white
    
    m_pLight->setCoordinateSystemID(0);
	
    
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
    
	[self initLight];
	
    [self setVisualisationModel];
    
    [self setTrackingData];
    

	
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
	
	UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
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
