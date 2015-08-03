$(window).load(function() {
    fixVids();
});



function fixVids() {
    
    if ( $('video').length ) {
        var vids = $('video');
        var boxLength = $('.video-inner').height();

        vids.each(function() {
            $(this).attr('height', boxLength);

            var pixelShift = ( ( $(this).width() / 2 ) - ( boxLength / 2 ) );

            $(this).css('margin-left', ( pixelShift * -1 ) );
        });

     } 

}