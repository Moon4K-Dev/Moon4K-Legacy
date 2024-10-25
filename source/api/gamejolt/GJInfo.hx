package api.gamejolt;

class GJInfo {
	/**
	 * Inline variable to change the font for the GameJolt API elements.
	 * @param font You can change the font by doing **Paths.font([Name of your font file])** or by listing your file path.
	 * If *null*, will default to the normal font.
	 */
	public static var font:String = null; /* Example: Paths.font("vcr.ttf"); */

	/**
	 * Inline variable to change the font for the notifications made by Firubii.
	 * 
	 * Don't make it a NULL variable. Worst mistake of my life.
	 */
	public static var fontPath:String = "assets/fonts/vcr.ttf";

	/**
	 * Image to show for notifications. Leave NULL for no image, it's all good :)
	 * 
	 * Example: Paths.getLibraryPath("images/stepmania-icon.png")
	 */
	public static var imagePath:String = null;

	/* Other things that shouldn't be messed with are below this line! */
	/**
	 * GameJolt + FNF version.
	 */
	public static var version:String = "1.0";

	// GJ ID
	public static var id:Int = 913345;

	/**
	 * Random quotes I got from other people. Nothing more, nothing less. Just for funny.
	 */
	public static var textArray:Array<String> = [
		"Chud fnf Darnell week 8 leak",
		"127.0.0.1 - be scared,",
		"Ily ninjamuffin99...",
		"mm chez burger...",
		"Thank you Firubii for the notification code :)"
	];
}
