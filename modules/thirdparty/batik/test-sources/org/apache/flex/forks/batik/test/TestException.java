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
 * Classes in the test package and subpackages should throw 
 * <tt>TestException</tt> to reflect internal failures in their
 * operation.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: TestException.java,v 1.3 2004/08/18 07:16:58 vhardy Exp $
 */
public class TestException extends Exception {
    /**
     * Error code
     */
    protected String errorCode;

    /**
     * Parameters for the error message
     */
    protected Object[] errorParams;

    /**
     * Exception, if any, that caused the error
     */
    protected Exception sourceError;

    public TestException(String errorCode,
                         Object[] errorParams,
                         Exception e){
        this.errorCode = errorCode;
        this.errorParams = errorParams;
        this.sourceError = e;
    }

    public String getErrorCode(){
        return errorCode;
    }

    public Object[] getErrorParams(){
        return errorParams;
    }

    public Exception getSourceError(){
        return sourceError;
    }

    public String getMessage(){
        return Messages.formatMessage(errorCode,
                                      errorParams);
    }
}
