--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.2
-- Dumped by pg_dump version 9.6.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE comments (
    id text NOT NULL,
    video_id text NOT NULL,
    user_id text NOT NULL,
    content text NOT NULL,
    likes bigint NOT NULL,
    dislikes bigint NOT NULL
);


ALTER TABLE comments OWNER TO postgres;

--
-- Name: video_qualities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE video_qualities (
    id text NOT NULL,
    "144p" text,
    "240p" text,
    "360p" text,
    "480p" text,
    "720p" text,
    "1080p" text,
    encode_done boolean NOT NULL
);


ALTER TABLE video_qualities OWNER TO postgres;

--
-- Name: videos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE videos (
    id text NOT NULL,
    title text NOT NULL,
    description text,
    date_uploaded time NOT NULL,
    uploaded boolean NOT NULL,
    date_generated time NOT NULL,
    timeout_date time NOT NULL,
    file_path text,
    view_count bigint NOT NULL,
    likes bigint NOT NULL,
    dislikes bigint NOT NULL
);


ALTER TABLE videos OWNER TO postgres;

--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: video_qualities video_qualities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY video_qualities
    ADD CONSTRAINT video_qualities_pkey PRIMARY KEY (id);


--
-- Name: videos videos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY videos
    ADD CONSTRAINT videos_pkey PRIMARY KEY (id);


--
-- Name: comments video_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT video_id FOREIGN KEY (video_id) REFERENCES videos(id);


--
-- Name: video_qualities video_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY video_qualities
    ADD CONSTRAINT video_id FOREIGN KEY (id) REFERENCES videos(id);


--
-- PostgreSQL database dump complete
--

