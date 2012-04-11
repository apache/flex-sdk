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

package flex2.compiler.util;

/**
 * Encapsulates the exceptions thrown during Velocity template usage.
 *
 * @author Paul Reilly
 */
public class VelocityException
{
    /**
     * Error reported when a template is not found.
     */
    public static class TemplateNotFound extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 3281434659448341356L;
        public String template;

        public TemplateNotFound(String template)
        {
            this.template = template;
            noPath();
        }
    }

    /**
     * Error reported when a problem occurs during generation.
     */
    public static class GenerateException extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -2645837653351436195L;
        public String message;
        public String template;

        public GenerateException(String template, String message)
        {
            this.template = template;
            this.message = message;
        }
    }

    /**
     * Error reported when a generated file can't be written to disk.
     */
    public static class UnableToWriteGeneratedFile extends CompilerMessage.CompilerWarning
    {
        private static final long serialVersionUID = 8829964076350246231L;
        public String fileName;
        public String message;

        public UnableToWriteGeneratedFile(String fileName, String message)
        {
            this.fileName = fileName;
	        this.message = message;
	        noPath();
        }
    }
}
