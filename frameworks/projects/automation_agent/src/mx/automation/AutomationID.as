////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package mx.automation
{

/**
 *  The Flex automation framework uses the AutomationID class to build object identification
 *  that Agents can use. AutomationID consists of many AutomationIDParts, where each part
 *  identifies an object in the hierarchy. AutomationID defines a serialization format for
 *  an Array of maps. You use this class to represent  a hierarchy using segments that describe the properties of each object
 *  within the hierarchy.  
 *  The serialize format of the id is:
 * 
 *  <pre>property_1_name{property_1_value property_1_type}property_2_name{property_2_value property_2_type}|property_1_name{property_1_value property_1_type}property_2_name{property_2_value property_2_type}</pre>
 *  <p>Consider a Flex application with following hierarchy:
 *  <pre>Application -- > Accordion -- > HBox -- > Button</pre></p>
 *  <p>The AutomationID of the button would consist of four AutomationIDParts, one for application,
 *  one for Accordion, one for HBox, and one for the Button. AutomationIDPart is a table of
 *  property names and their values. The property-value pairs are different for different object types.
 *  These property-value pairs should be usable to identify the object uniquely.</p>
 *  <p>AutomationID is created by walking the parent hierarchy of the leaf child object and creating
 *  the AutomationIDPart for each object encountered. Parents that have
 *  <code>showInAutomationHierarchy</code> set to <code>false</code> are skipped. Children of such
 *  parents are considered the children of the next higher
 *  parent whose <code>showInAuto</code> flag is set to <code>true</code>. During recording,
 *  this AutomationID can be saved by the agent. </p>
 * <p>During playback when Agent provides AutomationID for finding an object, the Display object
 *  hierarchy is walked from the top Application object downwards. At each level, a child that
 *  matches the AutomationIDPart closest is picked up from the list of all the children. If
 *  multiple children match the criteria, an error is thrown. Users are responsible to resolve
 *  such conflicts by providing a unique <code>automationName</code> or identifying new properties on
 *  objects which make them unique.</p>
 *  <p>Agents should save the object information if they desire persistence. AutomationID provides
 *  <code>toString()</code>  and <code>parse()</code> methods to convert the object to a
 *  string representation and back.</p>
 *  <p>You can use the <code>IAutomationManager.createAutomationID()</code> and
 *  <code>IAutomationManager.resolveAutomationID()</code> methods
 *  to create and resolve AutomationID objects, respectively.</p>
 *  <p>You can use the <code>IAutomationObjectHelper.helpCreateIDPart()</code>
 *  and <code>IAutomationObjectHelper.helpResolveIDPart()</code> methods
 *  to identify a child with in a parent which matches the AutomationIDPart.</p> 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AutomationID
{
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static function getValue(typename:String, stringValue:String):Object
    {
        switch (typename.toLowerCase())
        {
            case "boolean":
            {
                stringValue = stringValue ? stringValue.toLowerCase() : "false";
                return stringValue == "true" || stringValue == "t";
            }
    
            case "string":
            {
                return stringValue;
            }
                
            case "number":
            {
                return parseFloat(stringValue);
            }
                
            case "int":
            case "uint":
            {
                return parseInt(stringValue);
            }
                
            case "date":
            {
                return new Date(Date.parse(stringValue));
            }
                
            case "mx.core.reproducibleid":
            {
                return new AutomationID();
            }
            
            default:
            {
                return null;
            }
        }
    }

    /**
     *  Parses the string and returns an id.
     *
     *  @param s Serialized form of the id as provided by  the <code>toString()</code> method.
     *
     *  @return Parsed id.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function parse(s:String):AutomationID
    {
        var result:AutomationID = new AutomationID();
        
        var parts:Array = s.split("|");
        for (var i:int = 0; i < parts.length; i++)
        {
            var part:AutomationIDPart = new AutomationIDPart();
            result.addLast(part);
            var x:Array = parts[i].split(/[\{\ \}]/);
            for (var j:int = 0; (j+2) < x.length; j += 3)
            {
                part[decodeURI(x[j])] = 
                    AutomationID.getValue(x[j + 2], decodeURI(x[j + 1]));
            }
        }
        
        return result;
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function AutomationID()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var parts:Array = []; /* of AutomationIDPart */

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  length
    //----------------------------------

    /**
     *  The number of parts in this id.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get length():int
    {
        return parts.length;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Indicates if there are more parts of the id.
     * 
     *  @return <code>true</code> if there are no more parts of the id, 
     *  <code>false</code> otherwise.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function isEmpty():Boolean
    {
        return parts.length == 0;
    }

    /**
     *  Returns the first object in the id
     *
     *  @return First object in the id.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function peekFirst():AutomationIDPart
    {
        return parts[0] as AutomationIDPart;
    }

    /**
     *  Returns the last object in the id.
     *
     *  @return Last object in the id.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function peekLast():AutomationIDPart
    {
        return parts[parts.length - 1] as AutomationIDPart;
    }

    /**
     *  Removes the first object from this id.
     *
     *  @return First object in this id.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function removeFirst():AutomationIDPart
    {
        return parts.shift() as AutomationIDPart;
    }

    /**
     *  Removes the last object from this id.
     *
     *  @return Last object in this id.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function removeLast():AutomationIDPart
    {
        return parts.pop() as AutomationIDPart;
    }
    
    /**
     *  Adds a parts to the end of the id.
     *
     *  @param p Map of properties.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function addLast(p:AutomationIDPart):void
    {
        parts.push(p);
    }
    
    /**
     *  Adds a parts to the front of the id.
     *
     *  @param p Map of properties.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function addFirst(p:AutomationIDPart):void
    {
        parts.unshift(p);
    }

    /**
     *  Concatenates another id to this id. Returns a new id,
     *  and does not mutate this instance.
     *
     *  @param other id to concatenate.
     *
     *  @return This id concatenated with the other id.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function concat(other:AutomationID):AutomationID
    {
        var newID:AutomationID = new AutomationID();
        newID.parts = parts.concat(other.parts);
        return newID;
    }

    /**
     *  @private
     *  Removes any properties from the maps within the id that
     *  match the names provided.
     */
    public function stripProperties(names:Array):AutomationID
    {
        for (var i:int = 0; i < names.length; i++)
        {
            for (var j:int = 0; j < parts.length; j++)
            {
                if (names[i] in parts[j])
                    delete parts[j][names[i]];
            }
        }

        return this;
    }

    /**
     *  Serializes the id to a string.
     *
     *  @return The serialized id.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function toString():String
    {
        return parts.join("|");
    }

    /**
     *  @private
     *  Returns a duplicate object.
     */
    public function clone():AutomationID
    {
        var result:AutomationID = new AutomationID();
        
        for (var i:int = 0; i < parts.length; i++)
        {
            result.parts[i] = new AutomationIDPart();
            for (var j:Object in parts[i])
            {
                result.parts[i][j] = parts[i][j];
            }
        }

        return result;
    }
    
    /**
     * Compares this object with the given AutomationID.
     * 
     * @param other AutomationID object which needs to be compared.
     * 
     * @return <code>true</code> if they are equal, <code>false</code> otherwise.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function equals(other:AutomationID):Boolean
    {
        if (parts.length != other.parts.length)
            return false;

        for (var i:int = 0; i < parts.length; i++)
        {
            for (var j:Object in parts[i])
            {
                if (!(j in other.parts[i] && (parts[i][j] == other.parts[i][j]))) 
                    return false;
            }
            
        }

        return true;
    }

}

}
