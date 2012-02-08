package swf.bridge {
	import swf.plugin.ISwfPlugin;

	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	/***
	 * Please use this class only indirect via
	 * <code>FdtViewBridge</code> or <code>FdtDialogBridge</code>. 
	 */
	public class AbstractFdtBridge {
		private var _instanceId : String;
		private static var _stampCounter : int;
		private var _stampMap : Dictionary = new Dictionary();
		private var _messageID : int = -1;
		private var _messageLen : int = 0;
		private var _coreRequestor : FdtCoreRequestor;
		private var _workspaceRequestor : FdtWorkspaceRequestor;
		private var _editorRequestor : FdtEditorRequestor;
		protected var _modelRequestor : FdtModelRequestor;
		
		protected var _parameters : Object;
		protected var _swfPlugin : ISwfPlugin;
		protected var _bridgeSocket : Socket;
		protected var _lastStamp : int = -1; 
		protected var _byteBuffer : ByteArray = new ByteArray();

		/***
		 * This constructor may change in future, please use 
		 * <code>FdtViewBridge</code>, <code>FdtDialogBridge</code>, or <code>IFdtActionBrige</code>
		 * to get access to the requestors. 
		 */
		public function AbstractFdtBridge(loaderInfo : LoaderInfo, swfPlugin : ISwfPlugin) {
			_swfPlugin = swfPlugin;
			_parameters = loaderInfo.parameters;
			_instanceId = _parameters["Instance"];
			trace("A:" + _instanceId);
			trace("B:" + _parameters["SwfBridgeHost"]);
			trace("C:" + _parameters["SwfBridgePort"]);
			_bridgeSocket = new Socket(_parameters["SwfBridgeHost"], _parameters["SwfBridgePort"]);
			_bridgeSocket.addEventListener(Event.CLOSE, bridgeCloseHandler);
			_bridgeSocket.addEventListener(Event.CONNECT, bridgeConnectHandler);
			_bridgeSocket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_bridgeSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			_bridgeSocket.addEventListener(ProgressEvent.SOCKET_DATA, bridgeSocketDataHandler);
			_coreRequestor = new FdtCoreRequestor(this);
			_workspaceRequestor = new FdtWorkspaceRequestor(this);
			_modelRequestor = new FdtModelRequestor(this);
			_editorRequestor = new FdtEditorRequestor(this);											
		}

		private function bridgeSocketDataHandler(event : ProgressEvent) : void {
			var len : uint = _bridgeSocket.bytesAvailable;
			while (len > 0) {
				trace(_messageID + "::" + _messageLen + " -- " + len + "  " + _bridgeSocket.bytesAvailable);
				if (_messageID == -1) {
					if (len >= 6) {
						_messageLen = _bridgeSocket.readInt();
						_messageID = _bridgeSocket.readShort();
						_byteBuffer.clear();
						_lastStamp = -1;
						_messageLen = _messageLen - 2;
						len = len - 6;
					} else {
						return;
					}
				}
				if (_messageID > 20000) {
					if (_messageID == 20002) {					
					  	if (_lastStamp == -1) {
							if (len >= 4){
								len = len - 4;						
								_messageLen = _messageLen - 4;
								_lastStamp = _bridgeSocket.readInt(); 
							} else {
								return;
							}
					  	} 
					}
					var toRead : uint = Math.min(_messageLen, len);
					if (toRead > 0) {
						_bridgeSocket.readBytes(_byteBuffer, _byteBuffer.length, toRead);
					}
					_messageLen = _messageLen - toRead;
					len = len - toRead;
					if (_messageLen == 0) {
						readBufferedMessage(_messageID);
						_byteBuffer.clear();
						_messageID = -1;
					}
				} else if (_messageID > -1 && len >= _messageLen) {
					readMessage(_messageID);
					len = len - _messageLen;
					_messageID = -1;
				}
				//trace(len);
			}
		}

		private function securityErrorHandler(event : SecurityErrorEvent) : void {
			trace("Security: " + event);
		}

		private function ioErrorHandler(event : IOErrorEvent) : void {
			trace("ioError: " + event);
		}

		private function bridgeConnectHandler(event : Event) : void {
			_bridgeSocket.writeByte(19);
			_bridgeSocket.writeUTF(_instanceId);
			_bridgeSocket.flush();
			initPlugin();
		}

		/***
		 * Please do not use this function. It is for internal use. 
		 */
		protected function initPlugin() : void {
		}

		private function bridgeCloseHandler(event : Event) : void {
		}

		/***
		 * Please do not use this function. It is for internal use. 
		 */
		protected function readBufferedMessage(messageID : int) : void {
			if (messageID == 20002){
				readStampedLongMessage();
			}
		}

		private function readMessage(messageID : int) : void {
			if (messageID == 2) {
				readStampedMessage();
			}
			if (messageID < 2000) {
				readBaseMessage(messageID);
			} else {
				readExtendedMessage(messageID);
			}
		}

		private function readStampedMessage() : void {
			var stamp : int = _bridgeSocket.readInt();
			var o : Object = _stampMap[stamp];
			o.method.call(o.callObject, _bridgeSocket);
			delete _stampMap[stamp];
		}

		private function readStampedLongMessage() : void {
			var stamp : int = _lastStamp;
			var o : Object = _stampMap[stamp];
			o.method.call(o.callObject, _byteBuffer);
			delete _stampMap[stamp];
			_lastStamp = -1;
			_byteBuffer = new ByteArray();
		}

		/***
		 * Please do not use this function. It is for internal use. 
		 */
		protected function readBaseMessage(messageID : int) : void {
		}

		/***
		 * Please do not use this function. It is for internal use. 
		 */
		protected function readExtendedMessage(messageID : int) : void {
		}

		/***
		 * Please do not use this function. It is for internal use. 
		 */
		private static function getNextStamp() : int {
			_stampCounter++;
			return _stampCounter;
		}

		/***
		 * Please do not use this function. It is for internal use. 
		 */
		internal function sendStampedMessage(messageId : int, thisObject : Object, receive : Function) : void {
			var stamp : int = getNextStamp();
			_stampMap[stamp] = { callObject : thisObject, method:receive};
			_bridgeSocket.writeShort(messageId);
			_bridgeSocket.writeInt(stamp);
		}

		/***
		 * Please do not use this function. It is for internal use. 
		 */
		internal function get bridgeSocket() : Socket {
			return _bridgeSocket;
		}

		/***
		 * Use this requestor to access core functions
		 */
		public function get core() : FdtCoreRequestor {
			return _coreRequestor;
		}

		/***
		 * Use this requestor to access workspace functions
		 */
		public function get workspace() : FdtWorkspaceRequestor {
			return _workspaceRequestor;
		}

		/***
		 * Use this requestor to access model functions
		 */
		public function get model() : FdtModelRequestor {
			return _modelRequestor;
		}

		/***
		 * Use this requestor to access editor functions
		 */
		public function get editor() : FdtEditorRequestor {
			return _editorRequestor;
		}

		/***
		 * The instance id of the swf bridge. This id is unique among 
		 * all bridges to fdt.
		 */		
		public function get instanceId() : String {
			return _instanceId;			
		}

		/***
		 * Creates a new request. 
		 */
		public function newRequest() : FdtRequest {
			return new FdtRequest();
		}

	}
}
