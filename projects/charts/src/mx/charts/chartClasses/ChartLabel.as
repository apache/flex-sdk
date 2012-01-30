////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.charts.chartClasses
{

import flash.display.*;
import flash.geom.*;

import mx.charts.AxisLabel;
import mx.charts.AxisRenderer;
import mx.core.FlexBitmap;
import mx.core.IDataRenderer;
import mx.core.IUITextField;
import mx.core.LayoutDirection;
import mx.core.UIComponent;
import mx.core.UITextField;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  Draws data labels on chart controls.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ChartLabel extends UIComponent implements IDataRenderer
{
    include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private static var ORIGIN:Point = new Point(0, 0);
	
	/**
	 *  @private
	 */
	private static var X_UNIT:Point = new Point(1, 0);
	
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
	public function ChartLabel()
	{
		super();
		this.includeInLayout = false;
		this.layoutDirection = LayoutDirection.LTR;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var _label:IUITextField;
	
	/**
	 *  @private
	 */
	private var _bitmap:Bitmap;
	
	/**
	 *  @private
	 */
	private var _capturedText:BitmapData;
	
	/**
	 *  @private
	 */
	private var _text:String;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  data
	//----------------------------------

	/**
	 *  @private
	 */
	private var _data:Object;
	
	[Inspectable(environment="none")]

	/**
	 *  Defines the contents of the label.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get data():Object
	{
		return _data;
	}

	/**
	 *  @private
	 */
	public function set data(value:Object):void
	{
		if (value == _data)	
			return;
			
		_data = value;
		
		if (value is AxisLabel)
			_text = AxisLabel(value).text;
		else if (value is String)
			_text = String(value);
		
		_label.text = _text == null ? "":_text;
		
		invalidateSize();
		invalidateDisplayList();
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: UIComponent
	//
	//--------------------------------------------------------------------------

	/**
	 *  @inheritDoc
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override public function invalidateSize():void
	{
		super.invalidateSize();
	}

	/**
	 *  @inheritDoc
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override protected function createChildren():void
	{
		super.createChildren();
		
		_label = IUITextField(createInFontContext(UITextField));
		_label.multiline = true;
		_label.selectable = false;
		_label.autoSize = "left";
		_label.styleName = this;
		
		addChild(DisplayObject(_label));
		
	}
	
	/**
	 *  @inheritDoc
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override protected function measure():void
	{
		var oldRotation:Number = rotation;
		
		if (parent && parent.rotation == 90)
			rotation = -90;
			
		_label.validateNow();

		if (_label.embedFonts)
		{
			measuredWidth = _label.measuredWidth + 6;
			measuredHeight = _label.measuredHeight + UITextField.TEXT_HEIGHT_PADDING;
		}
		else
		{
			measuredWidth = _label.textWidth + 6;
			measuredHeight = _label.textHeight + UITextField.TEXT_HEIGHT_PADDING;
		}
		rotation = oldRotation;
	}
	
	/**
	 *  @inheritDoc
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
	{
		if (parent && parent is AxisRenderer && parent.rotation == 90 && _label.embedFonts == true)
		{
			var p:AxisRenderer = AxisRenderer(parent);
			if ((p.getStyle('verticalAxisTitleAlignment') == 'vertical' && p.layoutDirection == LayoutDirection.LTR) ||
				(p.getStyle('verticalAxisTitleAlignment') == 'flippedVertical' && p.layoutDirection == LayoutDirection.RTL))
			{
				_label.rotation = 180;
				_label.y = _label.y + _label.height;
				_label.x = _label.x + _label.width;
			}
		}
		_label.validateNow();

		_label.setActualSize(unscaledWidth, unscaledHeight);

		var localX:Point;
		var localO:Point;
		var useLabel:Boolean = true;
		
		if (_label.embedFonts == false &&
			unscaledWidth > 0 &&
			unscaledHeight > 0)
		{
			localX = globalToLocal(X_UNIT);			
			localO = globalToLocal(ORIGIN);

			useLabel = localX.x - localO.x == 1 &&
					   localX.y - localO.y == 0;
		}

		if (useLabel)
		{
			if (_bitmap)
			{
				removeChild(_bitmap);
				_bitmap = null;
			}
			_label.visible = true;
		}
		else
		{
			_label.visible = false;

			if (!_capturedText ||
				_capturedText.width != unscaledWidth ||
				_capturedText.height != unscaledHeight)
			{
				_capturedText = new BitmapData(unscaledWidth, unscaledHeight);
				
				if (_bitmap)
				{
					removeChild(_bitmap);
					_bitmap = null;
				}
			}

			if (!_bitmap)
			{
				_bitmap = new FlexBitmap(_capturedText);
				_bitmap.smoothing = true;
				addChild(_bitmap);
			}

			_capturedText.fillRect(
				new Rectangle(0, 0, unscaledWidth, unscaledHeight), 0);
		
			_capturedText.draw(_label);
			if (parent && parent.rotation == 90 && parent is AxisRenderer)
			{
				p = AxisRenderer(parent);
				if((p.getStyle('verticalAxisTitleAlignment')=="vertical" && p.layoutDirection == LayoutDirection.LTR) ||
					(p.getStyle('verticalAxisTitleAlignment') == 'flippedVertical' && p.layoutDirection == LayoutDirection.RTL))
				{
					_bitmap.rotation = 180; 
					_bitmap.y = _label.x + _bitmap.height;
					_bitmap.x = _label.y + _bitmap.width;
				}
			}			
		}
	}
}

}
