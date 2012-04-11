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

/**
 * Interface for accessing a specific comment. All get methods
 * will return null, -1, or false if the attribute does not
 * exist. The easiest way to retrieve all the tags is through
 * the getAllTags() method.
 * 
 * @author klin
 *
 */
public interface DocComment
{
    //What kind of definition does this DocComment belongs to.
    public static final int PACKAGE = 0;
    public static final int CLASS = 1;
    public static final int INTERFACE = 2;
    public static final int FUNCTION = 3;
    public static final int FUNCTION_GET = 4;
    public static final int FUNCTION_SET = 5;
    public static final int FIELD = 6;
    public static final int METADATA = 7;
    
    /**
     * Method that returns a map of all the information 
     * derived from parsing the tags. The keys are the
     * tag names. The values correspond to the get methods
     * for each tag.
     */
    public Map getAllTags();
    
    //Basic get methods for most comments
    public String getName();
    public String getFullname();
    public int getType();
    public boolean isExcluded();
    
    public String getDescription();
    
    //Common ones for Definitions
    public boolean isFinal();
    public boolean isStatic();
    public boolean isOverride();
    
    //For Classes
    public boolean isDynamic();
    public String getSourceFile();
    public String getAccess();    //public, private, etc...
    public String getNamespace();
    public String getBaseClass();
    public String[] getInterfaces();
    
    //For Interfaces
    public String[] getBaseclasses();
    
    //For Methods
    public String[] getParamNames();
    public String[] getParamTypes();
    public String[] getParamDefaults();    //"undefined" if none found.
    public String getResultType();
    
    //For Fields
    public String getVartype();
    public String getDefaultValue();    //"unknown" if none found.
    public boolean isConst();
    
    //For Metadata
    public List getMetadata();   //returns List containing DocComments of type METADATA
    public String getMetadataType();
    public String getOwner();
    public String getType_meta();
    public String getEvent_meta();
    public String getKind_meta();
    public String getArrayType_meta();
    public String getFormat_meta();
    public String getInherit_meta();
    public String getEnumeration_meta();
    public String getTheme_meta();
    public String getMessage_meta(); // contains message for Deprecation
    public String getReplacement_meta(); // contains replacement for Deprecation
    public String getSince_meta(); // contains since for Deprecation
    
    
    //All @<something> tags are denoted by a get<Something>Tag() 
    //(or Tags()) method.
    
    //common ones
    public String getCopyTag();    //@copy
    public Map getCustomTags();    //(all unknown tags)
    public List getExampleTags();     //@example
    public String getHelpidTag();     //@helpid
    public List getIncludeExampleTags();
    public List getSeeTags();    //@see (multiple)
    public String getTiptextTag();    //@tiptext
    public boolean hasInheritTag();    //@inheritDoc

    //privacy tags
    public boolean hasPrivateTag();    //@private
    public String getInternalTag();    //@internal
    public boolean hasReviewTag();    //@review
    
    //Version of AS/other products
    public String getLangversionTag();    //@langversion
    public List<String> getPlayerversionTags();    //@playerversion (multiple)
    public List<String> getProductversionTags();   //@productversion (multiple)
    public String getToolversionTag();    //@toolversion
    public String getSinceTag();    //@since
    
    //For Classes and Interfaces
    public List getAuthorTags();    //@author (multiple)
    
    //For Methods
    public List getParamTags();    //@param (multiple)
    public String getReturnTag();    //@return
    public List getThrowsTags();    //@throws (multiple)
    public List<String> getEventTags();    //@event (multiple)
    
    //For Fields
    public String getDefaultTag();     //@default

    //[Event]-specific
    public String getEventTypeTag();    //@eventType
    
    public String getVariableType_meta();
    public String getRequired_meta();    
}
