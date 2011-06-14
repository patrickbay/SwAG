package swag.core.instances {
	
	import swag.core.SwagDispatcher;
	import swag.core.instances.SwagDate;
	import swag.core.instances.SwagTime;
	import swag.events.SwagErrorEvent;
	import swag.events.SwagZipEvent;
	import swag.interfaces.core.instances.ISwagZip;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * Used to access / extract ZIP-formatted data.
	 * <p>This class is heavily dependent on methods of the <code>ByteArray</code> class for both data access and fast 
	 * decompression.</p> 
	 * <p>Because ZIP files may contain nested directories as well as multiple file records, a virtual in-memory mapping
	 * is used to represent the stored of the file. Once this map is created, individual compressed entries may be 
	 * randomly accessed as desired (one of the advantaged of the ZIP format).</p>
	 * <p>This class adheres to the strict ZIP format specification (i.e. the "central directory" record is read and 
	 * analyzed first, followed by individual directory records). As such, future versions of ZIPFile may support recovery 
	 * of partially corrupted ZIP data. However, no compression algorithm other than "deflate" is currently supported 
	 * for compressed data so some records within the ZIP may be inaccessible -- though not corrupted (the format allows 
	 * for other compression methods than deflate).</p>
	 * <p>Other standardized formats such as OpenDocument and Office Open XML may be based on this class.</p>
	 * <p>The flow of events when ZIP file data is assigned is as follows:</p>
	 * <p><strong>ZIP data assigned to internal buffer</strong> -> <strong>header info is parsed</strong> -> 
	 * <strong>directory info is parsed</strong>
	 * <p>Each of these steps is dependent on the previous one so a failure in the chain will cause subequent steps to 
	 * also fail.</p>
	 * <p>Once the header information for the ZIP data is parsed into the <code>header</code> object (getter provided), 
	 * it will contain the following properties:</p>
	 * <p><ul>
	 * <li>diskNumber (<code>uint</code>): The disk number associated with this archive (for multi-disk archives).</li>
	 * <li>directoryDiskNumber (<code>uint</code>): The number of the current disk's directory (for multi-disk archives).</li>
	 * <li>directoryDiskRecords (<code>uint</code>): The total number of directory records across all disks (for multi-disk 
	 * archives).</li>
	 * <li>directoryRecords (<code>uint</code>): The total number of records in the current disk directory (should match the 
	 * number of <code>directory</code> elements once parsed).</li>
	 * <li>directorySize (<code>uint</code>): The size of the directory, in bytes, in the current disk archive.</li>
	 * <li>directoryOffser (<code>uint</code>): The offset, in bytes from the beginning of the ZIP data, of the directory 
	 * data in the current archive.</li>
	 * <li>comment (<code>String</code>): A comment associated with the current ZIP data. May be up to 65,535 characters.</li>
	 * </ul></p>
	 * <p>Once the <code>header</code> is parsed, the <code>directory</code> (getter provided) array is populated sequentially 
	 * with entries from the ZIP directory. For example, <code>directory[0]</code> is the first directory object, 
	 * <code>directory[1]</code> the second, and so on. The number of elements in the <code>directory</code> should match 
	 * the <code>header</code>'s <code>directoryRecords</code> value.</p>.
	 * <p>Each <code>directory</code> object contains the following information:</p>
	 * <p><ul>
	 * <li>compressorID (<code>uint</code>): The ID of the software used to create the ZIP data.</li>
	 * <li>compressorVersion (<code>uint</code>): The minium version of the software required to handle the associated 
	 * ZIP data.</li>
	 * <li>bitFlags (<code>uint</code>): Special attribute flags. Currently, if bit 3 is set (0x04), the CRC32 value is stored as 
	 * 0 in the <code>directory</code> object and will rather be appended as a 12-byte value at the end of the compressed 
	 * data.</li>
	 * <li>compressor (<code>uint</code>): The compression algorithm used for the stored file. Valid values include 
	 * <strong>0 = stored</strong> (no compression), <strong>1 = shrunk</strong>, <strong>2 to 5 = reduced with 
	 * compression factor 1 to 4</strong> (in order), <strong>6 = imploded</strong>, <strong>7 = reserved</strong>, 
	 * <strong>8 = deflated</strong> (most common).</li>
	 * <li>modifiedTime (<code>SwagTime</code>): The last modified time of the file, stored in a <code>SwagTime</code> 
	 * instance.</li>
	 * <li>modifiedDate (<code>SwagDate</code>): The last modified date of the file, stored in a <code>Swagdate</code> 
	 * instance.</li>
	 * <li>CRC32 (<code>uint</code>): The 32-bit cyclical redundancy check value that can be used to verify the integrity 
	 * of the associated data.</li>
	 * <li>compressedSize (<code>uint</code>): The size of the compressed file, in bytes.</li>
	 * <li>uncompressedSize (<code>uint</code>): The size of the uncompressed file, in bytes.</li>
	 * <li>startDisk (<code>uint</code>): The first disk in which the compressed file resides. For multi-disk / multi-part 
	 * ZIPs.</li>
	 * <li>internalAttributes (<code>uint</code>): Internal file attribute bits (exact values unknown).</li>
	 * <li>externalAttributes (<code>uint</code>): Internal file attribute bits (exact values unknown). Most likely these 
	 * refer to file-system settings for the associated file / folder.</li>
	 * <li>headerOffset (<code>uint</code>): The offset to the file header within the ZIP. After the header is the actual 
	 * compressed data. The file header repeats much of the information found in the directory information and can thus be used 
	 * to retrieve data from partially corrupted ZIP files.</li>
	 * <li>fullPath (<code>String</code>): The full, relative path of the file or folder. For example: 
	 * <em>/folder/sub_folder/my_file.txt</em> --or-- <em>no_folder_file.doc</em></li>
	 * <li>extraField (<code>uint</code>): Extra field provided for associating extra information with the compressed data. 
	 * Format unspecified.</li>
	 * <li>comment (<code>String</code>): A comment associated with the individual file or folder.</li>
	 * <li>name (<code>String</code>): The file name portion of the <code>fullPath</code> property. For example, if 
	 * <code>fullPath</code> is <em>some_folder/my_file.txt</em>, the name will be <em>my_file.txt</em>. For folder items, 
	 * this is an empty string.</li>
	 * <li>path (<code>String</code>): The path portion of the <code>fullPath</code> property. For example, if 
	 * <code>fullPath</code> is <em>some_folder/my_file.txt</em>, this path will be <em>some_folder</em>. If a file is 
	 * stored in the root of the ZIP data (not in any folder), this will be an empty string.</li>
	 * <li>pathParts (<code>Array</code>): The path broken up into a numbered array, each element corresponding to a 
	 * deeper level in the folder structure. For example, the path <em>folder_one/folder_two</em> would produce 
	 * <code>pathParts[0]="folder_one"</code> and <code>pathParts[1]="folder_two"</code>. The file name is not included 
	 * in this array since it's not part of the path.</li>
	 * <li>pathDepth (<code>uint</code>): The depth (within folder) at which the file resides. This is equal to the length 
	 * of the <code>pathParts</code> array. For example, the file <em>folder_one/second_folder/my_file.txt</em> is at 
	 * <code>pathDepth</code> 2 (two folders deep).</li> 
	 * <li>type (<code>String</code>): The type of item that this directory entry is. Valid values include "<em>file</em>" 
	 * and "<em>folder</em>".</li>
	 * <li>index (<code>uint</code>): The index value at which this item resides in the <code>directory</code> array.</li>
	 * </ul></p></p>
	 */
	public class SwagZip implements ISwagZip {
				
		/**
		 * @private
		 * The 32-bit signature defined by the ZIP specification. This is used to identify a ZIP
		 * record within the ZIP file. While this is used to verify the offset location of the file, it
		 * should not be used solely for identifying file offsets within the ZIP file as other data
		 * may take the same signature.
		 */
		private static const _fileHeaderSignature:uint=0x04034b50;
		/**
		 * @private
		 * The 32-bit  signature defined by the ZIP specification used to identify a ZIP
		 * record as a directory structure stored at the linear end of the ZIP file. This is then
		 * used to identify a compressed file record within the ZIP file.
		 */
		private static const _directoryHeaderSignature:uint=0x02014b50;
		/**
		 * @private
		 * The 32-bit  signature defined by the ZIP specification used to identify the directory
		 * at the end of the ZIP file. ZIP files are created in the order: 
		 * 		<em>compressed file</em>:<em>compressed file</em>:<em>directory record</em>:
		 * <em>directory record</em>:<em>directory end</em>
		 * In effect, the binary data must be read backwards to obtain the loctions of individual
		 * files and records within the file.
		 */
		private static const _directoryEndHeaderSignature:uint=0x06054b50;
		
		/**
		 * @private
		 * The actual compressed ZIP file data used by this class instance. This is assigned
		 * via the supplied <code>data</code> setter.
		 * 
		 */
		private var _ZIPData:ByteArray=null;
		/**
		 * @private
		 * Numbered array containing objects with information about the files stored in the ZIP data. This
		 * array is stored in the order in which it appears in the ZIP data although, once created, the data can
		 * be accessed randomly.
		 * 
		 */
		private var _directoryData:Array=null;
		/**
		 * @private
		 * Parsed information from the ZIP data's end directory record. This describes the other directory 
		 * elements which in turn describe the file elements.
		 * 
		 */
		private var _endDirectoryData:Object=null; 
		
		/**
		 * Default constructor for the class.
		 * 
		 * @param An optional <code>ByteArray</code> object containing valid ZIP-compressed data with which
		 * to initialilze the instance. If supplied, the compressed data and all associated functionality
		 * become available right away, otherwise it must be assigned to the <code>data</code> object first.
		 * 
		 */
		public function SwagZip (ZIPData:ByteArray=null) {
			this.setDefaults();
			if (ZIPData!=null) {
				this.data=ZIPData;
			}//if
		}//constructor
		
		/**
		 * Extracts file data from the ZIP into an object containing detailed information about
		 * the compressed data, as well as the data itself. 
		 * <p>Along with this is returned information from the file header within the ZIP. 
		 * This is a smaller sub-set of the <code>directory</code> information and should be the same as the associated 
		 * <code>directory</code> entry (but may not be!)</p> 
		 * <p>This smaller subset includes the properties:
		 * <code>compressorVersion</code>, <code>bitFlags</code>, <code>compressor</code>, <code>modifiedTime</code>, 
		 * <code>modifiedDate</code>, <code>CRC32</code>, <code>compressedSize</code>, <code>uncompressedSize</code>, 
		 * <code>name</code>, and <code>extraField</code>.</p> 
		 * <p>Differences between these values and the associated <code>directory</code> entry may indicate
		 * data corruption.</p>
		 * 
		 * @param fileName The name of the file as it appears in the ZIP directory. Use the associated 
		 * <code>directory</code> object to retrieve the list of files within the ZIP data first if this
		 * value is unknown.
		 * @param returnType The object type (<code>ByteArray</code>, <code>String</code>, or <code>XML</code>) to 
		 * return the decompressed data as. If not specified the default is <code>ByteArray</code> (safest).
		 * 
		 * @return <p>An object containing the properties of the associated file (detailed below), and also including 
		 * the following two properties:
		 * <p>
		 * <ul>
		 * <li>data (<code>ByteArray</code> / <code>String</code> / <code>XML</code>): The uncompressed data in the 
		 * format specified by the <code>returnType</code> parameter.</li>
		 * <li>type (<code>Class</code>): The class type specified in the <code>returnType</code> parameter.</li>
		 * </ul>
		 * </p>
		 * <p>If the required parameters are supplied as <em>null</em>, or they are of an unexpected type / format,
		 * <em>null</em> is returned.</p>
		 * <p>The returned object also contains the following properties:</p>
		 * <ul>
		 * <li>compressorID (<code>uint</code>): The ID of the software used to create the ZIP data.</li>
		 * <li>compressorVersion (<code>uint</code>): The minium version of the software required to handle the associated 
		 * ZIP data.</li>
		 * <li>bitFlags (<code>uint</code>): Special attribute flags. Currently, if bit 3 is set (0x04), the CRC32 value is stored as 
		 * 0 in the <code>directory</code> object and will rather be appended as a 12-byte value at the end of the compressed 
		 * data.</li>
		 * <li>compressor (<code>uint</code>): The compression algorithm used for the stored file. Valid values include 
		 * <strong>0 = stored</strong> (no compression), <strong>1 = shrunk</strong>, <strong>2 to 5 = reduced with 
		 * compression factor 1 to 4</strong> (in order), <strong>6 = imploded</strong>, <strong>7 = reserved</strong>, 
		 * <strong>8 = deflated</strong> (most common).</li>
		 * <li>modifiedTime (<code>SwagTime</code>): The last modified time of the file, stored in a <code>SwagTime</code> 
		 * instance.</li>
		 * <li>modifiedDate (<code>SwagDate</code>): The last modified date of the file, stored in a <code>Swagdate</code> 
		 * instance.</li>
		 * <li>CRC32 (<code>uint</code>): The 32-bit cyclical redundancy check value that can be used to verify the integrity 
		 * of the associated data.</li>
		 * <li>compressedSize (<code>uint</code>): The size of the compressed file, in bytes.</li>
		 * <li>uncompressedSize (<code>uint</code>): The size of the uncompressed file, in bytes.</li>
		 * <li>startDisk (<code>uint</code>): The first disk in which the compressed file resides. For multi-disk / multi-part 
		 * ZIPs.</li>
		 * <li>internalAttributes (<code>uint</code>): Internal file attribute bits (exact values unknown).</li>
		 * <li>externalAttributes (<code>uint</code>): Internal file attribute bits (exact values unknown). Most likely these 
		 * refer to file-system settings for the associated file / folder.</li>
		 * <li>headerOffset (<code>uint</code>): The offset to the file header within the ZIP. After the header is the actual 
		 * compressed data. The file header repeats much of the information found in the directory information and can thus be used 
		 * to retrieve data from partially corrupted ZIP files.</li>
		 * <li>fullPath (<code>String</code>): The full, relative path of the file or folder. For example: 
		 * <em>/folder/sub_folder/my_file.txt</em> --or-- <em>no_folder_file.doc</em></li>
		 * <li>extraField (<code>uint</code>): Extra field provided for associating extra information with the compressed data. 
		 * Format unspecified.</li>
		 * <li>comment (<code>String</code>): A comment associated with the individual file or folder.</li>
		 * <li>name (<code>String</code>): The file name portion of the <code>fullPath</code> property. For example, if 
		 * <code>fullPath</code> is <em>some_folder/my_file.txt</em>, the name will be <em>my_file.txt</em>. For folder items, 
		 * this is an empty string.</li>
		 * <li>path (<code>String</code>): The path portion of the <code>fullPath</code> property. For example, if 
		 * <code>fullPath</code> is <em>some_folder/my_file.txt</em>, this path will be <em>some_folder</em>. If a file is 
		 * stored in the root of the ZIP data (not in any folder), this will be an empty string.</li>
		 * <li>pathParts (<code>Array</code>): The path broken up into a numbered array, each element corresponding to a 
		 * deeper level in the folder structure. For example, the path <em>folder_one/folder_two</em> would produce 
		 * <code>pathParts[0]="folder_one"</code> and <code>pathParts[1]="folder_two"</code>. The file name is not included 
		 * in this array since it's not part of the path.</li>
		 * <li>pathDepth (<code>uint</code>): The depth (within folder) at which the file resides. This is equal to the length 
		 * of the <code>pathParts</code> array. For example, the file <em>folder_one/second_folder/my_file.txt</em> is at 
		 * <code>pathDepth</code> 2 (two folders deep).</li> 
		 * <li>type (<code>String</code>): The type of item that this directory entry is. Valid values include "<em>file</em>" 
		 * and "<em>folder</em>".</li>
		 * <li>index (<code>uint</code>): The index value at which this item resides in the <code>directory</code> array.</li>
		 * </ul></p>
		 * 
		 * @eventType SwagEvent.SwagErrorEvent.DATAFORMATERROR
		 * @eventType SwagEvent.SwagErrorEvent.UNSUPPORTEDOPERATIONERROR
		 * 
		 * @see #extractFileData()
		 */
		public function extractFile(fileName:String="", returnType:Class=null):Object {
			if ((fileName==null) || (fileName=="")) {
				return (null);
			}//if
			var fileInfo:Object=this.getFileInfo(fileName);
			if (fileInfo==null) {
				return (null);
			}//if
			if (returnType==null) {
				returnType=ByteArray; //Default return type is ByteArray -- the safest
			}//if
			var fileOffset:uint=fileInfo.headerOffset;
			this._ZIPData.position=fileOffset;
			var signature:uint=this._ZIPData.readUnsignedInt() as uint;
			if (signature!=_fileHeaderSignature) {
				var errorEvent:SwagErrorEvent=new SwagErrorEvent(SwagErrorEvent.DATAFORMATERROR);
				errorEvent.description="The file header signature for file "+fileInfo.name+" does not match the standard ";
				errorEvent.description+="ZIP signature (0x04034b50). Data is most likely corrupt.";
				errorEvent.remedy="No remedy available.";
				SwagDispatcher.dispatchEvent(errorEvent, this);
				return (null);
			}//if
			//Ignore all this information now ... just use it to get the right offset
			var returnObject:Object=new Object();
			returnObject.compressorVersion=this._ZIPData.readUnsignedShort() as uint;
			returnObject.bitFlags=this._ZIPData.readUnsignedShort() as uint;
			returnObject.compressor=this._ZIPData.readUnsignedShort() as uint;
			returnObject.modifiedTime=new SwagTime();
			returnObject.modifiedTime.MSDOSTime=this._ZIPData.readUnsignedShort() as uint;
			returnObject.modifiedDate=new SwagDate();
			returnObject.modifiedDate.MSDOSDate=this._ZIPData.readUnsignedShort() as uint;
			returnObject.CRC32=this._ZIPData.readUnsignedInt() as uint;
			returnObject.compressedSize=this._ZIPData.readUnsignedInt() as uint;
			returnObject.uncompressedSize=this._ZIPData.readUnsignedInt() as uint;
			var fileNameLength:uint=this._ZIPData.readUnsignedShort() as uint;
			var extraFieldLength:uint=this._ZIPData.readUnsignedShort() as uint;
			returnObject.name=new String(this._ZIPData.readMultiByte(fileNameLength, "utf-8") as String);
			returnObject.extraField=new String(this._ZIPData.readMultiByte(extraFieldLength, "utf-8") as String);
			returnObject.type=returnType;
			var tempData:ByteArray=new ByteArray();
			this._ZIPData.readBytes(tempData,0,returnObject.compressedSize);
			switch (returnObject.compressor) {
				case 8 : tempData.inflate(); break;
				case 0 : break; //No compression
				default : errorEvent=new SwagErrorEvent(SwagErrorEvent.UNSUPPORTEDOPERATIONERROR);
					errorEvent.description="Unsupported compression method used in ZIP data ";
					errorEvent.description+="("+returnObject.compressionMethod+").";
					errorEvent.remedy="No remedy available.";
					SwagDispatcher.dispatchEvent(errorEvent, this);
					break;
			}//switch
			if (returnType == ByteArray) {				
				returnObject.data=tempData;		
			}//if
			if (returnType == String) {				
				returnObject.data=new String(tempData.toString());				
			}//if			
			if (returnType == XML) {				
				returnObject.data=new XML(tempData.toString());
			}//if
			return (returnObject);
		}//extractFile
		
		/**
		 * Extracts file data from the ZIP as usable, uncompressed data. 
		 * <p>This is almost identical to the <code>extractFile</code> function except that it returns just 
		 * the uncompressed data, not an object with the complete associated file information.</p>
		 * 
		 * @param fileName The name of the file as it appears in the ZIP directory.
		 * @param returnType The object type (<code>ByteArray</code>, <code>String</code>, or <code>XML</code>) to 
		 * return the decompressed	data as. If not specified the default is <code>ByteArray</code> (safest).
		 * 
		 * @return The uncompressed data in the format specified by the returnType (<code>ByteArray</code> / 
		 * <code>String</code> / <code>XML</code>), or <em>null</em> if there was an error getting the data.
		 * 
		 * @eventType SwagEvent.SwagErrorEvent.DATAFORMATERROR
		 * @eventType SwagEvent.SwagErrorEvent.UNSUPPORTEDOPERATIONERROR
		 * 
		 * @see #extractFile()		 
		 */
		public function extractFileData(fileName:String="", returnType:Class=null):* {
			var returnObject:Object=this.extractFile(fileName, returnType);
			if (returnObject!=null) {
				return (returnObject.data);
			} else {
				return (null);
			}//else
		}//extractFileData
		
		/**
		 * Returns the file info object for a specified file name within the ZIP data. 
		 * <p>If a specific file name within the ZIP data is known to exist, this method will search
		 * for it within the <code>directory</code> array and return the found object. The <code>directory</code> 
		 * must first exist -- the ZIP data must already be assigned or loaded, in other words -- otherwise
		 * an error is dispatched and the method fails.</p>
		 * 
		 * @param fileName The exact file name (without path) of the file to find in the <code>directory</code> array.
		 * 
		 * @return An object from the <code>directory</code> array matching the file name specified in the
		 * parameter. This object contains the properties of the <code>header</code> object. <em>Null</em> is
		 * returned if the parameters are incorrect.
		 * <p>The returned object contains the following properties:</p>
		 * <p><ul>
		 * <li>compressorID (<code>uint</code>): The ID of the software used to create the ZIP data.</li>
		 * <li>compressorVersion (<code>uint</code>): The minium version of the software required to handle the associated 
		 * ZIP data.</li>
		 * <li>bitFlags (<code>uint</code>): Special attribute flags. Currently, if bit 3 is set (0x04), the CRC32 value is stored as 
		 * 0 in the <code>directory</code> object and will instead be appended as a 12-byte value at the end of the compressed 
		 * data.</li>
		 * <li>compressor (<code>uint</code>): The compression algorithm used for the stored file. Valid values include 
		 * <strong>0 = stored</strong> (no compression), <strong>1 = shrunk</strong>, <strong>2 to 5 = reduced with 
		 * compression factor 1 to 4</strong> (in order), <strong>6 = imploded</strong>, <strong>7 = reserved</strong>, 
		 * <strong>8 = deflated</strong> (most common).</li>
		 * <li>modifiedTime (<code>SwagTime</code>): The last modified time of the file, stored in a <code>SwagTime</code> 
		 * instance.</li>
		 * <li>modifiedDate (<code>SwagDate</code>): The last modified date of the file, stored in a <code>Swagdate</code> 
		 * instance.</li>
		 * <li>CRC32 (<code>uint</code>): The 32-bit cyclical redundancy check value that can be used to verify the integrity 
		 * of the associated data.</li>
		 * <li>compressedSize (<code>uint</code>): The size of the compressed file, in bytes.</li>
		 * <li>uncompressedSize (<code>uint</code>): The size of the uncompressed file, in bytes.</li>
		 * <li>startDisk (<code>uint</code>): The first disk in which the compressed file resides. For multi-disk / multi-part 
		 * ZIPs.</li>
		 * <li>internalAttributes (<code>uint</code>): Internal file attribute bits (exact values unknown).</li>
		 * <li>externalAttributes (<code>uint</code>): Internal file attribute bits (exact values unknown). Most likely these 
		 * refer to file-system settings for the associated file / folder.</li>
		 * <li>headerOffset (<code>uint</code>): The offset to the file header within the ZIP. After the header is the actual 
		 * compressed data. The file header repeats much of the information found in the directory information and can thus be used 
		 * to retrieve data from partially corrupted ZIP files.</li>
		 * <li>fullPath (<code>String</code>): The full, relative path of the file or folder. For example: 
		 * <em>/folder/sub_folder/my_file.txt</em> --or-- <em>no_folder_file.doc</em></li>
		 * <li>extraField (<code>uint</code>): Extra field provided for associating extra information with the compressed data. 
		 * Format unspecified.</li>
		 * <li>comment (<code>String</code>): A comment associated with the individual file or folder.</li>
		 * <li>name (<code>String</code>): The file name portion of the <code>fullPath</code> property. For example, if 
		 * <code>fullPath</code> is <em>some_folder/my_file.txt</em>, the name will be <em>my_file.txt</em>. For folder items, 
		 * this is an empty string.</li>
		 * <li>path (<code>String</code>): The path portion of the <code>fullPath</code> property. For example, if 
		 * <code>fullPath</code> is <em>some_folder/my_file.txt</em>, this path will be <em>some_folder</em>. If a file is 
		 * stored in the root of the ZIP data (not in any folder), this will be an empty string.</li>
		 * <li>pathParts (<code>Array</code>): The path broken up into a numbered array, each element corresponding to a 
		 * deeper level in the folder structure. For example, the path <em>folder_one/folder_two</em> would produce 
		 * <code>pathParts[0]="folder_one"</code> and <code>pathParts[1]="folder_two"</code>. The file name is not included 
		 * in this array since it's not part of the path.</li>
		 * <li>pathDepth (<code>uint</code>): The depth (within folder) at which the file resides. This is equal to the length 
		 * of the <code>pathParts</code> array. For example, the file <em>folder_one/second_folder/my_file.txt</em> is at 
		 * <code>pathDepth</code> 2 (two folders deep).</li> 
		 * <li>type (<code>String</code>): The type of item that this directory entry is. Valid values include "<em>file</em>" 
		 * and "<em>folder</em>".</li>
		 * <li>index (<code>uint</code>): The index value at which this item resides in the <code>directory</code> array.</li>
		 * </ul></p>
		 * 
		 * @see #extractFile() 
		 * 
		 */ 
		public function getFileInfo(fileName:String=null):Object {
			if ((fileName==null) || (fileName=="")) {
				return (null);
			}//if
			for (var count:uint=0; count<this._directoryData.length; count++) {
				var currentObject:Object=this._directoryData[count] as Object;
				if (currentObject.name==fileName) {
					return (currentObject);
				}//if
			}//for
			return (null);
		}//getFileInfo
		
		/**
		 * @private
		 * Finds a matching file or directory using wildcard or other regularl expression searches.
		 * 
		 * @param fileName An exact or wildcard file name (without path) of the file to find in the 
		 * <code>directory</code> array. Regular expression search terms such as "<em>*</em>"
		 * and "<em>?</em>" may be used.
		 * @param isDirectory If <em>true</em>, directory entries are searched instead of file
		 * entries. If <em>false</em> (default), only files are searched.
		 * 
		 * @return An object from the <code>directory</code> matching the file or or directory name specified 
		 * in the parameter. Only the first match will be returned, or <em>null</em> if none found.
		 */ 
		private function findFileInfo(fileName:String=null, isDirectory:Boolean=false):Object {
			//TODO: Implement!
			return (null);
		}//findFileInfo
		
		
		/**
		 * @private
		 * Parses the ZIP files directory, extracting information about the individual files and folders stored
		 * in the data. The <code>_endDirectoryData</code> object must be populated first (i.e. 
		 * <code>parseDirectoryEndRecord</code> must be called first). Once the directory has been parsed, 
		 * individual files may be arbitrarily extracted in any order.
		 * <p>In order to ensure that the full directory object has been parsed, listen for the
		 * <code>SwagZipEvent.PARSEDIRECTORY</code> event.</p>
		 *
		 * @return Array A numbered array of objects containing information about individual compressed files
		 * and folders in the ZIP data (see class description for more information). These are stored in the order 
		 * found in the ZIP, starting with 0. If no ZIP data exists, or if the end directory data has not yet been 
		 * parsed, <em>null</em> is returned.
		 * 
		 * @eventType SwagEvent.SwagZipEvent.PARSEDIRECTORY
		 * @eventType SwagEvent.SwagErrorEvent.DATAFORMATERROR
		 * 
		 */
		private function parseDirectory():Array {
			if (this._ZIPData==null) {
				return (null);
			}//if
			if (this._endDirectoryData==null) {
				return (null);
			}//if
			if ((this._endDirectoryData.directoryOffset==undefined) || (this._endDirectoryData.directoryOffset==null)) {
				return (null);
			}//if
			var directoryData:Array=new Array();
			this._ZIPData.position=this._endDirectoryData.directoryOffset;			
			for (var count:uint=0; count<this._endDirectoryData.directoryRecords; count++) {
				var signature:uint=this._ZIPData.readUnsignedInt() as uint;
				var fileInfoObject:Object=new Object();				
				if (signature!=_directoryHeaderSignature) {
					var errorEvent:SwagErrorEvent=new SwagErrorEvent(SwagErrorEvent.DATAFORMATERROR);
					errorEvent.description="The directory header signature at offset "+count+" does not match the ";
					errorEvent.description="standard ZIP signature (0x02014b50).";
					errorEvent.remedy="No remedy available. Other parsed sections may still be usable.";
					SwagDispatcher.dispatchEvent(errorEvent, this);
					//TODO: Seek forward byte by byte to find next header signature. Failing that we could also try extracting data using file header into (last-resort recovery).
					return (directoryData);
				} else {
					fileInfoObject.compressorID=this._ZIPData.readUnsignedShort() as uint;
					fileInfoObject.compressorVersion=this._ZIPData.readUnsignedShort() as uint;
					fileInfoObject.bitFlags=this._ZIPData.readUnsignedShort() as uint; //If bit 3 is set (0x04), CRC-32 is added in a 12-byte structure after file data and CRC data is 0.
					//0=stored (no compression), 1=shrunk, 2-5=reduced with compression factor 1 to 4, 6=imploded, 7=reserved, 8=deflated
					fileInfoObject.compressor=this._ZIPData.readUnsignedShort() as uint; 
					fileInfoObject.modifiedTime=new SwagTime();
					fileInfoObject.modifiedTime.MSDOSTime=this._ZIPData.readUnsignedShort() as uint; //Packed MS-DOS time structure
					fileInfoObject.modifiedDate=new SwagDate();
					fileInfoObject.modifiedDate.MSDOSDate=this._ZIPData.readUnsignedShort() as uint; //Packed MS-DOS date structure
					fileInfoObject.CRC32=this._ZIPData.readUnsignedInt() as uint;
					fileInfoObject.compressedSize=this._ZIPData.readUnsignedInt() as uint; //In bytes
					fileInfoObject.uncompressedSize=this._ZIPData.readUnsignedInt() as uint; //In bytes
					var fileNameLength:uint=this._ZIPData.readUnsignedShort() as uint;
					var extraFieldLength:uint=this._ZIPData.readUnsignedShort() as uint;
					var commentLength:uint=this._ZIPData.readUnsignedShort() as uint;
					fileInfoObject.startDisk=this._ZIPData.readUnsignedShort() as uint;
					fileInfoObject.internalAttributes=this._ZIPData.readUnsignedShort() as uint; //Bitmapped? Probably OS-specific.
					fileInfoObject.externalAttributes=this._ZIPData.readUnsignedInt() as uint; //Bitmapped? Probably OS-specific.
					fileInfoObject.headerOffset=this._ZIPData.readUnsignedInt() as uint;
					fileInfoObject.fullPath=new String(this._ZIPData.readMultiByte(fileNameLength, "utf-8") as String);
					fileInfoObject.extraField=new String(this._ZIPData.readMultiByte(extraFieldLength, "utf-8") as String);
					fileInfoObject.comment=new String(this._ZIPData.readMultiByte(commentLength, "utf-8") as String);
					//Parse the file info further
					fileInfoObject.name=new String(fileInfoObject.fullPath.substr(fileInfoObject.fullPath.lastIndexOf("/")+1));
					if (fileInfoObject.fullPath.lastIndexOf("/")>-1) {
						fileInfoObject.path=new String(fileInfoObject.fullPath.substr(0, fileInfoObject.fullPath.lastIndexOf("/")));
						fileInfoObject.pathParts=fileInfoObject.path.split("/") as Array;
						fileInfoObject.pathDepth=fileInfoObject.pathParts.length;
					} else {
						fileInfoObject.path=new String();
						fileInfoObject.pathParts=new Array();
						fileInfoObject.pathDepth=0;
					}//else
					if (fileInfoObject.fullPath.substr(fileInfoObject.fullPath.length-1,1)=="/") {
						fileInfoObject.type="folder";
					} else {
						fileInfoObject.type="file";
					}//else
					fileInfoObject.index=count;
				}//else			
				directoryData[count]=fileInfoObject;
			}//for
			var infoEvent:SwagZipEvent=new SwagZipEvent(SwagZipEvent.PARSEDIRECTORY);
			SwagDispatcher.dispatchEvent(infoEvent, this);
			return (directoryData);
		}//parseDirectory
		
		/**
		 * @private
		 * Retrieves and parses the end directory record of the ZIP data. 
		 * <p>This must be done first in order to identify the location of the directory. Following this second
		 * step, individual files may be read individually.</p>
		 * 
		 * @return The parsed directory end record or <em>null</null> if it could not be read (no ZIP data present, 
		 * for example).
		 * 
		 * @eventType SwagEvent.SwagZipEvent.PARSEHEADER
		 */
		private function parseDirectoryEndHeader():Object {
			if (this._ZIPData==null) {
				return (null);
			}//if
			var endRecord:Object=new Object();
			var endRecordData:ByteArray=new ByteArray();			
			this._ZIPData.position=this._ZIPData.length-4; 
			var dataOffset:uint=this._ZIPData.length-4;
			var currentRecord:uint=0;
			while (currentRecord!=_directoryEndHeaderSignature) {
				currentRecord=this._ZIPData.readUnsignedInt();
				dataOffset-=1; //Move by 1 byte since end record may be of arbitrary length due to the comment field
				this._ZIPData.position=dataOffset;
			}//while
			this._ZIPData.position+=5; //Skip beyond the header signature
			endRecord.diskNumber=this._ZIPData.readUnsignedShort() as uint; //The following three values are used for archives 
						//spread over multiple disks 
			endRecord.directoryDiskNumber=this._ZIPData.readUnsignedShort() as uint;
			endRecord.directoryDiskRecords=this._ZIPData.readUnsignedShort() as uint; 
			endRecord.directoryRecords=this._ZIPData.readUnsignedShort() as uint; //Records in this file's directory
			endRecord.directorySize=this._ZIPData.readUnsignedInt() as uint; //...in bytes
			endRecord.directoryOffset=this._ZIPData.readUnsignedInt() as uint; //From start of ZIP data
			var commentSize:uint=this._ZIPData.readUnsignedShort() as uint; //In bytes, so maximum posisble comment length 
						//is 65535 bytes
			endRecord.comment=new String(this._ZIPData.readMultiByte(commentSize, "utf-8") as String); //ZIP file character 
						//set is UTF-8
			var infoEvent:SwagZipEvent=new SwagZipEvent(SwagZipEvent.PARSEHEADER);
			SwagDispatcher.dispatchEvent(infoEvent, this);
			return (endRecord);
		}//parseDirectoryEndHeader
		
		/**
		 * @private
		 */
		private function setDefaults():void {
		}//setDefaults
		
		/** 
		 * The raw, compressed ZIP data for the class instance.
		 * <p>The data is parsed directly, verifying whether or not it's valid ZIP data, and then extracting 
		 * <code>directory</code> information from it (available via the <code>header</code> object).</p> 
		 */
		public function set data(dataSet:ByteArray):void {
			if (dataSet!=null) {
				this._ZIPData=dataSet;
				this._ZIPData.endian=Endian.LITTLE_ENDIAN; //Otherwise the bit order may not be correct!			
				this._endDirectoryData=this.parseDirectoryEndHeader();
				this._directoryData=this.parseDirectory();			
			}//if
		}//set data
		
		public function get data():ByteArray {
			return (this._ZIPData);
		}//get data
		
		/**
		 * The parsed directory information associated with the compressed ZIP data for this class.
		 * <p>This is a numbered array of objects, each of which contains information about each file or folder
		 * within the ZIP data.</p>
		 * <p>Each <code>directory</code> record contains the following information:</p>
		 * <p><ul>
		 * <li>compressorID (<code>uint</code>): The ID of the software used to create the ZIP data.</li>
		 * <li>compressorVersion (<code>uint</code>): The minium version of the software required to handle the associated 
		 * ZIP data.</li>
		 * <li>bitFlags (<code>uint</code>): Special attribute flags. Currently, if bit 3 is set (0x04), the CRC32 value is stored as 
		 * 0 in the <code>directory</code> object and will rather be appended as a 12-byte value at the end of the compressed 
		 * data.</li>
		 * <li>compressor (<code>uint</code>): The compression algorithm used for the stored file. Valid values include 
		 * <strong>0 = stored</strong> (no compression), <strong>1 = shrunk</strong>, <strong>2 to 5 = reduced with 
		 * compression factor 1 to 4</strong> (in order), <strong>6 = imploded</strong>, <strong>7 = reserved</strong>, 
		 * <strong>8 = deflated</strong> (most common).</li>
		 * <li>modifiedTime (<code>SwagTime</code>): The last modified time of the file, stored in a <code>SwagTime</code> 
		 * instance.</li>
		 * <li>modifiedDate (<code>SwagDate</code>): The last modified date of the file, stored in a <code>Swagdate</code> 
		 * instance.</li>
		 * <li>CRC32 (<code>uint</code>): The 32-bit cyclical redundancy check value that can be used to verify the integrity 
		 * of the associated data.</li>
		 * <li>compressedSize (<code>uint</code>): The size of the compressed file, in bytes.</li>
		 * <li>uncompressedSize (<code>uint</code>): The size of the uncompressed file, in bytes.</li>
		 * <li>startDisk (<code>uint</code>): The first disk in which the compressed file resides. For multi-disk / multi-part 
		 * ZIPs.</li>
		 * <li>internalAttributes (<code>uint</code>): Internal file attribute bits (exact values unknown).</li>
		 * <li>externalAttributes (<code>uint</code>): Internal file attribute bits (exact values unknown). Most likely these 
		 * refer to file-system settings for the associated file / folder.</li>
		 * <li>headerOffset (<code>uint</code>): The offset to the file header within the ZIP. After the header is the actual 
		 * compressed data. The file header repeats much of the information found in the directory information and can thus be used 
		 * to retrieve data from partially corrupted ZIP files.</li>
		 * <li>fullPath (<code>String</code>): The full, relative path of the file or folder. For example: 
		 * <em>/folder/sub_folder/my_file.txt</em> --or-- <em>no_folder_file.doc</em></li>
		 * <li>extraField (<code>uint</code>): Extra field provided for associating extra information with the compressed data. 
		 * Format unspecified.</li>
		 * <li>comment (<code>String</code>): A comment associated with the individual file or folder.</li>
		 * <li>name (<code>String</code>): The file name portion of the <code>fullPath</code> property. For example, if 
		 * <code>fullPath</code> is <em>some_folder/my_file.txt</em>, the name will be <em>my_file.txt</em>. For folder items, 
		 * this is an empty string.</li>
		 * <li>path (<code>String</code>): The path portion of the <code>fullPath</code> property. For example, if 
		 * <code>fullPath</code> is <em>some_folder/my_file.txt</em>, this path will be <em>some_folder</em>. If a file is 
		 * stored in the root of the ZIP data (not in any folder), this will be an empty string.</li>
		 * <li>pathParts (<code>Array</code>): The path broken up into a numbered array, each element corresponding to a 
		 * deeper level in the folder structure. For example, the path <em>folder_one/folder_two</em> would produce 
		 * <code>pathParts[0]="folder_one"</code> and <code>pathParts[1]="folder_two"</code>. The file name is not included 
		 * in this array since it's not part of the path.</li>
		 * <li>pathDepth (<code>uint</code>): The depth (within folder) at which the file resides. This is equal to the length 
		 * of the <code>pathParts</code> array. For example, the file <em>folder_one/second_folder/my_file.txt</em> is at 
		 * <code>pathDepth</code> 2 (two folders deep).</li> 
		 * <li>type (<code>String</code>): The type of item that this directory entry is. Valid values include "<em>file</em>" 
		 * and "<em>folder</em>".</li>
		 * <li>index (<code>uint</code>): The index value at which this item resides in the <code>directory</code> array.</li>
		 * </ul></p>
		 */
		public function get directory():Array {
			return (this._directoryData);
		}//get directory
		
		/**
		 * Retrieves the parsed header information for the associated ZIP data. 
		 * <p>This includes global items such as the offset of the file information headers within the ZIP 
		 * data, the comment associated with the ZIP data, and so on.</p>
		 * <p>The header object contains the following information:</p>
		 * <p><ul>
		 * <li>diskNumber (<code>uint</code>): The disk number associated with this archive (for multi-disk archives).</li>
		 * <li>directoryDiskNumber (<code>uint</code>): The number of the current disk's directory (for multi-disk archives).</li>
		 * <li>directoryDiskRecords (<code>uint</code>): The total number of directory records across all disks (for multi-disk 
		 * archives).</li>
		 * <li>directoryRecords (<code>uint</code>): The total number of records in the current disk directory (should match the 
		 * number of <code>directory</code> elements once parsed).</li>
		 * <li>directorySize (<code>uint</code>): The size of the directory, in bytes, in the current disk archive.</li>
		 * <li>directoryOffser (<code>uint</code>): The offset, in bytes from the beginning of the ZIP data, of the directory 
		 * data in the current archive.</li>
		 * <li>comment (<code>String</code>): A comment associated with the current ZIP data. May be up to 65,535 characters.</li>
		 * </ul></p>
		 */
		public function get header():Object {
			return (this._endDirectoryData);
		}//get header
				
	}//SwagZip class
	
}//package