/**************************************************************************
 * ADOBE CONFIDENTIAL
 *
 * ___________________
 *
 *  Copyright 2010 Adobe Systems Incorporated
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 **************************************************************************/

package mx.utils
{
import flash.net.registerClassAlias;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.managers.ISystemManager;
import mx.messaging.config.ConfigMap;
import mx.messaging.management.MBeanAttributeInfo;
import mx.messaging.management.MBeanConstructorInfo;
import mx.messaging.management.MBeanFeatureInfo;
import mx.messaging.management.MBeanInfo;
import mx.messaging.management.MBeanOperationInfo;
import mx.messaging.management.MBeanParameterInfo;
import mx.messaging.management.ObjectInstance;
import mx.messaging.management.ObjectName;
import mx.messaging.messages.AcknowledgeMessage;
import mx.messaging.messages.AcknowledgeMessageExt;
import mx.messaging.messages.AsyncMessage;
import mx.messaging.messages.AsyncMessageExt;
import mx.messaging.messages.CommandMessage;
import mx.messaging.messages.CommandMessageExt;
import mx.messaging.messages.ErrorMessage;
import mx.messaging.messages.HTTPRequestMessage;
import mx.messaging.messages.MessagePerformanceInfo;
import mx.messaging.messages.RemotingMessage;
import mx.messaging.messages.SOAPMessage;
import mx.utils.ObjectProxy;

/**
 *  The RpcClassAliasInitializer class registers all 
 * classes for AMF serialization needed by the Flex RPC library.
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class RpcClassAliasInitializer
{
    /**
     * In the event that an application does not use the Flex UI classes which processes
     * the <code>[RemoteClass(alias="")]</code> bootstrap code, this function registers all the
     * classes for AMF serialization needed by the Flex RPC library.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static function registerClassAliases():void
    {
        // Flex classes
        registerClassAlias("flex.messaging.io.ArrayCollection", ArrayCollection);
        registerClassAlias("flex.messaging.io.ArrayList", ArrayList);
        registerClassAlias("flex.messaging.io.ObjectProxy", ObjectProxy);
        
        // rpc classes
        registerClassAlias("flex.messaging.messages.AcknowledgeMessage", AcknowledgeMessage);
        registerClassAlias("DSK", AcknowledgeMessageExt);
        registerClassAlias("flex.messaging.messages.AsyncMessage", AsyncMessage);
        registerClassAlias("DSA", AsyncMessageExt);
        registerClassAlias("flex.messaging.messages.CommandMessage", CommandMessage);
        registerClassAlias("DSC", CommandMessageExt);
        registerClassAlias("flex.messaging.config.ConfigMap", ConfigMap);
        registerClassAlias("flex.messaging.messages.ErrorMessage", ErrorMessage);
        registerClassAlias("flex.messaging.messages.HTTPMessage", HTTPRequestMessage);
        registerClassAlias("flex.messaging.messages.MessagePerformanceInfo", MessagePerformanceInfo);
        registerClassAlias("flex.messaging.messages.RemotingMessage", RemotingMessage);
        registerClassAlias("flex.messaging.messages.SOAPMessage", SOAPMessage);

        // management classes - these are used in the flexadmin GUI program,
        // so will get registered in the usual way, don't do them here
        //registerClassAlias("flex.management.jmx.MBeanAttributeInfo", MBeanAttributeInfo);
        //registerClassAlias("flex.management.jmx.MBeanConstructorInfo", MBeanConstructorInfo);
        //registerClassAlias("flex.management.jmx.MBeanFeatureInfo", MBeanFeatureInfo);
        //registerClassAlias("flex.management.jmx.MBeanInfo", MBeanInfo);
        //registerClassAlias("flex.management.jmx.MBeanOperationInfo", MBeanOperationInfo);
        //registerClassAlias("flex.management.jmx.MBeanParameterInfo", MBeanParameterInfo);
        //registerClassAlias("flex.management.jmx.ObjectInstance", ObjectInstance);
        //registerClassAlias("flex.management.jmx.ObjectName", ObjectName);
    }
}
}