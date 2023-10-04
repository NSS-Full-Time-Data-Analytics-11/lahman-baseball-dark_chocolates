--What range of years for baseball games played does the provided database cover?
  --from data dict: 1871 through 2016
  
--Find the name and height of the shortest player in the database. How many games did he play in? 
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

--Find all players in the database who played at Vanderbilt University. 
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
  
--Using the fielding table, group players into three groups based on their position: label players 
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
SELECT *
FROM batting

--6. Find the player who had the most success stealing bases in 2016, where success is measured
--as the percentage of stolen base attempts which are successful. (A stolen base attempt 
--results either in a stolen base or being caught stealing.) Consider only players who attempted
--at least 20 stolen bases.



--7.From 1970 – 2016, what is the largest number of wins for a team that did not win the world 
--series? What is the smallest number of wins for a team that did win the world series? 
--Doing this will probably result in an unusually small number of wins for a world series 
--champion – determine why this is the case. Then redo your query, excluding the problem year. 
--How often from 1970 – 2016 was it the case that a team with the most wins also won the world 
--series? What percentage of the time?

--8. Using the attendance figures from the homegames table, find the teams and parks which had
--the top 5 average attendance per game in 2016 (where average attendance is defined as total 
--attendance divided by number of games). Only consider parks where there were at least 10 
--games played. Report the park name, team name, and average attendance. Repeat for the lowest
--5 average attendance

WITH big_games AS (SELECT team, park, (attendance/games) AS avg_attendance
					FROM homegames
					WHERE year = 2016 AND games >10
					ORDER BY avg_attendance DESC
					LIMIT 5)
SELECT team name , park_name, big_games.avg_attendance
FROM big_games INNER JOIN parks USING (park)
			
ORDER BY avg_attendance DESC

SELECT * FROM teams
SELECT * FROM parks

WITH big_games AS (SELECT team, park, (attendance/games) AS avg_attendance
					FROM homegames
					WHERE year = 2016 AND games >10
					ORDER BY avg_attendance DESC
					LIMIT 5)
SELECT name , park_name, big_games.avg_attendance
FROM teams INNER JOIN parks ON 'park' = 'park_name'
			INNER JOIN big_games USING(park)
ORDER BY avg_attendance DESC



--9. Which managers have won the TSN Manager of the Year award in both the National League(NL)
--and the American League (AL)? Give their full name and the teams that they were managing 
--when they won the award.

---failed INTERSECT
SELECT playerid, yearid , lgid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
AND lgid = 'NL' 
INTERSECT
SELECT playerid, yearid , lgid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
AND lgid = 'AL'
--why wont it pull johnsda02?

SELECT CONCAT(namefirst, ' ', namelast), awards.playerid, awards.yearid, teams.name
FROM people INNER JOIN teams USING(yearid)

SELECT * FROM people

--10. Find all players who hit their career highest number of home runs in 2016. Consider 
--only players who have played in the league for at least 10 years, and who hit at least 
--one home run in 2016. Report the players' first and last names and the number of home 
--runs they hit in 2016.

--*-find 10 year players
SELECT *
FROM people






