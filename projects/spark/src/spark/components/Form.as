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
import flash.utils.Dictionary;

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
        
        showInAutomationHierarchy = false;
    }
    
    private var errorStateChanged:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    
    mx_internal var _invalidElements:Dictionary = new Dictionary(true);
    
    /**
     *  A dictionary of descendant elements that are in an INVALID state. The 
     *  dictionary keys are the invalid elements themselves. The dictionary
     *  value is the errorString of that invalid element. 
     * 
     *  If a descendant is removed from the Form, the dictionary will not get 
     *  updated. 
     *     
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get invalidElements():Dictionary
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
     *  If one of our descendants has just passed validation, then
     *  remove it from the invalidElements dictionary
     */
    private function validHandler(event:FlexEvent):void
    {
        if (event.isDefaultPrevented())
            return;
        
        var targ:UIComponent = event.target as UIComponent;
        if (invalidElements[targ] != undefined)
            delete _invalidElements[targ];
        
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
            _invalidElements[targ] = targ.errorString;                    
        
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
            
            // TODO (jszeto) Figure out how to do the proper ordering 
            for (key in invalidElements)
            {
                isEmpty = false;
                if (errMsg != "")
                {
                    errMsg += "\n";
                }
                
                errMsg += UIComponent(key).errorString; 
            }
            
            // disabled state takes precedence over error state
            if (!isEmpty && enabled)
                result = "error";
            
            // Either set this to the concatenated string or empty string
            errorString = errMsg;
        }
        else if (enabled)
        {
            for (key in invalidElements)
            {
                result = "error";
                break;
            }
        }
            
        return result;
    }
}
}
