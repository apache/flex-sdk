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

import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.core.mx_internal;

/**
 *  The OLAPMember class represents a member of an OLAP dimension.
 * 
 *  @mxml
 *  <p>
 *  The <code>&lt;mx:OLAPMember&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, and adds the following tag attributes:
 *  </p>
 *  <pre>
 *  &lt;mx:OLAPMember
 *    <b>Properties</b>
 *  /&gt;
 *
 *  @see mx.olap.IOLAPMember
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPMember extends OLAPElement implements IOLAPMember
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
     *  @param name The name of the OLAP element that includes the OLAP schema hierarchy of the element. 
     *  For example, "Time_Year", where "Year" is a level of the "Time" dimension in an OLAP schema.
     *
     *  @param displayName The name of the OLAP member, as a String, which can be used for display.
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function OLAPMember(name:String=null, displayName:String=null)
    {
        OLAPTrace.traceMsg("Creating member: " + name, OLAPTrace.TRACE_LEVEL_3);
        super(name, displayName);    
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
	/**
	 *  @private
	 *  A child members map based on their name
	 */
    private var _childrenMap:Dictionary = new Dictionary(true);

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // dimension
    //----------------------------------
    
    /**
     *  The dimension to which this member belongs.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get dimension():IOLAPDimension
    {
        if (level && level.hierarchy)
            return level.hierarchy.dimension;
        return null;
    }
    
    //----------------------------------
    // uniqueName
    //----------------------------------
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get uniqueName():String
    {
        var list:Array = [];
        list.push(this);
        
        var parent:IOLAPMember = this.parent;

        // if the member is from a OLAPAttribute then 
        // we only need to push the hierarchy name
        if (hierarchy is OLAPAttribute)
        {
            list.push(hierarchy);
        }
        else
        {
            // if the member is from a OLAPHierarchy then we need to traverse
            // its parents till we reach the top level.            
            while (parent && parent.parent)
            {
                list.push(parent);
                parent = parent.parent; 
            }
            list.push(hierarchy.levels.getItemAt(0));
            list.push(hierarchy);
        }

        list.push(dimension);
        
        var uName:String = "";
        var n:int = list.length;
        for (var i:int = n - 1; i > -1; --i)
            uName += "[" + list[i].name + "].";
        uName = uName.substring(0, uName.length-1);
        return uName;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // children
    //----------------------------------
    
    private var _children:IList = new ArrayCollection;
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get children():IList
    {
        return _children;
    }
    
    //----------------------------------
    // dataField
    //----------------------------------
    
    private var _dataField:String;
    
    /**
     *  The field of the input data set that provides 
     *  the data for this OLAPMember instance.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get dataField():String
    {
        return _dataField;
    }
    
    /**
     *  @private
     */
    public function set dataField(field:String):void
    {
        _dataField = field;
    }
    
    //----------------------------------
    // hierarchy
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get hierarchy():IOLAPHierarchy
    {
        return level.hierarchy;
    }
    
    //----------------------------------
    // isAll
    //----------------------------------
    
    private var _all:Boolean = false;
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get isAll():Boolean
    {
        return _all;
    }
    
    //----------------------------------
    // isMeasure
    //----------------------------------
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get isMeasure():Boolean
    {
        return false;
    }
    
    //----------------------------------
    // level
    //----------------------------------

    private var _level:IOLAPLevel;
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get level():IOLAPLevel
    {
        return _level;
    }
    
    /**
     *  @private
     */
    public function set level(level:IOLAPLevel):void
    {
        _level = level;
    }
    
    //----------------------------------
    // parent
    //----------------------------------
    
    private var _parent:IOLAPMember;
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get parent():IOLAPMember
    {
        return _parent;
    }
    
    /**
     *  @private
     */
    public function set parent(p:IOLAPMember):void
    {
        _parent = p;
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
    public function findChildMember(name:String):IOLAPMember
    {
        return _childrenMap[name];
    }

    /**
     *  Sets this member as the all member. 
     *  By default, the member is not the all member. 
     *
     *  @param value <code>true</code> to make this member the all member. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    mx_internal function setIsAll(value:Boolean):void
    {
        _all = value;
    }
    
    /**
     *  @private
     * 
     *  Adds a child member to this member.
     *
     *  @param m The child member to add.
     */
    mx_internal function addChild(m:IOLAPMember):void
    {
        _children.addItem(m);
        _childrenMap[m.name] = m;
    }
}

}
