let map
let geocoder
let marker = [];
let infoWindow = [];
let allStore = gon.places;
let markerData = [];

for(let i = 0; i < allStore.length; i++){
  markerData.push({
    title: allStore[i]['name'],
    lat: allStore[i]['lat'],
    lng: allStore[i]['lng'],
    content: allStore[i]['name']
  });
};

function centerStore(lat, lng){
  geocoder = new google.maps.Geocoder();
  let mapStoreMarker = new google.maps.LatLng({lat: Number(lat), lng: Number(lng)});
  map = new google.maps.Map(document.getElementById('map'), {
    center: mapStoreMarker,
    zoom: 15, 
  });
  allStoreMarker(markerData);
  markerData.forEach((data, key) => {
    if(data['lat'] == lat && data['lng'] == lng){
      infoWindow[key].open(map, marker[key]);
    };
  });
};

function initMap(){
  geocoder = new google.maps.Geocoder();
  let mapLatLng = new google.maps.LatLng({lat: markerData[0]['lat'], lng: markerData[0]['lng']});
  map = new google.maps.Map(document.getElementById('map'), {
      center: mapLatLng, 
      zoom: 13, 
  });
  allStoreMarker(markerData);
};


function allStoreMarker(markerData){
  for (var i = 0; i < markerData.length; i++){
    markerLatLng = new google.maps.LatLng({lat: markerData[i]['lat'], lng: markerData[i]['lng']});
    marker[i] = new google.maps.Marker({
      position: markerLatLng, 
      map: map, 
      
    });
    infoWindow[i] = new google.maps.InfoWindow({
      content: markerData[i].title
    });
    markerEvent(i);
  };
};

function markerEvent(i){
  marker[i].addListener('click', function(){
    infoWindow[i].open(map, marker[i]);
  });
};

function listClickHandler(lat, lng){
  centerStore(lat, lng);

  markerData.forEach((data, key) => {
    if(data['lat'] == lat && data['lng'] == lng){
      infoWindow[key].open(map, marker[key]);
    };
  });
}

document.addEventListener('DOMContentLoaded', function(){
  facilitySelection();
});

document.addEventListener('turbolinks:load', function(){
  facilitySelection();
});

function facilitySelection(){
  const listItems = document.querySelectorAll('.list-item');

  listItems.forEach(item => {
    item.addEventListener('click', function() {
      const lat = this.getAttribute('data-lat');
      const lng = this.getAttribute('data-lng');

      listClickHandler(lat, lng);
    });
  });
}

window.initMap = initMap;
window.centerStore = centerStore;
window.allStoreMarker = allStoreMarker;
window.markerEvent = markerEvent;
window.listClickHandler = listClickHandler;
