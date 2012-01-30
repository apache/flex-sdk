////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{
import flash.display.DisplayObjectContainer;
import flash.display.StageAspectRatio;
import flash.events.Event;

import mx.core.EventPriority;
import mx.core.FlexGlobals;
import mx.core.IDeferredInstance;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.ResizeEvent;

import spark.components.supportClasses.ViewNavigatorBase;
import spark.events.ElementExistenceEvent;
import spark.events.PopUpEvent;
import spark.transitions.ViewTransitionBase;

use namespace mx_internal;

//--------------------------------------
//  SkinStates
//--------------------------------------

/**
 *  The skin state when the <code>aspectRatio</code> of the main 
 *  application is portrait.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
[SkinState("portrait")]

/**
 *  The skin state when the <code>aspectRatio</code> of the main
 *  application is landscape.
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
[SkinState("landscape")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("SplitViewNavigator.png")]

/**
 *  The SplitViewNavigator container displays multiple
 *  ViewNavigator or TabbedViewNavigator components at the same time in a single container.  
 *  Each child of the SplitViewNavigator defines one pane of the screen.
 *  Because its children are view navigators, the view navigator for each 
 *  pane contains its own view stack and action bar.
 *
 *  <p>The following image shows the SplitViewNavigator container in a 
 *  horizontal layout with a master and detail pane:</p>
 *
 * <p>
 *  <img src="../../images/svn_master_detail_svn.png" alt="SplitViewNavigator" />
 * </p>
 *
 *  <p>SplitViewNavigator takes ViewnNavigatorBase objects as children, and lays them out as
 *  defined by its <code>layout</code> property.  
 *  This component is useful for creating a master/detail interface on a mobile device. 
 *  There is no limit to the amount of child navigators this component can manage. </p>
 *
 *  <p><b>Note:</b> Because of the screen space required to display multiple panes 
 *  simultaneously, Adobe recommends that you only use the SplitViewNavigator on a tablet
 *  device.</p>
 * 
 *  <p>If the <code>autoHideFirstViewNavigator</code> property is set to
 *  <code>true</code>, the SplitViewNavigator automatically hides the
 *  navigator that is at index 0 when the top level application has a
 *  portrait aspect ratio.  
 *  The navigator reappears when the application is reoriented to a landsacpe aspect ratio.  
 *  You can manually hide and show a navigator by toggling the <code>visble</code>
 *  flag on the child.  When set, the <code>includeInLayout</code> property
 *  of that child will be set to match.</p>
 *    
 *  <p>SplitViewNavigator lets you  display the first navigator in a 
 *  popup.  By default, it uses a Callout component.  
 *  When you call the <code>showFirstViewNavigatorInPopUp()</code> method, the
 *  first navigator is displayed in a popup until the
 *  <code>hideViewNavigatorPopUp()</code> method is called, or the user
 *  touches outside the bounds of the popup.  
 *  It is important to note that when a navigator is displayed in a popup, 
 *  it is reparented as a child of that container.  
 *  This means that using IVisualElementContainer methods such as
 *  <code>getElementAt()</code> on SplitViewNavigator may not return the 
 *  expected results.  
 *  If you want to access the first or second  navigator, Adobe recommends 
 *  that you use the <code>getViewNavigatorAt()</code>  method.  
 *  This method always returns the correct navigator regardless of whether 
 *  a navigator is in a popup or not.</p>
 *
 *  <p>By default, when the popup is opened, it is sized to the preferred width 
 *  and height of the first navigator.  The size of the popup can be changed by
 *  explicitly setting its width and height or by reskinning the component.</p>
 * 
 *  <p><b>Note:</b> When a SplitViewNavigator is used as a child of a 
 *  TabbedViewNavigator, changes to the <code>tabBarVisible</code> on the
 *  active views will not be honored by the parent TabbedViewNavigator.</p>
 * 
 *  @mxml <p>The <code>&lt;s:SplitViewNavigator&gt;</code> tag inherits all of the tag
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:SplitViewNavigator
 *    <strong>Properties</strong>
 *    autoHideFirstViewNavigator="false"
 *  /&gt;
 *  </pre>
 *  
 *  @see spark.skins.mobile.SplitViewNavigatorSkin
 *  @see spark.components.supportClasses.ViewNavigatorBase
 *  @see spark.components.ViewNavigator
 *  @see spark.components.TabbedViewNavigator
 *  @see spark.components.Application#aspectRatio
 *  @see spark.components.Callout
 *  @see spark.components.SkinnablePopUpContainer
 *
 *  @includeExample examples/SplitViewNavigatorExample.mxml -noswf
 *  @includeExample examples/views/DetailView.mxml -noswf
 *  @includeExample examples/views/MasterView.mxml -noswf
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public class SplitViewNavigator extends ViewNavigatorBase
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function SplitViewNavigator()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    [SkinPart(required="false")]
    /**
     *  The popUp used to display a navigator when 
     *  <code>showFirstViewNavigatorInPopUp()</code> is called.  
     *  When creating a custom MXML skin, this component should not be on the display list, 
     *  but instead declared inside a <code>fx:Declarations</code> tag. 
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public var viewNavigatorPopUp:SkinnablePopUpContainer;
    
    //--------------------------------------------------------------------------
    //
    // Variables
    // 
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Tracks what the last aspectRatio of the application was to determine
     *  whether the component should hide or show the first navigator when
     *  <code>autoHideFirstNavigator is set to true</code>.
     */
    private var lastAspectRatio:String;
    
    /**
     *  @private
     *  Stores the original element index of the navigator that is reparented
     *  into the popup.
     */
    private var _popUpNavigatorIndex:int = -1;
    
    /**
     *  @private
     *  A reference to the navigator that is being displayed inside the popUp 
     */
    private var _popUpNavigator:ViewNavigatorBase = null;
    
    /**
     *  @private
     *  Object is used to store old layout constraints of a view navigator
     *  before opening it in a popup.
     */
    private var _popUpNavigatorSizeCache:Object = null;
    
    //--------------------------------------------------------------------------
    //
    // Properties
    // 
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  autoHideFirstViewNavigator
    //----------------------------------
    
    private var _autoHideFirstViewNavigator:Boolean = false;
    
    [Inspectable(category="General", defaultValue="false")]
    /**
     *  Specifies whether the visibility of the first view navigator should 
     *  automatically be toggled when the device receives an orientation change event.  
     *  When <code>true</code>, the first navigator is hidden as the device enters the portrait 
     *  orientation, and shown when entering a landscape orientation.
     * 
     *  <p>If this flag is set to <code>true</code> while the application is in a portrait
     *  orientation, the navigator is not hidden until the next orientation
     *  resize event.</p>
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function get autoHideFirstViewNavigator():Boolean
    {
        return _autoHideFirstViewNavigator;
    }
    
    /**
     *  @private
     */ 
    public function set autoHideFirstViewNavigator(value:Boolean):void
    {
        if (_autoHideFirstViewNavigator == value)
            return;
        
        _autoHideFirstViewNavigator = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    // 
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  mxmlContentFactory
    //----------------------------------
    
    [InstanceType("Array")]
    [ArrayElementType("spark.components.supportClasses.ViewNavigatorBase")]
    /**
     *  @private
     *  Override this setter so that we can restrict the mxmlContent type to 
     *  ViewNavigatorBase. 
     */
    override public function set mxmlContentFactory(value:IDeferredInstance):void
    {
        super.mxmlContentFactory = value;
    }
    
    //----------------------------------
    //  initialized
    //----------------------------------
    /**
     *  @private
     */
    override public function set initialized(value:Boolean):void 
    {
        // Add application resize event listener.  We want this navigator's
        // resize handler to run before any others due to conflicts with
        // states.  See SDK-31575.
        FlexGlobals.topLevelApplication.addEventListener(ResizeEvent.RESIZE, 
            application_resizeHandler, false, EventPriority.BINDING, true);
        
        // Toggle visibility of the first ViewNavigator if autoHideFirstViewNavigator is true
        if (numViewNavigators > 0 && autoHideFirstViewNavigator)
            application_resizeHandler(null);
        
        super.initialized = value;
    }
    
    
    //----------------------------------
    //  numViewNavigators
    //----------------------------------
    /**
     *  The number of view navigators managed by this container.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public function get numViewNavigators():int
    {
        return _popUpNavigatorIndex == -1 ? numElements : numElements + 1;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Public Methods
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  Returns a specific child navigator independent of the container's
     *  child display hierarchy.  
     *  Since a child navigator is not parented by this
     *  container when visible inside a popup, this method should be used instead of 
     *  <code>getElementAt()</code>.
     * 
     *  <p>When a popup is open, the navigator at index 0 refers to the
     *  navigator in the popup.</p> 
     * 
     *  @param index Index of the navigator to retrieve.
     * 
     *  @return The navigator at the specified index, null if one does not exist.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public function getViewNavigatorAt(index:int):ViewNavigatorBase
    {
        // If the index is the navigator currently in the popup, return it
        if (_popUpNavigatorIndex == index)
            return _popUpNavigator;
        
        // Since a popup is visible, one of the navigators has been removed
        // from this display tree.  If the index of the navigator in the popup
        // is before the passed index, decrement it by 1 so that it reflects 
        // the current indicies of the child navigatos.
        if (_popUpNavigatorIndex != -1 && _popUpNavigatorIndex < index)
            index--;
        
        if (index >= numElements)
            return null;
        
        return getElementAt(index) as ViewNavigatorBase;
    }
    
    /**
     *  Displays the child navigator at index 0 inside a popup.  
     *  The navigator is reparented as a child of the popop.
     * 
     *  <p>Since the navigator is reparented, using <code>getElementAt(0)</code> 
     *  does not return the first navigator, but returns the second.  
     *  Adobe recommends that you use the <code>getViewNavigatorAt()</code>
     *  method to access the navigators.</p>
     * 
     *  <p>The popup height is not set by this component.  The height sizes to
     *  fit the View currently active in the ViewNavigator.  A height can be set
     *  by reskinning this component or by manually setting the <code>height</code> 
     *  property on the <code>viewNavigatorPopUp</code> skinPart.</p>
     * 
     *  <p>If the popup is already open or the popup skin part does not exist, 
     *  this method does nothing.</p>
     * 
     *  <p>It is recommended that this method only be used on ViewNavigators
     *  that are currently hidden.</p>
     *
     *  @param owner The owner of the popup. The popup is positioned relative to
     *  its owner.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public function showFirstViewNavigatorInPopUp(owner:DisplayObjectContainer):void
    {
        showNavigatorAtIndexInPopUp(0, owner);
    }

    /**
     *  Hides the navigator popup if its open.  The navigator that was
     *  displayed in the popup is reparented as a child of this
     *  SplitViewNavigator.
     * 
     *  <p>This method is automatically called if the user touches outside 
     *  of the popup when it is visible.  The navigator inside the popup
     *  is hidden after the popup closes.</p>
     * 
     *  <p>After closing the popup, the navigator that was shown remains
     *  invisible unless <code>autoHideFirstViewNavigator</code> is <code>true</code>
     *  and the device orientation is landscape.  
     *  In all other cases, the visibility of the first navigator needs to be set 
     *  to <code>true</code> to make it visible again.</p>
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public function hideViewNavigatorPopUp():void
    {
        if (!viewNavigatorPopUp|| !viewNavigatorPopUp.isOpen)
            return;
        
        // Since view transitions can temporarily alter the display tree, we
        // need to end all view transitions so that the display tree is restored
        // to a correct state.
        ViewTransitionBase.endTransitions();
        
        // Cleanup handled by viewNavigatorPopUp_closeHandler
        viewNavigatorPopUp.close(true);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Shows the navigator at the specified index in the popup component.
     */ 
    mx_internal function showNavigatorAtIndexInPopUp(index:int, owner:DisplayObjectContainer):void
    {
        if (index >= numElements || !viewNavigatorPopUp|| viewNavigatorPopUp.isOpen)
            return;

        // Since view transitions can temporarily alter the display tree, we
        // need to end all view transitions so that the display tree is restored
        // to a correct state.
        ViewTransitionBase.endTransitions();

        _popUpNavigatorIndex = index;
        _popUpNavigator = getElementAt(index) as ViewNavigatorBase;

        // Save navigators current layout constraints
        _popUpNavigatorSizeCache = { percentWidth: _popUpNavigator.percentWidth,
                                     percentHeight: _popUpNavigator.percentHeight,
                                     explicitWidth: _popUpNavigator.explicitWidth,
                                     explicitHeight: _popUpNavigator.explicitHeight };
        
        // If an explict width or height is not set on the navigator, change
        // the percent bounds to 100% so that the navigator fills the entire
        // bounds of the popup.
        if (isNaN(_popUpNavigator.explicitWidth))
            _popUpNavigator.percentWidth = 100;
        
        if (isNaN(_popUpNavigator.explicitHeight))
            _popUpNavigator.percentHeight = 100;
        
        viewNavigatorPopUp.addEventListener(PopUpEvent.OPEN, viewNavigatorPopUp_openHandler);
        viewNavigatorPopUp.addEventListener(PopUpEvent.CLOSE, viewNavigatorPopUp_closeHandler);
        viewNavigatorPopUp.addEventListener('mouseDownOutside', navigatorPopUp_mouseDownOutsideHandler, false, 0, true);
        viewNavigatorPopUp.addElement(_popUpNavigator);
        
        // Make sure the first navigator is visible
        _popUpNavigator.visible = true;
        
        // Open the popup
        viewNavigatorPopUp.open(owner, true);
    }

    /**
     *  @private
     */
    private function viewNavigatorPopUp_openHandler(event:Event):void
    {
        event.target.removeEventListener(PopUpEvent.OPEN, viewNavigatorPopUp_openHandler);
        
        // Since an open transition may have the disableLayout property set to true,
        // the popup size may not be valid yet.  Force a validation to ensure that the
        // component is properly laid out.
        viewNavigatorPopUp.validateNow();

        _popUpNavigatorSizeCache.viewNavigatorPopUpWidth = viewNavigatorPopUp.explicitWidth;
        _popUpNavigatorSizeCache.viewNavigatorPopUpHeight = viewNavigatorPopUp.explicitHeight;
        
        // If the width or height of the popup isn't explicitly set, we size the
        // popup so that the size doesn't change as the active view of the navigator
        // changes.
        if (isNaN(viewNavigatorPopUp.explicitWidth))
            viewNavigatorPopUp.explicitWidth = viewNavigatorPopUp.width;
        
        if (isNaN(viewNavigatorPopUp.explicitHeight))
            viewNavigatorPopUp.explicitHeight = viewNavigatorPopUp.height;
    }
    
    /**
     *  @private
     */ 
    private function viewNavigatorPopUp_closeHandler(event:PopUpEvent):void
    {
        viewNavigatorPopUp.removeEventListener(PopUpEvent.CLOSE, viewNavigatorPopUp_closeHandler);
        viewNavigatorPopUp.removeEventListener('mouseDownOutside', navigatorPopUp_mouseDownOutsideHandler);
        
        if (_popUpNavigator)
            restoreNavigatorInPopUp();
        
        // When an orientation change occurs, the popup's visibility may be set to false.
        // Set it back to true so that it is visible the next time it is opened.
        viewNavigatorPopUp.visible = true;
    }
    
    /**
     *  @private
     */ 
    private function restoreNavigatorInPopUp():void
    {
        // Restore old layout constraints
        viewNavigatorPopUp.explicitWidth = _popUpNavigatorSizeCache.viewNavigatorPopUpWidth;
        viewNavigatorPopUp.explicitHeight = _popUpNavigatorSizeCache.viewNavigatorPopUpHeight;
        
        _popUpNavigator.percentWidth = _popUpNavigatorSizeCache.percentWidth;
        _popUpNavigator.percentHeight = _popUpNavigatorSizeCache.percentHeight;
        _popUpNavigator.explicitWidth = _popUpNavigatorSizeCache.explicitWidth;
        _popUpNavigator.explicitHeight = _popUpNavigatorSizeCache.explicitHeight;        
        _popUpNavigatorSizeCache = null;
        
        // Restore navigator parent
        addElementAt(_popUpNavigator, _popUpNavigatorIndex);
        
        if (autoHideFirstViewNavigator && _popUpNavigatorIndex == 0)
        {
            toggleFirstNavigatorVisibility();
        }
        else
        {
            _popUpNavigator.visible = false;
        }
        
        _popUpNavigator = null;
        _popUpNavigatorIndex = -1;
    }
    
    /**
     *  @private
     */
    private function elementAddHandler(event:ElementExistenceEvent):void
    {
        var navigator:ViewNavigatorBase = event.element as ViewNavigatorBase;
        
        if (navigator)
            setupNavigator(navigator);
    }
    
    /**
     *  @private
     */
    private function elementRemoveHandler(event:ElementExistenceEvent):void
    {
        if (event.element != _popUpNavigator)
        {
            var navigator:ViewNavigatorBase = event.element as ViewNavigatorBase;
            
            if (navigator)
               cleanUpNavigator(event.element as ViewNavigatorBase);
        }
    }
    
    /**
     *  @private
     */
    mx_internal function application_resizeHandler(event:ResizeEvent):void
    {
        if (numViewNavigators == 0)
            return;
        
        var aspectRatio:String = FlexGlobals.topLevelApplication.aspectRatio;
        
        // Only do the logic below if the aspectRatio has changed
        if (lastAspectRatio == aspectRatio)
            return;
        
        lastAspectRatio = aspectRatio;

        // Since view transitions can temporarily alter the display tree, we
        // need to end all view transitions so that the display tree is restored
        // to a correct state.
        ViewTransitionBase.endTransitions();
        
        if (autoHideFirstViewNavigator)
        {
            // The navigator in the popup needs to be immediately reparented
            // when the orientation changes since we don't provide orientation
            // effects.  Because of this, we don't want to see any close
            // transitions to play on the popup.  Since the transitions are
            // defined on the skin, there is no way to intercept them, so instead
            // the popup is hidden.  restoreNavigatorInPopUp() will call
            // toggleFirstNavigatorVisibility() if needed.
            if (_popUpNavigator)
            {
                restoreNavigatorInPopUp();
                viewNavigatorPopUp.visible = false;
            }
            else
            {
                toggleFirstNavigatorVisibility();
            }
        }
        
        // The navigator popup is always hidden if the orientation changes 
        hideViewNavigatorPopUp();
    }
    
    /**
     *  @private
     */
    private function toggleFirstNavigatorVisibility():void
    {
        if (numViewNavigators == 0)
            return;
        
        var aspectRatio:String = FlexGlobals.topLevelApplication.aspectRatio;
        var firstViewNavigator:ViewNavigatorBase = getViewNavigatorAt(0);
        
        if (aspectRatio == StageAspectRatio.PORTRAIT)
        {
            firstViewNavigator.visible = false;
        }
        else
        {
            firstViewNavigator.visible = true;
        }
    }
    
    /**
     *  @private
     */
    private function navigatorPopUp_mouseDownOutsideHandler(event:Event):void
    {
        hideViewNavigatorPopUp();
    }
    
    /**
     *  @private
     */
    private function setupNavigator(navigator:ViewNavigatorBase):void
    {
        navigator.setParentNavigator(this);
        
        // Add weak listeners for hide and show events on the navigator.  When
        // a navigator is hidden, its container is removed from layout.
        navigator.addEventListener(FlexEvent.HIDE, navigator_visibilityChangedHandler, false, EventPriority.DEFAULT, true);
        navigator.addEventListener(FlexEvent.SHOW, navigator_visibilityChangedHandler, false, EventPriority.DEFAULT, true);
        
        // Remove the navigator from layout if it isn't visible
        if (navigator.visible == false)
            navigator.includeInLayout = false;
    }
    
    /**
     *  @private
     */
    private function cleanUpNavigator(navigator:ViewNavigatorBase):void
    {
        navigator.setParentNavigator(null);
        navigator.removeEventListener(FlexEvent.HIDE, navigator_visibilityChangedHandler);
        navigator.removeEventListener(FlexEvent.SHOW, navigator_visibilityChangedHandler);
    }
    
    /**
     *  @private
     */
    private function navigator_visibilityChangedHandler(event:FlexEvent):void
    {
        var navigator:ViewNavigatorBase = event.target as ViewNavigatorBase;
    
        if (event.type == FlexEvent.HIDE && navigator == _popUpNavigator)
            hideViewNavigatorPopUp();

        navigator.includeInLayout = navigator.visible;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overriden Methods: ViewNavigatorBase
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function updateControlsForView(view:View):void
    {
        // This method is a no-op so that child views can't impact the
        // display properties of navigators above it.  This essentially prevents
        // View.tabBarVisible from interacting with TabbedViewNavigators that
        // are parents of this SplitViewNavigator.
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    override public function loadViewData(value:Object):void
    {
        super.loadViewData(value);
        
        var dataArray:Array = value.dataArray;
        
        // If the data array is null, we won't restore any data
        if (!dataArray)
            return;
        
        // Restore each navigators' persistence data
        for (var i:int = 0; i < numViewNavigators; i++)
        {
            if (i >= dataArray.length)
                break;
            
            getViewNavigatorAt(i).loadViewData(dataArray[i]);
        }
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    override public function saveViewData():Object
    {
        var object:Object = super.saveViewData();
        var dataArray:Array = new Array();
        
        // Push each navigator's persistence object to the data array
        for (var i:int = 0; i < numViewNavigators; i++)
            dataArray.push(getViewNavigatorAt(i).saveViewData());
        
        object.dataArray = dataArray;
        return object;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods: UIComponent
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */ 
    override protected function partAdded(partName:String, instance:Object):void
    {
        // Add event listeners before the child are added to the contentGroup
        if (instance == contentGroup)
        {
            contentGroup.addEventListener(ElementExistenceEvent.ELEMENT_ADD, elementAddHandler);
            contentGroup.addEventListener(ElementExistenceEvent.ELEMENT_REMOVE, elementRemoveHandler);
        }
        
        super.partAdded(partName, instance);
    }
    
    /**
     *  @private
     */ 
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == contentGroup)
        {
            contentGroup.removeEventListener(ElementExistenceEvent.ELEMENT_ADD, elementAddHandler);
            contentGroup.removeEventListener(ElementExistenceEvent.ELEMENT_REMOVE, elementRemoveHandler);
        }
    }
    
    /**
     *  @private
     */ 
    override public function validateNow():void
    {
        // If a navigator is currently inside a popup, force a validation on it as well.  
        // This was added because ViewNavigator will call validateNow on its parentNavigator 
        // when preparing to do a view transition.  Since the popup navigator is no longer 
        // a child of this SplitViewNavigator, the navigator in the popup isn't validated 
        // as expected.
        if (_popUpNavigatorIndex != -1)
            _popUpNavigator.validateNow();
        
        super.validateNow();
    }
}
}