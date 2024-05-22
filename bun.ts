const STORIES_URL = "https://hacker-news.firebaseio.com/v0/topstories.json";
const ITEM_URL_BASE = "https://hacker-news.firebaseio.com/v0/item";

async function fetchTopStories() {
  try {
    const response = await fetch(STORIES_URL);
    return response.json() as Promise<number[]>;
  } catch (error) {
    console.error("Error fetching top stories:", error);
    throw error;
  }
}

async function fetchStory(id) {
  try {
    const response = await fetch(`${ITEM_URL_BASE}/${id}.json`);
    return response.json() as Promise<{ title: string }>;
  } catch (error) {
    console.error(`Error fetching story ${id}:`, error);
    throw error;
  }
}

async function main() {
  const startTime = Date.now();

  try {
    const ids = await fetchTopStories();
    console.log(ids);

    const storyPromises = ids.map((id) => fetchStory(id)); // Limit to the top 50 stories for brevity

    const stories = await Promise.all(storyPromises);

    stories.forEach((story) => {
      if (story && story.title) {
        console.log(story.title);
      }
    });

    const endTime = Date.now();
    console.log(`Execution time: ${(endTime - startTime) / 1000} seconds`);
  } catch (error) {
    console.error("Error in main function:", error);
  }
}

main();
