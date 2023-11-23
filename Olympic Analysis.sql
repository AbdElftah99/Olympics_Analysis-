select *
From athlete_events

--Cleaning Data if there is Duplicates
delete
from athlete_events
Where ID in
	(Select ID
	From (select * , ROW_NUMBER() Over(Partition by ID, Name ,Sex,Age, Height, Weight,Team,NOC , Games ,Year , Season , City , Sport, Event,Medal Order by ID) as rn 
		 From athlete_events) x
	where x.rn > 1)

--Team column Adjustment
--Russia
update athlete_events
set Team = 'Russia'
where Team like 'Russia%'
or Team Like 'Soviet Union'
or Team = 'Soviet Union%'
--Germany
update athlete_events
set Team = 'Germany'
where Team like '%Germany'
or Team Like 'Germany%'
or Team = '%Germany%'
--Britain
update athlete_events
set Team = 'Great Britain'
where Team like '%Great Britain'
or Team Like 'Great Britain%'
or Team = '%Great Britain%'

--1
--How many olympics games have been held?
select count(Distinct Games) as Total_Olypic_Games
from athlete_events

--2 List down all Olympics games held so far.
select distinct Year , season , city
from athlete_events
order by year 

--3
--Mention the total no of nations who participated in each olympics game?
select games , count(distinct NOC) as Total_Countries
from athlete_events
group by games
Order By games

--4
--Which year saw the highest and lowest no of countries participating in olympics
--Use the Last Table
create Table Games_Countries
(
games varchar(20),
Total_Countries int
)

insert into Games_Countries
select games , count(distinct NOC) as Total_Countries
from athlete_events
group by games
Order By games


select distinct Concat(FIRST_VALUE(games) over(order by total_countries) , '-' , first_value(total_countries) over(order by total_countries)) as Lowest_countries ,
				Concat(FIRST_VALUE(games) over(order by total_countries desc) , '-' , first_value(total_countries) over(order by total_countries desc)) as Highest_countries
from Games_Countries

--5
--Which nation has participated in all of the olympic games
Select *
from
	(select distinct NOC , Count(distinct Games) as Total_Participated_Games
	from athlete_events
	group by NOC) x
Where x.Total_Participated_Games =51

--6
--Identify the sport which was played in all summer olympics.
WITH t1 AS 
		(select Count(distinct Games) as Total_games
		from athlete_events
		where season = 'Summer') , 
	 t2 AS 
	  (
	  select distinct sport , games
		from athlete_events
		where season = 'Summer'
	  ) ,
	  t3 AS
	  (
	  select sport , Count(1) as no_of_games
		from t2
		group by sport
	  )
SELECT *
FROM
    t3
JOIN
    t1 on t1.Total_games = t3.no_of_games

--7
--Which Sports were just played only once in the olympics.
WITH 
	 t2 AS 
	  (
	  select distinct sport , games
		from athlete_events
	  ) ,
	  t3 AS
	  (
	  select sport, Count(1) as no_of_games
		from t2
		group by sport 
	  )
SELECT t3.* , t2.Games
FROM
    t3
Join t2 on t3.Sport = t2.Sport
where 1 = t3.no_of_games

--8
--Fetch the total no of sports played in each olympic games.
select games , Count(distinct Sport) as no_of_sports
from athlete_events
group by games
order by 2 desc

--9
--Fetch oldest athletes to win a gold medal
with t1 as
	(select * 
	from athlete_events
	where medal ='Gold'),
	t2 as
	(
	select MAX(Age) as max_age
	from athlete_events
	where medal ='Gold'
	)
SELECT t1.* 
FROM
    t1
Join t2 on t1.age = t2.max_age

--10
--Find the Ratio of male and female athletes participated in all olympic games.
with t1 as
	(select count(*) as male_count
	from athlete_events
	where Sex = 'M'
	),
	t2 as
	(
	select count(*) as female_count
	from athlete_events
	where Sex = 'F'
	)
SELECT t2.female_count * 1.0 / t1.male_count *1.0
FROM
    t1 , t2

--11
--Fetch the top 5 athletes who have won the most gold medals.
select *
from 
	(select x.* , Dense_Rank() over( order by x.total_gold_medals desc) as Place
	from
		(select name , Team , count(name) as total_gold_medals 
			from athlete_events
			where medal ='Gold'
			group by name,Team
			) x ) y
where y.Place <6

--12
--Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
select *
from 
	(select x.* , Dense_Rank() over( order by x.total_gold_medals desc) as Place
	from
		(select name , Team , count(name) as total_gold_medals 
			from athlete_events
			where medal !='NA'
			group by name,Team
			) x ) y
where y.Place <6

--13
--Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

select *
from 
	(select x.* , Dense_Rank() over( order by x.total_gold_medals desc) as Place
	from
		(select Team , count(Medal) as total_medals 
			from athlete_events
			where medal !='NA'
			group by Team
			) x ) y
where y.Place <6

--14
--List down total gold, silver and bronze medals won by each country.
with t1 as
	(select distinct Team , count(Medal) as total_gold_medals 
			from athlete_events
			where medal ='Gold'
			group by Team ),
	t2 as
	(select distinct Team , count(Medal) as total_silver_medals 
			from athlete_events
			where medal ='Silver'
			group by Team),
	t3 as 
	(select distinct Team , count(Medal) as total_bronze_medals 
			from athlete_events
			where medal ='Bronze'
			group by Team)
select t1.* , t2.total_silver_medals , t3.total_bronze_medals
from t1 
join t2 on t1.Team = t2.Team
join t3 on t1.Team = t3.Team
order by 2 desc

