////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.messaging
{

/**
 * This is the class used for elements of the ArrayCollection subscriptions property in the 
 * MultiTopicConsumer property.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion BlazeDS 4
 *  @productversion LCDS 3 
 */
public class SubscriptionInfo 
{
    /** 
     * The subtopic. If null, represents a subscription for messages directed to the
     * destination with no subtopic.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */
    public var subtopic:String;

    /**
     * The selector. If null, indicates all messages should be sent.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */
    public var selector:String;

    /**
     * The maximum number of messages per second the subscription wants to receive.
     * Zero means the subscription has no preference for the number of messages
     * it receives.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */ 
    public var maxFrequency:uint;

    /** Builds a new SubscriptionInfo with the specified subtopic and selector.
     *
     *  @param st The subtopic for the subscription. If null, represents a subscription
     *  for messages directed to the destination with no subtopic.
     *
     *  @param sel The selector. If null, inidcates all messages should be sent.
     * 
     *  @param mi The maximum number of messages per second the subscription wants
     *  to receive. Zero means no preference.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */
    public function SubscriptionInfo(st:String, sel:String, mf:uint = 0)
    {
        subtopic = st;
        selector = sel;
        maxFrequency = mf;
    }
}

}
