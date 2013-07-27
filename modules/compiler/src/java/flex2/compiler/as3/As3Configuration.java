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

package flex2.compiler.as3;

import macromedia.asc.embedding.ConfigVar;
import macromedia.asc.util.ObjectList;

/**
 * This interface is used to restrict consumers of
 * CompilerConfiguration to as3 compiler specific options.
 *
 * @author Clement Wong
 * @see flex2.compiler.common.CompilerConfiguration
 */
public interface As3Configuration
{
	/**
	 * Omit method arg names.
	 */
	boolean optimize();

	/**
	 * Emit system paths with debug info.
	 */
	boolean verboseStacktraces();

	/**
	 * Generate SWFs for debugging
	 */
	boolean debug();

	int dialect();
	boolean adjustOpDebugLine();

	/**
	 * Run the AS3 compiler in strict mode
	 */
	boolean strict();

	/**
	 * Enable asc -warnings
	 */
	boolean warnings();

	/**
	 * Generate asdoc
	 */
	boolean doc();

	/**
	 * user-defined AS3 file encoding
	 */
	String getEncoding();
    
    /**
     * Configuration settings (ConfigVars) from <code>--compiler.define</code>
     * are retrieved using this getter.
     *  
     * @return ObjectList<macromedia.asc.embedding.ConfigVar>
     */
    ObjectList<ConfigVar> getDefine();

    boolean getGenerateAbstractSyntaxTree();

	/**
	 * Whether to export metadata into ABCs
	 */
	public boolean metadataExport();

    public boolean showDeprecationWarnings();

	// coach warnings

	public boolean warn_array_tostring_changes();

	public boolean warn_assignment_within_conditional();

	public boolean warn_bad_array_cast();

	public boolean warn_bad_bool_assignment();

	public boolean warn_bad_date_cast();

	public boolean warn_bad_es3_type_method();

	public boolean warn_bad_es3_type_prop();

	public boolean warn_bad_nan_comparison();

	public boolean warn_bad_null_assignment();

	public boolean warn_bad_null_comparison();

	public boolean warn_bad_undefined_comparison();

	public boolean warn_boolean_constructor_with_no_args();

	public boolean warn_changes_in_resolve();

	public boolean warn_class_is_sealed();

	public boolean warn_const_not_initialized();

	public boolean warn_constructor_returns_value();

	public boolean warn_deprecated_event_handler_error();

	public boolean warn_deprecated_function_error();

	public boolean warn_deprecated_property_error();

	public boolean warn_duplicate_argument_names();

	public boolean warn_duplicate_variable_def();

	public boolean warn_for_var_in_changes();

	public boolean warn_import_hides_class();

	public boolean warn_instance_of_changes();

	public boolean warn_internal_error();

	public boolean warn_level_not_supported();

	public boolean warn_missing_namespace_decl();

	public boolean warn_negative_uint_literal();

	public boolean warn_no_constructor();

	public boolean warn_no_explicit_super_call_in_constructor();

	public boolean warn_no_type_decl();

	public boolean warn_number_from_string_changes();

	public boolean warn_scoping_change_in_this();

	public boolean warn_slow_text_field_addition();

	public boolean warn_unlikely_function_value();

	public boolean warn_xml_class_has_changed();

	public boolean keepEmbedMetadata();
	
	public boolean getAdvancedTelemetry();
}
