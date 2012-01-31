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
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import mx.core.IFlexDisplayObject;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.core.FlexVersion;
import mx.events.ItemClickEvent;
import mx.managers.IFocusManager;
import mx.managers.IFocusManagerGroup;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

//--------------------------------------
//  Excluded APIs
//--------------------------------------

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("FxRadioButton.png")]

/**
 *  The FxRadioButton control lets the user make a single choice
 *  within a set of mutually exclusive choices.
 *  A FxRadioButton group is composed of two or more FxRadioButton controls
 *  with the same <code>groupName</code> property.
 *  The FxRadioButton group can refer to a group created by the
 *  <code>&lt;mx:FxRadioButtonGroup&gt;</code> tag.
 *  The user selects only one member of the group at a time.
 *  Selecting an unselected group member deselects the currently selected
 *  FxRadioButton control within that group.
 *
 *  <p>The FxRadioButton control has the following default characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>Wide enough to display the text label of the control</td>
 *        </tr>
 *        <tr>
 *           <td>Minimum size</td>
 *           <td>0 pixels</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>Undefined</td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mx:FxRadioButton&gt;</code> tag inherits all of the tag
 *  attributes of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:FxRadioButton
 *    <strong>Properties</strong>
 *    groupName=""  
 *  /&gt;
 *  </pre>
 *
 *  @see mx.components.FxRadioButtonGroup
 */
