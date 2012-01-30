////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

/*
 *  The IDisplayObjectContainerInterface defines the basic set of APIs
 *  for web version of flash.display.DisplayObjectContainer
 *  
 */
import flash.text.TextSnapshot;
import flash.geom.Point;

    /**
     *  @copy flash.display.DisplayObjectContainer#addChild()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function addChild(child:DisplayObject):DisplayObject;
   
    /**
     *  @copy flash.display.DisplayObjectContainer#addChildAt()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function addChildAt(child:DisplayObject, index:int):DisplayObject;
    
    /**
     *  @copy flash.display.DisplayObjectContainer#removeChild()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function removeChild(child:DisplayObject):DisplayObject;
    
    /**
     *  @copy flash.display.DisplayObjectContainer#removeChildAt()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function removeChildAt(index:int):DisplayObject;

    /**
     *  @copy flash.display.DisplayObjectContainer#getChildIndex()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getChildIndex(child:DisplayObject):int;
    
    /**
     *  @copy flash.display.DisplayObjectContainer#setChildIndex()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function setChildIndex(child:DisplayObject, index:int):void;

    /**
     *  @copy flash.display.DisplayObjectContainer#getChildAt()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getChildAt(index:int):DisplayObject;
    
    /**
     *  @copy flash.display.DisplayObjectContainer#getChildByName()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getChildByName(name:String):DisplayObject;

    /**
     *  @copy flash.display.DisplayObjectContainer#numChildren
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get numChildren():int;

    /**
     *  @copy flash.display.DisplayObjectContainer#textSnapshot
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get textSnapshot():TextSnapshot;
    
    /**
     *  @copy flash.display.DisplayObjectContainer#getObjectsUnderPoint()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getObjectsUnderPoint(point:Point):Array;

    /**
     *  @copy flash.display.DisplayObjectContainer#areInaccessibleObjectsUnderPoint()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function areInaccessibleObjectsUnderPoint(point:Point):Boolean;

    /**
     *  @copy flash.display.DisplayObjectContainer#tabChildren
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get tabChildren():Boolean;
    function set tabChildren(enable:Boolean):void;
    
    /**
     *  @copy flash.display.DisplayObjectContainer#mouseChildren
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get mouseChildren():Boolean;
    function set mouseChildren(enable:Boolean):void;

    /**
     *  @copy flash.display.DisplayObjectContainer#contains()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function contains(child:DisplayObject):Boolean;

    /**
     *  @copy flash.display.DisplayObjectContainer#swapChildrenAt()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function swapChildrenAt(index1:int, index2:int):void;

    /**
     *  @copy flash.display.DisplayObjectContainer#swapChildren()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function swapChildren(child1:DisplayObject, child2:DisplayObject):void;