--15
--List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
with t1 as
	(select distinct games , Team , count(Medal) as total_gold_medals 
			from athlete_events
			where medal ='Gold'
			group by Team , games),
	t2 as
	(select distinct games , Team , count(Medal) as total_silver_medals 
			from athlete_events
			where medal ='Silver'
			group by Team , games),
	t3 as 
	(select distinct games, Team , count(Medal) as total_bronze_medals 
			from athlete_events
			where medal ='Bronze'
			group by Team , games)
select t1.* , t2.total_silver_medals , t3.total_bronze_medals
from t1 
join t2 on t1.games = t2.games and t1.Team = t2.Team
join t3 on t1.games = t3.games and t1.Team = t3.Team
order by 1 ,2

--16
--Identify which country won the most gold, most silver and most bronze medals in each olympic games.
with t1 as
		(select *
		from (select * , FIRST_VALUE(Team) over(partition by games  order by total_gold_medals desc) as max_team , Concat(FIRST_VALUE(Team) over(partition by games  order by total_gold_medals desc) ,
							   '-' , FIRST_VALUE(total_gold_medals) over(partition by games  order by total_gold_medals desc)) as max_gold
			 from
			(select distinct games , Team , count(Medal) as total_gold_medals 
					from athlete_events
					where medal ='Gold'
					group by Team , games) x
			)y
			where team = max_team),
	t2 as
	(select *
		from (select * , FIRST_VALUE(Team) over(partition by games  order by total_gold_medals desc) as max_team , Concat(FIRST_VALUE(Team) over(partition by games  order by total_gold_medals desc) ,
							   '-' , FIRST_VALUE(total_gold_medals) over(partition by games  order by total_gold_medals desc)) as max_silver
			 from
			(select distinct games , Team , count(Medal) as total_gold_medals 
					from athlete_events
					where medal ='silver'
					group by Team , games) x
			)y
			where team = max_team),
	t3 as 
	(select *
		from (select * , FIRST_VALUE(Team) over(partition by games  order by total_gold_medals desc) as max_team , Concat(FIRST_VALUE(Team) over(partition by games  order by total_gold_medals desc) ,
							   '-' , FIRST_VALUE(total_gold_medals) over(partition by games  order by total_gold_medals desc)) as max_bronze
			 from
			(select distinct games , Team , count(Medal) as total_gold_medals 
					from athlete_events
					where medal ='Bronze'
					group by Team , games) x
			)y
			where team = max_team)
select t1.games ,t1.max_gold ,  t2.max_silver , t3.max_bronze
from t1 
join t2 on t1.games = t2.games 
join t3 on t1.games = t3.games 
order by 1 


--17
--Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
with t1 as
		(select *
		from (select * , FIRST_VALUE(Team) over(partition by games  order by total_gold_medals desc) as max_team , Concat(FIRST_VALUE(Team) over(partition by games  order by total_gold_medals desc) ,
							   '-' , FIRST_VALUE(total_gold_medals) over(partition by games  order by total_gold_medals desc)) as max_gold
			 from
			(select distinct games , Team , count(Medal) as total_gold_medals 
					from athlete_events
					where medal ='Gold'
					group by Team , games) x
			)y
			where team = max_team),
	t2 as
	(select *
		from (select * , FIRST_VALUE(Team) over(partition by games  order by total_gold_medals desc) as max_team , Concat(FIRST_VALUE(Team) over(partition by games  order by total_gold_medals desc) ,
							   '-' , FIRST_VALUE(total_gold_medals) over(partition by games  order by total_gold_medals desc)) as max_silver
			 from
			(select distinct games , Team , count(Medal) as total_gold_medals 
					from athlete_events
					where medal ='silver'
					group by Team , games) x
			)y
			where team = max_team),
	t3 as 
	(select *
		from (select * , FIRST_VALUE(Team) over(partition by games  order by total_gold_medals desc) as max_team , Concat(FIRST_VALUE(Team) over(partition by games  order by total_gold_medals desc) ,
							   '-' , FIRST_VALUE(total_gold_medals) over(partition by games  order by total_gold_medals desc)) as max_bronze
			 from
			(select distinct games , Team , count(Medal) as total_gold_medals 
					from athlete_events
					where medal ='Bronze'
					group by Team , games) x
			)y
			where team = max_team),
	t4 as 
	(select *
		from (select * , FIRST_VALUE(Team) over(partition by games  order by total_gold_medals desc) as max_team , Concat(FIRST_VALUE(Team) over(partition by games  order by total_gold_medals desc) ,
							   '-' , FIRST_VALUE(total_gold_medals) over(partition by games  order by total_gold_medals desc)) as max_medals
			 from
			(select distinct games , Team , count(Medal) as total_gold_medals 
					from athlete_events
					where medal !='NA'
					group by Team , games) x
			)y
			where team = max_team)
select t1.games ,t1.max_gold ,  t2.max_silver , t3.max_bronze ,t4.max_medals
from t1 
join t2 on t1.games = t2.games 
join t3 on t1.games = t3.games 
join t4 on t1.games = t4.games 
order by 1 

--18
--Which countries have never won gold medal but have won silver/bronze medals?

--19
--In which Sport/event, India has won highest medals.
Select Sport, Medals_per_Sport 
From
	(select * ,ROW_NUMBER() over(order by Medals_per_Sport desc) as RN
	from
		(select Sport , Count(Medal) as Medals_per_Sport
		from athlete_events
		where Team like '%India%'
		and Medal != 'NA'
		group by Sport) x) y
Where RN =1

--20
--Break down all olympic games where India won medal for Hockey and how many medals in each olympic games

select team , Sport , Games , Count(Medal) as Medals_per_Sport_and_year
		from athlete_events
		where Team like '%India%'
		and Medal != 'NA'
		group by Sport ,Team ,Games




