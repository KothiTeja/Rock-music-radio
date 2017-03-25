USE PROJ;

--Fix the air date. It is represented as number of seconds from Jan 1 1970.
alter table dbo.rock_raw
add date_aired date;
update dbo.rock_raw
set date_aired = dateadd(ss, time_sec, '1970/1/1');

--Combine the two data sets
select rw.play_id, rw.song , rw.artist, rs.combined, rw.radio_sign, rw.date_aired, rs.[Release Year] as rel_year
into rock
from dbo.rock_raw rw inner join [rock_songs] rs on rw.combined=rs.combined
where rs.[Release Year] >1950
      and rw.song is not null
	  and rw.artist is not null;

--The air dates in the data
select distinct date_aired
from dbo.rock
order by date_aired;

--Summary stats about the data
select count(distinct radio_sign) as Num_stations,
	   count(distinct artist) as Num_artists,
	   count(distinct song) as Num_songs,
	   count(distinct song)/count(distinct artist) as Songs_per_artist,
	   convert(decimal(4,0), avg(distinct rel_year)) as Avg_rel_year
from dbo.rock;

--Activity stats of the radio station
select avg(Num_plays) as Avg_num_plays,
       avg(Num_unique_songs) as Avg_num_unique_songs,
	   avg(Num_unique_artists) as Avg_num_unique_artists,
	   avg(Num_plays)/avg(Num_unique_songs) as Avg_plays_per_song,
	   avg(Num_plays)/avg(Num_unique_artists) as Avg_plays_per_artist
from (select date_aired, count(song) as Num_plays, 
	 	   count(distinct song) as Num_unique_songs,
	 	   count(distinct artist) as Num_unique_artists
	 from dbo.rock_raw 
	 group by date_aired) a
;

--Top artists
select top 5 Artist, count(play_id) as Num_plays, convert(decimal(10,2), avg(2014-rel_year)) as Age
from dbo.rock
group by artist
having count(distinct song)>6
order by Num_plays desc;

--One hit wonders
select top 5 Artist, count(play_id) as Num_plays, convert(decimal(10,2), avg(2014-rel_year)) as Age
from dbo.rock
group by artist
having count(distinct song)<=2
order by Num_plays desc;

--Top songs each day
select Date_Aired, Song, Artist, cnt as Listens
from(
	SELECT song, artist, date_aired, cnt, 
	row_number() over(partition by date_aired order by cnt desc) as rnk 
	FROM (
          select song,artist,DATE_AIRED,count(*)AS CNT FROM [rock_raw]
		  WHERE SONG IS NOT NULL AND ARTIST IS NOT NULL
		  GROUP BY song,artist,DATE_AIRED 
		  ) temp1
	 ) temp2
where temp2.rnk in (1)
order by temp2.date_aired, temp2.rnk;

--Output for analysis
select song, artist, count(play_id) as plays
into rock_music
from dbo.rock
group by song, artist;
