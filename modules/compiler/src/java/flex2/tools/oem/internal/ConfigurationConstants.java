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

package flex2.tools.oem.internal;

/**
 * Contains constants for all the configuration options.
 *
 * @version 2.0.1
 * @author Clement Wong
 */
interface ConfigurationConstants
{
    String USE_NETWORK                                          = "--use-network";
    String RUNTIME_SHARED_LIBRARIES                             = "--runtime-shared-libraries";
    String RAW_METADATA                                         = "--raw-metadata";
    String PROJECTOR                                            = "--projector";
    String METADATA_PUBLISHER                                   = "--metadata.publisher";
    String METADATA_LANGUAGE                                    = "--metadata.language";
    String METADATA_LOCALIZED_TITLE                             = "--metadata.localized-title";
    String METADATA_LOCALIZED_DESCRIPTION                       = "--metadata.localized-description";
    String METADATA_DATE                                        = "--metadata.date";
    String METADATA_CREATOR                                     = "--metadata.creator";
    String METADATA_CONTRIBUTOR                                 = "--metadata.contributor";
    String LINK_REPORT                                          = "--link-report";
    String SIZE_REPORT                                          = "--size-report";
    String LICENSES_LICENSE                                     = "--licenses.license";
    String INCLUDES                                             = "--includes";
    String INCLUDE_RESOURCE_BUNDLES                             = "--include-resource-bundles";
    String FRAMES_FRAME                                         = "--frames.frame";
    String LOAD_EXTERNS                                         = "--load-externs";
    String LOAD_CONFIG                                          = "--load-config";
    String EXTERNS                                              = "--externs";
    String DEFAULT_SIZE                                         = "--default-size";
    String DEFAULT_SCRIPT_LIMITS                                = "--default-script-limits";
    String DEFAULT_FRAME_RATE                                   = "--default-frame-rate";
    String DEFAULT_BACKGROUND_COLOR                             = "--default-background-color";
    String DEBUG_PASSWORD                                       = "--debug-password";
    String SWF_VERSION                                          = "--swf-version";
    String COMPILER_WARN_XML_CLASS_HAS_CHANGED                  = "--compiler.warn-xml-class-has-changed";
    String COMPILER_WARN_UNLIKELY_FUNCTION_VALUE                = "--compiler.warn-unlikely-function-value";
    String COMPILER_WARN_SLOW_TEXT_FIELD_ADDITION               = "--compiler.warn-slow-text-field-addition";
    String COMPILER_WARN_SCOPING_CHANGE_IN_THIS                 = "--compiler.warn-scoping-change-in-this";
    String COMPILER_WARN_NUMBER_FROM_STRING_CHANGES             = "--compiler.warn-number-from-string-changes";
    String COMPILER_WARN_NO_TYPE_DECL                           = "--compiler.warn-no-type-decl";
    String COMPILER_WARN_NO_EXPLICIT_SUPER_CALL_IN_CONSTRUCTOR  = "--compiler.warn-no-explicit-super-call-in-constructor";
    String COMPILER_WARN_NO_CONSTRUCTOR                         = "--compiler.warn-no-constructor";
    String COMPILER_WARN_NEGATIVE_UINT_LITERAL                  = "--compiler.warn-negative-uint-literal";
    String COMPILER_WARN_MISSING_NAMESPACE_DECL                 = "--compiler.warn-missing-namespace-decl";
    String COMPILER_WARN_LEVEL_NOT_SUPPORTED                    = "--compiler.warn-level-not-supported";
    String COMPILER_WARN_INTERNAL_ERROR                         = "--compiler.warn-internal-error";
    String COMPILER_WARN_INSTANCE_OF_CHANGES                    = "--compiler.warn-instance-of-changes";
    String COMPILER_WARN_IMPORT_HIDES_CLASS                     = "--compiler.warn-import-hides-class";
    String COMPILER_WARN_FOR_VAR_IN_CHANGES                     = "--compiler.warn-for-var-in-changes";
    String COMPILER_WARN_DUPLICATE_VARIABLE_DEF                 = "--compiler.warn-duplicate-variable-def";
    String COMPILER_WARN_DUPLICATE_ARGUMENT_NAMES               = "--compiler.warn-duplicate-argument-names";
    String COMPILER_WARN_DEPRECATED_PROPERTY_ERROR              = "--compiler.warn-deprecated-property-error";
    String COMPILER_WARN_DEPRECATED_FUNCTION_ERROR              = "--compiler.warn-deprecated-function-error";
    String COMPILER_WARN_DEPRECATED_EVENT_HANDLER_ERROR         = "--compiler.warn-deprecated-event-handler-error";
    String COMPILER_WARN_CONSTRUCTOR_RETURNS_VALUE              = "--compiler.warn-constructor-returns-value";
    String COMPILER_WARN_CONST_NOT_INITIALIZED                  = "--compiler.warn-const-not-initialized";
    String COMPILER_WARN_CLASS_IS_SEALED                        = "--compiler.warn-class-is-sealed";
    String COMPILER_WARN_CHANGES_IN_RESOLVE                     = "--compiler.warn-changes-in-resolve";
    String COMPILER_WARN_BOOLEAN_CONSTRUCTOR_WITH_NO_ARGS       = "--compiler.warn-boolean-constructor-with-no-args";
    String COMPILER_WARN_BAD_UNDEFINED_COMPARISON               = "--compiler.warn-bad-undefined-comparison";
    String COMPILER_WARN_BAD_NULL_COMPARISON                    = "--compiler.warn-bad-null-comparison";
    String COMPILER_WARN_BAD_NULL_ASSIGNMENT                    = "--compiler.warn-bad-null-assignment";
    String COMPILER_WARN_BAD_NAN_COMPARISON                     = "--compiler.warn-bad-nan-comparison";
    String COMPILER_WARN_BAD_ES3_TYPE_PROP                      = "--compiler.warn-bad-es3-type-prop";
    String COMPILER_WARN_BAD_ES3_TYPE_METHOD                    = "--compiler.warn-bad-es3-type-method";
    String COMPILER_WARN_BAD_DATE_CAST                          = "--compiler.warn-bad-date-cast";
    String COMPILER_WARN_BAD_BOOL_ASSIGNMENT                    = "--compiler.warn-bad-bool-assignment";
    String COMPILER_WARN_BAD_ARRAY_CAST                         = "--compiler.warn-bad-array-cast";
    String COMPILER_WARN_ASSIGNMENT_WITHIN_CONDITIONAL          = "--compiler.warn-assignment-within-conditional";
    String COMPILER_WARN_ARRAY_TOSTRING_CHANGES                 = "--compiler.warn-array-tostring-changes";
    String COMPILER_VERBOSE_STACKTRACES                         = "--compiler.verbose-stacktraces";
    String COMPILER_USE_RESOURCE_BUNDLE_METADATA                = "--compiler.use-resource-bundle-metadata";
    String COMPILER_THEME                                       = "--compiler.theme";
    String COMPILER_STRICT                                      = "--compiler.strict";
    String COMPILER_SOURCE_PATH                                 = "--compiler.source-path";
    String COMPILER_SHOW_UNUSED_TYPE_SELECTOR_WARNINGS          = "--compiler.show-unused-type-selector-warnings";
    String COMPILER_SHOW_DEPRECATION_WARNINGS                   = "--compiler.show-deprecation-warnings";
    String COMPILER_SHOW_SHADOWED_DEVICE_FONT_WARNINGS          = "--compiler.show-shadowed-device-font-warnings";
    String COMPILER_SHOW_BINDING_WARNINGS                       = "--compiler.show-binding-warnings";
    String COMPILER_SHOW_ACTIONSCRIPT_WARNINGS                  = "--compiler.show-actionscript-warnings";
    String COMPILER_SERVICES                                    = "--compiler.services";
    String COMPILER_OPTIMIZE                                    = "--compiler.optimize";
    String COMPILER_NAMESPACES_NAMESPACE                        = "--compiler.namespaces.namespace";
    String COMPILER_MOBILE                                      = "--compiler.mobile";
    String COMPILER_LOCALE                                      = "--compiler.locale";
    String COMPILER_LIBRARY_PATH                                = "--compiler.library-path";
    String COMPILER_INCLUDE_LIBRARIES                           = "--compiler.include-libraries";
    String COMPILER_KEEP_GENERATED_ACTIONSCRIPT                 = "--compiler.keep-generated-actionscript";
    String COMPILER_KEEP_AS3_METADATA                           = "--compiler.keep-as3-metadata";
    String COMPILER_KEEP_ALL_TYPE_SELECTORS                     = "--compiler.keep-all-type-selectors";
    String COMPILER_HEADLESS_SERVER                             = "--compiler.headless-server";
    String COMPILER_FONTS_MAX_GLYPHS_PER_FACE                   = "--compiler.fonts.max-glyphs-per-face";
    String COMPILER_FONTS_MAX_CACHED_FONTS                      = "--compiler.fonts.max-cached-fonts";
    String COMPILER_FONTS_MANAGERS                              = "--compiler.fonts.managers";
    String COMPILER_FONTS_LOCAL_FONT_PATHS                      = "--compiler.fonts.local-font-paths";
    String COMPILER_FONTS_LOCAL_FONTS_SNAPSHOT                  = "--compiler.fonts.local-fonts-snapshot";
    String COMPILER_FONTS_LANGUAGES_LANGUAGE_RANGE              = "--compiler.fonts.languages.language-range";
    String COMPILER_FONTS_FLASH_TYPE                            = "--compiler.fonts.flash-type";
    String COMPILER_FONTS_ADVANCED_ANTI_ALIASING                = "--compiler.fonts.advanced-anti-aliasing";
    String COMPILER_EXTERNAL_LIBRARY_PATH                       = "--compiler.external-library-path";
    String COMPILER_ES                                          = "--compiler.es";
    String COMPILER_DEFAULTS_CSS_URL                            = "--compiler.defaults-css-url";
    String COMPILER_DEBUG                                       = "--compiler.debug";
    String COMPILER_COMPRESS                                    = "--compiler.compress";
    String COMPILER_CONTEXT_ROOT                                = "--compiler.context-root";
    String COMPILER_AS3                                         = "--compiler.as3";
    String COMPILER_ALLOW_SOURCE_PATH_OVERLAP                   = "--compiler.allow-source-path-overlap";
    String COMPILER_ACTIONSCRIPT_FILE_ENCODING                  = "--compiler.actionscript-file-encoding";
    String COMPILER_ACCESSIBLE                                  = "--compiler.accessible";
    String TARGET_PLAYER                                        = "--target-player";
    String RUNTIME_SHARED_LIBRARY_PATH                          = "--runtime-shared-library-path";
    String VERIFY_DIGESTS                                       = "--verify-digests";
    String COMPILER_COMPUTE_DIGEST                              = "--compute-digest";
    String COMPILER_DEFINE                                      = "--compiler.define";
    String COMPILER_MXML_COMPATIBILITY							= "--compiler.mxml.compatibility-version";
    String COMPILER_EXTENSIONS                                  = "--compiler.extensions.extension";
    String REMOVE_UNUSED_RSLS                                   = "--remove-unused-rsls";
    String RUNTIME_SHARED_LIBRARY_SETTINGS_FORCE_RSLS           = "--runtime-shared-library-settings.force-rsls";
    String RUNTIME_SHARED_LIBRARY_SETTINGS_APPLICATION_DOMAIN  = "--runtime-shared-library-settings.application-domain";
}
