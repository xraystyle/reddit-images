module Helpers

    # pull in between 1 and 4 pages of JSON data from the requested subreddit.
    # return an array of JSON objects, one object per page of data.
    def get_pages(subreddit, sort_order, howmany)

        sort_order = "/#{sort_order}/".downcase

        pages = []

        howmany.to_i.times do |i|

            if i == 0
                url = "http://reddit.com/r/#{subreddit}#{sort_order}.json"
            else
                # id of the last post on the previous page:
                last_id = pages[i-1]['data']['children'].last["data"]['id']
                url = "http://reddit.com/r/#{subreddit}#{sort_order}.json?count=#{i * 25}&after=t3_#{last_id}"
            end

            # pull the json page, parse and add to the pages array.
            begin
                page = JSON.parse(open(url).read)
            rescue => e
                redirect to('/'), 500
            end
            pages << page
            
        end
        # return the array
        pages
    end


    # Parse each page for individual posts. Filter the posts by score, then 
    # send the post to the URL processing method to return an array of image urls, 
    # one per post. 
    def parse_pages(page_array, min_score = 1)

        # get all the posts into one array, filtered by min_score.
        posts = []
        page_array.each do |page|
            page['data']['children'].each do |post|
                posts << post if post["data"]["score"].to_i >= min_score.to_i
            end
        end

        # get the correct image and link urls for each post
        image_urls = []
        posts.each do |post|
            # process the URL to see if it's a useful image.
            # if so, add it to the image_urls array.
            urls = get_post_urls(post) # see the get_post_urls method below.
            image_urls << urls if urls
        end
        # return the array of image urls.
        image_urls
    end



    # Parse each post to retrieve the correct image and link URL for it.
    # returns a hash containing the image url and the link to the reddit
    # thread. Returns nil if no suitable image link.
    def get_post_urls(post)

        url_value = post['data']['url']

        url_pair = { post_url: "http://reddit.com" + post["data"]["permalink"], image_url: nil, format: nil }

        case url_value
        #imgur album, get the cover image.
        when /https?:\/\/imgur.com\/a\/(.*)/
            # Get the imgur id of the album.
            album_id = $1
            link_data = pull_imgur(album_id, :album)

            url_pair[:image_url] = link_data[:link]
            url_pair[:format] = link_data[:format]
            return url_pair if url_pair[:image_url]

        #imgur single image on a page, or direct link. Also handles mobile link posts.
        when /https?:\/\/(m|i\.)?imgur.com\/([a-zA-Z0-9]+)(\..*)?$/
            # adding the 'i.' and the '.jpg' to the url goes straight to the image,
            # regardless of format. (jpg, png, gif, etc.)
            image_id = $2

            # nested case statements, I know.
            case $3
            when '.gif', '.gifv'
                url_pair[:image_url] = url_value.sub(/\.gif(v)?/, '.webm')
                url_pair[:format] = :gifv
                return url_pair if url_pair[:image_url]
            when nil
                link_data = pull_imgur(image_id, :image)
                url_pair[:image_url] = link_data[:link]
                url_pair[:format] = link_data[:format]
                return url_pair if url_pair[:image_url]
            else
                url_pair[:image_url] = url_value
                url_pair[:format] = :image
                return url_pair if url_pair[:image_url]
            end

        #any direct URL to an image that's not imgur.
        when /https?:\/\/[a-zA-Z0-9\-._~\/]+\.(jpg|gif|png)/
            # Just return the value.
            url_pair[:image_url] = url_value
            url_pair[:format] = :image
            return url_pair if url_pair[:image_url]
        end

        # ignore unmatched urls.        
        
    end


    # query the imgur API for useful data about the link, return usable info.
    # Type can be either :image or :album
    def pull_imgur(id, type)

        # query imgur for json data on the object in question.
        begin
            raw = open(IMGUR_BASE + type.to_s + "/#{id}", "Authorization" => API_KEY).read
        rescue => e
            # returning these nils essentially skips the image in the output 
            # if there's an error when querying the imgur API.
            return { format: nil, link: nil }
        end

        json = JSON.parse(raw)

        if type == :image

            info = Hash.new # we return this at the end of the method.

            # get the type and direct link.
            format = json['data']['type']
            
            if format == "image/gif"
                info[:format] = :gifv
                info[:link] = json['data']['webm']
            else
                info[:format] = :image
                info[:link] = json['data']['link']
            end

        end

        # If the id passed is for an album, we want the info for the cover image.
        # Call the method recursively with the ID of the cover image.
        if type == :album
            cover_id = json['data']['cover']
            info = pull_imgur(cover_id, :image) 
        end

        info
    end


    def format_link(url_pair)
       
        # image display output
        if url_pair[:format] == :image
            return "<div class='image'>\n  <div class='image-inner'>\n    <a href='" + 
            url_pair[:post_url] + 
            "' target='_blank'>\n      <img src='" +
            url_pair[:image_url] +
            "' style='max-height: 300px;'>\n    </a>\n  </div>\n</div>"
        end

        # imgur gifv output
        if url_pair[:format] == :gifv
            return "<div class='video-container'>\n  <div class='video-inner'>\n    <a href='" +
            url_pair[:post_url] +
            "' target='_blank'>\n      <video autoplay='autoplay' id='video' loop='loop' muted='muted' preload='auto' src='" +
            url_pair[:image_url] +
            "'></video>\n    </a>\n  </div>\n</div>"
        end

       
    end


    def testing
        "This is a string of text."
    end

# end module.
end
