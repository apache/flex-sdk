////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.components
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.EventDispatcher;
import mx.core.ApplicationGlobals;
import mx.core.IFlexDisplayObject;
import mx.core.IMXMLObject;
import mx.core.IRawChildrenContainer;
import mx.core.mx_internal;
import mx.core.UIComponent;
import mx.events.FlexEvent;
import mx.events.ItemClickEvent;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the value of the selected FxRadioButton control in
 *  this group changes.
 *
 *  @eventType flash.events.Event.CHANGE
 */
[Event(name="change", type="flash.events.Event")]

/**
 *  Dispatched when a user selects a FxRadioButton control in the group.
 *  You can also set a handler for individual FxRadioButton controls.
 *
 *  @eventType mx.events.ItemClickEvent.ITEM_CLICK
 */
[Event(name="itemClick", type="mx.events.ItemClickEvent")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("FxRadioButtonGroup.png")]

/**
 *  The FxRadioButtonGroup control defines a group of FxRadioButton controls
 *  that act as a single mutually exclusive control; therefore,
 *  a user can select only one  control at a time.
 *  The <code>id</code> property is required when you use the
 *  <code>&lt;mx:FxRadioButtonGroup&gt;</code> tag to define the name
 *  of the group.
 *
 *  <p>Notice that the FxRadioButtonGroup control is a subclass of EventDispatcher,
 *  not UIComponent, and implements the IMXMLObject interface.
 *  All other Flex visual components are subclasses of UIComponent, which implements
 *  the IUIComponent interface.
 *  The FxRadioButtonGroup control has support built into the Flex compiler
 *  that allows you to use the FxRadioButtonGroup control as a child of a Flex
 *  container, even though it does not implement IUIComponent.
 *  All other container children must implement the IUIComponent interface.</p>
 *
 *  <p>Therefore, if you try to define a visual component as a subclass of
 *  EventDispatcher that implements the IMXMLObject interface,
 *  you will not be able to use it as the child of a container.</p>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mx:Group&gt;</code> tag inherits all of the
 *  tag attributes of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:FxRadioButtonGroup
 *    <strong>Properties</strong>
 *    enabled="true|false"
 *    id="<i>No default</i>"
 *
 *    <strong>Events</strong>
 *    change="<i>No default</i>"
 *    itemClick="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *
 *  @see mx.components.FxRadioButtonGroup
 */
