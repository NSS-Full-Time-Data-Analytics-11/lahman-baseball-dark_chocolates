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
 
 
--Find the average number of strikeouts per game by decade since 1920. Round the numbers 
--you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
SELECT *
FROM batting

WITH yearly_strikeouts AS (SELECT yearid, ROUND(AVG(so),2)
						   FROM batting
						   GROUP BY yearid
						   ORDER BY yearid)




--9. Which managers have won the TSN Manager of the Year award in both the National League(NL)
--and the American League (AL)? Give their full name and the teams that they were managing 
--when they won the award.

SELECT playerid, yearid , lgid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
ORDER BY playerid


---failed INTESECT
SELECT playerid, yearid , lgid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
AND lgid = 'NL' 
INTERSECT
SELECT playerid, yearid , lgid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
AND lgid = 'AL'


SELECT CONCAT(namefirst, ' ', namelast), awards.playerid, awards.yearid, teams.name
FROM people INNER JOIN teams USING(yearid)

SELECT * FROM teams

