/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.css.engine.sac;

import org.w3c.css.sac.AttributeCondition;
import org.w3c.css.sac.CSSException;
import org.w3c.css.sac.CombinatorCondition;
import org.w3c.css.sac.Condition;
import org.w3c.css.sac.ConditionFactory;
import org.w3c.css.sac.ContentCondition;
import org.w3c.css.sac.LangCondition;
import org.w3c.css.sac.NegativeCondition;
import org.w3c.css.sac.PositionalCondition;


/**
 * This class provides an implementation of the
 * {@link org.w3c.css.sac.ConditionFactory} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSConditionFactory.java 475685 2006-11-16 11:16:05Z cam $
 */
public class CSSConditionFactory implements ConditionFactory {

    /**
     * The class attribute namespace URI.
     */
    protected String classNamespaceURI;

    /**
     * The class attribute local name.
     */
    protected String classLocalName;
    
    /**
     * The id attribute namespace URI.
     */
    protected String idNamespaceURI;

    /**
     * The id attribute local name.
     */
    protected String idLocalName;
    
    /**
     * Creates a new condition factory.
     */
    public CSSConditionFactory(String cns,  String cln,
                               String idns, String idln) {
        classNamespaceURI = cns;
        classLocalName = cln;
        idNamespaceURI = idns;
        idLocalName = idln;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * ConditionFactory#createAndCondition(Condition,Condition)}.
     */    
    public CombinatorCondition createAndCondition(Condition first,
                                                  Condition second)
        throws CSSException {
        return new CSSAndCondition(first, second);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * ConditionFactory#createOrCondition(Condition,Condition)}.
     */    
    public CombinatorCondition createOrCondition(Condition first,
                                                 Condition second)
        throws CSSException {
        throw new CSSException("Not implemented in CSS2");
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.ConditionFactory#createNegativeCondition(Condition)}.
     */    
    public NegativeCondition createNegativeCondition(Condition condition)
        throws CSSException {
        throw new CSSException("Not implemented in CSS2");
    }

    /**
     * <b>SAC</b>: Implements {@link
     * ConditionFactory#createPositionalCondition(int,boolean,boolean)}.
     */    
    public PositionalCondition createPositionalCondition(int position, 
                                                         boolean typeNode, 
                                                         boolean type)
        throws CSSException {
        throw new CSSException("Not implemented in CSS2");
    }
    
    /**
     * <b>SAC</b>: Implements {@link
     *ConditionFactory#createAttributeCondition(String,String,boolean,String)}.
     */    
    public AttributeCondition createAttributeCondition(String localName,
                                                       String namespaceURI,
                                                       boolean specified,
                                                       String value)
        throws CSSException {
        return new CSSAttributeCondition(localName, namespaceURI, specified,
                                           value);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.ConditionFactory#createIdCondition(String)}.
     */    
    public AttributeCondition createIdCondition(String value)
        throws CSSException {
        return new CSSIdCondition(idNamespaceURI, idLocalName, value);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.ConditionFactory#createLangCondition(String)}.
     */    
    public LangCondition createLangCondition(String lang) throws CSSException {
        return new CSSLangCondition(lang);
    }

    /**
     * <b>SAC</b>: Implements {@link
 ConditionFactory#createOneOfAttributeCondition(String,String,boolean,String)}.
     */    
    public AttributeCondition createOneOfAttributeCondition(String localName,
                                                            String nsURI,
                                                            boolean specified,
                                                            String value)
        throws CSSException {
        return new CSSOneOfAttributeCondition(localName, nsURI, specified,
                                                value);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * ConditionFactory#createBeginHyphenAttributeCondition(String,String,boolean,String)}.
     */    
    public AttributeCondition createBeginHyphenAttributeCondition
        (String localName,
         String namespaceURI,
         boolean specified,
         String value)
        throws CSSException {
        return new CSSBeginHyphenAttributeCondition
            (localName, namespaceURI, specified, value);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.ConditionFactory#createClassCondition(String,String)}.
     */    
    public AttributeCondition createClassCondition(String namespaceURI,
                                                   String value)
        throws CSSException {
        return new CSSClassCondition(classLocalName, classNamespaceURI, value);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * ConditionFactory#createPseudoClassCondition(String,String)}.
     */    
    public AttributeCondition createPseudoClassCondition(String namespaceURI,
                                                         String value)
        throws CSSException {
        return new CSSPseudoClassCondition(namespaceURI, value);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.ConditionFactory#createOnlyChildCondition()}.
     */    
    public Condition createOnlyChildCondition() throws CSSException {
        throw new CSSException("Not implemented in CSS2");
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.ConditionFactory#createOnlyTypeCondition()}.
     */    
    public Condition createOnlyTypeCondition() throws CSSException {
        throw new CSSException("Not implemented in CSS2");
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.ConditionFactory#createContentCondition(String)}.
     */    
    public ContentCondition createContentCondition(String data)
        throws CSSException {
        throw new CSSException("Not implemented in CSS2");
    }
}
