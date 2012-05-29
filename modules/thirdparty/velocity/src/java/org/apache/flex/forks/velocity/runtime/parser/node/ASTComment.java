package org.apache.flex.forks.velocity.runtime.parser.node;

/*
 * Copyright 2000-2002,2004 The Apache Software Foundation.
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

import org.apache.flex.forks.velocity.runtime.parser.Parser;
import org.apache.flex.forks.velocity.runtime.parser.Token;
import org.apache.flex.forks.velocity.context.InternalContextAdapter;
import org.apache.flex.forks.velocity.exception.ResourceNotFoundException;
import org.apache.flex.forks.velocity.exception.ParseErrorException;
import org.apache.flex.forks.velocity.exception.MethodInvocationException;

import java.io.IOException;
import java.io.Writer;

/**
 *  Represents all comments...
 *
 *  @author <a href="mailto:geirm@apache.org">Geir Magnusson Jr.</a>
 *  @version $Id: ASTComment.java,v 1.5.4.1 2004/03/03 23:22:58 geirm Exp $
 */
public class ASTComment extends SimpleNode
{
    private String comment;

    public ASTComment(int id)
    {
        super(id);
    }

    public ASTComment(Parser p, int id) 
    {
        super(p, id);
    }

    /** Accept the visitor. **/
    public Object jjtAccept(ParserVisitor visitor, Object data) 
    {
        return visitor.visit(this, data);
    }

    public void jjtOpen()
    {
        comment = parser.getToken(1).image; // added
        int loc1 = comment.indexOf("##");
        int loc2 = comment.indexOf("#*");

        if (loc1 == -1 && loc2 == -1)
        {
        	comment = "";
        }
        else
        {
        	comment = comment.substring(0, (loc1 == -1) ? loc2 : loc1);
        }
    }
    
    public boolean render( InternalContextAdapter context, Writer writer)
        throws IOException, MethodInvocationException, ParseErrorException, ResourceNotFoundException
    {
        writer.write(comment);

        return true;
    }

}
