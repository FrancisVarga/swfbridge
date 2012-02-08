package swf.bridge {
	/***
	 * The editor context describes the current focused editor and its selection (cursor).
	 */
	public class FdtEditorContext {
		/***
		 * the file of the current editor 
		 */
		public var currentFile : String;
		
		/***
		 * the line of the selection start of the editor document
		 */
		public var currentLine : String;
		
		/***
		 * the offset of the line containing the selection start
		 */
		public var currentLineOffset : int;
		
		/***
		 * the offset of the selection start
		 */
		public var selectionOffset : int;
		
		/***
		 * the selection length 
		 */
		public var selectionLength : int;
		
		/***
		 * the line seperator of the current line 
		 */
		public var currentLineSeperator : String;
	}
}
