package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import network.Server;
import substates.RoomCodeInput;

class OnlineMenuState extends SwagState {
    private var roomCode:FlxText;
    private var statusText:FlxText;
    private var createBtn:FlxButton;
    private var joinBtn:FlxButton;
    private var playersList:FlxText;
    
    override public function create() {
        super.create();
        
        createBtn = new FlxButton(0, 0, "Create Room", createRoom);
        createBtn.screenCenter();
        add(createBtn);
        
        joinBtn = new FlxButton(0, createBtn.y + 50, "Join Room", joinRoom);
        joinBtn.screenCenter(X);
        add(joinBtn);
        
        roomCode = new FlxText(0, joinBtn.y + 50, FlxG.width, "", 32);
        roomCode.alignment = CENTER;
        add(roomCode);
        
        statusText = new FlxText(0, roomCode.y + 50, FlxG.width, "", 24);
        statusText.alignment = CENTER;
        add(statusText);
        
        playersList = new FlxText(0, statusText.y + 50, FlxG.width, "", 24);
        playersList.alignment = CENTER;
        add(playersList);
        
        try {
            Server.connect("127.0.0.1", 8080);
            statusText.text = "Connected to server!";
        } catch(e) {
            statusText.text = "Failed to connect: " + e;
        }
    }
    
    override public function update(elapsed:Float) {
        super.update(elapsed);
        

        if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE)
            transitionState(new MainMenuState());

        if (Server.roomCode != "") {
            roomCode.text = "Room Code: " + Server.roomCode;
            createBtn.visible = false;
            joinBtn.visible = false;
            
            var playersText = "Players in Room:\n";
            playersText += (Server.isHost ? "👑 " : "") + (FlxG.save.data.playerName ?? "Player") + " (You)\n";
            if (Server.otherPlayerName != "") {
                playersText += (Server.isHost ? "" : "👑 ") + Server.otherPlayerName;
            }
            playersList.text = playersText;
        }
        
        if (!Server.isConnected) {
            statusText.text = "Disconnected from server";
        }
    }
    
    private function createRoom() {
        if (Server.isConnected) {
            Server.sendMessage("create_room", {
                playerName: FlxG.save.data.playerName ?? "Player"
            });
            statusText.text = "Creating room...";
        } else {
            statusText.text = "Not connected to server!";
        }
    }
    
    private function joinRoom() {
        if (Server.isConnected) {
            openSubState(new RoomCodeInput(function(code:String) {
                Server.sendMessage("join_room", {
                    code: code,
                    playerName: FlxG.save.data.playerName ?? "Player"
                });
                statusText.text = "Joining room...";
            }));
        } else {
            statusText.text = "Not connected to server!";
        }
    }
} 