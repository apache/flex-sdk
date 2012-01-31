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

package spark.components
{

import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;

import mx.core.mx_internal;
import mx.graphics.BitmapScaleMode;
import mx.utils.BitFlagUtil;

import spark.components.supportClasses.Range;
import spark.components.supportClasses.SkinnableComponent;
import spark.core.IContentLoader;
import spark.primitives.BitmapImage;

use namespace mx_internal;

// Support basic text styles for any optional preloader label(s).
include "../styles/metadata/BasicInheritingTextStyles.as"

//--------------------------------------
//  SkinStates
//--------------------------------------

/**
 *  Uninitialized state of the Image.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
[SkinState("uninitialized")]

/**
 *  Preloading state of the Image. enablePreload must
 *  be set to true to enable this component state.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
[SkinState("loading")]

/**
 *  Ready state of the Image.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
[SkinState("ready")]

/**
 *  Invalid state of the Image, e.g. image could not be 
 *  successfully loaded.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
[SkinState("invalid")]

/**
 *  Disabled state.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
[SkinState("disabled")]

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when content loading is complete.
 *
 *  @eventType flash.events.Event.COMPLETE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="complete", type="flash.events.Event")]

/**
 *  Dispatched when a network request is made over HTTP 
 *  and Flash Player or AIR can detect the HTTP status code.
 * 
 *  @eventType flash.events.HTTPStatusEvent.HTTP_STATUS
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]

/**
 *  Dispatched when an input/output error occurs.
 *  @see flash.events.IOErrorEvent
 *
 *  @eventType flash.events.IOErrorEvent.IO_ERROR
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="ioError", type="flash.events.IOErrorEvent")]

/**
 *  Dispatched when content is loading.
 *
 *  <p><strong>Note:</strong> 
 *  The <code>progress</code> event is not guaranteed to be dispatched.
 *  The <code>complete</code> event may be received, without any
 *  <code>progress</code> events being dispatched.
 *  This can happen when the loaded content is a local file.</p>
 *
 *  @eventType flash.events.ProgressEvent.PROGRESS
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="progress", type="flash.events.ProgressEvent")]

/**
 *  Dispatched when a security error occurs.
 *  @see flash.events.SecurityErrorEvent
 *
 *  @eventType flash.events.SecurityErrorEvent.SECURITY_ERROR
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="securityError", type="flash.events.SecurityErrorEvent")]

//-----------------------------------
//  Styles
//-----------------------------------

/**
 *  When true, enables the 'loading' skin state.
 *  @default false
 * 
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 4.5
 */
[Style(name="enableLoadingState", type="Boolean", inherit="no")]

/**
 *  Style equivalent to BitmapImage's smoothingQuality property.When set to 
 *  <code>BitmapSmoothingQuality.BEST</code>, the image is resampled (if data
 *  is from a trusted source) to achieve a higher quality result.  
 *  If set to <code>BitmapSmoothingQuality.DEFAULT</code>, the default stage 
 *  quality for scaled bitmap fills is used.
 * 
 *  @default <code>BitmapSmoothingQuality.DEFAULT</code>
 * 
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 4.5
 */
[Style(name="smoothingQuality", type="String", inherit="no", enumeration="default,high")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("Image.png")]

/**
 *  The Image control is a skinnable component that provides a customizable
 *  loading state, chrome, and error state.  
 *  
 *  <p>The default skin provides a chromeless image skin with a generic progress 
 *  bar based preloader and broken image icon to reflect invalid content.</p>
 *
 *  <p>The Image control has the following default characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>Wide enough to hold the associated source content</td>
 *        </tr>
 *        <tr>
 *           <td>Minimum size</td>
 *           <td>0 pixels wide by 0 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>10000 pixels wide and 10000 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Default skin class</td>
 *           <td>spark.skins.spark.ImageSkin</td>
 *        </tr>
 *     </table>
 *
 *  @see spark.skins.spark.ImageSkin
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
public class Image extends SkinnableComponent
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    mx_internal static const CONTENT_LOADER_PROPERTY_FLAG:uint = 1 << 0;
    mx_internal static const CONTENT_LOADER_GROUPING_PROPERTY_FLAG:uint = 1 << 1;
    mx_internal static const FILL_MODE_PROPERTY_FLAG:uint = 1 << 2;
    mx_internal static const PRELIMINARY_WIDTH_PROPERTY_FLAG:uint = 1 << 3;
    mx_internal static const PRELIMINARY_HEIGHT_PROPERTY_FLAG:uint = 1 << 4;
    mx_internal static const HORIZONTAL_ALIGN_PROPERTY_FLAG:uint = 1 << 5;
    mx_internal static const SCALE_MODE_PROPERTY_FLAG:uint = 1 << 6;
    mx_internal static const SMOOTH_PROPERTY_FLAG:uint = 1 << 7;
    mx_internal static const SMOOTHING_QUALITY_PROPERTY_FLAG:uint = 1 << 8;
    mx_internal static const SOURCE_PROPERTY_FLAG:uint = 1 << 9;
    mx_internal static const SOURCE_WIDTH_PROPERTY_FLAG:uint = 1 << 10;
    mx_internal static const SOURCE_HEIGHT_PROPERTY_FLAG:uint = 1 << 11;
    mx_internal static const TRUSTED_SOURCE_PROPERTY_FLAG:uint = 1 << 12;
    mx_internal static const VERTICAL_ALIGN_PROPERTY_FLAG:uint = 1 << 13;
    
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
     *  @productversion Flex 4.5
     */
    public function Image()
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
    protected var _loading:Boolean = false;
    
    /**
     *  @private
     */
    protected var _invalid:Boolean = false;
    
    /**
     *  @private
     */
    mx_internal var imageDisplayProperties:Object = 
        {visible: true, scaleMode: BitmapScaleMode.LETTERBOX, trustedSource: true};
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  imageDisplay
    //----------------------------------
    
    [SkinPart(required="false")]
    
    /**
     *  A skin part that defines image content.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public var imageDisplay:BitmapImage;  
    
    //----------------------------------
    //  progressIndicator
    //----------------------------------
    
    [SkinPart(required="false")]
    
    /**
     *  An optional skin part that displays the current loading progress.
     *  As a convenience the progressIndicator value is automatically updated
     *  with the percentage complete while loading.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public var progressIndicator:Range;  
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  bytesLoaded
    //----------------------------------
    
    /**
     *  @copy mx.primitives.BitmapImage#bytesLoaded
     *  @default NaN
     */
    public function get bytesLoaded():Number 
    {
        return imageDisplay ? imageDisplay.bytesLoaded : NaN; 
    }
    
    //----------------------------------
    //  bytesTotal
    //----------------------------------
    
    /**
     *  @copy mx.primitives.BitmapImage#bytesTotal
     *  @default NaN
     */
    public function get bytesTotal():Number 
    {
        return imageDisplay ? imageDisplay.bytesTotal : NaN;
    }
    
    //----------------------------------
    //  contentLoader
    //----------------------------------
    
    /**
     *  @copy mx.primitives.BitmapImage#contentLoader
     *  @default null
     */
    public function get contentLoader():IContentLoader 
    {
        if (imageDisplay)
            return imageDisplay.contentLoader;
        else
            return imageDisplayProperties.contentLoader;
    }
    
    /**
     *  @private
     */
    public function set contentLoader(value:IContentLoader):void
    {
        if (imageDisplay)
        {
            imageDisplay.contentLoader = value;
            imageDisplayProperties = BitFlagUtil.update(imageDisplayProperties as uint, 
                CONTENT_LOADER_PROPERTY_FLAG, true);
        }
        else
            imageDisplayProperties.contentLoader = value;
    }
        
    //----------------------------------
    //  contentLoaderGrouping
    //----------------------------------
    
    /**
     *  @copy mx.primitives.BitmapImage#contentLoaderGrouping
     *  @default null
     */
    public function get contentLoaderGrouping():String 
    {
        if (imageDisplay)
            return imageDisplay.contentLoaderGrouping;
        else
            return imageDisplayProperties.contentLoaderGrouping;
    }
    
    /**
     *  @private
     */
    public function set contentLoaderGrouping(value:String):void
    {
        if (imageDisplay)
        {
            imageDisplay.contentLoaderGrouping = value;
            imageDisplayProperties = BitFlagUtil.update(imageDisplayProperties as uint, 
                CONTENT_LOADER_GROUPING_PROPERTY_FLAG, true);
        }
        else
            imageDisplayProperties.contentLoaderGrouping = value;
    }
    
    //----------------------------------
    //  fillMode
    //----------------------------------
    
    [Inspectable(category="General", enumeration="clip,repeat,scale", defaultValue="scale")]
    
    /**
     *  @copy mx.primitives.BitmapImage#fillMode
     *  @default <code>BitmapFillMode.SCALE</code>
     */
    public function get fillMode():String
    {
        if (imageDisplay)
            return imageDisplay.fillMode;
        else
            return imageDisplayProperties.fillMode;
    }
    
    /**
     *  @private
     */
    public function set fillMode(value:String):void
    {
        if (imageDisplay)
        {
            imageDisplay.fillMode = value;
            imageDisplayProperties = BitFlagUtil.update(imageDisplayProperties as uint, 
                FILL_MODE_PROPERTY_FLAG, true);
        }
        else
            imageDisplayProperties.fillMode = value;
    }

    //----------------------------------
    //  horizontalAlign
    //----------------------------------
    
    [Inspectable(category="General", enumeration="left,right,center", defaultValue="center")]
    
    /**
     *  @copy mx.primitives.BitmapImage#horizontalAlign
     *  @default <code>HorizontalAlign.CENTER</code>
     */
    public function get horizontalAlign():String
    {
        if (imageDisplay)
            return imageDisplay.horizontalAlign;
        else
            return imageDisplayProperties.horizontalAlign;
    }
    
    /**
     *  @private
     */
    public function set horizontalAlign(value:String):void
    {
        if (imageDisplay)
        {
            imageDisplay.horizontalAlign = value;
            imageDisplayProperties = BitFlagUtil.update(imageDisplayProperties as uint, 
                HORIZONTAL_ALIGN_PROPERTY_FLAG, value != null);
        }
        else
            imageDisplayProperties.horizontalAlign = value;
    }
    
    //----------------------------------
    //  preliminaryHeight
    //----------------------------------
    
    /**
     *  @copy mx.primitives.BitmapImage#preliminaryHeight
     *  @default NaN
     */
    public function get preliminaryHeight():Number
    {
        if (imageDisplay)
            return imageDisplay.preliminaryHeight;
        else
            return imageDisplayProperties.preliminaryHeight;
    }
    
    /**
     *  @private
     */
    public function set preliminaryHeight(value:Number):void
    {
        if (imageDisplay)
        {
            imageDisplay.preliminaryHeight = value;
            imageDisplayProperties = BitFlagUtil.update(imageDisplayProperties as uint, 
                PRELIMINARY_HEIGHT_PROPERTY_FLAG, true);
        }
        else
            imageDisplayProperties.preliminaryHeight = value;
    }
    
    //----------------------------------
    //  preliminaryWidth
    //----------------------------------
    
    /**
     *  @copy mx.primitives.BitmapImage#preliminaryWidth
     *  @default NaN
     */
    public function get preliminaryWidth():Number
    {
        if (imageDisplay)
            return imageDisplay.preliminaryWidth;
        else
            return imageDisplayProperties.preliminaryWidth;
    }
        
    /**
     *  @private
     */
    public function set preliminaryWidth(value:Number):void
    {
        if (imageDisplay)
        {
            imageDisplay.preliminaryWidth = value;
            imageDisplayProperties = BitFlagUtil.update(imageDisplayProperties as uint, 
                PRELIMINARY_WIDTH_PROPERTY_FLAG, true);
        }
        else
            imageDisplayProperties.preliminaryWidth = value;
    }
                
    //----------------------------------
    //  scaleMode
    //----------------------------------
    
    [Inspectable(category="General", enumeration="stretch,letterbox", defaultValue="letterbox")]
    
    /**
     *  @copy mx.primitives.BitmapImage#scaleMode
     *  @default <code>BitmapScaleMode.LETTERBOX</code>
     */
    public function get scaleMode():String
    {
        if (imageDisplay)
            return imageDisplay.scaleMode;
        else
            return imageDisplayProperties.scaleMode;
    }
    
    /**
     *  @private
     */
    public function set scaleMode(value:String):void
    {
        if (imageDisplay)
        {
            imageDisplay.scaleMode = value;
            imageDisplayProperties = BitFlagUtil.update(imageDisplayProperties as uint, 
                SCALE_MODE_PROPERTY_FLAG, true);
        }
        else
            imageDisplayProperties.scaleMode = value;
    }
       
    //----------------------------------
    //  smooth
    //----------------------------------
    
    /**
     *  @copy mx.primitives.BitmapImage#smooth
     */
    public function set smooth(value:Boolean):void
    {
        if (imageDisplay)
        {
            imageDisplay.smooth = value;
            imageDisplayProperties = BitFlagUtil.update(imageDisplayProperties as uint, 
                SMOOTH_PROPERTY_FLAG, true);
        }
        else
            imageDisplayProperties.smooth = value;
    }
    
    /**
     *  @private
     */
    public function get smooth():Boolean          
    {
        if (imageDisplay)
            return imageDisplay.smooth;
        else
            return imageDisplayProperties.smooth;
    }
    
    //----------------------------------
    //  source
    //----------------------------------
    
    /**
     *  @copy mx.primitives.BitmapImage#source
     */
    public function set source(value:Object):void
    {
        if (source != value)
            _invalid = false;
        
        if (imageDisplay)
        {
            imageDisplay.source = value;
            imageDisplayProperties = BitFlagUtil.update(imageDisplayProperties as uint, 
                SOURCE_PROPERTY_FLAG, value != null);
        }
        else
            imageDisplayProperties.source = value;
        
        invalidateSkinState();
    }
    
    /**
     *  @private
     */
    public function get source():Object          
    {
        if (imageDisplay)
            return imageDisplay.source;
        else
            return imageDisplayProperties.source;
    }
    
    //----------------------------------
    //  trustedSource
    //----------------------------------
        
    /**
     *  @copy mx.primitives.BitmapImage#trustedSource
     *  @default true
     */
    public function get trustedSource():Boolean          
    {
        if (imageDisplay)
            return imageDisplay.trustedSource;
        else
            return imageDisplayProperties.trustedSource;
    }
    
    //----------------------------------
    //  verticalAlign
    //----------------------------------
    
    [Inspectable(category="General", enumeration="top,bottom,middle", defaultValue="middle")]
    
    /**
     *  @copy mx.primitives.BitmapImage#verticalAlign
     *  @default <code>HorizontalAlign.MIDDLE</code>
     */
    public function get verticalAlign():String
    {
        if (imageDisplay)
            return imageDisplay.verticalAlign;
        else
            return imageDisplayProperties.verticalAlign;
    }
    
    /**
     *  @private
     */
    public function set verticalAlign(value:String):void
    {
        if (imageDisplay)
        {
            imageDisplay.verticalAlign = value;
            imageDisplayProperties = BitFlagUtil.update(imageDisplayProperties as uint, 
                VERTICAL_ALIGN_PROPERTY_FLAG, value != null);
        }
        else
            imageDisplayProperties.verticalAlign = value;
    }
        
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == imageDisplay)
        {
            imageDisplay.addEventListener(IOErrorEvent.IO_ERROR, imageDisplay_ioErrorHandler, false, 0, true);
            imageDisplay.addEventListener(ProgressEvent.PROGRESS, imageDisplay_progressHandler, false, 0, true);
            imageDisplay.addEventListener(Event.COMPLETE, imageDisplay_completeHandler, false, 0, true);
            imageDisplay.addEventListener(SecurityErrorEvent.SECURITY_ERROR, dispatchEvent, false, 0, true);
            imageDisplay.addEventListener(HTTPStatusEvent.HTTP_STATUS, dispatchEvent, false, 0, true);
            
            var newImageDisplayProperties:uint = 0;
            
            if (imageDisplayProperties.contentLoader !== undefined)
            {
                imageDisplay.contentLoader = imageDisplayProperties.contentLoader;
                newImageDisplayProperties = BitFlagUtil.update(newImageDisplayProperties, 
                    CONTENT_LOADER_PROPERTY_FLAG, true);
            }
            
            if (imageDisplayProperties.contentLoaderGrouping !== undefined)
            {
                imageDisplay.contentLoaderGrouping = imageDisplayProperties.contentLoaderGrouping;
                newImageDisplayProperties = BitFlagUtil.update(newImageDisplayProperties, 
                    CONTENT_LOADER_GROUPING_PROPERTY_FLAG, true);
            }
            
            if (imageDisplayProperties.fillMode !== undefined)
            {
                imageDisplay.fillMode = imageDisplayProperties.fillMode;
                newImageDisplayProperties = BitFlagUtil.update(newImageDisplayProperties, 
                    FILL_MODE_PROPERTY_FLAG, true);
            }
            
            if (imageDisplayProperties.preliminaryHeight !== undefined)
            {
                imageDisplay.preliminaryHeight = imageDisplayProperties.preliminaryHeight;
                newImageDisplayProperties = BitFlagUtil.update(newImageDisplayProperties, 
                    PRELIMINARY_HEIGHT_PROPERTY_FLAG, true);
            }
            
            if (imageDisplayProperties.preliminaryWidth !== undefined)
            {
                imageDisplay.preliminaryWidth = imageDisplayProperties.preliminaryWidth;
                newImageDisplayProperties = BitFlagUtil.update(newImageDisplayProperties, 
                    PRELIMINARY_WIDTH_PROPERTY_FLAG, true);
            }
            
            if (imageDisplayProperties.smooth !== undefined)
            {
                imageDisplay.smooth = imageDisplayProperties.smooth;
                newImageDisplayProperties = BitFlagUtil.update(newImageDisplayProperties, 
                    SMOOTH_PROPERTY_FLAG, true);
            }
            
            if (imageDisplayProperties.source !== undefined)
            {
                imageDisplay.source = imageDisplayProperties.source;
                newImageDisplayProperties = BitFlagUtil.update(newImageDisplayProperties, 
                    SOURCE_PROPERTY_FLAG, true);
            }
            
            if (imageDisplayProperties.smoothingQuality !== undefined)
            {
                imageDisplay.smoothingQuality = imageDisplayProperties.smoothingQuality;
                newImageDisplayProperties = BitFlagUtil.update(newImageDisplayProperties, 
                    SMOOTHING_QUALITY_PROPERTY_FLAG, true);
            }
            
            if (imageDisplayProperties.scaleMode !== undefined)
            {
                imageDisplay.scaleMode = imageDisplayProperties.scaleMode;
                newImageDisplayProperties = BitFlagUtil.update(newImageDisplayProperties, 
                    SCALE_MODE_PROPERTY_FLAG, true);
            }
                        
            if (imageDisplayProperties.verticalAlign !== undefined)
            {
                imageDisplay.verticalAlign = imageDisplayProperties.verticalAlign;
                newImageDisplayProperties = BitFlagUtil.update(newImageDisplayProperties, 
                    VERTICAL_ALIGN_PROPERTY_FLAG, true);
            }
            
            if (imageDisplayProperties.horizontalAlign !== undefined)
            {
                imageDisplay.horizontalAlign = imageDisplayProperties.horizontalAlign;
                newImageDisplayProperties = BitFlagUtil.update(newImageDisplayProperties, 
                    HORIZONTAL_ALIGN_PROPERTY_FLAG, true);
            }
            
            imageDisplayProperties = newImageDisplayProperties;
            
            // This mx_internal method is invoked now so that we initiate loading of our
            // source property prior to commitProperties. If we were to just wait
            // until commitProperties, the order that commitProperties is invoked
            // on multiple MXML Image instances does not match child order and as
            // such can be astonishing, especially when a queued loader is active.
            imageDisplay.validateSource();
        }
        else if (instance == progressIndicator)
        {
            if (_loading && progressIndicator)
                progressIndicator.value = percentComplete(imageDisplay.bytesLoaded, imageDisplay.bytesTotal);
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == imageDisplay)
        {
            imageDisplay.removeEventListener(IOErrorEvent.IO_ERROR, imageDisplay_ioErrorHandler);
            imageDisplay.removeEventListener(ProgressEvent.PROGRESS, imageDisplay_progressHandler);
            imageDisplay.removeEventListener(Event.COMPLETE, imageDisplay_completeHandler);
            imageDisplay.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, dispatchEvent);
            imageDisplay.removeEventListener(HTTPStatusEvent.HTTP_STATUS, dispatchEvent);
            
            var newImageDisplayProperties:Object = {};
            
            if (BitFlagUtil.isSet(imageDisplayProperties as uint, CONTENT_LOADER_PROPERTY_FLAG))
                newImageDisplayProperties.contentLoader = imageDisplay.contentLoader;
            
            if (BitFlagUtil.isSet(imageDisplayProperties as uint, CONTENT_LOADER_GROUPING_PROPERTY_FLAG))
                newImageDisplayProperties.contentLoaderGrouping = imageDisplay.contentLoaderGrouping;
                
            if (BitFlagUtil.isSet(imageDisplayProperties as uint, FILL_MODE_PROPERTY_FLAG))
                newImageDisplayProperties.fillMode = imageDisplay.fillMode;
            
            if (BitFlagUtil.isSet(imageDisplayProperties as uint, PRELIMINARY_HEIGHT_PROPERTY_FLAG))
                newImageDisplayProperties.preliminaryHeight = imageDisplay.preliminaryHeight;
                
            if (BitFlagUtil.isSet(imageDisplayProperties as uint, PRELIMINARY_WIDTH_PROPERTY_FLAG))
                newImageDisplayProperties.preliminaryWidth = imageDisplay.preliminaryWidth;
                
            if (BitFlagUtil.isSet(imageDisplayProperties as uint, SOURCE_PROPERTY_FLAG))
                newImageDisplayProperties.source = imageDisplay.source;
            
            if (BitFlagUtil.isSet(imageDisplayProperties as uint, SMOOTH_PROPERTY_FLAG))
                newImageDisplayProperties.smooth = imageDisplay.smooth;
            
            if (BitFlagUtil.isSet(imageDisplayProperties as uint, SMOOTHING_QUALITY_PROPERTY_FLAG))
                newImageDisplayProperties.smoothingQuality = imageDisplay.smoothingQuality;
            
            if (BitFlagUtil.isSet(imageDisplayProperties as uint, SCALE_MODE_PROPERTY_FLAG))
                newImageDisplayProperties.scaleMode = imageDisplay.scaleMode;
            
            if (BitFlagUtil.isSet(imageDisplayProperties as uint, TRUSTED_SOURCE_PROPERTY_FLAG))
                newImageDisplayProperties.trustedSource = imageDisplay.trustedSource;
            
            if (BitFlagUtil.isSet(imageDisplayProperties as uint, VERTICAL_ALIGN_PROPERTY_FLAG))
                newImageDisplayProperties.verticalAlign = imageDisplay.verticalAlign;
            
            if (BitFlagUtil.isSet(imageDisplayProperties as uint, HORIZONTAL_ALIGN_PROPERTY_FLAG))
                newImageDisplayProperties.horizontalAlign = imageDisplay.horizontalAlign;
            
            imageDisplayProperties = newImageDisplayProperties;
        }
    }
    
    /**
     *  @private
     */
    override protected function getCurrentSkinState():String
    {
        var enableLoadingState:Boolean = getStyle("enableLoadingState");
        
        if (_invalid)
            return "invalid";
        else if (!enabled)
            return "disabled";
        else if (_loading && enableLoadingState) 
            return "loading";
        else if (imageDisplay && imageDisplay.source)
            return "ready";
        else
            return "uninitialized";
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        var allStyles:Boolean = (styleProp == null || styleProp == "styleName");
        super.styleChanged(styleProp);
        
        if (allStyles || styleProp == "enableLoadingState")
        {
            invalidateSkinState();
        }
        
        if (allStyles || styleProp == "smoothingQuality")
        {
            smoothQuality = getStyle("smoothingQuality");
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Private smoothing quality setter used to push our smoothingQuality
     *  style value to our image display instance.
     */
    private function set smoothQuality(value:String):void
    {
        if (imageDisplay)
        {
            imageDisplay.smoothingQuality = value;
            imageDisplayProperties = BitFlagUtil.update(imageDisplayProperties as uint, 
                SMOOTHING_QUALITY_PROPERTY_FLAG, value != null);
        }
        else
            imageDisplayProperties.smoothingQuality = value;
    }
    
    /**
     *  @private
     */  
    private function percentComplete(bytesLoaded:Number, bytesTotal:Number):Number
    {
        var value:Number = Math.ceil((bytesLoaded / bytesTotal) * 100.0);
        return isNaN(value) ? 0 : value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function imageDisplay_ioErrorHandler(error:IOErrorEvent):void
    {
        _invalid = true;
        _loading = false;
        invalidateSkinState();
        
        if (hasEventListener(error.type))
            dispatchEvent(error);
    }
    
    /**
     *  @private
     */
    private function imageDisplay_progressHandler(event:ProgressEvent):void
    {
        if (!_loading)
            invalidateSkinState();

        if (progressIndicator)
            progressIndicator.value = percentComplete(event.bytesLoaded, event.bytesTotal);

        _loading = true;
        
        dispatchEvent(event);
    }
    
    /**
     *  @private
     */
    private function imageDisplay_completeHandler(event:Event):void
    {
        invalidateSkinState();
        _loading = false;
        dispatchEvent(event);
    }    
}
    
}
