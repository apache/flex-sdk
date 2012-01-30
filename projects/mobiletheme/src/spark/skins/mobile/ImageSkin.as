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

package spark.skins.mobile
{
import flash.display.DisplayObject;
import flash.display.Graphics;

import mx.core.DPIClassification;

import spark.components.BusyIndicator;
import spark.components.Group;
import spark.components.Image;
import spark.primitives.BitmapImage;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile160.assets.ImageInvalid;
import spark.skins.mobile240.assets.ImageInvalid;
import spark.skins.mobile320.assets.ImageInvalid;

/**
 *  ActionScript-based skin for the Image component in mobile applications.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class ImageSkin extends MobileSkin
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
     * 
     */
	public function ImageSkin()
	{
		super();
        
        // set the right assets and dimensions to use based on the screen density
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                imageInvalidClass = spark.skins.mobile320.assets.ImageInvalid;
                break;              
            }
            case DPIClassification.DPI_240:
            {
                imageInvalidClass = spark.skins.mobile240.assets.ImageInvalid;
                break;
            }
            default:
            {
                // default DPI_160
                imageInvalidClass = spark.skins.mobile160.assets.ImageInvalid;
                break;
            }
                
        }
	}
	
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	
    /** 
     * @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
	public var hostComponent:Image;
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts 
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Image imageDisplay skin part that contains the image content
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    public var imageDisplay:BitmapImage;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  Container of the BitmapImage to be displayed
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected var imageHolder:Group;

    /**
     *  The currently displayed asset: either the intended image,
     *  the loading indicator, the "invalid image" icon, or null.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    private var currentImage:DisplayObject;

    /**
     *  Specifies the FXG class to use in the "invalid" image state
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var imageInvalidClass:Class;
    
    /**
     *  Specifies the DisplayObject to use in the "invalid" image state
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    private var imageInvalid:DisplayObject;
    
    /**
     *  Displayed if the "enableLoadingState" style is true
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var loadingIndicator:BusyIndicator = null;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
	
    /**
     *  @private 
     */
    override protected function commitCurrentState():void
    {
        var alphaValue:Number = 1.0;
        
        if (currentState == "uninitialized")
        {
            if (imageInvalid)
            {
                removeChild(imageInvalid);
                imageInvalid = null;
            }
            
            if (loadingIndicator)
            {
                removeChild(loadingIndicator);
                loadingIndicator = null;
            }
            
            currentImage = null;
        }
        else if (currentState == "loading")
        {            
            // turn off any other images
            if (imageInvalid)
            {
                removeChild(imageInvalid);
                imageInvalid = null;
            }
            
            if (!loadingIndicator)
            {
                loadingIndicator = new BusyIndicator();
                addChild(loadingIndicator);
            }            
            
            currentImage = loadingIndicator;
        }
        else if (currentState == "ready")
        {
            if (imageInvalid)
            {
                removeChild(imageInvalid);
                imageInvalid = null;
            }

            if (loadingIndicator)
            {
                removeChild(loadingIndicator);
                loadingIndicator = null;
            }
            
            currentImage = imageHolder;
        }
        else if (currentState == "invalid")
        {
            if (loadingIndicator)
            {
                removeChild(loadingIndicator);
                loadingIndicator = null;
            }

            if (!imageInvalid)
            {
                imageInvalid = new imageInvalidClass();
                addChild(imageInvalid);
            }

            currentImage = imageInvalid;
        }
        else if (currentState == "disabled")
        {
            alphaValue = 0.5;
            
            // remove any loading or invalid images
            if (imageInvalid)
            {
                removeChild(imageInvalid);
                imageInvalid = null;
            }

            if (loadingIndicator)
            {
                removeChild(loadingIndicator);
                loadingIndicator = null;
            }
            
            currentImage = imageHolder;
        }
        else
        {
            // unexpected state; ignore
        }
        
        alpha = alphaValue;
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  @private 
     */ 
	override protected function createChildren():void
    {
        // create container for holding the currently displayed image
        imageHolder = new Group();
        addChild(imageHolder);
        
        // required skin part; the Image component will set this directly
        imageDisplay = new BitmapImage();
        imageDisplay.left = 0;
        imageDisplay.right = 0;
        imageDisplay.top = 0;
        imageDisplay.bottom = 0;
        
        imageHolder.addElement(imageDisplay);
	}
     
    /**
     *  @private 
     */ 
	override protected function measure():void
	{
        super.measure();
        
        if (currentImage)
        {
            measuredHeight = getElementPreferredHeight(currentImage);
            measuredWidth = getElementPreferredWidth(currentImage);
        }
    }
	
    /**
     *  @private 
     */ 
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        var preferredWidth:Number;
        var preferredHeight:Number;
        
        if (loadingIndicator && currentImage == loadingIndicator)
        {
            preferredWidth = loadingIndicator.getPreferredBoundsWidth();
            preferredHeight = loadingIndicator.getPreferredBoundsHeight();
            
            // loading indicator will be no bigger than its preferred width/height
            setElementSize(loadingIndicator,
                Math.min(unscaledWidth, preferredWidth),
                Math.min(unscaledHeight, preferredHeight));
            
            // center the loading indicator
            setElementPosition(loadingIndicator, 
                Math.max((unscaledWidth - preferredWidth) / 2, 0), 
                Math.max((unscaledHeight - preferredHeight) / 2, 0));
        }
        else if (imageInvalid && currentImage == imageInvalid)
        {
            preferredWidth = getElementPreferredWidth(imageInvalid);
            preferredHeight = getElementPreferredHeight(imageInvalid);
            
            // icon shrinks with any explicit image size
            setElementSize(imageInvalid,
                Math.min(preferredWidth, unscaledWidth),
                Math.min(preferredHeight, unscaledHeight));

            // center the invalid image icon
            setElementPosition(imageInvalid, 
                Math.max((unscaledWidth - preferredWidth) / 2, 0), 
                Math.max((unscaledHeight - preferredHeight) / 2, 0));
        }
        else if (currentImage == imageHolder)
            setElementSize(imageHolder, unscaledWidth, unscaledHeight);
        
        // set the background rect if specified
        var g:Graphics = graphics;
        g.clear();
        if (!isNaN(getStyle("backgroundColor")))
        {
            g.beginFill(getStyle("backgroundColor"), getStyle("backgroundAlpha"));
            g.drawRect(0, 0, unscaledWidth, unscaledHeight);
        }
	}
}
}