--SQL files group number 23
--Creating temporary tables to store the .tsv data from IMDb.
create table name_basics_source(
 nconst varchar,
 primary_name varchar,
 birthYear varchar,
 deathYear varchar,
 primary_profession varchar,
 known_for_titles varchar
);

COPY name_basics_source FROM '/home/vrushank/assn-2/name.basics.tsv' DELIMITER '	'; 

create table title_akas_source(
 title_ID varchar,
 ordering_num varchar,
 title varchar,
 region varchar,
 lang varchar,
 types_a varchar,
 attributs varchar,
 isOriginalTitle varchar
);

COPY title_akas_source FROM '/home/vrushank/assn-2/title.akas.tsv' DELIMITER '	';

delete from title_akas_source
where title_ID = 'titleId'


create table title_basics_source(
 tconst varchar,
 title_type varchar,
 primary_title varchar,
 original_title varchar,
 isAdult varchar,
 startYear varchar,
 endYear varchar,
 runtimeMinutes varchar,
 genre varchar
);

COPY title_basics_source FROM '/home/vrushank/assn-2/title.akas.tsv' DELIMITER '	';


create table title_crew_source(
 tconst varchar,
 director varchar,
 writer varchar
);


COPY title_crew_source FROM '/home/vrushank/assn-2/title.crew.tsv' DELIMITER '	';

delete from title_crew_source
where tconst = 'tconst'

create table title_episode_source(
 tconst varchar,
 parent_tconst varchar,
 season_num varchar,
 episode_num varchar
 );

COPY title_episode_source FROM '/home/vrushank/assn-2/title.episode.tsv' DELIMITER '	';

delete from title_crew_source
where tconst = 'tconst'


create table title_principals_source(
 tconst varchar,
 ordering_num varchar,
 nconst varchar,
 category varchar,
 job varchar,
 character_name varchar
 );

 COPY title_principals_source FROM '/home/vrushank/assn-2/title.principals.tsv' DELIMITER '	';*/

delete from title_principals_source
where tconst = 'tconst'

create table title_ratings_source(
 tconst varchar,
 avg_rating varchar,
 num_votes varchar
);


COPY title_ratings_source FROM '/home/vrushank/assn-2/title.ratings.tsv' DELIMITER '	';

delete from title_ratings_source
where tconst = 'tconst'
----------------------------------------------------------------------------------------------------------------------------------------

--CRAWL DATA FOR MOVIES
/*Crawled data for movies was stored in this table*/
create table movie_crawl_source(
Title_id varchar,
Title varchar,
Year_ varchar,
Rated varchar,
Runtime varchar,
Director varchar,
Actors varchar,
Plot varchar,
Language_ varchar,
Awards varchar,
Type_ varchar,
BoxOffice varchar,
Production varchar,
Website varchar
)

COPY movie_crawl_source FROM '/home/vrushank/assn-2/movie_crawl' DELIMITER '	';

/*Crawled data for tv-series was stored in this table*/
create table tvseries_crawl_source(
Title_id varchar,
Title varchar,
Plot varchar,
Awards varchar,
totalSeasons varchar,
Year_ varchar,
Rated varchar,
Runtime varchar,
Director varchar,
Actors varchar,
Language_ varchar,
Type_ varchar
)

COPY movie_crawl_source FROM '/home/vrushank/assn-2/tvseries_crawl' DELIMITER '	';

----------------------------------------------------------------------------------------------------

--CREATING TABLES FOR OUR DATABASE

--MOVIES TABLE:

create table movies(
	movie_id varchar,
	orginal_title varchar,
	primary_title varchar,
	title_type varchar, 
	runtime int,
	start_year int,
	PRIMARY KEY (movie_id)
);

insert into movies
select title_basics_source.tconst, original_title, primary_title, title_type, cast(runtimeminutes as int), cast(startyear as int)
from title_basics_source
where title_type = 'movie' or title_type = 'short'


--tv_episode TABLE:

CREATE TABLE tv_episodes
(
  episode_id varchar,
  original_title varchar,
  primary_title varchar,
  title_type varchar,
  runtime int,
  start_year int,
  end_year int,
  tvseries_id varchar,
  PRIMARY KEY (episode_id),
  FOREIGN KEY (tvseries_id) REFERENCES tvseries(tvseries_id)
);


insert into tv_episodes 
select title_basics_source.tconst, original_title, primary_title, title_type, cast(runtimeminutes as int), cast(startyear as int), cast(endyear as int)
from title_basics_source
where title_type = 'tvEpisode'


--TV SERIES TABLE

