/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* 
 * This Xerces 2.9.1 class was updated for use by the Flex SDK at Adobe. These
 * updates were based on the changes originally made against Xerces 2.4.0 at
 * Macromedia. The changes are labeled with the comment "modified by rsun" and
 * the date the original modifications were made.
 */

package org.apache.xerces.util;

import org.apache.xerces.xni.QName;

/**
 * The XMLAttributesImpl class is an implementation of the XMLAttributes
 * interface which defines a collection of attributes for an element. 
 * In the parser, the document source would scan the entire start element 
 * and collect the attributes. The attributes are communicated to the
 * document handler in the startElement method.
 * <p>
 * The attributes are read-write so that subsequent stages in the document
 * pipeline can modify the values or change the attributes that are
 * propogated to the next stage.
 *
 * @see org.apache.xerces.xni.XMLDocumentHandler#startElement
 *
 * @author Andy Clark, IBM 
 * @author Elena Litani, IBM
 * @author Michael Glavassevich, IBM
 *
 * @version $Id: XMLAttributesImpl.java 447241 2006-09-18 05:12:57Z mrglavas $
 */
public class XMLAttributesMMImpl
	extends XMLAttributesImpl {

    //
    // Constructors
    //

    /** Default constructor. */
    // modified by rsun 11/06/03 - changed AttributeImpl to AttributeMMImpl
    public XMLAttributesMMImpl() {
	    super();
	    fAttributes = new AttributeMMImpl[4];
	    
        for (int i = 0; i < fAttributes.length; i++) {
            fAttributes[i] = new AttributeMMImpl();
        }
    } // <init>()
    
    /**
     * @param tableSize initial size of table view
     */
    // modified by rsun 11/06/03 - changed AttributeImpl to AttributeMMImpl
    public XMLAttributesMMImpl(int tableSize) {
        fTableViewBuckets = tableSize;
        for (int i = 0; i < fAttributes.length; i++) {
            fAttributes[i] = new AttributeMMImpl();
        }
    } // <init>()

    /**
     * Adds an attribute. The attribute's non-normalized value of the
     * attribute will have the same value as the attribute value until
     * set using the <code>setNonNormalizedValue</code> method. Also,
     * the added attribute will be marked as specified in the XML instance
     * document unless set otherwise using the <code>setSpecified</code>
     * method.
     * <p>
     * This method differs from <code>addAttribute</code> in that it
     * does not check if an attribute of the same name already exists
     * in the list before adding it. In order to improve performance
     * of namespace processing, this method allows uniqueness checks
     * to be deferred until all the namespace information is available
     * after the entire attribute specification has been read.
     * <p>
     * <strong>Caution:</strong> If this method is called it should
     * not be mixed with calls to <code>addAttribute</code> unless
     * it has been determined that all the attribute names are unique.
     *
     * @param name the attribute name
     * @param type the attribute type
     * @param value the attribute value
     *
     * @see #setNonNormalizedValue
     * @see #setSpecified
     * @see #checkDuplicatesNS
     */
    public void addAttributeNS(QName name, String type, String value) {
        int index = fLength;
        if (fLength++ == fAttributes.length) {
            Attribute[] attributes;
            if (fLength < SIZE_LIMIT) {
                attributes = new Attribute[fAttributes.length + 4];
            }
            else {
                attributes = new Attribute[fAttributes.length << 1];
            }
            System.arraycopy(fAttributes, 0, attributes, 0, fAttributes.length);
            for (int i = fAttributes.length; i < attributes.length; i++) {
                // modified by rsun - etierney did the mod, but putting rsun in here in case anybody is
                // grepping for that to find our custom changes
                // modified by etierney 1/07/11 - changed AttributeImpl to AttributeMMImpl
                attributes[i] = new AttributeMMImpl();
            }
            fAttributes = attributes;
        }

        // set values
        Attribute attribute = fAttributes[index];
        attribute.name.setValues(name);
        attribute.type = type;
        attribute.value = value;
        attribute.nonNormalizedValue = value;
        attribute.specified = false;

        // clear augmentations
        attribute.augs.removeAllItems();
    }

    /**
     * Adds an attribute. The attribute's non-normalized value of the
     * attribute will have the same value as the attribute value until
     * set using the <code>setNonNormalizedValue</code> method. Also,
     * the added attribute will be marked as specified in the XML instance
     * document unless set otherwise using the <code>setSpecified</code>
     * method.
     * <p>
     * <strong>Note:</strong> If an attribute of the same name already
     * exists, the old values for the attribute are replaced by the new
     * values.
     * 
     * @param name  The attribute name.
     * @param type  The attribute type. The type name is determined by
     *                  the type specified for this attribute in the DTD.
     *                  For example: "CDATA", "ID", "NMTOKEN", etc. However,
     *                  attributes of type enumeration will have the type
     *                  value specified as the pipe ('|') separated list of
     *                  the enumeration values prefixed by an open 
     *                  parenthesis and suffixed by a close parenthesis.
     *                  For example: "(true|false)".
     * @param value The attribute value.
     * 
     * @return Returns the attribute index.
     *
     * @see #setNonNormalizedValue
     * @see #setSpecified
     */
    public int addAttribute(QName name, String type, String value) {

        int index;
        if (fLength < SIZE_LIMIT) {
            index = name.uri != null && !name.uri.equals("") 
                ? getIndexFast(name.uri, name.localpart)
                : getIndexFast(name.rawname);

            if (index == -1) {
                index = fLength;
                if (fLength++ == fAttributes.length) {
                    // modified by rsun 11/06/03 - changed AttributeImpl to AttributeMMImpl
                    Attribute[] attributes = new AttributeMMImpl[fAttributes.length + 4];
                    System.arraycopy(fAttributes, 0, attributes, 0, fAttributes.length);
                    for (int i = fAttributes.length; i < attributes.length; i++) {
                        attributes[i] = new AttributeMMImpl();
                    }
                    fAttributes = attributes;
                }
            }
        }
        else if (name.uri == null || 
            name.uri.length() == 0 || 
            (index = getIndexFast(name.uri, name.localpart)) == -1) {
            
            /**
             * If attributes were removed from the list after the table
             * becomes in use this isn't reflected in the table view. It's
             * assumed that once a user starts removing attributes they're 
             * not likely to add more. We only make the view consistent if
             * the user of this class adds attributes, removes them, and
             * then adds more.
             */
            if (!fIsTableViewConsistent || fLength == SIZE_LIMIT) {
                prepareAndPopulateTableView();
                fIsTableViewConsistent = true;
            }

            int bucket = getTableViewBucket(name.rawname); 
        
            // The chain is stale. 
            // This must be a unique attribute.
            if (fAttributeTableViewChainState[bucket] != fLargeCount) {
                index = fLength;
                if (fLength++ == fAttributes.length) {
                    // modified by rsun 11/06/03 - changed AttributeImpl to AttributeMMImpl
                    Attribute[] attributes = new AttributeMMImpl[fAttributes.length << 1];
                    System.arraycopy(fAttributes, 0, attributes, 0, fAttributes.length);
                    for (int i = fAttributes.length; i < attributes.length; i++) {
                        attributes[i] = new AttributeMMImpl();
                    }
                    fAttributes = attributes;
                }
            
                // Update table view.
                fAttributeTableViewChainState[bucket] = fLargeCount;
                fAttributes[index].next = null;
                fAttributeTableView[bucket] = fAttributes[index];
            }
            // This chain is active. 
            // We need to check if any of the attributes has the same rawname.
            else {
                // Search the table.
                Attribute found = fAttributeTableView[bucket];
                while (found != null) {
                    if (found.name.rawname == name.rawname) {
                        break;
                    }
                    found = found.next;
                }
                // This attribute is unique.
                if (found == null) {
                    index = fLength;
                    if (fLength++ == fAttributes.length) {
                        // modified by rsun 11/06/03 - changed AttributeImpl to AttributeMMImpl
                        Attribute[] attributes = new AttributeMMImpl[fAttributes.length << 1];
                        System.arraycopy(fAttributes, 0, attributes, 0, fAttributes.length);
                        for (int i = fAttributes.length; i < attributes.length; i++) {
                            attributes[i] = new AttributeMMImpl();
                        }
                        fAttributes = attributes;
                    }
                
                    // Update table view
                    fAttributes[index].next = fAttributeTableView[bucket];
                    fAttributeTableView[bucket] = fAttributes[index];
                }
                // Duplicate. We still need to find the index.
                else {
                    index = getIndexFast(name.rawname);
                }
            }
        }          
        
        // set values
        Attribute attribute = fAttributes[index];
        attribute.name.setValues(name);
        attribute.type = type;
        attribute.value = value;
        attribute.nonNormalizedValue = value;
        attribute.specified = false;
            
        // clear augmentations
        attribute.augs.removeAllItems();

        return index;

    } // addAttribute(QName,String,XMLString)
    
    //
    // Public methods
    //

    /**
     * modified by rsun 11/06/03 - added functions
     * Get/Set the line number on which this attribute
     * was found.
     */
    
    public void setLineNumber(int index, int lineno) {
	    if (index < 0 || index >= fLength) {
		    return;
	    }
	    if(!(fAttributes[index] instanceof AttributeMMImpl)) {
		    return;
	    }
	    
	    ((AttributeMMImpl)fAttributes[index]).lineno = lineno;
    }

    public int getLineNumber(int index) {
	    if (index < 0 || index >= fLength) {
		    return -1;
	    }
	    if(!(fAttributes[index] instanceof AttributeMMImpl)) {
		    return -1;
	    }
	    
		return ((AttributeMMImpl)fAttributes[index]).lineno;
    }

    //
    // Classes
    //

    /**
     * Attribute information.
     *
     * @author Andy Clark, IBM
     * modified by rsun 11/06/03 - subclassed original Attribute class,
     * adding lineno property.
     */
    static class AttributeMMImpl extends Attribute {
        
        //
        // Data
        //

	/** Line number. */
	public int lineno;
        
    } // class AttributeMMImpl

} // class XMLAttributesMMImpl
