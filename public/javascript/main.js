$(window).load(function() {
    
    $('.loading').fadeOut('400', function() {
        $('.images-container').fadeIn(2000);

        // If there's gifv's on the page, fix 'em!
        var $vids = $('video')
        if ($vids.length) {
            fixVids($vids);
            window.addEventListener("resize", fixVids);
        }

        fixImgs();

    });

});


// Set the height of any gifv's to the height of their containing div,
// then offset them by the correct number of pixels to center the video in
// the div.
function fixVids(videos) {
    var boxLength = $('.video-inner').height();

    videos.each(function() {
        $(this).attr('height', boxLength);

        var pixelShift = ( ( $(this).width() / 2 ) - ( boxLength / 2 ) );

        $(this).css('margin-left', ( pixelShift * -1 ) );
    });
}

function fixImgs() {
    var imgs = $('img');

    imgs.each(function() {

        if ( $(this).width() > $(this).height() ) {
            $(this).css('height', '100%');
        }    else {
            $(this).css('width', '100%');
        }

    });
}