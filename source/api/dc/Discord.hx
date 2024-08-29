package api.dc;
#if desktop
import hxdiscord_rpc.Discord as RichPresence;
import hxdiscord_rpc.Types;
import openfl.Lib;
import sys.thread.Thread;

class Discord {
	public static var initialized:Bool = false;

	public static function load():Void {
		if (initialized)
			return;

		var handlers:DiscordEventHandlers = DiscordEventHandlers.create();
		handlers.ready = cpp.Function.fromStaticFunction(onReady);
		handlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		handlers.errored = cpp.Function.fromStaticFunction(onError);
		RichPresence.Initialize(Utils.discordRpc, cpp.RawPointer.addressOf(handlers), 1, null);

		// Daemon Thread
		Thread.create(function() {
			while (true) {
				RichPresence.RunCallbacks();
				Sys.sleep(1);
			}
		});

		Lib.application.onExit.add((exitCode:Int) -> RichPresence.Shutdown());

		initialized = true;
	}

	public static function changePresence(details:String, ?state:String, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float):Void {
		var discordPresence:DiscordRichPresence = DiscordRichPresence.create();
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0) {
			endTimestamp = startTimestamp + endTimestamp;
		}

		discordPresence.details = details;

		if (state != null)
			discordPresence.state = state;

		discordPresence.largeImageKey = "rpcicon";
		discordPresence.largeImageText = 'Game by @yophlox';
		discordPresence.smallImageKey = smallImageKey;
		discordPresence.startTimestamp = Std.int(startTimestamp / 1000);
		discordPresence.endTimestamp = Std.int(endTimestamp / 1000);
		RichPresence.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));
	}

	private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void {
		final user:cpp.Star<DiscordUser> = cpp.ConstPointer.fromRaw(request).ptr;

		if (Std.parseInt(cast(user.discriminator, String)) != 0)
			trace('(Discord) Connected to User "${cast (user.username, String)}#${cast (user.discriminator, String)}"');
		else
			trace('(Discord) Connected to User "${cast (user.username, String)}"');

		Discord.changePresence('Just Started');
	}

	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void {
		trace('(Discord) Disconnected ($errorCode: ${cast (message, String)})');
	}

	private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void {
		trace('(Discord) Error ($errorCode: ${cast (message, String)})');
		// spammed with """errors"""
	}
}
#end