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

package flex2.compiler.mxml.rep;

import flex2.compiler.mxml.reflect.Event;
import flex2.compiler.mxml.reflect.Type;

/**
 * This class represents an event handler function.
 */
public class EventHandler implements LineNumberMapped {
    private Model model;
    private Event event;
    private String eventHandlerText;
    private String documentFunctionName;
    private String state;

    public EventHandler(Model model, Event event, String eventHandlerText) {
        this.model = model;
        this.event = event;
        this.eventHandlerText = eventHandlerText;
    }
    
    public EventHandler(Model model, Event event, String eventHandlerText, String state) {
        this.model = model;
        this.event = event;
        this.eventHandlerText = eventHandlerText;
        this.state = state;
    }

    public Model getModel() {
        return model;
    }

    public String getName() {
        return event.getName();
    }

    public Type getType() {
        return event.getType();
    }

    public String getEventHandlerText() {
        return eventHandlerText;
    }

    public String getDocumentFunctionName() {
        if (documentFunctionName == null)
        {
            StringBuilder buf = new StringBuilder();
            buf.append("__");
            buildNameChain(buf, model);
            buf.append("_");
            buf.append(event.getName());
            buf.append((state != null) ? "_" + state : "");
            documentFunctionName = buf.toString();
        }
        return documentFunctionName;
    }

    private boolean buildNameChain(StringBuilder buf, Model mod)
    {
        if (mod != null)
        {
            if (mod.getId() != null)
            {
                buf.append(mod.getId());
            }
            else
            {
                boolean needSep = buildNameChain(buf, mod.getParent());
                if (needSep)
                {
                    buf.append("_");
                }
                assert mod.getParentIndex() != null;
                buf.append(mod.getParentIndex());
            }
            return true;
        }
        return false;
    }

    // Implement LineNumberMapped interface
    /**
     * The line number where this model occurred in xml.  -1 if this model is synthetic
     * and has no creation site in MXML.
     */
    private int xmlLineNumber;

    public int getXmlLineNumber() {
        return xmlLineNumber;
    }

    public void setXmlLineNumber(int xmlLineNumber) {
        this.xmlLineNumber = xmlLineNumber;
    }

}
