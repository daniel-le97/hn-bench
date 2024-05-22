package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync"
	"time"
)

const STORIES_URL = "https://hacker-news.firebaseio.com/v0/topstories.json"
const ITEM_URL_BASE = "https://hacker-news.firebaseio.com/v0/item"

type Story struct {
	Title string
}

func fetchStory(id int, wg *sync.WaitGroup, mutex *sync.Mutex, stories *[]Story) {
	defer wg.Done()
	url := fmt.Sprintf("%s/%d.json", ITEM_URL_BASE, id)
	rsp, err := http.Get(url)
	if err != nil {
		fmt.Printf("Error fetching story %d: %v\n", id, err)
		return
	}
	defer rsp.Body.Close()

	data, err := io.ReadAll(rsp.Body)
	if err != nil {
		fmt.Printf("Error reading response for story %d: %v\n", id, err)
		return
	}

	var story Story
	if err := json.Unmarshal(data, &story); err != nil {
		fmt.Printf("Error unmarshalling story %d: %v\n", id, err)
		return
	}

	mutex.Lock()
	*stories = append(*stories, story)
	mutex.Unlock()
}

func main() {
	startTime := time.Now()

	rsp, err := http.Get(STORIES_URL)
	if err != nil {
		panic(err)
	}
	defer rsp.Body.Close()

	data, err := io.ReadAll(rsp.Body)
	if err != nil {
		panic(err)
	}

	var ids []int
	if err := json.Unmarshal(data, &ids); err != nil {
		panic(err)
	}

	var stories []Story
	var wg sync.WaitGroup
	var mutex sync.Mutex

	for _, id := range ids[:410] { // Fetch the top 410 stories
		wg.Add(1)
		go fetchStory(id, &wg, &mutex, &stories)
	}

	wg.Wait()

	for _, story := range stories {
		fmt.Println(story.Title)
	}

	fmt.Printf("Execution time: %.2f seconds\n", time.Since(startTime).Seconds())
}
