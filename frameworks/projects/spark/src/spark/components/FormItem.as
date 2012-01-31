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

import mx.core.IDeferredInstance;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.supportClasses.TextBase;
import spark.events.ElementExistenceEvent;

use namespace mx_internal;

/*
 *  TODO
 *  - Fix bug when setting errorString = "" 
 *  - Review applyErrorText API
 */ 

/**
 *  Specifies the image source to use for the error indicator. 
 *
 *  The default value is "assets/RequiredIndicator.png"
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
[Style(name="requiredIndicatorSource", type="Class", inherit="no")]

/**
 *  Specifies the image source to use for the required indicator. 
 *
 *  The default value is "assets/ErrorIndicator.png"
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
[Style(name="errorIndicatorSource", type="Class", inherit="no")]


/**
 *  SkinnableContainer with content and multiple properties. The FormItem's children 
 *  are the content and are placed in the contentGroup skin part. The FormItem 
 *  container defines a number of skin parts, including labelDisplay, 
 *  sequenceLabelDisplay, and helpContentGroup. The content of these skin parts are 
 *  specified in order by the label, sequenceLabel and helpContent properties.     
 */
public class FormItem extends SkinnableContainer
{
    
    public function FormItem()
    {
        super();
        // Set these here instead of in the CSS type selector for Form
        // We want to hide the fact that the Form itself doesn't show
        // the error skin or error tip, but that its children do. 
        setStyle("showErrorSkin", false);
        setStyle("showErrorTip", false);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    /**
     *   A reference to the visual element that displays this FormItem's label.
     */
    [SkinPart(required="false")]
    public var labelDisplay:TextBase;
            
    /**
     *  A reference to the visual element that displays the FormItem's sequenceLabel.
     */
    [SkinPart(required="false")]
    public var sequenceLabelDisplay:TextBase;
    
    /**
     *  A reference to the Group that contains the FormItem's helpContentGroup.
     */
    [SkinPart(required="false")]
    public var helpContentGroup:Group;
    
    /**
     *  A reference to the visual element that display the FormItem's error strings.
     */
    [SkinPart(required="false")]
    public var errorTextDisplay:TextBase;
    
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------
    
    mx_internal var _elementErrorStrings:Vector.<String> = new Vector.<String>;
    
    /**
     *  Each vector item contains the error string from a content element. 
     *  If none of the content elements are invalid, then the vector will 
     *  be empty. 
     */     
    [Bindable(event="elementErrorStringsChanged")]
    
    public function get elementErrorStrings():Vector.<String>
    {
        return _elementErrorStrings;
    }
     
    //----------------------------------
    //  helpContent
    //----------------------------------
    private var _helpContent:IDeferredInstance;
    private var helpContentChanged:Boolean = false;
    
    [Bindable("labelChanged")]
    [Inspectable(category="General", defaultValue="")]
    
    /**
     *  A factory object that creates the mxmlContent for the
     *  <code>helpContentGroup</code> skin part. 
     * 
     *  @default undefined
     */
    public function set helpContent(value:IDeferredInstance):void
    {
        _helpContent = value;
        helpContentChanged = true;
        invalidateProperties();
    }
    
    /**
     *  @private
     */
    public function get helpContent():IDeferredInstance
    {
        return _helpContent;
    }
    
    
    //----------------------------------
    //  label
    //----------------------------------
    
    private var _label:String = "";
    
    [Bindable("labelChanged")]
    [Inspectable(category="General", defaultValue="")]
    
    /**
     *  Text that names the form content. For example, a FormItem to 
     *  select a state might have a form label of "State"  
     * 
     *  @default ""
     */
    public function get label():String
    {
        return _label;
    }
    
    /**
     *  @private
     */
    public function set label(value:String):void
    {
        if (_label == value)
            return;
        
        _label = value;
        
        if (labelDisplay)
            labelDisplay.text = label;
        dispatchEvent(new Event("labelChanged"));
    }
            
    //----------------------------------
    //  required
    //----------------------------------
    
    private var _required:Boolean = false;
    
    [Bindable("requiredChanged")]
    [Inspectable(category="General", defaultValue="false")]
    
    /**
     *  If <code>true</code>, puts the FormItem skin into the
     *  <code>required</code> state. By default, this displays 
     *  an indicator that the FormItem children require user input.
     *  If <code>false</code>, indicator is not displayed.
     *
     *  <p>This property controls skin's state only.
     *  You must attach a validator to the children
     *  if you require input validation.</p>
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get required():Boolean
    {
        return _required;
    }
    
    /**
     *  @private
     */
    public function set required(value:Boolean):void
    {
        if (value == _required)
            return;
        
        _required = value;
        invalidateSkinState();
    }
    
    //----------------------------------
    //  sequenceLabel
    //----------------------------------
    
    private var _sequenceLabel:String = "";
    
    [Bindable("sequenceLabelChanged")]
    [Inspectable(category="General", defaultValue="")]
    
    /**
     *  The number of the form item if the form creates a 
     *  numbered list out of the form items  
     * 
     *  @default ""
     */
    public function get sequenceLabel():String
    {
        return _sequenceLabel;
    }
    
    /**
     *  @private
     */
    public function set sequenceLabel(value:String):void
    {
        if (_sequenceLabel == value)
            return;
        
        _sequenceLabel = value;
        
        if (sequenceLabelDisplay)
            sequenceLabelDisplay.text = sequenceLabel;
        dispatchEvent(new Event("sequenceLabelChanged"));
        
        invalidateProperties();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  baselinePosition
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        return getBaselinePositionForPart(labelDisplay);
    }     
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
 
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        createHelpContent();
    }
    
