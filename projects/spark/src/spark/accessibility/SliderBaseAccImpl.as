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
import flash.utils.getQualifiedClassName;

import mx.accessibility.AccImpl;
import mx.accessibility.AccConst;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

import spark.components.supportClasses.SliderBase;

use namespace mx_internal;

[ResourceBundle("components")]

/**
 *  SliderBaseAccImpl is the accessibility implementation class
 *  for spark.components.supportClasses.SliderBase.
 *
 *  <p>The Spark HSlider and VSlider components extend SliderBase
 *  and use SlideBaseAccImpl as their accessibility implementation
 *  class. 
 *  For convenience, the rest of this description uses the word
 *  Slider to mean either HSlider or VSlider, even though there
 *  is no Spark class named Slider.</p>
 *
 *  <p>When a Slider is created,
 *  its <code>accessibilityImplementation</code> property
 *  is set to an instance of this class.
 *  The Flash Player then uses this class to allow MSAA clients
 *  such as screen readers to see and manipulate the Slider.
 *  See the mx.accessibility.AccImpl and
 *  flash.accessibility.AccessibilityImplementation classes
 *  for background information about accessibility implementation
 *  classes and MSAA.</p>
 *
 *  <p><b>Children</b></p>
 *
 *  <p>A Slider has 3 MSAA children:
 *  <ol>
 *    <li>Clickable area to the left (or bottom) of thumb</li>
 *    <li>Thumb</li>
 *    <li>Clickable area to the right (or top) of thumb</li>
 *  </ol></p>
 *
 *  <p><b>Role</b></p>
 *
 *  <p>The MSAA Role of a Slider is ROLE_SYSTEM_SLIDER.</p>
 *
 *  <p>The Role of each child is:
 *  <ol>
 *    <li>ROLE_SYSTEM_PUSHBUTTON</li>
 *    <li>ROLE_SYSTEM_INDICATOR</li>
 *    <li>ROLE_SYSTEM_PUSHBUTTON</li>
 *  </ol></p>
 *
 *  <p><b>Name</b></p>
 *
 *  <p>The MSAA Name of a Slider is, by default, an empty string.
 *  When wrapped in a FormItem element, the Name is the FormItem's label.
 *  To override this behavior,
 *  set the Slider's <code>accessibilityName</code> property.</p>
 *
 *  <p>The Name of each child comes from a locale-dependent resource.
 *  In the en_US locale, the names are:
 *  <ol>
 *    <li>"Page left" for HSlider; "Page up" for VSlider</li>
 *    <li>"Position"</li>
 *    <li>"Page right" for HSlider; "Page down" for VSlider</li>
 *  </ol></p>
 *
 *  <p>When the Name of the Slider or one of its child parts changes,
 *  a Slider dispatches the MSAA event EVENT_OBJECT_NAMECHANGE
 *  with the proper childID for the part or 0 for itself.</p>
 *
 *  <p><b>Description</b></p>
 *
 *  <p>The MSAA Description of a Slider is, by default, the empty string,
 *  but you can set the Slider's <code>accessibilityDescription</code>
 *  property.</p>
 *
 *  <p>The Description of each child part is the empty string.</p>
 *
 *  <p><b>State</b></p>
 *
 *  <p>The MSAA state of a Slider is a combination of: 
 *  <ul>
 *    <li>STATE_SYSTEM_UNAVAILABLE (when enabled is false)</li>
 *    <li>STATE_SYSTEM_FOCUSABLE (when enabled is true)</li>
 *    <li>STATE_SYSTEM_FOCUSED
 *    (when enabled is true and the Slider has focus)</li>
 *  </ul></p>
 *
 *  <p>The State of each child part is:
 *  <ul>
 *     <li>STATE_SYSTEM_UNAVAILABLE (when enabled is false)</li>
 *  </ul></p>
 *
 *  <p>When the State of the Slider or one of its child parts changes,
 *  a Slider dispatches the MSAA event EVENT_OBJECT_STATECHANGE
 *  with the proper childID for the part or 0 for itself.</p>
 *
 *  <p><b>Value</b></p>
 *
 *  <p>The MSAA Value of a Slider is a number between 0 and 100.</p>
 *
 *  <p>The child parts do not have MSAA values.</p>
 *
 *  <p>When the Value of the Slider changes,
 *  a Slider dispatches the MSAA event EVENT_OBJECT_VALUECHANGE.</p>
 *
 *  <p><b>Location</b></p>
 *
 *  <p>The MSAA Location of a Slider or its thumb is its bounding rectangle.
 *  For the two children representing the trackbar regions adjacent
 *  to the thumb, the slider's bounding rectangle is returned.</p>
 *
 *  <p><b>Default Action</b></p>
 *
 *  <p>A Slider and its child parts have no default action.</p>
 *
 *  <p><b>Focus</b></p>
 *
 *  <p>A Slider accepts focus.
 *  When it does so, it dispatches the MSAA event EVENT_OBJECT_FOCUS.</p>
 *
 *  <p><b>Selection</b></p>
 *
 * <p>A Slider does not support selection in the MSAA sense.</p>
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class SliderBaseAccImpl extends AccImpl
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Enables accessibility in the SliderBase class.
     *
     *  <p>This method is called by application startup code
     *  that is autogenerated by the MXML compiler.
     *  Afterwards, when instances of sliders are initialized,
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
        SliderBase.createAccessibilityImplementation =
            createAccessibilityImplementation;
    }

    /**
     *  @private
     *  Creates a SliderBase's AccessibilityImplementation object.
     *  This method is called from UIComponent's
     *  initializeAccessibility() method.
     */
    mx_internal static function createAccessibilityImplementation(
                                component:UIComponent):void
    {
        component.accessibilityImplementation =
            new SliderBaseAccImpl(component);
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
    public function SliderBaseAccImpl(master:UIComponent)
    {
        super(master);

        role = AccConst.ROLE_SYSTEM_SLIDER;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: AccessibilityImplementation
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Gets the role for the component.
     *
     *  @param childID children of the component
     */
    override public function get_accRole(childID:uint):uint
    {
        var childRole:uint;
        
        switch (childID)
        {
            case 1:
            case 3:
            {
                childRole = AccConst.ROLE_SYSTEM_PUSHBUTTON;
                break;
            }
            case 2:
            {
                childRole = AccConst.ROLE_SYSTEM_INDICATOR;
                break;
            }
            default:
            {
                childRole = role;
                break;
            }
        }
        return childRole;
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
     *    Array of events that we should listen for from the master component.
     */
    override protected function get eventsToHandle():Array
    {
        return super.eventsToHandle.concat([ "change", FocusEvent.FOCUS_IN]);
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: AccessibilityImplementation
    //
    //--------------------------------------------------------------------------

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
        if (childID == 1 || childID == 3)
            return "Press";
        return null;
    }
    
    /**
     *  @private
     *  IAccessible method for executing the Default Action.
     *
     *  @param childID uint
     */
    override public function accDoDefaultAction(childID:uint):void
    { 
        var slider:SliderBase = SliderBase(master)
        if (childID == 1 && slider.enabled)
            slider.value = slider.value - slider.stepSize;
        else if (childID == 3 && slider.enabled)
            slider.value = slider.value + slider.stepSize;
    }
    
    /**
     *  @private
     *  IAccessible method for returning the bounding box of the Slider or its parts.
     *
     *  @param childID uint
     *
     *  @return Location Object
     */
    override public function accLocation(childID:uint):*
    {
        if (childID == 2)
            return SliderBase(master).thumb;
        // no way to return the parts of the track bar for childID 1 and 3
    }
    /**
     *  @private
     *  IAccessible method for returning the value of the slider
     *  (which would be the value of the item selected).
     *  The slider should return the value of the current thumb as the value.
     *
     *  @param childID uint
     *
     *  @return Value String
     */
    override public function get_accValue(childID:uint):String
    {
        if (childID > 0)
            return null;
        var val:Number = SliderBase(master).value;

        val = (val -  SliderBase(master).minimum) /
              (SliderBase(master).maximum - SliderBase(master).minimum) * 100;

        return String(Math.floor(val));
    }

    /**
     *  @private
     *  Method to return an array of childIDs, which is fixed for sliders.
     * (1 = left/top part of trackbar, 2 = thumb, 3 = right/bottom part of trackbar)
     *
     *  @return Array
     */
    override public function getChildIDArray():Array
    {
        return createChildIDArray(3);
    }

    /**
     *  @private
     *  Method for returning the name of the slider or its sunparts
     *
     *
     *  @param childID uint
     *
     *  @return Name String
     */
    override protected function getName(childID:uint):String
    {
        var resourceManager:IResourceManager = ResourceManager.getInstance();
        var isHSlider:Boolean = 
            getQualifiedClassName(master) == "spark.components::HSlider";
        switch(childID)
        {
            case 1:
                return resourceManager.getString(
                    "components", isHSlider ? 
                    "sliderPageLeftAccName" : "sliderPageDownAccName");
            break;
            case 2:
                return resourceManager.getString(
                    "components", "sliderPositiontAccName");
            break;
            case 3:
                return resourceManager.getString(
                    "components", isHSlider ? 
                    "sliderPageRightAccName" : "sliderPageUpAccName");
            break;
            default:
                return "";
            break;
        }
    }

    /**
     *  @private
     *  IAccessible method for returning the state of the Button.
     *  States are predefined for all the components in MSAA.
     *  Values are assigned to each state.
     *
     *  @param childID uint
     *
     *  @return State uint
     */
    override public function get_accState(childID:uint):uint
    {
        var accState:uint;
        if (childID == 0)
            accState= getState(childID);
        else if (!master.enabled)
            accState = AccConst.STATE_SYSTEM_UNAVAILABLE;
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
     *  All AccImpl must implement this to listen
     *  for events from its master component.
     */
    override protected function eventHandler(event:Event):void
    {
        // Let AccImpl class handle the events
        // that all accessible UIComponents understand.
        $eventHandler(event);

        switch (event.type)
        {
            case "change":
            {
                Accessibility.sendEvent(master, 0,
                                        AccConst.EVENT_OBJECT_VALUECHANGE, true);
                break;
            }
            case "focusIn":
                Accessibility.sendEvent(master, 0, AccConst.EVENT_OBJECT_FOCUS);
                break;
        }
    }
}

}
