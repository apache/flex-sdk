////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.preloaders
{

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.getDefinitionByName;
import flash.utils.getTimer;

import mx.events.FlexEvent;
import mx.events.RSLEvent;
import mx.graphics.RectangularDropShadow;
import mx.managers.ISystemManager;

/**
 *  The SparkDownloadProgressBar class displays download progress.
 *  It is used by the Preloader control to provide user feedback
 *  while the application is downloading and loading. 
 *
 *  <p>The download progress bar displays information about 
 *  two different phases of the application: 
 *  the download phase and the initialization phase. </p>
 *
 *  <p>In the Application container, use the 
 *  the <code>preloader</code> property to specify the name of your subclass.</p>
 *
 *  <p>You can implement a custom download progress bar component 
 *  by creating a subclass of the SparkDownloadProgressBar class. 
 *  Do not implement a download progress bar as an MXML component 
 *  because it loads too slowly.</p>
 *
 *  @see mx.core.Application
 *  @see mx.preloaders.IPreloaderDisplay
 *  @see mx.preloaders.Preloader
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class SparkDownloadProgressBar extends Sprite implements IPreloaderDisplay
{
    include "../core/Version.as";
    
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
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function SparkDownloadProgressBar() 
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
     */
    private var _barWidth:Number;
    
    /**
     *  @private
     */
    private var _bgSprite:Sprite;
    
    /**
     *  @private
     */
    private var _barSprite:Sprite;

    /**
     *  @private
     */
    private var _barFrameSprite:Sprite;

    /**
     *  @private
     */
    private var _startTime:int;

    /**
     *  @private
     */
    private var _showingDisplay:Boolean = false;
    
    /**
     *  @private
     */
    private var _downloadComplete:Boolean = false;

    /**
     *  @private
     */
    private var _displayStartCount:uint = 0; 

    /**
     *  @private
     */
    private var _initProgressCount:uint = 0;

    /**
     *  The total number of validation events you expect to get
     *  in the initializing phase.  This should be an integer
     *  greater or equal to 4 (and note that if it is greater than 4
     *  you might have an inefficiency in your initialization code)
     *
     *  @default 6
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected var initProgressTotal:uint = 6;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  visible
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the visible property.
     */
    private var _visible:Boolean = false;

    /**
     *  Specifies whether the download progress bar is visible.
     *
     *  <p>When the Preloader control determines that the progress bar should be displayed, 
     *  it sets this value to <code>true</code>. When the Preloader control determines that
     *  the progress bar should be hidden, it sets the value to <code>false</code>.</p>
     *
     *  <p>A subclass of the SparkDownloadProgressBar class should never modify this property. 
     *  Instead, you can override the setter method to recognize when 
     *  the Preloader control modifies it, and perform any necessary actions. </p>
     *
     *  @default false 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function get visible():Boolean
    {
        return _visible;
    }

    /**
     *  @private
     */
    override public function set visible(value:Boolean):void
    {
        if (!_visible && value) 
            show();
        
        else if (_visible && !value ) 
            hide();
        
        _visible = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties: IPreloaderDisplay
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  backgroundAlpha
    //----------------------------------

    /**
     *  @private
     *  Storage for the backgroundAlpha property.
     */
    private var _backgroundAlpha:Number = 1;

    /**
     *  Alpha level of the SWF file or image defined by 
     *  the <code>backgroundImage</code> property, or the color defined by 
     *  the <code>backgroundColor</code> property. 
     *  Valid values range from 0 to 1.0.    
     *  Override this property to set your own value in a custom class.
     *
     *  <p>You can specify either a <code>backgroundColor</code> 
     *  or a <code>backgroundImage</code>, but not both.</p>
     *
     *  @default 1.0
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get backgroundAlpha():Number
    {
        if (!isNaN(_backgroundAlpha))
            return _backgroundAlpha;
        else
            return 1;
    }
    
    /**
     *  @private
     */
    public function set backgroundAlpha(value:Number):void
    {
        _backgroundAlpha = value;
    }
    
    //----------------------------------
    //  backgroundColor
    //----------------------------------

    /**
     *  @private
     *  Storage for the backgroundColor property.
     */
    private var _backgroundColor:uint;

    /**
     *  Background color of a download progress bar.
     *  Override this property to set your own value in a custom class.
     *
     *  <p>You can specify either a <code>backgroundColor</code> 
     *  or a <code>backgroundImage</code>, but not both.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get backgroundColor():uint
    {
        return _backgroundColor;
    }

    /**
     *  @private
     */
    public function set backgroundColor(value:uint):void
    {
        _backgroundColor = value;
    }
    
    //----------------------------------
    //  backgroundImage
    //----------------------------------

    /**
     *  @private
     *  Storage for the backgroundImage property.
     */
    private var _backgroundImage:Object;
    
    /**
     *  The background image of the application,
     *  which is passed in by the preloader.
     *  Override this property to set your own value in a custom class.
     *
     *  <p>You can specify either a <code>backgroundColor</code> 
     *  or a <code>backgroundImage</code>, but not both.</p>
     *
     *  <p>A value of null means "not set". 
     *  If this style and the <code>backgroundColor</code> style are undefined, 
     *  the component has a transparent background.</p>
     *
     *  <p>The preloader does not display embedded images. 
     *  You can only use images loaded at runtime.</p>
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get backgroundImage():Object
    {
        return _backgroundImage;
    }
    
    /**
     *  @private
     */
    public function set backgroundImage(value:Object):void
    {
        _backgroundImage = value;
    }
    
    //----------------------------------
    //  backgroundSize
    //----------------------------------

    /**
     *  @private
     *  Storage for the backgroundSize property.
     */
    private var _backgroundSize:String = "";

    /**
     *  Scales the image specified by <code>backgroundImage</code>
     *  to different percentage sizes.
     *  A value of <code>"100%"</code> stretches the image
     *  to fit the entire component.
     *  To specify a percentage value, you must include the percent sign (%).
     *  A value of <code>"auto"</code>, maintains
     *  the original size of the image.
     *
     *  @default "auto"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get backgroundSize():String
    {
        return _backgroundSize;
    }
    
    /**
     *  @private
     */
    public function set backgroundSize(value:String):void
    {
        _backgroundSize = value;
    }
    
    //----------------------------------
    //  preloader
    //----------------------------------

    /**
     *  @private
     *  Storage for the preloader property.
     */
    private var _preloader:Sprite; 
     
    /**
     *  The Preloader class passes in a reference to itself to the display class
     *  so that it can listen for events from the preloader.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set preloader(value:Sprite):void
    {
        _preloader = value;
    
        value.addEventListener(ProgressEvent.PROGRESS, progressHandler);    
        value.addEventListener(Event.COMPLETE, completeHandler);
        
        value.addEventListener(RSLEvent.RSL_PROGRESS, rslProgressHandler);
        value.addEventListener(RSLEvent.RSL_COMPLETE, rslCompleteHandler);
        value.addEventListener(RSLEvent.RSL_ERROR, rslErrorHandler);
        
        value.addEventListener(FlexEvent.INIT_PROGRESS, initProgressHandler);
        value.addEventListener(FlexEvent.INIT_COMPLETE, initCompleteHandler);
    }

    //----------------------------------
    //  stageHeight
    //----------------------------------

    /**
     *  @private
     *  Storage for the stageHeight property.
     */
    private var _stageHeight:Number = 375;

    /**
     *  The height of the stage,
     *  which is passed in by the Preloader class.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

    /**
     *  @private
     *  Storage for the stageHeight property.
     */
    private var _stageWidth:Number = 500;

    /**
     *  The width of the stage,
     *  which is passed in by the Preloader class.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    //  Methods:IPreloaderDisplay
    //
    //--------------------------------------------------------------------------

    /**
     *  Called by the Preloader after the download progress bar
     *  has been added as a child of the Preloader. 
     *  This should be the starting point for configuring your download progress bar. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function initialize():void
    {
        _startTime = getTimer();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    
    /**
     *  Creates the subcomponents of the display.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function createChildren():void
    {       
        var g:Graphics = graphics;
        
        // Draw the background first
        // Same value as StyleManager.NOT_A_COLOR. However, we don't want to bring in StyleManager at this point. 
        if (backgroundColor != 0xFFFFFFFF)
        {
            g.beginFill(backgroundColor, backgroundAlpha);
            g.drawRect(0, 0, stageWidth, stageHeight);
        }
                
        if (backgroundImage != null)
            loadBackgroundImage(backgroundImage);
            
        // Determine the size
        var totalWidth:Number = Math.min(stageWidth - 10, 207);
        var totalHeight:Number = 19;
        var startX:Number = Math.round((stageWidth - totalWidth) / 2);
        var startY:Number = Math.round((stageHeight - totalHeight) / 2);
        
        _barWidth = totalWidth - 10;
        
        _bgSprite = new Sprite();
        _barFrameSprite = new Sprite();
        _barSprite = new Sprite();
        
        addChild(_bgSprite);
        addChild(_barFrameSprite);  
        addChild(_barSprite);
        
        _barFrameSprite.x = _barSprite.x = startX + 5;
        _barFrameSprite.y = _barSprite.y = startY + 5;
        
        // Draw the background/shadow
        g = _bgSprite.graphics;
        g.lineStyle(1, 0x636363);
        g.beginFill(0xE8E8E8);
        g.drawRect(startX, startY, totalWidth, totalHeight);
        g.endFill();
        g.lineStyle();
        
        g = graphics;
        var ds:RectangularDropShadow = new RectangularDropShadow();
        ds.color = 0x000000;
        ds.angle = 90;
        ds.alpha = .6;
        ds.distance = 2;
        ds.drawShadow(g, 
                      startX,
                      startY,
                      totalWidth,
                      totalHeight);
        
        var chromeColor:uint = getPreloaderChromeColor();
        if (chromeColor != DEFAULT_COLOR)
        {
            var colorTransform:ColorTransform = new ColorTransform();
            
            colorTransform.redOffset = ((chromeColor & (0xFF << 16)) >> 16) - DEFAULT_COLOR_VALUE;
            colorTransform.greenOffset = ((chromeColor & (0xFF << 8)) >> 8) - DEFAULT_COLOR_VALUE;
            colorTransform.blueOffset = (chromeColor & 0xFF) - DEFAULT_COLOR_VALUE;
            
            _bgSprite.transform.colorTransform = colorTransform;
            _barFrameSprite.transform.colorTransform = colorTransform;
            _barSprite.transform.colorTransform = colorTransform;
        }
    }
    
    private static const DEFAULT_COLOR:uint = 0xCCCCCC;
    private static const DEFAULT_COLOR_VALUE:uint = 0xCC;

    /**
     *  @private
     *  We don't have a reliable way to get the system manager for the currently
     *  loading application. During normal progres bar instantiation, the parent.parent
     *  is the system manager loading the app, so that is what we'll use.
     *  This is only needed to grab the "preloaderChromeColor" property from the info() 
     *  structure.
     */
    private function getPreloaderChromeColor():uint
    {
        const sm:ISystemManager = parent.parent as ISystemManager;
        const valueObject:Object = (sm) ? sm.info()["preloaderChromeColor"] : null;

        var valueString:String = valueObject as String;
        if (valueString && (valueString.charAt(0) == "#"))
            valueString = "0x" + valueString.substring(1);
        
        return (valueString) ? uint(valueString) : DEFAULT_COLOR;
    }
    
    private var lastBarWidth:Number = 0;
    
    /** 
     *  Updates the outer portion of the download progress bar to
     *  indicate download progress.
     *  
     *  @param completed Number of bytes of the application SWF file
     *  that have been downloaded.
     *
     *  @param total Size of the application SWF file in bytes.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function setDownloadProgress(completed:Number, total:Number):void
    {
        if (!_barFrameSprite)
            return;

        const outerHighlightColors:Array = [0xFFFFFF, 0xFFFFFF];
        const outerHighlightAlphas:Array = [0.12, 0.80];
        const fillColors:Array = [0xA9A9A9, 0xBDBDBD];
        const fillAlphas:Array = [1, 1];
        const ratios:Array = [0, 255];
        
        var w:Number = Math.round(_barWidth * Math.min(completed / total, 1));
        var h:Number = 9;
        var g:Graphics = _barFrameSprite.graphics;
        var m:Matrix = new Matrix();

        // Make sure the download progress bar never regresses in size.
        w = Math.max(w, lastBarWidth);
        lastBarWidth = w;
        
        m.createGradientBox(w, h, 90);
        
        g.clear();
        
        // Outer highlight
        g.lineStyle(1);
        g.lineGradientStyle("linear", outerHighlightColors, outerHighlightAlphas, ratios, m);
        g.drawRect(0, 0, w, h);
        
        // border/fill
        g.lineStyle(1, 0x636363);
        g.beginGradientFill("linear", fillColors, fillAlphas, ratios, m);
        g.drawRect(1, 1, w - 2, h - 2);
        g.endFill();
        
        // highlight
        g.lineStyle(1, 0, 0.12);
        g.moveTo(2, h - 1);
        g.lineTo(2, 2);
        g.lineTo(w - 2, 2);
        g.lineTo(w - 2, h - 1);

        if (completed == total)
            _downloadComplete = true
    }
    
    
    /** 
     *  Updates the inner portion of the download progress bar to
     *  indicate initialization progress.
     *  
     *  @param completed Number of initialization steps that
     *  have been completed
     *
     *  @param total Total number of initialization steps
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function setInitProgress(completed:Number, total:Number):void
    {
        const highlightColors:Array = [0xFFFFFF, 0xEAEAEA];
        const fillColors:Array = [0xFFFFFF, 0xD8D8D8];
        const alphas:Array = [1, 1];
        const ratios:Array = [0, 255];
        
        var w:Number = Math.round(_barWidth * Math.min(completed / total, 1));
        var h:Number = 9;
        var g:Graphics = _barSprite.graphics;
        var m:Matrix = new Matrix();
        
        m.createGradientBox(w - 6, h - 2, 90, 2, 2);
        
        g.clear();
        
        // highlight/fill
        g.lineStyle(1);
        g.lineGradientStyle("linear", highlightColors, alphas, ratios, m);
        g.beginGradientFill("linear", fillColors, alphas, ratios, m);
        g.drawRect(2, 2, w - 4, h - 4);
        g.endFill();
        
        // divider line
        g.lineStyle(1, 0, 0.55);
        g.moveTo(w - 1, 2);
        g.lineTo(w - 1, h - 1);
    }
    
    /**
     *  @private
     *  Make the display class visible.
     */
    private function show():void
    {
        // swfobject reports 0 sometimes at startup
        // if we get zero, wait and try on next attempt
        if (stageWidth == 0 && stageHeight == 0)
        {
            try
            {
                stageWidth = stage.stageWidth;
                stageHeight = stage.stageHeight
            }
            catch (e:Error)
            {
                stageWidth = loaderInfo.width;
                stageHeight = loaderInfo.height;
            }
            if (stageWidth == 0 && stageHeight == 0)
                return;
        }

        _showingDisplay = true;
        createChildren();
    }
    
    /**
     *  @private
     */
    private function hide():void
    {
    }
    
    /**
     *  Defines the algorithm for determining whether to show
     *  the download progress bar while in the download phase.
     *
     *  @param elapsedTime Number of milliseconds that have elapsed
     *  since the start of the download phase.
     *
     *  @param event The ProgressEvent object that contains
     *  the <code>bytesLoaded</code> and <code>bytesTotal</code> properties.
     *
     *  @return If the return value is <code>true</code>, then show the 
     *  download progress bar.
     *  The default behavior is to show the download progress bar 
     *  if more than 700 milliseconds have elapsed
     *  and if Flex has downloaded less than half of the bytes of the SWF file.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function showDisplayForDownloading(elapsedTime:int,
                                              event:ProgressEvent):Boolean
    {
//        trace("showDisplayForDownloading: elapsedTime = " + elapsedTime);
//        trace("showDisplayForDownloading:" + event.bytesLoaded + " " +  event.bytesTotal + " " +  (event.bytesLoaded < event.bytesTotal / 2));
        return elapsedTime > 700 &&
            event.bytesLoaded < event.bytesTotal / 2;
    }
    
    /**
     *  Defines the algorithm for determining whether to show the download progress bar
     *  while in the initialization phase, assuming that the display
     *  is not currently visible.
     *
     *  @param elapsedTime Number of milliseconds that have elapsed
     *  since the start of the download phase.
     *
     *  @param count number of times that the <code>initProgress</code> event
     *  has been received from the application.
     *
     *  @return If <code>true</code>, then show the download progress bar.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function showDisplayForInit(elapsedTime:int, count:int):Boolean
    {
//        trace("showDisplayForInit: elapsedTime = " + elapsedTime + " count = " + count);
        return elapsedTime > 300 && count == 2;
    }

    
    /**
     *  @private
     */
    private function loadBackgroundImage(classOrString:Object):void
    {
        var cls:Class;
        
        // The "as" operator checks to see if classOrString
        // can be coerced to a Class
        if (classOrString && classOrString as Class)
        {
            // Load background image given a class pointer
            cls = Class(classOrString);
            initBackgroundImage(new cls());
        }
        else if (classOrString && classOrString is String)
        {
            try
            {
                cls = Class(getDefinitionByName(String(classOrString)));
            }
            catch(e:Error)
            {
                // ignore
            }

            if (cls)
            {
                var newStyleObj:DisplayObject = new cls();
                initBackgroundImage(newStyleObj);
            }
            else
            {
                // Loading the image is slightly different
                // than in Loader.loadContent()... is this on purpose?

                // Load background image from external URL
                var loader:Loader = new Loader();
                loader.contentLoaderInfo.addEventListener(
                    Event.COMPLETE, loader_completeHandler);
                loader.contentLoaderInfo.addEventListener(
                    IOErrorEvent.IO_ERROR, loader_ioErrorHandler);  
                var loaderContext:LoaderContext = new LoaderContext();
                loaderContext.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
                loader.load(new URLRequest(String(classOrString)), loaderContext);      
            }
        }
    }
    
    /**
     *  @private
     */
    private function initBackgroundImage(image:DisplayObject):void
    {
        addChildAt(image,0);
        
        var backgroundImageWidth:Number = image.width;
        var backgroundImageHeight:Number = image.height;
        
        // Scale according to backgroundSize
        var percentage:Number = calcBackgroundSize();
        if (isNaN(percentage))
        {
            var sX:Number = 1.0;
            var sY:Number = 1.0;
        }
        else
        {
            var scale:Number = percentage * 0.01;
            sX = scale * stageWidth / backgroundImageWidth;
            sY = scale * stageHeight / backgroundImageHeight;
        }
        
        image.scaleX = sX;
        image.scaleY = sY;

        // Center everything.
        // Use a scrollRect to position and clip the image.
        var offsetX:Number =
            Math.round(0.5 * (stageWidth - backgroundImageWidth * sX));
        var offsetY:Number =
            Math.round(0.5 * (stageHeight - backgroundImageHeight * sY));

        image.x = offsetX;
        image.y = offsetY;

        // Adjust alpha to match backgroundAlpha
        if (!isNaN(backgroundAlpha))
            image.alpha = backgroundAlpha;
    }
    
    /**
     *  @private
     */
    private function calcBackgroundSize():Number
    {   
        var percentage:Number = NaN;
        
        if (backgroundSize)
        {
            var index:int = backgroundSize.indexOf("%");
            if (index != -1)
                percentage = Number(backgroundSize.substr(0, index));
        }
        
        return percentage;
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Event listener for the <code>ProgressEvent.PROGRESS</code> event. 
     *  This implementation updates the progress bar
     *  with the percentage of bytes downloaded.
     *
     *  @param event The event object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function progressHandler(event:ProgressEvent):void
    {
        var loaded:uint = event.bytesLoaded;
        var total:uint = event.bytesTotal;

        var elapsedTime:int = getTimer() - _startTime;
        
        // Only show the Loading phase if it will appear for awhile.
        if (!_showingDisplay && showDisplayForDownloading(elapsedTime, event))
            show();
            
        if (_showingDisplay)        
            setDownloadProgress(event.bytesLoaded, event.bytesTotal);
    }
    
    /**
     *  Event listener for the <code>Event.COMPLETE</code> event. 
     *  The default implementation does nothing.
     *
     *  @param event The event object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function completeHandler(event:Event):void
    {
    }
    
    /**
     *  Event listener for the <code>RSLEvent.RSL_PROGRESS</code> event. 
     *  The default implementation does nothing.
     *
     *  @param event The event object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function rslProgressHandler(event:RSLEvent):void
    {
    }
    
    /**
     *  Event listener for the <code>RSLEvent.RSL_COMPLETE</code> event. 
     *
     *  @param event The event object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function rslCompleteHandler(event:RSLEvent):void
    {
        //trace("rsl " + event.rslIndex + " of " + event.rslTotal);
    }
    
    /**
     *  Event listener for the <code>RSLEvent.RSL_ERROR</code> event. 
     *  This event listner handles any errors detected when downloading an RSL.
     *
     *  @param event The event object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function rslErrorHandler(event:RSLEvent):void
    {
        _preloader.removeEventListener(ProgressEvent.PROGRESS,
                                       progressHandler);    
        
        _preloader.removeEventListener(Event.COMPLETE,
                                       completeHandler);
        
        _preloader.removeEventListener(RSLEvent.RSL_PROGRESS,
                                       rslProgressHandler);

        _preloader.removeEventListener(RSLEvent.RSL_COMPLETE,
                                       rslCompleteHandler);

        _preloader.removeEventListener(RSLEvent.RSL_ERROR,
                                       rslErrorHandler);
        
        _preloader.removeEventListener(FlexEvent.INIT_PROGRESS,
                                       initProgressHandler);

        _preloader.removeEventListener(FlexEvent.INIT_COMPLETE,
                                       initCompleteHandler);
    
        if (!_showingDisplay)
        {
            show();
            // Call setDownloadProgress here to draw
            // the progress bar background.
            setDownloadProgress(100, 100);
        }
        
        var errorField:ErrorField = new ErrorField(this);
        errorField.show(event.errorText);
    }
    
    /**
     *  Event listener for the <code>FlexEvent.INIT_PROGRESS</code> event. 
     *  This implementation updates the progress bar
     *  each time the event is dispatched. 
     *
     *  @param event The event object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function initProgressHandler(event:Event):void
    {
        // make elapsed time relative the time we started init.
        if (_initProgressCount == 0)
            _startTime = getTimer();

        var elapsedTime:int = getTimer() - _startTime;
        
        _initProgressCount++;
        
        if (!_showingDisplay &&
            showDisplayForInit(elapsedTime, _initProgressCount))
        {
            _displayStartCount = _initProgressCount;
            show();
            
            // If we are showing the progress for the first
            // time here, we need to call setDownloadProgress() once to draw
            // the progress bar background.
            setDownloadProgress(100, 100);
        }

        if (_showingDisplay)
        {
            // if show() did not actually show because of SWFObject bug
            // then we may need to draw the download bar background here
            if (!_downloadComplete)
                setDownloadProgress(100, 100);

            setInitProgress(_initProgressCount, initProgressTotal);
        }
    }
    
    /**
     *  Event listener for the <code>FlexEvent.INIT_COMPLETE</code> event.
     *  This implementation dispatches a <code>Event.COMPLETE</code> event.
     * 
     *  @param event The event object
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function initCompleteHandler(event:Event):void
    {
        dispatchEvent(new Event(Event.COMPLETE)); 
    }

    /**
     *  @private
     */
    private function loader_completeHandler(event:Event):void
    {
        var target:DisplayObject = DisplayObject(LoaderInfo(event.target).loader);
        
        initBackgroundImage(target);
    }
    
    /**
     *  @private
     */
    private function loader_ioErrorHandler(event:IOErrorEvent):void
    {
        // Swallow the error
    }
    
}

}

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.system.Capabilities;
import flash.text.TextFieldAutoSize;
import flash.display.DisplayObjectContainer;
import flash.display.Stage;
import mx.preloaders.SparkDownloadProgressBar;


    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
/**
 * @private
 * 
 * Area to display error messages to help debug startup problems.
 * 
 */
class ErrorField extends Sprite
{
    private var downloadProgressBar:SparkDownloadProgressBar;
    private const MIN_WIDTH_INCHES:int = 2;                    // min width of error message in inches
    private const MAX_WIDTH_INCHES:int = 6;                    // max width of error message in inches
    private const TEXT_MARGIN_PX:int = 10;
    
    
    //----------------------------------
    //  labelFormat
    //----------------------------------

    /**
     *  The TextFormat object of the TextField component of the label.
     *  This is a read-only property which you must override
     *  if you need to change it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function get labelFormat():TextFormat
    {
        var tf:TextFormat = new TextFormat();
        tf.color = 0x000000;
        
        tf.font = "Arial";
        tf.size = 12;
        return tf;
    }

   
   /**
   * @private
   * 
   * @param - parent - parent of the error field.
   */ 
    public function ErrorField(downloadProgressBar:SparkDownloadProgressBar)
    {
        super();
        this.downloadProgressBar = downloadProgressBar;
    }
    
    
    /**
    * Create and show the error message.
    * 
    * @param errorText - text for error message.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public function show(errorText:String):void
    {
        if (errorText == null || errorText.length == 0)
            return;
            
        var screenWidth:Number = downloadProgressBar.stageWidth;
        var screenHeight:Number = downloadProgressBar.stageHeight;
        
        // create the text field for the message and 
        // add it to the parent.
        var textField:TextField = new TextField();
        
        textField.autoSize = TextFieldAutoSize.LEFT;
        textField.multiline = true;
        textField.wordWrap = true;
        textField.background = true;
        textField.defaultTextFormat = labelFormat;
        textField.text = errorText;

        textField.width = Math.max(MIN_WIDTH_INCHES * Capabilities.screenDPI, screenWidth - (TEXT_MARGIN_PX * 2));
        textField.width = Math.min(MAX_WIDTH_INCHES * Capabilities.screenDPI, textField.width);
        textField.y = Math.max(0, screenHeight - TEXT_MARGIN_PX - textField.height);
        
        // center field horizontally
        textField.x = (screenWidth - textField.width) / 2;
        
        downloadProgressBar.parent.addChild(this);
        this.addChild(textField);
                
    }
}
