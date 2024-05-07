let stringToHTML = function(str){
  let dom = document.createElement('div');
  dom.innerHTML = str;
  return dom;
};

document.addEventListener('DOMContentLoaded', function(){
  initializeCitySelection();
});

document.addEventListener('turbolinks:load', function(){
  initializeCitySelection();
});

function initializeCitySelection(){
  let prefecture = document.querySelector('#prefecture_select');
  let cityContainer = document.querySelector('#city_id');

  if(prefecture && cityContainer){
    prefecture.addEventListener('change', function(){
      let prefectureId = prefecture.value;

      if(prefectureId === ''){
        cityContainer.innerHTML = '';
      }else{
        let selectedTemplate = document.querySelector(`#city-select${prefectureId}`);
        if(selectedTemplate){
          cityContainer.innerHTML = selectedTemplate.innerHTML;
        }
      }
    });
  }
}
