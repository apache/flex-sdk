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

package spark.components
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import spark.components.supportClasses.ToggleButtonBase;
import mx.core.IFlexDisplayObject;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.ItemClickEvent;
import mx.managers.IFocusManager;
import mx.managers.IFocusManagerGroup;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  @copy spark.components.supportClasses.GroupBase#style:symbolColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("RadioButton.png")]



/**
 *  The RadioButton control lets the user make a single choice
 *  within a set of mutually exclusive choices.
 *  A RadioButton group is composed of two or more RadioButton controls
 *  with the same <code>groupName</code> property.
 *  While grouping RadioButton instances in a RadioButtonGroup is optional,
 *  a group lets you do things like set a single event handler on a group of buttons,
 *  rather than on each individual button.
 *
 *  <p>The RadioButton group can refer to a group created by the
 *  <code>&lt;s:RadioButtonGroup&gt;</code> tag.
 *  The user selects only one member of the group at a time.
 *  Selecting an unselected group member deselects the currently selected
 *  RadioButton control within that group.</p>
 *
 *  <p>The RadioButton control has the following default characteristics:</p>
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
 *           <td>18 pixels wide and 18 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>10000 pixels wide and 10000 pixels high</td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:RadioButton&gt;</code> tag inherits all of the tag
 *  attributes of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:RadioButton
 *    <strong>Properties</strong>
 *    group=""
 *    groupName="RadioButtonGroup_<i>n</i>"
 *    selected=""
 *    value="null"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.components.RadioButtonGroup
 *  @see spark.components.RadioButtonGroup
 *  @see spark.skins.spark.RadioButtonSkin
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class RadioButton extends ToggleButtonBase implements IFocusManagerGroup
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
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function RadioButton()
    {
        super();

        // Button variables.
        
        // Start out in the default group.  The button is always in a group,
        // either explicitly or implicitly.
        groupName = "radioGroup";
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
    
    /**
     *  @private
     *  The RadioButtonGroup that this radio button is in.  The group property
     *  should not be used to keep track of the radio button group for this radio
     *  button.  During state transitions, the radio button may come
     *  and go from the group and the group property is not reset.  The group
     *  property, if initially set, is needed when the radio button is readded
     *  to the group.
     */
    mx_internal var radioButtonGroup:RadioButtonGroup = null;
     
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
    private var _group:RadioButtonGroup;

    /**
     *  The RadioButtonGroup object to which this RadioButton belongs.
     *  When creating radio buttons to put in a RadioButtonGroup, it is 
     *  advisable to use either the <code>group</code> property 
     *  or the <code>groupName</code> property for all of 
     *  the buttons.  The <code>groupName</code> property will be set 
     *  to the generated name of the 
     *  RadioButtonGroup object.
     *  
     *  @default the default RadioButtonGroup
     *  @see #groupName
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get group():RadioButtonGroup
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
                var g:RadioButtonGroup;
                try
                {
                    g = RadioButtonGroup(document[groupName]);
                }
                catch(e:Error)
                {
                    // Special automaticRadioButtonGroup slot to hold generated
                    // radio button groups.  Shared with halo so prefix
                    // groupName to differentiate.
                    if (document.automaticRadioButtonGroups &&
                        document.automaticRadioButtonGroups[autoGroupIndex])
                    {
                        g = RadioButtonGroup(
                            document.automaticRadioButtonGroups[autoGroupIndex]);
                    }
                }
                if (!g)
                {
                    g = new RadioButtonGroup(IFlexDisplayObject(document));
                    
                    if (!document.automaticRadioButtonGroups)
                        document.automaticRadioButtonGroups = [];
                    document.automaticRadioButtonGroups[autoGroupIndex] = g;                        
                }
                else if (!(g is RadioButtonGroup))
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
    public function set group(value:RadioButtonGroup):void
    {
        if (_group == value)
            return;

        // If the button was in another group, remove it.
        removeFromGroup();    

        _group = value;  

        // If the group is set then the groupName is the generated name of
        // the rbg.  If it's set to null, then set the groupName back to the
        // default group so this button will move back to that group.
        _groupName = value ? group.name : "radioGroup";    
        
        // Make sure this gets added to it's RadioButtonGroup
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
    private var _groupName:String;
    
    /**
     *  @private
     */
    private var groupChanged:Boolean = false;

    [Inspectable(category="General", defaultValue="radioGroup")]

    /**
     *  Specifies the name of the group to which this RadioButton control belongs, or 
     *  specifies the value of the <code>id</code> property of a RadioButtonGroup control
     *  if this RadioButton is part of a group defined by a RadioButtonGroup control.
     *  All radio buttons with the same <code>groupName</code> property will be in the same tab group,
     *  even if they belong to different radio button groups. When creating
     *  radio buttons to put in a RadioButtonGroup, it is advisable to
     *  use either the <code>group</code> property 
     *  or the <code>groupName</code> property for all of the buttons.
     *
     *  @default <code>"RadioButtonGroup_<i>n</i>"</code>, where <i>n</i> is an integer greater
     *  than or equal to 0
     *  @see #group
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

        // Make sure this gets added to it's RadioButtonGroup
        groupChanged = true;
        
        invalidateProperties();
        invalidateDisplayList();
    }

    //----------------------------------
    //  selected
    //----------------------------------
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function set selected(value:Boolean):void
    {
        super.selected = value;
        invalidateDisplayList();
    }

    //----------------------------------
    //  value
    //----------------------------------

    /**
     *  @private
     *  Storage for value property.
     */
    private var _value:Object;

    [Inspectable(category="General", defaultValue="")]

    /**
     *  Optional user-defined value
     *  that is associated with a RadioButton control.
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        if (_value == value)
            return;
            
        _value = value;

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
        if (groupChanged)
        {
            addToGroup();
            groupChanged = false;
        }

        // Do this after radio button is added to the group so when the
        // skin state is set, enabled and selected will return the correct values,
        // and the correct skin will be used.
        super.commitProperties();
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
    private function addToGroup():RadioButtonGroup
    {        
        var g:RadioButtonGroup = group; // Trigger getting the group
        if (g)
            g.addInstance(this);
              
        return g;
    }

    /**
     *  @private
     */
    private function removeFromGroup():void
    {        
        // If the radio button was in a group, remove it.
        this.dispatchEvent(new Event(Event.REMOVED));
          
        // It's possible that the radio button was in the auto group.  If so,
        // delete the group if there are no other radio buttons still in it.
        // The radio button also could have been in an explicit RadioButtonGroup
        // specified via group or in a RadioButtonGroup that was in the document,
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
        var g:RadioButtonGroup = group;

        var fm:IFocusManager = focusManager;
        if (fm)
            fm.showFocusIndicator = true;

        for (var i:int = 1; i <= indexNumber; i++)
        {
            var radioButton:RadioButton = 
                    g.getRadioButtonAt(indexNumber - i);
            if (radioButton && isRadioButtonEnabled(radioButton))
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
        var g:RadioButtonGroup = group;

        var fm:IFocusManager = focusManager;
        if (fm)
            fm.showFocusIndicator = true;

        for (var i:int = indexNumber + 1; i < g.numRadioButtons; i++)
        {
            var radioButton:RadioButton = g.getRadioButtonAt(i);
            if (radioButton && isRadioButtonEnabled(radioButton))
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
     *  When using keyboard navigation, need to make sure we don't move to
     *  a radio button that's not enabled because it's in a different
     *  container that isn't enabled.
     */
    private function isRadioButtonEnabled(rb:RadioButton):Boolean
    {
        if (!rb.enabled)
            return false;
            
        var sbRoot:DisplayObject = rb.systemManager.getSandboxRoot(); 
              
        // If it's in another UIComponent like a container, is that enabled?
        var p:DisplayObject = rb.parent;
        while (p && p != sbRoot)
        {
            if (p is UIComponent && !UIComponent(p).enabled)
                return false;
            
            p = p.parent;
        }
        
        return true;                   
    }
    
    /**
     *  @private
     */
    private function setThis():void
    {
        if (!radioButtonGroup)
            addToGroup();

        var g:RadioButtonGroup = group;
        if (g.selection != this)
            g.setSelection(this);
    }

   /**
     *  @private
     *  The radio button group and the radio button each have enabled properties.
     *  The radio button component is enabled if the group is enabled and the button
     *  itself is enabled.
     */
    override public function get enabled():Boolean
    {
        // Is the radio button itself enabled?
        if (!super.enabled)
            return false;
            
        // The button is enabled so it's enabled if it's not in a group
        // or the group is enabled.
        return !radioButtonGroup || 
               radioButtonGroup.enabled;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden functions: UIComponent
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // If this rb is selected and in a group, make sure it is the group
        // selection.  If it is not selected and it's in a group, make sure it
        // is not the group selection.
        if (group)
        {
            if (selected)
                _group.selection = this;
            else if (group.selection == this)
                _group.selection = null;   
        }
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
        // Have to make sure we don't move to a radio button that's not enabled
        // because it's in a different container that is not enabled.
                
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
    override protected function clickHandler(event:MouseEvent):void
    {
        if (!enabled || selected)
            return; // prevent a selected button from dispatching "click"

        if (!radioButtonGroup)
            addToGroup();

        // Must call super.clickHandler() before setting
        // the group's selection.
        super.clickHandler(event);

        group.setSelection(this);

        // Dispatch an itemClick event from the RadioButtonGroup.
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
