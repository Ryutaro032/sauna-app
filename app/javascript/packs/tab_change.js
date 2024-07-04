document.addEventListener('DOMContentLoaded', function() {
  initializeTabSwitching();
});

document.addEventListener('turbolinks:load', function() {
  initializeTabSwitching();
});

function initializeTabSwitching(){
  const tabs = document.querySelectorAll('.tab');
  const tabBoxes = document.querySelectorAll('.tabbox');

  if (tabs.length && tabBoxes.length){
    tabs.forEach((tab, index) => {
      tab.addEventListener('click', function() {

        const activeTab = document.querySelector('.tab-active');
        const activeBox = document.querySelector('.box-show');

        if (activeTab){
          activeTab.classList.remove('tab-active');
        }
        if (activeBox){
          activeBox.classList.remove('box-show');
        }

        tab.classList.add('tab-active');
        tabBoxes[index].classList.add('box-show');
      });
    });
  }
}

