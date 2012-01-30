package spark.preloaders
{
    
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Sprite;
import flash.display.StageOrientation;
import flash.events.Event;
import flash.events.StageOrientationEvent;
import flash.geom.Matrix;
import flash.system.Capabilities;
import flash.text.TextField;
import flash.utils.getTimer;

import mx.events.FlexEvent;
import mx.managers.SystemManager;
import mx.preloaders.IPreloaderDisplay;

/**
 *  The SplashScreen class is the default preloader for Mobile Flex applications.
 *
 *  Developers can specify image class and resize mode through the Application properties
 *  <code>splashScreenImage</code>, <code>splashScreenScaleMode</code> and
 *  <code>splashScreenMinimumDelayTime</code>.
 *
 *  The SplashScreen monitors device orientation and updates the image so that it
 *  appears on screen as if the orientation is always StageOrientation.DEFAULT.
 *
 *  @see spark.Application#splashScreenImage
 *  @see spark.Application#splashScreenScaleMode
 *  @see spark.Application#splashScreenMinimumDisplayTime
 */
public class SplashScreen extends Sprite implements IPreloaderDisplay
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
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
    private var splashImage:DisplayObject;      // The splash image
    private var splashImageWidth:Number;        // original pre-transform width
    private var splashImageHeight:Number;       // original pre-transform height
    
    /**
     *  @private
     *  The resize mode for the splash image
     */
    // FIXME (egeorgie): string constants?
    private var scaleMode:String = "none";      // One of "none", "stretch", "letterbox" and "zoom".

    /**
     *  @private 
     *  Minimum time for the image to be visible 
     */    
    private var minimumDisplayTime:Number = 1000;  // in ms
    private var checkWaitTime:Boolean = false;  // obey minimumDisplayTime only valid if splashImage is valid
    private var displayTimeStart:int = -1;      // the start time of the image being displayed
    
    // FIXME (egeorgie): remove debugging code
    private var textField:TextField;
    private static var count:int = 0;

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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function initialize():void
    {
        // The preloader parameters are in the SystemManager's info() object
        var sysManager:SystemManager = this.parent.loaderInfo.content as SystemManager;
        if (!sysManager)
            return;
        var info:Object = sysManager.info();
        if (!info)
            return;

        if ("splashScreenImage" in info)
        {
            var SplashImageClass:Class = info["splashScreenImage"]; 
            this.splashImage = new SplashImageClass();
            this.splashImageWidth = splashImage.width;
            this.splashImageHeight = splashImage.height;
            addChild(splashImage as DisplayObject);

            if ("splashScreenScaleMode" in info)
                this.scaleMode = info["splashScreenScaleMode"];

            // Since we have a valid image being displayed, we need to obey the minimumDisplayTime
            if ("splashScreenMinimumDisplayTime" in info)
                this.minimumDisplayTime = info["splashScreenMinimumDisplayTime"];

            checkWaitTime = minimumDisplayTime > 0;
            if (checkWaitTime)
                this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);

            // FIXME (egeorgie): remove debug code
            {
                textField = new TextField();
                textField.width = 100;
                textField.height = 100;
                textField.textColor = 0xFF0000;
                addChild(textField);
            }

            this.stage.addEventListener(Event.RESIZE, Stage_resizeHandler, false /*useCapture*/, 0, true /*useWeakReference*/);
            this.stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, Stage_resizeHandler, false /*useCapture*/, 0, true /*useWeakReference*/)
            
            // Invoke explicitly to get the initial size/position
            Stage_resizeHandler(null);
            
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
        if (!splashImage)
            return;

        // Current stage orientation
        var orientation:String = stage.deviceOrientation;
        textField.text = orientation + " " + count++;

        // DPI scaling factor of the stage
        // FIXME (egeorgie): get this number from the SystemManager?
        var dpiScaling:Number = 1; //Capabilities.screenDPI >= 240 ? 1.5 : 1;

        // Get stage dimensions at default orientation
        var stageWidth:Number;
        var stageHeight:Number;
        if (orientation == StageOrientation.ROTATED_LEFT ||
            orientation == StageOrientation.ROTATED_RIGHT)
        {
            stageWidth = stage.stageHeight / dpiScaling;
            stageHeight = stage.stageWidth / dpiScaling;
        }
        else
        {
            stageWidth = stage.stageWidth / dpiScaling;
            stageHeight = stage.stageHeight / dpiScaling;
        }

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
        }
        
        if (scaleX != 1 || scaleY != 0)
        {
            width *= scaleX;
            height *= scaleY;
            m.scale(scaleX, scaleY);
        }

        // Rotate to keep aligned with StageOrientation.DEFAULT
        var rotation:Number = 0;
        switch (stage.deviceOrientation)
        {
            case StageOrientation.UNKNOWN:
            case StageOrientation.DEFAULT:
                rotation = 0;
            break;

            case StageOrientation.ROTATED_LEFT: 
                rotation = Math.PI * 1.5; // 270
            break;
            
            case StageOrientation.ROTATED_RIGHT: 
                rotation = Math.PI * 0.5; // 90
            break;

            case StageOrientation.UPSIDE_DOWN: 
                rotation = Math.PI; // 180
            break;
            
            // FIXME (egeorgie): remove debug code
            default:
                rotation = 12;
            break;
        }

        // Move center to (0,0):
        m.translate(-width / 2, -height / 2);

        // Rotate around center (0,0)
        if (rotation != 0)
            m.rotate(rotation);

        // Align center of image (0,0) to center of stage: 
        var stageWidthAfterOrientationAndDPI:Number = stage.stageWidth / dpiScaling;
        var stageHeightAfterOrientationAndDPI:Number = stage.stageHeight / dpiScaling;
        m.translate(stageWidthAfterOrientationAndDPI / 2, stageHeightAfterOrientationAndDPI / 2);

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
            dispatchEvent(new Event(Event.COMPLETE));
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
        
        this.removeEventListener(Event.ENTER_FRAME, initCompleteEnterFrameHandler);
        dispatchEvent(new Event(Event.COMPLETE)); 
    }
}
}