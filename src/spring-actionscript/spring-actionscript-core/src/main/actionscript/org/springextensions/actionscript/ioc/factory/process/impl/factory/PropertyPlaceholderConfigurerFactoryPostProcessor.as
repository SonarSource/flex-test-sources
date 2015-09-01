/*
 * Copyright 2007-2011 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.springextensions.actionscript.ioc.factory.process.impl.factory {
	import org.as3commons.async.operation.IOperation;
	import org.as3commons.lang.ObjectUtils;
	import org.as3commons.lang.StringUtils;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getClassLogger;
	import org.as3commons.reflect.Accessor;
	import org.as3commons.reflect.Type;
	import org.as3commons.reflect.Variable;
	import org.springextensions.actionscript.ioc.config.impl.RuntimeObjectReference;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.config.property.IPropertyPlaceholderResolver;
	import org.springextensions.actionscript.ioc.config.property.impl.PropertyPlaceholderResolver;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.MethodInvocation;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.PropertyDefinition;
	import org.springextensions.actionscript.util.TypeUtils;

	/**
	 * @author Christophe Herreman
	 * @author Roland Zwaga
	 * @productionversion SpringActionscript 2.0
	 */
	public class PropertyPlaceholderConfigurerFactoryPostProcessor extends AbstractOrderedFactoryPostProcessor {

		private static var logger:ILogger = getClassLogger(PropertyPlaceholderConfigurerFactoryPostProcessor);

		public static const DESTROY_METHOD_FIELD_NAME:String = 'destroyMethod';
		public static const FACTORY_METHOD_FIELD_NAME:String = 'factoryMethod';
		public static const FACTORY_OBJECT_NAME_FIELD_NAME:String = 'factoryObjectName';
		public static const INIT_METHOD_FIELD_NAME:String = 'initMethod';
		public static const PARENT_NAME_FIELD_NAME:String = 'parentName';

		/** Regular expression to resolve property placeholder with the pattern ${...} */
		public static const PROPERTY_REGEXP:RegExp = /\$\{[^}]+\}/g;

		/** Regular expression to resolve property placeholder with the pattern $(...) */
		public static const PROPERTY_REGEXP2:RegExp = /\$\([^)]+\)/g;

		/**
		 * Creates a new <code>PropertyPlaceholderConfigurer</code> instance.
		 */
		public function PropertyPlaceholderConfigurerFactoryPostProcessor(orderPosition:int) {
			super(orderPosition);
		}

		private var _ignoreUnresolvablePlaceholders:Boolean = false;

		/** The object factory that this post processor operates on. */
		private var _objectFactory:IObjectFactory;
		private var _properties:IPropertiesProvider;

		/**
		 * @private
		 */
		public function get ignoreUnresolvablePlaceholders():Boolean {
			return _ignoreUnresolvablePlaceholders;
		}

		/**
		 * Sets whether to ignore unresolvable placeholders. Default is "false":
		 * An exception will be thrown if a placeholder cannot be resolved.
		 */
		public function set ignoreUnresolvablePlaceholders(value:Boolean):void {
			if (value != _ignoreUnresolvablePlaceholders) {
				_ignoreUnresolvablePlaceholders = value;
			}
		}

		public function get properties():IPropertiesProvider {
			return _properties;
		}

		public function set properties(value:IPropertiesProvider):void {
			_properties = value;
		}

		override public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation {
			logger.debug("Post processing object factory {0}, ignore unresolvable placeholders set to '{1}'", [objectFactory, _ignoreUnresolvablePlaceholders]);
			_objectFactory = objectFactory;

			var resolver:IPropertyPlaceholderResolver = new PropertyPlaceholderResolver(null, _properties, _ignoreUnresolvablePlaceholders);

			for each (var objectName:String in objectFactory.objectDefinitionRegistry.objectDefinitionNames) {
				resolvePropertyPlaceholdersForObjectName(resolver, objectName);
			}

			for each (objectName in objectFactory.cache.getCachedNames()) {
				resolvePropertyPlaceholdersForInstance(resolver, objectFactory.cache.getInstance(objectName));
			}

			return null;
		}

		public function resolveObjectDefinitionProperty(resolver:IPropertyPlaceholderResolver, objectDefinition:IObjectDefinition, propertyName:String):void {
			if (!StringUtils.hasText(objectDefinition[propertyName])) {
				return;
			}
			logger.debug("Resolving property placeholder in property '{0}' of the object definition", [propertyName]);
			objectDefinition[propertyName] = resolver.resolvePropertyPlaceholders(objectDefinition[propertyName], PROPERTY_REGEXP);
			objectDefinition[propertyName] = resolver.resolvePropertyPlaceholders(objectDefinition[propertyName], PROPERTY_REGEXP2);
			logger.debug("Result of resolving property placeholder in property '{0}': '{1}'", [propertyName, objectDefinition[propertyName]]);
		}

		private function resolvePropertyPlaceholdersForInstance(resolver:IPropertyPlaceholderResolver, instance:Object):void {
			if ((!resolver && !instance) || (instance is Class)) {
				return;
			}
			logger.debug("Resolving property placeholders in instance '{0}'", [instance]);
			if (instance is Array) {
				logger.debug("Instance '{0}' is an array, checking to see if any items are strings and attempting to resolve possible placeholders.", [instance]);
				var array:Array = instance as Array;
				var numItems:uint = array.length;
				for (var i:int = 0; i < numItems; i++) {
					if ((array[i] is String) && (StringUtils.hasText(array[i]))) {
						logger.debug("Item '{0}' is a String, attempting to resolve placeholders...", [array[i]]);
						array[i] = resolver.resolvePropertyPlaceholders(array[i], PROPERTY_REGEXP);
						array[i] = resolver.resolvePropertyPlaceholders(array[i], PROPERTY_REGEXP2);
						logger.debug("Result of placeholder resolving: '{0}'", [array[i]]);
					}
				}
			} else if (!ObjectUtils.isSimple(instance)) {
				logger.debug("Instance '{0}' is a complex type, attempting to resolve possible placeholder in its properties.", [instance]);
				var type:Type = Type.forInstance(instance, _objectFactory.applicationDomain);
				var ns:String = "";
				var qname:QName;
				var prefix:String;
				for each (var property:Accessor in type.accessors) {
					if ((property) && (property.type) && (property.type.clazz == String) && (property.writeable && property.readable)) {
						ns = StringUtils.hasText(property.namespaceURI) ? property.namespaceURI : "";
						prefix = StringUtils.hasText(ns) ? null : "";
						qname = new QName(new Namespace(prefix, ns), property.name);
						try {
							if (StringUtils.hasText(instance[qname])) {
								logger.debug("Accessor '{0}' is of type String, its value is '{1}', attempting to resolve placeholders...", [property.name, instance[qname]]);
								instance[qname] = resolver.resolvePropertyPlaceholders(instance[qname], PROPERTY_REGEXP);
								instance[qname] = resolver.resolvePropertyPlaceholders(instance[qname], PROPERTY_REGEXP2);
								logger.debug("Result of placeholder resolving in accessor '{0}': '{1}'", [property.name, instance[qname]]);
							}
						} catch (e:Error) {
							logger.warn("Accessor '{0}' could not be resolved: {1}", [property.name, e.message]);
						}
					}
				}
				for each (var variable:Variable in type.variables) {
					if ((variable) && (variable.type) && (variable.type.clazz == String)) {
						ns = StringUtils.hasText(variable.namespaceURI) ? variable.namespaceURI : "";
						prefix = StringUtils.hasText(ns) ? null : "";
						qname = new QName(new Namespace(prefix, ns), variable.name);
						try {
							if (StringUtils.hasText(instance[qname])) {
								logger.debug("Variable '{0}' is of type String, its value is '{1}', attempting to resolve placeholders...", [variable.name, instance[qname]]);
								instance[qname] = resolver.resolvePropertyPlaceholders(instance[qname], PROPERTY_REGEXP);
								instance[qname] = resolver.resolvePropertyPlaceholders(instance[qname], PROPERTY_REGEXP2);
								logger.debug("Result of placeholder resolving in variable '{0}': '{1}'", [variable.name, instance[qname]]);
							}
						} catch (e:Error) {
							logger.warn("Property '{0}' could not be resolved: {1}", [variable.name, e.message]);
						}
					}
				}
			}
		}

		private function resolvePropertyPlaceholdersForObjectName(resolver:IPropertyPlaceholderResolver, objectName:String):void {
			logger.debug("Resolving property placeholders in object definition '{0}'", [objectName]);
			var objectDefinition:IObjectDefinition = _objectFactory.getObjectDefinition(objectName);
			var ref:RuntimeObjectReference;
			var resolvedObjectName:String;

			var i:int = 0;
			for each (var constructorArg:* in objectDefinition.constructorArguments) {
				if (constructorArg is String) {
					logger.debug("Resolving property placeholders in String constructor arg '{0}'", [constructorArg]);
					constructorArg = resolver.resolvePropertyPlaceholders(constructorArg, PROPERTY_REGEXP);
					objectDefinition.constructorArguments[i] = resolver.resolvePropertyPlaceholders(constructorArg, PROPERTY_REGEXP2);
					logger.debug("Result of placeholder resolving in String constructor arg: '{0}'", [objectDefinition.constructorArguments[i]]);
				} else if (constructorArg is RuntimeObjectReference) {
					logger.debug("Constructor argument is a RuntimeObjectReference, attempting to resolve placeholders in its objectName property.");
					ref = RuntimeObjectReference(constructorArg);
					resolvedObjectName = null;
					if (ref.objectName.match(PROPERTY_REGEXP).length > 0) {
						resolvedObjectName = resolver.resolvePropertyPlaceholders(ref.objectName, PROPERTY_REGEXP);
					} else if (ref.objectName.match(PROPERTY_REGEXP2).length > 0) {
						resolvedObjectName = resolver.resolvePropertyPlaceholders(ref.objectName, PROPERTY_REGEXP2);
					}
					if (resolvedObjectName != null) {
						objectDefinition.constructorArguments.arguments[i] = new RuntimeObjectReference(resolvedObjectName);
						logger.debug("Result of placeholder resolving in objectName property: '{0}'", [resolvedObjectName]);
					}
				}
				i++;
			}

			for each (var propDef:PropertyDefinition in objectDefinition.properties) {
				logger.debug("Resolving property placeholders in property '{0}'", [propDef]);
				if (propDef.value is String) {
					logger.debug("Resolving property placeholders in property '{0}' with value '{1}'", [propDef.name, propDef.value]);
					propDef.value = resolver.resolvePropertyPlaceholders(propDef.value, PROPERTY_REGEXP);
					propDef.value = resolver.resolvePropertyPlaceholders(propDef.value, PROPERTY_REGEXP2);
					logger.debug("Result of resolving property placeholders in property '{0}': '{1}'", [propDef.name, propDef.value]);
				} else if (propDef.value is RuntimeObjectReference) {
					logger.debug("Property definition value is a RuntimeObjectReference, attempting to resolve placeholders in its objectName property.");
					ref = RuntimeObjectReference(propDef.value);
					resolvedObjectName = null;
					if (ref.objectName.match(PROPERTY_REGEXP).length > 0) {
						resolvedObjectName = resolver.resolvePropertyPlaceholders(ref.objectName, PROPERTY_REGEXP);
					} else if (ref.objectName.match(PROPERTY_REGEXP2).length > 0) {
						resolvedObjectName = resolver.resolvePropertyPlaceholders(ref.objectName, PROPERTY_REGEXP2);
					}
					if (resolvedObjectName != null) {
						propDef.value = new RuntimeObjectReference(resolvedObjectName);
						logger.debug("Result of placeholder resolving in objectName property: '{0}'", [resolvedObjectName]);
					}
				}
			}

			// resolve method invocations
			for each (var mi:MethodInvocation in objectDefinition.methodInvocations) {
				i = 0;
				for each (var arg:Object in mi.arguments) {
					if (arg is String) {
						logger.debug("Resolving property placeholders in String method invocation arg arg '{0}'", [arg]);
						mi.arguments[i] = resolver.resolvePropertyPlaceholders(String(arg), PROPERTY_REGEXP);
						mi.arguments[i] = resolver.resolvePropertyPlaceholders(String(arg), PROPERTY_REGEXP2);
						logger.debug("Result of placeholder resolving in String constructor arg: '{0}'", [mi.arguments[i]]);
					} else if (arg is RuntimeObjectReference) {
						logger.debug("Method invocation arg is a RuntimeObjectReference, attempting to resolve placeholders in its objectName property.");
						ref = RuntimeObjectReference(arg);
						resolvedObjectName = null;
						if (ref.objectName.match(PROPERTY_REGEXP).length > 0) {
							resolvedObjectName = resolver.resolvePropertyPlaceholders(ref.objectName, PROPERTY_REGEXP);
						} else if (ref.objectName.match(PROPERTY_REGEXP2).length > 0) {
							resolvedObjectName = resolver.resolvePropertyPlaceholders(ref.objectName, PROPERTY_REGEXP2);
						}
						if (resolvedObjectName != null) {
							mi.arguments[i] = new RuntimeObjectReference(resolvedObjectName);
							logger.debug("Result of placeholder resolving in objectName property: '{0}'", [resolvedObjectName]);
						}
					}
					i++;
				}
			}

			i = 0;
			for each (var dep:String in objectDefinition.dependsOn) {
				logger.debug("Resolving property placeholders in depends-on value: '{0}'", [objectDefinition.dependsOn[i]]);
				objectDefinition.dependsOn[i] = resolver.resolvePropertyPlaceholders(objectDefinition.dependsOn[i], PROPERTY_REGEXP);
				objectDefinition.dependsOn[i] = resolver.resolvePropertyPlaceholders(objectDefinition.dependsOn[i], PROPERTY_REGEXP2);
				logger.debug("Result of resolving property placeholders in depends-on value: '{0}'", [objectDefinition.dependsOn[i]]);
				i++;
			}

			resolveObjectDefinitionProperty(resolver, objectDefinition, DESTROY_METHOD_FIELD_NAME);
			resolveObjectDefinitionProperty(resolver, objectDefinition, FACTORY_METHOD_FIELD_NAME);
			resolveObjectDefinitionProperty(resolver, objectDefinition, FACTORY_OBJECT_NAME_FIELD_NAME);
			resolveObjectDefinitionProperty(resolver, objectDefinition, INIT_METHOD_FIELD_NAME);
			resolveObjectDefinitionProperty(resolver, objectDefinition, PARENT_NAME_FIELD_NAME);

			// resolve result of factory method
			if (objectDefinition.factoryObjectName && objectDefinition.factoryMethod && objectDefinition.isSingleton) {
				resolvePropertyPlaceholdersForInstance(resolver, _objectFactory.getObject(objectName));
			}
		}
	}
}
