/*

   Copyright 2001-2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.test.xml;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.util.Vector;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * This helper class can be used to build Java object from their
 * XML description.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: XMLReflect.java,v 1.12 2004/08/18 07:17:06 vhardy Exp $
 */
public class XMLReflect implements XMLReflectConstants{
    /**
     * An error happened while trying to construct a test. No constructor
     * matching the list of arguments could be found
     * {0} : The test's class name
     * {1} : The list of argument types for which no constructor was found
     */
    public static final String NO_MATCHING_CONSTRUCTOR
        = "xml.XMLReflect.error.no.matching.constructor";

    /**
     * Implementation helper: builds a generic object
     */
    public static Object buildObject(Element element) throws Exception {

        Element classDefiningElement = 
            getClassDefiningElement(element);

        String className
            = classDefiningElement.getAttribute(XR_CLASS_ATTRIBUTE);

        Class cl = Class.forName(className);
        Object[] argsArray = null;
        Class[]  argsClasses = null;

        NodeList children = element.getChildNodes();
        if(children != null && children.getLength() > 0){
            int n = children.getLength();
            Vector args = new Vector();
            for(int i=0; i<n; i++){
                Node child = children.item(i);
                if(child.getNodeType() == Node.ELEMENT_NODE){
                    Element childElement = (Element)child;
                    String tagName = childElement.getTagName().intern();
                    if(tagName == XR_ARG_TAG){
                        Object arg = buildArgument(childElement);
                        args.addElement(arg);
                    }
                }
            }

            if(args.size() > 0){
                argsArray = new Object[args.size()];
                args.copyInto(argsArray);

                argsClasses = new Class[args.size()];

                for(int i=0; i<args.size(); i++){
                    argsClasses[i] = argsArray[i].getClass();
                }
            }
        }

        Constructor constructor
            = getDeclaredConstructor(cl, argsClasses);

        if (constructor == null) {
            String argsClassesStr = "null";
            if (argsClasses != null) {
                argsClassesStr = "";
                for (int i=0; i<argsClasses.length; i++) {
                    argsClassesStr += argsClasses[i].getName() + " / ";
                }
            }
            throw new Exception(Messages.formatMessage(NO_MATCHING_CONSTRUCTOR,
                                                       new Object[] { className,
                                                                      argsClassesStr }));
        }
        return configureObject(constructor.newInstance(argsArray),
                               element, classDefiningElement);
    }

    /**
     * Implementation helper: configures a generic object
     */
    public static Object configureObject(Object obj,
                                         Element element,
                                         Element classDefiningElement) throws Exception {
        // First, build a vector of elements from the child element
        // to the classDefiningElement so that we can go from the 
        // top (classDefiningElement) to the child and apply properties
        // as we iterate
        Vector v = new Vector();
        v.addElement(element);
        while (element != classDefiningElement) {
            element = (Element) element.getParentNode();
            v.addElement(element);
        }

        int ne = v.size();
        for (int j=ne-1; j>=0; j--) {
            element = (Element)v.elementAt(j);
            NodeList children = element.getChildNodes();
            if(children != null && children.getLength() > 0){
                int n = children.getLength();
                for(int i=0; i<n; i++){
                    Node child = children.item(i);
                    if(child.getNodeType() == Node.ELEMENT_NODE){
                        Element childElement = (Element)child;
                        String tagName = childElement.getTagName().intern();
                        if(tagName == XR_PROPERTY_TAG){
                            Object arg = buildArgument(childElement);
                            String propertyName
                                = childElement.getAttribute(XR_NAME_ATTRIBUTE);
                            setObjectProperty(obj, propertyName, arg);
                        }
                    }
                }
                
            }
        }

        return obj;
    }

    /**
     * Sets the property with given name on object to the input value
     */
    public static void setObjectProperty(Object obj,
                                         String propertyName,
                                         Object propertyValue)
        throws Exception {
        Class cl = obj.getClass();
        Method m = null;
        try {
            m = cl.getMethod("set" + propertyName,
                             new Class[]{propertyValue.getClass()});
            
        } catch (NoSuchMethodException e) {
            //
            // Check if the type was one of the primitive types, Double,
            // Float, Boolean or Integer
            //
            Class propertyClass = propertyValue.getClass();
            try {
                if (propertyClass == java.lang.Double.class) {
                    m = cl.getMethod("set" + propertyName,
                                     new Class[] {java.lang.Double.TYPE});
                } else if (propertyClass == java.lang.Float.class) {
                    m = cl.getMethod("set" + propertyName,
                                     new Class[] {java.lang.Float.TYPE});
                } else if (propertyClass == java.lang.Integer.class) {
                    m = cl.getMethod("set" + propertyName,
                                     new Class[] {java.lang.Integer.TYPE});
                } else if (propertyClass == java.lang.Boolean.class) {
                    m = cl.getMethod("set" + propertyName,
                                     new Class[] {java.lang.Boolean.TYPE});
                } else {
                    System.err.println("Could not find a set method for property : " + propertyName 
                                       + " with value " + propertyValue + " and class " + propertyValue.getClass().getName());
                    throw e;
                }
            } catch (NoSuchMethodException nsme) {
                throw nsme;
            }
        }
        if(m != null){
            m.invoke(obj, new Object[]{propertyValue});
        }
    }


    /**
     * Returns a constructor that has can be used for the input class
     * types.
     */
    public static Constructor getDeclaredConstructor(Class cl,
                                                 Class[] argClasses){
        Constructor[] cs = cl.getDeclaredConstructors();
        for(int i=0; i<cs.length; i++){
            Class[] reqArgClasses = cs[i].getParameterTypes();
            if(reqArgClasses != null && reqArgClasses.length > 0){
                if(reqArgClasses.length == argClasses.length){
                    int j=0;
                    for(; j<argClasses.length; j++){
                        if(!reqArgClasses[j].isAssignableFrom(argClasses[j])){
                            break;
                        }
                    }
                    if(j == argClasses.length){
                        return cs[i];
                    }
                }
            }
            else{
                if(argClasses == null || argClasses.length == 0){
                    return cs[i];
                }
            }
        }

        return null;
    }

    /**
     * Limitation: Arguments *must* have a String based
     * constructor. Or be an object that takes a set of string
     * based arguments.
     */
    public static Object buildArgument(Element element) throws Exception {
        if(!element.hasChildNodes()){
            Element classDefiningElement = 
                getClassDefiningElement(element);

            String classAttr = classDefiningElement.getAttribute(XR_CLASS_ATTRIBUTE);

            // String based argument
            Class cl = Class.forName(classAttr);

            if(element.hasAttribute(XR_VALUE_ATTRIBUTE)){
                String value = element.getAttribute(XR_VALUE_ATTRIBUTE);


                Constructor constructor
                    = cl.getDeclaredConstructor(new Class[] { String.class });

                return constructor.newInstance(new Object[] {value});
            }
            else{
                // Default constructor
                return cl.newInstance();
            }
        }
        else{
            return buildObject(element);
        }
    }

    /**
     * Gets the defining class element
     */
    public static Element getClassDefiningElement(Element element) {
        if(element != null){
            String classAttr = element.getAttribute(XR_CLASS_ATTRIBUTE);

            if(classAttr == null || "".equals(classAttr)){
                Node parent = element.getParentNode();
                if(parent != null && parent.getNodeType() == Node.ELEMENT_NODE){
                    return getClassDefiningElement((Element)parent);
                }
                else{
                    return null;
                }
            }
            
            return element;

        }

        return null;
    }
}
