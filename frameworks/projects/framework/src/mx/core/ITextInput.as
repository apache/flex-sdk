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

package mx.core
{

import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.managers.IFocusManagerComponent;
import mx.styles.IStyleClient;

/**
 *  Documentation is not currently available.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface ITextInput
	extends IDataRenderer, IDropInListItemRenderer, IFocusManagerComponent,
	IFontContextComponent, IIMESupport, IListItemRenderer, IUIComponent, 
    IInvalidating, IStyleClient
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  editable
	//----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get editable():Boolean;
	
	/**
	 *  @private
	 */
	function set editable(value:Boolean):void;

    //----------------------------------
    //  horizontalScrollPosition
    //----------------------------------

    /**
     *  Documentation is not currently available.
     */
    function get horizontalScrollPosition():Number;
    
    /**
     *  @private
     */
    function set horizontalScrollPosition(value:Number):void;

	//----------------------------------
	//  maxChars
	//----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get maxChars():int;
	
	/**
	 *  @private
	 */
	function set maxChars(value:int):void;

	//----------------------------------
	//  mouseChildren
	//----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get mouseChildren():Boolean;
	
	/**
	 *  @private
	 */
	function set mouseChildren(value:Boolean):void;

	//----------------------------------
	//  mouseEnabled
	//----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get mouseEnabled():Boolean;
	
	/**
	 *  @private
	 */
	function set mouseEnabled(value:Boolean):void;

	//----------------------------------
	//  parentDrawsFocus
	//----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get parentDrawsFocus():Boolean;
	
	/**
	 *  @private
	 */
	function set parentDrawsFocus(value:Boolean):void;

	//----------------------------------
	//  restrict
	//----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get restrict():String;
	
	/**
	 *  @private
	 */
	function set restrict(value:String):void;

	//----------------------------------
	//  selectable
	//----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get selectable():Boolean;
	
	/**
	 *  @private
	 */
	function set selectable(value:Boolean):void;

	//----------------------------------
	//  text
	//----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	function get text():String;
	
	/**
	 *  @private
	 */
	function set text(value:String):void;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

    /**
     *  For Halo, used to determine if the control's border object is visible.
     *  For Spark, it does nothing.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function showBorder(visible:Boolean):void;
    
    /**
     *  Selects the text in the range specified by the parameters.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function selectRange(anchorIndex:int, activeIndex:int):void;
}

}
