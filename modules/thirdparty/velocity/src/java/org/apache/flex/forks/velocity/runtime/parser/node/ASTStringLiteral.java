package org.apache.flex.forks.velocity.runtime.parser.node;

/*
 * Copyright 2000-2001,2004 The Apache Software Foundation.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 *  Modified by Adobe Flex.
 */

import org.apache.flex.forks.velocity.context.InternalContextAdapter;
import org.apache.flex.forks.velocity.runtime.parser.ParseException;
import org.apache.flex.forks.velocity.runtime.parser.Parser;
import org.apache.flex.forks.velocity.runtime.parser.Token;

import java.io.StringWriter;
import java.io.BufferedReader;
import java.io.StringReader;

import org.apache.flex.forks.velocity.runtime.RuntimeConstants;

/**
 * ASTStringLiteral support.  Will interpolate!
 *
 * @author <a href="mailto:geirm@optonline.net">Geir Magnusson Jr.</a>
 * @author <a href="mailto:jvanzyl@apache.org">Jason van Zyl</a>
 * @version $Id: ASTStringLiteral.java,v 1.17.4.1 2004/03/03 23:22:59 geirm Exp $
 */
public class ASTStringLiteral extends SimpleNode
{
    /* cache the value of the interpolation switch */
    private boolean interpolate = true;
    private SimpleNode nodeTree = null;
    private String image = "";
    private transient String interpolateimage = "";

    public ASTStringLiteral(int id)
    {
        super(id);
    }

    public ASTStringLiteral(Parser p, int id)
    {
        super(p, id);
    }
    
    /**
     *  init : we don't have to do much.  Init the tree (there 
     *  shouldn't be one) and then see if interpolation is turned on.
     */
    public Object init(InternalContextAdapter context, Object data) 
        throws Exception
    {
        /*
         *  simple habit...  we prollie don't have an AST beneath us
         */

        super.init(context, data);
        
        if(nodeTree != null) {
        	nodeTree.init(context, rsvc);
        	return data;
        }     
        
        interpolate = interpolate &&  rsvc.getBoolean(RuntimeConstants.INTERPOLATE_STRINGLITERALS , true);

        /*
         *  init with context. It won't modify anything
         */
        if(interpolate)
        {
	        /*
	         *  now parse and init the nodeTree
	         */
	        BufferedReader br = new BufferedReader(new StringReader(image));
	
	        /*
	         * it's possible to not have an initialization context - or we don't
	         * want to trust the caller - so have a fallback value if so
	         *
	         *  Also, do *not* dump the VM namespace for this template
	         */
	
	        try {
	        	nodeTree  = rsvc.parse(br, "StringLiteral", false);
	        } catch(ParseException pe) {
	        	// should jjtOpen throw a ParseException?
	        	throw new RuntimeException(pe);
	        }
        }
        
        return data;
    }
    
    public void jjtOpen()
    {
    	super.jjtOpen();
    	Token t = first;

        /*
         *  the stringlit is set at template parse time, so we can 
         *  do this here for now.  if things change and we can somehow 
         * create stringlits at runtime, this must
         *  move to the runtime execution path
         *
         *  so, only if interpolation is turned on AND it starts 
         *  with a " AND it has a  directive or reference, then we 
         *  can  interpolate.  Otherwise, don't bother.
         */

    
    	 /*
         *  get the contents of the string, minus the '/" at each end
         */        
        image = t.image.substring(1, t.image.length() - 1);

        interpolate = t.image.startsWith("\"") && ((image.indexOf('$') != -1) || (image.indexOf('#') != -1));
    }
    
    /** Accept the visitor. **/
    public Object jjtAccept(ParserVisitor visitor, Object data)
    {
        return visitor.visit(this, data);
    }

    /**
     *  renders the value of the string literal
     *  If the properties allow, and the string literal contains a $ or a #
     *  the literal is rendered against the context
     *  Otherwise, the stringlit is returned.
     */
    public Object value(InternalContextAdapter context)
    {
        if (interpolate)
        {          
            try
            {
                /*
                 *  now render against the real context
                 */

                StringWriter writer = new StringWriter();
                nodeTree.render(context, writer);
                
                /*
                 * and return the result as a String
                 */

                String ret = writer.toString();

                /*
                 *  remove the space from the end (dreaded <MORE> kludge)
                 */

                return ret;
            }
            catch(Exception e)
            {
                /* 
                 *  eh.  If anything wrong, just punt 
                 *  and output the literal 
                 */
                rsvc.error("Error in interpolating string literal : " + e);
            }
        }
        
        /*
         *  ok, either not allowed to interpolate, there wasn't 
         *  a ref or directive, or we failed, so
         *  just output the literal
         */

        return image;
    }
}
