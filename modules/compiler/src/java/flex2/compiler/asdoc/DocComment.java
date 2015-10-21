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
 */
public interface DocComment
{
    //What kind of definition does this DocComment belongs to.
    int PACKAGE = 0;
    int CLASS = 1;
    int INTERFACE = 2;
    int FUNCTION = 3;
    int FUNCTION_GET = 4;
    int FUNCTION_SET = 5;
    int FIELD = 6;
    int METADATA = 7;
    
    /**
     * Method that returns a map of all the information 
     * derived from parsing the tags. The keys are the
     * tag names. The values correspond to the get methods
     * for each tag.
     */
    Map getAllTags();
    
    //Basic get methods for most comments
    String getName();
    String getFullname();
    int getType();
    boolean isExcluded();
    
    String getDescription();
    
    //Common ones for Definitions
    boolean isFinal();
    boolean isStatic();
    boolean isOverride();
    
    //For Classes
    boolean isDynamic();
    String getSourceFile();
    String getAccess();    //public, private, etc...
    String getNamespace();
    String getBaseClass();
    String[] getInterfaces();
    
    //For Interfaces
    String[] getBaseclasses();
    
    //For Methods
    String[] getParamNames();
    String[] getParamTypes();
    String[] getParamDefaults();    //"undefined" if none found.
    String getResultType();
    
    //For Fields
    String getVartype();
    String getDefaultValue();    //"unknown" if none found.
    boolean isConst();
    
    //For Metadata
    List getMetadata();   //returns List containing DocComments of type METADATA
    String getMetadataType();
    String getOwner();
    String getType_meta();
    String getEvent_meta();
    String getKind_meta();
    String getArrayType_meta();
    String getFormat_meta();
    String getInherit_meta();
    String getEnumeration_meta();
    String getTheme_meta();
    String getMessage_meta(); // contains message for Deprecation
    String getReplacement_meta(); // contains replacement for Deprecation
    String getSince_meta(); // contains since for Deprecation
    
    
    //All @<something> tags are denoted by a get<Something>Tag() 
    //(or Tags()) method.
    
    //common ones
    String getCopyTag();    //@copy
    Map getCustomTags();    //(all unknown tags)
    List getExampleTags();     //@example
    String getHelpidTag();     //@helpid
    List getIncludeExampleTags();
    List getSeeTags();    //@see (multiple)
    String getTiptextTag();    //@tiptext
    boolean hasInheritTag();    //@inheritDoc

    //privacy tags
    boolean hasPrivateTag();    //@private
    String getInternalTag();    //@internal
    boolean hasReviewTag();    //@review
    
    //Version of AS/other products
    String getLangversionTag();    //@langversion
    List<String> getPlayerversionTags();    //@playerversion (multiple)
    List<String> getProductversionTags();   //@productversion (multiple)
    String getToolversionTag();    //@toolversion
    String getSinceTag();    //@since
    
    //For Classes and Interfaces
    List getAuthorTags();    //@author (multiple)
    
    //For Methods
    List getParamTags();    //@param (multiple)
    String getReturnTag();    //@return
    List getThrowsTags();    //@throws (multiple)
    List<String> getEventTags();    //@event (multiple)
    
    //For Fields
    String getDefaultTag();     //@default

    //[Event]-specific
    String getEventTypeTag();    //@eventType
    
    String getVariableType_meta();
    String getRequired_meta();
}
