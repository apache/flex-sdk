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

package mx.accessibility
{

import flash.accessibility.Accessibility;
import flash.accessibility.AccessibilityImplementation;
import flash.accessibility.AccessibilityProperties;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.system.ApplicationDomain;

import mx.core.IFlexModuleFactory;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.managers.ISystemManager;
import mx.resources.ResourceManager;
import mx.resources.IResourceManager;

use namespace mx_internal;

[ResourceBundle("controls")]

/**
 *  AccImpl is Flex's base accessibility implementation class
 *  for MX and Spark components.
 *
 *  <p>It is a subclass of the Flash Player's
 *  AccessibilityImplementation class.</p>
 *
 *  <p>When an MX or Spark component is created,
 *  its <code>accessibilityImplementation</code> property
 *  is set to an instance of a subclass of this class.
 *  The Flash Player then uses this object to allow MSAA clients
 *  such as screen readers to see and manipulate the component.
 *  See the flash.accessibility.AccessibilityImplementation class
 *  for additional information about accessibility implementation
 *  classes and MSAA.</p>
 *
 *  <p><b>Children</b></p>
 *
 *  <p>The Flash Player does not support
 *  a true hierarchy of accessible objects.
 *  If a DisplayObject has an <code>accessibilityImplementation</code> object,
 *  then the <code>accessibilityImplementation</code> objects
 *  of its children are ignored.
 *  However, the Player does allow a component's accessibility implementation class
 *  to expose MSAA information for its internal parts.
 *  (For example, a List exposes MSAA information about its items.)</p>
 *
 *  <p>The number of children (internal parts)
 *  and the child IDs used to identify them
 *  are determined by the <code>getChildIDArray()</code> method.
 *  In the Player's AccessibilityImplementation base class,
 *  this method simply returns <code>null</code>.
 *  Flex's AccImpl class overrides it to return an empty array.
 *  It also provides a protected utility method,
 *  <code>createChildIDArray()</code> which subclasses with internal parts
 *  can use in their overrides.</p>
 *
 *  <p><b>Role</b></p>
 *
 *  <p>The MSAA Role of a component and its internal parts
 *  is determined by the <code>get_accRole()</code> method.
 *  In the Player's AccessibilityImplementation base class,
 *  this method throws a runtime error,
 *  since subclasses are expected to override it.
 *  Flex's AccImpl class has a protected <code>role</code> property
 *  which subclasses generally set in their constructor,
 *  and it overrides <code>get_accRole()</code> to return this property.</p>
 *
 *  <p><b>Name</b></p>
 *
 *  <p>The MSAA Name of a component and its internal parts
 *  is determined by the <code>get_accName()</code> method.
 *  In the Player's AccessibilityImplementation base class,
 *  this method simply returns <code>null</code>.
 *  Flex's AccImpl class overrides it to construct a name as follows,
 *  starting with an empty string
 *  and separating added portions with a single space:
 *  <ul>
 *    <li>If a simple child (e.g., combo or list box item)
 *    is being requested, only the child's default name is returned.
 *    The rest of the steps below apply only to the component itself
 *   (childID 0).</li>
 *   <li>If the component is inside a Form: 
 *     <ul>
 *       <li>If the Form has a FormHeader, the header text is added.
 *       Developers wishing to avoid this should set the
 *       <code>accessibilityName</code> of the FormHeader
 *       to a space (" ").</li>
 *       <li>If the component is inside a FormItem,
 *       the FormItem label text is added.
 *       Developers wishing to avoid this should set the
 *       <code>accessibilityName</code> of the FormItem
 *       to a space (" ").</li>
 *       <li>If the field is required, the locale-dependent string
 *       "required field" is added.</li>
 *    </ul></li>
 *  <li>The component's name is then determined thus:
 *    <ul>
 *      <li>If the component's <code>accessibilityName</code>
 *      (i.e., <code>accessibilityProperties.name</code>) is a space,
 *      no component name is added.</li>
 *      <li>Otherwise, if the component's name is specified
 *      (i.e., is not null and not empty) then it is added.</li>
 *      <li>Otherwise, a protected <code>getName()</code> method,
 *      defined by AccImpl and implemented by each subclass,
 *      is called to provide a default name.
 *      (For example, ButtonAccImpl implements <code>getName()</code>
 *      to specify that a Button's default name is the label that it displays.)
 *      If not empty, the return value of <code>getName()</code> is added.</li>
 *      <li>Otherwise (if <code>getName()</code> returned empty),
 *      if the component's <code>toolTip</code> property is set,
 *      that String is added.</li>
 *      <li>If the component's <code>errorString</code> property is set,
 *      that String is added.</li>
 *    </ul></li>
 *  </ul></p>
 *
 *  <p><b>Description</b></p>
 *
 *  <p>The MSAA Description is determined solely by a component's
 *  <code>accessibilityProperties</code> object and not by its
 *  <code>accessibilityImplementation</code> object.
 *  Therefore there is no logic in AccessibilityImplementation or AccImpl
 *  or any subclasses of AccImpl related to the description.
 *  The normal way to set the description in Flex is via the
 *  <code>accessibilityDescription</code> property on UIComponent,
 *  which simply sets <code>accessibilityProperties.description</code>.</p>
 *
 *  <p><b>State</b></p>
 *
 *  <p>The MSAA State of a component and its internal parts
 *  is determined by the <code>get_accState()</code> method.
 *  In the Player's AccessibilityImplementation base class,
 *  this method throws a runtime error,
 *  since subclasses are expected to override it.
 *  Flex's AccImpl class does not override it,
 *  but provides a protected utility method, <code>getState()</code>,
 *  for subclasses to use in their overrides.
 *  The <code>getState()</code> method determines the state
 *  as a combination of
 *  <ul>
 *    <li>STATE_SYSTEM_UNAVAILABLE
 *    (when enabled is false on this component or any ancestor)</li>
 *    <li>STATE_SYSTEM_FOCUSABLE</li>
 *    <li>STATE_SYSTEM_FOCUSED (when focused)</li>
 *  </ul>
 *  Note that by default all components are assumed to be focusable
 *  and thus the accessibility implementation classes for non-focusable
 *  components like Label must clear this state flag.
 *  When a component has a state of unavailable,
 *  the focusable state is removed by the accessibility implementation class.</p>
 *
 *  <p><b>Value</b></p>
 *
 *  <p>The MSAA Value of a component and its internal parts
 *  is determined by the <code>get_accValue()</code> method.
 *  In the Player's AccessibilityImplementation base class,
 *  this method simply returns <code>null</code>.
 *  Flex's AccImpl class does not override it,
 *  but subclasses for components like TextInput do.</p>
 *
 *  <p><b>Location</b></p>
 *
 *  <p>The MSAA Location for a component's internal parts,
 *  but not the component itself,
 *  is determined by the <code>get_accLocation()</code> method.
 *  This method is never called with a childID of 0;
 *  instead, the Flash Player determines the MSAA Location of a component
 *  based on its bounding rectangle as determined by <code>getBounds()</code>.
 *  Flex's AccImpl class does not override this method,
 *  but subclasses for components with internal parts do.</p>
 *
 *  <p><b>Default Action</b></p>
 *
 *  <p>The MSAA DefaultAction for a component and its internal parts
 *  is determined by the <code>get_accDefaultAction()</code> method.
 *  In the Player's AccessibilityImplementation base class,
 *  this method simply returns <code>null</code>.
 *  Flex's AccImpl class does not override it,
 *  but subclasses with default actions do.
 *  These subclasses also override AccessibilityImplementation's
 *  <code>accDoDefaultAction()</code> method
 *  to perform the default action that they advertise.</p>
 *
 *  <p><b>Other</b></p>
 *
 *  <p>The MSAA events EVENT_OBJECT_SHOW and EVENT_OBJECT_HIDE
 *  are sent when the object is shown or hidden.
 *  The corresponding states for these are covered by the Flash Player
 *  which does not render any MSAA components that are hidden.
 *  When the component is shown the states mentioned for AccImpl
 *  are used.</p>
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */ 
public class AccImpl extends AccessibilityImplementation
{
    include "../core/Version.as";
        
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  
     *  Get the definition of a class, namespace, or function. The defintion is
     *  obtained from the specified moduleFactory. If there is no moduleFactory,
     *  then the definition of looked up in ApplicationDomain.currentDomain.
     * 
     *  @param name name of the class, namespace, or function to get.
     *  @param moduleFactory The moduleFactory that specifies the application 
     *  domain to use to find the name. If moduleFactory is null, then
     *  ApplicationDomain.currentDomain is used as a fall back.
     * 
     *  return a class, namespace, or function. 
     * 
     */ 
    mx_internal static function getDefinition(name:String, moduleFactory:IFlexModuleFactory):Object
    {
        var currentDomain:ApplicationDomain;
        
        // Use the given module factory to look for the domain. If the module 
        // factory is null then fall back to Application.currentDomain.
        if (moduleFactory)
            currentDomain = moduleFactory.info()["currentDomain"];
        else
            currentDomain = ApplicationDomain.currentDomain;

        if (currentDomain.hasDefinition(name))
            return currentDomain.getDefinition(name);
        
        return null;
    }
    
    /**
     *  Method for supporting state Accessibility.
     *  Returns true if an ancestor of the component has enabled set to false.
     */
    public static function isAncestorDisabled(component:UIComponent):Boolean
    {
        // keeping this DisplayObjectContainer since parent returns
        // that as root is not a UIComponent.
        var par:DisplayObjectContainer = component.parent; 

        // continue looking up the parent chain
        // until a disabled UIComponent is found
        // stopping at the root or system manager
        while (par && (par is UIComponent && UIComponent(par).enabled) &&
               !(par is ISystemManager) && par != component.root)
        {
            par = par.parent;
        }

        if (!(par is UIComponent))
            return false;
            
        return !UIComponent(par).enabled;
    }
    
    /**
     *  Method for supporting Form Accessibility.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function getFormName(component:UIComponent):String
    {
        var formName:String = "";
        
        // Return nothing if we are a container 
        var containerClass:Class = Class(getDefinition("mx.core.Container", component.moduleFactory));
        if (containerClass && component is containerClass)
            return formName;

        // keeping this DisplayObjectContainer since parent returns
        // that as root is not a UIComponent.
        var formItemClass:Class = Class(getDefinition("mx.containers.FormItem", component.moduleFactory));
        var par:DisplayObjectContainer = component.parent; 

        // continue looking up the parent chain
        // until a FormItem is found
        // stopping at the root or system manager
        while (par && !(formItemClass && par is formItemClass) &&
               !(par is ISystemManager) && par != component.root)
        {
            par = par.parent;
        }

        if (par && formItemClass && par is formItemClass)
            formName = updateFormItemString(par);

        return formName;
    }
    
    /**
     *  @private
     *  Method for supporting Form Accessibility.
     */
    private static function joinWithSpace(s1:String,s2:String):String
    {
        // Single space treated as null so developers can override default name elements with " ".
        if (s1 == " ")
            s1 = "";
        if (s2 == " ")
            s2 = "";
        if (s1 && s2)
            s1 += " " +s2;
        else if (s2)
            s1 = s2;
        // else we have non-empty s1 and empty s2, so do nothing.
        return s1;
    }

    /**
     *  @private
     *  Method for supporting Form Accessibility.
     * 
     *  @param formItem Object of type FormItem. Object is used here to avoid
     *  linking in FormItem. 
     */
    private static function updateFormItemString(formItem:Object):String
    {
        var formName:String = "";
        var resourceManager:IResourceManager = ResourceManager.getInstance();
        
        var formClass:Class = Class(getDefinition("mx.containers.Form", formItem.moduleFactory));
        var form:UIComponent = UIComponent(formItem.parent);

        // If we are located within a Form, then look for the first FormHeading
        // that is a sibling that is above us in the parent's child hierarchy
        if (formClass && form is formClass)
        {
            var formHeadingClass:Class = Class(getDefinition("mx.containers.FormHeading", formItem.moduleFactory));
            var formItemIndex:int = form.getChildIndex(DisplayObject(formItem));
            for (var i:int = formItemIndex; i >= 0; i--)
            {
                var child:UIComponent = UIComponent(form.getChildAt(i));
                if (formHeadingClass && child is formHeadingClass)
                {
                    // Accessible name if it exists, else label text.
                    if (formHeadingClass(child).accessibilityProperties)
                        formName = 
                            formHeadingClass(child).accessibilityProperties.name;
                    if (formName == "") 
                        formName = formHeadingClass(child).label;
                    break;
                }
            }
        }

        // Add in "Required Field" text if we are a required field
        if (formItem.required)
            formName = joinWithSpace(formName,
                resourceManager.getString("controls","requiredField"))

        // Add in the label from the formItem
        // Accessible name if it exists, else label text.
        var f:String = "";
        if (formItem.accessibilityProperties)
        {
            f = formItem.accessibilityProperties.name
            // TODO (gosmith) The purpose of the following two lines is to
            // make the FormItem "silent" so that its MSAA Name doesn't get
            // spoken. It doesn't need to be spoken since the Name of each
            // control inside the FormItem includes the FormItem's Name.
            // However, they seem to cause SDK-25042 and other problems.
            // Apparently, setting accessibilityProperties.silent to true
            // can make the accessibility models of JAWS and the Player
            // get out of sync, causing problems with child counts,
            // disabling virtual cursor mode in JAWS, and even causing
            // the Player to crash when JAWS asks for an object
            // that the Player thinks is no longer accessible.
            // Since we need a last-minute safe fix for these problems
            // I'm commenting these lines out.
//          if (formItem.itemLabel && formItem.itemLabel.accessibilityEnabled)
//              formItem.itemLabel.accessibilityEnabled = false;
        }
        if (f == "")
            f = formItem.label;
            
        formName = joinWithSpace(formName, f);

        return formName;
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function AccImpl(master:UIComponent)
    {
        super();

        this.master = master;
        
        stub = false;
        
        // Hook in UIComponentAccProps setup here!
        if (!master.accessibilityProperties)
        master.accessibilityProperties = new AccessibilityProperties();
        
        // Hookup events to listen for
        var events:Array = eventsToHandle;
        if (events)
        {
            var n:int = events.length;
            for (var i:int = 0; i < n; i++)
            {
                master.addEventListener(events[i], eventHandler);
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  A reference to the UIComponent instance that this AccImpl instance
     *  is making accessible.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var master:UIComponent;
    
    /**
     *  Accessibility role of the component being made accessible.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var role:uint;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  All subclasses must override this function by returning an array
     *  of strings of the events to listen for.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function get eventsToHandle():Array
    {
        return [ "errorStringChanged", "toolTipChanged", "show", "hide" ];
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: AccessibilityImplementation
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Returns the system role for the component.
     *
     *  @param childID uint.
     *
     *  @return Role associated with the component.
     *
     *  @tiptext Returns the system role for the component
     *  @helpid 3000
     */
    override public function get_accRole(childID:uint):uint
    {
        return role;
    }
    
    /**
     *  @private
     *  Returns the name of the component.
     *
     *  @param childID uint.
     *
     *  @return Name of the component.
     *
     *  @tiptext Returns the name of the component
     *  @helpid 3000
     */
    override public function get_accName(childID:uint):String
    {
        var accName:String;

        // For simple children, do not include anything but the default name.
        // Examples: combo box items, list items, etc.
        if (childID)
        {
            accName = getName(childID);
            // Historical: Return null and not "" for empty and null values.
            return (accName != null && accName != "") ? accName : null;
        }

        // Start with form header and/or formItem label text.
        // Also includes "Required Field" where appropriate.
        accName = getFormName(master);

        // Now the component's name or toolTip.
        if (master.accessibilityProperties && 
            master.accessibilityProperties.name != null && 
            master.accessibilityProperties.name != "")
        {
            // An accName is set, so use only that.
            accName = joinWithSpace(accName, master.accessibilityProperties.name);
        }
        else
        {
            // No accName set; use default name, or toolTip if that is empty.
            accName = joinWithSpace(accName, getName(0) || master.toolTip);
        }

        accName = joinWithSpace(accName, getStatusName());
        
        // Historical: Return null and not "" for empty and null values.
        return (accName != null && accName != "") ? accName : null;
    }
    
    /**
     *  @private
     *  Method to return an array of childIDs.
     *
     *  @return Array
     */
    override public function getChildIDArray():Array
    {
        return [];
    }
    
    /**
     *  @private
     *  IAccessible method for giving focus to a child item in the component
     *  (but not to the component itself; accSelect() is never called
     *  with a childID of 0).
     *  Even though this method does nothing, without it the Player
     *  causes an IAccessible "Member not found" error.
     */
    override public function accSelect(selFlag:uint, childID:uint):void
    {
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Returns the name of the accessible component.
     *  All subclasses must implement this
     *  instead of implementing get_accName().
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function getName(childID:uint):String
    {
        return null;
    }
    
    /**
     *  Utility method to determine state of the accessible component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function getState(childID:uint):uint
    {
        var accState:uint = AccConst.STATE_SYSTEM_NORMAL;
        
        if (!UIComponent(master).enabled || isAncestorDisabled(master))
        {
            accState &= ~AccConst.STATE_SYSTEM_FOCUSABLE;
            accState |= AccConst.STATE_SYSTEM_UNAVAILABLE;
        }
        else
        {
            accState |= AccConst.STATE_SYSTEM_FOCUSABLE
        
            if (UIComponent(master) == UIComponent(master).getFocus())
                accState |= AccConst.STATE_SYSTEM_FOCUSED;
        }

        return accState;
    }

    /**
     *  @private
     */
    private function getStatusName():String
    {
        var statusName:String = "";
        
        if (master is UIComponent && UIComponent(master).errorString)
            statusName = UIComponent(master).errorString;
        
        return statusName;
    }
    
    /**
     *  @private
     */
    protected function createChildIDArray(n:int):Array
    {
        var a:Array = new Array(n);
        
        for (var i:int = 0; i < n; i++)
        {
            a[i] = i + 1;
        }
        
        return a;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  Generic event handler.
     *  All AccImpl subclasses must implement this
     *  to listen for events from its master component. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function eventHandler(event:Event):void
    {
        $eventHandler(event);
    }

    /**
     *  @private
     *  Handles events common to all accessible UIComponents.
     */
    protected final function $eventHandler(event:Event):void
    {
        switch (event.type)
        {
            case "errorStringChanged":
            case "toolTipChanged":
            {
                Accessibility.sendEvent(master, 0,
                                        AccConst.EVENT_OBJECT_NAMECHANGE);
                Accessibility.updateProperties();
                break;
            }

            case "show":
            {
                Accessibility.sendEvent(master, 0,
                                        AccConst.EVENT_OBJECT_SHOW);
                Accessibility.updateProperties();
                break;
            }

            case "hide":
            {
                Accessibility.sendEvent(master, 0,
                                        AccConst.EVENT_OBJECT_HIDE);
                Accessibility.updateProperties();
                break;
            }            
        }
    }
}

}