public class FxRadioButtonGroup extends EventDispatcher implements IMXMLObject
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
     *  @param document In simple cases where a class extends EventDispatcher,
     *  the <code>document</code> parameter should not be used.
     *
     *  @see flash.events.EventDispatcher
     */
    public function FxRadioButtonGroup(document:IFlexDisplayObject = null)
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  The document containing a reference to this FxRadioButtonGroup.
     */
    private var document:IFlexDisplayObject;

    /**
     *  @private
     *  An Array of the FxRadioButtons that belong to this group.
     */
    private var radioButtons:Array /* of FxRadioButton */ = [];

    /**
     *  @private
     *  Whether the group is enabled.  This can be different than the individual
     *  radio buttons in the group.
     */
    private var _enabled:Boolean = true;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  enabled
    //----------------------------------

    [Bindable("enabledChanged")]
    [Inspectable(category="General", defaultValue="true")]

    /**
     *  Determines whether selection is allowed.
     *
     *  @default true
     */
    public function get enabled():Boolean
    {
        return _enabled;
    }

    /**
     *  @private
     */
    public function set enabled(value:Boolean):void
    {
        if (_enabled == value)
            return;

        _enabled = value;

        // The group state changed.  Invalidate all the radio buttons.  The
        // radio button skin most likely will change.
        for (var i:int = 0; i < numRadioButtons; i++)
            getRadioButtonAt(i).mx_internal::invalidateRadioButtonState(true);

        dispatchEvent(new Event("enabledChanged"));
    }

    //----------------------------------
    //  numRadioButtons
    //----------------------------------

    [Bindable("numRadioButtonsChanged")]

    /**
     *  The number of FxRadioButtons that belong to this FxRadioButtonGroup.
     *
     *  @default "0"
     */
    public function get numRadioButtons():int
    {
        return radioButtons.length;
    }

    //----------------------------------
    //  selectedValue
    //----------------------------------

    /**
     *  @private
     *  Storage for the selectedValue property.
     */
    private var _selectedValue:Object;

    [Bindable("change")]
    [Bindable("valueCommit")]
    [Inspectable(category="General")]

    /**
     *  The value of the <code>value</code> property of the selected
     *  FxRadioButton control in the group, if this has been set
     *  to be something other than <code>null</code> (the default value).
     *  Otherwise, <code>selectedValue</code> is the value of the
     *  <code>label</code> property of the selected FxRadioButton.
     *  If no FxRadioButton is selected, this property is <code>null</code>.
     *
     *  <p>If you set <code>selectedValue</code>, Flex selects the
     *  FxRadioButton control whose <code>value</code> or
     *  <code>label</code> property matches this value.</p>
     *
     *  @default null
     */
    public function get selectedValue():Object
    {
        if (selection)
        {
            return selection.value != null ?
                   selection.value :
                   selection.label;
        }

        return null;
    }

    /**
     *  @private.
     */
    public function set selectedValue(value:Object):void
    {
        _selectedValue = value;

        var n:int = numRadioButtons;
        for (var i:int = 0; i < n; i++)
        {
            var radioButton:FxRadioButton = getRadioButtonAt(i);
            if (radioButton.value == value ||
                radioButton.label == value)
            {
                changeSelection(i, false);
                break;
            }
        }

        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }

    //----------------------------------
    //  selection
    //----------------------------------

    /**
     *  @private
     *  Reference to the selected radio button.
     */
    private var _selection:FxRadioButton;

    [Bindable("change")]
    [Bindable("valueCommit")]
    [Inspectable(category="General")]

    /**
     *  Contains a reference to the currently selected
     *  FxRadioButton control in the group.
     *  You can access the property in ActionScript only;
     *  it is not settable in MXML.
     *  Setting this property to <code>null</code> deselects the currently
     *  selected FxRadioButton control.  A change event is not dispatched.
     *
     *  @default null
     */
    public function get selection():FxRadioButton
    {
        return _selection;
    }

    /**
     *  @private
     */
    public function set selection(value:FxRadioButton):void
    {
        // Going through the selection setter should never fire a change event.
        mx_internal::setSelection(value, false);
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Implementation of the <code>IMXMLObject.initialized()</code> method
     *  to support deferred instantiation.
     *
     *  @param document The MXML document that created this object.
     *
     *  @param id The identifier used by document to refer to this object.
     *  If the object is a deep property on document, <code>id</code> is null.
     *
     *  @see mx.core.IMXMLObject
     */
    public function initialized(document:Object, id:String):void
    {
        this.document = document ?
                        IFlexDisplayObject(document) :
                        IFlexDisplayObject(ApplicationGlobals.application);
    }

    /**
     *  Returns the  control at the specified index.
     *
     *  @param index The index of the  control in the
     *  FxRadioButtonGroup control, where the index of the first control is 0.
     *
     *  @return The specified FxRadioButton control if index between
     *  0 and numRadioButtons, otherwise null.
     * 
     *  @see numRadioButtons
     */
    public function getRadioButtonAt(index:int):FxRadioButton
    {
        if (index >= 0 && index < numRadioButtons)
            return radioButtons[index];
            
        return null;
    }

    /**
     *  @private
     *  Add a radio button to the group.  This can be called by
     *  FxRadioButton or via the addedHandler when applying a state.
     */
    mx_internal function addInstance(instance:FxRadioButton):void
    {
        // During a state transition, called when rb is removed from 
        // display list.
        instance.addEventListener(Event.REMOVED, radioButton_removedHandler);
        
        radioButtons.push(instance);

        // Apply group indices in "breadth-first" order.
        radioButtons.sort(breadthOrderCompare);
        for (var i:int = 0; i < radioButtons.length; i++)
            radioButtons[i].mx_internal::indexNumber = i;
        
        // If this radio button is selected, then it becomes the selection
        // for the group.
        if (instance.selected == true)
            selection = instance;

        instance.mx_internal::radioButtonGroup = this;
        instance.mx_internal::invalidateRadioButtonState();
        
		dispatchEvent(new Event("numRadioButtonsChanged"));
    }

    /**
     *  @private
     *  Remove a radio button from the group.  This can be called by
     *  FxRadioButton or via the removedHandler when removing a state.
     */
    private function removeInstance(instance:FxRadioButton):void
    {
        if (instance)
        {
            var foundInstance:Boolean = false;
            for (var i:int = 0; i < numRadioButtons; i++)
            {
                var rb:FxRadioButton = getRadioButtonAt(i);

                if (foundInstance)
                {
                    // Decrement the indexNumber for each button after the removed button.
                    rb.mx_internal::indexNumber = rb.mx_internal::indexNumber - 1;
                }
                else if (rb == instance)
                {
                    // During a state transition, called when rb is added back 
                    // to display list.
                    instance.addEventListener(Event.ADDED, radioButton_addedHandler);
        
                    // Don't set the group to null.  If this is being removed
                    // because the state changed, the group will be needed
                    // if the radio button is readded later because of another
                    // state transition.
                	//rb.group = null;

                    // If the rb is selected, leave the button itself selected
                    // but clear the selection for the group.
                    if (instance == _selection)
                        _selection = null;

                    instance.mx_internal::radioButtonGroup = null;
                    instance.mx_internal::invalidateRadioButtonState();

                    // Remove the radio button from the internal array.
                    radioButtons.splice(i,1);
                    foundInstance = true;

                    // redo the same index because we removed the previous item at this index
                    i--;
                }
            }

            if (foundInstance)
				dispatchEvent(new Event("numRadioButtonsChanged"));
        }
    }

    /**
     *  @private
     */
    protected function getEnabled():Boolean
    {
        return _enabled;
    }

    /**
     *  @private
     *  Return the value or the label value
     *  of the selected radio button.
     */
    private function getValue():String
    {
        if (selection)
        {
            return selection.value &&
                   selection.value is String &&
                   String(selection.value).length != 0 ?
                   String(selection.value) :
                   selection.label;
        }
        else
        {
            return null;
        }
    }

    /**
     *  @private
     */
    mx_internal function setSelection(value:FxRadioButton, fireChange:Boolean = true):void
    {
        if (value == null && _selection != null)
        {
            _selection.selected = false;
            _selection = null;
            if (fireChange)
                dispatchEvent(new Event(Event.CHANGE));
        }
        else
        {
            var n:int = numRadioButtons;
            for (var i:int = 0; i < n; i++)
            {
                if (value == getRadioButtonAt(i))
                {
                    changeSelection(i, fireChange);
                    break;
                }
            }
        }

        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }

    /**
     *  @private
     */
    private function changeSelection(index:int, fireChange:Boolean = true):void
    {
        if (getRadioButtonAt(index))
        {
            // Unselect the currently selected radio
            if (selection)
                selection.selected = false;

            // Change the focus to the new radio.
            // Set the state of the new radio to true.
            // Fire a click event for the new radio.
            // Fire a click event for the radio group.
            _selection = getRadioButtonAt(index);
            _selection.selected = true;
            if (fireChange)
                dispatchEvent(new Event(Event.CHANGE));
        }
    }

    /**
     *  @private
     */
    private function breadthOrderCompare(a:DisplayObject, b:DisplayObject):Number
    {
        var aParent:DisplayObject = a.parent;
        var bParent:DisplayObject = b.parent;

        if (!aParent || !bParent)
            return 0;

        var aNestLevel:int = (a is UIComponent) ? UIComponent(a).nestLevel : -1;
        var bNestLevel:int = (b is UIComponent) ? UIComponent(b).nestLevel : -1;

        var aIndex:int = aParent is IRawChildrenContainer ?
            IRawChildrenContainer(aParent).rawChildren.getChildIndex(a) :
            DisplayObjectContainer(aParent).getChildIndex(a);

        var bIndex:int = bParent is IRawChildrenContainer ?
            IRawChildrenContainer(bParent).rawChildren.getChildIndex(b) :
            DisplayObjectContainer(bParent).getChildIndex(b);

        if (aNestLevel > bNestLevel || (a.parent == b.parent && aIndex > bIndex))
            return 1;
        else if (aNestLevel < bNestLevel ||  (a.parent == b.parent && bIndex > aIndex))
            return -1;
        else if (a == b)
            return 0;
        else // Nest levels are identical, compare ancestors.
            return breadthOrderCompare(aParent, bParent);
    }

    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
     /**
     *  @private
     */
    private function radioButton_addedHandler(event:Event):void
    {
        var rb:FxRadioButton = event.target as FxRadioButton;
        if (rb)
        {
            //trace("radioButton_addedHandler", rb.id);
            rb.removeEventListener(Event.ADDED, radioButton_addedHandler);
            mx_internal::addInstance(rb);
        }
    }

     /**
     *  @private
     */
    private function radioButton_removedHandler(event:Event):void
    {
        var rb:FxRadioButton = event.target as FxRadioButton;
        if (rb)
        {
            //trace("radioButton_removedHandler", rb.id);
        	rb.removeEventListener(Event.REMOVED, radioButton_removedHandler);
            removeInstance(rb);
        }
    }
}

}
