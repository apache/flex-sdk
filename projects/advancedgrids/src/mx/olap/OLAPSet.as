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

import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.core.mx_internal;
import mx.resources.ResourceManager;

use namespace mx_internal;

[ResourceBundle("olap")]

/**
 *  The OLAPSet class represents a set, 
 *  which is used to configure the axis of an OLAP query.
 *  A set consists of zero or more tuples; 
 *  a set that does not contain any tuples is known as an empty set.
 *
 *  @see mx.olap.IOLAPSet
 *  @see mx.olap.OLAPQueryAxis
 *  @see mx.olap.IOLAPResultAxis
 *  @see mx.olap.OLAPResultAxis
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPSet implements IOLAPSet
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
    public function OLAPSet()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private 
     *  flag to indicate the mode in which compareMembers should
     *  return the values.
     */
    private var reverseCompare:Boolean = false;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // tuples
    //----------------------------------
    
    private var _tuples:Array = [];

    /**
     *  The tuples contained by this set instance, 
     *  as an Array of IOLAPTuple instances.
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
    public function addElement(e:IOLAPElement):void
    {
        var members:IList = new ArrayCollection;
        if (e is IOLAPDimension)
            members.addItem((e as IOLAPDimension).defaultMember);
        if (e is IOLAPHierarchy)
            members.addItem((e as IOLAPHierarchy).defaultMember);
        if (e is IOLAPLevel)
            members = (e as IOLAPLevel).members;
        if (e is IOLAPMember)
            members.addItem(e);
        
        var t:OLAPTuple;
        if (members.length > 0)
        {
        	var n:int = members.length;
            for (var i:int = 0; i < n; ++i)
            {
                var m:IOLAPMember = members[i];
                t = new OLAPTuple();
                t.addMember(m);
                _tuples.push(t);
            }
        }
        else
        {
            OLAPTrace.traceMsg("Members were not added for " + e.uniqueName, OLAPTrace.TRACE_LEVEL_1);      
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
    public function addElements(members:IList):void
    {
        var t:OLAPTuple;
        var n:int = members.length;
        for (var i:int = 0; i < n; ++i)
        {
            var m:IOLAPMember = members[i];
            t = new OLAPTuple();
            t.addMember(m);
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
    public function addTuple(tuple:IOLAPTuple):void
    {
        _tuples.push(tuple);
    }
    
    /**
     * @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function crossJoin(input:IOLAPSet):IOLAPSet
    {
        var join:OLAPSet = input as OLAPSet;
        validateCrossJoin(join);
        var newSet:OLAPSet = new OLAPSet();
        
        var tuple:OLAPTuple = new OLAPTuple();
        for each (var tuple1:OLAPTuple in _tuples)
        {
            for each (var tuple2:OLAPTuple in join.tuples)
            {
                tuple.addMembers(tuple1.explicitMembers);
                tuple.addMembers(tuple2.explicitMembers);
                if (tuple.isValid)
                {
                    newSet.addTuple(tuple);
                    tuple = new OLAPTuple();
            	}
            	else
            	{
            		tuple.clear();
            	}
            }
        }
        
        return newSet;
    }
    
    /**
     *  @private
     *  Validates a crossjoin defined by an IOLAPSet instance.
     *
     *  This method throws an error if the crossjoin is invalid.
     *
     *  @param input The IOLAPSet instance that contains a crossjoin 
     *  of two IOLAPSet instances.
     */
    protected function validateCrossJoin(input:IOLAPSet):void
    {
        var join:OLAPSet = input as OLAPSet;
        for each (var t1:OLAPTuple in _tuples)
        {
            for each (var t2:OLAPTuple in join.tuples)
            {
                var hierarchy:IOLAPHierarchy = findCommonHierarchy(t1, t2);
                if (hierarchy)
                {
                    var message:String = ResourceManager.getInstance().getString(
                            "olap", "crossJoinSameHierarchyError", [hierarchy.uniqueName]);
                    throw Error(message);
                }
            }
        }
        
    }
    
    /**
     *  Returns the common IOLAPHierarchy instance for two tuples, 
     *  or null if the tuples do not share a hierarchy.
     *
     *  @param t1 The first tuple.
     *
     *  @param t2 The second tuple.
     *
     *  @return The common IOLAPHierarchy instance for the two tuples, 
     *  or null if the tuples do not share a hierarchy.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function findCommonHierarchy(t1:OLAPTuple, t2:OLAPTuple):IOLAPHierarchy
    {
        for each (var m1:OLAPMember in t1.explicitMembers)
        {
            for each (var m2:OLAPMember in t2.explicitMembers)
            {
                if (m1.hierarchy == m2.hierarchy)
                    return m1.hierarchy;        
            }
        }
        //no common hierarchy found
        return null;
    }
    
    /**
     * @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function hierarchize(post:Boolean=false):IOLAPSet
    {
        var newSet:OLAPSet = new OLAPSet;

        reverseCompare = post;
        // go through all the tuples of the set and arrange them in 
        // their natural order. 
        var arrayIndices:Array = tuples.sort(sortTuple, Array.RETURNINDEXEDARRAY);
        
        for each (var index:int in arrayIndices)
            newSet.addTuple(_tuples[index]);
        
        //reset the flag because union also uses compareMembers function.
        reverseCompare = false;            
        return newSet;
    }
    
    /**
     *  Returns information about the relative location of 
     *  two members in the set. 
     *
     *  @param m1 The first member.
     *
     *  @param m2 The second member.
     *
     *  @return The following:
     *  <ul>
     *    <li>0 if the members are at the same level</li>
     *    <li>1 if m2 is higher in the hierarchy than m1</li>
     *    <li>-1 if m1 is higher in the hierarchy than m2</li>
     *  </ul>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function compareMembers(m1:IOLAPMember, m2:IOLAPMember):int
    {
        //trace("Comparing " + m1.name + " " + m2.name);
        if (m1 == m2)
            return 0;
        
        while (true)
        {   
            if (m1 && !m2)
                return reverseCompare ? -1 : 1;
            if (!m1 && m2)
                return reverseCompare ? 1 : -1;
            
            if (m1.level.depth < m2.level.depth)
            {
                m2 = m2.parent;
                if (m1 == m2)
                    return reverseCompare ? 1 : -1;
            }
            else if (m1.level.depth > m2.level.depth)
            {
                m1 = m1.parent;
                if (m1 == m2)
                    return reverseCompare ? -1 : 1;
            }
            else 
            {
                if (m1.parent == m2.parent)
                {
                    var compResult:int = m1.name.localeCompare(m2.name);
        
                    if (compResult == 0)
                        return 0;
                    else if (compResult > 0)
                        return 1;
                    else 
                        return -1;
                }
                m1 = m1.parent;
                m2 = m2.parent;
            }
        }
                        
        return 0;
    }
    
    /**
     *  Returns information about the relative location of 
     *  two tuples in the set. 
     *
     *  @param t1 The first tuple.
     *
     *  @param t2 The second tuple.
     *
     *  @return The following:
     *  <ul>
     *    <li>0 if the tuples are at the same level</li>
     *    <li>1 if t2 is higher than t1</li>
     *    <li>-1 if t1 is higher than t2</li>
     *  </ul>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function sortTuple(t1:OLAPTuple, t2:OLAPTuple):int
    {
        var t1Mems:Array = t1.explicitMembers.toArray();
        var t2Mems:Array = t2.explicitMembers.toArray();
        
        var n:int = t1Mems.length;
        for (var i:int = 0; i < n; ++i) 
        {
            var m1:IOLAPMember = t1Mems[i];
            var m2:IOLAPMember = t2Mems[i];
            var result:int = compareMembers(m1, m2);
            if (result != 0)
                break;
        }

        return result;
    }
    
    /**
    * @private
    */
    private function isDuplicate(t1:OLAPTuple, t2:OLAPTuple):Boolean
    {
        var m1:IList = t1.explicitMembers;
        var m2:IList = t2.explicitMembers;

        var n:int = m1.length;        
        for (var i:int = 0; i < n; ++i)
        {
            if (m1.getItemAt(i) != m2.getItemAt(i))
                return false;
        }
        
        return true;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function union(secondSet:IOLAPSet):IOLAPSet
    {
        //TODO should we handle null sets?
        
        var input:OLAPSet = secondSet as OLAPSet;
        var newSet:OLAPSet = new OLAPSet;
        //check for same hierarchy
        var ts1:Array = tuples;
        var ts2:Array = input.tuples;
        
        //create a hierarchy array which can be used for comparision
        var hierarchies:Array = [];
        var t1:IOLAPTuple = ts1[0];
        var m1:IList = t1.explicitMembers;
        var explicitMemberLength:int = m1.length;
        for (var i:int = 0; i < explicitMemberLength; ++i)
        {
            hierarchies.push(m1.getItemAt(i).hierarchy);
        }
        
        checkTupleHierarchies(this, explicitMemberLength, hierarchies);
        checkTupleHierarchies(input, explicitMemberLength, hierarchies);
        
        var newTuples:Array = tuples.concat(input._tuples);
        
        //TODO remove duplicates
        var arrayIndices:Array = newTuples.sort(sortTuple, Array.RETURNINDEXEDARRAY);
            
        var end:int = arrayIndices.length - 1;
        var duplicates:Array = [];
        for (i = 0; i < end; ++i)
        {
	        if (isDuplicate(newTuples[arrayIndices[i]], newTuples[arrayIndices[i + 1]]))
	        {
	            duplicates.push(arrayIndices[i]);
	        }
        }
        
        //we remove items backwards as otherwise indices will change
        //with each item removal  
        duplicates = duplicates.sort(Array.NUMERIC | Array.DESCENDING);
        for each (i in duplicates)
            newTuples.splice(i, 1);
        
        newSet._tuples = newTuples;
        
        return newSet;
    }
    
    /**
    * @private
    */
    private function checkTupleHierarchies(olapSet:OLAPSet, length:int, hierarchies:Array):void
    {
        var tuples:Array = olapSet.tuples;
        var message:String = ResourceManager.getInstance().getString(
            "olap", "unionError");
        //validate input set
        var n:int = tuples.length;
        for (var i:int = 0; i < n; ++i)
        {
            var tuple:OLAPTuple = tuples[i];
            var members:IList = tuple.explicitMembers;
            
            if (members.length != length)
                throw Error(message);   
            
            for (var j:int = 0; j < length; ++j)
            {
                var hierarchy:IOLAPHierarchy = members.getItemAt(j).hierarchy;
                if (hierarchy != hierarchies[j])
                    throw Error(message);
            }
        }
    }
}

}
