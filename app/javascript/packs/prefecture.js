let stringToHTML = function(str){
  let dom = document.createElement('div');
  dom.innerHTML = str;
  return dom;
};

document.addEventListener('DOMContentLoaded', function(){
  let prefecture = document.querySelector('#prefecture_select');
  let cityContainer = document.querySelector('#city');

  let defaultCitySelect = `
    <select name="city" id="city" class="search-field">
      <option value>ーーーーーーーーーーーー</option>
    </select>`;

  prefecture.addEventListener('change', function(){
    let prefectureId = prefecture.value;

    if(prefectureId === ''){
      cityContainer.innerHTML = defaultCitySelect;
    }else{
      let selectedTemplate = document.querySelector(`#city-select${prefectureId}`);
      cityContainer.innerHTML = selectedTemplate.innerHTML;
    }
  });
});
