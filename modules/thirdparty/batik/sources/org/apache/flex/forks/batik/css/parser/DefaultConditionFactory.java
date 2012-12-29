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
package org.apache.flex.forks.batik.css.parser;

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
 * @version $Id: DefaultConditionFactory.java 478283 2006-11-22 18:53:40Z dvholten $
 */

public class DefaultConditionFactory implements ConditionFactory {

    /**
     * The instance of this class.
     */
    public static final ConditionFactory INSTANCE =
        new DefaultConditionFactory();

    /**
     * This class does not need to be instantiated.
     */
    protected DefaultConditionFactory() {
    }

    /**
     * <b>SAC</b>: Implements {@link
     * ConditionFactory#createAndCondition(Condition,Condition)}.
     */
    public CombinatorCondition createAndCondition(Condition first,
                                                  Condition second)
        throws CSSException {
        return new DefaultAndCondition(first, second);
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
        return new DefaultAttributeCondition(localName, namespaceURI,
                                             specified, value);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.ConditionFactory#createIdCondition(String)}.
     */
    public AttributeCondition createIdCondition(String value)
        throws CSSException {
        return new DefaultIdCondition(value);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.ConditionFactory#createLangCondition(String)}.
     */
    public LangCondition createLangCondition(String lang) throws CSSException {
        return new DefaultLangCondition(lang);
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
        return new DefaultOneOfAttributeCondition(localName, nsURI, specified,
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
        return new DefaultBeginHyphenAttributeCondition
            (localName, namespaceURI, specified, value);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.ConditionFactory#createClassCondition(String,String)}.
     */
    public AttributeCondition createClassCondition(String namespaceURI,
                                                   String value)
        throws CSSException {
        return new DefaultClassCondition(namespaceURI, value);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * ConditionFactory#createPseudoClassCondition(String,String)}.
     */
    public AttributeCondition createPseudoClassCondition(String namespaceURI,
                                                         String value)
        throws CSSException {
        return new DefaultPseudoClassCondition(namespaceURI, value);
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
