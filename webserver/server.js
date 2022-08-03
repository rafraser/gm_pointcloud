import express from 'express';
import http from 'http';
import { Server as IOServer } from 'socket.io';

// Create a simple express server + a socket.io server on the same port
const app = express();
const server = http.createServer(app);
const io = new IOServer(server);

// Simple relay for points
app.use(express.json({ limit: '10mb', type: '*/*' }));
app.post('/data', (req, res) => {
  io.emit('points', req.body);
  console.log('Broadcasting', req.body.length, 'points');
  res.sendStatus(200);
});

app.use(express.static('public'));

// Start the server!
const port = process.env.PORT || 3000;
server.listen(port, () => {
  console.log(`Server listening on *:${port}`);
});
