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

package flex2.compiler.asdoc;

import java.util.List;
import java.util.Map;
import java.util.Iterator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import flex2.compiler.mxml.lang.StandardDefs;

/**
 * This class is used to generate the toplevel.xml file.
 *
 */
public class TopLevelGenerator implements DocCommentGenerator
{
    StringBuilder xml;
    
    /**
     * Constructor
     */
    public TopLevelGenerator()
    {
        xml = new StringBuilder();
    }
    
    /**
     * Future implementation of this will just save it to a file in generate.
     */
    public String toString()
    {
        return xml.toString();
    }
    
    /**
     * Iterates through all classes and creates toplevel.xml
     */
    public void generate(DocCommentTable table)
    {
        xml.append("<asdoc>\n");
        Iterator packageIterator = table.getPackages().keySet().iterator();
        while (packageIterator.hasNext())
        {
            String currentPackage = (String)packageIterator.next();
            Iterator classIterator = table.getClassesAndInterfaces(currentPackage).keySet().iterator();
            while (classIterator.hasNext())
            {
                String currentClass = (String)classIterator.next();
                Iterator commentsIterator = table.getAllClassComments(currentClass, currentPackage).iterator();
                while (commentsIterator.hasNext())
                {
                    emitDocComment((DocComment)commentsIterator.next());
                }
            }
        }
        xml.append("\n</asdoc>\n");
    }
    
    /**
     * helper method for printing a tag in toplevel.xml
     * @param tagName
     * @param value
     */
    private void appendTag(String tagName, String value)
    {
        xml.append("\n<");
        xml.append(tagName);
        xml.append("><![CDATA[");
        xml.append(value);
        xml.append("]]></");
        xml.append(tagName);
        xml.append(">");
    }
    
    /**
     * append all tags in xml format (except inheritDoc)
     * @param tags
     */
    private void emitTags(Map tags)
    {
        Iterator tagIterator = tags.keySet().iterator();
        while (tagIterator.hasNext())
        {
            String tagName = ((String)tagIterator.next()).intern();
            Object o = tags.get(tagName);
            if (o == null)
                continue;
            if (o instanceof Boolean)
            {
                boolean b = ((Boolean)o).booleanValue();
                if (b)
                {
                    appendTag(tagName, "");
                }
                else 
                    continue;
            }
            else if (o instanceof List)
            {
                List l = (List)o;
                for (int i = 0; i < l.size(); i++)
                {
                    String value = (String)l.get(i);
                    appendTag(tagName, value);
                }
            }
            else if (o instanceof Map)   //custom Tags (implied tagName.equals("custom")
            {
                Map m = (Map)o;
                Iterator customTagIter = m.keySet().iterator();
                while (customTagIter.hasNext())
                {
                    tagName = (String)customTagIter.next();
                    String value = (String)m.get(tagName);
                    appendTag(tagName, value);
                }
            }
            else
            {
                String value = (String)o;
                appendTag(tagName, value);
            }
        }
    }

