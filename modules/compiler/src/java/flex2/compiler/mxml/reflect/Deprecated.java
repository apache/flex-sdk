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

package flex2.compiler.mxml.reflect;

/**
 * Defines the reflection API of a class, function, property, or
 * variable, which has been deprecated.
 *
 * @author Clement Wong
 */
public interface Deprecated
{
    // [Deprecated(...)] statments
	String DEPRECATED   = "Deprecated";
	String REPLACEMENT  = "replacement";
	String MESSAGE		= "message";
	String SINCE		= "since";

    // the following are used in other statements, e.g. [Style(..., deprecatedMessage=...)]
    //TODO want a "deprecated"-only property for Styles 
    String DEPRECATED_REPLACEMENT = "deprecatedReplacement";
	String DEPRECATED_MESSAGE     = "deprecatedMessage";
    String DEPRECATED_SINCE       = "deprecatedSince";

	String getReplacement();

	String getMessage();
	
	String getSince();
}
