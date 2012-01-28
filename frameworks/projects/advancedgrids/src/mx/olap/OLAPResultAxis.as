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

package mx.olap
{

import mx.collections.IList;
import mx.collections.ArrayCollection;

/**
 *  The OLAPResultAxis class represents an axis of the result of an OLAP query.
 *
 *  @see mx.olap.OLAPQuery
 *  @see mx.olap.OLAPQueryAxis
 *  @see mx.olap.IOLAPResultAxis
 *  @see mx.olap.IOLAPResult
 *  @see mx.olap.OLAPResult
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPResultAxis implements IOLAPResultAxis
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // positions
    //----------------------------------
    
    private var _positions:IList = new ArrayCollection; //of IOLAPAxisPositions
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get positions():IList
    {
        return _positions;
    }
    
    /**
     *  @private
     */
    public function set positions(value:IList):void
    {
        _positions = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Adds a position to the axis of the query result.
     *
     *  @param p The IOLAPAxisPosition instance that represents the position.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function addPosition(p:IOLAPAxisPosition):void
    {
        _positions.addItem(p);
    }
    
    /**
     *  Removes a position from the axis of the query result.
     *
     *  @param p The IOLAPAxisPosition instance that represents the position.
     *
     *  @return <code>true</code> if the position is removed from the axis, 
     *  and <code>false</code> if not. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function removePosition(p:IOLAPAxisPosition):Boolean
    {
        var index:int = _positions.getItemIndex(p);
        if (index != -1)
        {
            _positions.removeItemAt(index);
            return true;
        }
        return false;
    }
    
}
}