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
import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.IViewCursor;
import mx.core.mx_internal;
import mx.resources.ResourceManager;

use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="dimension", kind="property")]

//--------------------------------------
//  metadata
//--------------------------------------

[DefaultProperty("elements")]

/**
 *  The OLAPDimension class represents a dimension of an OLAP cube.
 *
 *  @mxml
 *  <p>
 *  The <code>&lt;mx:OLAPDimension&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, and adds the following tag attributes:
 *  </p>
 *  <pre>
 *  &lt;mx:OLAPDimension
 *    <b>Properties</b>
 *    attributes=""
 *    elements=""
 *    hierarchies=""
  *  /&gt;
 *
 *  @see mx.olap.IOLAPDimension
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPDimension extends OLAPElement implements IOLAPDimension
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
     *  @param name The name of the OLAP dimension that includes the OLAP schema hierarchy of the element.
     *
     *  @param displayName The name of the OLAP dimension, as a String, which can be used for display. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function OLAPDimension(name:String=null, displayName:String=null)
    {
        OLAPTrace.traceMsg("Creating dimension: " + name, OLAPTrace.TRACE_LEVEL_3);
        super(name, displayName);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    //map of attributes using name as the key
    private var attributeMap:Dictionary = new Dictionary(true);

    //map of hierarchies using name as the key
    private var _hierarchiesMap:Dictionary = new Dictionary(true);

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // attributes
    //----------------------------------
    
    private var _attributes:IList = new ArrayCollection;
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get attributes():IList
    {
        return _attributes;
    }
    
    /**
     *  @private
     */
    public function set attributes(value:IList):void
    {
        _attributes = value;
        var n:int = value.length;
        for (var attrIndex:int = 0; attrIndex < n; ++attrIndex)
        {
            var attr:OLAPAttribute = value.getItemAt(attrIndex) as OLAPAttribute;
            attr.dimension = this;
            attributeMap[attr.name] = attr;
        }
    }
    
    //----------------------------------
    // cube
    //----------------------------------
    
    private var _cube:IOLAPCube;
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get cube():IOLAPCube
    {
        return _cube;
    }
    
    /**
     *  @private
     */
    public function set cube(value:IOLAPCube):void
    {
        _cube = value;
    }
    
    //----------------------------------
    // dataProvider
    //----------------------------------

    mx_internal function get dataProvider():ICollectionView
    {
        return OLAPCube(cube).dataProvider;
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
        // get the default hierarchy here
        if ((hierarchies.length + attributes.length) > 1)
        {
            var message:String = ResourceManager.getInstance().getString(
                        "olap", "multipleHierarchies");
            throw Error(message);
        }
        
        return hierarchies[0].defaultMember;
    }
    
    //----------------------------------
    // elements
    //----------------------------------
    
    /**
     *  Processes the input Array and initializes the <code>attributes</code>
     *  and <code>hierarchies</code> properties based on the elements of the Array.
     *  Attributes are represented in the Array by instances of the OLAPAttribute class, 
     *  and hierarchies are represented by instances of the OLAPHierarchy class.
     *
     *  <p>Use this property to define the attributes and hierarchies of a cube in a single Array.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function set elements(value:Array):void
    {
        var attrs:ArrayCollection = new ArrayCollection();
        var userHierarchies:ArrayCollection = new ArrayCollection();
        for each (var element:Object in value)
        {
            if (element is OLAPAttribute)
                attrs.addItem(element);
            else if (element is OLAPHierarchy)
                userHierarchies.addItem(element);
            else
                OLAPTrace.traceMsg("Invalid element specified for dimension elements");
        }
        
        attributes = attrs;
        hierarchies = userHierarchies;
    }
    
    //----------------------------------
    // hierarchies
    //----------------------------------
    
    private var _hierarchies:IList = new ArrayCollection;

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get hierarchies():IList
    {
        return _hierarchies;
    }
    
    /**
     *  @private
     */
    public function set hierarchies(value:IList):void
    {
        //limitation till we support multiple hierarchies.
        if (value.length > 1)
        {
            var message:String = ResourceManager.getInstance().getString(
                        "olap", "multipleHierarchiesNotSupported", [name]);
            throw Error(message);
        }
        
        _hierarchies = value;
        for (var i:int = 0; i < value.length; ++i)
        {
            var h:OLAPHierarchy = value.getItemAt(i) as OLAPHierarchy;
            h.dimension = this;
            _hierarchiesMap[h.name] = h;
        }
    }
    
    //----------------------------------
    // isMeasure
    //----------------------------------
    
    private var _isMeasureDimension:Boolean = false;
    
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
        return _isMeasureDimension;
    }
    
    /**
     *  @private
     */
    mx_internal function setAsMeasure(value:Boolean):void
    {
        _isMeasureDimension = value;
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
        var temp:Array = [];
        
        for (var i:int = 0; i < hierarchies.length; ++i)
            temp = temp.concat(hierarchies.getItemAt(i).members.toArray());
        
        return new ArrayCollection(temp);
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
     public function findHierarchy(name:String):IOLAPHierarchy
    {
        return _hierarchiesMap[name];
    }
    
    /**
    *  @inheritDoc
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public function findAttribute(name:String):IOLAPAttribute
    {
        return attributeMap[name];
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
        var member:IOLAPMember;
        var i:int = 0;
        var h:OLAPHierarchy;
        
        for (i = 0; i < attributes.length; ++i)
        {
            h = attributes.getItemAt(i) as OLAPHierarchy;
            member = h.findMember(name);
            if (member)
                break;
        }
        
        if (!member)
        {
            for (i = 0; i < hierarchies.length; ++i)
            {
                h = hierarchies.getItemAt(i) as OLAPHierarchy;
                member = h.findMember(name);
                if (member)
                    break;
            }
        }
        
        return member;          
    }
    
    /**
     *  @private
     *  Creates a hierarchy of the dimension.
     *
     *  @param name The name of the hierarchy.
     *
     *  @return An OLAPHierarchy instance that represents the new hierarchy.
     */
    mx_internal function createHierarchy(name:String):OLAPHierarchy
    {
        var h:OLAPHierarchy = new OLAPHierarchy(name);
        h.dimension = this;
        _hierarchies.addItem(h);
        _hierarchiesMap[h.name] = h;
        return h;
    }

    /**
     *  @private
     */
    mx_internal function refresh():void
    {
        //if dimension is of measure type we have nothing to do.
        if (isMeasure)
            return;
        var temp:Object;
        var dataHandlers:Array  =[];
        
        var i:int = 0;
        var n:int = attributes.length;
        for (i = 0; i < n; ++i)
        {
            temp = attributes.getItemAt(i);
            dataHandlers.push(temp);
        }
        
        n = hierarchies.length;
        for (i = 0; i < n; ++i)
        {
            temp = hierarchies.getItemAt(i);
            temp.refresh(); 
            dataHandlers.push(temp);
        }
        
        for (i = 0; i < n; ++i)
        {
            var h:OLAPHierarchy = hierarchies.getItemAt(i) as OLAPHierarchy;
            var levels:IList = h.levels;
            var m:int = levels.length;
            for (var j:int = 0; j < m; ++j)
            {
                var level:OLAPLevel = levels[j];
                //levels doesn't include allLevel
                //if (level == h.allLevel)
                //    continue;
                var a:OLAPAttribute = findAttribute(level.name) as OLAPAttribute;
                a.userHierarchy = level.hierarchy;
                a.userHierarchyLevel = level;
            }
        }
        
        // we need to refresh attributes here because we need the userHierarchy
        // userLevels to be set before refresh can happen.
        n = attributes.length;
        for (i = 0; i < n; ++i)
        {
            temp = attributes.getItemAt(i);
            temp.refresh(); 
        }
        
        var iterator:IViewCursor = dataProvider.createCursor();
        
        while (!iterator.afterLast)
        {
            var currentData:Object = iterator.current;
            for each (temp in dataHandlers)
                temp.processData(currentData);
            iterator.moveNext();
        }
    }

    /**
     *  @private
     */
    mx_internal function addAttribute(name:String, dataField:String):IOLAPAttribute
    {
        var attrHierarchy:OLAPAttribute = attributeMap[name];
        if (!attrHierarchy)
        {
            attrHierarchy = new OLAPAttribute(name);
            attrHierarchy.dataField = dataField;
            attrHierarchy.dimension = this;
            attributeMap[name] = attrHierarchy;
            _attributes.addItem(attrHierarchy);
        }
        return attrHierarchy;
    }

}

}
