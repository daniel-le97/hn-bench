import net.http
import json
import time
import sync.pool

const stories_url = 'https://hacker-news.firebaseio.com/v0/topstories.json'
const item_base_url = 'https://hacker-news.firebaseio.com/v0/item'

struct Story {
	title string
}

fn main() {
	timer := time.new_stopwatch()
	resp := http.get(stories_url)!
	ids := json.decode([]int, resp.body)!

	mut pp := pool.new_pool_processor(
		maxjobs:100
		callback: fn (mut pp pool.PoolProcessor, idx int, wid int)  {
			id := pp.get_item[int](idx)
			resp := http.get('${item_base_url}/${id}.json') or { panic(err) }
			story := json.decode(Story, resp.body) or { panic(err) }
			println(story.title)
		},
		
	)
	pp.work_on_items(ids)
	println('Elapsed: ${timer.elapsed()}')
}
