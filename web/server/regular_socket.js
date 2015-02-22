var SOCKPORT = 3333;
var IOPORT = 4444;
var HOST = "localhost";
var DBNAME = "dpa";

var net = require('net');
var server = net.createServer();
var sql = require('sqlite3');
var db = new sql.Database(DBNAME);

var dataCount = 0;

var webSock;
// FUNCTIONS
function initDatabase(db){
	db.run("CREATE TABLE if not exists plates(id integer not null primary key autoincrement, street_id integer, timestamp integer, plate varchar(255), lat varchar(255), long varchar(255))");
	db.run("CREATE TABLE if not exists streets(id integer not null primary key autoincrement, start_lat varchar(255), end_lat varchar(255), start_long varchar(255), end_long varchar(255), max_spots int)");
	db.run("CREATE TABLE if not exists spots(id integer not null primary key autoincrement, timestamp int, lat varchar(255), long varchar(255), street_id int)");
}

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
function dropTables(db){
	db.run("drop table plates");
	db.run("drop table streets");
	db.run("drop table spots");
}
//
//dropTables(db);
initDatabase(db);
server.listen(SOCKPORT);
server.on('connection', function(socket){ // Client connected // 
	console.log("Client Connected");
	socket.on('data', function(data){
		var message = data.toString().replace("\r\n", "");
		message = message.split(" ");
		console.log(message); // Message: insert plateno time longitude latitude
		switch(message[0]){
		case "insert":
			var sttmnt = db.prepare("insert into plates (plate, timestamp, lat, long) values (?, ?, ?, ?)");	
			longitude = latitude = undefined;
			if(message.length > 3){
				longitude = message[3];
				latitude = message[4];
			}
			sttmnt.run(message[1].toString(), Number(message[2]), longitude, latitude);
			sttmnt.finalize();
			console.log("INSERTED");
			dataCount++;
			webSock.emit('plate', { message: JSON.stringify(message)});
			//webSock.emit('
			break;
		case "read":
			db.each("select * from plates", function(err, row){
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
	console.log("WEB CLIENT CONNECTED");
	var data = {"plates":[], "spots":[], "streets":[]};
	//data["plates"].push(1);
	//data["spots"].push(2);
	//data["streets"].push(3);
	db.each("select * from plates", function(err, row){
		data.plates.push(row);
		webSock.emit("plate", {message: row}); 
	});
	db.each("select * from spots", function(err, row){
		data.spots.push(row);
		webSock.emit("spot", {message: row});
	});
	db.each("select * from streets", function(err, row){
		data.streets.push(row);
		webSock.emit("streets", {message: row});
	});
	
	webSock.on("end", function(){
		console.log("WEBSOCKET DISCONNECTED");
	});

});
app.listen(IOPORT);

