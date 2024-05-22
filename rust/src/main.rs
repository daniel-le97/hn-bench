use reqwest::Error;
use serde_json::Value;
use tokio;

const HACKER_NEWS_API: &str = "https://hacker-news.firebaseio.com/v0/topstories.json";
const ITEM_URL: &str = "https://hacker-news.firebaseio.com/v0/item/";

#[tokio::main]
async fn main() -> Result<(), Error> {
    let top_stories: Vec<u64> = reqwest::get(HACKER_NEWS_API).await?.json().await?;
    let top_stories = &top_stories[..10];
    
    let fetch_story = |id| async move {
        let url = format!("{}{}.json", ITEM_URL, id);
        let story: Value = reqwest::get(&url).await?.json().await?;
        Ok(story) as Result<Value, Error>
    };

    let story_futures = top_stories.iter().map(|&id| fetch_story(id));
    let stories: Vec<_> = futures::future::join_all(story_futures).await.into_iter().filter_map(Result::ok).collect();

    for story in stories {
        println!("{:?}", story);
    }

    Ok(())
}
