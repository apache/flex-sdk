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
package spark.skins.mobile
{
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.Sprite;

import mx.core.DPIClassification;

import spark.components.Group;
import spark.components.SpinnerListContainer;
import spark.layouts.HorizontalLayout;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile160.assets.SpinnerListContainerBackground;
import spark.skins.mobile160.assets.SpinnerListContainerSelectionIndicator;
import spark.skins.mobile160.assets.SpinnerListContainerShadow;
import spark.skins.mobile240.assets.SpinnerListContainerBackground;
import spark.skins.mobile240.assets.SpinnerListContainerSelectionIndicator;
import spark.skins.mobile240.assets.SpinnerListContainerShadow;
import spark.skins.mobile320.assets.SpinnerListContainerBackground;
import spark.skins.mobile320.assets.SpinnerListContainerSelectionIndicator;
import spark.skins.mobile320.assets.SpinnerListContainerShadow;

/**
 *  ActionScript-based skin for the SpinnerListContainer in mobile applications. 
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */
public class SpinnerListContainerSkin extends MobileSkin
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
	 * 
	 */
	public function SpinnerListContainerSkin()
	{
		super();
		
		switch (applicationDPI)
		{
			case DPIClassification.DPI_320:
			{
				borderClass = spark.skins.mobile320.assets.SpinnerListContainerBackground;
				selectionIndicatorClass = spark.skins.mobile320.assets.SpinnerListContainerSelectionIndicator;
				shadowClass = spark.skins.mobile320.assets.SpinnerListContainerShadow;
				
				cornerRadius = 10;
				borderThickness = 2;
				selectionIndicatorHeight = 120;
				break;
			}
			case DPIClassification.DPI_240:
			{
				borderClass = spark.skins.mobile240.assets.SpinnerListContainerBackground;
				selectionIndicatorClass = spark.skins.mobile240.assets.SpinnerListContainerSelectionIndicator;
				shadowClass = spark.skins.mobile240.assets.SpinnerListContainerShadow;
				
				cornerRadius = 8;
				borderThickness = 1;
				selectionIndicatorHeight = 90;
				break;
			}
			default: // default DPI_160
			{
				borderClass = spark.skins.mobile160.assets.SpinnerListContainerBackground;
				selectionIndicatorClass = spark.skins.mobile160.assets.SpinnerListContainerSelectionIndicator;
				shadowClass = spark.skins.mobile160.assets.SpinnerListContainerShadow;
			
				cornerRadius = 5;
				borderThickness = 1;
				selectionIndicatorHeight = 60;
				
				break;
			}
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  Pixel thickness of the border 
	 *       
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.5.2
	 */
	protected var borderThickness:Number;
	
	/**
	 *  Radius of the border corners 
	 *       
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.5.2
	 */
	protected var cornerRadius:Number;
	
	/**
	 *  Height of the selection indicator  
	 *       
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.5.2
	 */
	protected var selectionIndicatorHeight:Number;
	
	/**
	 *  Class for the border part 
	 *       
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.5.2
	 */
	protected var borderClass:Class;
	
	/**
	 *  Class for the selection indicator part 
	 *       
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.5.2
	 */
	protected var selectionIndicatorClass:Class;
	
	/**
	 *  Class for the shadow part  
	 *       
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.5.2
	 */
	protected var shadowClass:Class;
	
	/**
	 *  Border part which includes the background 
	 *       
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.5.2
	 */
	protected var border:InteractiveObject;
	
	/**
	 *  Selection indicator part 
	 *       
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.5.2
	 */
	protected var selectionIndicator:InteractiveObject;
	
	/**
	 *  Shadow part 
	 *       
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.5.2
	 */
	protected var shadow:InteractiveObject;
	
	/**
	 *  Mask for the content group 
	 *       
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.5.2
	 */
	protected var contentGroupMask:Sprite;
	
	//--------------------------------------------------------------------------
	//
	//  Skin parts 
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  An optional skin part that defines the Group where the content 
	 *  children get pushed into and laid out.
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.5.2
	 */
	public var contentGroup:Group;
	
	//--------------------------------------------------------------------------
	//
	//  Properties 
	//
	//--------------------------------------------------------------------------
	/** 
	 *  @copy spark.skins.spark.ApplicationSkin#hostComponent
	 */
	public var hostComponent:SpinnerListContainer;
	
	//--------------------------------------------------------------------------
	//
	//  Overridden Methods 
	//
	//--------------------------------------------------------------------------
	override protected function createChildren():void
	{
		super.createChildren();
		
		if (!border)
		{
			// Border and background
			border = new borderClass();
			border.mouseEnabled = false;
			addChild(border);
		}
		
		if (!contentGroup)
		{
			// Contains the child elements
			contentGroup = new Group();
			var hLayout:HorizontalLayout = new HorizontalLayout();
			hLayout.gap = 0;
			contentGroup.layout = hLayout;
			contentGroup.id = "contentGroup";
			addChild(contentGroup);
		}
		
		if (!shadow)
		{
			// Shadowing sits on top of the content
			shadow = new shadowClass();
			shadow.mouseEnabled = false;
			addChild(shadow);
		}
		
		if (!selectionIndicator)
		{
			// Selection indicator is on top
			selectionIndicator = new selectionIndicatorClass();
			selectionIndicator.mouseEnabled = false;
			addChild(selectionIndicator);
		}
		
		if (!contentGroupMask)
		{
			// Create a mask for the content
			contentGroupMask = new Sprite();
			addChild(contentGroupMask);
		}
	}	
	
	override protected function measure():void
	{
		super.measure();
		
		var contentW:Number = contentGroup.getPreferredBoundsWidth();
		var contentH:Number = contentGroup.getPreferredBoundsHeight();
		
		// TODO (jszeto) Figure out min size behavior
		measuredWidth = measuredMinWidth = contentW + borderThickness * 2;
		measuredHeight = measuredMinHeight = contentH + borderThickness * 2;
	}
		
	override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.layoutContents(unscaledWidth, unscaledHeight);
		
		var contentW:Number = contentGroup.getPreferredBoundsWidth();
		var contentH:Number = contentGroup.getPreferredBoundsHeight();
		
		setElementSize(contentGroup, unscaledWidth - borderThickness * 2, unscaledHeight - borderThickness * 2);
        setElementPosition(contentGroup, borderThickness, borderThickness);
		
		// Inset by the borderThickness horizontally because the selectionIndicator starts at 0
        setElementSize(border, unscaledWidth - borderThickness * 2, unscaledHeight);
		setElementPosition(border, borderThickness, 0);
		
        setElementSize(shadow, unscaledWidth - borderThickness * 4, unscaledHeight - borderThickness * 2);
		setElementPosition(shadow, borderThickness * 2, borderThickness);
				
        setElementSize(selectionIndicator, unscaledWidth, selectionIndicatorHeight);
		setElementPosition(selectionIndicator, 0, Math.floor((unscaledHeight - selectionIndicatorHeight) / 2));
				
		// The SpinnerLists contain a left and right border. We don't want to show the leftmost 
		// SpinnerLists's left border nor the rightmost one's right border. 
		// We inset the mask on the left and right sides to accomplish this. 
		var g:Graphics = contentGroupMask.graphics;
		g.clear();
		g.beginFill(0x00FF00);
		g.drawRoundRect(borderThickness * 2, borderThickness, 
						unscaledWidth - borderThickness * 4,
						unscaledHeight - borderThickness * 2,
						cornerRadius, cornerRadius);
		g.endFill();
		
		contentGroup.mask = contentGroupMask;		
	}
}
}