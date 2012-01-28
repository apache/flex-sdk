
package mx.olap
{

import mx.collections.ArrayCollection;
import mx.collections.IList;

/**
 *  The OLAPAxisPosition class represents a position along the axis of the result of an OLAP query result.
 *
 *  @see mx.olap.IOLAPResultAxis
 *  @see mx.olap.IOLAPResult
 *  @see mx.olap.OLAPResult
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPAxisPosition implements IOLAPAxisPosition
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
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function OLAPAxisPosition()
    {
        super();    
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // members
    //----------------------------------
    
    private var _members:ArrayCollection = new ArrayCollection;
    
    /**
     *  The members of the query result,
     *  at this position as a list of IOLAPMember instances.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get members():IList
    {
        return _members;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    public function addMember(member:IOLAPMember):void
    {
        // should we check for duplicates here?
        _members.addItem(member);
    }
    
}
}