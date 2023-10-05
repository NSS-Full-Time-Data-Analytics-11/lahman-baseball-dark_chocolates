--1. What range of years for baseball games played does the provided database cover?
  --from data dict: 1871 through 2016
  
--2. Find the name and height of the shortest player in the database. How many games did he play in? 
SELECT playerid, CONCAT (namefirst,' ', namelast), height, g_all AS games_played
FROM people JOIN appearances USING(playerid)
ORDER BY height
LIMIT 1;
--check it
SELECT *
FROM appearances
WHERE playerid = 'gaedeed01'
--What is the name of the team for which he played?
SELECT playerid, CONCAT (namefirst,' ', namelast), height, g_all AS games_played, teams.name AS team_name
FROM people JOIN appearances USING(playerid)
			JOIN teams USING(teamid)
ORDER BY height
LIMIT 1;


--3. Find all players in the database who played at Vanderbilt University. 
SELECT * FROM schools WHERE schoolname = 'Vanderbilt University'
SELECT *
FROM collegeplaying 
WHERE schoolid = 'vandy'

--Create a list showing each player’s first and last names as well as the total salary they earned in the 
--major leagues. Sort this list in descending order by the total salary earned. 

WITH vandyplayers AS (SELECT DISTINCT playerid, CONCAT(namefirst, ' ', namelast)AS name
					FROM collegeplaying INNER JOIN people USING(playerid)
					WHERE schoolid = 'vandy')
SELECT playerid, vandyplayers.name, SUM(salary) AS total_salary 
FROM salaries INNER JOIN vandyplayers USING(playerid)
GROUP BY playerid, vandyplayers.name
ORDER BY total_salary DESC
--Which Vanderbilt player earned the most money in the majors?
  --add a limit 1 to above & get David Price only
  
--4. Using the fielding table, group players into three groups based on their position: label players 
--with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those 
--with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups 
--in 2016.

SELECT SUM(po) AS putouts , 
	CASE WHEN pos IN ('OF') THEN 'Outfield' 
		 WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
		 WHEN pos IN ('P', 'C')  THEN 'Battery'END AS position	
FROM fielding
WHERE yearid = 2016
GROUP BY position

SELECT *
FROM FIELDING
 
 
--5.)Find the average number of strikeouts per game by decade since 1920. Round the numbers 
--you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

--Joshua's way--
WITH statsavg AS (SELECT yearid, MIN(FLOOR(yearid/10)*10) AS decade, ROUND(AVG(g),2) AS avg_games, 
		ROUND(AVG(so),2) AS avg_so, ROUND(AVG(hr),2) AS avg_hr
	FROM pitching
	WHERE yearid >= 1920
	GROUP BY yearid
	ORDER BY yearid)
SELECT decade, ROUND(AVG(avg_so/avg_games),2) AS so_gameavg, ROUND(AVG(avg_hr/avg_games),2) AS hr_gameavg
FROM statsavg
GROUP BY decade

--6. Find the player who had the most success stealing bases in 2016, where success is measured
--as the percentage of stolen base attempts which are successful. (A stolen base attempt 
--results either in a stolen base or being caught stealing.) Consider only players who attempted
--at least 20 stolen bases.
WITH steal_attempts AS (SELECT playerid, SUM(sb + cs) AS attempts, CONCAT(people.namefirst, ' ', people.namelast) AS playername
		FROM batting INNER JOIN people USING(playerid)
		WHERE yearid = 2016 
		GROUP BY playername, playerid
		ORDER BY attempts DESC)
SELECT playername, sb, cs, ROUND(sb/attempts, 2)AS steal_perc
FROM batting INNER JOIN steal_attempts USING(playerid)
WHERE attempts >20
GROUP BY steal_attempts

SELECT * FROM batting
round((sb::numeric/(sb+cs)::numeric)*100, 2)
--number of steals/attempts = %

--7.From 1970 – 2016, what is the largest number of wins for a team that did not win the world 
--series? 
select name , w , yearid
from TEAMS
WHERE (yearid BETWEEN 1970 AND 2016)
	AND wswin = 'N'
ORDER BY w DESC

--What is the smallest number of wins for a team that did win the world series? 
select name , w , yearid
from TEAMS
WHERE (yearid BETWEEN 1970 AND 2016)
	AND wswin = 'Y'
ORDER BY w 

--Doing this will probably result in an unusually small number of wins for a world series 
--champion – determine why this is the case. 
SELECT yearid, ROUND(AVG(g),2) AS avg_games
FROM teams
WHERE yearid >= 1970
GROUP BY yearid
ORDER BY avg_games


--Then redo your query, excluding the problem year. 
--How often from 1970 – 2016 was it the case that a team with the most wins also won the world 
--series? What percentage of the time?
SELECT name , w , yearid
FROM TEAMS
WHERE (yearid BETWEEN 1970 AND 2016)
	AND yearid <> 1981
	AND wswin = 'Y'
ORDER BY w 


--8. Using the attendance figures from the homegames table, find the teams and parks which had
--the top 5 average attendance per game in 2016 (where average attendance is defined as total 
--attendance divided by number of games). Only consider parks where there were at least 10 
--games played. Report the park name, team name, and average attendance. 

WITH big_games AS (SELECT team, park, (attendance/games) AS avg_attendance
					FROM homegames
					WHERE year = 2016 AND games >10
					ORDER BY avg_attendance DESC
					LIMIT 5)
SELECT team name, park_name, big_games.avg_attendance, teams.name
FROM big_games INNER JOIN parks USING (park)
			   full JOIN teams ON 'year' = 'yearid' AND 'team' = 'teamid'
ORDER BY avg_attendance 
LIMIT 5

--Repeat for the lowest 5 average attendance

--9. Which managers have won the TSN Manager of the Year award in both the National League(NL)
--and the American League (AL)? Give their full name and the teams that they were managing 
--when they won the award.
WITH winners AS ((SELECT playerid
				FROM awardsmanagers
				WHERE awardid = 'TSN Manager of the Year'
				AND lgid = 'NL' 
				ORDER BY playerid)
			INTERSECT
				(SELECT playerid
				FROM awardsmanagers
				WHERE awardid = 'TSN Manager of the Year'
				AND lgid = 'AL'
				ORDER BY playerid))
SELECT DISTINCT playerid, yearid, teamid, CONCAT(namefirst, ' ', namelast)
FROM awardsmanagers INNER JOIN winners USING(playerid)
					INNER JOIN managers USING(playerid, yearid)
					INNER JOIN people USING(playerid)
	
--10. Find all players who hit their career highest number of home runs in 2016. Consider 
--only players who have played in the league for at least 10 years, and who hit at least 
--one home run in 2016. Report the players' first and last names and the number of home 
--runs they hit in 2016.

--*-find 10 year players first
WITH decade_players AS (SELECT playerid, CONCAT(namefirst, ' ', namelast) AS name
						FROM people
						WHERE (finalgame::date - debut::date)/365 >10
						GROUP BY playerid)
SELECT playerid, hr, decade_players.name
FROM batting INNER JOIN decade_players USING(playerid)
WHERE yearid = 2016
ORDER BY hr DESC

 
