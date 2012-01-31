////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package mx.graphics
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.Transform;

import mx.core.IInvalidating;
import mx.core.IVisualElement;

/**
 *  The IGraphicElement interface is implemented by all child tags of Graphic and Group.
 */
public interface IGraphicElement extends IVisualElement, IInvalidating
{
 
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  Specifies the level of transparency of the graphic element.
     * 
     *  @see flash.display.DisplayObject#Alpha
     */
    function get alpha():Number;
    function set alpha(value:Number):void;

    /**
     *  Specifies the blend mode.
     * 
     *  @see flash.display.DisplayObject#BlendMode
     */
    function get blendMode():String;
    function set blendMode(value:String):void;
        
    /**
     *  The array of IBitmapFilter filters applied to the element.
     */
    function get filters():Array;
    function set filters(value:Array):void;
    
    /**
     *  Controls how the mask performs masking on the element. 
     *  Possible values are MaskType.CLIP and MaskType.ALPHA
     *  A value of MaskType.CLIP means that the mask either displays the pixel
     *  or doesn't. Strokes and bitmap filters are not used. 
     *  A value of MaskType.ALPHA means that the mask respects opacity and
     *  will use the strokes and bitmap filters of the mask.  
     */
    function get maskType():String;
    function set maskType(value:String):void;
    
    /**
     * The mask applied to the element.
     */
    function set mask(value:DisplayObject):void;
    function get mask():DisplayObject;
    
    /**
     *  An object with properties pertaining to an element's matrix, 
     *  color transform, and pixel bounds. 
     */
    function get transform():Transform;
    function set transform(value:Transform):void; 
    
    /**
     *  The DisplayObject where the GraphicElement will be drawn.
     *  This property is automatically assigned by the parent Group of this element.
     */
    function get displayObject():DisplayObject;
    function set displayObject(value:DisplayObject):void;
    
    /**
     *  <code>true</code> if the graphic element needs its own unique display object to render into.
     *  In general, you will not set this property, although if you extend the GraphicElement class, you
     *  might override the setter.
     */
    function get needsDisplayObject():Boolean;
    
    /**
     *  <code>true</code> if the another graphic element can use this display object to render into.
     *  In general, you will not set this property, although if you extend the GraphicElement class, you
     *  might override the setter.
     */
    function get nextSiblingNeedsDisplayObject():Boolean;
    
    /**
     *  The DisplayObject where the GraphicElement will be drawn.  This DisplayObject is shared
     *  between other GraphicElements.  This property is automatically assigned by the 
     *  parent Group of this element.
     */
    function get sharedDisplayObject():DisplayObject;
    function set sharedDisplayObject(value:DisplayObject):void;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * @copy mx.managers.ILayoutManagerClient#validateProperties
     */
    function validateProperties():void;
    
    /**
     * @copy mx.managers.ILayoutManagerClient#validateSize
     */
    function validateSize(recursive:Boolean = false):void;
    
    /**
     * @copy mx.managers.ILayoutManagerClient#validateDisplayList
     */
    function validateDisplayList():void;
    
    /**
     *  Called by Flex when a graphic element object is added to or removed from a parent.
     *  Developers typically never need to call this method.
     *
     *  @param p The parent of this graphic element object.
     */
    function parentChanged(p:DisplayObjectContainer):void;
    
    /**
     *  Creates a new DisplayObject where the GraphicElement is drawn, 
     *  if one does not already exist.  This methods also assigns the graphic element's 
     *  <code>displayObject</code> property to the newly created DisplayObject.
     * 
     *  @return The display object created
     */
    function createDisplayObject():DisplayObject;
    
    /**
     *  This method is called to let the GraphicElement know that the 
     *  display object is no longer needed.  This does not remove the 
     *  display object from the display list.
     * 
     *  @return The display object that this graphic element owned (null 
     *  if it didn't own one).
     */
    function destroyDisplayObject():DisplayObject;
}
}
