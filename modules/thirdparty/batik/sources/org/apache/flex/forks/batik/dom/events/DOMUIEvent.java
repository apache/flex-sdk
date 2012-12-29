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
package org.apache.flex.forks.batik.dom.events;

import java.util.ArrayList;
import java.util.List;

import org.apache.flex.forks.batik.xml.XMLUtilities;

import org.w3c.dom.events.UIEvent;
import org.w3c.dom.views.AbstractView;

/**
 * The UIEvent class provides specific contextual information
 * associated with User Interface events.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DOMUIEvent.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public class DOMUIEvent extends AbstractEvent implements UIEvent {

    private AbstractView view;
    private int detail;

    /**
     * DOM: The <code>view</code> attribute identifies the
     * <code>AbstractView</code> from which the event was generated.
     */
    public AbstractView getView() {
        return view;
    }

    /**
     * DOM: Specifies some detail information about the
     * <code>Event</code>, depending on the type of event.
     */
    public int getDetail() {
        return detail;
    }

    /**
     * DOM: The <code>initUIEvent</code> method is used to initialize
     * the value of a <code>UIEvent</code> created through the
     * <code>DocumentEvent</code> interface.  This method may only be
     * called before the <code>UIEvent</code> has been dispatched via
     * the <code>dispatchEvent</code> method, though it may be called
     * multiple times during that phase if necessary.  If called
     * multiple times, the final invocation takes precedence.
     *
     * @param typeArg Specifies the event type.
     * @param canBubbleArg Specifies whether or not the event can bubble.
     * @param cancelableArg Specifies whether or not the event's default
     *   action can be prevented.
     * @param viewArg Specifies the <code>Event</code>'s
     *   <code>AbstractView</code>.
     * @param detailArg Specifies the <code>Event</code>'s detail.
     */
    public void initUIEvent(String typeArg,
                            boolean canBubbleArg,
                            boolean cancelableArg,
                            AbstractView viewArg,
                            int detailArg) {
        initEvent(typeArg, canBubbleArg, cancelableArg);
        this.view = viewArg;
        this.detail = detailArg;
    }

    /**
     * <b>DOM</b>: Initializes this event object.
     */
    public void initUIEventNS(String namespaceURIArg,
                              String typeArg,
                              boolean canBubbleArg,
                              boolean cancelableArg,
                              AbstractView viewArg,
                              int detailArg) {
        initEventNS(namespaceURIArg, typeArg, canBubbleArg, cancelableArg);
        this.view = viewArg;
        this.detail = detailArg;
    }

    /**
     * Splits a whitespace separated string into tokens.
     */
    protected String[] split(String s) {
        List a = new ArrayList(8);
        StringBuffer sb;
        int i = 0;
        int len = s.length();
        while (i < len) {
            char c = s.charAt(i++);
            if (XMLUtilities.isXMLSpace(c)) {
                continue;
            }
            sb = new StringBuffer();
            sb.append(c);
            while (i < len) {
                c = s.charAt(i++);
                if (XMLUtilities.isXMLSpace(c)) {
                    a.add(sb.toString());
                    break;
                }
                sb.append(c);
            }
            if (i == len) {
                a.add(sb.toString());
            }
        }
        return (String[]) a.toArray(new String[a.size()]);
    }
}
