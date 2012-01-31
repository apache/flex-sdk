////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.controls
{

import flash.events.Event;
import flash.events.MouseEvent;
import mx.collections.ICollectionView;
import mx.collections.IViewCursor;
import mx.collections.CursorBookmark;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.menuClasses.IMenuDataDescriptor;
import mx.controls.treeClasses.DefaultDataDescriptor;
import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.events.MenuEvent;
import mx.managers.PopUpManager;

use namespace mx_internal;

//--------------------------------------
//  Events
//-------------------------------------- 

/**
 *  Dispatched when a user selects an item from the pop-up menu.
 *
 *  @eventType mx.events.MenuEvent.ITEM_CLICK
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="itemClick", type="mx.events.MenuEvent")]

/**
 *  The name of a CSS style declaration used by the dropdown menu.  
 *  This property allows you to control the appearance of the dropdown menu.
 *  The default value sets the <code>fontWeight</code> to <code>normal</code> and 
 *  the <code>textAlign</code> to <code>left</code>.
 *
 *  @default "popUpMenu"
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="popUpStyleName", type="String", inherit="no")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="toggle", kind="property")]
[Exclude(name="selectedDisabledIcon", kind="style")]
[Exclude(name="selectedDisabledSkin", kind="style")]
[Exclude(name="selectedDownIcon", kind="style")]
[Exclude(name="selectedDownSkin", kind="style")]
[Exclude(name="selectedOverIcon", kind="style")]
[Exclude(name="selectedOverSkin", kind="style")]
[Exclude(name="selectedUpIcon", kind="style")]
[Exclude(name="selectedUpSkin", kind="style")]

//--------------------------------------
//  Other metadata
//-------------------------------------- 

//[IconFile("PopUpMenuButton.png")]

[RequiresDataBinding(true)]

/**
 *  The PopUpMenuButton control creates a PopUpButton control with a main
 *  sub-button and a secondary sub-button.
 *  Clicking on the secondary (right) sub-button drops down a menu that
 *  can be popluated through a <code>dataProvider</code> property. 
 *  Unlike the Menu and MenuBar controls, the PopUpMenuButton control 
 *  supports only a single-level menu. This means that the menu cannot contain
 *  cascading submenus.
 * 
 *  <p>The main sub-button of the PopUpMenuButton control can have a 
 *     text label, an icon, or both on its face.
 *     When a user selects an item from the drop-down menu or clicks 
 *     the main button of the PopUpMenuButton control, the control 
 *     dispatches an <code>itemClick</code> event.
 *     When a user clicks the main button of the 
 *     control, the control also dispatches a <code>click</code> event. 
 *     You can customize the look of a PopUpMenuButton control.</p>
 *
 *  <p>The PopUpMenuButton control has the following sizing 
 *     characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>Sufficient to accommodate the label and any icon on 
 *               the main button, and the icon on the pop-up button. 
 *               The control does not reserve space for the menu.</td>
 *        </tr>
 *        <tr>
 *           <td>Minimum size</td>
 *           <td>0 pixels.</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>10000 by 10000.</td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *  
 *  <p>The <code>&lt;mx:PopUpMenuButton&gt;</code> tag inherits all of the tag
 *  attributes of its superclass, and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;mx:PopUpMenuButton
 *    <strong>Properties</strong>
 *    dataDescriptor="<i>instance of DefaultDataDescriptor</i>"
 *    dataProvider="undefined"
 *    iconField="icon"
 *    iconFunction="undefined"
 *    labelField="label"
 *    labelFunction="undefined"
 *    showRoot="false|true"
 *    &nbsp;
 *    <strong>Event</strong>
 *    change=<i>No default</i>
 *  /&gt;
 *  </pre>
 *
 *  @includeExample examples/PopUpButtonMenuExample.mxml
 *
 *  @see mx.controls.Menu
 *  @see mx.controls.MenuBar
 *
 *  @tiptext Provides ability to pop up a menu and act as a button
 *  @helpid 3441
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class PopUpMenuButton extends PopUpButton
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function PopUpMenuButton()
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
     */
    private var dataProviderChanged:Boolean = false;
    
    /**
     *  @private
     */
    private var labelSet:Boolean = false;
    
    /**
     *  @private
     */
    private var popUpMenu:Menu = null;
    
    /**
     *  @private
     */
    private var selectedIndex:int = -1;
    
    /**
     *  @private
     */ 
    private var itemRenderer:IListItemRenderer = null;
    
    /**
     *  @private
     */ 
    private var explicitIcon:Class = null;
    
    /**
     *  @private
     */ 
    private var menuSelectedStyle:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    /**
     *  A reference to the pop-up Menu object.
     *
     *  <p>This property is read-only, and setting it has no effect.
     *  Set the <code>dataProvider</code> property, instead.
     *  (The write-only indicator appears in the syntax summary because the
     *  property in the superclass is read-write and this class overrides
     *  the setter with an empty implementation.)</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function set popUp(value:IUIComponent):void
    {
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    // dataDescriptor
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Storage for the dataDescriptor property.
     */
    private var _dataDescriptor:IMenuDataDescriptor =
                                        new DefaultDataDescriptor();
    
    /**
     *  The data descriptor accesses and manipulates data in the data provider.
     *  <p>When you specify this property as an attribute in MXML, you must
     *  use a reference to the data descriptor, not the string name of the
     *  descriptor. Use the following format for the property:</p>
     *
     *  <pre>&lt;mx:PopUpMenuButton id="menubar" dataDescriptor="{new MyCustomDataDescriptor()}"/&gt;</pre>
     *
     *  <p>Alternatively, you can specify the property in MXML as a nested
     *  subtag, as the following example shows:</p>
     *
     *  <pre>&lt;mx:PopUpMenuButton&gt;
     *  &lt;mx:dataDescriptor&gt;
     *     &lt;myCustomDataDescriptor&gt;
     *  &lt;/mx:dataDescriptor&gt;
     *  ...</pre>
     *
     *  <p>The default value is an internal instance of the
     *  DefaultDataDescriptor class.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get dataDescriptor():IMenuDataDescriptor
    {
        return IMenuDataDescriptor(_dataDescriptor);
    }

    /**
     *  @private
     */
    public function set dataDescriptor(value:IMenuDataDescriptor):void
    {
        _dataDescriptor = value;
    }

    //--------------------------------------------------------------------------
    // dataProvider
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Storage for dataProvider property.
     */
    private var _dataProvider:Object = null;

    [Bindable("collectionChange")]
    [Inspectable(category="Data", defaultValue="null")]

    /**
     *  DataProvider for popUpMenu.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get dataProvider():Object
    {
        if (popUpMenu)
            return Menu(popUpMenu).dataProvider;
        return _dataProvider;
    }

    /**
     *  @private
     */
    public function set dataProvider(value:Object):void
    {
        _dataProvider = value;
        dataProviderChanged = true;
        
        invalidateProperties();     
    }
    
    //--------------------------------------------------------------------------
    //  iconField
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Storage for the iconField property.
     */
    private var _iconField:String = "icon";

    [Bindable("iconFieldChanged")]
    [Inspectable(category="Data", defaultValue="icon")]

    /**
     *  Name of the field in the <code>dataProvider</code> Array that contains the icon to
     *  show for each menu item.
     *  The <code>iconFunction</code> property, if set, overrides this property.
     * 
     *  <p>The item renderer looks in the data provider for a property with 
     *  the name specified to the <code>iconField</code> property.  
     *  If the value of the property is a 
     *  Class, it instantiates that class and expect it to be an instance 
     *  of an IFlexDisplayObject. If the value of the property is a String, 
     *  it looks to see if a Class property exists with that name in the application. 
     *  If it can't find a property on the application, it looks for a property on the 
     *  document with that name and expect that property to map to a Class.</p>
     * 
     *  <p>If the data provider is an E4X XML object, you must set this property
     *  explicitly; for example, use &#064;icon to specify the <code>icon</code> attribute.</p>
     *
     *  @default "icon"
     */
    public function get iconField():String
    {
        return _iconField;
    }

    /**
     *  @private
     */
    public function set iconField(value:String):void
    {
        if (_iconField != value)
        {
            _iconField = value;
            
            if (popUpMenu)
                popUpMenu.iconField = _iconField;
            
            dispatchEvent(new Event("iconFieldChanged"));
        }
    }

    //--------------------------------------------------------------------------
    //  iconFunction
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Storage for the iconFunction property.
     */
    private var _iconFunction:Function;

    [Inspectable(category="Data")]

    /**
     *  A function that determines the icon to display for each menu item.
     *  If you omit this property, Flex uses the contents of the field or attribute
     *  determined by the <code>iconField</code> property.
     *  If you specify this property, Flex ignores any <code>iconField</code>
     *  property value.
     *
     *  <p>By default, the menu does not try to display icons with the text 
     *  in the rows.  However, by specifying an icon function, you can specify 
     *  a Class for a graphic that will be created and displayed as an icon 
     *  in the row. </p>
     *
     *  <p>The iconFunction takes a single argument which is the item
     *  in the data provider and returns a Class:</p>
     * 
     *  <blockquote>
     *  <code>iconFunction(item:Object):Class</code>
     *  </blockquote>
     *
     *  @default null
     */
    public function get iconFunction():Function
    {
        return _iconFunction;
    }

    /**
     *  @private
     */
    public function set iconFunction(value:Function):void
    {
        if (_iconFunction != value)
        {
            _iconFunction = value;
            
            if (popUpMenu)
                popUpMenu.iconFunction = _iconFunction;
        }
    }

    //--------------------------------------------------------------------------
    //  label
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Storage for the label property.
     */
    private var _label:String = "";

    [Inspectable(category="General", defaultValue="")]

    /**
     *  @private
     */
    override public function set label(value:String):void
    {
        // labelSet is different from labelChanged as it is never unset.
        labelSet = true;
        _label = value;
        super.label = _label;
    }

    //--------------------------------------------------------------------------
    //  labelField
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Storage for the labelField property.
     */
    private var _labelField:String = "label";

    [Bindable("labelFieldChanged")]
    [Inspectable(category="Data", defaultValue="label")]

    /**
     *  Name of the field in the <code>dataProvider</code> Array that contains the text to
     *  show for each menu item.
     *  The <code>labelFunction</code> property, if set, overrides this property.
     *  If the data provider is an Array of Strings, Flex uses each String
     *  value as the label.
     *  If the data provider is an E4X XML object, you must set this property
     *  explicitly; for example, use &#064;label to specify the <code>label</code> attribute.
     *
     *  @default "label"
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
        if (_labelField != value)
        {
            _labelField = value;
            
            if (popUpMenu)
                popUpMenu.labelField = _labelField;
            
            dispatchEvent(new Event("labelFieldChanged"));
        }
    }

    //--------------------------------------------------------------------------
    //  labelFunction
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Storage for the labelFunction property.
     */
    private var _labelFunction:Function;

    [Inspectable(category="Data")]

    /**
     *  A function that determines the text to display for each menu item.
     *  If you omit this property, Flex uses the contents of the field or attribute
     *  determined by the <code>labelField</code> property.
     *  If you specify this property, Flex ignores any <code>labelField</code>
     *  property value.
     *
     *  <p>If you specify this property, the label function must find the
     *  appropriate field or fields and return a displayable string.
     *  The <code>labelFunction</code> property is good for handling formatting
     *  and localization.</p>
     *
     *  <p>The label function must take a single argument which is the item
     *  in the dataProvider and return a String, as the following example shows:</p>
     * 
     *  <pre>labelFunction(item:Object):String</pre>
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get labelFunction():Function
    {
        return _labelFunction;
    }

    /**
     *  @private
     */
    public function set labelFunction(value:Function):void
    {
        if (_labelFunction != value)
        {
            _labelFunction = value;
            
            if (popUpMenu)
                popUpMenu.labelFunction = _labelFunction;
        }
    }

    //--------------------------------------------------------------------------
    //  showRoot
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Storage for the showRoot property.
     */
    mx_internal var _showRoot:Boolean = true;

    /**
     *  @private
     */
    private var _showRootChanged:Boolean = false;

    [Inspectable(category="Data", enumeration="true,false", defaultValue="true")]

    /**
     *  Specifies whether to display the top-level node or nodes of the data provider.
     *
     *  If this is set to <code>false</code>, the control displays
     *  only descendants of the first top-level node.
     *  Any other top-level nodes are ignored.
     *  You normally set this property to <code>false</code> for
     *  E4X format XML data providers, where the top-level node is the document
     *  object.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get showRoot():Boolean
    {
        return _showRoot;
    }

    /**
     *  @private
     */
    public function set showRoot(value:Boolean):void
    {
        if (_showRoot != value)
        {
            _showRoot = value;
            _showRootChanged = true;

            invalidateProperties();
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        if (dataProviderChanged && !popUpMenu)
        {
            // In general we shouldn't create the popUp until
            // they are actually popped up. However, in this case
            // the initial label, icon and action on the main button's 
            // click are to be borrowed from the popped menu. 
            // Moreover since PopUpMenuButton doesn't expose selectedIndex
            // selectedItem etc., one should be able to access them
            // prior to popping up the menu.        
            getPopUp();
        }
        
        if (_showRootChanged)
        {
            _showRootChanged = false;
            if (popUpMenu != null)
                popUpMenu.showRoot = _showRoot;
            invalidateDisplayList();
        }

        if (popUpMenu && dataProviderChanged)
        {
            popUpMenu.dataProvider = _dataProvider;
            popUpMenu.validateNow();

            if (dataProvider.length)
            {
                selectedIndex = 0;
                
                var cursor:IViewCursor = dataProvider.createCursor()
                cursor.seek(CursorBookmark.FIRST, 0);

                var item:* = cursor.current;
                
                // Set button label.
                if (labelSet)
                    super.label = _label;
                else
                    super.label = popUpMenu.itemToLabel(item);
                
                // Set button icon,
                setSafeIcon(popUpMenu.itemToIcon(item));
            }
            else
            {
                selectedIndex = -1;
                
                if (labelSet)
                    super.label = _label;
                else
                    super.label = "";
                
                clearStyle("icon");
            }

            dataProviderChanged = false;
        }

        super.commitProperties();
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);
        //style is actually set here already.
        if (styleProp == "icon" || styleProp == null || styleProp == "styleName" ) 
        {
            if (menuSelectedStyle)
            {
                if (explicitIcon)
                {
                    menuSelectedStyle = false;
                    setStyle("icon", explicitIcon);
                }
            }
            else
            {
                explicitIcon = getStyle("icon");
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: PopUpButton
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override mx_internal function getPopUp():IUIComponent
    {
        super.getPopUp();

        if (!popUpMenu || !super.popUp)
        {
            popUpMenu = new Menu();
            popUpMenu.iconField = _iconField;
            popUpMenu.iconFunction = _iconFunction;
            popUpMenu.labelField = _labelField;
            popUpMenu.labelFunction = _labelFunction;
            popUpMenu.showRoot = _showRoot;
            popUpMenu.dataDescriptor = _dataDescriptor;
            popUpMenu.dataProvider = _dataProvider;
            popUpMenu.addEventListener(MenuEvent.ITEM_CLICK, menuChangeHandler);
            popUpMenu.addEventListener(FlexEvent.VALUE_COMMIT,
                                       menuValueCommitHandler);
            super.popUp = popUpMenu;
            // Add PopUp to PopUpManager here so that
            // commitProperties of Menu gets called even
            // before the PopUp is opened. This is 
            // necessary to get the initial label and dp.
            PopUpManager.addPopUp(super.popUp, this, false);
            super.popUp.owner = this;
        }

        return popUpMenu;
    }
    
    //--------------------------------------------------------------------------
    //
    //   private helper methods
    //
    //--------------------------------------------------------------------------
    
     /**
     *  @private
     */
     private function setSafeIcon(iconClass:Class):void
     {
          menuSelectedStyle = true;
          setStyle("icon", iconClass);
          menuSelectedStyle = false;
     }

    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers: Button
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function clickHandler(event:MouseEvent):void
    {
        super.clickHandler(event);

        if (!overArrowButton(event))
            menuClickHandler(event);
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function menuClickHandler(event:MouseEvent):void
    {
        if (selectedIndex >= 0)
        {
            var menuEvent:MenuEvent = new MenuEvent(MenuEvent.ITEM_CLICK);
            menuEvent.menu = popUpMenu;
            menuEvent.menu.selectedIndex = selectedIndex;

            var cursor:IViewCursor = dataProvider.createCursor();
            cursor.seek(CursorBookmark.FIRST, selectedIndex);

            menuEvent.item =  cursor.current
            menuEvent.itemRenderer = itemRenderer;
            menuEvent.index = selectedIndex;
            menuEvent.label =
                popUpMenu.itemToLabel(cursor.current);
            dispatchEvent(menuEvent);
            
            // Reset selection after the change event is dispatched
            // just like in a menu.
            popUpMenu.selectedIndex = -1;
        }
    }

    /**
     *  @private
     */
    private function menuValueCommitHandler(event:FlexEvent):void
    {
        // Change label/icon if selectedIndex is changed programatically.
        if (popUpMenu.selectedIndex >= 0)
        {
            var cursor:IViewCursor = dataProvider.createCursor();
            cursor.seek(CursorBookmark.FIRST, selectedIndex);

            selectedIndex = popUpMenu.selectedIndex;
            if (labelSet)
                super.label = _label;
            else
                super.label = popUpMenu.itemToLabel(cursor.current);
            setSafeIcon(popUpMenu.itemToIcon(cursor.current));
        }
    }

    /**
     *  @private
     */
    private function menuChangeHandler(event:MenuEvent):void
    {
        if (event.index >= 0)
        {
            var menuEvent:MenuEvent = new MenuEvent(MenuEvent.ITEM_CLICK);
            
            menuEvent.label = popUpMenu.itemToLabel(event.item);
            if (labelSet)
                super.label = _label;
            else
                super.label = popUpMenu.itemToLabel(event.item);
            setSafeIcon(popUpMenu.itemToIcon(event.item));
            menuEvent.menu = popUpMenu;
            menuEvent.menu.selectedIndex = menuEvent.index = 
                selectedIndex = event.index;
            menuEvent.item = event.item;
            itemRenderer = menuEvent.itemRenderer = 
                event.itemRenderer;
            dispatchEvent(menuEvent);
        }
    }
}

}
