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

import flash.geom.Rectangle;
import mx.utils.MatrixUtil;

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
	
	private var popUpWidth:Number = 0;
	private var popUpHeight:Number = 0;
	
	private var popUpIsDisplayed:Boolean = false;
	private var addedToStage:Boolean = false;
	
	private static var decomposition:Vector.<Number> = new Vector.<Number>();
	decomposition.push(0);
	decomposition.push(0);
	decomposition.push(0);
	decomposition.push(0);
	decomposition.push(0);	
	
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
		applyPopUpTransform(width, height);
	}
	
	/**
	 *  This function is called when the popUp is positioned when it is displayed
	 *  or when updatePopUpTransform() is called. Override this function to 
	 *  alter the position of the popUp.  
	 * 
	 *  @return The absolute position of the popUp in the global coordinate system  
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	protected function positionPopUp():Point
	{
		// This implementation doesn't handle rotation
		var matrix:Matrix = $transform.concatenatedMatrix;
		var regPoint:Point = new Point();
		
		var popUpBounds:Rectangle = new Rectangle(); 
		determinePosition(popUpPosition, popUp.width, popUp.height,
						  matrix, regPoint, popUpBounds);
		
		var adjustedPosition:String;
		
		// Position the popUp in the opposite direction if it 
		// does not fit on the screen. 
		if (screen)
		{
			switch(popUpPosition)
			{
				case "below" :
					if (popUpBounds.bottom > screen.bottom)
						adjustedPosition = "above"; 
					break;
				case "above" :
					if (popUpBounds.top < screen.top)
						adjustedPosition = "below"; 
					break;
				case "left" :
					if (popUpBounds.left < screen.left)
						adjustedPosition = "right"; 
					break;
				case "right" :
					if (popUpBounds.right > screen.right)
						adjustedPosition = "left"; 
					break;
			}
		}
		
		// Get the new registration point based on the adjusted position
		if(adjustedPosition != null)
		{
			var adjustedRegPoint:Point = new Point();
			var adjustedBounds:Rectangle = new Rectangle(); 
			determinePosition(adjustedPosition, popUp.width, popUp.height,
							  matrix, adjustedRegPoint, adjustedBounds);
		 
			if (screen)
			{
				// If we adjusted the position but the popUp still doesn't fit, 
				// then revert to the original position. 
				switch(adjustedPosition)
				{
					case "below" :
						if (popUpBounds.bottom > screen.bottom)
							adjustedPosition = null; 
						break;
					case "above" :
						if (popUpBounds.top < screen.top)
							adjustedPosition = null; 
						break;
					case "left" :
						if (popUpBounds.left < screen.left)
							adjustedPosition = null; 
						break;
					case "right" :
						if (popUpBounds.right > screen.right)
							adjustedPosition = null;  
						break;
				}	
			}
			
			if (adjustedPosition != null)
			{
				regPoint = adjustedRegPoint;
				popUpBounds = adjustedBounds;
			}
		}
		
		MatrixUtil.decomposeMatrix(decomposition, matrix, 0, 0);
		var concatScaleX:Number = decomposition[3];
		var concatScaleY:Number = decomposition[4]; 
		
		// If the popUp still doesn't fit, then nudge it
		// so it is completely on the screen. Make sure to include scale.

		if (popUpBounds.top < screen.top)
			regPoint.y += (screen.top - popUpBounds.top) / concatScaleY;
		else if (popUpBounds.bottom > screen.bottom)
			regPoint.y -= (popUpBounds.bottom - screen.bottom) / concatScaleY;
		
		if (popUpBounds.left < screen.left)
			regPoint.x += (screen.left - popUpBounds.left) / concatScaleX;	
		else if (popUpBounds.right > screen.right)
			regPoint.x -= (popUpBounds.right - screen.right) / concatScaleX;
		
		return matrix.transformPoint(regPoint);
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
		if (!addedToStage)
			return;
		
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
			applyPopUpTransform(width, height);
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
	mx_internal function determinePosition(placement:String, popUpWidth:Number, popUpHeight:Number,
										   matrix:Matrix, registrationPoint:Point, bounds:Rectangle):void
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
				
		var globalTL:Point = matrix.transformPoint(registrationPoint);
		registrationPoint.y += popUp.height;
		var globalBL:Point = matrix.transformPoint(registrationPoint);
		registrationPoint.x += popUp.width;
		var globalBR:Point = matrix.transformPoint(registrationPoint);
		registrationPoint.y -= popUp.height;
		var globalTR:Point = matrix.transformPoint(registrationPoint);
		registrationPoint.x -= popUp.width;
		
		bounds.left = Math.min(globalTL.x, globalBL.x, globalBR.x, globalTR.x);
		bounds.right = Math.max(globalTL.x, globalBL.x, globalBR.x, globalTR.x);
		bounds.top = Math.min(globalTL.y, globalBL.y, globalBR.y, globalTR.y);
		bounds.bottom = Math.max(globalTL.y, globalBL.y, globalBR.y, globalTR.y);
	}
	
	/**
	 *  @private 
	 */ 
	private function applyPopUpTransform(unscaledWidth:Number, unscaledHeight:Number):void
	{
		if (!popUpIsDisplayed)
			return;
		
		var m:Matrix = $transform.concatenatedMatrix;
		
		var popUpWidth:Number = autoSizePopUpWidth ? unscaledWidth : popUp.getPreferredBoundsWidth(false);
		var popUpHeight:Number = autoSizePopUpHeight ? unscaledHeight : popUp.getPreferredBoundsHeight(false);
		
		// Set the dimensions explicitly because UIComponents always set themselves to their
		// measured / explicit dimensions if they are parented by the SystemManager. 
		popUp.width = popUpWidth;
		popUp.height = popUpHeight;
		
		var popUpPoint:Point = positionPopUp();
				
		// Position the popUp. 
		m.tx = popUpPoint.x;
		m.ty = popUpPoint.y;
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
