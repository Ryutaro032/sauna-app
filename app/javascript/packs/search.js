document.addEventListener('DOMContentLoaded', function() {
  initMap();
});

document.addEventListener('turbolinks:load', function(){
  initMap();
});

function initMap() {
  let facilityLat = parseFloat(document.getElementById('map').dataset.lat);
  let facilityLng = parseFloat(document.getElementById('map').dataset.lng);
  let facilityLocation = { lat: facilityLat, lng: facilityLng };

  let map = new google.maps.Map(document.getElementById('map'), {
    zoom: 15,
    center: facilityLocation
  });

  let marker = new google.maps.Marker({
    position: facilityLocation,
    map: map
  });
}

if (typeof google !== 'undefined') {
  initMap();
} else {
  window.initMap = initMap;
}
