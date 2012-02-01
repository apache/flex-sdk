////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
///////////////////////////////////////////////////////////////////////////////

package spark.events 
{

import flash.events.Event;

[ExcludeClass]

/**
 *  @private
 *  This event class is an internal implementation detail subject to change.
 *  It is currently used by the accessibility implementation classes.
 */
public class SkinPartEvent extends Event 
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
	 *  This event is dispatched during partAdded().
	 */
    public static const PART_ADDED:String = "partAdded";
    
    /**
     *  @private
	 *  This event is dispatched during partRemoved().
	 */
    public static const PART_REMOVED:String = "partRemoved";
        
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function SkinPartEvent(type:String, bubbles:Boolean = false,
                                  cancelable:Boolean = false,
                                  partName:String = null, 
                                  instance:Object = null) 
    {
        super(type, bubbles, cancelable);

        this.partName = partName;
        this.instance = instance;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  instance
    //----------------------------------

    /**
     *  The skin part being added or removed.
     */    
    public var instance:Object;

    //----------------------------------
    //  partName
    //----------------------------------

    /**
     *  The name of the skin part being added or removed.
     */   
    public var partName:String;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: Event
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */     
    override public function clone():Event
    {
        return new SkinPartEvent(type, bubbles, cancelable, 
								 partName, instance);
    }
}

}
