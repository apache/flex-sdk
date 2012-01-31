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
import flash.geom.Matrix;
import flash.geom.Point;

import mx.core.ITransientDeferredInstance;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.managers.PopUpManager;
import flash.display.Graphics;

import mx.core.IFlexDisplayObject;
import mx.core.IFactory;

use namespace mx_internal;


[DefaultProperty("popUp")]

/**
 *  This component is used to position a dropDown in layout. Since a dropDown is 
 *  added to the display list via the PopUpManager, it doesn't normally participate 
 *  in layout. The PopUp component is a UIComponent that does get added to a 
 *  container and thus is laid out. It is responsible for then sizing and 
 *  positioning the dropDown relative to itself.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
public class PopUpAnchor extends UIComponent
{
	
	/**
	 *  Constructor
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
 	 *  @playerversion AIR 1.5
 	 *  @productversion Flex 4
 	 */
	public function PopUpAnchor()
	{
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
	}
	
	private var layoutWidth:Number = 0;
	private var layoutHeight:Number = 0;
	
	private var popUpWidth:Number = 0;
	private var popUpHeight:Number = 0;
	
	private var popUpIsDisplayed:Boolean = false;
	private var addedToStage:Boolean = false;
	
	//--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	
	//----------------------------------
    //  autoSizePopUpHeight
    //----------------------------------
	
	private var _autoSizePopUpHeight:Boolean = false;
	
	/**
	 *  If true, the popUp's height is set to the value of the PopUpAnchor's height.
	 * 
	 *  @default false
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
	public function set autoSizePopUpHeight(value:Boolean):void
	{
		if (_autoSizePopUpHeight == value)
			return;
			
		_autoSizePopUpHeight = value;
		
		invalidateDisplayList();
	}
	
	/**
	 *  @private
	 */
	public function get autoSizePopUpHeight():Boolean
	{
		return _autoSizePopUpHeight;
	}
	
	//----------------------------------
    //  autoSizePopUpWidth
    //----------------------------------
	
	private var _autoSizePopUpWidth:Boolean = false;
	
	/**
	 *  If true, the popUp's width is set to the value of the PopUpAnchor's width.
	 * 
	 *  @default false
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
	public function set autoSizePopUpWidth(value:Boolean):void
	{
		if (_autoSizePopUpWidth == value)
			return;
			
		_autoSizePopUpWidth = value;
		
		invalidateDisplayList();
	}
	
	/**
	 *  @private
	 */
	public function get autoSizePopUpWidth():Boolean
	{
		return _autoSizePopUpWidth;
	}

	//----------------------------------
    //  displayPopUp
    //----------------------------------
	
	private var _displayPopUp:Boolean = false;
	
	/**
	 *  If true, add the popUp to the PopUpManager. If false, remove it.  
	 *  
	 *  @default false
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function set displayPopUp(value:Boolean):void
	{
		if (_displayPopUp == value)
			return;
			
		_displayPopUp = value;
		updatePopUpState();
	}
	
	/**
	 *  @private
	 */
	public function get displayPopUp():Boolean
	{
		return _displayPopUp;
	}

	/*[InstanceType("mx.core.UIComponent")]
	private var _popUpFactory:ITransientDeferredInstance;
	
	public function set popUpFactory(value:ITransientDeferredInstance):void
	{
		if (_popUpFactory == value)
			return;
	
		_popUpFactory = value;
		
		updatePopUpState();
	}
	
	public function get popUpFactory():ITransientDeferredInstance
	{
		return _popUpFactory;
	}*/
	
	//----------------------------------
    //  popUp
    //----------------------------------
	
	private var _popUp:UIComponent;
	
	/**
	 *  UIComponent to add to the PopUpManager when the PopUpAnchor is opened. 
	 *  If the popUp implements IFocusManagerContainer, the popUp will have its
     *  own FocusManager so that, if the user uses the TAB key to navigate between
     *  controls, only the controls in the popUp will be accessed. 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
	public function set popUp(value:UIComponent):void
	{
		if (_popUp == value)
			return;
			
		_popUp = value;
		
		if (_popUp)
			_popUp.styleName = this;
			
		
	}
	
	/**
	 *  @private
	 */
	public function get popUp():UIComponent 
	{ 
		return _popUp 
	}
	
	//----------------------------------
    //  popUpPosition
    //----------------------------------
	
	private var _popUpPosition:String = "exact";
	
	/**
	 *  Position of the popUp when it is opened. 
	 *  Possible values are "left", "right", "above", "below", "center", and "exact"
	 * 
	 *  @default "exact" 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
	
	public function set popUpPosition(value:String):void
	{
		if (_popUpPosition == value)
			return;
			
		_popUpPosition = value;
		invalidateDisplayList();	
	}
	
	public function get popUpPosition():String
	{
		return _popUpPosition;
	}
		
	//--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private 
	 */
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
					
		layoutWidth = unscaledWidth;
		layoutHeight = unscaledHeight;
				
		applyPopUpTransform(unscaledWidth, unscaledHeight);			
	}
	
	//--------------------------------------------------------------------------
    //
    //  Public Methods
    //
    //--------------------------------------------------------------------------   
	
	/**
	 *  Call this function to update the popUp's transform matrix. Typically 
	 *  this would be called while performing an effect upon the PopUpAnchor. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function updatePopUpTransform():void
	{
		applyPopUpTransform(layoutWidth, layoutHeight);
	}
	
	/**
	 *  This function is called when the popUp is positioned when it is displayed
	 *  or when updatePopUpTransform() is called. Override this function to 
	 *  alter the position of the popUp.  
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	protected function positionPopUp():void
	{
		
	}
	
	//--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //-------------------------------------------------------------------------- 
	
	// TODO (jszeto) Rename to not use 'state'
	/**
	 *  @private 
	 */
	private function updatePopUpState():void
	{
		// If we haven't been initialized, we need to perform this function 
		// in commitProperties
		if (!addedToStage)
		{
			return;
		}	
		
		/*if (popUpFactory && popUp == null && displayPopUp)
		{
			_popUp = UIComponent(popUpFactory.getInstance());
			_popUp.styleName = this
		}*/
		
		if(popUp == null)
			return;
						
		if(popUp.parent == null && displayPopUp)
		{	
			PopUpManager.addPopUp(popUp,this,false);
			popUpIsDisplayed = true;
			popUpWidth = popUp.explicitWidth;
			popUpHeight = popUp.explicitHeight;
			applyPopUpTransform(layoutWidth, layoutHeight);
		}
		else if (popUp.parent != null && displayPopUp == false)
		{
			PopUpManager.removePopUp(popUp);
			popUpIsDisplayed = false;
			popUp.explicitWidth = popUpWidth;
			popUp.explicitHeight = popUpHeight;
			
			/*if (popUpFactory)
			{
				_popUp.styleName = null;
				_popUp = null;
				popUpFactory.reset();
			}*/
		}
		
		
	}
	
	/**
	 *  @private 
	 */
	private function determinePosition(placement:String,popUpWidth:Number,popUpHeight:Number,registrationPoint:Point):void
	{
		switch(placement)
		{
			case "below":
				registrationPoint.x = 0;
				registrationPoint.y = unscaledHeight;
				break;
			case "above":
				registrationPoint.x = 0;
				registrationPoint.y = -popUpHeight;
				break;
			case "left":
				registrationPoint.x = -popUpWidth;
				registrationPoint.y = 0;
				break;
			case "right":
				registrationPoint.x = unscaledWidth;
				registrationPoint.y = 0;
				break;			
			case "center":
				registrationPoint.x = (unscaledWidth - popUpWidth) / 2;
				registrationPoint.y = (unscaledHeight - popUpHeight) / 2;
				break;			
			case "exact":
				// already 0,0
				break;
		}
	}
	
	/**
	 *  @private 
	 */ 
	private function applyPopUpTransform(unscaledWidth:Number, unscaledHeight:Number):void
	{
		if (!popUpIsDisplayed)
			return;
		
		var m:Matrix = $transform.concatenatedMatrix;
		
		var registrationPoint:Point = new Point();
		var popUpWidth:Number = autoSizePopUpWidth ? unscaledWidth : popUp.getPreferredBoundsWidth(false);
		var popUpHeight:Number = autoSizePopUpHeight ? unscaledHeight : popUp.getPreferredBoundsHeight(false);
		
		determinePosition(popUpPosition,popUpWidth,popUpHeight,registrationPoint);
		var globalTL:Point = m.transformPoint(registrationPoint);
		registrationPoint.x += popUpWidth;
		registrationPoint.y += popUpHeight;
		var globalBR:Point = m.transformPoint(registrationPoint);
		var adjustedPlacement:String;
		
		if (screen)
		{
			switch(popUpPosition)
			{
				case "below":
					if(globalBR.y > screen.bottom)
						adjustedPlacement = "above"; 
					break;
				case "above":
					if(globalTL.y < screen.top)
						adjustedPlacement = "below"; 
					break;
				case "left":
					if(globalBR.x < screen.left)
						adjustedPlacement = "right"; 
					break;
				case "right":
					if(globalTL.y > screen.right)
						adjustedPlacement = "left"; 
					break;
			}
		}
		
		if(adjustedPlacement != null)
		{
			determinePosition(adjustedPlacement,popUpWidth,popUpHeight,registrationPoint);
			globalTL = m.transformPoint(registrationPoint);
		}
		
		// Set the dimensions explicitly because UIComponents always set themselves to their
		// measured / explicit dimensions if they are parented by the SystemManager.  
		popUp.width = popUpWidth;
		popUp.height = popUpHeight;
		
		// Position the popUp. 
		m.tx = globalTL.x;
		m.ty = globalTL.y;
		popUp.setLayoutMatrix(m,false);
	}
	
	/**
	 *  @private 
	 *  TODO (jszeto) Remove
	 */ 
	private function traceTransform(targ:UIComponent):void
	{
		var p:DisplayObject = targ;
		
		while (p)
		{
			var m:Matrix = p is UIComponent ? UIComponent(p).$transform.matrix : p.transform.matrix;
			var concatM:Matrix = p is UIComponent ? UIComponent(p).$transform.concatenatedMatrix : p.transform.concatenatedMatrix;
			
			trace(p,"matrix:",m,"concatenatedMatrix:",concatM);
			
			p = p.parent;
		}
	}
	
	//--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //-------------------------------------------------------------------------- 
	
	/**
	 *  @private 
	 */ 
	private function addedToStageHandler(event:Event):void
	{
		addedToStage = true;
		updatePopUpState();	
	}
	
	/**
	 *  @private 
	 */ 
	private function removedFromStageHandler(event:Event):void
	{
		addedToStage = false;
		// TODO (jszeto) Remove popup from PopUpManager
	}
}
}
