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
    private var leaveBtn:FlxButton;
    private var startBtn:FlxButton;
    
    override public function create() {
        FlxG.stage.window.title = "Moon4K - OnlineMenuState";

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
        
        leaveBtn = new FlxButton(0, playersList.y + 100, "Leave Room", leaveLobby);
        leaveBtn.screenCenter(X);
        leaveBtn.visible = false;
        add(leaveBtn);
        
        startBtn = new FlxButton(0, leaveBtn.y, "Start Game", startGame);
        startBtn.screenCenter(X);
        startBtn.y = leaveBtn.y + leaveBtn.height + 10;
        startBtn.visible = false;
        add(startBtn);
        
        try {
            Server.connect("127.0.0.1", 8080);
            statusText.text = "Connected to server!";
        } catch(e) {
            statusText.text = "Failed to connect: " + e;
        }
    }
    
    override public function update(elapsed:Float) {
        #if desktop
		Discord.changePresence("In a lobby! Code: " + Server.roomCode, null); // i think showing the code in discord rpc should be toggable - abdumannan1340
		#end
        super.update(elapsed);
        
        if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE)
            transitionState(new MainMenuState());

        if (Server.roomCode != "") {
            roomCode.text = "Room Code: " + Server.roomCode;
            createBtn.visible = false;
            joinBtn.visible = false;
            leaveBtn.visible = true;
            
            startBtn.visible = Server.isHost;
            
            var playersText = "Players in Room:\n";
            playersText += (Server.isHost ? "👑 " : "") + (FlxG.save.data.playerName ?? "Player") + " (You)\n";
            if (Server.otherPlayerName != "") {
                playersText += (Server.isHost ? "" : "👑 ") + Server.otherPlayerName;
            }
            playersList.text = playersText;
        } else {
            createBtn.visible = true;
            joinBtn.visible = true;
            leaveBtn.visible = false;
            startBtn.visible = false;
            playersList.text = "";
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
    
    private function leaveLobby() {
        Server.sendMessage("leave_room", {});
        Server.roomCode = "";
        Server.otherPlayerName = "";
        Server.isHost = false;
        statusText.text = "Left room";
    }
    
    private function startGame() {
        if (Server.isHost && Server.otherPlayerName != "") {
            Server.sendMessage("force_start", {});
            var freeplay = new Freeplay();
            freeplay.isOnline = true;
            freeplay.isHost = true;
            transitionState(freeplay);
        }
    }
} 