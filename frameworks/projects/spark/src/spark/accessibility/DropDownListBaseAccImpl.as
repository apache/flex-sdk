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

import mx.accessibility.AccConst;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.accessibility.AccImpl;
import spark.components.supportClasses.ListBase;
import spark.components.supportClasses.DropDownListBase;

use namespace mx_internal;
    
/**
 *  DropDownListAccImpl is the accessibility implementation class
 *  for spark.components.supportClasses.DropDownListBase.
 *
 *  <p>Although ComboBox has its own accessibility implementation subclass,
 *  DropDownList simply uses the one for DropDownListBase.
 *  Therefore, the rest of this description refers to
 *  the commonly-used DropDownList component rather than the DropDownListBase
 *  base class.</p>
 *
 *  <p>When a Spark DropDownList is created,
 *  its <code>accessibilityImplementation</code> property
 *  is set to an instance of this class.
 *  The Flash Player then uses this class to allow MSAA clients
 *  such as screen readers to see and manipulate the DropDownList.
 *  See the mx.accessibility.AccImpl and
 *  flash.accessibility.AccessibilityImplementation classes
 *  for background information about accessibility implementation
 *  classes and MSAA.</p>
 *
 *  <p><b>Children</b></p>
 *
 *  <p>The MSAA children of a DropDownList are its list items.
 *  The number of children is the number of items
 *  in the <code>dataProvider</code>
 *  not just the number of visible renderers.</p>
 *
 *  <p>As described below, the accessibility of the list items
 *  is managed by the DropDownList;
 *  the <code>accessibilityImplementation</code>
 *  and <code>accessibilityProperties</code> of the item renderers
 *  are ignored by the Flash Player.</p>
 *
 *  <p><b>Role</b></p>
 *
 *  <p>The MSAA Role of a DropDownList is ROLE_SYSTEM_COMBOBOX.</p>
 *
 *  <p>The Role of each list item is ROLE_SYSTEM_LISTITEM.</p>
 *
 *  <p><b>Name</b></p>
 *
 *  <p>The MSAA Name of a DropDownList is, by default, an empty string.
 *  When wrapped in a FormItem element, the Name is the FormItem's label.
 *  To override this behavior,
 *  set the DropDownList's <code>accessibilityName</code> property.</p>
 *
 *  <p>The Name of each list item is determined by the DropDownList's
 *  <code>itemToLabel()</code> method.</p>
 *
 *  <p>When the Name of the DropDownList or one of its items changes,
 *  a DropDownList dispatches the MSAA event EVENT_OBJECT_NAMECHANGE
 *  with the proper childID for a list item or 0 for itself.</p>
 *
 *  <p><b>Description</b></p>
 *
 *  <p>The MSAA Description of a DropDownList is, by default,
 *  an empty string, but you can set the DropDownList's
 *  <code>accessibilityDescription</code> property.</p>
 *
 *  <p>The Description of each list item is the empty string.</p>
 *
 *  <p><b>State</b></p>
 *
 *  <p>The MSAA State of a DropDownList is a combination of:
 *  <ul>
 *    <li>STATE_SYSTEM_UNAVAILABLE (when enabled is false)</li>
 *    <li>STATE_SYSTEM_FOCUSABLE (when enabled is true)</li>
 *    <li>STATE_SYSTEM_FOCUSED
 *    (when enabled is true and the DropDownList has focus)</li>
 *    <li>STATE_SYSTEM_EXPANDED (when it is open)</li>
 *    <li>STATE_SYSTEM_COLLAPSED (when it is closed)</li>
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
 *  <p>When the State of the DropDownList or one of its list items changes,
 *  a DropDownList dispatches the MSAA event EVENT_OBJECT_STATECHANGE
 *  with the proper childID for the list item or 0 for itself.</p>
 *
 *  <p><b>Value</b></p>
 *
 *  <p>The MSAA Value of a DropDownList is the MSAA Name
 *  of the currently selected list item.</p>
 *
 *  <p>The Value of each list item is the empty string.</p>
 *
 *  <p>When the Value of the DropDownList changes,
 *  it dispatches the MSAA event EVENT_OBJECT_VALUECHANGE.</p>
 *
 *  <p><b>Location</b></p>
 *
 *  <p>The MSAA Location of a DropDownList or a list item
 *  is its bounding rectangle.</p>
 *
 *  <p><b>Default Action</b></p>
 *
 *  <p>A DropDownList does not have an MSAA DefaultAction</p>
 * 
 *  <p>The DefaultAction of a list item is "Double click".</p>
 *
 *  <p><b>Focus</b></p>
 *
 *  <p>The DropDownList itself can receive focus, as well as its list items
 *  (either while the DropDownList is collapsed or expanded).
 *  The EVENT_OBJECT_FOCUS is fired when this happens.</p>
 *
 *  <p><b>Selection</b></p>
 *
 *  <p>The DropDownList allows a single item to be selected,
 *  in which case an EVENT_OBJECT_SELECTION event is fired.</p>
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class DropDownListBaseAccImpl extends ListBaseAccImpl
{
    include "../core/Version.as";
    
    //-------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Enables accessibility in the DropDownListBase class.
     *
     *  <p>This method is called by application startup code
     *  that is autogenerated by the MXML compiler.
     *  Afterwards, when instances of DropDownListBase are initialized,
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
        DropDownListBase.createAccessibilityImplementation =
            createAccessibilityImplementation;
    }
    
    /**
     *  @private
     *  Creates a DropDownListBase AccessibilityImplementation object.
     *  This method is called from UIComponent's
     *  initializeAccessibility() method.
     */
    mx_internal static function createAccessibilityImplementation(
        component:UIComponent):void
    {
        component.accessibilityImplementation =
            new DropDownListBaseAccImpl(component);
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
    public function DropDownListBaseAccImpl(master:UIComponent)
    {
        super(master);
        
        role = AccConst.ROLE_SYSTEM_COMBOBOX;
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
        return super.eventsToHandle.concat(["open", "close"]);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: AccessibilityImplementation
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  IAccessible method for returning the value of the DropDownListBase
     *  (which would be the text of the item selected).
     *  The DropDownListBase should return the content of the selected item as the value.
     *
     *  @param childID uint
     *
     *  @return Value String
     */
    override public function get_accValue(childID:uint):String
    {
        if (childID == 0)
            return getName(DropDownListBase(master).selectedIndex + 1);
        return null;
    }
    
    /**
     *  @private
     */
    override public function get_accState(childID:uint):uint
    {
        var accState:uint = super.get_accState(childID);
        
        if (childID == 0)
        {
            if (DropDownListBase(master).isDropDownOpen)
                accState |= AccConst.STATE_SYSTEM_EXPANDED;
            else
                accState |= AccConst.STATE_SYSTEM_COLLAPSED;
        }
        else if (!DropDownListBase(master).isDropDownOpen)
        {
            if (childID-1 == ListBase(master).caretIndex)
                    accState |= AccConst.STATE_SYSTEM_SELECTED;        
            accState = AccConst.STATE_SYSTEM_INVISIBLE;
        }
        
        return accState;
    }
    
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
        switch (event.type)
        {
            case "open":
            {
                Accessibility.sendEvent(master, 0, AccConst.EVENT_OBJECT_STATECHANGE);
                
                var index:uint = DropDownListBase(master).selectedIndex;
                if (index >= 0)
                {
                    Accessibility.sendEvent(master, index + 1,
                        AccConst.EVENT_OBJECT_FOCUS);
                }
                break;
            }
            case "close":
            {
                Accessibility.sendEvent(master, 0, AccConst.EVENT_OBJECT_STATECHANGE);
                Accessibility.sendEvent(master, 0, AccConst.EVENT_OBJECT_FOCUS);
                break;
            }
            case "change":
            {
                if (!(DropDownListBase(master).isDropDownOpen))
                {
                    Accessibility.sendEvent(master, 0, 
                        AccConst.EVENT_OBJECT_VALUECHANGE, true);
                    break;
                }
            }
            case "caretChange":
            {
                if (!(DropDownListBase(master).isDropDownOpen))
                    break;
            }
            default:
            {
                super.eventHandler(event);
                break;
            }
        }
    }
}
    
}
