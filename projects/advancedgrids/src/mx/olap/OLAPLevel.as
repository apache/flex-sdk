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

import mx.collections.IViewCursor;
import mx.collections.ICollectionView;
import flash.utils.Dictionary;
import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.core.mx_internal;
import mx.resources.ResourceManager;

use namespace mx_internal;

[ResourceBundle("olap")]

/**
 *  The OLAPLevel class represents a level in an OLAP cube.
 *
 *  @mxml
 *  <p>
 *  The <code>&lt;mx:OLAPLevel&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, and adds the following tag attributes:
 *  </p>
 *  <pre>
 *  &lt;mx:OLAPLevel
 *    <b>Properties</b>
 *    attributeName=""
 *  /&gt;
 *
 *  @see mx.olap.IOLAPLevel 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPLevel extends OLAPElement implements IOLAPLevel
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Temporary location to hold the OLAPMember instance which
     *  didn't get used. This helps is reducing the number of instances
     *  of OLAPMembers getting created.
     */    
    static private var tempMember:OLAPMember;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     *
     *  @param name The name of the OLAP level that includes the OLAP schema hierarchy of the element. 
     *  For example, "Time_Year", where "Year" is a level of the "Time" dimension in an OLAP schema.
     *
     *  @param displayName The name of the OLAP level, as a String, which can be used for display.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function OLAPLevel(name:String=null, displayName:String=null)
    {
        OLAPTrace.traceMsg("Created Level: " + name, OLAPTrace.TRACE_LEVEL_3);
        super(name, displayName);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  A map of members based on their unique name.
     */
    private var _membersMapOnUName:Dictionary = new Dictionary(true);

    /**
     *  @private
     *  A map of members based on their name.
     *  The value is an array.
     */
    private var _membersMapOnName:Dictionary = new Dictionary(true);

    /**
     *  @private
     *  A list of members as they were added to the level.
     */
    private var orderedMembers:ArrayCollection = new ArrayCollection;
    
    /**
    *  @private
    *  The all member name used at a level.
    */
    private var _allMemberName:String = "(All)";
    
    /**
     *  @private
     *  The all member objecct for this level
     */
    mx_internal var levelAllMember:IOLAPMember;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------   
    
    //----------------------------------
    // name
    //----------------------------------

    /**
     *  The value of the <code>name</code> property of the 
     *  OLAPAttribute instance associated with this OLAPLevel instance. 
     *  Even though this property is writable, its value is determned by the OLAPAttribute instance 
     *  associated with the level and cannot be set.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get name():String
    {
        if (_attribute)
            return _attribute.name;
        return super.name;
    }
    
    /**
     *  @private
     */
    override public function set name(value:String):void
    {
        OLAPTrace.traceMsg("Attempt to set the name of a level. Name of a level is defined by the associated attribute", OLAPTrace.TRACE_LEVEL_1);  
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
        return String("[" + hierarchy.dimension.name + "].[" + hierarchy.name + "].[" + name + "]");
    }
    
    //----------------------------------
    // attribute
    //----------------------------------
    
    /**
     *  @private
     *  The attribute connected to this level. 
     */
    private var _attribute:OLAPAttribute;
    
    /**
     *  The attribute connected to this level, as an instance of OLAPAttribute. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get attribute():OLAPAttribute
    {
        return _attribute;
    }
    
    //----------------------------------
    // attributeName
    //----------------------------------
    
    private var _attributeName:String;

    /**
     *  The name of the attribute to be used at this level. 
     *  The value of this property corresponds to the value of the 
     *  <code>OLAPAttribute.name</code> property for the corresponding attribute.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get attributeName():String
    {
        return _attributeName;
    }
    
    /**
     *  @private
     */
    public function set attributeName(value:String):void
    {
        _attributeName = value;
    }
    
    //----------------------------------
    // child
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get child():IOLAPLevel
    {
        var levels:IList = OLAPHierarchy(hierarchy).allLevels;
        var index:int = levels.getItemIndex(this);
        
        if (index < levels.length-1)
            return levels.getItemAt(index+1) as IOLAPLevel;
        
        return null;
    }
    
    //----------------------------------
    // dataField
    //----------------------------------
    
    /**
     *  The field of the input data set 
     * that provides the data for this OLAPLevel instance.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get dataField():String
    {
        if (_attribute)
            return _attribute.dataField;
        
        return null;
    }
    
    //----------------------------------
    // dataFunction
    //----------------------------------
    
    /**
     *  @private
     *  A callback function which would be called
     *  to get the data value for this particular level.
     *  Users can create calculated members by providing this function.
     *  Example : If input data contains ages(1, 4, 9, 10, 12, 15, 20 etc) of people a new Attribute
     *  can be defined to return age groups (1-10, 11-20 etc).
     */
    mx_internal function get dataFunction():Function
    {
        if (_attribute)
            return _attribute.dataFunction;
        
        return null;
    }
    
    //----------------------------------
    // dataCompareFunction
    //----------------------------------
    
    /**
     *  @private
     */
    mx_internal function get dataCompareFunction():Function
    {
        if (_attribute)
            return _attribute.dataCompareFunction;
        
        return null;
    }
    
    //----------------------------------
    // depth
    //----------------------------------
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get depth():int
    {
        return OLAPHierarchy(hierarchy).allLevels.getItemIndex(this);
    }
    
    //----------------------------------
    // hierarchy
    //----------------------------------
    
    /**
     *  @private
     */
    private var _hierarchy:IOLAPHierarchy;

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
        return _hierarchy;
    }
    
    /**
     *  @private
     */
    public function set hierarchy(h:IOLAPHierarchy):void
    {
        _hierarchy = h;
    }
    
    //----------------------------------
    // members
    //----------------------------------
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get members():IList
    {
        if (hierarchy.allMemberName == name)
            return getMembers();
        return getMembers(false);
    }
    
    //----------------------------------
    // parent
    //----------------------------------
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get parent():IOLAPLevel
    {
        var levels:IList = OLAPHierarchy(hierarchy).allLevels;
        var index:int = levels.getItemIndex(this);
        if (index >= 1)
            return levels.getItemAt(index-1) as IOLAPLevel;
        return null;
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
    public function findMember(name:String):IList
    {
        return _membersMapOnName[name];
    }
    
    /**
     *  @private 
     *  Adds a member to the level. 
     *
     *  @param m The member to add.
     *
     *  @return <code>true</code> if the member is added, and <code>false</code> if not.
     */
    mx_internal function addMember(m:OLAPMember):Boolean
    {
        m.level = this;
        var member:Object = _membersMapOnUName[m.uniqueName];
        if (member)
        {
            member = _membersMapOnName[m.name];
	        if (member)
	            return false;
        }

        _membersMapOnUName[m.uniqueName] = m;
        if (_membersMapOnName[m.name])
        {
            _membersMapOnName[m.name].addItem(m);
        }
        else
        {
            _membersMapOnName[m.name] = new ArrayCollection();
            _membersMapOnName[m.name].addItem(m);
        }
        orderedMembers.addItem(m);
        return true;
    }
    
    /**
     *  @private
     *  Creates a new IOLAPMember instance and add it to the level. 
     *
     *  @param parent The parent of the member.
     *
     *  @param name The name of the member.
     *
     *  @return The IOLAPMember instance that represents the new member.
     */
    mx_internal function createMember(parent:IOLAPMember, name:String):IOLAPMember
    {
        var member:OLAPMember;// = _membersMap[name];
        //we need to create a new member if the parents are different
        //if (!member || member.parent != parent)
        {
        	if (tempMember)
        	{
        		member = tempMember;
                //initialize the name explicitly
        		member.name = name;
        	}
        	else
            member = new OLAPMember(name);
            member.parent = parent;
            member.level = this;
            member.dimension = dimension;

            //should we map this using unique name?
            //if (!_membersMap[name])
            //  _membersMap[name] = [];
            //_membersMap[name].push(member);
            if (!_membersMapOnUName[member.uniqueName])
            {
            	tempMember = null;
	            
	            if (attribute && attribute.displayNameFunction != null)
    	        	member.displayName = attribute.displayNameFunction(name);
    	        	
                _membersMapOnUName[member.uniqueName] = member;
            
                if (_membersMapOnName[member.name])
                {
                    _membersMapOnName[member.name].addItem(member);
                }
                else
                {
                    _membersMapOnName[member.name] = new ArrayCollection;
                    _membersMapOnName[member.name].addItem(member);
                }
                
                orderedMembers.addItem(member);
                
	            if (parent)
	            {
	                //OLAPTrace.traceMsg("Member parent: " + parent.name, OLAPTrace.TRACE_LEVEL_3);
	                //add the member to its parent
	                OLAPMember(parent).addChild(member);
	            }
	        }
    	    else
            {
            	tempMember = member;
                member = _membersMapOnUName[member.uniqueName];
            }
        }
        //else
        //  OLAPTrace.traceMsg("Trying to create a member again:" + member.name, OLAPTrace.TRACE_LEVEL_3);
        return member;
    }
    
    /**
     * @private
     */ 
    mx_internal function getMembers(includeAll:Boolean=true):ArrayCollection //of IOLAPMembers
    {
        if (includeAll)
            return orderedMembers;
        
        var tempArray:Array = orderedMembers.source.slice(0);
        var temp:ArrayCollection = new ArrayCollection(tempArray);
        var tempIndex:int = temp.getItemIndex(levelAllMember);
        if (tempIndex > -1)
            temp.removeItemAt(tempIndex);
        return temp;
    }
    
    /**
     *  @private
     */
    mx_internal function refresh():void
    {
        var message:String;
        if (!findMember(_allMemberName))
            levelAllMember = createMember(null, _allMemberName)

        if (_attributeName)
        {
            _attribute = OLAPDimension(dimension).findAttribute(_attributeName) as OLAPAttribute;
            if (!_attribute)
            {
                message = ResourceManager.getInstance().getString(
                    "olap", "invalidAttributeName", [_attributeName]);
                throw Error(message);
            }
        }
        else
        {
            if (OLAPHierarchy(hierarchy).allLevel != this)
            {
                message = ResourceManager.getInstance().getString(
                    "olap", "noAttributeForLevel", [hierarchy.name]);
                throw Error(message);
            }
        }
    }

    /**
     *  @private
     *  Removes a member from the level.
     *
     *  @param m The IOLAPMember instance that identifies the member to remove.
     */
    mx_internal function removeMember(m:IOLAPMember):void
    {
        if (m)
        {
            delete _membersMapOnUName[m.uniqueName];
            var list:IList = _membersMapOnName[m.name];
            var index:int = list.getItemIndex(m);
            if (index > -1)
                list.removeItemAt(index);
        }
            
    }
    
    /**
     *  @private
     *  Removes a member from the level.
     *
     *  @param name The name of the member to remove.
     */
    mx_internal function removeMemberByName(name:String):void
    {
        var m:IOLAPMember = _membersMapOnUName[name];
        if (m)
            removeMember(m);
        else
        {
            var list:IList = _membersMapOnName[name];
            if (list.length == 1)
                removeMember(list.getItemAt(0) as IOLAPMember);
        }
    }
    
}

}
