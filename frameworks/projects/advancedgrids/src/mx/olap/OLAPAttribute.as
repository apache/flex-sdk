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

import mx.collections.IList;
import mx.collections.ArrayCollection;
import mx.core.mx_internal;

use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="levels", kind="property")]
[Exclude(name="elements", kind="property")]

/**
 *  The OLAPAttribute class represents a single attribute of an OLAPDimension.
 *  Use this class to associate a field of the flat data that is used to populate
 *  an OLAP cube with a level of the dimension.
 *
 *  @mxml
 *  <p>
 *  The <code>&lt;mx:OLAPAttribute&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, and adds the following tag attributes:
 *  </p>
 *  <pre>
 *  &lt;mx:OLAPAttribute
 *    <b>Properties</b>
 *    dataField=""
 *  /&gt;
 *.
 *  @see mx.olap.OLAPDimension
 *  @see mx.olap.OLAPLevel
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPAttribute extends OLAPHierarchy implements IOLAPAttribute
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *
     *  @param name The name of the OLAPAttribute instance. 
     *  You use this parameter to associate the OLAPAttribute instance with an OLAPLevel instance.
     *
     *  @param displayName The name of the attribute, as a String, which can be used for display.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function OLAPAttribute(name:String = null, displayName:String=null)
    {
        super(name, displayName);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var uniqueChildrenMap:Dictionary = new Dictionary(true);

    private var uniqueMembers:IList = new ArrayCollection;

    private var singleLevel:OLAPLevel;
    
    mx_internal var userDataFunction:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // allLevels
    //----------------------------------
    
    /**
     * @private
     */
    override mx_internal function get allLevels():IList
    {
        return new ArrayCollection([allLevel, singleLevel]);
    }
    
    //----------------------------------
    // hasAll
    //----------------------------------

    /**
     *  Contains <code>true</code> because attributes are assumed to be aggregatable 
     *  and all member is present. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get hasAll():Boolean
    {
        //can this flag be false?
        //if the attribute is not aggregatable this can be false
        //but we are not supporting this as of now
        return true;
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
    override public function get members():IList
    {
        //TODO ***** we need to send the all member here.
        var temp:ArrayCollection = new ArrayCollection(uniqueMembers.toArray());
        temp.addItemAt(super.findMember(allMemberName), 0);

        return temp;
    }
    
    //----------------------------------
    // children
    //----------------------------------

    /**
     *  @private
     */
    override public function get children():IList
    {
        return uniqueMembers;
    }
    
    //----------------------------------
    // levels
    //----------------------------------
    
    /**
     *  @private
     */
    override public function set levels(value:IList):void
    {
        // attribute doesn't allow setting up of levels by users
        // it has its own level creation logic
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------   
    
    //----------------------------------
    // userHierarchy
    //----------------------------------
    
    private var _userHierarchy:IOLAPHierarchy;
    
    mx_internal function get userHierarchy():IOLAPHierarchy
    {
        return _userHierarchy;
    }
    
    mx_internal function set userHierarchy(value:IOLAPHierarchy):void
    {
        _userHierarchy = value;
    }
    
    //----------------------------------
    // userHierarchyLevel
    //----------------------------------
    
    private var _userHierarchyLevel:OLAPLevel;
    
    mx_internal function get userHierarchyLevel():OLAPLevel
    {
        return _userHierarchyLevel;
    }
    
    mx_internal function set userHierarchyLevel(value:OLAPLevel):void
    {
        _userHierarchyLevel = value;
    }
    
    //----------------------------------
    // dataField
    //----------------------------------
    
    private var _dataField:String;
    
    /**
     *  The field of the input data set that provides the data for 
     *  this OLAPAttribute instance. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function set dataField(value:String):void
    {
        _dataField = value;
    }
    
    /**
     * @private
     */
    public function get dataField():String
    {
        return _dataField;  
    }
    
    //----------------------------------
    // dataFunction
    //----------------------------------
    
    /**
     * @private
     */
    protected var _dataFunction:Function = internalDataFunction;
    
    /**
    *  A callback function that returns the actual data for the attribute.
    *  Use this callback function to return computed data based on the
    *  actual data. For example, you can return the month name as a String 
    *  from actual date that represents the month as a number. 
    *  Or, you can calculate a value.
    *  For example, your input data contains the ages of people, 
    *  such as 1, 4, 9, 10, 12, 15, or 20.
    *  Your callback function can return an age group 
    *  that contains the age, as in 1-10, or 11-20.
    *
    *  <p>The signature of the callback function is:</p>
    *
    *  <pre>
    *      function myDataFunction(rowData:Object, dataField:String):Object;</pre>
    *
    *  where <code>rowData</code> contains the data for the row of 
    *  the input flat data, and <code>dataField</code> contains 
    *  the name of the data field.
    *
    *  <p>The function can return a String or a Number.</p>
    *
    *  <p>The following example returns the age group for each age value 
    *  in the flat data:</p>
    *
    *  <pre>
    *      private function ageGroupingHandler(rowData:Object, field:String):Object
    *      {
    *          return rowData[field] / 10;
    *      } </pre>
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public function get dataFunction():Function
    {
        return _dataFunction;
    }
    
    public function set dataFunction(value:Function):void
    {
        if (value != null)
        {
            _dataFunction = value;
            userDataFunction = true;
        }
        else
        {
            _dataFunction = internalDataFunction;
            userDataFunction = false;           
        }
    }

    /**
     *  User supplied callback function that would be used to compare
     *  the data elements while sorting the data. By default the data
     *  members would be compared directly.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var dataCompareFunction:Function = internalDataCompareFunction;
    
    /**
     *  A callback function that returns the display name of a member element.
     *  Flex calls this function for each member added
     *  to the OLAPAttribute instance. 
     *
     *  <p>The function signature is:</p>
     *
     *  <pre>
     *      function myDisplayNameFunction(memberName:String):String</pre>
     *
     *  <p>where <code>memberName</code> contains the name of the element.</p>
     *
     *  <p>The function returns the display name of the element.</p>
     *
     *  <p>The following example converts a numeric group name, such as 1,2, or 3 
     *  into display names "0-9", "10-19":</p>
     *
     *  <pre>
     *      private function myDispFunction(name:String):String
     *      {
     *          var value:int = parseInt(name);
     *          return String((value)*10 + " - ") + String((value+1)*10-1);     
     *      }</pre>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    public var displayNameFunction:Function;
   
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    override public function findLevel(name:String):IOLAPLevel
    {
        return null;
    }
    
    
    override mx_internal function processData(data:Object):void
    {
        var name:String = dataFunction(data, dataField);
        if (!uniqueChildrenMap[name])
        {
            var m:IOLAPMember = singleLevel.createMember(allMember, name);
            
            if (displayNameFunction != null)
                OLAPMember(m).displayName = displayNameFunction(name); 
            uniqueChildrenMap[m.name] = m;
            uniqueMembers.addItem(m);
        }
    }
    
    /**
     * @private
     */
    override mx_internal function refresh():void
    {
        uniqueChildrenMap = new Dictionary(true);
        uniqueMembers = new ArrayCollection();
        
        if (!super.findLevel(name))
        {
            createAllLevelIfRequired();
                
            singleLevel = createLevel(name);
            
            OLAPLevel(allLevel).refresh();
            singleLevel.refresh();

            if (userHierarchyLevel)
            {
                if (userHierarchyLevel.depth == 1)
                    OLAPAttributeLevel(allLevel).userLevel = OLAPHierarchy(userHierarchy).allLevel;
                OLAPAttributeLevel(singleLevel).userLevel = userHierarchyLevel;
            }
        }
    }

    /**
     *  @private
     */
    override protected function createAllLevelIfRequired():void
    {
        var level:OLAPLevel;
        if (hasAll)
        {
            //check if we don't have all level and member
            // if we don't have create them
            level = _levelMap[allLevelName];
            if (!level)
            {
                //level = createLevel(allLevelName);
                level = new OLAPAttributeLevel(allLevelName);
                level.hierarchy = this;
                level.dimension = dimension;
                level.attributeName = name;
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
    override mx_internal function createLevel(name:String):OLAPLevel
    {
        var l:OLAPAttributeLevel = new OLAPAttributeLevel(name);
        l.hierarchy = this;
        l.dimension = dimension;
        l.attributeName = name;        
        _levels.addItem(l);
        _levelMap[name] = l;
        
        return l;   
    }
    
    /**
     *  @private
     */
    private function internalDataFunction(rowData:Object, dataField:String):Object
    {
        return rowData[dataField];
    }
    
    /**
     *  @private
     */
    private function internalDataCompareFunction(data1:Object, data2:Object):int
    {
        var value1:Object = internalDataFunction(data1, dataField);
        var value2:Object = internalDataFunction(data2, dataField);
        
        if (value1 < value2)
            return -1;
        if (value1 > value2)
            return 1;
        return 0;
            
    }
}

}
