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
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.utils.Dictionary;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.events.ElementExistenceEvent;
    
use namespace mx_internal;

/*
 *  TODO:
 * 
 * 
 * 
 *  ISSUES:
 *  - Support auto-generation of numberLabel values?
 *  - Should we support developer overriding the layout defined value in columnWidths? 
 *  If so, we need a seperate property or function like columnWidthsOverride
 * 
 */ 

/**
 *  SkinnableContainer with FormItem children. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5 
 */
public class Form extends SkinnableContainer
{
    
    public function Form()
    {
        super();
        addEventListener(FlexEvent.VALID, validHandler, true);
        addEventListener(FlexEvent.INVALID, invalidHandler, true);
        
        // Set these here instead of in the CSS type selector for Form
        // We want to hide the fact that the Form itself doesn't show
        // the error skin or error tip, but that its children do. 
        setStyle("showErrorSkin", false);
        setStyle("showErrorTip", false);
    }
    
    private var errorStateChanged:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    mx_internal var _invalidElements:Array = new Array();
    
    /**
     *  A sorted array of descendant elements that are in an INVALID state.
     *  The items in the array are Objects with the following properties:
     *  element:UIComponent - the invalid descendant element
     *  position:Vector.%lt;int%gt; - a Vector of integers representing the position
     *  of the element in the display list tree. This is used for sorting the array.  
     * 
     *  If a descendant is removed from the Form, the dictionary will not get 
     *  updated. 
     *     
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get invalidElements():Array
    {
        return _invalidElements;
    }
     
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  If an element is invalid, then we listen for changes to the errorString
     */
    private function errorStringChangedHandler(event:Event):void
    {
        var uicElt:UIComponent = event.target as UIComponent;

        // If errorString == "", then remove the target from the invalidElement dictionary
        if (uicElt && uicElt.errorString == "")
        {
            var elementIndex:int = findInvalidElementIndex(uicElt);
            if (elementIndex != -1)
                _invalidElements.splice(elementIndex, 1);
            
            uicElt.removeEventListener("errorStringChanged", errorStringChangedHandler);
            
            errorStateChanged = true;
            invalidateSkinState();
        }
    }
    
    /**
     *  @private
     *  If one of our descendants has just passed validation, then
     *  remove it from the invalidElements dictionary
     */
    private function validHandler(event:FlexEvent):void
    {
        if (event.isDefaultPrevented())
            return;
        
        var targ:UIComponent = event.target as UIComponent;
        
        if (targ)
        {            
            var elementIndex:int = findInvalidElementIndex(targ);
            if (elementIndex != -1)
                _invalidElements.splice(elementIndex, 1);
            
            targ.removeEventListener("errorStringChanged", errorStringChangedHandler);
        }    
        
        errorStateChanged = true;
        invalidateSkinState();
    }
    
    /**
     *  @private
     *  If one of our descendants has just failed validation, then
     *  add it to the invalidElements dictionary
     */
    private function invalidHandler(event:FlexEvent):void
    {
        if (event.isDefaultPrevented())
            return;
        
        var targ:UIComponent = event.target as UIComponent;
        
        if (targ)
        {         
            if (findInvalidElementIndex(targ) == -1)   
            {
                // Insert a new element into the array and re-sort
                var position:Vector.<int> = getElementNestedPosition(targ, contentGroup);
                var item:Object = {element:targ, position: position};
                
                _invalidElements.push(item);
                _invalidElements.sort(compareNestedPosition);

                // Listen for errorString == ""
                targ.addEventListener("errorStringChanged", errorStringChangedHandler);
            }
        }
        
        errorStateChanged = true;
        invalidateSkinState();
    }
    
    /**
     *  @private
     */
    override protected function getCurrentSkinState():String
    {
        var result:String = super.getCurrentSkinState();
        var key:Object;
        
        if (errorStateChanged)
        {
            errorStateChanged = false;
            var isEmpty:Boolean = true;
            var errMsg:String = "";
            
            for (var i:int = 0; i < invalidElements.length; i++)
            {
                isEmpty = false;
                if (errMsg != "")
                {
                    errMsg += "\n";
                }
                
                errMsg += UIComponent(invalidElements[i].element).errorString; 
            }
            
            // disabled state takes precedence over error state
            if (!isEmpty && enabled)
                result = "error";
            
            // Either set this to the concatenated string or empty string
            errorString = errMsg;
        }
        else if (enabled && invalidElements.length > 0)
        {
            result = "error";
        }
            
        return result;
    }
    
    /**
     *  @private
     *  Used to sort the element positions calculated using getElementNestedPosition. 
     *  
     *  @param item1 first element to compare
     *  @param item2 second element to compare
     *  @return -1 if item1 is less than item2, 0 if they are equal, 
     *  1 if item1 is greater than item2 
     */
    private function compareNestedPosition(item1:Object, item2:Object):int
    {
        var item1Pos:Vector.<int> = item1.position;
        var item2Pos:Vector.<int> = item2.position;
        
        var item1Depth:int = item1Pos.length;
        var item2Depth:int = item2Pos.length;
        
        var minDepth:int = Math.min(item1Depth, item2Depth);
        
        var currentDepth:int = 0;
        
        // Iterate through the elements of the position Vectors
        // Each element in the Vectors represents a level in the display list tree
        // We compare the child index of each element at each depth
        // If they are equal, then we move down to the next depth
        while (currentDepth < minDepth)
        {
            var item1Value:int = item1Pos[currentDepth];
            var item2Value:int = item2Pos[currentDepth];
            
            if (item1Value < item2Value)
                return -1;
            else if (item1Value > item2Value)
                return 1;
            else
            {
                currentDepth++;
            }
        } 
        
        // If all of the previous levels shared the same child index, then
        // compare the depth of the elements. A deeper element is always greater
        // if the elements share the same ancestors. 
        if (item1Depth < item2Depth)
            return -1;
        else if (item1Depth > item2Depth)
            return 1;
        else
            return 0;
    }
    
    /**
     *  @private
     *  Helper function to find a target in the invalidElementsArray
     */
    private function findInvalidElementIndex(element:UIComponent):int
    {
        for (var i:int = 0; i < invalidElements.length; i++)
        {
            if (element == invalidElements[i].element)
                return i;
        }
        
        return -1;
    }
    
    /**
     *  @private
     *  
     *  Calculates the position of the target relative to the subTreeRoot. Used to compare the position
     *  of two tree nodes. The return value is a Vector of ints. Each int represents the childIndex of the 
     *  target's ancestor at a particular depth. The highest depths are at the beginning of the Vector
     * 
     *  @param target Return the position of this displayObject 
     *  @param subTreeRoot The displayObject to use as the root of the subTree
     *  
     *  @return a Vector of ints representing the position of the target in the display list tree
     * 
     */
    private function getElementNestedPosition(target:DisplayObject, subTreeRoot:DisplayObjectContainer = undefined):Vector.<int>
    {
        var p:DisplayObjectContainer = target.parent;
        var current:DisplayObject = target;
        var pos:Vector.<int> = new Vector.<int>();
        
        if (p == null || current == subTreeRoot)
        {
            pos.push(0);
        }
        else
        {
            while (p != null && current != subTreeRoot)
            {
                pos.splice(0, 0, p.getChildIndex(current));
                current = p;
                p = p.parent;
            }
        
        }
        return pos;
    }
    
    
}
}
