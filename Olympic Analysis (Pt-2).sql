--1
--How many different sports are recorded in the dataset?
select count(distinct Sport) as sports_count
from athlete_events

--2
--List the cities that hosted the Olympic Games along with the number of times each city hosted.
select distinct City , count(distinct Games) as no_games_hosted
from athlete_events
group by City
order by 2 desc

--3
--Identify the athlete with the highest number of participations in the Olympics.
select *	
from
	(select * , Dense_Rank() over(order by no_games_played desc) as Rank
	from	
		(select distinct name , count(distinct Games) as no_games_played 
		from athlete_events
		group by name
		) x ) y
where y.Rank =1

--4
--Find the average age of athletes who won gold medals.
select AVG(isnull(age,0))
from
	(select distinct name , age
	from athlete_events
	where medal ='Gold') x

--5
--List the countries that have participated in both summer and winter Olympics.
with t1 as	
	(select distinct team , season
		from athlete_events
		where Season = 'Summer') ,
	 t2 as
	 (select distinct team , season
		from athlete_events
		where Season = 'Winter')
select distinct t1.* , t2.season
from t1 
join t2 on t1.team = t2.team

--6
--Identify the event with the highest number of participants in a single Olympics
select top 1  event , count(distinct ID) as ParticipantsCount
	from athlete_events
	group by event
	order by ParticipantsCount desc	

--7
--Find the youngest athlete to win a medal in any Olympics.
select top 1 name , age
	from athlete_events
	where Medal != 'NA' and age is not null
	order by Age	

--8
--Fetch the total number of events held in each Olympic game.
select distinct Games ,COUNT(distinct Event) as total_events_played
	from athlete_events
	group by Games
	order by total_events_played desc

--9
--List the sports that have been played in both summer and winter Olympics.
with t1 as	
	(select distinct Sport , season
		from athlete_events
		where Season = 'Summer') ,
	 t2 as
	 (select distinct Sport , season
		from athlete_events
		where Season = 'Winter')
select distinct t1.* , t2.season
from t1 
join t2 on t1.Sport = t2.Sport

--10
--Identify the athletes who won a medal in multiple sports.
select * 
from 
	(select distinct name , count(distinct Sport) as sports_played
	from athlete_events
	where Medal != 'NA'
	group by name) x
where sports_played >1
order by sports_played desc

--11
--Find the ratio of male to female athletes for each Olympic game.
with t1 as
	(select distinct Games , count(distinct case when sex='M' then ID End) as male_count
	from athlete_events
	group by Games
	),
	t2 as
	(
	select distinct Games , count(distinct case when sex='F' then ID End) as female_count
	from athlete_events
	group by Games
	)
SELECT t1.games , (t2.female_count * 1.0 / t1.male_count * 1.0) *100 as ratio_F_to_M
FROM
    t1 
join t2 on t1.Games =t2.Games

--12
--List the athletes who have won gold medals in consecutive Olympic games.
with t1 as
	(select  name , Medal ,  Games ,Year ,DENSE_RANK() over(order by games) as D_RNK
	from athlete_events
	where Medal = 'Gold'),
	t2 as
	(select name , Medal ,  Games ,year ,DENSE_RANK() over(order by games) as D_RNK
	from athlete_events
	where Medal = 'Gold')
Select  distinct t1.Name , t1.Games , t1.Year , t2.Games , t2.Year 
from t1 join t2 on t1.Name = t2.Name and t1.games <> t2.Games and t1.D_RNK =t2.D_RNK-1
order by name

--13
--Identify the sports where the oldest athletes have won medals.
select * , Dense_rank() over(order by x.max_age desc) as D_RNK
from 
	(select distinct Sport  , max(age) as max_age
	from athlete_events
	where Medal != 'NA'
	group by Sport) x

--14
--Identify the countries that have won medals in both individual and team sports.
--First we need to add a new column (Sport_Type)
alter table athlete_events
add Sport_event varchar(30)

update athlete_events
set Sport_event =
    CASE
        WHEN Sport IN ('Shooting', 'Archery', 'Roque', 'Equestrianism', 'Curling', 'Croquet', 'Alpinism',
                      'Fencing', 'Golf', 'Racquets', 'Figure Skating', 'Cricket', 'Tennis', 'Canoeing',
                      'Cross Country Skiing', 'Cycling', 'Ski Jumping', 'Luge', 'Skeleton', 'Wrestling',
                      'Jeu De Paume', 'Diving', 'Speed Skating', 'Boxing', 'Modern Pentathlon',
                      'Table Tennis', 'Freestyle Skiing', 'Trampolining', 'Badminton', 'Taekwondo',
                      'Aeronautics', 'Rhythmic Gymnastics') THEN 'Individual Sport'
        WHEN Sport IN ('Sailing', 'Rowing', 'Athletics', 'Polo', 'Motorboating', 'Swimming',
                      'Handball', 'Tug-Of-War', 'Water Polo', 'Hockey', 'Softball', 'Volleyball',
                      'Weightlifting', 'Rugby', 'Basketball', 'Football', 'Lacrosse', 'Ice Hockey',
                      'Canoeing', 'Synchronized Swimming', 'Basque Pelota', 'Military Ski Patrol',
                      'Basketball', 'Football', 'Lacrosse', 'Ice Hockey', 'Synchronized Swimming',
                      'Basque Pelota', 'Military Ski Patrol', 'Beach Volleyball', 'Baseball',
                      'Hockey', 'Snowboarding', 'Nordic Combined', 'Alpine Skiing', 'Triathlon',
                      'Judo', 'Boxing', 'Basketball', 'Football', 'Lacrosse', 'Beach Volleyball',
                      'Rugby Sevens') THEN 'Team Sport'
        ELSE 'Unclassified'
    END

with t1 as
	(select Team
	from athlete_events
	where Medal != 'NA' and Sport_event = 'Individual Sport'),
	
	t2 as 
	(select Team
	from athlete_events
	where Medal != 'NA' and Sport_event = 'Team Sport')
select distinct t1.Team
from t1 
join t2 on t1.Team = t2.Team




	


