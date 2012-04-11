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

package flex2.compiler.mxml.builder;

import flex2.compiler.CompilationUnit;
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.dom.InlineComponentNode;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.rep.Model;
import flex2.compiler.mxml.rep.MxmlDocument;
import flex2.compiler.util.MxmlCommentUtil;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.QName;

/**
 * This builder handles building a Model instance from an
 * InlineComponentNode.  The Model instance is used as an rvalue.
 *
 * @author Paul Reilly
 */
class InlineComponentBuilder extends AbstractBuilder
{
    InlineComponentBuilder(CompilationUnit unit, TypeTable typeTable,
            MxmlConfiguration mxmlConfiguration, MxmlDocument document,
            boolean topLevel)
    {
        super(unit, typeTable, mxmlConfiguration, document);
        this.topLevel = topLevel;
    }

    protected boolean topLevel;
    Model rvalue;

    public void analyze(InlineComponentNode node)
    {
        QName classQName = node.getClassQName();

        rvalue = factoryFromClass(NameFormatter.toDot(classQName), node.beginLine);

        String id = (String)getLanguageAttributeValue(node, StandardDefs.PROP_ID);
        if (id != null || topLevel)
        {
            // if node has a comment then transfer it to the model.
            if (node.comment != null)
            {
                // if generate ast is false, lets not scan the tokens here
                // because they will be scanned later in asc scanner.
                // we will go the velocity template route
                if (!mxmlConfiguration.getGenerateAbstractSyntaxTree())
                {
                    rvalue.comment = node.comment;
                }
                else
                {
                    rvalue.comment = MxmlCommentUtil.commentToXmlComment(node.comment);
                }
            }

            registerModel(id, rvalue, topLevel);
        }
    }

    public Model getRValue()
    {
        return rvalue;
    }
}