    /**
     * appends metadata associated with a definition.
     * @param metadata
     */
    private void emitMetadata(List metadata)
    {
        for (int i = 0; i < metadata.size(); i++)
        {
            DocComment meta = (DocComment)metadata.get(i);
            String metadataType = meta.getMetadataType().intern();
            xml.append("\n<metadata>\n");
            xml.append("\t<");
            xml.append(metadataType);
            xml.append(" owner='");
            xml.append(meta.getOwner());
            xml.append("' ");
            String name = meta.getName();
            if (!name.equals("IGNORE"))
                xml.append("name='").append(name).append("' ");
            String type_meta = meta.getType_meta();
            if (type_meta != null)
            {
                xml.append("type='").append(type_meta).append("' ");
            }
            
            String event_meta = meta.getEvent_meta();
            if (event_meta != null)
            {
                xml.append("event='").append(event_meta).append("' ");
            }
            String kind_meta = meta.getKind_meta();
            if (kind_meta != null)
            {
                xml.append("kind='").append(kind_meta).append("' ");
            }
            String arrayType_meta = meta.getArrayType_meta();
            if (arrayType_meta != null)
            {
                xml.append("arrayType='").append(arrayType_meta).append("' ");
            }
            String format_meta = meta.getFormat_meta();
            if (format_meta != null)
            {
                xml.append("format='").append(format_meta).append("' ");
            }
            String enumeration_meta = meta.getEnumeration_meta();
            if (enumeration_meta != null)
            {
                xml.append("enumeration='").append(enumeration_meta).append("' ");
            }
            String inherit_meta = meta.getInherit_meta();
            if (inherit_meta != null)
            {
                xml.append("inherit='").append(inherit_meta).append("' ");
            }
            
            if (metadataType == StandardDefs.MD_EVENT || metadataType == StandardDefs.MD_STYLE || metadataType == StandardDefs.MD_EFFECT)
            {
                // if message meta data is present then emit it. Applicable for Deprecation 
                String message_meta = meta.getMessage_meta();
                if (message_meta != null)
                {
                    xml.append("deprecatedMessage='").append(message_meta).append("' ");
                }                
                
                // if replacement meta data is present then emit it. Applicable for Deprecation 
                String replacement_meta = meta.getReplacement_meta();
                if (replacement_meta != null)
                {
                    xml.append("deprecatedReplacement='").append(replacement_meta).append("' ");
                }                
                
                // if since meta data is present then emit it. Applicable for Deprecation 
                String since_meta = meta.getSince_meta();
                if (since_meta != null)
                {
                    xml.append("deprecatedSince='").append(since_meta).append("' ");
                }                                       
                
                if(metadataType == StandardDefs.MD_STYLE)
                {
                	// if theme meta data is present then emit it.
                    String theme_meta = meta.getTheme_meta();
                    if (theme_meta != null)
                    {
                        xml.append("theme='").append(theme_meta).append("' ");
                    }                	
                }
            }
            else if(metadataType == StandardDefs.MD_SKINPART)
            {
                String variableType_meta = meta.getVariableType_meta();
                if (variableType_meta != null)
                {
                    xml.append("var_type='").append(variableType_meta).append("' ");
                }                
                
                String required_meta = meta.getRequired_meta();
                if (required_meta != null)
                {
                    xml.append("required='").append(required_meta).append("' ");
                }
                else 
                {
                    // false is now the default value for required in case of SkinPart.
                    xml.append("required='false' ");
                }
            }
            else 
            {
                // if message meta data is present then emit it. Applicable for Deprecation 
                String message_meta = meta.getMessage_meta();
                if (message_meta != null)
                {
                    xml.append("message='").append(message_meta).append("' ");
                }                
                
                // if replacement meta data is present then emit it. Applicable for Deprecation 
                String replacement_meta = meta.getReplacement_meta();
                if (replacement_meta != null)
                {
                    xml.append("replacement='").append(replacement_meta).append("' ");
                }                
                
                // if since meta data is present then emit it. Applicable for Deprecation 
                String since_meta = meta.getSince_meta();
                if (since_meta != null)
                {
                    xml.append("since='").append(since_meta).append("' ");
                }                                
            }
            
            xml.append(">");
            
            //These types of metadata can have comments associated with them
            if (metadataType == StandardDefs.MD_EVENT || metadataType == StandardDefs.MD_STYLE || metadataType == StandardDefs.MD_EFFECT 
                    || metadataType == StandardDefs.MD_SKINSTATE || metadataType == StandardDefs.MD_SKINPART || metadataType == StandardDefs.MD_ALTERNATIVE
                    || metadataType == StandardDefs.MD_DISCOURAGEDFORPROFILE)
            {
                String desc = meta.getDescription();
                if (desc != null)
                    appendTag("description", meta.getDescription());
                emitTags(meta.getAllTags());
            }
            xml.append("\n\t</");
            xml.append(metadataType);
            xml.append(">\n</metadata>");
        }
        
    }
    
    /**
     * Appends a package.
     * @param comment
     */
    private void emitPackage(DocComment comment)
    {
        xml.append("\n<packageRec name='");
        xml.append(comment.getFullname());
        xml.append("' fullname='");
        xml.append(comment.getFullname());
        xml.append("'>");
        
        String desc = comment.getDescription();
        if (desc != null)
            appendTag("description", comment.getDescription());
        emitTags(comment.getAllTags());
        
        xml.append("\n</packageRec>");
    }
    
    /**
     * Appends a class or interface
     * @param comment
     */
    private void emitClass(DocComment comment)
    {
        String tagName = (comment.getType() == DocComment.CLASS) ? "classRec" : "interfaceRec"; 
        xml.append("\n<");
        xml.append(tagName);
        xml.append(" name='");
        xml.append(comment.getName());
        xml.append("' fullname='");
        xml.append(comment.getFullname());
        String sourcefile = comment.getSourceFile();
        if (sourcefile != null)
        {
            xml.append("' sourcefile='");
            xml.append(sourcefile);
        }
        xml.append("' namespace='");
        xml.append(comment.getNamespace());
        xml.append("' access='");
        xml.append(comment.getAccess());
        xml.append("' ");
        if (comment.getType() == DocComment.INTERFACE)
        {
            String[] baseClasses = comment.getBaseclasses();
            if (baseClasses != null)
            {
                xml.append("baseClasses='");
                for (int i = 0; i < baseClasses.length; i++)
                {
                    String baseclass = baseClasses[i];
                    if (baseclass != null)
                    {
                        if (i != 0)
                            xml.append(";");
                        xml.append(baseclass);
                    }
                }
                xml.append("' ");
            }
        }
        else
        {
            xml.append("baseclass='");
            xml.append(comment.getBaseClass());
            xml.append("' ");
            String[] interfaces = comment.getInterfaces();
            if (interfaces != null)
            {
                xml.append("interfaces='");
                for (int i = 0; i < interfaces.length; i++)
                {
                    String inter = interfaces[i];
                    if (inter != null)
                    {
                        if (i != 0)
                            xml.append(";");
                        xml.append(inter);
                    }
                }
                xml.append("' ");
            }
        }
        xml.append("isFinal='");
        xml.append(comment.isFinal());
        xml.append("' ");
        xml.append("isDynamic='");
        xml.append(comment.isDynamic());
        xml.append("' ");
        xml.append(">");
        
        String desc = comment.getDescription();
        if (desc != null)
            appendTag("description", comment.getDescription());
        emitTags(comment.getAllTags());
        
        if (comment.getMetadata() != null)
            emitMetadata(comment.getMetadata());
        xml.append("\n</");
        xml.append(tagName);
        xml.append(">");
    }
    
