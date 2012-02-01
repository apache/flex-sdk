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

package spark.skins.spark
{

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.IBitmapDrawable;
import flash.events.Event;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.supportClasses.Skin;
import spark.components.supportClasses.SkinnableComponent;
import spark.core.DisplayObjectSharingMode;
import spark.core.IGraphicElement;

use namespace mx_internal;

/**
 *  Focus skins for Spark components.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class FocusSkin extends UIComponent
{
    include "../../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    // FIXME (gruehle): Make this a style property?
    private const FOCUS_THICKNESS:int = 2;    
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    private static var colorTransform:ColorTransform = new ColorTransform(
                1.01, 1.01, 1.01, 2);
    private static var glowFilter:GlowFilter = new GlowFilter(
                0x70B2EE, 0.85, 5, 5, 3, 1, false, true);
    private static var rect:Rectangle = new Rectangle();;
    private static var filterPt:Point = new Point();
                 
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     * Constructor.
     */
    public function FocusSkin()
    {
        super();
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
     *  @private
     */
    private var _focusObject:SkinnableComponent;
    
    /**
     *  Object to draw focus around.  If null, uses focusManager.getFocus();
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get focusObject():SkinnableComponent
    {
        return _focusObject;
    }
    
    public function set focusObject(value:SkinnableComponent):void
    {
        _focusObject = value;
        
        // Add an "updateComplete" listener to the skin so we can redraw
        // whenever the skin is drawn.
        if (_focusObject.skin)
            _focusObject.skin.addEventListener(FlexEvent.UPDATE_COMPLETE, 
                    skin_updateCompleteHandler, false, 0, true);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {   
        // Grab a bitmap of the focused object
        if (!focusObject && focusManager)
            focusObject = focusManager.getFocus() as SkinnableComponent;
        
        // if we weren't handed a focusObject or we had no focusManager to 
        // give us one, then exit early
        if (!focusObject)
           return;
            
        var bitmapData:BitmapData = new BitmapData(
                    focusObject.width + (FOCUS_THICKNESS * 2), 
                    focusObject.height + (FOCUS_THICKNESS * 2), true, 0);
        var m:Matrix = new Matrix();
        
        // If the focus object already has a focus skin, make sure it is hidden.
        if (focusObject.focusObj)
            focusObject.focusObj.visible = false;
       
        // Ensure no 3D transforms apply, as this skews our snapshot bitmap.
        var transform3D:Matrix3D = null;
        if (focusObject.$transform.matrix3D)
        {
            transform3D = focusObject.$transform.matrix3D;  
            focusObject.$transform.matrix3D = null;
        }
        
		/* Some skins may have elements inside of them that they don't 
		want considered for the focus skins.  if they list any sub elements
		using the focusSkinExclusions property, we need to first set them to
		invisible before we render our bitmap
		*/
		var skin:Skin = focusObject.skin;
		var exclusions:Array = skin.focusSkinExclusions;
		var exclusionCount:Number = (exclusions == null)? 0:exclusions.length;
		/* we'll store off the previous visibility of the exclusions so we
		can restore them when we're done
		*/
		var exclusionVisibilityValues:Array = [];
		var needRedraw:Boolean = false;
		for(var i:int = 0;i<exclusionCount;i++)		
		{
			var ex:Object = exclusions[i];
			/* we're going to go under the covers here to try and modify visibility with the least
			amount of disruption to the component.  For UIComponents, we go to Sprite's visibile property;
			*/
			if(ex is UIComponent)
			{
				exclusionVisibilityValues[i] = (ex as UIComponent).$visible; 
				(ex as UIComponent).$visible = false;
			} 
			else if (ex is DisplayObject)
			{
				exclusionVisibilityValues[i] = (ex as UIComponent).visible; 
				(ex as UIComponent).visible = false;
			}
			else if (ex is IGraphicElement) 
			{
				/* if we're lucky, the IGE has its own DisplayObject, and we can just trip its visibility.
				If not, we're going to have to set it to invisible, and force a redraw of the whole component */
				var ge:IGraphicElement = ex as IGraphicElement;
				if(ge.displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
				{
					exclusionVisibilityValues[i] = ge.displayObject.visible;
					ge.displayObject.visible = false;
				}
				else
				{
					exclusionVisibilityValues[i] = ge.visible;
					ge.visible = false;
					needRedraw = true;
				}
			}
			
		}
		/* if we excluded an IGE without its own DO, we need to update the component before grabbing the bitmap */
		if(needRedraw)
			skin.validateNow();
		
        m.tx = FOCUS_THICKNESS;
        m.ty = FOCUS_THICKNESS;
        bitmapData.draw(focusObject as IBitmapDrawable, m);
        
        // Show the focus skin, if needed.
        if (focusObject.focusObj)
            focusObject.focusObj.visible = true;
        
		/* now go through and reverse our visibility modifications.  For any excluded component
		that we made invisible, set it back to its previous value
		*/
		needRedraw = false;
		for(i=0;i<exclusionCount;i++)		
		{
			ex = exclusions[i];
			if(ex is UIComponent)
			{
				(ex as UIComponent).$visible = exclusionVisibilityValues[i];
			} 
			else if (ex is DisplayObject)
			{
				(ex as UIComponent).visible = exclusionVisibilityValues[i];
			}
			else if (ex is IGraphicElement) 
			{
				ge  = ex as IGraphicElement;
				if(ge.displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
				{
					ge.displayObject.visible = exclusionVisibilityValues[i];
				}
				else
				{
					/* note that this is using a public API of GraphicElements that will, in fact,
					trigger another update pass on the graphic element
					*/
					ge.visible = exclusionVisibilityValues[i];					
				}
			}
			
		}
		
        // Special case for Scroller - fill the entire rect.
        // FIXME (gruehle): Figure out a better solution.
        if (weakIsCheck(focusObject, "spark.components::Scroller"))
        {
            rect.x = rect.y = FOCUS_THICKNESS;
            rect.width = focusObject.width;
            rect.height = focusObject.height;
            bitmapData.fillRect(rect, 0xFFFFFFFF);
        }
        
        // Transform the color to remove the transparency. The GlowFilter has the "knockout" property
        // set to true, which removes this image from the final display, leaving only the outer glow.
        rect.x = rect.y = FOCUS_THICKNESS;
        rect.width = focusObject.width;
        rect.height = focusObject.height;
        bitmapData.colorTransform(rect, colorTransform);
        
        // Apply the glow filter
        rect.x = rect.y = 0;
        rect.width = bitmapData.width;
        rect.height = bitmapData.height;
        // If the focusObject has an errorString, use "errorColor" instead of "focusColor" 
        if (focusObject.errorString != null && focusObject.errorString != "") 
        {
            glowFilter.color = focusObject.getStyle("errorColor");
        }
        else
        {
            glowFilter.color = focusObject.getStyle("focusColor");
        }
        bitmapData.applyFilter(bitmapData, rect, filterPt, glowFilter); 
               
        if (!bitmap)
        {
            bitmap = new Bitmap();
            addChild(bitmap);
            bitmap.x = bitmap.y = -FOCUS_THICKNESS;
        }
        
        bitmap.bitmapData = bitmapData;
        
        // Restore original 3D matrix if applicable.
        if (transform3D)
            focusObject.$transform.matrix3D = transform3D;
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
    
    private function skin_updateCompleteHandler(event:Event):void
    {
        // We need to redraw whenever the focus object skin redraws.
        invalidateDisplayList();
    }
}
}        
