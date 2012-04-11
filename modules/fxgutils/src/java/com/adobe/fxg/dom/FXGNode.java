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

package com.adobe.fxg.dom;

/**
 * Implementations of FXGNode represent a node in the DOM of an FXG document.
 * 
 * @author Peter Farland
 */
public interface FXGNode
{
    /**
     * @return The XML element name of this node.
     */
    String getNodeName();

    /**
     * @return The namespace URI of this node.
     */
    String getNodeURI();

    /**
     * Adds an FXG child node to this node.
     * 
     * @param child - a child FXG node to be added to this node.
     */
    void addChild(FXGNode child);

    /**
     * @return The root node of the FXG document.
     */
    FXGNode getDocumentNode();

    /**
     * Establishes the root node of the FXG document containing this node.
     * @param root - the root node of the FXG document.
     */
    void setDocumentNode(FXGNode root);
    
    /**
     * Sets an FXG attribute on this node.
     * 
     * @param name - the unqualified attribute name
     * @param value - the attribute value
     */
    void setAttribute(String name, String value);


    //--------------------------------------------------------------------------
    //
    //  Document Line Information (Used in Error Reporting)
    //
    //--------------------------------------------------------------------------

    /**
     * @return the line on which the node declaration started.
     */
    int getStartLine();

    /**
     * @param line - the line on which the node declaration started.
     */
    void setStartLine(int line);

    /**
     * @return - the column on which the node declaration started.
     */
    int getStartColumn();

    /**
     * @param column - the line on which the node declaration started.
     */
    void setStartColumn(int column);

    /**
     * @return the line on which the node declaration ended.
     */
    int getEndLine();

    /**
     * @param line - the line on which the node declaration ended.
     */
    void setEndLine(int line);

    /**
     * @return - the column on which the node declaration ended.
     */
    int getEndColumn();

    /**
     * Sets the end column.
     * 
     * @param column the column
     */
    void setEndColumn(int column);
}
