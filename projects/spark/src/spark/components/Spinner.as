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

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;

import spark.components.supportClasses.Range;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  The radius of the corners of this component.
 *
 *  @default 2
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="cornerRadius", type="Number", format="Length", inherit="no", theme="spark", minValue="0.0")]

/**
 *  The alpha of the focus ring for this component.
 *
 *  @default 0.5
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="focusAlpha", type="Number", inherit="no", theme="spark", minValue="0.0", maxValue="1.0")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:focusColor
 *
 *  @default 0x70B2EE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:symbolColor
 *
 *  @default 0x000000
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark")]

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the value of the Spinner control changes
 *  as a result of user interaction.
 *
 *  @eventType flash.events.Event.CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="change", type="flash.events.Event")]

//--------------------------------------
//  Skin states
//--------------------------------------

/**
 *  Normal State
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("normal")]

/**
 *  Disabled State
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("disabled")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[AccessibilityClass(implementation="spark.accessibility.SpinnerAccImpl")]

[IconFile("Spinner.png")]

/**
 * Because this component does not define a skin for the mobile theme, Adobe
 * recommends that you not use it in a mobile application. Alternatively, you
 * can define your own mobile skin for the component. For more information,
 * see <a href="http://help.adobe.com/en_US/flex/mobileapps/WS19f279b149e7481c698e85712b3011fe73-8000.html">Basics of mobile skinning</a>.
 */
[DiscouragedForProfile("mobileDevice")]

