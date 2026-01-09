package share

import (
	"context"
	"html/template"
	"log"

	"github.com/gin-gonic/gin"
)

const postSummaryTemplate = `
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>{{.Title}}</title>

        <!-- Open Graph / Facebook -->
        <meta property="og:type" content="article" />
        <meta property="og:url" content="https://sofluffy.io/{{.Slug}}.md" />
        <link rel="canonical" href="https://sofluffy.io/{{.Slug}}.md" />
        <meta property="og:title" content="{{.Title}}" />
        <meta property="og:description" content="{{.Summary}}" />
        {{ if .FeaturedImageURL }}
        <meta property="og:image" content="{{.FeaturedImageURL}}" />
        {{ end }}
        <meta property="og:site_name" content="Your Blog Name" />

        <!-- Twitter -->
        <meta property="twitter:card" content="summary_large_image" />
        <meta
            property="twitter:url"
            content="https://sofluffy.io/{{.Slug}}.md"
        />
        <meta property="twitter:title" content="{{.Title}}" />
        <meta property="twitter:description" content="{{.Summary}}" />
        {{ if .FeaturedImageURL }}
        <meta property="twitter:image" content="{{.FeaturedImageURL}}" />
        {{ end }}

        <style>
            :root {
                --primary-color: #e06634; /* primary from default.json */
                --secondary-color: #007aff; /* secondary from default.json */
                --text-color: #141718; /* neutral7 from default.json */
                --light-text-color: #343839; /* neutral5 from default.json */
                --background-color: #f3f5f7; /* neutral2 from default.json */
                --container-background: #fefefe; /* neutral1 from default.json */
                --border-color: #e8ecef; /* neutral3 from default.json */
                --tag-background: #e8ecef; /* neutral3 from default.json */
            }

            body {
                font-family:
                    Nunito,
                    -apple-system,
                    BlinkMacSystemFont,
                    "Segoe UI",
                    Roboto,
                    Helvetica,
                    Arial,
                    sans-serif; /* Nunito from default.json */
                margin: 0; /* Remove default body margin */
                padding: 20px;
                background-color: var(--background-color);
                color: var(--text-color);
                line-height: 1.6;
            }
            .container {
                max-width: 800px;
                margin: 20px auto; /* Add top/bottom margin for spacing */
                padding: 30px; /* Increased padding */
                border: 1px solid var(--border-color);
                border-radius: 10px; /* Slightly larger radius */
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); /* Stronger shadow */
                background-color: var(--container-background);
            }
            h1 {
                color: var(--primary-color); /* Use primary color for title */
                font-size: 2.5em; /* Larger title */
                margin-bottom: 0.5em;
                text-align: center; /* Center the title */
            }
            img {
                max-width: 100%;
                height: auto;
                border-radius: 8px; /* Slightly larger radius for image */
                margin-bottom: 30px; /* Increased margin */
                display: block; /* Ensure image is block level */
                margin-left: auto;
                margin-right: auto;
            }
            .summary {
                font-size: 1.2em; /* Larger summary font */
                color: var(
                    --light-text-color
                ); /* Use light text color for summary */
                margin-bottom: 30px; /* Increased margin */
                text-align: center; /* Center the summary */
            }
            .author-info {
                font-size: 1em; /* Adjusted font size */
                color: var(--light-text-color);
                margin-top: 30px; /* Increased margin */
                border-top: 1px solid var(--border-color);
                padding-top: 15px; /* Increased padding */
                text-align: center; /* Center author info */
            }
            .author-info p {
                margin-bottom: 8px; /* Spacing between author info paragraphs */
            }
            .tags {
                margin-top: 15px; /* Adjusted margin */
                text-align: center; /* Center tags */
            }
            .tag {
                display: inline-block;
                background-color: var(--tag-background);
                color: var(--text-color); /* Use primary text color for tags */
                padding: 6px 12px; /* Adjusted padding */
                border-radius: 6px; /* Adjusted radius */
                margin-right: 8px;
                font-size: 0.9em;
            }
            a {
                color: var(
                    --secondary-color
                ); /* Use secondary color for links */
                text-decoration: none; /* Remove underline */
                font-weight: bold; /* Make link bold */
            }
            a:hover {
                text-decoration: underline; /* Add underline on hover */
            }
        </style>
        <script>
            (function() {
                var slug = "{{.Slug}}";
                if (slug) {
                    window.location.replace("https://sofluffy.io/" + slug + ".md");
                }
            })();
        </script>
    </head>
    <body>
        <div class="container">
            {{ if .FeaturedImageURL }}
            <img src="{{.FeaturedImageURL}}" alt="{{.Title}} featured image" />
            {{ end }}
            <h1>{{.Title}}</h1>
            <p class="summary">{{.Summary}}</p>
            <div class="author-info">
                {{ if .Author }}
                <p><strong>Author:</strong> {{.Author.DisplayName}}</p>
                {{ end }}
                <p>
                    <strong>Published:</strong> {{.CreatedAt.Format "January 2, 2006"}}
                </p>
                {{ if .Tags }}
                <div class="tags">
                    <strong>Tags:</strong>
                    {{ range .Tags }}
                    <span class="tag">{{.}}</span>
                    {{ end }}
                </div>
                {{ end }}
            </div>
            <p>
                Read the full post on
                <a href="https://sofluffy.io/{{.Slug}}.md">Your Blog Name</a>
            </p>
        </div>
    </body>
</html>
`

type Handler struct {
	Templates  *template.Template
	Repository *Repository
}

func NewHandler(repo *Repository) *Handler {
	tmpl, err := template.New("post_summary.html").Parse(postSummaryTemplate)
	if err != nil {
		log.Fatalf("Error parsing template: %v", err)
	}
	return &Handler{Templates: tmpl, Repository: repo}
}

func (h *Handler) GetPostSummaryPageBySlug(ginContext *gin.Context) {
	ginContext.Writer.Header().Set("Content-Type", "text/html; charset=utf-8")

	slug := ginContext.Param("slug")
	lang := ginContext.GetHeader("lang")

	if slug == "" {
		h.Templates.ExecuteTemplate(ginContext.Writer, "post_summary.html", gin.H{"Title": "Post Not Found", "Summary": "The requested post could not be found."})
		return
	}

	post, err := h.Repository.GetPostBySlug(context.Background(), slug, lang)
	if err != nil {
		log.Printf("error when fetching post by slug for summary page: %v", err)
		h.Templates.ExecuteTemplate(ginContext.Writer, "post_summary.html", gin.H{"Title": "Error", "Summary": "Internal server error."})
		return
	}

	if post == nil {
		h.Templates.ExecuteTemplate(ginContext.Writer, "post_summary.html", gin.H{"Title": "Post Not Found", "Summary": "The requested post could not be found."})
		return
	}

	summaryPost := SummaryPost{
		ID:               post.ID,
		Title:            post.Title,
		Slug:             post.Slug,
		Summary:          post.Summary,
		FeaturedImageURL: post.FeaturedImageURL,
		Author:           post.Author,
		CreatedAt:        post.CreatedAt,
		UpdatedAt:        post.UpdatedAt,
		Tags:             post.Tags,
	}

	h.Templates.ExecuteTemplate(ginContext.Writer, "post_summary.html", summaryPost)
}
