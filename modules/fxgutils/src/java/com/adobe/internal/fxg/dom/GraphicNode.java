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

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static com.adobe.fxg.FXGConstants.*;

import com.adobe.fxg.FXGException;
import com.adobe.fxg.FXGVersion;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.types.MaskType;
import com.adobe.internal.fxg.dom.types.ScalingGrid;

/**
 * Represents the root &lt;Graphic&gt; element of an FXG Document.
 * 
 * @author Peter Farland
 * @author Sujata Das
 */
public class GraphicNode extends AbstractFXGNode implements MaskableNode
{
	public static final String APACHE_FLEX_CLASSNAME = "className";
	public static final String APACHE_FLEX_BASECLASSNAME = "baseClassName";
	
    private FXGVersion compilerVersion = null; // The version of FXG compiler.
    private String profile;
    private String documentName = null;
    private FXGVersion version = null; // The version of FXG being processed.
    
    /** The reserved nodes. */
    public Map<String, Class<? extends FXGNode>> reservedNodes;
    	
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------
	
    /** The distance from the origin of the left edge of the scale grid, 
     * in the group's own coordinate system. */
	public double scaleGridLeft = 0.0;
	
	/** The distance from the origin of the top edge of the scale grid, 
	 * in the group's own coordinate system. */
    public double scaleGridTop = 0.0;

    /** The distance from the origin of the right edge of the scale grid, 
     * in the group's own coordinate system. */
    public double scaleGridRight = 0.0;
    
    /** The distance from the origin of the bottom edge of the scale grid, 
     * in the group's own coordinate system. */
    public double scaleGridBottom = 0.0;

    /** The view width. */
    public double viewWidth = Double.NaN;
    
    /** The view height. */
    public double viewHeight = Double.NaN;

    /** an optional class name */
    public String className = null;
    
    /** an optional base class name */
    public String baseClassName = null;
    
    /** The mask type. */
    public MaskType maskType = MaskType.CLIP;

    protected boolean luminosityInvert=false;
    protected boolean luminosityClip=false;

    //Flag indicating whether the FXG version is newer than the compiler version.
    private boolean isVersionGreaterThanCompiler = false;

    //--------------------------------------------------------------------------
    //
    // Children
    //
    //--------------------------------------------------------------------------

    /** The children. */
    public List<GraphicContentNode> children;
    
    /** The library. */
    public LibraryNode library;
    
    /** The mask. */
    public MaskingNode mask;
    
    /**
     * Get the compiler version.
     * 
     * @return FXGVersion the compiler version.
     */
    public FXGVersion getCompilerVersion()
    {
        return compilerVersion;
    }

    /**
     * Set compiler version.
     * 
     * @param version - the compiler version.
     */
    public void setCompilerVersion(FXGVersion version)
    {
        compilerVersion = version;
    }
    
    /** 
     * @return true if the processing is for Mobile, else return false.
     */
    public boolean isForMobile()
    {
        return profile.equals(FXG_PROFILE_MOBILE);
    }

    /**
     * @return - true if version of the FXG file is greater than the compiler/FXGVersionHandler
     * version. false otherwise.
     */
    public boolean isVersionGreaterThanCompiler()
    {
        return isVersionGreaterThanCompiler;
    }
    
    /**
     * sets isVersionGreaterThanCompiler
     * @param versionGreaterThanCompiler
     */
    public void setVersionGreaterThanCompiler(boolean versionGreaterThanCompiler)
    {
        isVersionGreaterThanCompiler = versionGreaterThanCompiler;
    }
    
    /**
     * @return - the name of the FXG file being processed.
     */
    public String getDocumentName()
    {
        return documentName;
    }
    
    /**
     * Set the name of the FXG file being processed.
     * 
     * @param documentName the document name
     */
    public void setDocumentName(String documentName)
    {
        this.documentName = documentName;
    }

    /**
     * @return - version as FXGVersion.
     */
    public FXGVersion getVersion()
    {
        return version;
    }
    
