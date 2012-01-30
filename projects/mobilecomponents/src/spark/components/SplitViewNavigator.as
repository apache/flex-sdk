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

use namespace mx_internal;

//--------------------------------------
//  SkinStates
//--------------------------------------

/**
 *  This skin state is triggered when the aspectRatio of the main 
 *  application is changed to portrait.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */
[SkinState("portrait")]

/**
 *  The state is triggered when the aspectRatio of the main
 *  application is changed to landscape.
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */
[SkinState("landscape")]

/**
 *  SplitViewNavigator is a component responsible for displaying multiple
 *  ViewNavigators at the same time in a single container.  SplitViewNavigator
 *  takes ViewnNavigatorBase objects as children and lays them out as
 *  defined by its <code>layout</code> property.  This component is useful for 
 *  creating a master/detail interface on a mobile device. There is no limit to
 *  the amount of child navigators this component can manage. 
 * 
 *  <p>If the <code>autoHideFirstViewNavigator</code> property is set to
 *  <code>true</code>, the SplitViewNavigator will automatically hide the
 *  navigator that is at index 0 when the top level application has a
 *  portrait aspect ratio.  The navigator will be redisplayed when the
 *  application is reoriented into a landsacpe orientation.  A developer
 *  can manually hide and show a navigator by toggling the <code>visble</code>
 *  flag on the child.  When set, the <code>includeInLayout</code> property
 *  of that child will be set to match.</p>
 *    
 *  <p>SplitViewNavigator adds the additional functionalilty of temporarily 
 *  displaying the first navigator inside a Callout component.  When the
 *  <code>showFirstViewNavigatorInCallout()</code> method is called, the
 *  first navigator is displayed in a callout until the
 *  <code>hideViewNavigatorCallout()</code> method is called, or the user
 *  touches outside the bounds of the callout.  It is important to note that
 *  when a navigator is displayed in a callout, it is reparented as a child of
 *  that container.  This means using IVisualElementContainer methods such as
 *  <code>getElementAt()</code> on SplitViewNavigator may not return the 
 *  expected results.  If a developer wants to access the first or second 
 *  navigator, it is recommended that they use the <code>getViewNavigatorAt()</code> 
 *  method.  These will always return the correct navigator regardless of whether 
 *  a navigator is in a callout or not.</p>
 *  
 *  @see spark.components.ViewNavigatorBase
 *  @see spark.components.ViewNavigator
 *  @see spark.components.TabbedViewNavigator
 *  @see spark.components.Application#aspectRatio
 *  @see spark.components.Callout
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
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
     *  @productversion Flex 4.5.2
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
     *  The Callout used to display a navigator when 
     *  <code>showFirstViewNavigatorInCallout()</code> is called.
     */
    public var viewNavigatorCallout:Callout;
    
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
     *  into the callout.
     */
    private var _calloutNavigatorIndex:int = -1;
    
    /**
     *  @private
     *  A reference to the navigator that is being displayed in the callout 
     */
    private var _calloutNavigator:ViewNavigatorBase = null;
    
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
     *  This flag indicates whether the visibility of the first view navigator should 
	 *  automatically be toggled when the device receives an orientation change event.  
	 *  When true, the first navigator is hidden as the device enters the portrait 
	 *  orientation, and shown when entering a landscape orientation.
     * 
     *  <p>If this flag is set to true while the application is in a portrait
     *  orientation, the navigator is not hidden until the next orientation
     *  resize event.</p>
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
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
        // Add application resize event listener
        FlexGlobals.topLevelApplication.addEventListener(ResizeEvent.RESIZE, 
            application_resizeHandler, false, EventPriority.DEFAULT, true);
        
        // Toggle visibility of the first ViewNavigator if autoHideFirstViewNavigator is true
        if (numViewNavigators > 0 && autoHideFirstViewNavigator)
            application_resizeHandler(null);
        
        super.initialized = value;
    }
    
    
    //----------------------------------
    //  numViewNavigators
    //----------------------------------
    /**
     *  The number of navigators managed by this container
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */ 
    public function get numViewNavigators():int
    {
        return _calloutNavigatorIndex == -1 ? numElements : numElements + 1;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Public Methods
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  This method returns a specific child navigator independent of the container's
     *  child display hierarchy.  Since a child navigator is not parented by this
     *  container when visible inside a callout, this method should be used instead of 
     *  <code>getElementAt()</code>.
     * 
     *  <p>When a callout is open, the navigator at index 0 will refer to the
     *  navigator in the callout.</p> 
     * 
     *  @param index Index of the navigator to retrieve
     * 
     *  @return The navigator at the specified index, null if one does not exist
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */ 
    public function getViewNavigatorAt(index:int):ViewNavigatorBase
    {
        // If the index is the navigator currently in the callout, return it
        if (_calloutNavigatorIndex == index)
            return _calloutNavigator;
        
        // Since a callout is visible, one of the navigators has been removed
        // from this display tree.  If the index of the navigator in the callout
        // is before the passed index, decrement it by 1 so that it reflects 
        // the current indicies of the child navigatos.
        if (_calloutNavigatorIndex != -1 && _calloutNavigatorIndex < index)
            index--;
        
        if (index >= numElements)
            return null;
        
        return getElementAt(index) as ViewNavigatorBase;
    }
    
    /**
     *  Displays the child navigator at index 0 inside a callout.  The navigator
     *  is reparented as a child of the callout.
     * 
     *  <p>Since the navigator is reparented, using <code>getElementAt(0)</code> 
     *  will not return the first navigator, but will return the second one.  
     *  It is recommended that developers use the <code>getViewNavigatorAt()</code>
     *  method to access the navigators.</p>
     * 
     *  <p>The callout height is fixed by the component but can be changed by
     *  reskinning or by manually setting the height property on the 
     *  <code>viewNavigatorCallout</code> skinPart.</p>
     * 
     *  <p>If the callout is already open or the callout skinpart does not exist, 
     *  this method will do nothing.</p>
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */ 
    public function showFirstViewNavigatorInCallout(owner:DisplayObjectContainer):void
    {
        showNavigatorAtIndexInCallout(0, owner);
    }

    /**
     *  Hides the navigator callout if its open.  The navigator that was
     *  displayed in the callout will be reparented as a child of this
     *  SplitViewNavigator.
     * 
     *  <p>This method is automatically called if the user touches outside 
     *  of the callout when it is visible.  The navigator inside the callout
     *  will be invisible after the callout is closed.</p>
     * 
     *  <p>After closing the callout, the navigator that was shown will remain
     *  invisible unless <code>autoHideFirstViewNavigator</code> is <code>true</code>
     *  and the device orientation is landscape.  In all other cases, the
     *  visibility of the first navigator will need to be set to <code>true</code>
     *  to make it visible again.</p>
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */ 
    public function hideViewNavigatorCallout():void
    {
		if (!viewNavigatorCallout|| !viewNavigatorCallout.isOpen)
			return;
		
        viewNavigatorCallout.addEventListener(PopUpEvent.CLOSE, navigatorCallout_closeHandler);
		viewNavigatorCallout.close(true);
		viewNavigatorCallout.removeEventListener('mouseDownOutside', navigatorCallout_mouseDownOutsideHandler);
    }
    
	//--------------------------------------------------------------------------
	//
	//  Private Methods
	// 
	//--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Shows the navigator at the specified index in the callout component.
     */ 
    mx_internal function showNavigatorAtIndexInCallout(index:int, owner:DisplayObjectContainer):void
    {
        // TODO (chiedozi): Consider replacing the navigator in the callout if
        // it is already open.
        if (index >= numElements || !viewNavigatorCallout|| viewNavigatorCallout.isOpen)
            return;
        
        _calloutNavigatorIndex = index;
        _calloutNavigator = getElementAt(index) as ViewNavigatorBase;
        
        viewNavigatorCallout.addEventListener('mouseDownOutside', navigatorCallout_mouseDownOutsideHandler, false, 0, true);
        viewNavigatorCallout.addElement(_calloutNavigator);
        viewNavigatorCallout.open(owner, true);
        
        // Make sure the first navigator is visible
        _calloutNavigator.visible = true;
    }
    
    /**
     *  @private
     */ 
    private function navigatorCallout_closeHandler(event:PopUpEvent):void
    {
        viewNavigatorCallout.removeEventListener(PopUpEvent.CLOSE, navigatorCallout_closeHandler);
        
        if (_calloutNavigator)
            restoreNavigatorInCallout();
        
        // When an orientation change occurs, the callout's visibility may be set to false.
        // Set it back to true so that it is visible the next time it is opened.
        viewNavigatorCallout.visible = true;
    }
    
    /**
     *  @private
     */ 
    private function restoreNavigatorInCallout():void
    {
        // Restore navigator parent
        addElementAt(_calloutNavigator, _calloutNavigatorIndex);
        
        if (autoHideFirstViewNavigator && _calloutNavigatorIndex == 0)
        {
            toggleFirstNavigatorVisibility();
        }
        else
        {
            _calloutNavigator.visible = false;
        }
        
        _calloutNavigator = null;
        _calloutNavigatorIndex = -1;
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
        if (event.element != _calloutNavigator)
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
		
		if (autoHideFirstViewNavigator)
		{
            // The navigator in the callout needs to be immediately reparented
            // when the orientation changes since we don't provide orientation
            // effects.  Because of this, we don't want to see any close
            // transitions to play on the callout.  Since the transitions are
            // defined on the skin, there is no way to intercept them, so instead
            // the callout is hidden.  restoreNavigatorInCallout() will call
            // toggleFirstNavigatorVisibility() if needed.
            if (_calloutNavigator)
            {
                restoreNavigatorInCallout();
                viewNavigatorCallout.visible = false;
            }
            else
            {
                toggleFirstNavigatorVisibility();
            }
		}
        
        // The navigator callout is always hidden if the orientation changes 
        hideViewNavigatorCallout();
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
	private function navigatorCallout_mouseDownOutsideHandler(event:Event):void
	{
		hideViewNavigatorCallout();
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
	
        if (event.type == FlexEvent.HIDE && navigator == _calloutNavigator)
            hideViewNavigatorCallout();

        navigator.includeInLayout = navigator.visible;
	}
	
    //--------------------------------------------------------------------------
    //
    //  Overriden Methods: ViewNavigatorBase
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */ 
    override public function loadViewData(value:Object):void
    {
        super.loadViewData(value);
        
        var dataArray:Array = value.dataArray;
        
        // If the data array is null, we won't restore any data
        if (!dataArray)
            return;
        
        // Restore each navigators persistence data
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
     *  @productversion Flex 4.5.2
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
        // If a navigator is currently inside a callout, force a validation on it as well.  
        // This was added because ViewNavigator will call validateNow on its parentNavigator 
        // when preparing to do a view transition.  Since the callout navigator is no longer 
        // a child of this SplitViewNavigator, the navigator in the callout isn't validated 
        // as expected.
        if (_calloutNavigatorIndex != -1)
            _calloutNavigator.validateNow();
        
        super.validateNow();
    }
}
}