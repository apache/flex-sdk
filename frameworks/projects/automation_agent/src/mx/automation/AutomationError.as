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

package mx.automation
{


/**
 * The AutomationError class defines the error constants used by the Flex Automation mechanism.
 * These error codes are used by QTP. 
 * They are used when QTP requests the type of the error that occurred during any operation.
 *
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AutomationError extends Error 
{

/**
 * Defines the code for the error when an object is not found by the Flex automation mechanism.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
    public static const OBJECT_NOT_FOUND:Number = 0x80040202;

/**
 * Defines the code for the error when the Flex automation mechanism detects that an object has the same identification parameters as another object.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
    public static const OBJECT_NOT_UNIQUE:Number = 0x80040203;

/**
 * Defines the code for the error when the Flex automation mechanism encounters an illegal operation.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
    public static const ILLEGAL_OPERATION:Number = 0x80040206;

/**
 * Defines the code for the error when the Flex automation mechanism encounters an illegal runtime ID.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
    public static const ILLEGAL_RUNTIME_ID:Number = 0x8004020D;

/**
 * Defines the code for the error when an object used by the Flex automation mechanism is not visible.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
    public static const OBJECT_NOT_VISIBLE:Number = 0x80040205; 

    private var _code:Number = 0;
    
    /**
     * Constructor.
     *
     *  @param msg An error message.
     *
     *  @param code The error code associated with the error message.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function AutomationError(msg:String, code:Number)
    {
        super(msg);
        this._code = code;
    }
    
    
    /**
     * The current error code.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get code():Number
    {
        return _code;
    }
}
}
