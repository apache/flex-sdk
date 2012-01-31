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
