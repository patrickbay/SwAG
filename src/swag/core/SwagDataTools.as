package swag.core {	
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import swag.core.SwagDispatcher;
	import swag.interfaces.core.ISwagDataTools;
	/**
	 * The <code>SwagDataTools</code> class contains a variety of static methods and properties to assist with a variety
	 * of data modification and verification tasks. For the most part, methods and properties can be accessed directly
	 * without first creating an instance of the <code>SwagDataTools</code> class. 
	 * 
	 * @author Patrick Bay
	 */
	public final class SwagDataTools extends SwagDispatcher implements ISwagDataTools {
		
		/**
		 * Contains the range of all numeric ASCII characters that can be used with various string operations. 
		 */		
		public static const NUMBERS_RANGE:String="0123456789";
		/**
		 * Contains the range of all lowercase ASCII characters that can be used with various string operations. 
		 */		
		public static const LOWERCASE_RANGE:String="abcdefghijklmnopqrstuvwxyz";
		/**
		 * Contains the range of all uppercase ASCII characters that can be used with various string operations. 
		 */		
		public static const UPPERCASE_RANGE:String="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		/**
		 * Contains the range of all puncuation ASCII characters that can be used with various string operations. 
		 */		
		public static const PUNCTUATION_RANGE:String="~`!@#$%^&*()+-={}[]|:\";'<>,.?";
		
		/**
		 * Contains the range of all separator ASCII characters (space, hyphen, underscore, back slash, forward slash), 
		 * that can be used with various string operations. 
		 */
		public static const SEPARATOR_RANGE:String=" -_\\/";
		
		/**
		 * 
		 * Verifies the supplied <code>property</code> against the supplied <code>type</code>.
		 * 
		 * @param property The property (variable, object, reference, etc.), to check.
		 * @param type The type to check against. If this is an object reference, it is used directly. If this is a string,
		 * a <code>getDefinitionByType</code> call is made to attempt to retrieve the object type first.
		 * @param canBeNull If <em>true</em>, the evaluation will still return <code>true</code> even if the 
		 * supplied <code>property</code> is null. If <em>false</em>, the <code>property</code> must contain a value (i.e. be non-null). 
		 * 
		 * @return <em>true</em> if the supplied <code>property</code> parameter matches the supplied <code>type</code>
		 * parameter, or <em>false</em> if the type doesn't match, or the <code>property</code> is null and <code>canBeNull</code> 
		 * is false.
		 * 
		 */
		public static function isType(property:*=null, type:*=null, canBeNull:Boolean=false):Boolean {
			if ((property==null) && (canBeNull==false)) {
				return (false)
			}//if
			if ((type==null) && (property==null)) {
				return (true);
			}//if
			if (type is String) {
				try {
					var typeClass:Class=getDefinitionByName(type) as Class;
					if (property is typeClass) {
						return (true);
					}//if
				} catch (e:ReferenceError) {
					return (false);
				}//catch
			} else {
				if (property is type) {
					return (true);
				}//if
			}//else
			return (false);
		}//isType
		
		/**
		 * Verifies that the supplied property has data -- is not <em>undefined</em> and not <em>null</em>.
		 *  
		 * @param args The property to check.
		 * 
		 * @return <em>True</em> if the supplied <code>property</code> is not <em>undefined</em> and not <em>null</em>, otherwise
		 * <em>false</em> is returned.
		 * 
		 */
		public static function hasData(... args):Boolean {			
			if (args[0]==undefined) {
				return (false);
			}//if
			if (args[0]==null) {
				return (false);
			}//if
			return (true);
		}//hasData
		
		/**
		 * Verifies that the supplied parameter is one of the valid ActionScript 3 XML objects, or a string that can be converted to a valid XML
		 * object.
		 *  
		 * @param args The first parameter is the argument to validate as either <code>XML</code>, <code>XMLList</code>, <code>XMLDocument</code>, 
		 * <code>XMLNode</code>, or a string with valid XML data if the optional second parameter is <em>true</em> (default is <em>false</em>).
		 * 
		 * @return <em>True</em> if the supplied argument is a valid <code>XML</code>, <code>XMLList</code>, <code>XMLDocument</code>, or 
		 * <code>XMLNode</code> object, or if it's a string that can be converted used as a valid XML object (if the second parameter is <em>true</em>). 
		 * <em>False</em> is returned when none of these conditions are met. 
		 * 
		 */
		public static function isXML(... args):Boolean {
			if (args == null) {				
				return (false);
			}//if
			if (args[0] == undefined) {				
				return (false);
			}//if
			if ((args[0] is String) && (args[1]==true)){
				var localString:String=new String(args[0]);
				try {					
					var testXML:XML=new XML(localString);
					return (true);
				} catch (e:TypeError) {					
					return (false);
				}//catch				
			}//if
			if ((args[0] is XML) || (args[0] is XMLList) || (args[0] is XMLDocument) || (args[0] is XMLNode)) {				
				return (true);
			}//if			
			return (false);
		}//isXML
		
		/**
		 * 
		 * Scans <code>sourceString</code> for occurances of <code>searchString</code> and returns true if found.
		 * <p>Optionally, a case-insensitive search may be performed between the two strings.</p>
		 *  
		 * @param sourceString The string, or strings, to search through. If this parameter is a string, it is used as is. If the parameter is an
		 * array, the contents of the array are analyzed one by one wherever possible. If the parameter is of a type that can be converted to a string
		 * (XML, for example), a conversion will be attempted.
		 * @param searchString The string to find within <code>sourceString</code>.
		 * @param caseSensitive If <em>true</em>, a case-insensitive search is performed, otherwise the strings must match exactly.
		 * 
		 * @return True if the <code>searchString</code> could be found within the <code>sourceString</code>. <em>False</em> is returned if
		 * <code>sourceString</code> or <code>searchString</code> are <em>null</em>, or are of a type that can't be analyzed.		 
		 * 
		 */
		public static function stringContains(sourceString:*, searchString:String, caseSensitive:Boolean=true):Boolean {
			if ((sourceString==null) || (searchString==null)) {
				return (false);
			}//if			
			if (sourceString is String) {
				var localSourceString:String=new String(sourceString);
				var localSearchString:String=new String(searchString);
				if (!caseSensitive) {
					localSourceString=localSourceString.toLowerCase();
					localSearchString=localSearchString.toLowerCase();
				}//if
				if (localSourceString.indexOf(localSearchString)>-1) {
					return (true);
				} else {
					return (false);
				}//else
			} else if (sourceString is Array) {
				localSearchString=new String(searchString);
				if (!caseSensitive) {					
					localSearchString=localSearchString.toLowerCase();
				}//if
				for (var count:uint=0; count<sourceString.length; count++) {
					localSourceString=new String(sourceString[count] as String);
					if (!caseSensitive) {
						localSourceString=localSourceString.toLowerCase();						
					}//if
					if (localSourceString.indexOf(localSearchString)>-1) {
						return (true);
					} else {
						return (false);
					}//else
				}//for
			} else if ((sourceString is XML) || (sourceString is XMLNode)) {
				localSourceString=new String(sourceString.toString());
				localSearchString=new String(searchString);
				if (!caseSensitive) {
					localSourceString=localSourceString.toLowerCase();
					localSearchString=localSearchString.toLowerCase();
				}//if
				if (localSourceString.indexOf(localSearchString)>-1) {
					return (true);
				} else {
					return (false);
				}//else
			} else {
				return (false);
			}//else
			return (false);
		}//stringContains
		
		/**
		 * Strips the leading characters from an input string and returns the newly reformatted string. As soon as a non-stripped
		 * character is encountered, the remainder of the string is left intact.
		 *  
		 * @param inputString The string from which to strip the leading characters. The contents of this parameter are copied
		 * so the original data is not affected.
		 * @param stripChars The character or characters to strip from <code>inputString</code>. Multiple characters may be included
		 * as a string or, alternately, this parameter may be an array of strings.
		 * 
		 * @return A newly created copy of <code>inputString</code> with all the specified characters stripped out.
		 * 
		 * @example The following example strips all punctuation from the beginning of the given input string:
		 * <listing version="3.0">
		 * var sourceString:String = "$-=This should not have puncutation at the beginning.";
		 * var strippedString:String = SwagDataTools.stripLeadingChars(sourceString, SwagDataTools.PUNCTUATION_RANGE);
		 * trace (strippedString); //"This should not have puncutation at the beginning."
		 * </listing>
		 * 
		 */
		public static function stripLeadingChars(inputString:String, stripChars:*=" "):String {
			if (inputString==null) {
				return(new String());
			}//if
			if ((inputString=="") || (inputString.length==0)) {
				return(new String());
			}//if
			if (stripChars==null) {
				return (inputString);
			}//if
			var localStripChars:String=new String();
			if (stripChars is Array) {
				for (var count:uint=0; count<stripChars.length; count++) {
					localStripChars.concat(String(stripChars[count] as String));
				}//for	
			} else if (stripChars is String) {
				localStripChars=new String(stripChars);
			} else {
				return (inputString);
			}//else
			if ((localStripChars=="") || (localStripChars.length==0)) {
				return (inputString);
			}//if
			var localInputString:String=new String(inputString);
			var returnString:String=new String();
			var leadStripped:Boolean=false;
			for (var charCount:Number=0; charCount<localInputString.length; charCount++) {
				var currentChar:String=localInputString.charAt(charCount);				
				if ((localStripChars.indexOf(currentChar)<0) || (leadStripped)) {					
					returnString=returnString.concat(currentChar);	
					leadStripped=true;
				}//if
			}//for
			return (returnString);
		}//stripLeadingChars
		
		/**
		 * Strips the trailing (end) characters from an input string and returns the newly reformatted string. As soon as a non-stripped
		 * character is encountered, the remainder of the string is left intact.
		 *  
		 * @param inputString The string from which to strip the trailing characters. The contents of this parameter are copied
		 * so the original data is not affected.
		 * @param stripChars The character or characters to strip from <code>inputString</code>. Multiple characters may be included
		 * as a string or, alternately, this parameter may be an array of strings.
		 * 
		 * @return A newly created copy of <code>inputString</code> with all the specified characters stripped out.
		 * 
		 * @example The following example strips all lowercase letters and separators from the end of the given input string:
		 * <listing version="3.0">
		 * var sourceString:String = "IF YOU'RE NOT SHOUTING you will not be heard";
		 * var strippedString:String = SwagDataTools.stripTrailingChars(sourceString, SwagDataTools.LOWERCASE_RANGE + SwagDataTools.SEPARATOR_RANGE);
		 * trace (strippedString); //"IF YOU'RE NOT SHOUTING"
		 * </listing>
		 * 
		 */
		public static function stripTrailingChars(inputString:String, stripChars:*=" "):String {
			if (inputString==null) {
				return(new String());
			}//if
			if ((inputString=="") || (inputString.length==0)) {
				return(new String());
			}//if
			if (stripChars==null) {
				return (inputString);
			}//if
			var localStripChars:String=new String();
			if (stripChars is Array) {
				for (var count:uint=0; count<stripChars.length; count++) {
					localStripChars.concat(String(stripChars[count] as String));
				}//for	
			} else if (stripChars is String) {
				localStripChars=new String(stripChars);
			} else {
				return (inputString);
			}//else
			if ((localStripChars=="") || (localStripChars.length==0)) {
				return (inputString);
			}//if
			var localInputString:String=new String(inputString);
			var returnString:String=new String();
			var trailStripped:Boolean=false;
			for (var charCount:Number=(localInputString.length-1); charCount>=0; charCount--) {
				var currentChar:String=localInputString.charAt(charCount);
				if ((localStripChars.indexOf(currentChar)<0) || (trailStripped)) {
					returnString=currentChar+returnString;	
					trailStripped=true;
				}//if
			}//for
			return (returnString);
		}//stripTrailingChars
		
		/**
		 * Strips the outside (leading and trailing) characters from an input string and returns the newly reformatted string. As soon as a 
		 * non-stripped character is encountered from both directions, the remaining middle of the string is left intact.
		 *  
		 * @param inputString The string from which to strip the outside characters. The contents of this parameter are copied
		 * so the original data is not affected.
		 * @param stripChars The character or characters to strip from <code>inputString</code>. Multiple characters may be included
		 * as a string or, alternately, this parameter may be an array of strings.
		 * 
		 * @return A newly created copy of <code>inputString</code> with all the specified characters stripped out.
		 * 
		 * @example The following example strips all punctuation and separators from the beginning and end of the given input string:
		 * <listing version="3.0">
		 * var sourceString:String = "*** No extra stuff here! ***";
		 * var strippedString:String = SwagDataTools.stripOutsideChars(sourceString, SwagDataTools.PUNCTUATION_RANGE + SwagDataTools.SEPARATOR_RANGE);
		 * trace (strippedString); //"No extra stuff here"
		 * </listing>
		 * 
		 */
		public static function stripOutsideChars(inputString:String, stripChars:*):String {
			var returnString:String=new String();
			returnString=stripLeadingChars(inputString, stripChars);
			returnString=stripTrailingChars(returnString, stripChars);
			return (returnString);
		}//stripOutsideChars
		
		/**
		 * Strips all of the specified characters from an input string and returns the newly reformatted string.
		 *  
		 * <p>This method affects the whole string unlike the <code>stripLeadingChars</code>, <code>stripTrailingChars</code>, and
		 * <code>stripOutsideChars</code> methods.</p>
		 *  
		 * @param inputString The string from which to strip the characters. The contents of this parameter are copied
		 * so the original data is not affected.
		 * @param stripChars The character or characters to strip from <code>inputString</code>. Multiple characters may be included
		 * as a string or, alternately, this parameter may be an array of strings.
		 * 
		 * @return A newly created copy of <code>inputString</code> with all the specified characters stripped out.
		 * 
		 * @example The following example strips the uppercase letters from the input string:
		 * <listing version="3.0">
		 * var sourceString:String = "EeVvEeRrYy OoTtHhEeRr LlEeTtTtEeRr IiSs OoKkAaYy";
		 * var strippedString:String = SwagDataTools.stripChars(sourceString, SwagDataTools.UPPERCASE_RANGE);
		 * trace (strippedString); //"every other letter is okay"
		 * </listing>
		 * 
		 */
		public static function stripChars(inputString:String, stripChars:*=" "):String {
			if (inputString==null) {
				return(new String());
			}//if
			if ((inputString=="") || (inputString.length==0)) {
				return(new String());
			}//if
			if (stripChars==null) {
				return (inputString);
			}//if
			var localStripChars:String=new String();
			if (stripChars is Array) {
				for (var count:uint=0; count<stripChars.length; count++) {
					localStripChars.concat(String(stripChars[count] as String));
				}//for	
			} else if (stripChars is String) {
				localStripChars=new String(stripChars);
			} else {
				return (inputString);
			}//else
			if ((localStripChars=="") || (localStripChars.length==0)) {
				return (inputString);
			}//if
			var localInputString:String=new String(inputString);
			var returnString:String=new String();			
			for (var charCount:Number=(localInputString.length-1); charCount>=0; charCount--) {
				var currentChar:String=localInputString.charAt(charCount);
				if (localStripChars.indexOf(currentChar)<0) {
					returnString=currentChar+returnString;						
				}//if
			}//for
			return (returnString);
		}//stripChars
		
		/**
		 * Replaces all occurances of a specified string within a string with another string.
		 *  
		 * @param sourceString The string within which to perform the replacement. The contents of the string are copied so that
		 * the original string is not affected.
		 * @param insertString The string to replace within <code>sourceString</code>.
		 * @param patternString The pattern to replace with <code>insertString</code> within the <code>sourceString</code>.
		 * 
		 * @return A copy of the <code>sourceString</code> with any occurances of <code>patternString</code> replaced with 
		 * <code>insertString</code>.
		 * 
		 * @example The following example replaces all occurances of "%name%" with "Bob".
		 * 
		 * <listing version="3.0">
		 * var sourceString:String = "%name% is an excellent developer, and %name% is also a friend.";
		 * var resultString:String = SwagDataTools.replaceString(sourceString, "Bob", "%name%");
		 * trace (resultString); //"Bob is an excellent developer, and Bob is also a friend."
		 * </listing> 
		 * 
		 */
		public static function replaceString(sourceString:String, insertString:String, patternString:String):String {
			var localSourceString:String=new String(sourceString);
			var replaceSplit:Array=localSourceString.split(patternString);
			var returnString:String=replaceSplit.join(insertString);
			return (returnString);
		}//replaceString
		
		/**
		 * Parses / splits a string containing software version information (for example, "3.2.1 b"), into native (numeric / boolean) values.
		 * 
		 * <p>The format of a typical version string is: <strong>majorVersion.minorVersion.buildNumber.internalBuildNumber a / b</strong>, where
		 * "a" signifies an alpha version, and "b" is a beta version. If both "a" and "b" appear in the version information, it's considered
		 * to represent an alpha version.</p>
		 *  
		 * @param versionString The version string to parse. Currently, four levels of revision are supported (i.e. four
		 * separators), as well as optional "b" or "a" on the end to denote beta or alpha versions.
		 * @param separator The separator character between the version numbers (for example, ".").
		 * 
		 * @return An object containing the following properties:
		 * <ul>
		 * <li>major (<code>int</code>) - The parsed major value from the version string.</li>
		 * <li>minor (<code>int</code>) - The parsed minor value from the version string.</li> 
		 * <li>build (<code>int</code>) - The parsed build value from the version string.</li>
		 * <li>internalBuild (<code>int</code>) - The parsed internal build value from the version string.</li>
		 * <li>alpha (<code>Boolean</code>) - The parsed alpha notation setting from the version string.</li>
		 * <li>beta (<code>Boolean</code>) - The parsed beta notation setting from the version string (if <code>alpha</code> 
		 * is <em>true</em>, <code>beta</code> will always be false).</li>
		 * </ul>
		 * Any numeric version values omitted will be returned as <em>-1</em>, and boolean values as <em>false</em>.
		 * 
		 * @see flash.system.Capabilities#version
		 */
		public static function parseVersionString(versionString:String, separator:String="."):Object {			
			var returnObject:Object=new Object();
			returnObject.major=new int(-1);
			returnObject.minor=new int(-1);
			returnObject.build=new int(-1);
			returnObject.internalBuild=new int(-1);
			returnObject.alpha=new Boolean();
			returnObject.alpha=false;
			returnObject.beta=new Boolean();
			returnObject.beta=false;
			if (versionString==null) {
				return (returnObject);
			}//if
			var localVersionString:String=new String(versionString);
			localVersionString=stripOutsideChars(localVersionString, " ");
			if ((localVersionString=="") || ((localVersionString.length==0))) {
				return (returnObject);
			}//if 
			var versionParts:Array=localVersionString.split(separator);
			if (hasData(versionParts[0])) {
				returnObject.major=int(versionParts[0] as String);
			}//if
			if (hasData(versionParts[1])) {
				returnObject.minor=int(versionParts[1] as String);
			}//if
			if (hasData(versionParts[2])) {
				returnObject.build=int(versionParts[2] as String);
			}//if
			if (hasData(versionParts[3])) {
				var finalPart:String=new String(versionParts[3] as String);
				var stripCharacters:String=SwagDataTools.LOWERCASE_RANGE+SwagDataTools.UPPERCASE_RANGE
										+SwagDataTools.PUNCTUATION_RANGE+SwagDataTools.SEPARATOR_RANGE;
				returnObject.internalBuild=int(stripChars(finalPart, stripCharacters));						
			}//if			
			if (stringContains(localVersionString, "a", false)) {
				returnObject.alpha=true;
			} else if (stringContains(localVersionString, "b", false)) {
				returnObject.beta=true;
			}//else if
			return (returnObject);
		}//parseVersionString
		
		/**
		 * Converts the input Number / int / uint to its binary string representation.
		 *  
		 * @param inputNumber The number (Number / int / uint) to convert to a binary string representation.
		 * @param bits The number of bits to process in the <code>inputNumber</code>. Note that if using a 
		 * <code>bits</code> value that is less than the number of bits found in the <code>inputNumber</code>
		 * (typically 32 or 64), the resulting binary value won't be equal to the original decimal value since
		 * some of the information is necessarily lost.
		 * 
		 * @return The binary representation of the input number, accurate to the number of bits specified.
		 * 
		 * @see fromBinaryString()
		 * 
		 */
		public static function toBinaryString(inputNumber:*, bits:uint=32):String {
			if (((inputNumber is uint) || (inputNumber is int) || (inputNumber is Number))==false) {
				return (new String());
			}//if
			if (bits==0) {
				return (new String());
			}//if
			var returnString:String=new String();
			var currentDigit:String;
			for (var count:uint=0; count<bits; count++) {						
				currentDigit=String((inputNumber & (1 << count)) >>> count);
				returnString=currentDigit+returnString;				
			}//for
			return (returnString);
		}//toBinaryString
		
		/**
		 * Converts the input binary string sequence to a native numeric type.
		 *  
		 * @param inputString The string to convert to a native numeric type.
		 * @param returnType The numeric type to convert the <code>inputString</code> to. Valid types are 
		 * <code>Number</code>, <code>uint</code>, and <code>int</code>.
		 * 
		 * @return The numeric value represented by the binary <code>inputString</code>, of the type specified
		 * by <code>returnType</code>. If the <code>returnType</code> specified is not a valid numeric type,
		 * or the <code>inputString</code> contains invalid digits (not 0 or 1), <em>null</em> is returned.
		 * 
		 * @see toBinaryString()
		 * 
		 */
		public static function fromBinaryString(inputString:String, returnType:Class):* {			
			if ((returnType!=Number) && (returnType!=uint) && (returnType!=int)) {				
				return (null);
			}//else
			var returnValue:*;
			var localInputString:String=new String(inputString);
			localInputString=stripOutsideChars(localInputString, SwagDataTools.SEPARATOR_RANGE);			
			if ((localInputString=="") || (localInputString.length==0)) {
				returnValue=0;
				return (returnValue);
			}//if			
			for (var count:int=0; count<localInputString.length; count++) {
				var currentChar:String=localInputString.charAt(count);				
				if (currentChar=="1") {
					returnValue=returnValue | (1 << (localInputString.length-count-1));
				} else if (currentChar=="0") {
					returnValue=returnValue | (0 << (localInputString.length-count-1));
				} else {
					//Return null if an unexpected character is encountered.
					return (null);
				}//else
			}//for
			if (returnType==int) {
				returnValue=int(returnValue);	
			} else if (returnType==uint) {
				returnValue=uint(returnValue);
			} else {
				returnValue=Number(returnValue);
			}//else
			return (returnValue);
		}//fromBinaryString

		/**
		 * Retrieves an ordered list (<code>Array</code>), of the parameters for the specified method.
		 * <p>The returned list will be an array of classes / types that can be used to determine what data type(s)
		 * the supplied method supports.</p> 
		 * 
		 * @param method The method for which to retrieve the list of parameters.
		 * @param container The containing object in which the <code>method</code> resides. Without this reference it's
		 * not possible to determine the specific method properties (this call will fail).
		 * 
		 * @return An ordered <code>Array</code> of classes / types, in the order in which they appear, of the specified
		 * method, or <em>null</em> if there was a problem retrieving this information. For a method with no parameters,
		 * an empty <code>Array</code> object is returned. If the <code>container</code> property is <em>null</em> or
		 * doesn't contain the referenced <code>method</code>, <em>null</em> is returned. If a parameter is a wildcard (&#42;),
		 * a <em>null</em> value is stored at the associated index location within the returned array. The <code>... rest</code>
		 * notation is not considered a parameter since, technically, the method does not expect any data and no type is declared. 
		 * <p><strong>Note: Unlike the index values returned by the <code>describeType</code> method, the returned parameter list 
		 * is 0-indexed (i.e. always 1 less than in the XML description).</strong></p>
		 * 
		 */		
		public static function getMethodParameters(method:Function, container:*):Array {
			if (method==null) {
				return (null);
			}//if
			if (container==null) {
				return (null);
			}//if
			var returnArray:Array=new Array();
			var containerInfo:XML=describeType(container) as XML;
			if (SwagDataTools.hasData(containerInfo.method)==false) {
				return (null);
			}//if
			var methods:XMLList=containerInfo.method as XMLList;				
			for (var count:uint=0; count<methods.length(); count++) {
				var currentMethodNode:XML=methods[count] as XML;				
				if (SwagDataTools.hasData(currentMethodNode.@name)) {
					var methodName:String=new String(currentMethodNode.@name);
					if (container[methodName]===method) {						
						if (SwagDataTools.hasData(currentMethodNode.parameter)) {
							var parameterIndex:uint=0;
							var parameterNodes:XMLList=currentMethodNode.parameter as XMLList;
							for (var count2:uint=0; count2<parameterNodes.length(); count2++) {
								var currentParameterNode:XML=parameterNodes[count2] as XML;
								if (SwagDataTools.hasData(currentParameterNode.@index)) {
									parameterIndex=uint(String(currentParameterNode.@index));
									parameterIndex-=1; //parameters are 1-indexed
								}//if
								if (SwagDataTools.hasData(currentParameterNode.@type)) {
									var typeString:String=new String(currentParameterNode.@type);
									if (typeString=="*") {
										returnArray[parameterIndex]=null;
									} else {
										try {
											typeString=SwagDataTools.replaceString(typeString, ".", "::");											
											var typeClass:Class=getDefinitionByName(typeString) as Class;
											if (typeClass!=null) {
												returnArray[parameterIndex]=typeClass;		
											}//if
										} catch (e:*) {											
										}//catch
									}//else
								}//if
								parameterIndex++;
							}//for
						}//if
					}//if
				}//if
			}//for
			return (returnArray);
		}//getMethodParameters
		
	}//SwagDataTools class
	
}//package