    /**
     * Set the reserved nodes HashMap. Those XML element names are reserved and
     * cannot be used as the definition name for a library element.
     * 
     * @param reservedNodes the reserved nodes
     */
    public void setReservedNodes(Map<String, Class<? extends FXGNode>> reservedNodes)
    {
        this.reservedNodes = reservedNodes;
    }
    
    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Adds an FXG child node to this Graphic node. Supported child nodes
     * include graphic content nodes (e.g. Group, BitmapGraphic, Ellipse, Line,
     * Path, Rect, TextGraphic), control nodes (e.g. Library, Private), or
     * property nodes (e.g. mask).
     * 
     * @param child - a child FXG node to be added to this node.
     * @throws FXGException if the child is not supported by this node.
     */
    @Override
    public void addChild(FXGNode child)
    {
        if (child instanceof MaskPropertyNode)
        {
        	/**
        	 * According to FXG 2.0 spec., <mask> must be before any graphical element.
        	 */
        	if (children != null)
        	{
                throw new FXGException(child.getStartLine(), child.getStartColumn(), "InvalidMaskElement");
        	}	
        	if (mask == null)
        	{
        		mask = ((MaskPropertyNode)child).mask;
        	}
        	else
        	{
                throw new FXGException(child.getStartLine(), child.getStartColumn(), "MultipleMaskElements");
        	}           
        }
        else if (child instanceof LibraryNode)
        {   
        	/**
        	 * According to FXG 2.0 spec., <Library> must be before <mask> and any graphical element.
        	 */
        	if (mask != null || children != null)
        	{
                throw new FXGException(child.getStartLine(), child.getStartColumn(), "InvalidLibraryElement");
        	}	
            if (library == null)
            {
                library = (LibraryNode)child;
            }
            else
            {
                throw new FXGException(child.getStartLine(), child.getStartColumn(), "MultipleLibraryElements");
            }
        }
        else if (child instanceof GraphicContentNode)
        {
            if (children == null)
                children = new ArrayList<GraphicContentNode>();

            if (child instanceof GroupNode)
            {
                GroupNode group = (GroupNode)child;

                if (definesScaleGrid)
                {
                    group.setInsideScaleGrid(true);
                }
            }


            children.add((GraphicContentNode)child);
        }
        else
        {
            super.addChild(child);
        }
    }

