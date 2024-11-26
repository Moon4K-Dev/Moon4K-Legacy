const net = require('net');

const rooms = new Map();

const server = net.createServer((socket) => {
    console.log('Client connected');
    
    let buffer = '';
    
    socket.on('data', (data) => {
        buffer += data.toString();
        
        let newlineIndex;
        while ((newlineIndex = buffer.indexOf('\n')) !== -1) {
            const line = buffer.slice(0, newlineIndex);
            buffer = buffer.slice(newlineIndex + 1);
            
            try {
                const data = JSON.parse(line);
                handleMessage(socket, data);
            } catch (e) {
                console.error('Error parsing message:', e);
            }
        }
    });

    socket.on('end', () => handleDisconnect(socket));
    socket.on('error', (err) => {
        console.error('Socket error:', err);
        handleDisconnect(socket);
    });
});

function sendToSocket(socket, data) {
    socket.write(JSON.stringify(data) + '\n');
}

function handleMessage(socket, data) {
    switch(data.type) {
        case 'create_room':
            const roomCode = Math.random().toString(36).substring(2, 8);
            rooms.set(roomCode, {
                host: socket,
                players: [{
                    socket: socket,
                    name: data.playerName
                }]
            });
            sendToSocket(socket, {
                type: 'create_room',
                room: roomCode,
                isHost: true
            });
            break;

        case 'join_room':
            const room = rooms.get(data.code);
            if (room && room.players.length < 2) {
                room.players.push({
                    socket: socket,
                    name: data.playerName
                });
                
                sendToSocket(socket, {
                    type: 'join_room',
                    room: data.code,
                    isHost: false,
                    otherPlayerName: room.players[0].name
                });
                
                sendToSocket(room.players[0].socket, {
                    type: 'player_joined',
                    playerName: data.playerName
                });
            }
            break;
            
        case 'note_hit':
        case 'score_update':
            for (const [code, roomData] of rooms) {
                if (roomData.players.some(p => p.socket === socket)) {
                    roomData.players
                        .filter(p => p.socket !== socket)
                        .forEach(p => sendToSocket(p.socket, data));
                    break;
                }
            }
            break;

        case 'leave_room':
            for (const [code, room] of rooms) {
                const playerIndex = room.players.findIndex(p => p.socket === socket);
                if (playerIndex !== -1) {
                    room.players.splice(playerIndex, 1);
                    
                    if (room.players.length > 0) {
                        sendToSocket(room.players[0].socket, {
                            type: 'player_left'
                        });
                    }
                    
                    if (room.players.length === 0) {
                        rooms.delete(code);
                    }
                    break;
                }
            }
            break;

        case 'force_start':
            for (const [code, room] of rooms) {
                if (room.host === socket) { 
                    room.players
                        .filter(p => p.socket !== socket)
                        .forEach(p => sendToSocket(p.socket, {
                            type: 'force_start'
                        }));
                    break;
                }
            }
            break;
    }
}

function handleDisconnect(socket) {
    console.log('Client disconnected');
    for (const [code, room] of rooms) {
        const playerIndex = room.players.findIndex(p => p.socket === socket);
        if (playerIndex !== -1) {
            room.players.splice(playerIndex, 1);
            
            if (room.players.length > 0) {
                sendToSocket(room.players[0].socket, {
                    type: 'player_left'
                });
            }
            
            if (room.players.length === 0) {
                rooms.delete(code);
            }
            break;
        }
    }
}

const PORT = 8080;
server.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
});