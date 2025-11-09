package model

import (
	nowispb "nowis/protobuf/generated/nowis"
)

type SidebarPost struct {
	ID    string `json:"id"`
	Title string `json:"title"`
	Slug  string `json:"slug"`
}

type TagSidebar struct {
	TagName string        `json:"tag_name"`
	Posts   []SidebarPost `json:"posts"`
}

func FromPBSidebarPost(pbSidebarPost *nowispb.SidebarPost) *SidebarPost {
	return &SidebarPost{
		ID:    pbSidebarPost.Id,
		Title: pbSidebarPost.Title,
		Slug:  pbSidebarPost.Slug,
	}
}

func FromPBTagSidebar(pbTagSidebar *nowispb.TagSidebar) *TagSidebar {
	posts := make([]SidebarPost, len(pbTagSidebar.Posts))
	for i, pbPost := range pbTagSidebar.Posts {
		posts[i] = *FromPBSidebarPost(pbPost)
	}
	return &TagSidebar{
		TagName: pbTagSidebar.TagName,
		Posts:   posts,
	}
}

func (sp *SidebarPost) ToGinMap() map[string]interface{} {
	return map[string]interface{}{
		"id":    sp.ID,
		"title": sp.Title,
		"slug":  sp.Slug,
	}
}

func (ts *TagSidebar) ToGinMap() map[string]interface{} {
	postsMap := make([]map[string]interface{}, len(ts.Posts))
	for i, post := range ts.Posts {
		postsMap[i] = post.ToGinMap()
	}
	return map[string]interface{}{
		"tag_name": ts.TagName,
		"posts":    postsMap,
	}
}