    /**
     *  @private
     */
    override protected function getCurrentSkinState():String
    {
        if (required)
        {
            if (!enabled)
                return "requiredAndDisabled";
            else if (elementErrorStrings.length > 0)
                return "requiredAndError";
            else
                return "required";
        }
        else
        {
            if (!enabled)
                return "disabled";
            else if (elementErrorStrings.length > 0)
                return "error";
            else
                return "normal";       
        }
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object) : void
    {
        super.partAdded(partName, instance);
        
        if (instance == labelDisplay)
            labelDisplay.text = label;
        else if (instance == sequenceLabelDisplay)
            sequenceLabelDisplay.text = sequenceLabel;
        else if (instance == errorTextDisplay)
            updateErrorTextDisplay();
        else if (instance == helpContentGroup)
            createHelpContent();
        else if (instance == contentGroup)
        {
            contentGroup.addEventListener(FlexEvent.VALID, contentGroup_validHandler, true);
            contentGroup.addEventListener(FlexEvent.INVALID, contentGroup_invalidHandler, true);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function updateErrorString():void
    {
        var uicElt:UIComponent;
        _elementErrorStrings = new Vector.<String>;
        
        for (var i:int = 0; i < numElements; i++)
        {
            uicElt = getElementAt(i) as UIComponent;
            
            if (uicElt)
            {
                if (uicElt.errorString != "")
                {
                    _elementErrorStrings.push(uicElt.errorString);
                }
            }
        }
        
        invalidateSkinState();
        
        updateErrorTextDisplay();
        dispatchEvent(new Event("elementErrorStringsChanged"));
    }
    
    /**
     *  Converts elementErrorStrings into a string and assigns
     *  that string to the errorTextDisplay skinPart. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    protected function updateErrorTextDisplay():void
    {
        var msg:String = "";
        for (var i:int=0; i < elementErrorStrings.length; i++)
        {
            if (msg != "")
                msg += "\n";
            msg += elementErrorStrings[i];
        }
        
        if (errorTextDisplay)
            errorTextDisplay.text = msg;
        errorString = msg;
    }
    
    /**
     *  @private
     */
    private function createHelpContent():void
    {
        if (_helpContent && helpContentGroup && helpContentChanged)
        {            
            helpContentChanged = false;
            
            var content:Object = _helpContent.getInstance();
            
            if (!(content is Array))
                content = [content];
            
            helpContentGroup.mxmlContent = content as Array; 
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers 
    //
    //--------------------------------------------------------------------------
   
    /**
     *  @private
     */
    private function contentGroup_validHandler(event:FlexEvent):void
    {
        // update error string
        updateErrorString();
    }
    
    /**
     *  @private
     */
    private function contentGroup_invalidHandler(event:FlexEvent):void
    {
        // update error string
        updateErrorString();
    }
    

    
}
}