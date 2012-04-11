/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flex2.tools.oem;

/**
 * The <code>Logger</code> interface is the Flex compiler logging mechanism for OEM applications.
 * You implement this interface and provide an instance of the implementation to the 
 * <code>Application.setLogger()</code> and/or <code>Library.setLogger()</code> methods.
 * 
 * <p>
 * The Flex compiler API exposes warnings and errors as <code>Message</code> objects.
 * You can use the <code>Message.getClass().getName()</code> method to differentiate
 * between message types programmatically.
 * 
 * <p>
 * The compiler utilizes some third-party libraries that use error-code-based
 * logging systems. As a result, the <code>log()</code> method also supports error codes.
 * 
 * @version 2.0.1
 * @author Clement Wong
 */
public interface Logger
{
    // C: Ideally, errorCode and source should be in Message...
    // void log(Message message);
    
    /**
     * Logs a compiler message.
     *  
     * @param message An object that implements the <code>flex2.tools.oem.Message</code> interface.
     * @param errorCode Error code. -1 if an error code is not available.
     * @param source Source code line number specified by the <code>message.getLine()</code> method.
     *               <code>null</code> if the compiler message is not associated with any source file.
     */
    void log(Message message, int errorCode, String source);
}
