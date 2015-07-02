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

        # get all the posts into one array
        posts = []
        page_array.each do |page|
            page['data']['children'].each do |post|
                posts << post if post["data"]["score"].to_i >= min_score.to_i
            end
        end

        # get the correct image urls for each post
        image_urls = []
        posts.each do |post|

            image_urls << get_image_url(post)
            
        end
        # return the array of image urls.
        image_urls

    end

    # Parse each post to retrieve the correct image URL for it.
    def get_image_url(post)

        url_value = post['data']['url']

        case url_value
        when /https?:\/\/imgur.com\/a\/.*/  #imgur album, get the first image
           
            # Edge cases occur where reddit doesn't pull the first image.
            # When that happens, there's no thumbnail preview on the post, and the 
            # oembed hash doesn't exist, causing a NoMethodError.

            begin
                puts "#{url_value}, matches imgur album."
                return post['data']['media']['oembed']['thumbnail_url']
            rescue => e
                puts "Post had no oembed data. FAIL."
            end

        when /https?:\/\/[a-zA-Z0-9\-._~\/]+\.(jpg|gifv|gif|png)/ #any direct URL to an image.
            puts "#{url_value}, matches direct link."
            return url_value
        when /https?:\/\/(m\.)?imgur.com\/[a-zA-Z0-9]+$/ #imgur single image on a page. Also handles mobile link posts.
            # adding the 'i.' and the '.jpg' to the url goes straight to the image,
            # regardless of format. (jpg, png, gif, etc.)
            puts "#{url_value}, matches imgur single page."
            url_value.sub!(/m\./, "")
            url_value.sub!(/imgur/, "i.imgur")
            return url_value + ".jpg" 
        end

        # ignore unmatched urls.
        
    end






# end module.
end
