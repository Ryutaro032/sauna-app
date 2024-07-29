$(document).ready(function() {
  modalWindow();

  $(document).on('turbolinks:load', function() {
    modalWindow();
  });

  function modalWindow() {
    $('.modal-search').on('click',function(){
      $('.modal-search-contents,.masksearch').fadeIn();
    });
    $('.modalsearch-close').on('click',function(){
      $('.modal-search-contents,.masksearch').fadeOut();
    });
  };
});