create table tv_series(
	tvseries_id varchar,
	orginal_title varchar,
	primary_title varchar,
	title_type varchar, 
	runtime int,
	start_year int,
	end_year int,
	PRIMARY KEY (tvseries_id)
);

insert into tv_series
select title_basics_source.tconst, original_title, primary_title, title_type, cast(runtimeminutes as int), cast(startyear as int), cast(endyear as int)
from title_basics_source
where title_type = 'tvSeries'

--PERSON

create table person(
	person_id varchar,
	person_name varchar,
	birth_year int,
	death_year int,
	PRIMARY KEY (person_id)
);

insert into person
select nconst,primary_name,cast(birthyear as int),cast(deathyear as int) from name_basics_source;

--GENRES

CREATE TABLE genre
(
  genre_type varchar,
  PRIMARY KEY (genre_type)
);

CREATE TABLE genres_temp
(
  genre_type varchar,
  PRIMARY KEY (genre_type)
);

insert into genres_temp 
select string_agg(genre,',')
from title_basics_source

insert into genre
SELECT distinct unnest(string_to_array(genre_type, ',')) FROM genres_temp;

--MOVIE GENRE

create table movie_genres(
	title_id varchar,
	genre varchar,
	PRIMARY KEY (title_id, genre)
);

insert into movie_genres
SELECT tconst, unnest(string_to_array(genre,','))
FROM title_basics_source
where title_type = 'movie' or title_type = 'short'


--TV_SERIES GENRE

create table tv_series_genres(
	title_id varchar,
	genre varchar,
	PRIMARY KEY (title_id, genre)
);

insert into tv_series_genres
SELECT tconst, unnest(string_to_array(genre,','))
FROM title_basics_source
where title_type = 'tvSeries'

--role TABLE
create table roles(
  role_name varchar,
  PRIMARY KEY(role_name)
)

insert into roles
SELECT DISTINCT category
from title_principals_source


--MOVIE CAST CREW TABLE

create table movie_cast_crew(
	person_id varchar,
	movie_id varchar,
	role_name varchar,
	FOREIGN KEY (person_id) REFERENCES person(person_id),
	FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
	FOREIGN KEY (role_name) REFERENCES roles(role_name)
);

insert into movie_cast_crew 
SELECT tconst,nconst,category
FROM title_principals_source, movies
where movie_id = tconst

--TVepisode CAST CREW TABLE

create table tvepisode_castcrew(
	person_id varchar,
	episode_id varchar,
	role_name varchar,
	FOREIGN KEY (person_id) REFERENCES person(person_id),
	FOREIGN KEY (episode_id) REFERENCES tv_episode(episode_id),
	FOREIGN KEY (role_name) REFERENCES roles(role_name)
)

insert into tvepisode_castcrew 
SELECT nconst,tconst,category
FROM title_principals_source, tv_episodes
where episode_id = tconst

--Table for Production companies
create table production(
company_name varchar,
PRIMARY KEY(company_name)
)

--Movie production relation
create table movie_production(
	movie_id varchar,
	company_name varchar,
	FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
	FOREIGN KEY (company_name) REFERENCES production(company_name)
)

insert into movie_production
select title_id,production
from movie_crawl_source 
where length(production) > 1


--Table for movie plots
create table movie_plots(
	movie_id varchar,
	plot varchar,
	PRIMARY KEY(movie_id,plot)
)

insert into movie_plots
select title_id, plot
from movie_crawl_source


--Table for tvseries plots
create table tvseries_plots(
	tvseries_id varchar,
	plot varchar,
	PRIMARY KEY(tvseries_id,plot)
)

insert into tvseries_plots
select title_id, plot
from movie_crawl_source


--Table for movie awards
create table movie_awards(
	movie_id varchar,
	awards_num varchar,
	FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
)

insert into movie_awards
select title_id,awards
from movie_crawl_source 
where length(awards) > 1

--Temporary Relation to store the release region from crawl data
create table movie_tvseries_release(
	show_id varchar,
	region varchar,
	lang varchar
)

insert into movie_release_lang
select show_id,region,lang
from movie_tvseries_release, movies 
where movie_id = show_id

--movies release region and language
create table tvseries_release_lang(
	tvseries_id varchar,
	region varchar,
	lang varchar,
	FOREIGN KEY (tvseries_id) REFERENCES tvseries(tvseries_id)
)


--movie_release region and language
create table movie_release_lang(
	movie_id varchar,
	region varchar,
	lang varchar,
	FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
)

insert into tvseries_release_lang
select show_id,region,lang
from movie_tvseries_release, tv_series 
where tvseries_id = show_id










