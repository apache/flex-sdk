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

import com.adobe.fxg.FXGException;
import com.adobe.fxg.FXGVersion;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.fxg.util.FXGLog;
import com.adobe.fxg.util.FXGLogger;

/**
 * A helper class that serves as the base implementation of FXGNode. Subclasses
 * can delegate to this class to handle unknown attributes or children.
 * 
 * @author Peter Farland
 * @author Sujata Das
 */
public abstract class AbstractFXGNode implements FXGNode
{   
    protected FXGNode documentNode;
    protected String uri;
    protected int startLine;
    protected int startColumn;
    protected int endLine;
    protected int endColumn;

    /** The Constant ALPHA_MIN_INCLUSIVE. */
    public static final double ALPHA_MIN_INCLUSIVE = 0.0;
    
    /** The Constant ALPHA_MAX_INCLUSIVE. */
    public static final double ALPHA_MAX_INCLUSIVE = 1.0;
    
    /** The Constant COLOR_BLACK. */
    public static final int COLOR_BLACK = 0xFF000000;
    
    /** The Constant COLOR_WHITE. */
    public static final int COLOR_WHITE = 0xFFFFFFFF;
    
    /** The Constant COLOR_RED. */
    public static final int COLOR_RED = 0xFFFF0000;
    
    /** The Constant GRADIENT_ENTRIES_MAX_INCLUSIVE. */
    public static final int GRADIENT_ENTRIES_MAX_INCLUSIVE = 15;
    
    /** The Constant EPSILON. */
    public static final double EPSILON = 0.00001;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Adds an FXG child node to this node.
     * 
     * @param child - a child FXG node to be added to this node.
     * @throws FXGException if the child is not supported by this node.
     */
    public void addChild(FXGNode child)
    {
    	//Exception:Child node {0} is not supported by node {1}.
        if (child == null) 
        {
            throw new FXGException("InvalidChildNode",   null, getNodeName());
        }
        else
        {
            throw new FXGException(child.getStartLine(), child.getStartColumn(), "InvalidChildNode",  child.getNodeName(), getNodeName());            
        }
    }

    /**
     * Sets an FXG attribute on this FXG node. A message is logged if the 
     * attribute is not supported by this node and the file version is greater  
     * than the version supported by the compiler.
     * 
     * @param name - the unqualified attribute name
     * @param value - the attribute value
     * @throws FXGException if the attribute name is not supported by this node.
     */
    public void setAttribute(String name, String value)
    {
    	if (isVersionGreaterThanCompiler())
        {
            // Warning: Minor version of this FXG file is greater than minor
            // version supported by this compiler. Log a warning for an unknown
            // attribute or an attribute with values out of range.
    	    FXGLog.getLogger().log(FXGLogger.WARN, "UnknownNodeAttribute", null, getDocumentName(), startLine, startColumn, name, getNodeName());
        }
        else
        {
            // Exception:Attribute {0} not supported by node {1}.
            throw new FXGException(getStartLine(), getStartColumn(), "InvalidNodeAttribute", name, getNodeName());
        }
    }

    /**
     * @return The root node of the FXG document.
     */
    public FXGNode getDocumentNode()
    {
        return documentNode;
    }

    /**
     * Establishes the root node of the FXG document containing this node.
     * @param root - the root node of the FXG document.
     */
    public void setDocumentNode(FXGNode root)
    {
        documentNode = root;
    }

    /**
     * return the namespace URI of this node.
     * 
     * @return the node uri
     */
    public String getNodeURI()
    {
        return uri;
    }

    /**
     * @param uri - the namespace URI of this node.
     */
    public void setNodeURI(String uri)
    {
        this.uri = uri;
    }

    /**
     * @return the line on which the node declaration started.
     */
    public int getStartLine()
    {
        return startLine;
    }

    /**
     * @param line - the line on which the node declaration started.
     */
    public void setStartLine(int line)
    {
        startLine = line;
    }

    /**
     * @return - the column on which the node declaration started.
     */
    public int getStartColumn()
    {
        return startColumn;
    }

    /**
     * @param column - the line on which the node declaration started.
     */
    public void setStartColumn(int column)
    {
        startColumn = column;
    }

    /**
     * @return the line on which the node declaration ended.
     */
    public int getEndLine()
    {
        return endLine;
    }

    /**
     * @param line - the line on which the node declaration ended.
     */
    public void setEndLine(int line)
    {
        endLine = line;
    }

    /**
     * @return - the column on which the node declaration ended.
     */
    public int getEndColumn()
    {
        return endColumn;
    }

    /**
     * Sets the end column.
     * 
     * @param column the column
     */
    public void setEndColumn(int column)
    {
        endColumn = column;
    }
    
    //--------------------------------------------------------------------------
    //
    // Helper Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @return - true if version of the FXG file is greater than the compiler
     * version. false otherwise.
     */
    public boolean isVersionGreaterThanCompiler()
    {
        return ((GraphicNode)this.documentNode).isVersionGreaterThanCompiler();
    }

    /**
     * Gets the file version.
     * 
     * @return the file version
     */
    public FXGVersion getFileVersion()
    {
        return ((GraphicNode)this.documentNode).getVersion();
    }
    
    /**
     * Gets the compiler version.
     * 
     * @return the compiler version
     */
    public FXGVersion getCompilerVersion()
    {
        return ((GraphicNode)this.documentNode).getCompilerVersion();
    }
    
    /**
     * @return true if the processing is for Mobile, else return false.
     * 
     */
    public boolean isForMobile()
    {
        return ((GraphicNode)this.documentNode).isForMobile();
    }
    
    /**
     * @return - the name of the FXG file being processed.
     */
    public String getDocumentName()
    {
        return ((GraphicNode)this.getDocumentNode()).getDocumentName();
    }
}
