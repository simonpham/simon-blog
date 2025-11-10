CREATE TYPE post_status AS ENUM ('draft', 'published', 'archived');
CREATE TYPE post_visibility AS ENUM ('public', 'private', 'unlisted');

CREATE TYPE animal_type AS ENUM (
    'rabbit', 'cat', 'dog', 'bear', 'panda',
    'sheep', 'koala', 'wolf', 'fox', 'chipmunk'
);

CREATE TYPE background_color_type AS ENUM (
    'red', 'orange', 'yellow', 'green', 'blue', 'purple', 'pink'
);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TABLE users
(
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email        TEXT NOT NULL UNIQUE,
    password     BYTEA NOT NULL,
    username     TEXT NOT NULL UNIQUE,
    first_name   TEXT,
    last_name    TEXT,
    display_name TEXT,
    avatar       TEXT,
    avatar_hash  TEXT,
    bio          TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_user_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);

CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    content TEXT NOT NULL,
    summary TEXT NOT NULL,
    featured_image_url TEXT,
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status post_status NOT NULL DEFAULT 'draft',
    visibility post_visibility NOT NULL DEFAULT 'private',
    comments_count INTEGER NOT NULL DEFAULT 0,
    likes_count INTEGER NOT NULL DEFAULT 0,
    read_time_minutes INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    search_vector TSVECTOR
);

CREATE TRIGGER update_post_updated_at
BEFORE UPDATE ON posts
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_posts_status ON posts(status);
CREATE INDEX idx_posts_visibility ON posts(visibility);
CREATE INDEX idx_posts_author_id ON posts(author_id);

CREATE OR REPLACE FUNCTION update_posts_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector = to_tsvector('english', NEW.title || ' ' || NEW.summary || ' ' || NEW.content);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_posts_search_vector_trigger
BEFORE INSERT OR UPDATE ON posts
FOR EACH ROW EXECUTE FUNCTION update_posts_search_vector();

CREATE INDEX idx_posts_search_vector ON posts USING GIN(search_vector);

CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE post_tags (
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    tag_id INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, tag_id)
);

CREATE INDEX idx_post_tags_post_id ON post_tags(post_id);
CREATE INDEX idx_post_tags_tag_id ON post_tags(tag_id);

CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    animal animal_type,
    background_color background_color_type,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION increment_comments_count() RETURNS TRIGGER AS $$
BEGIN
    UPDATE posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION decrement_comments_count() RETURNS TRIGGER AS $$
BEGIN
    UPDATE posts SET comments_count = comments_count - 1 WHERE id = OLD.post_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER comments_after_insert
AFTER INSERT ON comments
FOR EACH ROW EXECUTE PROCEDURE increment_comments_count();

CREATE TRIGGER comments_after_delete
AFTER DELETE ON comments
FOR EACH ROW EXECUTE PROCEDURE decrement_comments_count();

CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_created_at ON comments(created_at DESC);

CREATE TABLE likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (post_id, user_id)
);

CREATE OR REPLACE FUNCTION increment_likes_count() RETURNS TRIGGER AS $$
BEGIN
    UPDATE posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION decrement_likes_count() RETURNS TRIGGER AS $$
BEGIN
    UPDATE posts SET likes_count = likes_count - 1 WHERE id = OLD.post_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER likes_after_insert
AFTER INSERT ON likes
FOR EACH ROW EXECUTE PROCEDURE increment_likes_count();

CREATE TRIGGER likes_after_delete
AFTER DELETE ON likes
FOR EACH ROW EXECUTE PROCEDURE decrement_likes_count();

CREATE INDEX idx_likes_post_id ON likes(post_id);
CREATE INDEX idx_likes_user_id ON likes(user_id);

CREATE TABLE user_sessions
(
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    access_token  TEXT NOT NULL UNIQUE,
    refresh_token TEXT NOT NULL UNIQUE,
    user_agent    TEXT NOT NULL,
    ip_address    TEXT NOT NULL,
    last_used_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    revoked_at    TIMESTAMPTZ
);

CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);

DROP VIEW IF EXISTS published_public_posts;
CREATE VIEW published_public_posts AS
SELECT
    p.id,
    p.title,
    p.slug,
    p.content,
    p.summary,
    p.featured_image_url,
    p.author_id,
    p.status,
    p.visibility,
    p.comments_count,
    p.likes_count,
    p.read_time_minutes,
    p.created_at,
    p.updated_at,
    p.search_vector,
    ARRAY_AGG(t.name) FILTER (WHERE t.name IS NOT NULL) AS tags
FROM
    posts p
LEFT JOIN
    post_tags pt ON p.id = pt.post_id
LEFT JOIN
    tags t ON pt.tag_id = t.id
WHERE
    p.status = 'published' AND p.visibility = 'public'
GROUP BY
    p.id, p.title, p.slug, p.content, p.summary, p.featured_image_url, p.author_id,
    p.status, p.visibility, p.comments_count, p.likes_count, p.read_time_minutes,
    p.created_at, p.updated_at, p.search_vector;