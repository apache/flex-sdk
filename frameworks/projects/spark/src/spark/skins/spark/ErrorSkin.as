////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.default
{

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.IBitmapDrawable;
import flash.events.Event;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import spark.components.supportClasses.SkinnableComponent;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;

use namespace mx_internal;

/**
 *  The ErrorSkin class defines the error skin for Spark components.
 *  Flex displays the error skin when a validation error occurs.
 *
 *  @see mx.validators.Validator
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ErrorSkin extends UIComponent
{
    include "../../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    // TODO: Make this a style property?
    private const ERROR_THICKNESS:int = 1;    
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    private static var colorTransform:ColorTransform = new ColorTransform(
                1.01, 1.01, 1.01, 2);
    private static var glowFilter:GlowFilter = new GlowFilter(
                0xFF0000, 0.85, 2, 2, 3, 1, false, true);
    private static var rect:Rectangle = new Rectangle();;
    private static var filterPt:Point = new Point();
                 
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
    public function ErrorSkin()
    {
        super();
        
        mouseEnabled = false;
        mouseChildren = false;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Bitmap capture of the focused component. This bitmap includes a glow
     *  filter that shows the focus glow.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private var bitmap:Bitmap;

    /**
     * @private
     */
    private var _errorObject:SkinnableComponent;
    
    /**
     *  The Spark component to draw the error skin around.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get errorObject():SkinnableComponent
    {
        return _errorObject;
    }
    
    public function set errorObject(value:SkinnableComponent):void
    {
        _errorObject = value;
        
        // Add an "updateComplete" listener to the skin so we can redraw
        // whenever the skin is drawn.
        if (_errorObject.skin)
            _errorObject.skin.addEventListener(FlexEvent.UPDATE_COMPLETE, 
                    skin_updateCompleteHandler, false, 0, true);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * @inheritDoc
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // Early exit if we don't have an error object
        if (!errorObject)
            return;
            
        // Grab a bitmap of the error object
        var bitmapData:BitmapData = new BitmapData(
                    errorObject.width + (ERROR_THICKNESS * 2), 
                    errorObject.height + (ERROR_THICKNESS * 2), true, 0);
        var m:Matrix = new Matrix();
        
        // If the error object has a focus skin, make sure it is hidden.
        if (errorObject.focusObj)
            errorObject.focusObj.visible = false;
       
        // Temporary solution for error drawing on CheckBox and RadioButton components.
        // Hide the label before drawing the focus. 
        // TODO: Figure out a better solution.
        var hidLabelElement:Boolean = false;
        if ((weakIsCheck(errorObject, "spark.components::CheckBox") ||
             weakIsCheck(errorObject, "spark.components::RadioButton"))
             && Object(errorObject).labelElement)
        {
            Object(errorObject).labelElement.displayObject.visible = false;
            hidLabelElement = true;
        }
            
        m.tx = ERROR_THICKNESS;
        m.ty = ERROR_THICKNESS;
        bitmapData.draw(errorObject as IBitmapDrawable, m);
       
        // Show the focus skin, if needed.
        if (errorObject.focusObj)
            errorObject.focusObj.visible = true;
        
        // Show the label, if needed.
        if (hidLabelElement)
            Object(errorObject).labelElement.displayObject.visible = true;
        
        // Special case for Scroller - fill the entire rect.
        // TODO: Figure out a better solution.
        if (weakIsCheck(errorObject, "spark.components::Scroller"))
        {
            rect.x = rect.y = ERROR_THICKNESS;
            rect.width = errorObject.width;
            rect.height = errorObject.height;
            bitmapData.fillRect(rect, 0xFFFFFFFF);
        }
        
        // Transform the color to remove the transparency. The GlowFilter has the "knockout" property
        // set to true, which removes this image from the final display, leaving only the outer glow.
        rect.x = rect.y = ERROR_THICKNESS;
        rect.width = errorObject.width;
        rect.height = errorObject.height;
        bitmapData.colorTransform(rect, colorTransform);
        
        // Apply the glow filter
        rect.x = rect.y = 0;
        rect.width = bitmapData.width;
        rect.height = bitmapData.height;
        glowFilter.color = errorObject.getStyle("errorColor");
        bitmapData.applyFilter(bitmapData, rect, filterPt, glowFilter); 
               
        if (!bitmap)
        {
            bitmap = new Bitmap();
            addChild(bitmap);
        }
        
        bitmap.bitmapData = bitmapData;
        
        // Set the size of the bitmap to be the size of the component. This has the effect
        // of overlaying the error skin on the border of the component.
        bitmap.width = errorObject.width;
        bitmap.height = errorObject.height;
    }
    
    private static var classDefCache:Object = {};
    
    /**
     *  @private
     */
    private function weakIsCheck(obj:Object, className:String):Boolean
    {
        if (!(className in classDefCache))
        {            
            var classObj:Class = Class(systemManager.getDefinitionByName(className));
            
            classDefCache[className] = classObj;
        }
        
        if (!classDefCache[className])
            return false;
            
        return obj is classDefCache[className];
    }
    
    /**
     *  @private
     */
    private function skin_updateCompleteHandler(event:Event):void
    {
        // Whenever the skin is updated, we need to redraw
        invalidateDisplayList();
    }
}
}        
