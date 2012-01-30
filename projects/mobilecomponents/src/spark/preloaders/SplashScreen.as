////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.preloaders
{
    
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.StageAspectRatio;
import flash.display.StageOrientation;
import flash.events.Event;
import flash.events.StageOrientationEvent;
import flash.geom.Matrix;
import flash.system.Capabilities;
import flash.utils.getTimer;

import mx.core.RuntimeDPIProvider;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.SystemManager;
import mx.preloaders.IPreloaderDisplay;
import mx.preloaders.Preloader;

use namespace mx_internal;

/**
 *  The SplashScreen class is the default preloader for Mobile Flex applications.
 *
 *  Developers can specify image class and resize mode through the Application properties
 *  <code>splashScreenImage</code>, <code>splashScreenScaleMode</code> and
 *  <code>splashScreenMinimumDisplayTime</code>.
 *
 *  The SplashScreen monitors device orientation and updates the image so that it
 *  appears on screen as if the orientation is always StageOrientation.DEFAULT.
 *
 *  @see spark.components.Application#splashScreenImage
 *  @see spark.components.Application#splashScreenScaleMode
 *  @see spark.components.Application#splashScreenMinimumDisplayTime
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class SplashScreen extends Sprite implements IPreloaderDisplay
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function SplashScreen()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  The splash image 
     */
    private var splashImage:DisplayObject;              // The splash image
    private var splashImageWidth:Number;                // original pre-transform width
    private var splashImageHeight:Number;               // original pre-transform height
    private var SplashImageClass:Class;                 // The class of the generated splash image
    private var dynamicSourceAttempted:Boolean = false; // Have we tried to create the dynamicSource instance?
    private var dynamicSource:SplashScreenImage;        // Instance of the SplashScreenImage sub-class if one is passed in 
                                                        // as the value of Application's splashScreenImage property. 
    
    /**
     *  @private
     *  The resize mode for the splash image
     */
    private var info:Object = null;                     // The systemManager's info object
    private var scaleMode:String = "none";              // One of "none", "stretch", "letterbox" and "zoom".

    /**
     *  @private 
     *  Minimum time for the image to be visible 
     */    
    private var minimumDisplayTime:Number = 1000;       // in ms
    private var checkWaitTime:Boolean = false;          // obey minimumDisplayTime only valid if splashImage is valid
    private var displayTimeStart:int = -1;              // the start time of the image being displayed
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  backgroundAlpha
    //----------------------------------
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get backgroundAlpha():Number 
    { 
        return 0;
    }
    
    /**
     *  @private
     */
    public function set backgroundAlpha(value:Number):void
    {
    }
    
    //----------------------------------
    //  backgroundColor
    //----------------------------------
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function get backgroundColor():uint
    {
        return 0;
    }
    
    /**
     *  @private
     */
    public function set backgroundColor(value:uint):void
    {
    }
    
    //----------------------------------
    //  backgroundImage
    //----------------------------------
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get backgroundImage():Object
    {
        return null; 
    }
    
    /**
     *  @private
     */
    public function set backgroundImage(value:Object):void
    {
    }
    
    //----------------------------------
    //  backgroundSize
    //----------------------------------
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get backgroundSize():String
    {
        return null;
    }
    
    /**
     *  @private
     */
    public function set backgroundSize(value:String):void
    {
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  preloader
    //----------------------------------
    
    /**
     *  @copy mx.preloaders.DownloadProgressBar#preloader
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function set preloader(obj:Sprite):void
    {
        obj.addEventListener(FlexEvent.INIT_COMPLETE, preloader_initCompleteHandler, false /*useCapture*/, 0, true /*useWeakReference*/);
    }
    
    //----------------------------------
    //  stageHeight
    //----------------------------------
    
    private var _stageHeight:Number;
    
    /**
     *  @copy mx.preloaders.DownloadProgressBar#stageHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get stageHeight():Number
    { 
        return _stageHeight;
    }
    
    /**
     *  @private
     */
    public function set stageHeight(value:Number):void
    {
        _stageHeight = value;
    }
    
    //----------------------------------
    //  stageWidth
    //----------------------------------
    
    private var _stageWidth:Number;
    
    /**
     *  @copy mx.preloaders.DownloadProgressBar#stageWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get stageWidth():Number
    { 
        return _stageWidth;
    }
    
    /**
     *  @private
     */
    public function set stageWidth(value:Number):void
    {
        _stageWidth = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @copy mx.preloaders.DownloadProgressBar#initialize()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function initialize():void
    {
        // The preloader parameters are in the SystemManager's info() object
        var sysManager:SystemManager = this.parent.loaderInfo.content as SystemManager;
        if (!sysManager)
            return;
        
        info = sysManager.info();
        if (!info)
            return;
        
        // Add event listeners for resize.  The first render will happen
        // after the first resize 
        this.stage.addEventListener(Event.RESIZE, Stage_resizeHandler, false /*useCapture*/, 0, true /*useWeakReference*/);
    }

    /**
     *  @private
     *  Returns the class of the DisplayObject that should be instantiated
     *  as the splash screen.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    mx_internal function getImageClass(aspectRatio:String, dpi:Number, resolution:Number):Class
    {        
        var sourceClass:Class;

        // If we don't have a dynamic source, then get the class from the info object  
        if (!dynamicSource)
        {
            sourceClass = info["splashScreenImage"];
            
            // Is this class a dynamicSource?
            if (sourceClass && !dynamicSourceAttempted)
            {
                dynamicSourceAttempted = true
                dynamicSource = new sourceClass() as SplashScreenImage;
            }
        }
     
        // If we have a dynamic source, call its method to get the appropriate class
        return dynamicSource ? dynamicSource.getImageClass(aspectRatio, dpi, resolution) : sourceClass; 
    }
    
    private function prepareSplashScreen():void
    {
        // Grab the application's dpi provider class.  If one doesn't exist,
        // use the framework's default provider 
        var dpiProvider:RuntimeDPIProvider = ("runtimeDPIProvider" in info) ? 
            new info["runtimeDPIProvider"]() : new RuntimeDPIProvider();
        
        // Capture device dpi and orientation
        var dpi:Number = dpiProvider.runtimeDPI;
        var aspectRatio:String = (stage.stageWidth < stage.stageHeight) ? StageAspectRatio.PORTRAIT : StageAspectRatio.LANDSCAPE;
        var imageClass:Class = getImageClass(aspectRatio, dpi, Math.max(stage.stageWidth, stage.stageHeight));
        
        // The SplashImageClass will only be set if a splash screen image has
        // already be generated.  If the desired imageClass differs from the
        // current one, the splash screen should recreate the image with the
        // new class.
        if (imageClass && imageClass != SplashImageClass)
        {
            // The first time we create a splash screen, this will be null.
            // In this case, assign the initial splash screen properties
            if (!SplashImageClass)
            {
                if ("splashScreenScaleMode" in info)
                    this.scaleMode = info["splashScreenScaleMode"];
                
                // Since we have a valid image being displayed, we need to obey the minimumDisplayTime
                if ("splashScreenMinimumDisplayTime" in info)
                    this.minimumDisplayTime = info["splashScreenMinimumDisplayTime"];
                
                // Prepare the enterFrame handler for the minimum display time
                checkWaitTime = minimumDisplayTime > 0;
                if (checkWaitTime)
                    this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
            }
            
            // Store the new class
            SplashImageClass = imageClass;
            
            // Remove the old splash image
            if (splashImage)
                removeChild(splashImage);
            
            // Create the image
            this.splashImage = new SplashImageClass();
            this.splashImageWidth = splashImage.width;
            this.splashImageHeight = splashImage.height;
            addChildAt(splashImage as DisplayObject, 0);
        }
    }
    
    /**
     *  How long has the image beein showing on screen?  
     *  For the minimumDisplayTime property.
     *  @private 
     */
    private function get currentDisplayTime():int
    {
        if (-1 == displayTimeStart)
            return -1;
        return flash.utils.getTimer() - displayTimeStart;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     *  Updates the splashImage matrix based on the scaleMode, stage dimensions and stage orientation.
     */        
    private function Stage_resizeHandler(event:Event):void
    {
        // This method will prepare the splash screen and create a
        // new instance if needed
        prepareSplashScreen();

        if (!splashImage)
            return;

        // Current stage orientation
        var orientation:String = stage.orientation;

        // DPI scaling factor of the stage
        var dpiScale:Number = this.root.scaleX;

        // Get stage dimensions at default orientation
        var stageWidth:Number = stage.stageWidth / dpiScale;
        var stageHeight:Number = stage.stageHeight / dpiScale;

        // The image dimensions
        var width:Number = splashImageWidth;
        var height:Number = splashImageHeight;

        // Start building a matrix for the image
        var m:Matrix = new Matrix();

        // Stretch
        var scaleX:Number = 1;
        var scaleY:Number = 1;
        
        switch(scaleMode)
        {
            case "zoom":
                scaleX = Math.max( stageWidth / width, stageHeight / height);
                scaleY = scaleX;
            break;
            
            case "letterbox":
                scaleX = Math.min( stageWidth / width, stageHeight / height);
                scaleY = scaleX;
            break;
            
            case "stretch":
                scaleX = stageWidth / width;
                scaleY = stageHeight / height;
            break;

            case "none":
                // SDK-30984: undo application's dpi scaling if we have a dynamic SplashScreen source
                if (dynamicSource)
                {
                    scaleX = 1 / dpiScale;
                    scaleY = 1 / dpiScale;
                }
            break;
        }
        
        if (scaleX != 1 || scaleY != 1)
        {
            width *= scaleX;
            height *= scaleY;
            m.scale(scaleX, scaleY);
        }

        // Move center to (0,0):
        m.translate(-width / 2, -height / 2);

        // Align center of image (0,0) to center of stage: 
        m.translate(stageWidth / 2, stageHeight / 2);

        // Apply matrix
        splashImage.transform.matrix = m;
    }
    
    /**
     *  Remembers when the splash image was visible for the first time.
     *  For the minimumDisplayTime property.
     *  @private 
     */
    private function enterFrameHandler(event:Event):void
    {
        this.displayTimeStart = flash.utils.getTimer();
        this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
    }
    
    /**
     *  @private 
     *  Called when the Application has finished initializing.
     */
    private function preloader_initCompleteHandler(event:Event):void
    {
        // Do we have to wait?
        if (checkWaitTime && currentDisplayTime < minimumDisplayTime)
            this.addEventListener(Event.ENTER_FRAME, initCompleteEnterFrameHandler);
        else        
            dispatchComplete();
    }

    /**
     *  @private
     *  If the application is ready before the preloader minimumDisplayTime,
     *  then this handler will be called on every ENTER_FRAME until the 
     *  minimumDisplayTime is reached, when it will dispatch a COMPLETE event
     *  to let the Preloader class put up the Applicaiton on screen. 
     */
    private function initCompleteEnterFrameHandler(event:Event):void
    {
        if (currentDisplayTime <= minimumDisplayTime)
            return;

        dispatchComplete();
    }

    private function dispatchComplete():void
    {
        // Clean-up all listeners
        var preloader:Preloader = this.parent as Preloader;
        preloader.removeEventListener(FlexEvent.INIT_COMPLETE, preloader_initCompleteHandler, false /*useCapture*/);
        this.removeEventListener(Event.ENTER_FRAME, initCompleteEnterFrameHandler);
        this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);

        // Even though we have weak listeners, remove them since this object is not going to be destroyed until GC runs,
        // which means we could receive Stage events even if we're off-stage.
        this.stage.removeEventListener(Event.RESIZE, Stage_resizeHandler, false /*useCapture*/);
        this.stage.removeEventListener(StageOrientationEvent.ORIENTATION_CHANGE, Stage_resizeHandler, false);

        dispatchEvent(new Event(Event.COMPLETE));
    }
}
}