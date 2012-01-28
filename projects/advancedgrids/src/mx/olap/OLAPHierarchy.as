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
import flash.utils.getTimer;

import mx.collections.ArrayCollection;
import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.IViewCursor;
import mx.core.mx_internal;

use namespace mx_internal;

//--------------------------------------
//  metadata
//--------------------------------------

[DefaultProperty("elements")]

/**
 *  The OLAPHierarchy class represents a hierarchy of the schema of an OLAP cube.
 *
 *  @mxml
 *  <p>
 *  The <code>&lt;mx:OLAPHierarchy&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, and adds the following tag attributes:
 *  </p>
 *  <pre>
 *  &lt;mx:OLAPHierarchy
 *    <b>Properties</b>
 *    allMemberName="(All)"
 *    elements="<i>An array of Levels of this hierarchy</i>"
 *    hasAll="true|false"
 *    name="<i>No default</i>"
 *  /&gt;
 *
 *  @see mx.olap.IOLAPHierarchy
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPHierarchy extends OLAPElement implements IOLAPHierarchy
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
     *  @param name The name of the OLAP level that includes the OLAP schema hierarchy of the element.
     *
     *  @param displayName The name of the OLAP level, as a String, which can be used for display. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function OLAPHierarchy(name:String=null, displayName:String=null)
    {
        OLAPTrace.traceMsg("Creating hierarchy: " + name, OLAPTrace.TRACE_LEVEL_3);
        //if (!name)
        //  name = "Hierarchy";
        super(name, displayName);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     * The all member of this hierarchy.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    mx_internal var allMember:OLAPMember;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------   
    
    //----------------------------------
    // hasAll
    //----------------------------------
    
    private var _hasAll:Boolean = true;
    
    /**
     *  @inheritDoc
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
     public function get hasAll():Boolean
    {
        return _hasAll;
    }
    
    /**
     *  @private
     */
     public function set hasAll(value:Boolean):void
    {
        //we need to recreate this.
        if (_hasAll != value)
            _allLevels = null;
        _hasAll = value;
    }
    
    //----------------------------------
    // levels
    //----------------------------------

    /**
     *  @private
     */
    protected var _levels:IList = new ArrayCollection();
    
    /**
     *  @private
     */
    protected var _levelMap:Dictionary = new Dictionary(true);
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get levels():IList
    {
        return _levels;
    }
    
    /**
     *  @private
     */
    public function set levels(value:IList):void
    {
        var level:OLAPLevel;
        _levels = value;
        _levelMap = new Dictionary(true);
        
        var n:int = levels.length;
        for (var i:int = 0; i < n; ++i)
        {
            level = levels.getItemAt(i) as OLAPLevel;
            level.hierarchy = this;
            _levelMap[level.attributeName] = level;
        }
    }
    
    //----------------------------------
    // elements
    //----------------------------------
    
    /**
    *  An Array of the  levels of the hierarchy, as OLAPLevel instances.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public function set elements(value:Array):void
    {
        levels = new ArrayCollection(value);
    }
    
    //----------------------------------
    // allLevels
    //----------------------------------
    
    /**
     *  @private
     */
    protected var _allLevels:IList;
    
    /**
     *  @private
     */
    mx_internal function get allLevels():IList
    {
        if (!_allLevels)
        {
            _allLevels = new ArrayCollection(_levels.toArray());
            _allLevels.addItemAt(allLevel, 0);
        }

        return _allLevels;
    }
    
    //----------------------------------
    // dataProvider
    //----------------------------------
    
    private var _dataProvider:ICollectionView;

    /**
     *  @private
     */
    public function get dataProvider():ICollectionView
    {
        if (_dataProvider)
            return _dataProvider;
        return OLAPDimension(dimension).dataProvider;
    }
    
    /**
     *  @private
     */
    public function set dataProvider(value:ICollectionView):void
    {
        _dataProvider = value;
    }
    
    //----------------------------------
    // allLevelName
    //----------------------------------
    
    /**
     *  @private
     */
    protected var _allLevelName:String = "(All)";
    
    /**
     *  The name of the all level for the hierarchy.
     *
     *  @default "(All)"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    mx_internal function get allLevelName():String
    {
        return _allLevelName;
    }
    
    /**
     *  @private
     */
    mx_internal function set allLevelName(value:String):void
    {
        _allLevelName = value;
    }
    
    //----------------------------------
    // allLevel
    //----------------------------------
    
    private var _allLevel:IOLAPLevel;
    
    /**
     *  The all level for the hierarchy.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    mx_internal function set allLevel(l:IOLAPLevel):void
    {
        _allLevel = l;
    }
    
    /**
     *  @private
     */
    mx_internal function get allLevel():IOLAPLevel
    {
        return _allLevel;
    }
    
    //----------------------------------
    // allMemberName
    //----------------------------------
    
    private var _allMemberName:String = "(All)";
    
    /**
     *  @inheritDoc
     *
     *  @default "(All)"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get allMemberName():String
    {
        return _allMemberName;
    }
    
    /**
     *  @private
     */
    public function set allMemberName(value:String):void
    {
        if (value && _allMemberName != value)
        {
        	//if all level and all member are already present update them
        	//this may be a rare case 
            var level:OLAPLevel = _levelMap[allLevelName];
            if (level)
            {
                level.removeMemberByName(_allMemberName);
                _allMemberName = value;
                allMember = level.createMember(null, allMemberName) as OLAPMember;
                allMember.setIsAll(true);
            }
            else
                _allMemberName = value;
        }
        
    }
    
    //----------------------------------
    // members
    //----------------------------------
    
    /**
     *  @private
     */ 
    private var allMembersCache:ArrayCollection;

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
        var temp:Array = [];
        if (hasAll)
        {
            if (!allMembersCache)
            {
                // add the all member then add children of each member up to the leaf level.
                temp.push(allMember);
                temp = temp.concat(getMembersRecursively(allMember));
                allMembersCache = new ArrayCollection(temp);
            } 
            return allMembersCache;
        }
        else
        {
            //TODO handle the case when all member is not present. Is this correct?
            var n:int = levels.length;
            for (var i:int = 0; i < n; ++i)
            {
                var level:OLAPLevel = levels.getItemAt(i) as OLAPLevel;
                temp = temp.concat(level.getMembers(false).source);
            }
        }

        return new ArrayCollection(temp);
    }
    
    //----------------------------------
    // defaultMember
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
     public function get defaultMember():IOLAPMember
    {
        if (hasAll)
            return allMember;
            
        // return the first levels first member as default
        return levels.length >= 1 ? levels[0].members[0] : null;
    }
    
    //----------------------------------
    // name
    //----------------------------------

    /**
     * User defined name of this hierarchy. If user has not set a explicit name 
     * then the dimension name is returned.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */  
    override public function get name():String
    {   
        var n:String = super.name;
        if (!n)
            return dimension.name;
        return n;
    }
    
    //----------------------------------
    // children
    //----------------------------------

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
        if (allLevel)
        {
            var temp:IOLAPMember = allLevel.members.getItemAt(0) as IOLAPMember;
            var retValue:IList = temp.children;
            return retValue; 
        }
    
        //TODO pick first level's members as we don't have the all level?
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
    public function findLevel(name:String):IOLAPLevel
    {
        // allLevel is internal
        if (name == allLevelName)
            return null;
        return _levelMap[name];
    }
    
    /**
     *  @private
     *  Creates a level of a hierarchy.
     *
     *  @param name The name of the level.
     *
     *  @return An OLAPLevel instance that represents the new level.
     */
    mx_internal function createLevel(name:String):OLAPLevel
    {
        var l:OLAPLevel = new OLAPLevel(name);
        l.hierarchy = this;
        l.dimension = dimension;
        _levels.addItem(l);
        _levelMap[name] = l;
        
        return l;   
    }
    
    /**
     *  @private
     */
    protected function createAllLevelIfRequired():void
    {
        var level:OLAPLevel;
        if (hasAll)
        {
            //check if we don't have all level and member
            // if we don't have create them
            level = _levelMap[allLevelName];
            if (!level)
            {
                //we don't want all level to get included in levels array
                //level = createLevel(allLevelName);
                level = new OLAPLevel(name);
                level.hierarchy = this;
                level.dimension = dimension;
                allLevel = level;
                allMember = level.createMember(null, allMemberName) as OLAPMember;
                allMember.setIsAll(true);
            }
        }
        else
        {
            allLevel = null;
            allMember = null;
            level = _levelMap[allLevelName];
            if (level)
            {
                var index:int = _levels.getItemIndex(level);
                if (index > -1)
                    _levels.removeItemAt(index);
                delete _levelMap[allLevelName];
            }
        }
    }
    
    /**
     *  @private
     */
    mx_internal function refresh():void
    {
        //clear the cached array
        _allLevels = null;
        allMembersCache = null;

        createAllLevelIfRequired();
        
        if (allLevel)
            OLAPLevel(allLevel).refresh();
        
        for each (var level:OLAPLevel in _levels)
        {
            level.dimension = dimension;
            level.refresh();
        }    
    }
    
    /**
     *  @private
     */
    mx_internal function processData(data:Object):void
    {
        var parent:IOLAPMember;
        if (allLevel)
            parent = allLevel.members.getItemAt(0) as IOLAPMember;
        
        var n:int = levels.length;
        for (var i:int = 0; i < n; ++i)
        {
            var level:OLAPLevel = levels.getItemAt(i) as OLAPLevel;
            var value:String = level.dataFunction(data, level.dataField);
            
            //the new member is parent to the next member
            parent = level.createMember(parent, value);
        }
    }

    /**
     *  @private
     */
    private function makeMembers():Boolean
    {
        var iterator:IViewCursor = dataProvider.createCursor();
        
        var startTime:int = getTimer();
        
        while (!iterator.afterLast)
        {
            var currentData:Object = iterator.current;
            processData(currentData);
            iterator.moveNext();
        }
        
        var endTime:int = getTimer();

        return true;            
    }
    
    /**
     *  @private
     */
    private function getMembersRecursively(m:IOLAPMember):Array
    {
        var temp:Array = [];
        var children:IList = m.children;
        var n:int = children.length;
        for (var i:int = 0; i < n; ++i)
        {
            var member:IOLAPMember = children.getItemAt(i) as IOLAPMember;
            temp.push(member);
            if (member.children.length > 0)
            {
                var members:Array = getMembersRecursively(member);
                temp = temp.concat(members);
            }
        }
        return temp;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function findMember(name:String):IOLAPMember
    {
        if (allLevel)
        {
            if (name == allMemberName)
                return allMember;
            return allMember.findChildMember(name);
        }
        
        if (levels.length)
        {
            var defLevel:IOLAPLevel = levels[0];
            var list:IList = defLevel.findMember(name);
            if (list && list.length == 1)
                return list.getItemAt(0) as IOLAPMember;
        }
        
        return null;
    }
}
    
}
