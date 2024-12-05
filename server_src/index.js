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
    try {
        const message = JSON.stringify(data) + '\n';
        console.log('Sending message:', message);
        socket.write(message);
    } catch (e) {
        console.error('Error sending message:', e);
    }
}

function handleMessage(socket, data) {
    console.log('Received message:', data.type, data);

    switch(data.type) {
        case 'create_room':
            const roomCode = Math.random().toString(36).substring(2, 8);
            console.log(`Creating room with code: ${roomCode}`);
            
            rooms.set(roomCode, {
                host: socket,
                players: [{
                    socket: socket,
                    name: data.data.playerName || "Player"
                }]
            });
            
            console.log(`Current rooms: ${Array.from(rooms.keys()).join(', ')}`);
            
            sendToSocket(socket, {
                type: 'create_room',
                room: roomCode,
                isHost: true
            });
            break;

        case 'join_room':
            console.log(`Attempting to join room: ${data.data.code}`);
            const room = rooms.get(data.data.code.toLowerCase());
            if (!room) {
                console.log('Room not found');
                sendToSocket(socket, {
                    type: 'error',
                    message: 'Room not found'
                });
                return;
            }
            
            console.log('Room found:', room);
            console.log('Current players:', room.players.length);
            
            if (room.players.length >= 2) {
                console.log('Room is full');
                sendToSocket(socket, {
                    type: 'error',
                    message: 'Room is full'
                });
                return;
            }
            
            console.log('Joining room with player:', data.data.playerName);
            room.players.push({
                socket: socket,
                name: data.data.playerName
            });
            
            console.log('Sending join confirmation');
            sendToSocket(socket, {
                type: 'join_room',
                room: data.data.code,
                isHost: false,
                otherPlayerName: room.players[0].name
            });
            
            console.log('Notifying host');
            sendToSocket(room.players[0].socket, {
                type: 'player_joined',
                playerName: data.data.playerName
            });
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
server.listen(PORT, '0.0.0.0', () => {
    console.log(`Server listening on port ${PORT} on all interfaces`);
});