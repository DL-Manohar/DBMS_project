--DBMS ASSIGNMENT-3
--GROUP-23
--SQL QUERIES


--QUERY-1
select movies_id,count(person_id)
from movie_cast_crew mcc
where role_name = 'director'
group by movies_id having count(person_id)>=2


--QUERY-2
select distinct t1.person_id, person.person_name 
from 
(select person_id, count(movies_id) as total_movies
 from movie_cast_crew mcc 
 where role_name = 'actor'
 group by person_id) as t1,
(select mcc_a.person_id, count(mcc_a.movies_id) as zack_movies
 from movie_cast_crew mcc_a, movie_cast_crew mcc_b
 where mcc_a.role_name ='actor' and mcc_a.movies_id = mcc_b.movies_id and mcc_b.person_id = 'nm0811583' and mcc_b.role_name = 'director'
 group by mcc_a.person_id) as t2, person
 where ((2*(t2.zack_movies) - t1.total_movies) > 0) and t1.person_id = t2.person_id and t1.person_id = person.person_id



--QUERY-3
select movie_id,original_title
from movie_awards, movies
where awards < 2 and movies.movie_id = movie_awards.movie_id



--QUERY-4
select X.person_name,Y.person_name
from person X,person Y,
(select A.person_id as actorID, B.person_id as directorID
from movie_cast_crew A inner join movie_cast_crew B
on A.role_name = 'actor' and B.role_name = 'director' and A.movies_id = B.movies_id
inner join title_ratings_source on A.movies_id = title_ratings_source.tconst 
where cast(avg_rating as float) >= 7
group by (A.person_id, B.person_id) having count(A.movies_id) <= 2) as table1
where X.person_id = table1.actorID and Y.person_id = table1.directorID



--QUERY-5
select orginal_title, (end_year-start_year) as air_time_years
from tv_series
where end_year is not null and start_year is not null and 
end_year-start_year = (select max(end_year-start_year) 
							from tv_series where 
							end_year is not null and start_year is not null)



--QUERY-6
select person_name 
from person,
(select distinct person_id
from (select movie_id,runtime
	  from movies
	  where start_year = 2020 and runtime = (select distinct runtime from movies where start_year = 2020 order by runtime limit 1 offset 1))
      as table1, movie_cast_crew
	  where table1.movie_id = movie_cast_crew.movies_id and movie_cast_crew.role_name = 'director') as table2
where table2.person_id = person.person_id



--QUERY-7
select TRS.tconst,original_title 
from title_basics_source TBS, title_ratings_source TRS
where isadult = '1' and TBS.tconst = TRS.tconst and (TBS.title_type = 'movie' or TBS.title_type = 'short')
order by avg_rating limit 1



--QUERY-8
select *
from
(select person_id,avg(cast(avg_rating as float)) as average_rating
from movie_cast_crew mcc inner join title_ratings_source trs 
on mcc.movies_id = trs.tconst
where mcc.role_name = 'director'
group by person_id) as table1
order by table1.average_rating desc limit 5




--QUERY-9
--Movies
select t1.movie_id, count(distinct region) as region_num, count(distinct company_name) as pro_num
from 
(select mrl.movie_id, mrl.region, mp.company_name 
from
movie_release_lang mrl inner join movie_production mp 
on mrl.movie_id = mp.movie_id ) as t1
group by t1.movie_id
having count(distinct region) >= 3 and count(distinct company_name) >=2

--TV series
select t1.tvseries_id, count(distinct region) as region_num, count(distinct company_name) as pro_num
from 
(select mrl.tvseries_id, mrl.region, mp.company_name 
from
movie_release_lang mrl inner join movie_production mp 
on mrl.tvseries_id = mp.tvseries_id ) as t1
group by t1.tvseries_id
having count(distinct region) >= 3 and count(distinct company_name) >=2



--QUERY-10
select person_id,person_name
from oscars, person
where oscars.person_id = person.person_id 
order by oscars.year_of_win desc



