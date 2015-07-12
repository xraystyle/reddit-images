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
            page = JSON.parse(open(url).read)
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
            urls = get_post_urls(post)
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
        when /https?:\/\/imgur.com\/a\/.*/  #imgur album, get the first image
           
            # Edge cases occur where reddit doesn't pull the first image.
            # When that happens, there's no thumbnail preview on the post, and the 
            # oembed hash doesn't exist, causing a NoMethodError.

            begin
                url_pair[:image_url] = post['data']['media']['oembed']['thumbnail_url']
            end

        when /https?:\/\/[a-zA-Z0-9\-._~\/]+\.(jpg|gifv|gif|png)/ #any direct URL to an image.
            # Just return the value.
            url_pair[:image_url] = url_value

        when /https?:\/\/(m\.)?imgur.com\/[a-zA-Z0-9]+$/ #imgur single image on a page. Also handles mobile link posts.
            # adding the 'i.' and the '.jpg' to the url goes straight to the image,
            # regardless of format. (jpg, png, gif, etc.)
            url_value.sub!(/m\./, "")
            url_value.sub!(/imgur/, "i.imgur")
            url_pair[:image_url] = url_value + ".jpg"
        end

        # ignore unmatched urls.

        # return the URL pair if it has a valid image, otherwise nil.
        url_pair if url_pair[:image_url]
        
    end



    def format_link(url_pair)
        
    end


# end module.
end
