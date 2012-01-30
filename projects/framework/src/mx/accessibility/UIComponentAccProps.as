////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.accessibility
{

import flash.accessibility.Accessibility;
import flash.accessibility.AccessibilityProperties;
import flash.events.Event;
import mx.accessibility.AccImpl;
import mx.controls.FormItemLabel;
import mx.controls.scrollClasses.ScrollBar;
import mx.core.UIComponent;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  The UIComponentAccProps class is the accessibility class for UIComponent.
 *  It is used to provide accessibility to Form, ToolTip, and Error ToolTip.
 *
 *  @helpid 3030
 *  @tiptext This is the UIComponent Accessibility Class.
 *  @review
 */
public class UIComponentAccProps extends AccessibilityProperties
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class initialization
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Static variable triggering the hookAccessibility() method.
     *  This is used for initializing UIComponentAccProps class to hook its
     *  createAccessibilityImplementation() method to UIComponent class 
     *  before it gets called from UIComponent.initialize().
     */
    private static var accessibilityHooked:Boolean = hookAccessibility();

    /**
     *  @private
     *  Static Method for swapping the
     *  createAccessibilityImplementation method of UIComponent with
     *  the UIComponentAccProps class.
     */
    private static function hookAccessibility():Boolean
    {
        UIComponent.createAccessibilityImplementation =
            createAccessibilityImplementation;

        return true;
    }

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Method for creating the Accessibility class.
     *  This method is called from UIComponent. 
     *  @review
     */
    mx_internal static function createAccessibilityImplementation(
                                            component:UIComponent):void
    {
        component.accessibilityProperties =
            new UIComponentAccProps(component);
    }
    
    /**
     *  Method call for enabling accessibility for a component.
     *  This method is required for the compiler to activate
     *  the accessibility classes for a component.
     */
    public static function enableAccessibility():void
    {
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param master The UIComponent instance that this
     *  AccessibilityProperties instance is making accessible.
     */
    public function UIComponentAccProps(component:UIComponent)
    {
        super();

        master = component;
        
        if (component.accessibilityProperties)
        {
            silent = component.accessibilityProperties.silent;
            
            forceSimple = component.accessibilityProperties.forceSimple;
            
            noAutoLabeling = component.accessibilityProperties.noAutoLabeling;
            
            if (component.accessibilityProperties.name)
                name = component.accessibilityProperties.name;
            
            if (component.accessibilityProperties.description)
                description = component.accessibilityProperties.description;
            
            if (component.accessibilityProperties.shortcut)
                shortcut = component.accessibilityProperties.shortcut;
        }
        
        if (master is ScrollBar)
        {
            silent = true;
        }
        else if (master is FormItemLabel)
        {
            name = AccImpl.getFormName(master);
            silent = true;
        }
        else
        {
            var formName:String = AccImpl.getFormName(master);

            if (formName && formName.length != 0)
                name = formName + name;  

            if (master.toolTip && master.toolTip.length != 0)
            {
                oldToolTip = " " + master.toolTip;
                name += oldToolTip;
            }

            if (master.errorString && master.errorString.length != 0)
            {
                oldErrorString = " " + master.errorString;
                name += oldErrorString;
            }

            master.addEventListener("toolTipChanged", eventHandler);
            master.addEventListener("errorStringChanged", eventHandler);
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var oldToolTip:String;
    
    /**
     *  @private
     */
    private var oldErrorString:String;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  master
    //----------------------------------

    /**
     *  A reference to the UIComponent itself.
     */
    protected var master:UIComponent;
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  Generic event handler.
     *  All UIComponentAccProps subclasses must implement this
     *  to listen for events from its master component. 
     */
    protected function eventHandler(event:Event):void
    {
        var pos:int;
        switch (event.type)
        {
            case "errorStringChanged":
            {
                if (name && name.length != 0 && oldErrorString)
                {
                    pos = name.indexOf(oldErrorString);
                    if (pos != -1)
                    {
                        name = name.substring(0, pos) +
                               name.substring(pos + oldErrorString.length);
                    }
                    oldErrorString = null;
                }

                if (master.errorString && master.errorString.length != 0)
                {
                    if (!name)
                        name = "";

                    oldErrorString = " " + master.errorString;
                    name += oldErrorString;
                }

                Accessibility.updateProperties();
            }

            case "toolTipChanged":
            {
                if (name && name.length != 0 && oldToolTip)
                {
                    pos = name.indexOf(oldToolTip);
                    if (pos != -1)
                    {
                        name = name.substring(0, pos) +
                               name.substring(pos + oldToolTip.length);
                    }
                    oldToolTip = null;
                }

                if (master.toolTip && master.toolTip.length != 0)
                {
                    if (!name)
                        name = "";

                    oldToolTip = " " + master.toolTip;
                    name += oldToolTip;
                }

                Accessibility.updateProperties();
            }
        }
    }
}

}
