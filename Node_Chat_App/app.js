const express = require('express');

const app = express();
const PORT = process.env.PORT || 4000;
const server = app.listen(PORT, ()=> {
    console.log('Server is working on', PORT);
});

const io = require('socket.io')(server);
const connectedUser = new Set();

io.on('connection', (socket) =>{
    console.log('Connection successfully', socket.id);
    
    connectedUser.add(socket.id);
    io.emit('connected-user', connectedUser.size);
    //Disconnect
    socket.on('disconnect', () => {
        console.log('Disconnected', socket.id);
        connectedUser.delete(socket.id);
        io.emit('connected-user', connectedUser.size);
    });

    //Handle event from client
    socket.on('message', (msg) => {
        console.log(msg);
        socket.broadcast.emit('message-receice', msg)
    });
});