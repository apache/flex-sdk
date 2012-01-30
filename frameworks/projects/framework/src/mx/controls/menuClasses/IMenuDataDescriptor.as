////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.controls.menuClasses
{

import mx.collections.ICollectionView;

/**
 *  The IMenuDataDescriptor interface defines the interface that a 
 *  dataDescriptor for a Menu or MenuBar control must implement. 
 *  The interface provides methods for parsing and modifyng a collection
 *  of data that is displayed by a Menu or MenuBar control.
 *
 *  @see mx.collections.ICollectionView
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IMenuDataDescriptor
{
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

    /**
     *  @copy mx.controls.treeClasses.DefaultDataDescriptor#getChildren()  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	function getChildren(node:Object, model:Object = null):ICollectionView;
	
	/**
     *  @copy mx.controls.treeClasses.DefaultDataDescriptor#hasChildren() 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	function hasChildren(node:Object, model:Object = null):Boolean;

	/**
     *  @copy mx.controls.treeClasses.DefaultDataDescriptor#getData() 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	function getData(node:Object, model:Object = null):Object;

    /**
     *  @copy mx.controls.treeClasses.DefaultDataDescriptor#isBranch() 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	function isBranch(node:Object, model:Object = null):Boolean;

	/**
     *  @copy mx.controls.treeClasses.DefaultDataDescriptor#getType()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	function getType(node:Object):String;

	/**
     *  @copy mx.controls.treeClasses.DefaultDataDescriptor#addChildAt()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function addChildAt(parent:Object, newChild:Object, index:int,
						model:Object = null):Boolean;

    /**
     *  @copy mx.controls.treeClasses.DefaultDataDescriptor#removeChildAt()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function removeChildAt(parent:Object, child:Object, index:int,
						   model:Object = null):Boolean;
	
	/**
     *  @copy mx.controls.treeClasses.DefaultDataDescriptor#isEnabled()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	function isEnabled(node:Object):Boolean;

	/**
     *  @copy mx.controls.treeClasses.DefaultDataDescriptor#setEnabled()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	function setEnabled(node:Object, value:Boolean):void;

	/**
     *  @copy mx.controls.treeClasses.DefaultDataDescriptor#isToggled()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	function isToggled(node:Object):Boolean;

	/**
     *  @copy mx.controls.treeClasses.DefaultDataDescriptor#setToggled()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	function setToggled(node:Object, value:Boolean):void;

	/**
     *  @copy mx.controls.treeClasses.DefaultDataDescriptor#getGroupName()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	function getGroupName(node:Object):String;
}

}