    /**
     * Appends a function
     * @param comment
     */
    private void emitFunction(DocComment comment)
    {
        xml.append("\n<method name='");
        xml.append(comment.getName());
        xml.append("' fullname='");
        xml.append(comment.getFullname());
        xml.append("' ");
        xml.append("isStatic='");
        xml.append(comment.isStatic());
        xml.append("' ");
        xml.append("isFinal='");
        xml.append(comment.isFinal());
        xml.append("' ");
        xml.append("isOverride='");
        xml.append(comment.isOverride());
        xml.append("' ");
        
        String[] param_names = comment.getParamNames();
        if (param_names != null)
        {
            xml.append(" param_names='");
            for (int i = 0; i < param_names.length; i++)
            {
                String pname = param_names[i];
                if (pname != null)
                {
                    if (i != 0)
                        xml.append(";");
                    xml.append(pname);
                }
            }
            xml.append("'");
            
            String[] param_types = comment.getParamTypes();
            xml.append(" param_types='");
            for (int i = 0; i < param_types.length; i++)
            {
                String ptype = param_types[i];
                if (ptype != null)
                {
                    if (i != 0)
                        xml.append(";");
                    xml.append(ptype);
                }
            }
            xml.append("'");
            
            String[] param_defaults = comment.getParamDefaults();
            xml.append(" param_defaults='");
            for (int i = 0; i < param_defaults.length; i++)
            {
                String pdefa = param_defaults[i];
                if (pdefa != null)
                {
                    if (i != 0)
                        xml.append(";");
                    xml.append(pdefa);
                }
            }
            xml.append("'");
        }
        
        xml.append(" result_type='");
        xml.append(comment.getResultType());
        xml.append("'>");
        
        String desc = comment.getDescription();
        if (desc != null)
            appendTag("description", comment.getDescription());
        emitTags(comment.getAllTags());
        
        if (comment.getMetadata() != null)
            emitMetadata(comment.getMetadata());
        xml.append("\n</method>");
    }
    
    /**
     * Appends a field.
     * @param comment
     */
    private void emitField(DocComment comment)
    {
        xml.append("\n<field name='");
        xml.append(comment.getName());
        xml.append("' fullname='");
        xml.append(comment.getFullname());
        xml.append("' type='");
        String type = comment.getVartype();
        if (type != null)
            xml.append(comment.getVartype());
        xml.append("' isStatic='");
        xml.append(comment.isStatic());
        xml.append("' isConst='");
        xml.append(comment.isConst());
        xml.append("' ");
        String defaultValue = comment.getDefaultValue();
        if (defaultValue != null)
        {
            xml.append("defaultValue='");
            
            try
            {
                Pattern pattern = Pattern.compile("\\p{Cntrl}");
                Matcher matcher = pattern.matcher(defaultValue);
                defaultValue = matcher.replaceAll("");
            }
            catch (Exception ex) {}
            
            xml.append(defaultValue);
            xml.append("' ");
        }
        xml.append(">");
        
        String desc = comment.getDescription();
        if (desc != null)
            appendTag("description", comment.getDescription());
        emitTags(comment.getAllTags());
        
        if (comment.getMetadata() != null)
            emitMetadata(comment.getMetadata());
        xml.append("\n</field>");
    }
    
    /**
     * Appends a specific comment to the StringBuilder.
     * @param comment
     */
    private void emitDocComment(DocComment comment)
    {
        if (!comment.isExcluded())
        {
            int type = comment.getType();
            if (type == DocComment.PACKAGE)
                emitPackage(comment);
            else if (type == DocComment.CLASS || type == DocComment.INTERFACE)
                emitClass(comment);
            else if (type >= DocComment.FUNCTION && type <= DocComment.FUNCTION_SET)
                emitFunction(comment);
            else if (type == DocComment.FIELD)
                emitField(comment);
        }
    }

}
