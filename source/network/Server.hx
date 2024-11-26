package network;

import sys.net.Socket;
import sys.net.Host;
import haxe.io.Bytes;
import haxe.Json;
import states.*;

class Server {
    private static var socket:Socket;
    public static var isConnected:Bool = false;
    public static var roomCode:String = "";
    public static var isHost:Bool = false;
    public static var otherPlayerName:String = "";

    public static function connect(address:String, port:Int) {
        try {
            socket = new Socket();
            socket.connect(new Host(address), port);
            isConnected = true;
            trace("Connected to server!");
            
            sys.thread.Thread.create(() -> {
                while (isConnected) {
                    try {
                        var data = socket.input.readLine();
                        handleMessage(Json.parse(data));
                    } catch(e) {
                        trace("Error reading from socket: " + e);
                        isConnected = false;
                        break;
                    }
                }
            });
            
        } catch(e) {
            trace("Failed to connect: " + e);
        }
    }

    public static function sendMessage(type:String, data:Dynamic) {
        if (isConnected && socket != null) {
            try {
                var message = {
                    type: type,
                    data: data
                };
                var jsonString = Json.stringify(message) + "\n";
                socket.output.writeString(jsonString);
            } catch(e) {
                trace("Failed to send message: " + e);
                isConnected = false;
            }
        }
    }

    private static function handleMessage(data:Dynamic) {
        if (data == null) return;
        
        switch (data.type) {
            case "join_room":
                roomCode = data.room;
                isHost = data.isHost;
                trace('Joined room: $roomCode (Host: $isHost)');
                
            case "create_room":
                roomCode = data.room;
                isHost = true;  
                trace('Created room: $roomCode (Host: true)');
                
            case "game_start":
                trace('Game starting with song: ${data.song}');
                if (Freeplay.instance != null) {
                    Freeplay.instance.startOnlineSong(data.song);
                }
                
            case "note_hit":
                if (PlayState.instance != null) {
                    PlayState.instance.handleOnlineNoteHit(data.data);
                }
                
            case "score_update":
                if (PlayState.instance != null) {
                    PlayState.instance.updateOpponentScore(
                        data.data.score, 
                        data.data.accuracy,
                        data.data.misses
                    );
                }
                
            default:
                trace("Unknown message type: " + data.type);
        }
    }
}