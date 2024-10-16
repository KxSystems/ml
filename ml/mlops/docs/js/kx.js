// Kx Handbook Documentation
// Copyright (c) 2021 Kx Systems Inc


// Fix code syntax highlighting for Prism.js
//   Code taken from: https://github.com/PrismJS/prism/issues/2099
$("pre code").each(function(){
    var c = $(this).attr('class');
    if( c ) {
        $(this).addClass('language-'+c);
    }
});

// Remove the footer nav
$(".md-footer-nav").remove()

