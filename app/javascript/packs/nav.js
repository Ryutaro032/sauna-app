$(document).ready(function() {
  toggleNav();

  $(document).on('turbolinks:load', function() {
    toggleNav();
  });

  function toggleNav() {
    $(".nav-toggle").click(function() {
      $(".nav-toggle, .nav-wrapper").toggleClass("open");
    });

    $(".span").click(function() {
      $(".nav-toggle, .span").toggleClass("open");
    });
  }
});
