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
package com.adobe.fxg;

import java.io.IOException;
import java.io.InputStream;

import com.adobe.fxg.dom.FXGNode;

/**
 * A FXGParser parses an InputStream for an FXG document and builds a custom
 * DOM. Custom FXGNodes can be registered to represent specific elements and
 * elements can also be marked as skipped prior to parsing .
 * 
 * @author Sujata Das
 */
public interface FXGParser
{
    
    /**
     * Parses an FXG document InputStream to produce an FXGNode based DOM.
     * 
     * @param is the input stream
     * 
     * @return the root FXGNode of the DOM
     * 
     * @throws FXGException if an exception occurred while parsing.
     * @throws IOException if an exception occurred while reading the stream.
     */
    FXGNode parse(InputStream is) throws FXGException, IOException;

    /**
     * Parses an FXG document InputStream to produce an FXGNode based DOM.
     * 
     * @param documentName - the name of the FXG document which can be useful
     * for error reporting.
     * @param is the input stream
     * 
     * @return the root FXGNode of the DOM
     * 
     * @throws FXGException if an exception occurred while parsing.
     * @throws IOException if an exception occurred while reading the stream.
     */
    FXGNode parse(InputStream is, String documentName) throws FXGException, IOException;

    /**
     * Registers a custom FXGNode for a particular type of element encountered 
     * while parsing an FXG document.
     * 
     * This method must be called prior to parsing.
     * 
     * @param version - the FXG version of the FXG element 
     * @param uri - the namespace URI of the FXG element
     * @param localName - the local name of the FXG element
     * @param nodeClass - Class of an FXGNode implementation that will represent
     * an element in the DOM and process its attributes and child nodes during
     * parsing.
     */
    void registerElementNode(double version , String uri,  String localName, Class<? extends FXGNode> nodeClass);

    /**
     * Specifies that a particular element should be skipped while parsing an
     * FXG document. All of the element's attributes and child nodes will be
     * skipped.
     * 
     * Skipped elements must be registered prior to parsing.
     * 
     * @param version - the FXG version of the FXG element 
     * @param uri - the namespace URI of the FXG element to skip
     * @param localName - the name of the FXG element to skip
     */
    void skipElement(double version, String uri, String localName);
}