--QUERY-11
select person.person_name,t3.pid1,(0.3*(dir_count+(coalesce(adir_count,0)) + 0.7*(0.8*(coalesce(dir_rating,0))+0.2*(coalesce(adir_rating,0))))) as score
from
((select person_id as pid1,count(movies_id) as dir_count,avg(cast(avg_rating as float)) as dir_rating
	from movie_cast_crew mcc inner join title_ratings_source trs
	on mcc.movies_id = trs.tconst 
	where role_name = 'director'
	group by person_id) t1
	full outer join
 (select person_id as pid2,count(movies_id) as adir_count,avg(cast(avg_rating as float)) as adir_rating
	from movie_cast_crew mcc inner join title_ratings_source trs
	on mcc.movies_id = trs.tconst 
	where role_name = 'asst_director'
	group by person_id) t2
	on t1.pid1 = t2.pid2) as t3,person
where person.person_id = t3.pid1
order by score desc



--QUERY-12
select *
from
(select t1.orginal_title, t1.genre, t1.box_office_collection,
rank() OVER (
            PARTITION BY genre
            ORDER BY box_office_collection DESC
        )
from
(select movie_id,orginal_title,genre, box_office_collection
from movies inner join movie_genres mg 
on movies.movies_id = mg.title_id) as t1) as t2
where t2.rank<=5




--QUERY-13
select person_name
from
(select distinct mcc.person_id
from movie_cast_crew mcc inner join tvepisode_castcrew tc
on mcc.person_id = tc.person_id 
where (mcc.role_name = 'actor' or mcc.role_name = 'actress')) as t1, person
where t1.person_id = person.person_id



--QUERY-14
select episode_id,te.start_year,runtime
from tv_episodes te ,
(select start_year ,min(runtime) as min_rt
 from tv_episodes
 where (runtime is not null) and (start_year is not null)
 group by start_year ) as table1
 where table1.start_year = te.start_year and table1.min_rt = te.runtime 
 order by te.start_year



 --QUERY-15
select *
from
(select t1.title_id, t1.genre, t1.avg_rating,
 rank() OVER (
            PARTITION BY genre
            ORDER BY avg_rating DESC
        )
from
(select title_id, genre, avg_rating
 from movie_genres inner join title_ratings_source trs
 on trs.tconst = movie_genres.title_id) as t1) as t2
 where t2.rank<=3



--QUERY-16
select movie_id
from movie_locations
where location_name = 'Switzerland'
union
select distinct tvseries_id
from tvepisode_location
where location_name = 'Switzerland'



--QUERY-17
select movie_id, region, certificate
from movie_release_lang mrl, movies
where mrl.movie_id = movies.movie_id and movies.start_year = 1995 and mrl.region is not notnull
order by mrl.region



--QUERY-18
select distinct t2.person_name, t1.role_name
from 
(person inner join ((select * from movie_cast_crew) union (select episode_id as movies_id, person_id, role_name from tvepisode_castcrew)) mtvc
on person.person_id = mtvc.person_id) as t2,
(select tmp.role_name, min(2021-person.birth_year) as present_age
 from person inner join ((select * from movie_cast_crew) union (select episode_id as movies_id, person_id, role_name from tvepisode_castcrew)) tmp
 on person.person_id = tmp.person_id 
 where person.birth_year is not null
 group by role_name) as t1
 where t2.role_name = t1.role_name and t2.birth_year is not null and (2021-t2.birth_year = t1.present_age)
 order by role_name asc



--QUERY-19
select person.person_id, person.person_name
from
(select person.person_id
 from movie_cast_crew mcc,person
 where person.person_id = mcc.person_id and (mcc.role_name = 'composer' or mcc.role_name = 'archive_sound')
 group by person.person_id 
 having count(movies_id)>=5)as t1, person
 where person.person_id = t1.person_id



--QUERY-20
select t1.person_id,t1.num_movies,person.person_name 
from
(select person_id, count(movies_id) as num_movies
 from movie_cast_crew mcc 
 where role_name = 'actor'
 group by person_id) as t1,
(select count(person_id) as num_crew
 from movie_cast_crew mcc 
 where movies_id = 'tt0000617') as t2,person
 where t1.num_movies = t2.num_crew and person.person_id = t1.person_id



