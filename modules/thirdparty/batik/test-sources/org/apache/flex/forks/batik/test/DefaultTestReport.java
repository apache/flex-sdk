/*

   Copyright 2001  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.test;

/**
 * Simple, default implementation for the <tt>TestReport</tt>
 * interface.
 * 
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: DefaultTestReport.java,v 1.4 2004/08/18 07:16:56 vhardy Exp $
 */
public class DefaultTestReport implements TestReport {
    private boolean passed = true;

    protected Entry[] description = null;

    protected Test test;

    private String errorCode;
    
    /**
     * Parent report, in case this report is part of a
     * <tt>TestSuiteReport</tt>
     */
    protected TestSuiteReport parent;

    public DefaultTestReport(Test test){
        if(test == null){
            throw new IllegalArgumentException();
        }

        this.test = test;
    }

    public TestSuiteReport getParentReport(){
        return parent;
    }

    public void setParentReport(TestSuiteReport parent){
        this.parent = parent;
    }

    public Test getTest(){
        return test;
    }

    public String getErrorCode(){
        return errorCode;
    }

    public void setErrorCode(String errorCode){
        if( !passed && errorCode == null ){
            /**
             * Error code should be set first
             */
            throw new IllegalArgumentException();
        }

        this.errorCode = errorCode;
    }

    public boolean hasPassed(){
        return passed;
    }
    
    public void setPassed(boolean passed){
        if( !passed && (errorCode == null) ){
            /**
             * Error Code should be set first
             */
            throw new IllegalArgumentException();
        }
        this.passed = passed;
    }
    
    public Entry[] getDescription(){
        return description;
    }
    
    public void setDescription(Entry[] description){
        this.description = description;
    }

    public void addDescriptionEntry(String key,
                                    Object value){
        addDescriptionEntry(new Entry(key, value));
    }

    protected void addDescriptionEntry(Entry entry){
        if(description == null){
            description = new Entry[1];
            description[0] = entry;
        }
        else{
            Entry[] oldDescription = description;
            description = new Entry[description.length + 1];
            System.arraycopy(oldDescription, 0, description, 0,
                             oldDescription.length);
            description[oldDescription.length] = entry;
        }
    }

}

