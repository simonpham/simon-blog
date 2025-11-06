package model

import (
	nowispb "nowis/protobuf/generated/nowis"

	"github.com/google/uuid"
)

// SidebarPost represents a post item for the sidebar
type SidebarPost struct {
	ID    uuid.UUID `json:"id"`
	Title string    `json:"title"`
	Slug  string    `json:"slug"`
}

// ToPBSidebarPost converts a SidebarPost model to its Protobuf representation.
func (sp *SidebarPost) ToPBSidebarPost() *nowispb.SidebarPost {
	return &nowispb.SidebarPost{
		Id:    sp.ID.String(),
		Title: sp.Title,
		Slug:  sp.Slug,
	}
}

// TagSidebar represents a tag and its associated posts for the sidebar
type TagSidebar struct {
	TagName string        `json:"tag_name"`
	Posts   []SidebarPost `json:"posts"`
}

// ToPBTagSidebar converts a TagSidebar model to its Protobuf representation.
func (ts *TagSidebar) ToPBTagSidebar() *nowispb.TagSidebar {
	pbPosts := make([]*nowispb.SidebarPost, len(ts.Posts))
	for i, post := range ts.Posts {
		pbPosts[i] = post.ToPBSidebarPost()
	}
	return &nowispb.TagSidebar{
		TagName: ts.TagName,
		Posts:   pbPosts,
	}
}