    /**
     * @return The unqualified name of a Graphic node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_GRAPHIC_ELEMENT;
    }

    /**
     * Sets an FXG attribute on this Graphic node. Delegates to the parent 
     * class to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>scaleGridLeft</b> (Number): The distance from the origin of the 
     * left edge of the scale grid, in the group's own coordinate system.</li>
     * <li><b>scaleGridTop</b> (Number): The distance from the origin of the 
     * top edge of the scale grid, in the group's own coordinate system.</li>
     * <li><b>scaleGridRight</b> (Number): The distance from the origin of the 
     * right edge of the scale grid, in the group's own coordinate system.</li>
     * <li><b>scaleGridBottom</b> (Number): The distance from the origin of the 
     * bottom edge of the scale grid, in the group's own coordinate system.</li>
     * <li><b>viewWidth</b> (Number): The view width.</li>
     * <li><b>viewHeight</b> (Number): The view height.</li>
     * <li><b>version</b> (Number): The integer portion of the version 
     * represents the major version of the document, while the fractional 
     * portion corresponds to the minor version. </li>
     * <li><b>maskType</b> (Number): The mask type.</li>
     * <li><b>luminosityInvert</b> (Boolean): Determines whether the 
     * polarity of the luminosity mask is inverted or not. Defaults to 
     * false.</li>
     * <li><b>luminosityClip</b> (Boolean): Determines whether the values 
     * outside of the mask bounds are opaque or transparent. Defaults to 
     * false. </li>
     *  
     * @param name - the unqualified attribute name
     * @param value - the attribute value
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.AbstractFXGNode#setAttribute(java.lang.String, java.lang.String)
     */
    public void setAttribute(String name, String value)
    {
        if (FXG_SCALEGRIDLEFT_ATTRIBUTE.equals(name))
        {
            scaleGridLeft = DOMParserHelper.parseDouble(this, value, name);
            definesScaleGrid = true;
        }
        else if (FXG_SCALEGRIDTOP_ATTRIBUTE.equals(name))
        {
            scaleGridTop = DOMParserHelper.parseDouble(this, value, name);
            definesScaleGrid = true;
        }
        else if (FXG_SCALEGRIDRIGHT_ATTRIBUTE.equals(name))
        {
            scaleGridRight = DOMParserHelper.parseDouble(this, value, name);
            definesScaleGrid = true;
        }
        else if (FXG_SCALEGRIDBOTTOM_ATTRIBUTE.equals(name))
        {
            scaleGridBottom = DOMParserHelper.parseDouble(this, value, name);
            definesScaleGrid = true;
        }
        else if (FXG_VIEWWIDTH_ATTRIBUTE.equals(name))
        {
            viewWidth = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_VIEWHEIGHT_ATTRIBUTE.equals(name))
        {
            viewHeight = DOMParserHelper.parseDouble(this, value, name);
        }
        else if (FXG_VERSION_ATTRIBUTE.equals(name))
        {
            try
            {
                version = FXGVersion.newInstance(DOMParserHelper.parseDouble(this, value, name));
            }
            catch (FXGException e)
            {
                throw new FXGException("InvalidVersionNumber", e);
            }
        }
        else if (FXG_MASKTYPE_ATTRIBUTE.equals(name))
        {
            maskType = DOMParserHelper.parseMaskType(this, value, name, maskType);
        }
        else if ((version != null) && (version.equalTo(FXGVersion.v1_0)))
        {
            // Rest of the attributes are not supported by FXG 1.0
            // Exception:Attribute {0} not supported by node {1}. 
            throw new FXGException(getStartLine(), getStartColumn(), "InvalidNodeAttribute", name, getNodeName());
        }
        else if (FXG_LUMINOSITYINVERT_ATTRIBUTE.equals(name))
        {
            luminosityInvert = DOMParserHelper.parseBoolean(this, value, name);
        }        
        else if (FXG_LUMINOSITYCLIP_ATTRIBUTE.equals(name))
        {
            luminosityClip = DOMParserHelper.parseBoolean(this, value, name); 
        }        
        else if (APACHE_FLEX_CLASSNAME.equals(name))
        {
            className = value; 
        }        
        else if (APACHE_FLEX_BASECLASSNAME.equals(name))
        {
            baseClassName = value; 
        }        
        else
        {
            super.setAttribute(name, value);
        }
    }

    //--------------------------------------------------------------------------
    //
    // MaskableNode Implementation
    //
    //--------------------------------------------------------------------------
    
    /**
     * {@inheritDoc}
     */
    public MaskingNode getMask()
    {
        return mask;
    }

    /**
     * {@inheritDoc}
     */
    public MaskType getMaskType()
    {
        return maskType;
    }

    /**
     * {@inheritDoc}
     */
    public boolean getLuminosityClip()
    {
        return luminosityClip;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean getLuminosityInvert()
    {
        return luminosityInvert;
    }
    
    //--------------------------------------------------------------------------
    //
    // Other Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Gets the definition instance by name.
     * 
     * @param name the name
     * 
     * @return the definition instance
     */
    public PlaceObjectNode getDefinitionInstance(String name)
    {
        PlaceObjectNode instance = null;

        if (library != null)
        {
            DefinitionNode definition = library.getDefinition(name);
            if (definition != null)
            {
                instance = new PlaceObjectNode();
                instance.definition = definition;
            }
        }

        return instance;
    }

    /**
     * Gets the scaling grid.
     * 
     * @return the scaling grid
     */
    public ScalingGrid getScalingGrid()
    {
        ScalingGrid scalingGrid = null;

        if (definesScaleGrid())
        {
            scalingGrid = new ScalingGrid();
            scalingGrid.scaleGridLeft = scaleGridLeft;
            scalingGrid.scaleGridTop = scaleGridTop;
            scalingGrid.scaleGridRight = scaleGridRight;
            scalingGrid.scaleGridBottom = scaleGridBottom;
        }

        return scalingGrid;
    }

    /**
     * Check whether a scaling grid is defined.
     * 
     * @return true, if a scaling grid is defined.
     */
    public boolean definesScaleGrid()
    {
        return definesScaleGrid;
    }

    public void setProfile(String profile) {
		this.profile = profile;
	}

	public String getProfile() {
		return profile;
	}

	private boolean definesScaleGrid;
    
}
