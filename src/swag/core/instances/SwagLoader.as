package swag.core.instances {
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	
	import swag.core.SwagDataTools;
	import swag.core.SwagDispatcher;
	import swag.core.SwagSystem;
	import swag.events.SwagLoaderEvent;
	import swag.interfaces.core.instances.ISwagLoader;
	
	/**
	 * Provides runtime-agnostic methods and properties for downloading / uploading data from / to remote or local sources. 
	 * <p>"Runtime-agnostic" means that the best methods will be used depending on the runtime and should be completely transparent
	 * to the developer. In other words, if <code>SwagLoader</code> is running within an AIR instance, it will attempt to use AIR-based
	 * file routines instead of standard Flash URL-based ones.</p>
	 * <p>The aim of runtime-agnosticism is to provide the developer with the easiest way to load file data reliably without the need
	 * to split or change code to work with the target runtime.</p> 
	 * 
	 * @author Patrick Bay
	 * 
	 */
	public class SwagLoader implements ISwagLoader {
		
		/**
		 * Denotes that the associated <code>SwagLoader</code> instance will attempt to use a local, file-based
		 * transport mechanism (a <code>FileStream</code> instance).
		 */
		public static const LOCALTRANSPORT:String="SwagLoader.LOCALTRANSPORT";
		/**
		 * Denotes that the associated <code>SwagLoader</code> instance will attempt to use a remote, URL-based
		 * transport mechanism (a <code>URLStream</code> instance). This is the default transport type since
		 * it has the broadest support (both Flash and AIR), and is also the fallback transport if a local one
		 * isn't available.
		 */
		public static const REMOTETRANSPORT:String="SwagLoader.REMOTETRANSPORT";
		/**
		 * Denotes that the <code>SwagLoader</code> instance will not attempt any load. This is the default
		 * transport when the class hasn't been properly initialized.
		 */
		public static const NOTRANSPORT:String="SwagLoader.NOTRANSPORT";
		/**
		 * @private 
		 */
		private var _stream:*=null
		/**
		 * @private 
		 */
		private var _path:*=null;
		/**
		 * @private 
		 */
		private var _loadedBinaryData:ByteArray=null;		
		/**
		 * @private 
		 */
		private var _loadedData:*=null;
		/**
		 * @private 
		 */
		private var _returnType:*=null;
		
		/**
		 * Default constructor for the class.
		 *  
		 * @param filePathRef The file path to associate with this <code>SwagLoader</code> instance. This
		 * value may either be a <code>String</code>, in which case it's assumed to be a direct file / URL reference,
		 * a <code>URLRequest</code> object to be used directly with a <code>URLStream</code> instance, or a
		 * <code>File</code> instance to be used directly with a <code>FileStream</code> instance. If omitted,
		 * the <code>path</code> property must be set manually before attempting a load operation.
		 * 
		 */
		public function SwagLoader(pathRef:*=null) {			
			this.path=pathRef;
		}//constructor
		
		/**
		 * Begins a load (download) operation for the <code>SwagLoader</code> instance.
		 * <p>Unless otherwise specified, this method attempts to automatically determine the best, most robust,
		 * and most reliable transport mechanism for the load.</p>
		 *  
		 * @param pathRef The path, or an object containing a reference to the path, of the file to load. This
		 * may either be a string containing a full or partial file path or URL, a <code>URLRequest</code> instance,
		 * or a <code>File</code> instance. This parameter may not be null. 
		 * @param returnType The expected return data type for the loaded. <code>SwagLoader</code> attempts to
		 * convert the loaded data to this type once loaded. While data is being loaded, it's stored in a <code>ByteArray</code>
		 * object, which is also the default <code>returnType</code> if none is specified, or the type specified isn't supported.
		 * Supported return types currently include: <code>ByteArray</code>, <code>String</code>, <code>XML</code>
		 * @param forceTransport The type of transport to use with the load, regardless of what <code>SwagLoader</code>
		 * determines to be the best one. Valid load types can be found in <code>SwagLoader</code>'s constant values,
		 * and include <code>SwagLoader.LOCALTRANSPORT</code> and <code>SwagLoader.REMOTETRANSPORT</code>.
		 * 
		 * @return <em>True</em> if the load was successfully started, <em>false</em> otherwise (for example, the 
		 * <code>path</code> is <em>null</em> or empty, or the <code>SwagLoader</code> instance reports no available transport).
		 * 
		 */
		public function load(pathRef:*=null, returnType:Class=null, forceTransport:String=null):Boolean {
			if (pathRef!=null) {
				this.path=pathRef;
			}//if
			if (this.path==null) {
				return (false);
			}//if
			this._returnType=returnType;
			if ((forceTransport==null) || (forceTransport=="")) {
				if (this.transport==SwagLoader.LOCALTRANSPORT) {
					//Using local transport					
					try {												
						if (this._path is URLRequest) {
							var fileInstance:*=File.applicationDirectory.resolvePath(URLRequest(this._path).url);
						} else if (this._path is String) {
							fileInstance=File.applicationDirectory.resolvePath(this._path);
						} else if (this._path is File) {
							//do nothing
						} else {
							return (false);
						}//else						
					} catch (error:*) {						
						return (false);
					}//catch					
					this._stream=new FileStream();
					this._stream.addEventListener(ProgressEvent.PROGRESS, this.onLoadProgress);
					this._stream.addEventListener(Event.COMPLETE, this.onLoadComplete);
					this._stream.addEventListener(IOErrorEvent.IO_ERROR, this.onLoadError);
					this._loadedBinaryData=new ByteArray();
					SwagDispatcher.dispatchEvent(new SwagLoaderEvent(SwagLoaderEvent.START), this);
					this._stream.openAsync(fileInstance, FileMode.READ);					
				} else if (this.transport==SwagLoader.REMOTETRANSPORT) {
					//Using remote transport
					try {
						if (this._path is URLRequest) {
							//do nothing
						} else if (this._path is String) {
							var requestInstance:*=new URLRequest(this._path);
						} else if (this._path is File) {
							requestInstance=new URLRequest(this._path.url);
						} else {
							return (false);
						}//else
					} catch (error:*) {
						return (false);
					}//catch
					this._stream=new URLStream();
					this._stream.addEventListener(ProgressEvent.PROGRESS, this.onLoadProgress);
					this._stream.addEventListener(Event.COMPLETE, this.onLoadComplete);
					this._stream.addEventListener(IOErrorEvent.IO_ERROR, this.onLoadError);
					this._stream.addEventListener(HTTPStatusEvent.HTTP_STATUS, this.onLoadHTTPStatus);
					this._loadedBinaryData=new ByteArray();
					SwagDispatcher.dispatchEvent(new SwagLoaderEvent(SwagLoaderEvent.START), this);					
					URLStream(this._stream).load(requestInstance);
				} else {
					return (false);
				}//else
			} else {
				
			}//else
			return (true);
		}//load
		
		/**		 
		 * @private		 
		 */
		private function onLoadProgress(eventObj:ProgressEvent):void {			
			this._stream.readBytes(this.loadedBinaryData, this.loadedBinaryData.length);
			SwagDispatcher.dispatchEvent(new SwagLoaderEvent(SwagLoaderEvent.DATA), this);
		}//onLoadProgress
		
		/**		 
		 * @private		 
		 */
		private function onLoadError(eventObj:IOErrorEvent):void {			
			this._stream.removeEventListener(ProgressEvent.PROGRESS, this.onLoadProgress);
			this._stream.removeEventListener(Event.COMPLETE, this.onLoadComplete);
			this._stream.removeEventListener(IOErrorEvent.IO_ERROR, this.onLoadError);
			this._stream.removeEventListener(HTTPStatusEvent.HTTP_STATUS, this.onLoadHTTPStatus);
			//TODO: handle the error
		}//onLoadError
		
		/**		 
		 * @private		 
		 */
		private function onLoadComplete(eventObj:Event):void {
			if (this.loadedBinaryData!=null) {				
				if (this._returnType==String) {
					this._loadedData=new String(String(this._loadedBinaryData.toString()));
				} else if (this._returnType==XML) {
					this._loadedData=new XML(String(this._loadedBinaryData.toString()));
				} else if (this._returnType==ByteArray) {
					this._loadedData=this._loadedBinaryData;
				} else {
					//Default to ByteArray
					this._loadedData=this._loadedBinaryData;
				}//else				
			}//if
			this._stream.removeEventListener(ProgressEvent.PROGRESS, this.onLoadProgress);
			this._stream.removeEventListener(Event.COMPLETE, this.onLoadComplete);
			this._stream.removeEventListener(IOErrorEvent.IO_ERROR, this.onLoadError);
			this._stream.removeEventListener(HTTPStatusEvent.HTTP_STATUS, this.onLoadHTTPStatus);
			SwagDispatcher.dispatchEvent(new SwagLoaderEvent(SwagLoaderEvent.COMPLETE), this);
		}//onLoadComplete
		
		/**		 
		 * @private		 
		 */
		private function onLoadHTTPStatus(eventObj:HTTPStatusEvent):void {
			trace ("onLoadHTTPStatus: "+eventObj.toString());
		}//onLoadHTTPStatus
		
		/**
		 * The instance of the data streaming object (<code>URLStream</code> or <code>FileStream</code> instance, depending on 
		 * the runtime), being used to most stream data for this <code>SwagLoader</code> instance.
		 * <p>This value will be <em>null</em> until a load or send operation has been started.</p>
		 */
		public function get stream():* {
			return (this._stream);
		}//get stream
		
		/**
		 * The file path associated with this <code>SwagLoader</code> instance (i.e. the path to the file to be 
		 * downloaded / uploaded).
		 * <p>This value may either be a string which will be analyzed for the most appropriate transport method 
		 * (i.e. using Flash or AIR routines depending on the runtime), a <code>URLRequest</code> instance which
		 * will use <code>URLStream</code> by default, or a <code>File</code> instance which will use 
		 * <code>FileStream</code> by default. The transport method (<code>URLStream</code> or <code>FileStream</code>),
		 * can be changed manually if desired.</p>
		 * 
		 */
		public function get path():* {
			return (this._path);
		}//get path
		
		public function set path(pathSet:*):void {
			this._path=pathSet;			
		}//set path
		
		/**
		 * The raw loaded binary data for the <code>SwagLoader</code> instance.
		 * <p>This object contains all the data loaded by <code>SwagLoader</code> so far. Because
		 * this data may be read during a load operation, it should not be assumed to be complete
		 * until <code>SwagLoader</code> dipatches its completion event.</p>
		 * <p>If no load operation has been started yet, this object will be <em>null</em>.</p>
		 * 
		 */
		public function get loadedBinaryData():ByteArray {
			return (this._loadedBinaryData);
		}//get loadedBinaryData	
		
		/**
		 * A reference to the data loaded by the <code>SwagLoader</code> instance in its native format,
		 * as specified when the load operation was started.
		 * <p>If a load hasn't completed or started yet, this value will be <em>null</em>.</p> 
		 * @return 
		 * 
		 */
		public function get loadedData():* {
			return (this._loadedData);
		}//get loadedData
		
		/**
		 * Identifies the type of transport being used to load the file data.
		 * <p>The valid transport types (currently local, or AIR, and remote, or URL),
		 * can be found as class constants of the <code>SwagLoader</code> class.		 
		 */
		public function get transport():String {
			if (this.path==null) {
				return (SwagLoader.NOTRANSPORT);
			}//if
			if (this.path is String) {
				var localPath:String=new String(this.path);				
			} else if (this.path is URLRequest) {
				localPath=new String(URLRequest(this.path).url);
			} else if (this.path is File) {
				localPath=new String(File(this.path).url);
			}//else if
			localPath=SwagDataTools.stripOutsideChars(localPath, SwagDataTools.SEPARATOR_RANGE+SwagDataTools.PUNCTUATION_RANGE);
			var transportString:String=SwagDataTools.getStringBefore(localPath, ":", false);
			//No transport specified...
			if ((transportString==null) || (transportString=="")) {
				if (SwagSystem.isAIR) {
					return (SwagLoader.LOCALTRANSPORT);
				} else {
					return (SwagLoader.REMOTETRANSPORT);
				}//else
			} else {
				//Transport is a local file URL or a local file path (starting with a drive letter).
				if ((transportString=="file") || (transportString=="app-storage") 
				  || (transportString=="app") || (transportString.length==1)) {
					if (SwagSystem.isAIR) {
						return (SwagLoader.LOCALTRANSPORT);
					} else {
						return (SwagLoader.REMOTETRANSPORT);
					}//else
				} else {
					return (SwagLoader.REMOTETRANSPORT);
				}//else
				return (SwagLoader.NOTRANSPORT);
			}//else
			return (SwagLoader.NOTRANSPORT);
		}//get transport
		
		/**
		 * The total bytes loaded for the <code>SwagLoader</code> instance.
		 * <p>If no load operation has been started, or if no data has yet been loaded, this value will
		 * be 0.</code>		 
		 * 
		 */
		public function get bytesLoaded():uint {
			var returnValue:uint=new uint();
			returnValue=0;
			if (this.loadedBinaryData!=null) {
				returnValue=this.loadedBinaryData.length;
			}//if
			return (returnValue)
		}//get bytesLoaded
		
		/**
		 * @private 
		 * 
		 * Returns an instance of an AIR File class if the current runtime supports it, or <em>null</em>
		 * if the current runtime isn't AIR.
		 */
		private static function get File():Class {
			try {
				var classRef:Class=getDefinitionByName("flash.filesystem.File") as Class;
				return (classRef);
			} catch (e:ReferenceError) {
				return (null);	
			}//catch
			return (null);
		}//get File
		
		/**
		 * @private 
		 * 
		 * Returns an instance of an AIR FileStream class if the current runtime supports it, or <em>null</em>
		 * if the current runtime isn't AIR.
		 */
		private static function get FileStream():Class {
			try {
				var classRef:Class=getDefinitionByName("flash.filesystem.FileStream") as Class;
				return (classRef);
			} catch (e:ReferenceError) {
				return (null);	
			}//catch
			return (null);
		}//get FileStream
		
		/**
		 * @private 
		 * 
		 * Returns an instance of an AIR FileMode class if the current runtime supports it, or <em>null</em>
		 * if the current runtime isn't AIR.
		 */
		private static function get FileMode():Class {
			try {
				var classRef:Class=getDefinitionByName("flash.filesystem.FileMode") as Class;
				return (classRef);
			} catch (e:ReferenceError) {
				return (null);	
			}//catch
			return (null);
		}//get FileMode
		
	}//SwagLoader class
	
}//package