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
 *  Dispatched by <code>SkinnablePopUpContainer</code> to single opening or closing.
 *  
 *  <p>When closing, this event provides a mechanism to pass commit information to
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
public class PopUpEvent extends Event
{   
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @eventType open
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const OPEN:String = "open";

    /**
     *  @eventType close
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
     *  @param type The event type; indicates the action that caused the event.
     *
     *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
     *
     *  @param cancelable Specifies whether the behavior associated with the event can be prevented.
     * 
     *  @param commit <p>Indicates whether the listener should commit the data from the PopUp.
     *  Only used with <code>PopUpEvent.CLOSE</code>.</p>
     * 
     *  @param data <p>The PopUp data to commit. Only used with <code>PopUpEvent.CLOSE</code>.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function PopUpEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, 
                               commit:Boolean = false, data:* = undefined)
    {
        super(type, bubbles, cancelable);
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
     *  Only used with <code>PopUpEvent.CLOSE</code>.
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
     *  Only used with <code>PopUpEvent.CLOSE</code>.
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
        return new PopUpEvent(type, bubbles, cancelable, commit, data);
    }
}

}