public class FxRadioButton extends FxToggleButton implements IFocusManagerGroup
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function FxRadioButton()
    {
        super();

        // Button variables.
        
        // Start out in the default group.  The button is always in a group,
        // either explicitly or implicitly.
        groupName = "radioGroup"; 
        
        _buttonEnabled = enabled;           
    }
         
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Default inital index value
     */
    mx_internal var indexNumber:int = 0;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  group
    //----------------------------------

    /**
     *  @private
     *  Storage for the group property.
     */
    private var _group:FxRadioButtonGroup;

    /**
     *  The FxRadioButtonGroup object to which this FxRadioButton belongs.
     *
     *  @default "undefined"
     */
    public function get group():FxRadioButtonGroup
    {
        // Debugger asks too soon.
        if (!document)
            return _group;

        if (!_group)
        {
            // If using the default groupName, the button isn't added to the 
            // group until it is first accessed.
            if (groupName && groupName != "")
            {
                var g:FxRadioButtonGroup;
                try
                {
                    g = FxRadioButtonGroup(document[groupName]);
                }
                catch(e:Error)
                {
                    // Special automaticRadioButtonGroup slot to hold generated
                    // radio button groups.  Shared with halo so prefix
                    // groupName to differentiate.
                    if (document.automaticRadioButtonGroups &&
                        document.automaticRadioButtonGroups[autoGroupIndex])
                    {
                        g = FxRadioButtonGroup(
                            document.automaticRadioButtonGroups[autoGroupIndex]);
                    }
                }
                if (!g)
                {
                    g = new FxRadioButtonGroup(IFlexDisplayObject(document));
                    
                    if (!document.automaticRadioButtonGroups)
                        document.automaticRadioButtonGroups = [];
                    document.automaticRadioButtonGroups[autoGroupIndex] = g;                        
                }
                else if (!(g is FxRadioButtonGroup))
                {
                    return null;
                }

                _group = g;
            }
        }

        return _group;
    }

    /**
     *  @private
     */
    public function set group(value:FxRadioButtonGroup):void
    {
        if (_group == value)
            return;

        // If the button was in another group, remove it.
        removeFromGroup();    

        _group = value;
        
        // Make sure this gets added to it's FxRadioButtonGroup
        groupChanged = true;
        
        invalidateProperties();
        invalidateDisplayList();
    }

    //----------------------------------
    //  groupName
    //----------------------------------

    /**
     *  @private
     *  Storage for groupName property.
     */
    mx_internal var _groupName:String;

    /**
     *  @private
     */
    private var groupChanged:Boolean = false;

    [Bindable("groupNameChanged")]
    [Inspectable(category="General", defaultValue="radioGroup")]

    /**
     *  Specifies the name of the group to which this FxRadioButton control belongs, or 
     *  specifies the value of the <code>id</code> property of a FxRadioButtonGroup control
     *  if this FxRadioButton is part of a group defined by a FxRadioButtonGroup control.
     *
     *  @default "undefined"
     */
    public function get groupName():String
    {
        return _groupName;
    }
    
    /**
     *  @private
     */
    public function set groupName(value:String):void
    {
        // A groupName must be non-empty string.
        if (!value || value == "")
            return;

        // If the button was in another group, remove it, before changing the
        // groupName.
        removeFromGroup();            
   
        _groupName = value;
        
        // Make sure get group recalculates the group.
        _group = null;

        // Make sure this gets added to it's FxRadioButtonGroup
        groupChanged = true;
        
        invalidateProperties();
        invalidateDisplayList();

        dispatchEvent(new Event("groupNameChanged"));
    }

    //----------------------------------
    //  value
    //----------------------------------

    /**
     *  @private
     *  Storage for value property.
     */
    private var _value:Object;

    [Bindable("valueChanged")]
    [Inspectable(category="General", defaultValue="")]

    /**
     *  Optional user-defined value
     *  that is associated with a FxRadioButton control.
     * 
     *  @default null
     */
    public function get value():Object
    {
        return _value;
    }

    /**
     *  @private
     */
    public function set value(value:Object):void
    {
        _value = value;

        dispatchEvent(new Event("valueChanged"));
        if (selected && group)
            group.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Update properties before measurement/layout.
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (groupChanged)
        {
            addToGroup();
            groupChanged = false;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  automaticRadioButtonGroups is shared with halo radio button groups.
     *  Gumbo radio button groups are prefixed with _fx to differentiate the
     *  halo groups which are stored in the same table.
     */
    private function get autoGroupIndex():String
    {
        return "_fx_" + groupName;
    }

    /**
     *  @private
     *  Create radio button group if it does not exist
     *  and add the instance to the group.
     */
    private function addToGroup():FxRadioButtonGroup
    {        
        var g:FxRadioButtonGroup = group; // Trigger getting the group
        if (g)
        {
            g.addInstance(this);

            // If this button is selected, then change the group selection.            
            if (selected && g.selection != this)
                g.setSelection(this, false);

            // If this button is joining a disabled group, then disable the button.
            // Don't use the enabled setter so that _buttonEnabled remains untouched.
            setEnabled();           
        }
        
        return g;
    }

    /**
     *  @private
     */
    mx_internal function removeFromGroup():void
    {        
        // If the radio button was in a group, remove it.
        this.dispatchEvent(new Event(Event.REMOVED));
          
        // It's possible that the radio button was in the auto group.  If so,
        // delete the group if there are no other radio buttons still in it.
        // The radio button also could have been in an explicit FxRadioButtonGroup
        // specified via group or in a FxRadioButtonGroup that was in the document,
        // specified by groupName.
        try
        {
            if (document.automaticRadioButtonGroups[autoGroupIndex].numRadioButtons == 0)
            {
                delete document.automaticRadioButtonGroups[autoGroupIndex];
            }
        }
        catch(e:Error)
        {
        }
    }

    /**
     *  @private
     *  Set previous radio button in the group.
     */
    private function setPrev(moveSelection:Boolean = true):void
    {
        var g:FxRadioButtonGroup = group;

        var fm:IFocusManager = focusManager;
        if (fm)
            fm.showFocusIndicator = true;

        for (var i:int = 1; i <= indexNumber; i++)
        {
            var radioButton:FxRadioButton = g.getRadioButtonAt(indexNumber - i);
            if (radioButton && radioButton.enabled)
            {
                if (moveSelection)
                    g.setSelection(radioButton);
                radioButton.setFocus();
                return;
            }
        }

        if (moveSelection && g.getRadioButtonAt(indexNumber) != g.selection)
            g.setSelection(this);
        
        this.drawFocus(true);   
    }

    /**
     *  @private
     *  Set the next radio button in the group.
     */
    private function setNext(moveSelection:Boolean = true):void
    {
        var g:FxRadioButtonGroup = group;

        var fm:IFocusManager = focusManager;
        if (fm)
            fm.showFocusIndicator = true;

        for (var i:int = indexNumber + 1; i < g.numRadioButtons; i++)
        {
            var radioButton:FxRadioButton = g.getRadioButtonAt(i);
            if (radioButton && radioButton.enabled)
            {
                if (moveSelection)
                    g.setSelection(radioButton);
                radioButton.setFocus();
                return;
            }
        }

        if (moveSelection && g.getRadioButtonAt(indexNumber) != g.selection)
            g.setSelection(this);
        this.drawFocus(true);   
    }

    /**
     *  @private
     */
    private function setThis():void
    {
        if (!_group)
            addToGroup();

        var g:FxRadioButtonGroup = group;
        if (g.selection != this)
            g.setSelection(this);
    }


    /**
     *  @private
     *  Enable the component if the group it is enabled and the radio button
     *  itself is enabled. If the group is disabled the button is disabled.
     */
    mx_internal function setEnabled():void
    {
        if (_group && !_group.enabled)
        {
            super.enabled = false;
        }
        else
        {
            super.enabled = _buttonEnabled;
        }
        
        invalidateButtonState();
    }

    /**
     *  @private
     *  Storage for enabled property.  It must be merged with the FxRadionButtonGroup
     *  enabled property to determine if the button is enabled.
     */
    mx_internal var _buttonEnabled:Boolean;

    /**
     *  @private
     *  The radio button group and the radio button each have enabled properties.
     *  The underlying component is enabled if the group is enabled and the button
     *  itself is enabled.
     */
    override public function set enabled(value:Boolean):void
    {
        _buttonEnabled = value;
        setEnabled();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers: UIComponent
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Support the use of keyboard within the group.
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        if (!enabled)
            return;
            
        switch (event.keyCode)
        {
            case Keyboard.DOWN:
            {
                setNext(!event.ctrlKey);
                event.stopPropagation();
                break;
            }

            case Keyboard.UP:
            {
                setPrev(!event.ctrlKey);
                event.stopPropagation();
                break;
            }

            case Keyboard.LEFT:
            {
                setPrev(!event.ctrlKey);
                event.stopPropagation();
                break;
            }

            case Keyboard.RIGHT:
            {
                setNext(!event.ctrlKey);
                event.stopPropagation();
                break;
            }

            case Keyboard.SPACE:
            {
                setThis();
                //fall through, no break
            }

            default:
            {
                super.keyDownHandler(event);
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers: Button
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Set radio button to selected and dispatch that there has been a change.
     */
    override protected function onClick(event:MouseEvent):void
    {
        if (!enabled || selected)
            return; // prevent a selected button from dispatching "click"

        if (!_group)
            addToGroup();

        // Must call super.clickHandler() before setting
        // the group's selection.
        super.onClick(event);

        group.setSelection(this);

        // Dispatch an itemClick event from the FxRadioButtonGroup.
        var itemClickEvent:ItemClickEvent =
            new ItemClickEvent(ItemClickEvent.ITEM_CLICK);
        itemClickEvent.label = label;
        itemClickEvent.index = indexNumber;
        itemClickEvent.relatedObject = this;
        itemClickEvent.item = value;
        group.dispatchEvent(itemClickEvent);
    }
}

}
