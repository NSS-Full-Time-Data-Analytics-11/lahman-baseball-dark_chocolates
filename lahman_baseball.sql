SELECT * from allstarfull
SELECT * from teams
SELECT * from homegames
SELECT * from teamshalf
SELECT * from appearances
SELECT * from awardsplayers
SELECT * from batting
---What range of years for baseball games played does the provided database cover? 

SELECT min(yearid),max(yearid) from teams


--Find the name and height of the shortest player in the database. How many games did he play in? 
--What is the name of the team for which he played?
SELECT * from people;
SELECT namefirst,namelast,g_all,min(height),count(g) as games_played 
from appearances
inner join people using (playerid)
INNER join teams using(teamid) 
group by people.playerid,namefirst,namelast,g_all
order by min(height) asc
LIMIT 1



--Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as 
--the total salary they earned in the major leagues. Sort this list in descending order by 
--the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT schoolname ,namefirst,namelast,SUM(salary ::numeric::money)as total_salary
FROM people
INNER JOIN salaries
USING (playerid)
INNER join collegeplaying 
USING (playerid)
INNER join schools 
USING (schoolid)
WHERE  schools.schoolname='Vanderbilt University'
GROUP BY schools.schoolname,people.namefirst,people.namelast
ORDER BY total_salary DESC;

--Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those
--with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
--Determine the number of putouts made by each of these three groups in 2016
SELECT * from fielding
SELECT * from people

SELECT namegiven as player, 
	CASE when pos in ('OF') then 'Outfield'
		 when pos in('SS', '1B','2B','3B') then 'Infield'
		 when pos in('P','C') then 'Battery'
		 else 'No position' 
		 end as position, sum(po) as putouts
from fielding
INNER join people using (playerid)
WHERE yearid = 2016
GROUP by 1,2
ORDER by player asc,putouts DESC



--Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. 
--Do the same for home runs per game. Do you see any trends?
SELECT yearid, so, g, so/g as so_per_game
	FROM teams
	where yearid >= 1920;
	
	
with strikeouts as (SELECT yearid, sum(so) / sum(g) as so_per_g
	FROM teams
	where yearid >= 1920
	GROUP BY yearid)
	select concat(left(yearid::text, 3),'0'), round(avg(so_per_g),2) from strikeouts
	--select left(yearid::text, 3), round(avg(so_per_g),2) from strikeouts
	group by left(yearid::text, 3)
	order by 1


--Do the same for home runs per game. Do you see any trends?

with homeruns as (SELECT yearid, sum(hra) / sum(g) as hra_per_g
	FROM teams
	where yearid >= 1920
	GROUP BY yearid)
	select concat(left(yearid::text, 3),'0'), round(avg(hra_per_g),2) from homeruns
	--select left(yearid::text, 3), round(avg(so_per_g),2) from strikeouts
	group by left(yearid::text, 3)
	order by 1



--Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. 
--(A stolen base attempt results either in a stolen base or being caught stealing.)
--Consider only players who attempted _at least_ 20 stolen bases.

	

 
--Add name
SELECT playerid, round((sb::numeric/(sb+cs)::numeric)*100, 2) as sb_success_rate
from batting
WHERE sb > 20 and yearid = 2016
order by 2 desc
limit 1


/*
	Step# 1
    From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
	Step# 2
	What is the smallest number of wins for a team that did win the world series? 
	Step# 3
	Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
	Then redo your query, excluding the problem year. 
	step #4
	How often from 1970 – 2016 was it the case that a 
team with the most wins also won the world series? What percentage of the time? */

(SELECT yearid, teamid, w as wins, WSWin as world_series_wins from teams
WHERE yearid between 1970 and 2016 and WSWin = 'N'
ORDER by wins desc
LIMIT 1)
union
(SELECT yearid, teamid, w as wins, WSWin as world_series_wins from teams
WHERE yearid between 1970 and 2016 and WSWin = 'Y' and yearid <> 1981
ORDER by wins asc
LIMIT 1)

/* part 4 of above question */

(SELECT yearid, teamid, w as wins, WSWin as world_series_wins from teams
WHERE yearid between 1970 and 2016 and WSWin = 'Y'
ORDER by wins desc
LIMIT 1)



SELECT yearid, teamid, sum(w) as wins, WSWin as world_series_wins from teams
WHERE yearid between 1970 and 2016 and WSWin = 'Y'
GROUP by teamid,yearid,world_series_wins
ORDER by wins desc


/*
Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per
game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. 
Report the park name, team name, and average attendance.  Repeat for the lowest 5 average attendance. */

with attendancedetails as (SELECT team,park,avg(attendance/games) ::integer as avg_attendance
						from homegames
						WHERE year = 2016
						GROUP BY 1,2)

SELECT attendancedetails.team,attendancedetails.park,sum(g) as games from attendancedetails 
INNER join parks 
on parks.park = attendancedetails.park
INNER join teams 
on parks.park_name = teams.park
WHERE g > 10
GROUP by 1,2,avg_attendance
order by avg_attendance desc
limit 5


SELECT *from homegames
SELECT *from parks

SELECT *from teams



/*
Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their 
full name and the teams that they were  managing when they won the award.*/

SELECT *from awardsmanagers;
SELECT *from teams;
SELECT * from managers



with attendancedata as (SELECT teams.teamid, awardid,yearid 
						from awardsmanagers
						INNER join teams using(yearid)
						WHERE awardid = 'TSN Manager of the Year' and awardsmanagers.lgid = 'AL'
						intersect
						SELECT teams.teamid,awardid, yearid from awardsmanagers
						INNER join teams using(yearid)
						WHERE awardid = 'TSN Manager of the Year' and awardsmanagers.lgid = 'NL')
						
SELECT distinct(teamid), awardid from attendancedata
INNER join managers using(teamid)



/*
Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years,
and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.*/
SELECT * from batting
SELECT * from teams

SELECT batting.yearid, teamid, max(batting.hr) from teams
INNER join batting using(teamid)
where batting.yearid = 2016
GROUP by 1,2

