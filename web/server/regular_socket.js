var SOCKPORT = 3333;
var IOPORT = 4444;
var HOST = "localhost";
var DBNAME = "dpa";

var net = require('net');
var server = net.createServer();
var sql = require('sqlite3');
var db = new sql.Database(DBNAME);

var dataCount = 0;
//var newDataEvent = new Event('newData');

var webSock;
// FUNCTIONS
function getTime(){
	return Math.floor(Date.now() / 1000);
}

function bsGps(pta, ptb, nd){
	// a, b == ARRAY OF X AND Y COORDS
	// nd == NUMBER TO DIVIDE BY. ASSUMED NUM OF CARS.
	var a = typeof pta === 'undefined' ? [39.953824, -75.187293]:pta;
	var b = typeof ptb === 'undefined' ? [39.953579, -75.185348]:ptb;
	var delta = [a[0] - b[0], a[1] - b[1]];
	var numDivision = typeof nd === 'undefined' ? 10:nd;
	var arr = [a];
	for(var i = 1; i < numDivision; i++){
		arr.push([arr[i - 1][0] + delta[0]/numDivision, arr[i - 1][1] + delta[1]/numDivision]);
		
	}
	console.log("DELTA : ", delta);
	return arr;
}

// WRAPPERS //
function createTable(db){
	db.run("CREATE TABLE if not exists dpa (plate varchar(255), time int)");
}

function dropTable(db){
	db.run("drop table dpa");
}
//

createTable(db);
server.listen(SOCKPORT);
server.on('connection', function(socket){ // Client connected // 
	console.log("Client Connected");
	socket.on('data', function(data){
		var message = data.toString();
		message = message.split(" ");
		console.log(message);
		switch(message[0]){
		case "insert":
			var sttmnt = db.prepare("insert into dpa (plate, time) values (?, ?)");	
			sttmnt.run(message[1].toString(), Number(message[2]));
			sttmnt.finalize();
			console.log("INSERTED");
			dataCount++;
			webSock.emit('welcome', { message: message});
			break;
		case "read":
			db.each("select * from dpa", function(err, row){
				console.log(row);
			});		
			break;
		case "truncate":
			dropTable(db);
			createTable(db);
			console.log("TRUNCATED");
			break;
		case "bsgps":
			console.log(bsGps());
			break;

		}
	});
	
	socket.on('error', function(error){
		console.log("ERROR", getTime());
		console.log(error);
	});
	
	socket.on('end', function(){
		console.log("Client Disconnected", client, getTime());
	});
});


// SOCKET.IO SECTION.
var http = require('http');
var fs = require('fs');
var index = fs.readFileSync(__dirname + '/index.html');
var app = http.createServer(function(req, res){
        res.writeHead(200, {'Content-Type': 'text/html'});
        res.end(index);
});
var sockio = require('socket.io').listen(app);

sockio.sockets.on("connection", function(socket){
	webSock = socket;
        console.log("ASD", socket);
});
app.listen(IOPORT);

