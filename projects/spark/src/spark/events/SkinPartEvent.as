////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

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
