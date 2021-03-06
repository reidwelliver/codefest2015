$(document).ready(function(){
  var map;
  function verifySpotData(data){
    return (data.hasOwnProperty('lat') && data.hasOwnProperty('long'));
  }

  function addSpotsToMap(data){
    if(!Array.isArray(data)){
      data = [data];
    }

    for (var i = data.length - 1; i >= 0; i--) {
      	data = data[0].message;
        console.log(data);
	if(verifySpotData(data)){
        console.log("creating new point, which is pretty cool");
        var marker = new google.maps.Marker({
          position: new google.maps.LatLng(data.lat,data.long),
          map: map
        });
      }
    };
  }

  var socket = io.connect('http://127.0.0.1:4444');

  socket.on('connect', function () { console.log("socket connected"); });
  socket.on('spot',function(data){
    addSpotsToMap(data);
  });
  socket.on('plate',function(data){
    console.log(data);
  });
  //socket.emit('private message', { user: 'me', msg: 'whazzzup?' });


  /* affix the navbar after scroll below header */
  $('#nav').affix({
        offset: {
          top: $('header').height()-$('#nav').height()
        }
  });	

  /* highlight the top nav as scrolling occurs */
  $('body').scrollspy({ target: '#nav' });

  /* smooth scrolling for nav sections */
  /*
  $('#nav .navbar-nav li>a').click(function(){
    var link = $(this).attr('href');
    var posi = $(link).offset().top;
    $('body,html').animate({scrollTop:posi},700);
  });
  */
  
      function initialize() {
        function getMapStyle(){
          return[
          {"featureType":"all",
            "elementType":"labels",
            "stylers":[
              {"visibility":"on"}
          ]},
          {"featureType":"landscape",
            "elementType":"all",
            "stylers":[
              {"visibility":"on"},
              {"color":"#f9ddc5"}
          ]},
          {"featureType":"landscape.man_made",
            "elementType":"geometry",
            "stylers":[
              {"weight":0.9},
              {"visibility":"off"}
          ]},
          {"featureType":"poi.park",
            "elementType":"geometry.fill",
            "stylers":[
              {"visibility":"on"},
              {"color":"#83cead"}
          ]},
          {"featureType":"road",
            "elementType":"all",
            "stylers":[
              {"visibility":"on"},
              {"color":"#813033"}
          ]},
          {"featureType":"road",
            "elementType":"labels",
            "stylers":[
              {"visibility":"off"}
          ]},

          {"featureType":"road.local",
           "elementType":"all",
            "stylers":[
             {"color":"#f19f53"}
          ]},
          {"featureType":"road.highway",
            "elementType":"all",
            "stylers":[
              {"color":"#c65b5b"}
          ]},
          {"featureType":"road.arterial",
            "elementType":"all",
            "stylers":[
              {"color":"#c65b5b"}
          ]},
          {"featureType":"water",
            "elementType":"all",
            "stylers":[
              {"color":"#7fc8ed"}
          ]}];
        }

        map = new google.maps.Map(
          document.getElementById('map-canvas'),
          {
            center: { lat: 39.953938, lng: -75.188484},
            zoom: 16,
            keyboardShortcuts: false,
            styles: getMapStyle()
          }
        );
      }
      google.maps.event.addDomListener(window, 'load', initialize);
});
