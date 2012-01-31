////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2004-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.controls
{

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Keyboard;
import flash.utils.getTimer;
import mx.controls.colorPickerClasses.SwatchPanel;
import mx.controls.colorPickerClasses.WebSafePalette;
import mx.core.LayoutDirection;
import mx.core.UIComponent;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.effects.Tween;
import mx.events.ColorPickerEvent;
import mx.events.DropdownEvent;
import mx.events.FlexEvent;
import mx.events.FlexMouseEvent;
import mx.events.InterManagerRequest;
import mx.events.SandboxMouseEvent;
import mx.managers.IFocusManager;
import mx.managers.ISystemManager;
import mx.managers.PopUpManager;
import mx.managers.SystemManager;
import mx.skins.halo.SwatchSkin;
import mx.styles.StyleProxy;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the selected color 
 *  changes as a result of user interaction.
 *
 *  @eventType mx.events.ColorPickerEvent.CHANGE
 *  @helpid 4918
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="change", type="mx.events.ColorPickerEvent")]

/**
 *  Dispatched when the swatch panel closes.
 *
 *  @eventType mx.events.DropdownEvent.CLOSE
 *  @helpid 4921
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="close", type="mx.events.DropdownEvent")]

/**
 *  Dispatched if the ColorPicker <code>editable</code>
 *  property is set to <code>true</code>
 *  and the user presses Enter after typing in a hexadecimal color value.
 *
 *  @eventType mx.events.ColorPickerEvent.ENTER
 *  @helpid 4919
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="enter", type="mx.events.ColorPickerEvent")]

/**
 *  Dispatched when the user rolls the mouse out of a swatch
 *  in the SwatchPanel object.
 *
 *  @eventType mx.events.ColorPickerEvent.ITEM_ROLL_OUT
 *  @helpid 4924
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="itemRollOut", type="mx.events.ColorPickerEvent")]

/**
 *  Dispatched when the user rolls the mouse over a swatch
 *  in the SwatchPanel object.
 *
 *  @eventType mx.events.ColorPickerEvent.ITEM_ROLL_OVER
 *  @helpid 4923
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="itemRollOver", type="mx.events.ColorPickerEvent")]

/**
 *  Dispatched when the color swatch panel opens.
 *
 *  @eventType mx.events.DropdownEvent.OPEN
 *  @helpid 4920
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="open", type="mx.events.DropdownEvent")]

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/FocusStyles.as"
include "../styles/metadata/IconColorStyles.as"
include "../styles/metadata/LeadingStyle.as"
include "../styles/metadata/TextStyles.as"

/**
 *  Color of the outer border on the SwatchPanel object.
 *  The default value is <code>0xA5A9AE</code>.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="borderColor", type="uint", format="Color", inherit="no", theme="halo")]

/**
 *  Length of a close transition, in milliseconds.
 * 
 *  The default value for the Halo theme is 250.
 *  The default value for the Spark theme is 50.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="closeDuration", type="Number", format="Time", inherit="no")]

/**
 *  Easing function to control component tweening.
 *  The default value is <code>undefined</code>.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="closeEasingFunction", type="Function", inherit="no")]

/**
 *  Alphas used for the background fill of controls.
 *  The default value is <code>[ 0.6, 0.4 ]</code>.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="fillAlphas", type="Array", arrayType="Number", inherit="no", theme="halo")]

/**
 *  Colors used to tint the background of the control.
 *  Pass the same color for both values for a flat-looking control.
 *  The default value is <code>[ 0xFFFFFF, 0xCCCCCC ]</code>.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="fillColors", type="Array", arrayType="uint", format="Color", inherit="no", theme="halo")]

/**
 *  Alphas used for the highlight fill of controls.
 *  The default value is <code>[ 0.3, 0.0 ]</code>.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="highlightAlphas", type="Array", arrayType="Number", inherit="no", theme="halo")]

/**
 *  Length of an open transition, in milliseconds.
 *
 *  The default value for the Halo theme is 250.
 *  The default value for the Spark theme is 0.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="openDuration", type="Number", format="Time", inherit="no")]

/**
 *  Easing function to control component tweening.
 *  The default value is <code>undefined</code>.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="openEasingFunction", type="Function", inherit="no")]

/**
 *  Bottom padding of SwatchPanel object below the swatch grid.
 *  The default value is 5.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]

/**
 *  Left padding of SwatchPanel object to the side of the swatch grid.
 *  The default value is 5.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="paddingLeft", type="Number", format="Length", inherit="no")]

/**
 *  Right padding of SwatchPanel object to the side of the swatch grid.
 *  The default value is 5.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="paddingRight", type="Number", format="Length", inherit="no")]

/**
 *  Top padding of SwatchPanel object above the swatch grid.
 *  The default value is 4.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="paddingTop", type="Number", format="Length", inherit="no")]

/**
 *  Color of the swatches' borders.
 *  The default value is <code>0x000000</code>.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="swatchBorderColor", type="uint", format="Color", inherit="no", theme="halo")]

/**
 *  Size of the outlines of the swatches' borders.
 *  The default value is 1.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="swatchBorderSize", type="Number", format="Length", inherit="no")]

/**
 *  Name of the class selector that defines style properties for the swatch panel.
 *  The default value is <code>undefined</code>. The following example shows the default style properties
 *  that are defined by the <code>swatchPanelStyleName</code>. 
 *  <pre>
 *  ColorPicker {
 *      swatchPanelStyleName:mySwatchPanelStyle;
 *  }
 *  
 *  .mySwatchPanelStyle {
 *      backgroundColor:#E5E6E7;
 *      columnCount:20;
 *      horizontalGap:0;
 *      previewHeight:22;
 *      previewWidth:45;
 *      swatchGridBackgroundColor:#000000;
 *      swatchGridBorderSize:0;
 *      swatchHeight:12;
 *      swatchHighlightColor:#FFFFFF;
 *      swatchHighlightSize:1;
 *      swatchWidth:12;
 *      textFieldWidth:72;
 *      verticalGap:0;
 *  }
 *  </pre>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="swatchPanelStyleName", type="String", inherit="no")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------
[Exclude(name="text", kind="property")]

[Exclude(name="fillAlphas", kind="style")]
[Exclude(name="fillColors", kind="style")]
[Exclude(name="highlightAlphas", kind="style")]

//--------------------------------------
//  Other metadata
//--------------------------------------


[AccessibilityClass(implementation="mx.accessibility.ColorPickerAccImpl")]

[DataBindingInfo("acceptedTypes", "{ dataProvider: { label: &quot;String&quot; } }")]

[DefaultBindingProperty(source="selectedItem", destination="dataProvider")]

[DefaultTriggerEvent("change")]

[IconFile("ColorPicker.png")]

   

/**
 *  The ColorPicker control provides a way for a user to choose a color from a swatch list.
 *  The default mode of the component shows a single swatch in a square button.
 *  When the user clicks the swatch button, the swatch panel appears and
 *  displays the entire swatch list.
 *
 *  <p>The ColorPicker control has the following default sizing characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>ColorPicker: 22 by 22 pixels
 *          <br>Swatch panel: Sized to fit the ColorPicker control width</br></td>
 *        </tr>
 *        <tr>
 *           <td>Minimum size</td>
 *           <td>0 pixels by 0 pixels</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>Undefined</td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mx:ColorPicker&gt;</code> tag inherits all of the properties of its
 *  superclass, and the following properties:</p>
 *
 *  <pre>
 *  &lt;mx:ColorPicker
 *    <b>Properties</b>
 *    colorField="color"
 *    labelField="label"
 *    selectedColor="0x000000"
 *    selectedIndex="0"
 *    showTextField="true|false"
 * 
 *    <b>Styles</b>
 *    borderColor="0xA5A9AE"
 *    closeDuration="250"
 *    closeEasingFunction="undefined"
 *    color="0x0B333C"
 *    disabledIconColor="0x999999"
 *    fillAlphas="[0.6,0.4]"
 *    fillColors="[0xFFFFFF, 0xCCCCCC]"
 *    focusAlpha="0.5"
 *    focusRoundedCorners="tl tr bl br"
 *    fontAntiAliasType="advanced"
 *    fontfamily="Verdana"
 *    fontGridFitType="pixel"
 *    fontSharpness="0""
 *    fontSize="10"
 *    fontStyle="normal"
 *    fontThickness="0"
 *    fontWeight="normal"
 *    highlightAlphas="[0.3,0.0]"
 *    iconColor="0x000000"
 *    leading="2"
 *    openDuration="250"
 *    openEasingFunction="undefined"
 *    paddingBottom="5"
 *    paddingLeft="5"
 *    paddingRight="5"
 *    paddingTop="4"
 *    swatchBorderColor="0x000000"
 *    swatchBorderSize="1"
 *    swatchPanelStyleName="undefined"
 *    textAlign="left"
 *    textDecoration="none"
 *    textIndent="0"
 * 
 *    <b>Events</b>
 *    change="<i>No default</i>"
 *    close="<i>No default</i>"
 *    enter="<i>No default</i>"
 *    itemRollOut="<i>No default</i>"
 *    itemRollOver="<i>No default</i>"
 *    open="<i>No default</i>"
 *    /&gt;
 *  </pre>
 *
 *  @see mx.controls.List
 *  @see mx.effects.Tween
 *  @see mx.managers.PopUpManager
 *
 *  @includeExample examples/ColorPickerExample.mxml
 *
 *  @helpid 4917
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ColorPicker extends ComboBase
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class mixins
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Placeholder for mixin by SliderAccImpl.
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function ColorPicker()
    {
        super();

        if (!isModelInited)
            loadDefaultPalette();

        // Make editable false so that focus doesn't go
        // to the comboBase's textInput which is not used by CP
        super.editable = false;

        // Register for events.
        addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Used by SwatchPanel
     */
    mx_internal var showingDropdown:Boolean = false;

    /**
     *  @private
     *  Used by SwatchPanel
     */
    mx_internal var isDown:Boolean = false;

    /**
     *  @private
     *  Used by SwatchPanel
     */
    mx_internal var isOpening:Boolean = false;

    /**
     *  @private
     */
    private var dropdownGap:Number = 6;

    /**
     *  @private
     */
    private var indexFlag:Boolean = false;

    /**
     *  @private
     */
    private var initializing:Boolean = true;

    /**
     *  @private
     */
    private var isModelInited:Boolean = false;

    /**
     *  @private
     */
    private var collectionChanged:Boolean = false;

    /**
     *  @private
     */
    private var swatchPreview:SwatchSkin;

    /**
     *  @private
     */
    private var dropdownSwatch:SwatchPanel;

    /**
     *  @private
     */
    private var triggerEvent:Event;

    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  dataProvider
    //----------------------------------

    [Bindable("collectionChange")]
    [Inspectable(category="Data")]

    /**
     *  @private
     *  The dataProvider for the ColorPicker control.
     *  The default dataProvider is an Array that includes all
     *  the web-safe colors.
     *
     *  @helpid 4929
     */
    override public function set dataProvider(value:Object):void
    {
        super.dataProvider = value;
        
        isModelInited = true;
        
        if (dropdownSwatch)
            dropdownSwatch.dataProvider = value;
    }

    //----------------------------------
    //  editable
    //----------------------------------

    [Bindable("editableChanged")]
    [Inspectable(category="General", defaultValue="true")]

    /**
     *  @private
     */
    private var _editable:Boolean = true;

    /**
     *  @private
     *  Specifies whether the user can type a hexadecimal color value
     *  in the text box.
     *
     *  @default true
     *  @helpid 4930
     */
    override public function get editable():Boolean
    {
        return _editable;
    }

    /**
     *  @private
     */
    override public function set editable(value:Boolean):void
    {
        _editable = value;
        
        if (dropdownSwatch)
            dropdownSwatch.editable = value;
        
        dispatchEvent(new Event("editableChanged"));
    }

    //----------------------------------
    //  selectedIndex
    //----------------------------------

    [Bindable("change")]
    [Bindable("collectionChange")]
    [Inspectable(defaultValue="0")]

    /**
     *  Index in the dataProvider of the selected item in the
     *  SwatchPanel object.
     *  Setting this property sets the selected color to the color that
     *  corresponds to the index, sets the selected index in the drop-down
     *  swatch to the <code>selectedIndex</code> property value, 
     *  and displays the associated label in the text box.
     *  The default value is the index corresponding to 
     *  black(0x000000) color if found, else it is 0.
     *
     *  @helpid 4931
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function set selectedIndex(value:int):void
    {
        if ((selectedIndex != -1 || !isNaN(selectedColor)) &&
            value != selectedIndex)
        {
            if (value >= 0)
            {
                indexFlag = true;
                selectedColor = getColor(value);
                // Call super in mixed-in DataSelector
                super.selectedIndex = value;
            }

            if (dropdownSwatch)
                dropdownSwatch.selectedIndex = value;
        }
    }

    //----------------------------------
    //  selectedItem
    //----------------------------------

    [Bindable("change")]
    [Bindable("collectionChange")]
    [Inspectable(defaultValue="0")]

    /**
     *  @private
     *  If the dataProvider is a complex object, this property is a
     *  reference to the selected item in the SwatchPanel object.
     *  If the dataProvider is an Array of color values, this
     *  property is the selected color value.
     *  If the dataProvider is a complex object, modifying fields of
     *  this property modifies the dataProvider and its views.
     *
     *  <p>If the dataProvider is a complex object, this property is
     *  read-only. You cannot change its value directly.
     *  If the dataProvider is an Array of hexadecimal color values,
     *  you can change this value directly. 
     *  The default value is undefined for complex dataProviders;
     *  0 if the dataProvider is an Array of color values.
     *
     *  @helpid 4933
     */
    override public function set selectedItem(value:Object):void
    {
        if (value != selectedItem)
        {
            // Call super in mixed-in DataSelector
            super.selectedItem = value;

            if (typeof(value) == "object")
                selectedColor = Number(value[colorField]);
            else if (typeof(value) == "number")
                selectedColor = Number(value);

            indexFlag = true;

            if (dropdownSwatch)
                dropdownSwatch.selectedItem = value;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  colorField
    //----------------------------------

    /**
     *  @private
     *  Storage for the colorField property.
     */
    private var _colorField:String = "color";

    [Bindable("colorFieldChanged")]
    [Inspectable(category="Data", defaultValue="color")]

    /**
     *  Name of the field in the objects of the dataProvider Array that
     *  specifies the hexadecimal values of the colors that the swatch
     *  panel displays.
     *
     *  <p>If the dataProvider objects do not contain a color
     *  field, set the <code>colorField</code> property to use the correct field name.
     *  This property is available, but not meaningful, if the
     *  dataProvider is an Array of hexadecimal color values.</p>
     *
     *  @default "color"
     *  @helpid 4927
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get colorField():String
    {
        return _colorField;
    }

    /**
     *  @private
     */
    public function set colorField(value:String):void
    {
        _colorField = value;

        if (dropdownSwatch)
            dropdownSwatch.colorField = value;

        dispatchEvent(new Event("colorFieldChanged"));
    }

    //----------------------------------
    //  dropdown
    //----------------------------------

    /**
     *  A reference to the SwatchPanel object that appears when you expand
     *  the ColorPicker control.
     *
     *  @helpid 4922
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    mx_internal function get dropdown():SwatchPanel
    {
        return dropdownSwatch; // null if not created yet
    }

    //----------------------------------
    //  labelField
    //----------------------------------

    /**
     *  Storage for the labelField property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private var _labelField:String = "label";

    [Bindable("labelFieldChanged")]
    [Inspectable(category="Data", defaultValue="label")]

    /**
     *  Name of the field in the objects of the dataProvider Array that
     *  contain text to display as the label in the SwatchPanel object text box.
     *
     *  <p>If the dataProvider objects do not contain a label
     *  field, set the <code>labelField</code> property to use the correct field name.
     *  This property is available, but not meaningful, if the
     *  dataProvider is an Array of hexadecimal color values.</p>
     *
     *  @default "label"
     *  @helpid 4928
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get labelField():String
    {
        return _labelField;
    }

    /**
     *  @private
     */
    public function set labelField(value:String):void
    {
        _labelField = value;

        if (dropdownSwatch)
            dropdownSwatch.labelField = value;

        dispatchEvent(new Event("labelFieldChanged"));
    }

    //----------------------------------
    //  selectedColor
    //----------------------------------

    /**
     *  @private
     *  Storage for the selectedColor property.
     */
    private var _selectedColor:uint = 0x000000;

    [Bindable("change")]
    [Bindable("valueCommit")]
    [Inspectable(category="General", defaultValue="0", format="Color")]

    /**
     *  The value of the currently selected color in the
     *  SwatchPanel object. 
     *  In the &lt;mx:ColorPicker&gt; tag only, you can set this property to 
     *  a standard string color name, such as "blue".
     *  If the dataProvider contains an entry for black (0x000000), the
     *  default value is 0; otherwise, the default value is the color of
     *  the item at index 0 of the data provider.
     *
     *  @helpid 4932
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get selectedColor():uint
    {
        return _selectedColor;
    }

    /**
     *  @private
     */
    public function set selectedColor(value:uint):void
    {
        if (!indexFlag)
        {
            super.selectedIndex = findColorByName(value);
        }
        else
        {
            indexFlag = false;
        }

        if (value != selectedColor)
        {
            _selectedColor = value;

            updateColor(value);

            if (dropdownSwatch)
                dropdownSwatch.selectedColor = value;
        }

        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }

    //----------------------------------
    //  showTextField
    //----------------------------------

    /**
     *  @private
     *  Storage for the showTextField property.
     */
    private var _showTextField:Boolean = true;

    [Inspectable(category="General", defaultValue="true")]

    /**
     *  Specifies whether to show the text box that displays the color
     *  label or hexadecimal color value.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get showTextField():Boolean
    {
        return _showTextField;
    }

    /**
     *  @private
     */
    public function set showTextField(value:Boolean):void
    {
        _showTextField = value;

        if (dropdownSwatch)
            dropdownSwatch.showTextField = value;
    }

    //----------------------------------
    //  swatchStyleFilters
    //----------------------------------
    
    /**
     *  Set of styles to pass from the ColorPicker through to the preview swatch. 
     *  @see mx.styles.StyleProxy
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function get swatchStyleFilters():Object
    {
        return _swatchStyleFilters;
    }

    private static const _swatchStyleFilters:Object = 
    {
        "swatchBorderColor" : "swatchBorderColor",
        "swatchBorderSize" : "swatchBorderSize"
    };

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function initializeAccessibility():void
    {
        if (ColorPicker.createAccessibilityImplementation != null)
            ColorPicker.createAccessibilityImplementation(this);
    }

    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();

        // Create swatch preview
        if (!swatchPreview)
        {
            swatchPreview = new SwatchSkin();

            swatchPreview.styleName = new StyleProxy(this, swatchStyleFilters);
            swatchPreview.color = selectedColor;
            swatchPreview.name = "colorPickerSwatch";

            addChild(swatchPreview);
        }

        setChildIndex(swatchPreview, getChildIndex(downArrowButton));
        textInput.visible = false;

        // Update the preview swatch
        if (!enabled)
            super.enabled = enabled;

        initializing = false;
    }

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

        // Code executed when model (dataProvider changes)
        // If dataProvider is changed, selectedColor if found in
        // the new dataProvider is selected
        // else selectedColor is color at selectedIndex = 0;
        if (collectionChanged)
        {
            if (findColorByName(selectedColor) == -1)
            {
                if (dataProvider.length > 0 && selectedIndex > dataProvider.length)
                    selectedIndex = 0;
                if (getColor(selectedIndex) >= 0)
                {
                    selectedColor = getColor(selectedIndex);
                    swatchPreview.color = selectedColor;
                }
                else
                {
                    if (dropdownSwatch)
                        swatchPreview.color = dropdownSwatch.selectedColor;
                }
            }
            else
                selectedIndex = findColorByName(selectedColor);
            collectionChanged = false;
        }
    }

    /**
     *  @private
     */
    override protected function measure():void
    {
        // Though deriving from ComboBase this doesnot implement
        // calcPreferredSizeFromData required by the super measure.
        // Hence do not call it.
        // super.measure();

        // Make sure we're a small square, so we use HEIGHT for both
        measuredMinWidth = measuredWidth = DEFAULT_MEASURED_MIN_HEIGHT;
        measuredMinHeight = measuredHeight = DEFAULT_MEASURED_MIN_HEIGHT;
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        swatchPreview.color = selectedColor;
        swatchPreview.setActualSize(unscaledWidth, unscaledHeight);

        // super may push it around
        downArrowButton.move(0, 0);
        downArrowButton.setActualSize(unscaledWidth, unscaledHeight);

        if (dropdownSwatch)
        {
            dropdownSwatch.setActualSize(
                dropdownSwatch.getExplicitOrMeasuredWidth(),
                dropdownSwatch.getExplicitOrMeasuredHeight());
        }
    }

    /**
     *  @private
     *  Invalidate Style
     */
    override public function styleChanged(styleProp:String):void
    {

        if (dropdownSwatch)
        {
            if (styleProp == "swatchPanelStyleName")
            {
                var swatchPanelStyleName:Object = getStyle("swatchPanelStyleName");
                if (swatchPanelStyleName)
                    dropdownSwatch.styleName = swatchPanelStyleName;
            }
            dropdownSwatch.styleChanged(styleProp);
        }
    

        super.styleChanged(styleProp);

        // Adjust tweenMask size if needed
        invalidateDisplayList();
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Displays the drop-down SwatchPanel object
     *  that shows colors that users can select.
     *
     *  @helpid 4925
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function open():void
    {
        displayDropdown(true);
    }

    /**
     *  Hides the drop-down SwatchPanel object.
     *
     *  @param trigger The event to dispatch when the 
     *  drop-down list closes.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function close(trigger:Event = null):void
    {
        displayDropdown(false, trigger);
    }

    /**
     *  @private
     *  Dropdown Creation
     */
    mx_internal function getDropdown():SwatchPanel
    {
        if (initializing)
            return null;

        if (!dropdownSwatch)
        {
            dropdownSwatch = new SwatchPanel();
            dropdownSwatch.owner = this;
            dropdownSwatch.editable = editable;
            dropdownSwatch.colorField = colorField;
            dropdownSwatch.labelField = labelField;
            dropdownSwatch.dataProvider = dataProvider;
            dropdownSwatch.showTextField = showTextField;
            dropdownSwatch.selectedColor = selectedColor;
            dropdownSwatch.selectedIndex = selectedIndex;
            dropdownSwatch.textInputClass = getStyle("textInputClass");

            var swatchPanelStyleName:Object = getStyle("swatchPanelStyleName");
            if (swatchPanelStyleName)
                dropdownSwatch.styleName = swatchPanelStyleName;

            // Assign event handlers
            dropdownSwatch.addEventListener(ColorPickerEvent.ITEM_ROLL_OVER,
                                            dropdownSwatch_itemRollOverHandler);
            dropdownSwatch.addEventListener(ColorPickerEvent.ITEM_ROLL_OUT,
                                            dropdownSwatch_itemRollOutHandler);

            dropdownSwatch.cacheAsBitmap = true;
            dropdownSwatch.scrollRect = new Rectangle(0, 0, 0, 0);
            
            PopUpManager.addPopUp(dropdownSwatch, this);
            
            UIComponentGlobals.layoutManager.validateClient(dropdownSwatch, true);
            dropdownSwatch.setActualSize(
                dropdownSwatch.getExplicitOrMeasuredWidth(),
                dropdownSwatch.getExplicitOrMeasuredHeight());
            dropdownSwatch.validateDisplayList();
        }

        dropdownSwatch.layoutDirection = layoutDirection;
        dropdownSwatch.scaleX = scaleX;
        dropdownSwatch.scaleY = scaleY;

        return dropdownSwatch;
    }

    /**
     *  @private
     *  Display Dropdown
     */
    mx_internal function displayDropdown(show:Boolean, trigger:Event = null):void
    {
        if (show == showingDropdown)
            return;
        
        // Show or hide the dropdown
        var initY:Number;
        var endY:Number;
        var tween:Tween = null;
        var easingFunction:Function;
        var duration:Number;
        
        // Save the current triggerEvent
        triggerEvent = trigger; 
    
        if (show) // Open
        {
            getDropdown();
                        
            // Find global position for the dropdown
            var point:Point = new Point(layoutDirection == LayoutDirection.RTL ? 
                                        dropdownSwatch.getExplicitOrMeasuredWidth() : 0, 
                                        0);
            point = localToGlobal(point);
            
            if (dropdownSwatch.parent == null)
                PopUpManager.addPopUp(dropdownSwatch, this, false);
            else
                PopUpManager.bringToFront(dropdownSwatch);

            dropdownSwatch.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE,
                                            dropdownSwatch_mouseDownOutsideHandler);
            dropdownSwatch.addEventListener(FlexMouseEvent.MOUSE_WHEEL_OUTSIDE,
                                            dropdownSwatch_mouseDownOutsideHandler);
            dropdownSwatch.addEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE,
                                            dropdownSwatch_mouseDownOutsideHandler);
            dropdownSwatch.addEventListener(SandboxMouseEvent.MOUSE_WHEEL_SOMEWHERE,
                                            dropdownSwatch_mouseDownOutsideHandler);

            dropdownSwatch.isOpening = true;
            dropdownSwatch.showTextField = showTextField;
            dropdownSwatch.selectedColor = selectedColor;
            dropdownSwatch.owner = this;

            // Position: top or bottom
            var sm:ISystemManager = systemManager.topLevelSystemManager;
            var screen:Rectangle = sm.getVisibleApplicationRect(null, true);

            if (point.y + height + dropdownGap + dropdownSwatch.height > screen.bottom && 
                point.y > (screen.top + dropdownGap + dropdownSwatch.height)) // Up
            {
                // Dropdown opens up instead of down
                point.y -= dropdownGap + dropdownSwatch.height;
                initY = -dropdownSwatch.height/scaleY;
                dropdownSwatch.tweenUp = true;
            }
            else // Down
            {
                point.y += dropdownGap + height;
                initY = dropdownSwatch.height/scaleY;
                dropdownSwatch.tweenUp = false;
            }

            // Position: left or right
            if (point.x + dropdownSwatch.width > screen.right && 
                point.x > (screen.left + dropdownSwatch.width))
            {
                // Dropdown appears to the left instead of right
                point.x -= (dropdownSwatch.width - width);
            }
            
            point.x = Math.max(point.x, 0);

            // Position the dropdown
            point = dropdownSwatch.parent.globalToLocal(point);
            dropdownSwatch.move(point.x, point.y);

            //dropdownSwatch.setFocus();

            isDown = true;
            isOpening = true;

            endY = 0;
            duration = getStyle("openDuration");
            easingFunction = getStyle("openEasingFunction") as Function;
            showingDropdown = show;
        }
        else // Close
        {
            initY = 0;

            endY = dropdownSwatch.tweenUp ?
                   -dropdownSwatch.height/scaleY :
                   dropdownSwatch.height/scaleY;

            isDown = false;
            duration = getStyle("closeDuration");
            easingFunction = getStyle("closeEasingFunction") as Function;
            showingDropdown = show;
            dropdownSwatch.removeEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE,
                                               dropdownSwatch_mouseDownOutsideHandler);
            dropdownSwatch.removeEventListener(FlexMouseEvent.MOUSE_WHEEL_OUTSIDE,
                                               dropdownSwatch_mouseDownOutsideHandler);
            dropdownSwatch.removeEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE,
                                            dropdownSwatch_mouseDownOutsideHandler);
            dropdownSwatch.removeEventListener(SandboxMouseEvent.MOUSE_WHEEL_SOMEWHERE,
                                            dropdownSwatch_mouseDownOutsideHandler);
                                               
            PopUpManager.removePopUp(dropdownSwatch);
        }
        
        if (dropdownSwatch)
        {
            dropdownSwatch.visible = true;
            dropdownSwatch.enabled = false;
        }
        
        UIComponentGlobals.layoutManager.validateNow();
        // Block all layout, responses from web service, and other background
        // processing until the tween finishes executing.
        UIComponent.suspendBackgroundProcessing();
        
        tween = new Tween(this, initY, endY, duration);
        if (easingFunction != null)
            tween.easingFunction = easingFunction;
    }

    /**
     *  @private
     *  Load Default Palette
     */
    private function loadDefaultPalette():void
    {
        // Initialize default swatch list
        if (!dataProvider || dataProvider.length < 1)
        {
            var wsp:WebSafePalette = new WebSafePalette();
            dataProvider = wsp.getList();
        }
        selectedIndex = findColorByName(selectedColor);
    }

    /**
     *  @private
     *  Update Color Preview
     */
    private function updateColor(color:Number):void
    {
        if (initializing || isNaN(color))
            return;

        // Update the preview swatch
        swatchPreview.updateSkin(color);
    }

    /**
     *  @private
     *  Find Color by Name
     */
    private function findColorByName(name:Number):int
    {
        if (name == getColor(selectedIndex))
            return selectedIndex;

        var n:int = dataProvider.length;
        for (var i:int = 0; i < dataProvider.length; i++)
        {
            if (name == getColor(i))
                return i;
        }

        return -1;
    }

    /**
     *  @private
     *  Get Color Value
     */
    private function getColor(location:int):Number
    {
        if (!dataProvider || dataProvider.length < 1 ||
            location < 0 || location >= dataProvider.length)
        {
            return -1;
        }

        return Number(typeof(dataProvider.getItemAt(location)) == "object" ?
                      dataProvider.getItemAt(location)[colorField] :
                      dataProvider.getItemAt(location));

    }

    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers: UIComponent
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function focusInHandler(event:FocusEvent):void
    {
        var fm:IFocusManager = focusManager;
        if (fm)
            fm.showFocusIndicator = true;
        
        if (isDown && !isOpening)
            close();
        else if (isOpening)
            isOpening = false;

        super.focusInHandler(event);
    }

    /**
     *  @private
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        var cpEvent:ColorPickerEvent = null;
        
        // If rtl layout, need to swap LEFT and RIGHT so correct action
        // is done.
        var keyCode:uint = mapKeycodeForLayoutDirection(event);

        if (event.ctrlKey && keyCode == Keyboard.DOWN)
        {
            displayDropdown(true, event);
        }
        
        else if ((event.ctrlKey && keyCode == Keyboard.UP) ||
                 keyCode == Keyboard.ESCAPE)
        {
            if (dropdownSwatch && dropdownSwatch.enabled)
                close(event);
        }
        
        else if (showingDropdown && keyCode == Keyboard.ENTER && dropdownSwatch.enabled)
        {
            if (!dropdownSwatch.isOverGrid && editable)
            {
                if (selectedColor != dropdownSwatch.selectedColor)
                {
                    selectedColor = dropdownSwatch.selectedColor;

                    cpEvent = new ColorPickerEvent(ColorPickerEvent.CHANGE);
                    cpEvent.index = selectedIndex;
                    cpEvent.color = selectedColor;
                    dispatchEvent(cpEvent);

                    cpEvent = new ColorPickerEvent(ColorPickerEvent.ENTER);
                    // The index isn't set for an ENTER event,
                    // because the user can enter an RGB hex string that
                    // doesn't correspond to any color in the dataProvider.
                    cpEvent.color = selectedColor;
                    dispatchEvent(cpEvent);
                }
            }
            else if (selectedIndex != dropdownSwatch.focusedIndex)
            {
                dropdownSwatch.selectedIndex = dropdownSwatch.focusedIndex;
                selectedIndex = dropdownSwatch.selectedIndex;

                cpEvent = new ColorPickerEvent(ColorPickerEvent.CHANGE);
                cpEvent.index = selectedIndex;
                cpEvent.color = selectedColor;
                dispatchEvent(cpEvent);
            }
            close();
            event.stopPropagation();
        }
        
        else if (showingDropdown &&
                 (keyCode == Keyboard.HOME ||
                  keyCode == Keyboard.END ||
                  keyCode == Keyboard.PAGE_UP ||
                  keyCode == Keyboard.PAGE_DOWN ||
                  keyCode == Keyboard.LEFT ||
                  keyCode == Keyboard.RIGHT ||
                  keyCode == Keyboard.UP ||
                  keyCode == Keyboard.DOWN))
        {
            // Redispatch the event from the SwatchPanel
            // so that its keyDownHandler() can handle it.
            dropdownSwatch.dispatchEvent(event);
        }
        
        else if (keyCode == Keyboard.LEFT)
            {
                if (selectedIndex == -1)
                {
                    selectedIndex = findColorByName(selectedColor);
                }
                if (selectedIndex - 1 >= 0)
                {
                    selectedIndex--;
    
                    cpEvent = new ColorPickerEvent(ColorPickerEvent.CHANGE);
                    cpEvent.index = selectedIndex;
                    cpEvent.color = selectedColor;
                    dispatchEvent(cpEvent);
                }
            }
            
        else if (keyCode == Keyboard.RIGHT)
            {
                if (selectedIndex == -1)
                {
                    selectedIndex = findColorByName(selectedColor);
                }
                if (selectedIndex + 1 < dataProvider.length)
                {
                    selectedIndex++;
    
                    cpEvent = new ColorPickerEvent(ColorPickerEvent.CHANGE);
                    cpEvent.index = selectedIndex;
                    cpEvent.color = selectedColor;
                    dispatchEvent(cpEvent);
                }
            }
        }

    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers: ComboBase
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function collectionChangeHandler(event:Event):void
    {
        // Change index to match selectedcolor if the model changes.
        if (!initializing)
        {
            if (dataProvider.length > 0)
                invalidateProperties();
            else
            {
                selectedColor = 0x000000;
                selectedIndex = -1;
            }
            collectionChanged = true;
        }

        if (dropdownSwatch)
            dropdownSwatch.dataProvider = dataProvider;
    }

    /**
     *  @private
     *  On Down Arrow
     */
    override protected function downArrowButton_buttonDownHandler(
                                    event:FlexEvent):void
    {
        // The down arrow should always toggle the visibility of the dropdown
        displayDropdown(!showingDropdown, event);
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function dropdownSwatch_itemRollOverHandler(event:ColorPickerEvent):void
    {
        dispatchEvent(event);
    }

    /**
     *  @private
     */
    private function dropdownSwatch_itemRollOutHandler(event:ColorPickerEvent):void
    {
        dispatchEvent(event);
    }

    /**
     *  @private
     */
    private function dropdownSwatch_mouseDownOutsideHandler(event:Event):void
    {
        if (event is MouseEvent)
        {
            var mouseEvent:MouseEvent = MouseEvent(event);
            if (!hitTestPoint(mouseEvent.stageX, mouseEvent.stageY, true))
                close(event);
        }
        else if (event is SandboxMouseEvent)
            close(event);
    }
    
    /**
     *  @private
     */
    mx_internal function onTweenUpdate(value:Number):void
    {
        dropdownSwatch.scrollRect = new Rectangle(0, value, dropdownSwatch.width, dropdownSwatch.height);
    }
    
    /**
     *  @private
     */   
    mx_internal function onTweenEnd(value:Number):void
    {
        if (showingDropdown)
        {
            dropdownSwatch.scrollRect = null; 
        }
        else
        {
            onTweenUpdate(value);
            dropdownSwatch.visible = false;
            isOpening = false;
        }
                
        UIComponent.resumeBackgroundProcessing();
        
        if (showingDropdown && showTextField)
            dropdownSwatch.callLater(dropdownSwatch.setFocus);
        else
            setFocus();
        
        dropdownSwatch.enabled = true;  
        dispatchEvent(new DropdownEvent(showingDropdown ? DropdownEvent.OPEN : DropdownEvent.CLOSE, false, false, triggerEvent));   
    }
}

} 
