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

package flex.ant;

import flex.ant.config.ConfigAppendString;
import flex.ant.config.ConfigBoolean;
import flex.ant.config.ConfigInt;
import flex.ant.config.ConfigString;
import flex.ant.config.ConfigVariable;
import flex.ant.config.NestedAttributeElement;
import flex.ant.config.OptionSource;
import flex.ant.config.OptionSpec;
import flex.ant.config.RepeatableConfigString;
import flex.ant.types.DefaultScriptLimits;
import flex.ant.types.DefaultSize;
import flex.ant.types.FlexFileSet;
import flex.ant.types.Fonts;
import flex.ant.types.Metadata;
import flex.ant.types.RuntimeSharedLibraryPath;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.DynamicConfigurator;

import java.util.ArrayList;
import java.util.Iterator;
import java.io.File;

/**
 * Implements the &lt;asdoc&gt; Ant task.  For example:
 * <p>
 * <pre>
 *      &lt;asdoc output="${FLEX_HOME}/tempDoc" lenient="true" failonerror="true" keep-xml="true" skip-xsl="true" &gt;
 *         &lt;compiler.source-path path-element="${basedir}/src"/&gt;
 *         &lt;doc-classes class="SparkSkinsClasses"/&gt;
 *         &lt;external-library-path dir="${FLEX_HOME}/frameworks/libs/player/${local.playerglobal.version}"&gt;
 *             &lt;include name="playerglobal.swc" /&gt;
 *         &lt;/external-library-path&gt;
 *         &lt;external-library-path dir="${FLEX_HOME}/frameworks/libs"&gt;
 *             &lt;include name="framework.swc" /&gt;
 *             &lt;include name="spark.swc" /&gt;
 *         &lt;/external-library-path&gt;
 *         &lt;jvmarg line="${asdoc.jvm.args}"/&gt;
 *     &lt;/asdoc&gt;
 * </pre>
 * <p>
 * All the simple asdoc configuration parameters are supported as tag
 * attributes.  Complex configuration options, like
 * -compiler.namespaces.namespace, are implemented as child tags.  For
 * example:
 * <p>
 * </code>
 *     &lt;namespace uri="http://www.adobe.com/2006/mxml" manifest="${basedir}/manifest.xml"/&gt;
 * </code>
 * <p>
 * One of the more common child tags is &lt;doc-classes&gt;.  For example:
 * <p>
 * <code>
 *     &lt;doc-classes class="SparkSkinsClasses"/&gt;
 * </code>
 *
 * @author gauravj
 */
public final class AsDocTask extends FlexTask implements DynamicConfigurator
{
    /*
     * =======================================================================
     * Static variables and initializer *
     * =======================================================================
     */
    private static OptionSpec nsSpec = new OptionSpec("compiler", "namespaces.namespace", "namespace");
    private static OptionSpec liSpec = new OptionSpec("licenses", "license");
    private static OptionSpec exSpec = new OptionSpec("externs");
    private static OptionSpec inSpec = new OptionSpec("includes");
    private static OptionSpec rsSpec = new OptionSpec(null, "runtime-shared-libraries", "rsl");
    private static OptionSpec frSpec = new OptionSpec("frames", "frame");

    private static OptionSpec ccSpec = new OptionSpec("compiler", "define");
    private static OptionSpec elSpec = new OptionSpec("compiler", "external-library-path", "el");
    private static OptionSpec ilSpec = new OptionSpec("compiler", "include-libraries");
    private static OptionSpec lpSpec = new OptionSpec("compiler", "library-path", "l");
    private static OptionSpec spSpec = new OptionSpec("compiler", "source-path", "sp");
    private static OptionSpec thSpec = new OptionSpec("compiler", "theme");
    private static OptionSpec lcSpec = new OptionSpec("load-config");
    private static OptionSpec kmSpec = new OptionSpec("compiler", "keep-as3-metadata");

