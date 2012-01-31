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

package mx.messaging.messages
{
    import mx.messaging.messages.MessagePerformanceInfo;
    
    /** 
     * The MessagePerformanceUtils class is used to retrieve various metrics about
     * the sizing and timing of a message sent from a client to the server and its 
     * response message, as well as pushed messages from the server to the client.  
     *
     * <p>Metrics are gathered when the following properties on the channel are set to <code>true</code>:
     * <code>&lt;record-message-times&gt;</code> enables capturing of timing information,
     * <code>&lt;record-message-sizes&gt;</code> enables capturing of sizing information.
     * Set these parameters to <code>true</code> or <code>false</code>, 
     * where the default value is <code>false</code>. 
     * You can set them to different values to capture only one type of metrics. 
     * For example, the following channel definition specifies to capture message timing information, 
     * but not message sizing information:</p>
     *
     * <pre>
     * &lt;channel-definition id="my-streaming-amf" 
     *     class="mx.messaging.channels.StreamingAMFChannel"&gt;
     *     &lt;endpoint 
     *         url="http://{server.name}:{server.port}/{context.root}/messagebroker/streamingamf"          
     *         class="flex.messaging.endpoints.StreamingAMFEndpoint"/&gt;
     *     &lt;properties&gt;
     *         &lt;record-message-times&gt;true&lt;/record-message-times&gt;
     *         &lt;record-message-sizes&gt;false&lt;/record-message-sizes&gt;
     *     &lt;/properties&gt;
     * &lt;/channel-definition&gt;</pre>     
     * 
     * <p>In your client application, you use the methods and properties of this class 
     * to retrieve performance metrics about received messages.</p>
     * 
     * <p>When these metrics are enabled an instance of this class should be created from 
     * a response, acknowledgement, or message handler in the form: </p>
     * 
     * <pre>var mpiutil:MessagePerformanceUtils = new MessagePerformanceUtils(event.message);
     * </pre>    
     * 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion BlazeDS 4
     *  @productversion LCDS 3 
     */ 
    public class MessagePerformanceUtils
    {   
        /**
         * @private 
         * 
         * Information about the original message sent out by the client
         */
        public var mpii:MessagePerformanceInfo;
        
        /**
         * @private 
         * 
         * Information about the response message sent back to the client
         */     
        public var mpio:MessagePerformanceInfo;
        
        /**
         * @private 
         * 
         * If this is a pushed message, information about the original message
         * that caused the push
         */             
        public var mpip:MessagePerformanceInfo;        
        
        /**
         * @private 
         * 
         * Header for MPI of original message sent by client
         */         
        public static const MPI_HEADER_IN:String = "DSMPII";
        
        /**
         * @private 
         * 
         * Header for MPI of response message sent to the client
         */         
        public static const MPI_HEADER_OUT:String = "DSMPIO";
        
        /**
         * @private 
         * 
         * Header for MPI of a message that caused a pushed message             
         */         
        public static const MPI_HEADER_PUSH:String = "DSMPIP";        

        
        //--------------------------------------------------------------------------
        //
        // Constructor
        // 
        //--------------------------------------------------------------------------    
        
        /**
         * Constructor. 
         * 
         * Creates an MessagePerformanceUtils instance with information from 
         * the message received by the client.
         * 
         * @param message The message received from the server. 
         * This can be a message pushed from the server, or an acknowledge message received
         * by the client after the client pushed a message to the server. 
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */                 
        public function MessagePerformanceUtils(message:Object):void
        {
            super();

            this.mpii=message.headers[MPI_HEADER_IN] as MessagePerformanceInfo;                                   
            this.mpio=message.headers[MPI_HEADER_OUT] as MessagePerformanceInfo;
                        
            // it is possible that if not all participants have mpi enabled we might be missing parts here
            if (mpio == null || (mpii == null && message.headers[MPI_HEADER_PUSH] == null))
            {
                throw new Error("Message is missing MPI headers.  Verify that all participants have it enabled.");
            }                
            
            if (pushedMessageFlag)
                this.mpip = message.headers[MPI_HEADER_PUSH] as MessagePerformanceInfo;            
        }
        
        //--------------------------------------------------------------------------
        //
        //  Public Methods
        //
        //--------------------------------------------------------------------------        
        
        /**
         * Time, in milliseconds, between this client sending a message and 
         * receiving a response from the server.
         *
         * <p>This property contains 0 for a streaming or RTMP (LiveCycle Data Services ES only) channel. </p> 
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */         
        public function get totalTime():Number
        {
            if (mpii == null)
                return 0;
            else
                return mpio.receiveTime - mpii.sendTime;
        }
        
        /**
         * Time, in milliseconds, between server receiving the client message and 
         * either the time the server responded to the received message or has 
         * the pushed message ready to be sent to a receiving client.
         * For example, for an acknowledge message, this is the time from when the server receives 
         * a message from the producer and sends the acknowledge message back to the producer. 
         * For a consumer that uses polling, it is the time between the arrival of 
         * the consumers polling message and any message returned in response to the poll. 
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */         
        public function get serverProcessingTime():Number
        {
            if (pushedMessageFlag)
            {
                return mpip.serverPrePushTime - mpip.receiveTime;
            }
            else
            {
                return mpio.sendTime - mpii.receiveTime;
            }                
        }       
        
        /**
         * Time, in milliseconds, between the server receiving the client message 
         * and the server beginning to push the message out to other clients.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */         
        public function get serverPrePushTime():Number
        {
            if (mpii == null)
                return 0;
            if (mpii.serverPrePushTime == 0)
                return serverProcessingTime;
            
            return mpii.serverPrePushTime - mpii.receiveTime;
        }    
        
        /**
         * Processing time, in milliseconds, of the message by the adapter 
         * associated with the destination before either the response to 
         * the message was ready or the message has been prepared to be pushed 
         * to the receiving client. 
         * This corresponds to the time that the message was processed by your code 
         * on the server.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */           
        public function get serverAdapterTime():Number
        {
            if (pushedMessageFlag)
            {
                if (mpip == null)
                    return 0;
                if (mpip.serverPreAdapterTime == 0 || mpip.serverPostAdapterTime == 0)
                    return 0;
            
                return mpip.serverPostAdapterTime - mpip.serverPreAdapterTime;              
            }
            else
            {
                if (mpii == null)
                    return 0;
                if (mpii.serverPreAdapterTime == 0 || mpii.serverPostAdapterTime == 0)
                    return 0;
            
                return mpii.serverPostAdapterTime - mpii.serverPreAdapterTime;
            }
        }   

        /**
         * Time, in milliseconds, spent in a module invoked from the adapter associated 
         * with the destination for this message, before either the response to the message 
         * was ready or the message had been prepared to be pushed to the receiving client. 
         * This corresponds to the time that the message was processed by the server,
         * excluding the time it was processed by your custom code, as defined by the value in
         * the <code>serverAdapterTime</code> property.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */         
        public function get serverAdapterExternalTime():Number
        {
            if (pushedMessageFlag)
            {
                if (mpip == null)
                    return 0;
                if (mpip.serverPreAdapterExternalTime == 0 || mpip.serverPostAdapterExternalTime == 0)
                    return 0;
            
                return mpip.serverPostAdapterExternalTime - mpip.serverPreAdapterExternalTime;              
            }
            else            
            {
                if (mpii == null)
                    return 0;
                if (mpii.serverPreAdapterExternalTime == 0 || mpii.serverPostAdapterExternalTime == 0)
                    return 0;
            
                return mpii.serverPostAdapterExternalTime - mpii.serverPreAdapterExternalTime;
            }
        }   

        /**
         * Time, in milliseconds, that this message sat on the server after it was ready 
         * to be pushed to this client but before it was picked up by a poll request.
         * 
         * <p>For a streaming or RTMP (LiveCycle Data Services ES only) channel, this value is always 0.</p>
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */     
        public function get serverPollDelay():Number
        {
            if (mpip == null)
                return 0;
            if (mpip.serverPrePushTime == 0 || mpio.sendTime == 0)
                return 0;
            
            return mpio.sendTime - mpip.serverPrePushTime;  
        }
        
        /**
         * Server processing time spent outside of the adapter associated with 
         * the destination of this message. 
         * Calculated as <code>serverProcessingTime</code> - <code>serverAdapterTime</code>.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */         
        public function get serverNonAdapterTime():Number
        {       
            return serverProcessingTime - serverAdapterTime;
        }       
        
        /**
         * The duration, in milliseconds, from when a client sent a message to the server 
         * until it received a response, excluding the server processing time. 
         * This value is calculated as totalTime - serverProcessingTime. 
         * 
         * <p>If a pushed message is using a streaming or RTMP (LiveCycle Data Services ES only) channel, 
         * the metric is meaningless because the client does not initiate the pushed message; 
         * the server sends a message to the client whenever a message is available. 
         * Therefore, for a message pushed over a streaming or RTMP channel, 
         * this value is 0. 
         * However, for an acknowledge message sent over a streaming or RTMP channel, 
         * the metric contains a valid number. </p>
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */             
        public function get networkRTT():Number
        {
            if (!pushedMessageFlag)
                return totalTime - serverProcessingTime;
            else
                return 0;
        }           
        
        /**
         * The number of milliseconds since the start of the Unix epoch, 
         * January 1, 1970, 00:00:00 GMT, to when the server sent a response message back to the client.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */             
        public function get serverSendTime():Number
        {
            return  mpio.sendTime;
        }       
        
        /**
         * The number of milliseconds since the start of the Unix epoch, 
         * January 1, 1970, 00:00:00 GMT, to when the client received response message from the server.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */         
        public function get clientReceiveTime():Number
        {
            return mpio.receiveTime;    
        }                       
        
        /**
         * The size of the original client message, in bytes, 
         * as measured during deserialization by the server endpoint.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */         
        public function get messageSize():int
        {
            if (mpii == null)
                return 0;
            else
                return mpii.messageSize;
        }           
        
        /**
         * The size, in bytes, of the response message sent to the client by the server 
         * as measured during serialization at the server endpoint.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */         
        public function get responseMessageSize():int
        {
            return mpio.messageSize;
        }       
        
        /**
         * Contains <code>true</code> if the message was pushed to the client 
         * but is not a response to a message that originated on the client. 
         * For example, when the client polls the server for a message, 
         * <code>pushedMessageFlag</code> is <code>false</code>. 
         * When you are using a streaming channel, <code>pushedMessageFlag</code> is true. 
         * For an acknowledge message, <code>pushedMessageFlag</code> is <code>false</code>.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */         
        public function get pushedMessageFlag():Boolean
        {
            return mpio.pushedFlag;
        }                           
        
        /**
         * Time, in milliseconds, from when the originating client sent a message 
         * and the time that the receiving client received the pushed message. 
         * Note that this value is only relevant if the two clients have synchronized clocks.
         * Only populated in the case of a pushed message, but not for an acknowledge message,
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */             
        public function get totalPushTime():Number
        {           
            return clientReceiveTime - originatingMessageSentTime  - pushedOverheadTime;
        }           
        
        /**
         * Time, in milliseconds, from when the server pushed the message 
         * until the client received it. 
         * Note that this value is only relevant if the server and receiving client 
         * have synchronized clocks.
         * Only populated in the case of a pushed message, but not for an acknowledge message.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */ 
        public function get pushOneWayTime():Number
        {
            return  clientReceiveTime - serverSendTime;
        }                   
        
        /**
         * The timestamp, in milliseconds since the start of the Unix epoch on 
         * January 1, 1970, 00:00:00 GMT, to when the client that caused a push message sent its message.
         * Only populated in the case of a pushed message, but not for an acknowledge message.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */             
        public function get originatingMessageSentTime():Number
        {
            return mpip.sendTime;   
        }                   
        
        /**
         * Size, in bytes, of the message that originally caused this pushed message.
         * Only populated in the case of a pushed message, but not for an acknowledge message.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */         
        public function get originatingMessageSize():Number
        {
            return mpip.messageSize;    
        }                               
        
        /**
         * The prettyPrint() method returns a formatted String containing all 
         * non-zero and non-null properties of the class.
         *
         * <p>For example, you can use the Alert control to display the available metrics, 
         * as the following example shows:</p>
         * 
         * <pre>
         *      var mpiutil:MessagePerformanceUtils = new MessagePerformanceUtils(message);                     
         *      Alert.show(mpiutil.prettyPrint(), "MPI Output", Alert.NONMODAL);
         * </pre>            
         * 
         * @return String containing a summary of all available non-zero and non-null metrics.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion BlazeDS 4
         *  @productversion LCDS 3 
         */         
        public function prettyPrint():String
        {       
            var alertString:String = new String("");
            if (messageSize != 0)
                alertString +="Original message size(B): " + messageSize + "\n";
            if (responseMessageSize != 0)              
                alertString +="Response message size(B): " + responseMessageSize + "\n";
            if (totalTime != 0)
                alertString +="Total time (s): " + (totalTime / 1000) + "\n";
            if (networkRTT != 0)
                alertString +="Network Roundtrip time (s): " + (networkRTT / 1000) + "\n";
            if (serverProcessingTime != 0)
                alertString +="Server processing time (s): " + (serverProcessingTime / 1000) + "\n";
            if (serverAdapterTime != 0)
                alertString +="Server adapter time (s): " + (serverAdapterTime / 1000) + "\n";      
            if (serverNonAdapterTime != 0)
                alertString +="Server non-adapter time (s): " + (serverNonAdapterTime / 1000) + "\n"                  
            if (serverAdapterExternalTime != 0)
                alertString +="Server adapter external time (s): " + (serverAdapterExternalTime / 1000) + "\n";     
            
            if (pushedMessageFlag)
            {
                alertString += "PUSHED MESSAGE INFORMATION:\n";
                if (totalPushTime != 0)
                    alertString += "Total push time (s): " + (totalPushTime / 1000) + "\n";
                if (pushOneWayTime != 0)
                    alertString += "Push one way time (s): " + (pushOneWayTime / 1000) + "\n";
                if (originatingMessageSize != 0)
                    alertString += "Originating Message size (B): " + originatingMessageSize + "\n";
                if (serverPollDelay != 0)
                    alertString +="Server poll delay (s): " + (serverPollDelay / 1000) + "\n";                        
            }
            
            return alertString;
        }           
        
        //--------------------------------------------------------------------------
        //
        //  Private Methods
        //
        //--------------------------------------------------------------------------     
                
        /**
         * @private
         * 
         * Overhead time in milliseconds for processing of the push causer message
         */                 
        private function get pushedOverheadTime():Number
        {
            return mpip.overheadTime;   
        }                           
        
    }
}