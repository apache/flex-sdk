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

import spark.components.supportClasses.ButtonBarBase;
import spark.components.supportClasses.ListBase;

use namespace mx_internal;

/**
 *  ButtonBarBaseAccImpl is the accessibility implementation class
 *  for spark.components.supportClasses.ButtonBarBase.
 *
 *  <p>Although TabBar has its own accessibility implementation subclass,
 *  ButtonBar simply uses the one for ButtonBarBase.
 *  Therefore, the rest of this description refers to the commonly-used
 *  ButtonBar component rather than the ButtonBarBase base class.</p>
 *
 *  <p>When a Spark ButtonBar is created,
 *  its <code>accessibilityImplementation</code> property
 *  is set to an instance of this class.
 *  The Flash Player then uses this class to allow MSAA clients
 *  such as screen readers to see and manipulate the ButtonBar.
 *  See the mx.accessibility.AccImpl and
 *  flash.accessibility.AccessibilityImplementation classes
 *  for background information about accessibility implementation
 *  classes and MSAA.</p>
 *
 *  <p><b>Children</b></p>
 *
 *  <p>The MSAA children of a ButtonBar are its buttons.
 *  As described below, the accessibility of these Buttons
 *  is managed by the ButtonBar;
 *  their own <code>accessibilityImplementation</code>
 *  and <code>accessibilityProperties</code> are ignored
 *  by the Flash Player.</p>
 *
 *  <p><b>Role</b></p>
 *
 *  <p>The MSAA Role of a ButtonBar is ROLE_SYSTEM_TOOLBAR.</p>
 *
 *  <p>The Role of each Button in the ButtonBar is ROLE_SYSTEM_PUSHBUTTON.</p>
 *
 *  <p><b>Name</b></p>
 *
 *  <p>The MSAA Name of a ButtonBar is, by default, an empty string.
 *  When wrapped in a FormItem element, the Name is the FormItem's label.
 *  To override this behavior,
 *  set the ButtonBar's <code>accessibilityName</code> property.</p>
 *
 *  <p>The Name of each Button is determined by the ButtonBar's
 *  <code>itemToLabel()</code> method.</p>
 *
 *  <p>When the Name of the ButtonBar or one of its Buttons changes,
 *  a ButtonBar dispatches the MSAA event EVENT_OBJECT_NAMECHANGE
 *  with the proper childID for the Button or 0 for itself.</p>
 *
 *  <p><b>Description</b></p>
 *
 *  <p>The MSAA Description of a ButtonBar is, by default, an empty string,
 *  but you can set the ButtonBar's <code>accessibilityDescription</code>
 *  property.</p>
 *
 *  <p>The Description of each Button is the empty string.</p>
 *
 *  <p><b>State</b></p>
 *
 *  <p>The MSAA State of a ButtonBar is a combination of:
 *  <ul>
 *    <li>STATE_SYSTEM_UNAVAILABLE (when enabled is false)</li>
 *    <li>STATE_SYSTEM_FOCUSABLE (when enabled is true)</li>
 *    <li>STATE_SYSTEM_FOCUSED (when enabled is true
 *    and the ButtonBar has focus)</li>
 *  </ul></p>
 *
 *  <p>The State of a Button in a ButtonBar is a combination of:
 *  <ul>
 *    <li>STATE_SYSTEM_FOCUSED (when it has focus)</li>
 *    <li>STATE_SYSTEM_PRESSED (when it is selected)</li>
 *  </ul></p>
 *
 *  <p>When the State of the ButtonBar or one of its Buttons changes,
 *  a ButtonBar dispatches the MSAA event EVENT_OBJECT_STATECHANGE
 *  with the proper childID for the Button or 0 for itself.</p>
 *
 *  <p><b>Value</b></p>
 *
 *  <p>A ButtonBar, or a Button in a ButtonBar, does not have an MSAA Value.</p>
 *
 *  <p><b>Location</b></p>
 *
 *  <p>The MSAA Location of a ButtonBar, or a Button in a ButtonBar,
 *  is its bounding rectangle.</p>
 *
 *  <p><b>Default Action</b></p>
 *
 *  <p>A ButtonBar does not have an MSAA DefaultAction.</p>
 *
 *  <p>The DefaultAction for a Button in a ButtonBar is "Press".</p>
 *
 *  <p><b>Focus</b></p>
 *
 *  <p>Both the ButtonBar and its individual buttons accept focus.
 *  When they do so it dispatches the MSAA event EVENT_OBJECT_FOCUS.
 *  A button is not automatically selected when focused
 *  through arrow key navigation.
 *  To select a focused button, the user must press the spacebar.</p>
 *
 *  <p><b>Selection</b></p>
 *
 *  <p>MSAA Selection will press the button
 *  corresponding to the specified childID.
 *  Only one button can be pressed at a time.</p>
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ButtonBarBaseAccImpl extends ListBaseAccImpl
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Enables accessibility in the ButtonBarBase class.
     *
     *  <p>This method is called by application startup code
     *  that is autogenerated by the MXML compiler.
     *  Afterwards, when instances of ButtonBarBase are initialized,
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
        ButtonBarBase.createAccessibilityImplementation =
            createAccessibilityImplementation;
    }

    /**
     *  @private
     *  Creates a ButtonBarBase's AccessibilityImplementation object.
     *  This method is called from UIComponent's
     *  initializeAccessibility() method.
     */
    mx_internal static function createAccessibilityImplementation(
                                component:UIComponent):void
    {
        component.accessibilityImplementation =
            new ButtonBarBaseAccImpl(component);
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
    public function ButtonBarBaseAccImpl(master:UIComponent)
    {
        super(master);
        role = AccConst.ROLE_SYSTEM_TOOLBAR;
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
        return childID == 0 ? role : AccConst.ROLE_SYSTEM_PUSHBUTTON;
    }

    /**
     *  @private
     *  IAccessible method for returning the state of the ButtonBar Button.
     *  States are predefined for all the components in MSAA.
     *  Values are assigned to each state.
     *  Depending upon the ButtonBar Button being Selected, Selectable, pressed
     *  a value is returned.
     *
     *  @param childID uint
     *
     *  @return State uint
     */
    override public function get_accState(childID:uint):uint
    {
        var accState:uint = getState(childID);

        if (childID > 0)
        {
            var index:int = childID - 1;
            if (ListBase(master).isItemIndexSelected(index))
                accState |= AccConst.STATE_SYSTEM_PRESSED;
            if (index == ListBase(master).caretIndex)
                accState |= AccConst.STATE_SYSTEM_FOCUSED;
        }
        return accState;
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
        if (childID == 0)
            return null;

        return "Press";
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
	 *  @private
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
                var pressed:int = ButtonBarBase(master).selectedIndex;
                
                Accessibility.sendEvent(master, pressed + 1,
                    AccConst.EVENT_OBJECT_STATECHANGE, true);
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