    private static OptionSpec dcSpec = new OptionSpec(null, "doc-classes", "dc");
    private static OptionSpec dnSpec = new OptionSpec(null, "doc-namespaces", "dn");
    private static OptionSpec dsSpec = new OptionSpec(null, "doc-sources", "ds");
    private static OptionSpec ecSpec = new OptionSpec("exclude-classes");
    private static OptionSpec pkgSpec = new OptionSpec("packages", "package");
    private static OptionSpec esSpec = new OptionSpec(null, "exclude-sources");

    /*
     * =======================================================================
     * Non static declarations
     * =======================================================================
     */
    private final ArrayList nestedFileSets;

    private final RepeatableConfigString dcStrings;

    private Metadata metadata;
    private Fonts fonts;

    /*
     * =======================================================================
     * Singular arguments *
     * =======================================================================
     */
    private String output;

    /**
     *
     */
    public AsDocTask()
    {
        super("asdoc", "flex2.tools.ASDoc", "asdoc.jar", new ConfigVariable[] {
                // Basic Booleans
                new ConfigBoolean(new OptionSpec("benchmark")),
                new ConfigBoolean(new OptionSpec("compiler", "accessible")),
                new ConfigBoolean(new OptionSpec("compiler", "debug")),
                new ConfigBoolean(new OptionSpec("compiler", "incremental")),
                new ConfigBoolean(new OptionSpec("compiler", "optimize")),
                new ConfigBoolean(new OptionSpec("compiler", "report-invalid-styles-as-warnings")),
                new ConfigBoolean(new OptionSpec("compiler", "report-missing-required-skin-parts-as-warnings")),
                new ConfigBoolean(new OptionSpec("compiler", "show-actionscript-warnings")),
                new ConfigBoolean(new OptionSpec("compiler", "show-binding-warnings")),
                new ConfigBoolean(new OptionSpec("compiler", "show-deprecation-warnings")),
                new ConfigBoolean(new OptionSpec("compiler", "show-invalid-css-property-warnings")),
                new ConfigBoolean(new OptionSpec("compiler", "show-unused-type-selector-warnings")),
                new ConfigBoolean(new OptionSpec("compiler", "strict")),
                new ConfigBoolean(new OptionSpec("compiler", "use-resource-bundle-metadata")),
                new ConfigBoolean(new OptionSpec("use-network")),
                new ConfigBoolean(new OptionSpec("warnings")),
                new ConfigBoolean(new OptionSpec("exclude-dependencies")),
                new ConfigBoolean(new OptionSpec("lenient")),
                new ConfigBoolean(new OptionSpec("keep-xml")),
                new ConfigBoolean(new OptionSpec("skip-xsl")),
                new ConfigBoolean(new OptionSpec("restore-builtin-classes")),
                new ConfigBoolean(new OptionSpec("date-in-footer")),
                
                // Advanced Booleans
                new ConfigBoolean(new OptionSpec("compiler", "allow-source-path-overlap")),
                new ConfigBoolean(new OptionSpec("compiler", "as3")),
                new ConfigBoolean(new OptionSpec("compiler", "doc")),
                new ConfigBoolean(new OptionSpec("compiler", "es")),
                new ConfigBoolean(new OptionSpec("compiler", "generate-abstract-syntax-tree")),
                new ConfigBoolean(new OptionSpec("compiler", "headless-server")),
                new ConfigBoolean(new OptionSpec("compiler", "keep-all-type-selectors")),
                new ConfigBoolean(new OptionSpec("compiler", "keep-generated-actionscript", "keep")),
                new ConfigBoolean(new OptionSpec("compiler", "verbose-stacktraces")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-array-tostring-changes")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-assignment-within-conditional")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-bad-array-cast")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-bad-bool-assignment")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-bad-date-cast")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-bad-es3-type-method")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-bad-es3-type-prop")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-bad-nan-comparison")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-bad-null-assignment")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-bad-null-comparison")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-bad-undefined-comparison")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-boolean-constructor-with-no-args")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-changes-in-resolve")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-class-is-sealed")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-const-not-initialized")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-constructor-returns-value")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-deprecated-event-handler-error")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-deprecated-function-error")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-deprecated-property-error")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-duplicate-argument-names")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-duplicate-variable-def")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-for-var-in-changes")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-import-hides-classes")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-instance-of-changes")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-internal-error")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-level-not-supported")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-missing-namespace-decl")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-negative-uint-literal")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-no-constructor")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-no-explicit-super-call-in-constructor")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-no-type-decl")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-number-from-string-changes")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-scoping-change-in-this")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-slow-text-field-addition")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-unlikely-function-value")),
                new ConfigBoolean(new OptionSpec("compiler", "warn-xml-class-has-changed")),
                new ConfigBoolean(new OptionSpec(null, "static-link-runtime-shared-libraries", "static-rsls")),
                // String Variables
                new ConfigString(new OptionSpec("compiler", "actionscript-file-encoding")),
                new ConfigString(new OptionSpec("compiler", "mxml.compatibility-version", "compatibility-version")),
                new ConfigString(new OptionSpec("compiler", "context-root")),
                new ConfigString(new OptionSpec("compiler", "defaults-css-url")),
                new ConfigString(new OptionSpec("compiler", "locale")),
                new ConfigString(new OptionSpec("compiler", "services")),
                new ConfigString(new OptionSpec("debug-password")),
                new ConfigString(new OptionSpec("dump-config")),
                new ConfigString(new OptionSpec("link-report")),
                new ConfigString(new OptionSpec("load-externs")),
                new ConfigString(new OptionSpec(null, "output", "o")),
                new ConfigString(new OptionSpec("raw-metadata")),
                new ConfigString(new OptionSpec("resource-bundle-list")),
                new ConfigString(new OptionSpec("target-player")),
                new ConfigAppendString(new OptionSpec("configname")),
                new ConfigString(new OptionSpec("footer")),
                new ConfigString(new OptionSpec("main-title")),
                new ConfigString(new OptionSpec("window-title")),
                new ConfigString(new OptionSpec("examples-path")),
                new ConfigString(new OptionSpec("templates-path")),
                new ConfigString(new OptionSpec("package-description-file")),
                // Int Variables
                new ConfigInt(new OptionSpec("left-frameset-width")),
                new ConfigInt(new OptionSpec("swf-version"))
        });

        nestedAttribs = new ArrayList();
        nestedFileSets = new ArrayList();
        dcStrings = new RepeatableConfigString(new OptionSpec(null, "doc-classes", "dc"));
    }

    /*
     * =======================================================================
     * Other Attributes *
     * =======================================================================
     */

    /*
     * Necessary to override inherited setOutput method since ant gives priority
     * to parameter types more specific than String.
     */
    public void setOutput(File o)
    {
        setOutput(o.getAbsolutePath());
    }

    public void setOutput(String o)
    {
        this.output = o;
    }

    /*
     * =======================================================================
     * Child Elements *
     * =======================================================================
     */

    public Metadata createMetadata()
    {
        if (metadata == null)
        {
            return metadata = new Metadata();
        }
        else
        {
            throw new BuildException("Only one nested <metadata> element is allowed in an <asdoc> task.");
        }
    }

    public Fonts createFonts()
    {
        if (fonts == null)
        {
            return fonts = new Fonts(this);
        }
        else
        {
            throw new BuildException("Only one nested <fonts> element is allowed in an <asdoc> task.");
        }
    }

    public NestedAttributeElement createNamespace()
    {
        return createElem(new String[] {"uri", "manifest"}, nsSpec);
    }

    public NestedAttributeElement createLicense()
    {
        return createElem(new String[] {"product", "serial-number"}, liSpec);
    }

    public NestedAttributeElement createExterns()
    {
        return createElem("symbol", exSpec);
    }

    public NestedAttributeElement createIncludes()
    {
        return createElem("symbol", inSpec);
    }

    public NestedAttributeElement createFrame()
    {
        return createElem(new String[] {"label", "classname"}, frSpec);
    }
    
    public Object createDynamicElement(String name)
    {
        if (kmSpec.matches(name))
        {
            return createElem("name", kmSpec);
        }
        else if (ccSpec.matches(name))
        {
            return createElem(new String[] {"name", "value"}, ccSpec);
        }
        else if (rsSpec.matches(name))
        {
            return createElem("url", rsSpec);
        }
        else if (rslpSpec.matches(name))
        {
            RuntimeSharedLibraryPath runtimeSharedLibraryPath = new RuntimeSharedLibraryPath();
            nestedAttribs.add(runtimeSharedLibraryPath);
            return runtimeSharedLibraryPath;
        }
        else if (lcSpec.matches(name))
        {
        	return createElemAllowAppend(new String[] {"filename"} , lcSpec);
        }
        else if (spSpec.matches(name))
        {
            return createElem("path-element", spSpec);
        }
        else if (elSpec.matches(name))
        {
            FlexFileSet fs = new FlexFileSet(elSpec, true);
            nestedFileSets.add(fs);
            return fs;
        }
        else if (ilSpec.matches(name))
        {
            FlexFileSet fs = new FlexFileSet(ilSpec, true);
            nestedFileSets.add(fs);
            return fs;
        }
        else if (lpSpec.matches(name))
        {
            FlexFileSet fs = new FlexFileSet(lpSpec, true);
            nestedFileSets.add(fs);
            return fs;
        }
        else if (thSpec.matches(name))
        {
            FlexFileSet fs = new FlexFileSet(thSpec);
            nestedFileSets.add(fs);
            return fs;
        }
        // asdoc specific
        else if (dsSpec.matches(name)) // -doc-sources
        {
            return createElem("path-element", dsSpec);
        }
        else if (dnSpec.matches(name)) // -doc-namespaces
        {
            return createElem("uri", dnSpec);
        }
        else if (dcSpec.matches(name)) // -doc-classes
        {
            return createElem("class", dcSpec);
        }
        else if (ecSpec.matches(name)) // -exclude-classes
        {
            return createElem("class", ecSpec);
        }
        else if (pkgSpec.matches(name)) // -packages.package
        {
            return createElem(new String[] {"name", "description"}, pkgSpec);
        }
        else if (esSpec.matches(name)) // -exclude-sources
        {
            return createElem("path-element", esSpec);
        }            

        return super.createDynamicElement(name);
    }

    /*
     * =======================================================================
     * Execute and Related Functions *
     * =======================================================================
     */

    protected void prepareCommandline() throws BuildException
    {
        for (int i = 0; i < variables.length; i++)
        {
            variables[i].addToCommandline(cmdl);
        }

        if (metadata != null)
        {
            metadata.addToCommandline(cmdl);
        }

        if (fonts != null)
        {
            fonts.addToCommandline(cmdl);
        }

        dcStrings.addToCommandline(cmdl);

        Iterator it = nestedAttribs.iterator();

        while (it.hasNext())
        {
            ((OptionSource)it.next()).addToCommandline(cmdl);
        }

        it = nestedFileSets.iterator();

        while (it.hasNext())
        {
            ((OptionSource)it.next()).addToCommandline(cmdl);
        }

        if (output != null)
        {
            (new ConfigString(new OptionSpec(null, "output", "o"), output)).addToCommandline(cmdl);
        }

    }

    public void setDynamicAttribute(String name, String value)
    {
        /* Handle required attributes and then delegate to super */
        if (dcStrings.matches(name))
        {
            dcStrings.addAll(value.split(" "));
        }
        else
        {
            super.setDynamicAttribute(name, value);
        }
    }
} // End of AsDocTask
