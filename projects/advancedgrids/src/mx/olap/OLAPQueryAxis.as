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

import mx.resources.ResourceBundle;
import mx.resources.ResourceManager;

[ResourceBundle("olap")]

/**
 *  The OLAPQueryAxis interface represents an axis of an OLAP query.
 *
 *  @mxml
 *  <p>
 *  The <code>&lt;mx:OLAPQueryAxis&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, and adds the following tag attributes:
 *  </p>
 *  <pre>
 *  &lt;mx:OLAPQueryAxis
 *    <b>Properties</b>
 *  /&gt;
 *
 *  @see mx.olap.OLAPQuery
 *  @see mx.olap.IOLAPQueryAxis
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPQueryAxis implements IOLAPQueryAxis
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     *
     *  @param ordinal The type of axis. 
     *  Use <code>OLAPQuery.COLUMN AXIS</code> for a column axis, 
     *  <code>OLAPQuery.ROW_AXIS</code> for a row axis, 
     *  and <code>OLAPQuery.SLICER_AXIS</code> for a slicer axis.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function OLAPQueryAxis(ordinal:int)
    {
        axisOrdinal = ordinal;
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // axisOrdinal
    //----------------------------------
    
    /**
     *  The type of axis, as 
     *  <code>OLAPQuery.COLUMN AXIS</code> for a column axis, 
     *  <code>OLAPQuery.ROW_AXIS</code> for a row axis, 
     *  and <code>OLAPQuery.SLICER_AXIS</code> for a slicer axis.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var axisOrdinal:int;
    
    //----------------------------------
    // sets
    //----------------------------------
    
    private var _sets:Array = [];
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get sets():Array
    {
        return _sets;
    }
    
    //----------------------------------
    // tuples
    //----------------------------------
    
    private var _tuples:Array = [];

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get tuples():Array
    {
        return _tuples;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
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
    public function addMember(m:IOLAPMember):void
    {
        if (!m)
        {
            var message:String = ResourceManager.getInstance().getString(
                    "olap", "nullMemberOnAxis", [axisOrdinal]);
            throw new QueryError(message);
        }
        
        var t:OLAPTuple = new OLAPTuple;
        _tuples.push(t);

        //TODO should we keep creating new sets?
        var s:OLAPSet = new OLAPSet;
        s.addTuple(t)
        _sets.push(s);

        t.addMember(m);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function addSet(s:IOLAPSet):void
    {
        _sets.push(s);
        for each (var t:OLAPTuple in OLAPSet(s).tuples)
        {
            _tuples.push(t);
        }
    }   

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function addTuple(t:IOLAPTuple):void
    {
        _tuples.push(t);
        var s:OLAPSet = new OLAPSet;
        s.addTuple(t)
        _sets.push(s);
    }
    
    /**
     * Clears all the sets, tuples and members from this axis.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function clear():void
    {
		_tuples.splice(0);
		_sets.splice(0);    	
    }
}

}
