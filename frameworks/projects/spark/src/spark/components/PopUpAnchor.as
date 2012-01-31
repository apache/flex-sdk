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
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Point;

import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.managers.PopUpManager;
import flash.display.Graphics;

use namespace mx_internal;


[DefaultProperty("content")]

/**
 *  This component is used to position a dropDown in layout. Since a dropDown is 
 *  added to the display list via the PopUpManager, it doesn't normally participate 
 *  in layout. The PopUp component is a UIComponent that does get added to a 
 *  container and thus is laid out. It is responsible for then sizing and 
 *  positioning the dropDown relative to itself.
 * 
 *  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
public class PopUp extends UIComponent
{
	public function PopUp()
	{
		/*addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
		addEventListener(Event.REMOVED_FROM_STAGE,removedFromStageHandler);*/
	}
	
	private var _alpha:Number = 1;
	private var alphaChanged:Boolean = false; 
	
	// TODO (jszeto) Remove since we won't support proxying all props
	override public function set alpha(value:Number):void
	{
		// TODO!!! move this into commitProperties
		if (_alpha != value)
		{
			_alpha = value;
			
			if (content)
				content.alpha = _alpha;
			else
			{
				alphaChanged = true;
				invalidateProperties();
			}
			
		}
	}
	
	override public function get alpha():Number
	{
		return content ? content.alpha : _alpha; 
	}
	
	private var _open:Boolean = false;
	private var _content:UIComponent;
	public var placement:String = "below";
	
	/**
	 *  UIComponent to add to the PopUpManager when the PopUp is opened. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
	public function set content(value:UIComponent):void
	{
		_content = value;
		updateContentState();
	}
	
	/**
	 *  @private
	 */
	public function get content():UIComponent 
	{ 
		return _content 
	}
	
	
	/**
	 *  If true, add the content to the PopUpManager. If false, remove it.  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function set open(value:Boolean):void
	{
		if (value != _open)
		{
			_open = value;
			updateContentState();
		}
	}
	
	/**
	 *  @private
	 */
	public function get open():Boolean
	{
		return _open;
	}
	
	
	override protected function commitProperties() : void
	{
		if (content)
		{
		
			if (alphaChanged)
			{
				alphaChanged = false;
				content.alpha = _alpha;
				dispatchEvent(new Event("alphaChanged"));
			}
		}
		/*
		// Force validation of content Properties
		content.validateProperties();*/
	}
	
	/*private function addedToStageHandler(e:Event):void
	{
		_open = true;
		updateContentState();
	}
	
	private function removedFromStageHandler(e:Event):void
	{
		_open = false;
		updateContentState();
	}*/
	
	// TODO (jszeto) Rename to not use 'state'
	private function updateContentState():void
	{
		if(_content == null)
			return;
		if(_content.parent == null && _open)
		{	
						
			PopUpManager.addPopUp(_content,this,false);
			applyContentTransform(width, height);
		}
		else if (_content.parent != null && _open == false)
		{
			PopUpManager.removePopUp(_content);
		}
	}
	
	private function determinePosition(placement:String,contentWidth:Number,contentHeight:Number,registrationPoint:Point):void
	{
		switch(placement)
		{
			case "below":
				registrationPoint.x = 0;
				registrationPoint.y = unscaledHeight;
				break;
			case "above":
				registrationPoint.x = 0;
				registrationPoint.y = -contentHeight;
				break;
			case "left":
				registrationPoint.x = -contentWidth;
				registrationPoint.y = 0;
				break;
			case "right":
				registrationPoint.x = unscaledWidth;
				registrationPoint.y = 0;
				break;					
			case "inside":
				// already 0,0
				break;
		}
	}

	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{			
		// Size the content to its measured size
		/*_content.width = _content.getExplicitOrMeasuredWidth();
		_content.height = _content.getExplicitOrMeasuredHeight();*/
				
		applyContentTransform(unscaledWidth, unscaledHeight);			
	}
	
	
	private function applyContentTransform(unscaledWidth:Number, unscaledHeight:Number):void
	{
		var m:Matrix = $transform.concatenatedMatrix;
		
		//traceTransform(this);
		
		var registrationPoint:Point = new Point();
		var contentWidth:Number = _content.getPreferredBoundsWidth(false);
		var contentHeight:Number = _content.getPreferredBoundsHeight(false);
		
		switch(placement)
		{
			case "below":
			case "above":
				contentWidth = Math.max(contentWidth,unscaledWidth);
				break;
		}
		
		determinePosition(placement,contentWidth,contentHeight,registrationPoint);
		var globalTL:Point = m.transformPoint(registrationPoint);
		registrationPoint.x += contentWidth;
		registrationPoint.y += contentHeight;
		var globalBR:Point = m.transformPoint(registrationPoint);
		var adjustedPlacement:String;
		switch(placement)
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
		if(adjustedPlacement != null)
		{
			determinePosition(adjustedPlacement,contentWidth,contentHeight,registrationPoint);
			globalTL = m.transformPoint(registrationPoint);
		}
		
		m.tx = globalTL.x;
		m.ty = globalTL.y;
		 
		/*_content.width = contentWidth;
		_content.height = contentHeight;*/
		_content.setActualSize(contentWidth, contentHeight);
		_content.width = contentWidth;
		_content.setLayoutMatrix(m,false);
	
	}
	
	/**
	 *  Call this function to update the content's transform matrix. Typically 
	 *  this would be called while performing an effect upon the PopUp. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function updateContentTransform():void
	{
		applyContentTransform(width, height);
	}
	
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
}
}