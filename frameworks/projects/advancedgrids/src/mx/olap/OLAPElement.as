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
import flash.utils.Proxy;

/**
 *  The OLAPElement class defines a base interface that provides common properties for all OLAP elements.
 *
 *  @mxml
 *  <p>
 *  The <code>&lt;mx:OLAPElement&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, and adds the following tag attributes:
 *  </p>
 *  <pre>
 *  &lt;mx:OLAPElement
 *    <b>Properties</b>
 *    dimensions=""
 *    name=""
 *  /&gt;
 * 
 *  @see mx.olap.IOLAPElement
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPElement extends Proxy implements IOLAPElement
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
     *  @param displayName The name of the OLAP element, as a String, which can be used for display.
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function OLAPElement(name:String=null, displayName:String=null)
    {
        _name = name;
        _displayName = displayName;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------   
    
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
    public function get uniqueName():String
    {
        if (dimension)
            return String("[" + dimension.name + "].[" + name + "]");
        else
            return name;
    }
    
    //----------------------------------
    // displayName
    //----------------------------------
    
    /**
     *  @private
     */
    private var _displayName:String;
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get displayName():String
    {
        return _displayName ? _displayName : name;
    }

    /**
     *  @private
     */
    public function set displayName(value:String):void
    {
        _displayName = value;
    }
    
    //----------------------------------
    // name
    //----------------------------------
    
    /**
     *  @private
     */
    private var _name:String;
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get name():String
    {
        return _name;
    }

    /**
     *  @private
     */
    public function set name(value:String):void
    {
        OLAPTrace.traceMsg("Setting the name to: " + value, OLAPTrace.TRACE_LEVEL_3);
        _name = value;
    }
    
    //----------------------------------
    // dimension
    //----------------------------------
    
    private var _dimension:IOLAPDimension;
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get dimension():IOLAPDimension
    {
        return _dimension;
    }
    
    /**
     *  @private
     */
    public function set dimension(value:IOLAPDimension):void
    {
        _dimension = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Returns the unique name of the element.
     *
     *  @return The unique name of the element.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function toString():String
    {
        return uniqueName;  
    }

}

}