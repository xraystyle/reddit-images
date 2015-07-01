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


    # Parse each page for individual posts, send the post to the URL processing method
    # to return an array of image urls, one per post.
    def parse_pages(page_array)

        # get all the posts into one array
        posts = []
        page_array.each do |page|
            page['data']['children'].each do |post|
                posts << post
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


    def get_image_urls(post)

        url_value = post['data']['url']

        
        
    end






# end module.
end
