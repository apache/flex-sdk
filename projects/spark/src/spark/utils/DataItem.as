////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.utils
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

import mx.binding.BindabilityInfo;
import mx.core.mx_internal;
import mx.utils.ObjectProxy;
import mx.utils.DescribeTypeCache;

use namespace mx_internal;
use namespace flash_proxy;

[RemoteClass(alias="spark.utils.DataItem")]

/**
 *  The DataItem class represents a dynamic object with bindable properties.   
 *  That means the Flex data binding mechanism recognizes when properties
 *  of a DataItem change at runtime. 
 *  For example, a Spark DataGrid item renderer relies on data binding 
 *  to a property of the items in the control's data provider.
 *  Because of data binding, when the property changes at runtime, 
 *  the item renderer updates automatically.
 * 
 *  <p>This class is intended to be used in MXML to define object literals 
 *  whose properties must be bindable.   
 *  It's typically used to define List or 
 *  DataGrid data provider items within an MXML file for small applications or examples
 *  with item renderers that bind to their data.  
 *  Non-trival applications, or any application for which performance is a concern, 
 *  should define a <code>[Bindable]</code> class with a fixed set of 
 *  strongly typed properties and use that class to define data provider items.</p>
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public dynamic class DataItem extends ObjectProxy
{
    /**
     *  Constructor
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function DataItem()
    {
        super();
    }
    
    /**
     *  @private
     */
    override flash_proxy function setProperty(name:*, value:*):void
    {
        // The first time a property is set, update the BindableInfo metadata
        // to indicate that it's bindable and that it dispatches a PropertyChangeEvent.
        
        const info:BindabilityInfo = DescribeTypeCache.describeType(this).bindabilityInfo;
        const events:Object = info.getChangeEvents(name);
        if (events["propertyChange"] === undefined)
            events["propertyChange"] = true;            
        
        super.setProperty(name, value);
    }
}
}