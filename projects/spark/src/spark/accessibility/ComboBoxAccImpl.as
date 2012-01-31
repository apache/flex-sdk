////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.accessibility
{
    
import flash.accessibility.Accessibility;
import flash.events.Event;
import flash.events.FocusEvent;

import mx.accessibility.AccConst;
import mx.core.UIComponent;
import mx.core.mx_internal;

import spark.components.ComboBox;
import spark.components.TextInput;
import spark.events.IndexChangeEvent;
import spark.events.SkinPartEvent;

use namespace mx_internal;

/**
 *  ComboBoxAccImpl is the accessibility implementation class
 *  for spark.components.ComboBox.
 *
 *  <p>When a Spark ComboBox is created,
 *  its <code>accessibilityImplementation</code> property
 *  is set to an instance of this class.
 *  The Flash Player then uses this class to allow MSAA clients
 *  such as screen readers to see and manipulate the ComboBox.
 *  See the mx.accessibility.AccImpl and
 *  flash.accessibility.AccessibilityImplementation classes
 *  for background information about accessibility implementation
 *  classes and MSAA.</p>
 *
 *  <p><b>Children</b></p>
 *
 *  <p>The MSAA children of a ComboBox are its editable TextInput
 *  (with childID 1) and its list items (with childIDs 2, 3, ... n).
 *  The number of children is one plus the number of items
 *  in the <code>dataProvider</code>
 *  (not one plus the the number of visible renderers).</p>
 *
 *  <p>As described below, the accessibility of the TextInput
 *  and the list items is managed by the ComboBox;
 *  their <code>accessibilityImplementation</code>
 *  and <code>accessibilityProperties</code> 
 *  are ignored by the Flash Player.</p>
 *
 *  <p><b>Role</b></p>
 *
 *  <p>The MSAA Role of a ComboBox is ROLE_SYSTEM_COMBOBOX.</p>
 *
 *  <p>The MSAA Role of the editable TextInput is ROLE_SYSTEM_TEXT.</p>
 *
 *  <p>The Role of each list item is ROLE_SYSTEM_LISTITEM.</p>
 *
 *  <p><b>Name</b></p>
 *
 *  <p>The MSAA Name of a ComboBox (as well as its editable TextInput)
 *  is, by default, an empty string.
 *  When wrapped in a FormItem element, the Name is the FormItem's label.
 *  To override this behavior, set the ComboBox's
 *  <code>accessibilityName</code> property.</p>
 *
 *  <p>The Name of each list item is determined by the ComboBox's
 *  <code>itemToLabel()</code> method</p>
 *
 *  <p>When the Name of the ComboBox or one of its items changes,
 *  a ComboBox dispatches the MSAA event EVENT_OBJECT_NAMECHANGE
 *  with the proper childID for a list item or 0 for itself.</p>
 *
 *  <p><b>Description</b></p>
 *
 *  <p>The MSAA Description of a ComboBox, by default, an empty string,
 *  but you can set the ComboBox's <code>accessibilityDescription</code>
 *  property.</p>
 *
 *  <p>The Description of each list item is the empty string.</p>
 *
 *  <p><b>State</b></p>
 *
 *  <p>The MSAA State of a ComboBox is a combination of:
 *  <ul>
 *    <li>STATE_SYSTEM_UNAVAILABLE (when enabled is false)</li>
 *    <li>STATE_SYSTEM_FOCUSABLE (when enabled is true)</li>
 *    <li>STATE_SYSTEM_FOCUSED
 *    (when enabled is true and the ComboBox has focus)</li>
 *    <li>STATE_SYSTEM_EXPANDED (when it is open)</li>
 *    <li>STATE_SYSTEM_COLLAPSED (when it is closed)</li>
 *  </ul></p>
 *
 *  <p>The State of the editable TextInput is a combination of:
 *  <ul>
 *    <li>STATE_SYSTEM_UNAVAILABLE (when enabled is false)</li>
 *    <li>STATE_SYSTEM_FOCUSABLE (when enabled is true)</li>
 *    <li>STATE_SYSTEM_FOCUSED
 *    (when enabled is true and the ComboBox has focus)</li>
 *  </ul></p>
 *
 *  <p>The State of a list item is a combination of:
 *  <ul>
 *    <li>STATE_SYSTEM_FOCUSABLE</li>
 *    <li>STATE_SYSTEM_FOCUSED (when it has focus)</li>
 *    <li>STATE_SYSTEM_SELECTABLE</li>
 *    <li>STATE_SYSTEM_SELECTED (when it is selected)</li>
 *  </ul></p>
 *
 *  <p>When the State of the ComboBox, its TextInput,
 *  or one of its list items changes,
 *  a ComboBox dispatches the MSAA event EVENT_OBJECT_STATECHANGE
 *  with the proper childID for the TextInput or list item,
 *  or 0 for itself.</p>
 *
 *  <p><b>Value</b></p>
 *
 *  <p>The MSAA Value of a ComboBox is the MSAA Name
 *  of the currently selected list item
 *  or the text entered into the TextInput.</p>
 *
 *  <p>The Value of a list item is always the empty string.</p>
 *
 *  <p>When the Value of the ComboBox changes,
 *  a ComboBox dispatches the MSAA event EVENT_OBJECT_VALUECHANGE.</p>
 *
 *  <p><b>Location</b></p>
 *
 *  <p>The MSAA Location of a ComboBox, its TextInput, or one of its
 *  list items is its bounding rectangle.</p>
 *
 *  <p><b>Default Action</b></p>
 *
 *  <p>Neither the ComboBox or it's TextInput have an MSAA DefaultAction.</p>
 *
 *  <p>The DefaultAction of a list item is "Double Click".
 *  Performing this action will select the item.</p>
 *
 *  <p><b>Focus</b></p>
 *
 *  <p>The ComboBox itself can receive focus, as well as its list items
 *  (either while the ComboBox is collapsed or expanded).</p>
 *
 *  <p><b>Selection</b></p>
 *
 *  <p>The ComboBox allows a single item to be selected,
 *  in which case an EVENT_OBJECT_SELECTION event is fired.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ComboBoxAccImpl extends DropDownListBaseAccImpl
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Enables accessibility in the ComboBox class.
     * 
     *  <p>This method is called by application startup code
     *  that is autogenerated by the MXML compiler.
     *  Afterwards, when instances of ComboBox are initialized,
     *  their <code>accessibilityImplementation</code> property
     *  will be set to an instance of this class.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static function enableAccessibility():void
    {
        ComboBox.createAccessibilityImplementation =
            createAccessibilityImplementation;
    }
    
    /**
     *  @private
     *  Creates a ComboBox's AccessibilityImplementation object.
     *  This method is called from UIComponent's
     *  initializeAccessibility() method.
     */
    mx_internal static function createAccessibilityImplementation(
        component:UIComponent):void
    {
        component.accessibilityImplementation =
            new ComboBoxAccImpl(component);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *
     *  @param master The UIComponent instance that this AccImpl instance
     *  is making accessible.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ComboBoxAccImpl(master:UIComponent)
    {
        super(master);
        
        // ComboBox has a TextInput as a skin part,
        // and we need to listen to some of its events.
        // It may or may not be present when this constructor is called.
        // If it comes or goes later, we are notified via
        // "partAdded" and "partRemoved" events.
        var textInput:TextInput = ComboBox(master).textInput;
        if (textInput)
            textInput.addEventListener(Event.CHANGE, textInputChangeHandler);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: AccImpl
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  eventsToHandle
    //----------------------------------
    
    /**
     *  @private
     *  Array of events that we should listen for from the master component.
     */
    override protected function get eventsToHandle():Array
    {
        return super.eventsToHandle.concat([ FocusEvent.FOCUS_IN,
                                             SkinPartEvent.PART_ADDED,
                                             SkinPartEvent.PART_REMOVED ]);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: AccessibilityImplementation
    //
    //--------------------------------------------------------------------------
    /**
     *  @private
     *  Returns the name of the component.
     *
     *  @param childID uint.
     *
     *  @return Name of the component.
     *
     *  @tiptext Returns the name of the component
     */
    override public function get_accName(childID:uint):String
    {
        if (childID <= 1)
            return super.get_accName(0);
        else
            return super.get_accName(childID - 1);
    }
    
    
    /**
     *  @private
     *  Gets the role for the component.
     *
     *  @param childID children of the component
     */
    override public function get_accRole(childID:uint):uint
    {
        if (childID == 1)
            return AccConst.ROLE_SYSTEM_TEXT;
        else if (childID == 0)
            return super.get_accRole(0);
        else 
            return super.get_accRole(childID - 1);
    }
    
    /**
     *  @private
     *  IAccessible method for returning the state of the ComboBox.
     *  States are predefined for all the components in MSAA.
     *  Values are assigned to each state.
     *
     *  @param childID uint
     *
     *  @return State uint
     */
    override public function get_accState(childID:uint):uint
    {
        if (childID <= 1)
            return  super.get_accState(0);
        else {
            return super.get_accState(ComboBox(master).isDropDownOpen ? childID -1 : 0);
        }
    }
    
    /**
     *  @private
     *  IAccessible method for returning the Default Action.
     *
     *  @param childID uint
     *
     *  @return DefaultAction String
     */
    override public function get_accDefaultAction(childID:uint):String
    {
        if (childID <= 1)
            return null;
        
        return super.get_accDefaultAction(childID - 1);
    }
    
    /**
     *  @private
     *  IAccessible method for executing the Default Action.
     *
     *  @param childID uint
     */
    override public function accDoDefaultAction(childID:uint):void
    {
        if (childID > 1)
            super.accDoDefaultAction(childID -1);
    }
    
    /**
     *  @private
     *  Method to return an array of childIDs.
     *
     *  @return Array
     */
    override public function getChildIDArray():Array
    {
        var childIDArray:Array = super.getChildIDArray();
        childIDArray[childIDArray.length] = childIDArray.length;
        return childIDArray;
    }
    
    /**
     *  @private
     *  IAccessible method for returning the childFocus of the List.
     *
     *  @param childID uint
     *
     *  @return focused childID.
     */
    override public function get_accFocus():uint
    {
        var index:uint = super.get_accFocus();
        return index > 0 ? index + 1 : 0;
    }
    
    /**
     *  @private
     *  IAccessible method for returning the bounding box of the ListItem.
     *
     *  @param childID uint
     *
     *  @return Location Object
     */
    override public function accLocation(childID:uint):*
    {
        if (childID == 0)
            return super.accLocation(0);
        else if (childID == 1)
            return ComboBox(master).textInput;
        else
            return super.accLocation(childID - 1);
    }
    
    /**
     *  @private
     *  IAccessible method for selecting an item.
     *
     *  @param childID uint
     */
    override public function accSelect(selFlag:uint, childID:uint):void
    {
        if (childID > 1 )
            super.accSelect(selFlag, childID - 1)
    }
    
    /**
     *  @private
     *  IAccessible method for returning the value of the ComboBox
     *  (which would be the text of the item selected 
     *  or the text entered in textInput).
     *  @param childID uint
     *
     *  @return Value String
     */
    override public function get_accValue(childID:uint):String
    {
        var comboBox:ComboBox = ComboBox(master);
        if (childID <= 1)
            return comboBox.selectedIndex == -1 ?
                comboBox.textInput.text :comboBox.selectedItem;
        return null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: AccImpl
    //
    //--------------------------------------------------------------------------
    
    
    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers: AccImpl
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Override the generic event handler.
     *  All AccImpl must implement this
     *  to listen for events from its master component.
     */
    override protected function eventHandler(event:Event):void
    {
        var textInput:TextInput;
        if (event is IndexChangeEvent)
        {
            var tweaked_event:Event = event.clone();
            IndexChangeEvent(tweaked_event).oldIndex += 1;
            IndexChangeEvent(tweaked_event).newIndex += 1;
            super.eventHandler(tweaked_event);
        } 
                
        switch (event.type)
        {
            case "open":
            {
                Accessibility.sendEvent(master, 0, AccConst.EVENT_OBJECT_STATECHANGE);
                break;
            }

            case "focusIn":
            {
                Accessibility.sendEvent(master, 0, AccConst.EVENT_OBJECT_FOCUS);
                break;
            }

            case "caretChange":
            {
                var index:uint = IndexChangeEvent(event).newIndex;
                var childID:uint = index + 2;
                if (!ComboBox(master).isDropDownOpen) { 
                    Accessibility.sendEvent(master, 0,
                        AccConst.EVENT_OBJECT_VALUECHANGE);
                    Accessibility.sendEvent(master, 1,
                        AccConst.EVENT_OBJECT_VALUECHANGE);
					Accessibility.sendEvent(master, childID,
						AccConst.EVENT_OBJECT_FOCUS);   
                }
                
                break;
            }
                
            case SkinPartEvent.PART_ADDED:
            {
                textInput = ComboBox(master).textInput;
                if (SkinPartEvent(event).instance == textInput)
                {
                    textInput.addEventListener(Event.CHANGE,
                                               textInputChangeHandler);
                }
                break;
            }
                
            case SkinPartEvent.PART_REMOVED:
            {
                textInput = ComboBox(master).textInput;
                if (SkinPartEvent(event).instance == textInput)
                {
                    textInput.removeEventListener(Event.CHANGE,
                                                  textInputChangeHandler);
                }
                break;
            }
                
            default:
            {
                super.eventHandler(event);
            }
        }
    }
    
    /**
     *  @private
     */
    private function textInputChangeHandler(event:Event):void
    {
        Accessibility.sendEvent(master, 0, AccConst.EVENT_OBJECT_VALUECHANGE);
    }
}
    
    
}

