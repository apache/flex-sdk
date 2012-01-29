////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{

import flash.display.FocusDirection;
import flash.events.Event;
import flash.html.HTMLLoader;
import mx.managers.IFocusManagerComplexComponent
import mx.utils.NameUtil;

/**
 *  FlexHTMLLoader is a subclass of the Player's HTMLLoader class used by the
 *  Flex HTML control.
 *  It overrides the <code>toString()</code> method
 *  to return a string indicating the location of the object
 *  within the hierarchy of DisplayObjects in the application.
 * 
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class FlexHTMLLoader extends HTMLLoader implements IFocusManagerComplexComponent
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  <p>Sets the <code>name</code> property to a string
     *  returned by the <code>createUniqueName()</code>
     *  method of the mx.utils.NameUtils class.</p>
     *
     *  <p>This string is the name of the object's class concatenated
     *  with an integer that is unique within the application,
     *  such as <code>"FlexLoader13"</code>.</p>
     *
     *  @see flash.display.DisplayObject#name
     *  @see mx.utils.NameUtils#createUniqueName()
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function FlexHTMLLoader()
    {
        super();

        try
        {
            name = NameUtil.createUniqueName(this);
        }
        catch(e:Error)
        {
            // The name assignment above can cause the RTE
            //   Error #2078: The name property of a Timeline-placed
            //   object cannot be modified.
            // if this class has been associated with an asset
            // that was created in the Flash authoring tool.
            // The only known case where this is a problem is when
            // an asset has another asset PlaceObject'd onto it and
            // both are embedded separately into a Flex application.
            // In this case, we ignore the error and toString() will
            // use the name assigned in the Flash authoring tool.
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  focusEnabled
    //----------------------------------

    /**
     *  @private
     */
    private var _focusEnabled:Boolean = true;

    /**
     *  A flag that indicates whether the component can receive focus when selected.
     *
     *  <p>As an optimization, if a child component in your component
     *  implements the IFocusManagerComponent interface, and you
     *  never want it to receive focus,
     *  you can set <code>focusEnabled</code>
     *  to <code>false</code> before calling <code>addChild()</code>
     *  on the child component.</p>
     *
     *  <p>This will cause the FocusManager to ignore this component
     *  and not monitor it for changes to the <code>tabFocusEnabled</code>,
     *  <code>tabChildren</code>, and <code>mouseFocusEnabled</code> properties.
     *  This also means you cannot change this value after
     *  <code>addChild()</code> and expect the FocusManager to notice.</p>
     *
     *  <p>Note: It does not mean that you cannot give this object focus
     *  programmatically in your <code>setFocus()</code> method;
     *  it just tells the FocusManager to ignore this IFocusManagerComponent
     *  component in the Tab and mouse searches.</p>
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get focusEnabled():Boolean
    {
        return _focusEnabled;
    }

    /**
     *  @private
     */
    public function set focusEnabled(value:Boolean):void
    {
        _focusEnabled = value;
    }

    //----------------------------------
    //  hasFocusableChildren
    //----------------------------------

    /**
     *  @private
     *  Storage for the hasFocusableChildren property.
     */
    private var _hasFocusableChildren:Boolean = false;

    [Bindable("hasFocusableChildrenChange")]
    [Inspectable(defaultValue="true")]

    /**
     *  A flag that indicates whether child objects can receive focus
     * 
     *  <p>This is similar to the <code>tabChildren</code> property
     *  used by the Flash Player.</p>
     * 
     *  <p>This is usually <code>false</code> because most components
     *  either receive focus themselves or delegate focus to a single
     *  internal sub-component and appear as if the component has
     *  received focus.  For example, a TextInput contains a focusable
     *  child RichEditableText control, but while the RichEditableText
     *  sub-component actually receives focus, it appears as if the
     *  TextInput has focus.  TextInput sets <code>hasFocusableChildren</code>
     *  to <code>false</code> because TextInput is considered the
     *  component that has focus.  Its internal structure is an
     *  abstraction.</p>
     *
     *  <p>Usually only navigator components like TabNavigator and
     *  Accordion have this flag set to <code>true</code> because they
     *  receive focus on Tab but focus goes to components in the child
     *  containers on further Tabs</p>
     *  
     *  @default false
     *  
     *  @langversion 4.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get hasFocusableChildren():Boolean
    {
        return _hasFocusableChildren;
    }

    /**
     *  @private
     */
    public function set hasFocusableChildren(value:Boolean):void
    {
        if (value != _hasFocusableChildren)
        {
            _hasFocusableChildren = value;
            dispatchEvent(new Event("hasFocusableChildrenChange"));
        }
    }

    //----------------------------------
    //  mouseFocusEnabled
    //----------------------------------

    /**
     *  @private
     *  Storage for the mouseFocusEnabled property.
     */
    private var _mouseFocusEnabled:Boolean = true;

    [Inspectable(defaultValue="true")]

    /**
     *  Whether the component can receive focus when clicked on.
     *  If <code>false</code>, focus will be transferred to
     *  the first parent that is <code>mouseFocusEnable</code>
     *  set to <code>true</code>.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get mouseFocusEnabled():Boolean
    {
        return _mouseFocusEnabled;
    }

    /**
     *  @private
     */
    public function set mouseFocusEnabled(value:Boolean):void
    {
        _mouseFocusEnabled =  value;
    }


    //----------------------------------
    //  tabFocusEnabled
    //----------------------------------

    /**
     *  @private
     *  Storage for the tabFocusEnabled property.
     */
    private var _tabFocusEnabled:Boolean = true;

    [Bindable("tabFocusEnabledChange")]
    [Inspectable(defaultValue="true")]

    /**
     *  A flag that indicates whether child objects can receive focus
     * 
     *  <p>This is similar to the <code>tabEnabled</code> property
     *  used by the Flash Player.</p>
     * 
     *  <p>This is usually <code>true</code> for components that
     *  handle keyboard input, but some components in controlbars
     *  have them set to <code>false</code> because they should not steal
     *  focus from another component like an editor.
     *  </p>
     *
     *  @default true
     *  
     *  @langversion 4.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get tabFocusEnabled():Boolean
    {
        return _tabFocusEnabled;
    }

    /**
     *  @private
     */
    public function set tabFocusEnabled(value:Boolean):void
    {
        if (value != _tabFocusEnabled)
        {
            _tabFocusEnabled = value;
            dispatchEvent(new Event("tabFocusEnabledChange"));
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Called by the FocusManager when the component receives focus.
     *  The component may in turn set focus to an internal component.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function setFocus():void
    {
        stage.focus = this;
    }

    /**
     *  Called by the FocusManager when the component receives focus.
     *  The component should draw or hide a graphic
     *  that indicates that the component has focus.
     *
     *  @param isFocused If <code>true</code>, draw the focus indicator,
     *  otherwise hide it.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function drawFocus(isFocused:Boolean):void
    {
    }

    /**
     *  Called by the FocusManager when the component receives focus.
     *  The component may in turn set focus to an internal component.
     *  The component's <code>setFocus()</code> method will still be called when focused by
     *  the mouse, but this method will be used when focus changes via the
     *  keyboard.
     *
     *  @param direction one of flash.display.FocusDirection
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function assignFocus(direction:String):void
    {
        stage.assignFocus(this, direction);
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Returns a string indicating the location of this object
     *  within the hierarchy of DisplayObjects in the Application.
     *  This string, such as <code>"MyApp0.HBox5.FlexLoader13"</code>,
     *  is built by the <code>displayObjectToString()</code> method
     *  of the mx.utils.NameUtils class from the <code>name</code>
     *  property of the object and its ancestors.
     *
     *  @return A String indicating the location of this object
     *  within the DisplayObject hierarchy.
     *
     *  @see flash.display.DisplayObject#name
     *  @see mx.utils.NameUtils#displayObjectToString()
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function toString():String
    {
        return NameUtil.displayObjectToString(this);
    }
}

}
