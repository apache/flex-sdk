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

package spark.events
{

import flash.events.Event;

/**
 *  Dispatched by <code>SkinnablePopUpContainer</code> to single closing.
 *  
 *  <p>The event provides a mechanism to pass commit information from the container to
 *  a listener.  One typical usage scenario is building a multiple-choice dialog with a 
 *  cancel button.  When a valid option is selected, the developer closes the dialog
 *  with a call to the <code>SkinnablePopUpContainer.close()</code> method, passing
 *  <code>true</code> to the <code>commit</code> parameter and optionally passing in
 *  any relevant data.  When the <code>SkinnablePopUpContainer</code> has completed closing,
 *  it will dispatch this event.  Then, in the listener, the developer can check
 *  the <code>commit</code> parameter and perform the appropriate action.</p>
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class PopUpCloseEvent extends Event
{   
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *
     *  @eventType popUpClose
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const CLOSE:String = "close";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *
     *  @param commit Indicates whether the listener should commit the data from the PopUp.
     *  @param data The PopUp data to commit.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function PopUpCloseEvent(commit:Boolean = false, data:* = undefined)
    {
        super(CLOSE);
        this.commit = commit;
        this.data = data;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  commit
    //----------------------------------
    
    /**
     *  Whether the listener should commit the PopUp data.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var commit:Boolean;

    //----------------------------------
    //  data
    //----------------------------------
    
    /**
     *  The PopUp data to commit.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var data:*;
    
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
        return new PopUpCloseEvent(commit, data);
    }
}

}