/**
 *  A Spinner component selects a value from an
 *  ordered set. It uses two buttons that increase or
 *  decrease the current value based on the current
 *  value of the <code>stepSize</code> property.
 *  
 *  <p>A Spinner consists of two required buttons,
 *  one to increase the current value and one to decrease the 
 *  current value. Users can also use the Up Arrow and Down Arrow keys
 *  and the mouse wheel to cycle through the values. 
 *  An input value is committed when the user presses the Enter key,
 *  removes focus from the component, or steps the Spinner 
 *  by pressing an arrow button or by calling the 
 *  <code>changeValueByStep()</code> method.</p>
 *
 *  <p>The scale of an Spinner component is the set of 
 *  allowed values for the <code>value</code> property. 
 *  The allowed values are the sum of the minimum with
 *  integer multiples of the <code>snapInterval</code> property
 *  which are less than or equal to the <code>maximum</code>value.
 *  For example:</p>
 *  
 *  <ul>
 *    <li><code>minimum</code> = -1</li>
 *    <li><code>maximum</code> = 10</li>
 *    <li><code>snapInterval</code> = 3</li>
 *  </ul>
 *  
 *  Therefore the scale is {-1,2,5,8,10}.
 *
 *  <p>To use this component in a list-based component, such as a List or DataGrid, 
 *  create an item renderer.
 *  For information about creating an item renderer, see 
 *  <a href="http://help.adobe.com/en_US/flex/using/WS4bebcd66a74275c3-fc6548e124e49b51c4-8000.html">
 *  Custom Spark item renderers</a>. </p>
 *
 *  <p>The Spinner control has the following default characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>19 pixels wide by 23 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Minimum size</td>
 *           <td>12 pixels wide and 12 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>10000 pixels wide and 10000 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Default skin class</td>
 *           <td>spark.skins.spark.SpinnerSkin</td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:Spinner&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:Spinner
 *    <strong>Properties</strong>
 *    allowValueWrap="false"
 *  
 *    <strong>Events</strong>
 *    change="<i>No default</i>"
 *
 *    <strong>Styles</strong>
 *    cornerRadius="2"
 *    focusAlpha="0.5"
 *    focusColor="0x70B2EE"
 *    symbolColor="0x000000"
 *      
 *  /&gt;
 *  </pre>
 *
 *  @see spark.components.NumericStepper
 *  @see spark.skins.spark.SpinnerSkin
 *
 *  @includeExample examples/SpinnerExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Spinner extends Range implements IFocusManagerComponent
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class mixins
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Placeholder for mixin by SpinnerAccImpl.
     */
    mx_internal static var createAccessibilityImplementation:Function;

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
    public function Spinner():void
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    // SkinParts
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  decrementButton
    //----------------------------------

    [SkinPart(required="false")]
    
    /**
     *  A skin part that defines the  button that, 
     *  when pressed, decrements the <code>value</code> property
     *  by <code>stepSize</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var decrementButton:Button;
    
    //----------------------------------
    //  incrementButton
    //----------------------------------

    [SkinPart(required="false")]
    
    /**
     *  A skin part that defines the  button that, 
     *  when pressed, increments the <code>value</code> property
     *  by <code>stepSize</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var incrementButton:Button;
    
    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  allowValueWrap
    //----------------------------------
    
    /**
     *  @private
     */
    private var _allowValueWrap:Boolean = false;
    
    [Inspectable(category="General", defaultValue="false")]
    
    /**
     *  Determines the behavior of the control for a step when the current 
     *  <code>value</code> is either the <code>maximum</code> 
     *  or <code>minimum</code> value.  
     *  If <code>allowValueWrap</code> is <code>true</code>, then the 
     *  <code>value</code> property wraps from the <code>maximum</code> 
     *  to the <code>minimum</code> value, or from 
     *  the <code>minimum</code> to the <code>maximum</code> value.
     * 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get allowValueWrap():Boolean
    {
        return _allowValueWrap;
    }

    public function set allowValueWrap(value:Boolean):void
    {
        _allowValueWrap = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

     /**
     *  @private
     */
    override protected function initializeAccessibility():void
    {
        if (Spinner.createAccessibilityImplementation != null)
            Spinner.createAccessibilityImplementation(this);
    }

    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);

        if (instance == incrementButton)
        {
            incrementButton.focusEnabled = false;
            incrementButton.addEventListener(FlexEvent.BUTTON_DOWN,
                                        incrementButton_buttonDownHandler);
            incrementButton.autoRepeat = true;
        }
        else if (instance == decrementButton)
        {
            decrementButton.focusEnabled = false;
            decrementButton.addEventListener(FlexEvent.BUTTON_DOWN,
                                        decrementButton_buttonDownHandler);
            decrementButton.autoRepeat = true;
        }
    }

    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);

        if (instance == incrementButton)
        {
            incrementButton.removeEventListener(FlexEvent.BUTTON_DOWN, 
                                           incrementButton_buttonDownHandler);
        }
        else if (instance == decrementButton)
        {
            decrementButton.removeEventListener(FlexEvent.BUTTON_DOWN, 
                                           decrementButton_buttonDownHandler);
        }
    }
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function getCurrentSkinState():String
    {
        return enabled ? "normal" : "disabled";
    }

    /**
     *  @private
     */
    override public function changeValueByStep(increase:Boolean = true):void
    {
        if (allowValueWrap)
        {
            if (increase && (value == maximum))
                value = minimum;
            else if (!increase && (value == minimum))
                value = maximum;
            else 
                super.changeValueByStep(increase);
        }
        else
            super.changeValueByStep(increase);
    }
    
    //--------------------------------------------------------------------------
    // 
    //  Event handlers
    //
    //--------------------------------------------------------------------------
       
    /**
     *  @private
     *  Handle a click on the incrementButton. This should
     *  increment <code>value</code> by <code>stepSize</code>.
     */
    protected function incrementButton_buttonDownHandler(event:Event):void
    {
        var prevValue:Number = this.value;
        
        changeValueByStep(true);
        
        if (value != prevValue)
            dispatchEvent(new Event("change"));
    }
    
    /**
     *  @private
     *  Handle a click on the decrementButton. This should
     *  decrement <code>value</code> by <code>stepSize</code>.
     */
    protected function decrementButton_buttonDownHandler(event:Event):void
    {
        var prevValue:Number = this.value;
        
        changeValueByStep(false);
        
        if (value != prevValue)
            dispatchEvent(new Event("change"));
    }   
    
    /**
     *  @private
     *  Handles keyboard input. Up arrow increments. Down arrow
     *  decrements. Home and End keys set the value to maximum
     *  and minimum respectively.
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        if (event.isDefaultPrevented())
            return;
                
        var prevValue:Number = this.value;
                
        switch (event.keyCode)
        {
            case Keyboard.DOWN:
            //case Keyboard.LEFT: (handle layoutDirection if uncommented)
            {
                changeValueByStep(false);
                event.preventDefault();
                break;
            }

            case Keyboard.UP:
            //case Keyboard.RIGHT: (handle layoutDirection if uncommented)
            {
                changeValueByStep(true);
                event.preventDefault();
                break;
            }

            case Keyboard.HOME:
            {
                value = minimum;
                event.preventDefault();
                break;
            }

            case Keyboard.END:
            {
                value = maximum;
                event.preventDefault();
                break;
            }
            
            default:
            {
                super.keyDownHandler(event);
                break;
            }
        }

        if (value != prevValue)
            dispatchEvent(new Event("change"));

    }
    
    /**
     *  @private
     *  If the component is in focus,
     *  then it should respond to mouseWheel events.
     *  We listen to these events on systemManager in the capture phase
     *  because this behavior should have the highest priority. 
     */ 
    override protected function focusInHandler(event:FocusEvent):void
    {
        super.focusInHandler(event);

        systemManager.getSandboxRoot().addEventListener(
            MouseEvent.MOUSE_WHEEL, system_mouseWheelHandler, true);
    }
    
    /**
     *  @private
     */
    override protected function focusOutHandler(event:FocusEvent):void
    {
        super.focusOutHandler(event);

        systemManager.getSandboxRoot().removeEventListener(
            MouseEvent.MOUSE_WHEEL, system_mouseWheelHandler, true);
    }
    
    /**
     *  @private
     *  Handles the <code>mouseWheel</code> event
     *  when the component is in focus.
     *  The spinner is moved by the amount of the mouse event delta
     *  multiplied by the <code>stepSize</code>.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    protected function system_mouseWheelHandler(event:MouseEvent):void
    {
        if (!event.isDefaultPrevented())
        {
            var newValue:Number = nearestValidValue(value + event.delta * stepSize, stepSize);
            setValue(newValue);
            dispatchEvent(new Event(Event.CHANGE));
            event.preventDefault();
        }
    }
}

}
