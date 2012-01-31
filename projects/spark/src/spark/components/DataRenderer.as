////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components { 
    
import mx.core.IDataRenderer;
import mx.events.FlexEvent;

/**
 *  Dispatched when the <code>data</code> property changes.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 * 
 *  @eventType mx.events.FlexEvent.DATA_CHANGE
 * 
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]

/**
 *  The base class for data components in Spark. 
 *
 *  <p>Note: This class may be removed in a later release.</p>
 *
 *  @mxml <p>The <code>&lt;s:DataRenderer&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:DataRenderer
 *    <strong>Properties</strong>
 *    data=""
 *  
 *    <strong>Events</strong>
 *    dataChange="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class DataRenderer extends Group implements IDataRenderer
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function DataRenderer()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  data
    //----------------------------------

    /**
     *  @private
     *  Storage for the data property.
     */
    private var _data:Object;

    [Bindable("dataChange")]

    /**
     *  The implementation of the <code>data</code> property
     *  as defined by the IDataRenderer interface.
     *  
     *  <p>This property is Bindable; it dispatches 
     * "dataChange" events</p>
     *
     *  @default null
     *  @eventType dataChange 
     *  @see mx.core.IDataRenderer
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get data():Object
    {
        return _data;
    }

    /**
     *  @private
     */
    public function set data(value:Object):void
    {
        _data = value;

        dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
    }
}
}