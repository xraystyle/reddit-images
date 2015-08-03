$(window).load(function() {
    
    // If there's gifv's on the page, fix 'em!
    if ($('video').length) {
        fixVids();
        window.addEventListener("resize", fixVids);
    }

});


// Set the height of any gifv's to the height of their containing div,
// then offset them by the correct number of pixels to center the video in
// the div.
function fixVids() {
    var vids = $('video');
    var boxLength = $('.video-inner').height();

    vids.each(function() {
        $(this).attr('height', boxLength);

        var pixelShift = ( ( $(this).width() / 2 ) - ( boxLength / 2 ) );

        $(this).css('margin-left', ( pixelShift * -1 ) );
    });
}