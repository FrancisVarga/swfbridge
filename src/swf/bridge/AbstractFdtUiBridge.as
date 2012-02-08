package swf.bridge {
	import swf.plugin.ISwfWindowPlugin;

	import flash.display.LoaderInfo;

	/***
	 * Please do not use this class. It is for internal use.
	 */
	public class AbstractFdtUiBridge extends AbstractFdtBridge {
		private var _swfUiPlugin : ISwfWindowPlugin;

		/***
		 * This constructor may change in future, please use 
		 * <code>FdtViewBridge</code>, <code>FdtDialogBridge</code>, or <code>IFdtActionBrige</code>
		 * to get access to the requestors. 
		 */
		public function AbstractFdtUiBridge(loaderInfo : LoaderInfo, swfUiPlugin : ISwfWindowPlugin) {
			super(loaderInfo, swfUiPlugin);
			_swfUiPlugin = swfUiPlugin;
		}

		/***
		 * Please do not use this function. It is for internal use. 
		 */
		override protected function readExtendedMessage(messageID : int) : void {
			if (messageID < 4000) {
				readBaseUiMessage(messageID);
			} else {
				readExtendedUiMessage(messageID);
			}
		}

		private function readBaseUiMessage(messageID : int) : void {
			switch (messageID) {
				case 2500:
					baseOpened(_bridgeSocket.readInt(), _bridgeSocket.readInt());
					return;
				case 2501:
					_swfUiPlugin.setSize(_bridgeSocket.readInt(), _bridgeSocket.readInt());
					return;
				case 2502:
					var callerInstanceId : String = _bridgeSocket.readUTF();
					var dialogInstanceId : String = _bridgeSocket.readUTF();
					var result : String = _bridgeSocket.readUTF();
					dialogClosed(callerInstanceId, dialogInstanceId, result);
					return;
				case 2525:
					var entryId : String = _bridgeSocket.readUTF();
					callEntryAction(entryId);
			}
		}

		/***
		 * Please do not use this function. It is for internal use. 
		 */
		protected function callEntryAction(entryId : String) : void {
		}

		/***
		 * Please do not use this function. It is for internal use. 
		 */
		protected function dialogClosed(callerInstanceId : String, dialogInstanceId : String, result : String) : void {
			_swfUiPlugin.dialogClosed(dialogInstanceId, result);
		}

		/***
		 * Please do not use this function. It is for internal use. 
		 */
		protected function readExtendedUiMessage(messageID : int) : void {
		}

		/***
		 * Please do not use this function. It is for internal use. 
		 */
		internal function baseOpened(width : int, height : int) : void {
			_swfUiPlugin.setSize(width, height);
		}
	}
}
