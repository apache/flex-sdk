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

package com.adobe.internal.fxg.dom;

import com.adobe.fxg.dom.FXGNode;

/**
 * A marker interface to denote that an FXG node represents a type of filter. 
 */
public interface FilterNode extends FXGNode
{
    /**
     * An id attribute provides a well defined name to a filter node.
     * @return the node id.
     */
    public String getId();

    /**
     * Sets the node id.
     * @param value - the node id as a String.
     */
    public void setId(String value);
}
