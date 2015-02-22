

var IOPORT = 4444;

// SOCKET.IO SECTION.
var http = require('http');
var fs = require('fs');
var index = fs.readFileSync(__dirname + '/index.html');
var app = http.createServer(function(req, res){
        console.log(res, req);
        res.writeHead(200, {'Content-Type': 'text/html'});
        res.end(index);
});
var sockio = require('socket.io').listen(app);


sockio.sockets.on("connection", function(socket){
        socket.emit('welcome', { message: 'Welcome!' });
        console.log("ASD", socket);
});
app.listen(IOPORT);

