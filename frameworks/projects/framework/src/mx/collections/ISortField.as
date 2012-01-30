////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.collections
{
/**
 *  The <code>ISortField</code> interface defines the interface for classes that
 *  are used with <code>ISort</code> classes, to provide the sorting information
 *  required to sort the specific fields or property in a collection view.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 4.5
 */
public interface ISortField
    {
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  This helper property is used internally by the <code>findItem()</code> 
     *  and <code>sort()</code> methods. Other uses of this property are not 
     *  supported.
     *  Returns -1 if this ISortField shouldn't be used by the <code>Sort</code>
     *  class to sort the field (there is no compareFunction or no name). Otherwise, returns a bitmask of sort options..
     * 
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    function get arraySortOnOptions():int;

    /**
     *  The function that compares two items during a sort of items for the
     *  associated collection. If you specify a <code>compareFunction</code>
     *  property in an ISort object, Flex ignores any 
     *  <code>compareFunction</code> properties of the ISort's ISortField
     *  objects.
     *  <p>The compare function must have the following signature:</p>
     *
     *  <p><code>function myCompare(a:Object, b:Object):int</code></p>
     *
     *  <p>This function returns the following values:</p>
     *
     *   <ul>
     *        <li>-1, if <code>a</code> should appear before <code>b</code> in
     *        the sorted sequence</li>
     *        <li>0, if <code>a</code> equals <code>b</code></li>
     *        <li>1, if <code>a</code> should appear after <code>b</code> in the
     *        sorted sequence</li>
     *  </ul>
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    function get compareFunction():Function;
    function set compareFunction(c:Function):void;

    /**
     *  Specifies whether this field should be sorted in descending
     *  order.
     *
     *  <p>The default value is <code>false</code> (ascending).</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    function get descending():Boolean;
    function set descending(value:Boolean):void;

    /**
     *  The name of the field to be sorted.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    function get name():String;
    function set name(n:String):void;

    /**
     *  Specifies that if the field being sorted contains numeric
     *  (<code>number/int/uint</code>) values, or string representations of numeric values,
     *  the comparator use a numeric comparison.
     *  <p>
     *  This property is used by <code>SortField</code> class in case custom compare
     *  function is not provided.
     *  </p>
     *  <p>
     *  If this property is <code>true</code>, the built-in numeric compare
     *  function is used. Each of data items is cast to a
     *  <code>Number()</code> function before the comparison.
     *  </p>
     *  <p>
     *  If this property is <code>false</code>, the built-in string compare
     *  function is used. Each of data items is cast to a
     *  <code>String()</code> function before the comparison.
     *  </p>
     *  <p>
     *  If this property is <code>null</code>, the first data item
     *  is introspected to see if it is a number or string and the sort
     *  proceeds based on that introspection.
     *  </p>
     *  
     *  @default null
     *  
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    function get numeric():Object;
    function set numeric(value:Object):void;

    /**
     *  True if this <code>ISortField</code> uses a custom comparator function.
     *
     *  @see @compareFunction
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    function get usingCustomCompareFunction():Boolean;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  A helper function called by the <code>Sort</code> class to set the
     *  default comparison function to perform a comparison based on
     *  one of three things: whether or not a custom compare function has
     *  been set, the data type for the specified field or the the value of the
     *  numeric property. If the the <code>numeric</code> property is true,
     *  then a numeric comparison will be performed when sorting.
     *
     *  @param obj The object that contains the data. If the field name has
     *  been set with the name property, then the name will be used to access
     *  the data value from this object. Otherwise the object itself will
     *  be used as the data value.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    function initializeDefaultCompareFunction(obj:Object):void;

    /**
     *  Reverse the criteria for this sort field.
     *  If the field was sorted in descending order, for example, sort it
     *  in ascending order.
     *
     *  <p>NOTE: An <code>ICollectionView</code> does not automatically 
     *  update when the <code>ISortFields</code> are modified; call its 
     *  <code>refresh()</code> method to update the view.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    function reverse():void;
}
}
