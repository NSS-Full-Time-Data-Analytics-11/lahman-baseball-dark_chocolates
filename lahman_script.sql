--     1. What range of years for baseball games played does the provided database cover?
-- 1871 to 2016

SELECT MIN(yearid), MAX(yearid)
FROM teams;



--     2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
-- Eddie Gaedel at 43 inches (3ft 7 in) played in 1 game for the St. Louis Browns. (This franchise would later become the Baltimore Orioles)

SELECT namefirst, namelast, height, G_all, name AS team_name --, franchname
FROM people LEFT JOIN (SELECT playerid, teamid, G_all FROM appearances) AS appearances USING (playerid)
			LEFT JOIN teams USING (teamid)
			LEFT JOIN teamsfranchises USING (franchid)
ORDER BY height
LIMIT 1;



--     3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last 
--	   names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. 
--	   Which Vanderbilt player earned the most money in the majors?
-- David Price with $245,553,888,00

SELECT namefirst || ' ' || namelast AS fullname, MIN(schoolname) AS schoolname, SUM(salary)::numeric::money AS tot_salary
FROM people LEFT JOIN collegeplaying USING (playerid)
			LEFT JOIN    schools     USING (schoolid)
			LEFT JOIN    salaries    USING (playerid)
WHERE schoolname = 'Vanderbilt University'
GROUP BY namefirst, namelast
ORDER BY tot_salary DESC NULLS LAST;



--     4. Using the fielding table, group players into three groups based on their position: label players with position OF as 
--	   "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
--	   Determine the number of putouts made by each of these three groups in 2016.
-- Battery: 41424		Infield: 58934		Outfield: 29560

SELECT CASE WHEN pos = 'OF' THEN 'Outfield'
	   		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
			WHEN pos IN ('P', 'C') THEN 'Battery'
			ELSE 'NA' END AS position,
	   SUM(po) AS tot_putouts
FROM fielding
WHERE yearid = 2016
GROUP BY position;



--     5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
-- Both Strikeouts and Homeruns had a peak in the 50's and 60's and have generally trended downward since (although strikeouts rose a bit in the 2010's)

WITH year_stats AS (
	SELECT yearid, MIN(FLOOR(yearid/10)*10) AS decade, 
		ROUND(AVG(g),2) AS avg_games, ROUND(AVG(so),2) AS avg_so, ROUND(AVG(hr),2) AS avg_hr
	FROM pitching
	WHERE yearid >= 1920
	GROUP BY yearid
	ORDER BY yearid)

SELECT decade, ROUND(AVG(avg_so/avg_games),2) AS so_per_game, ROUND(AVG(avg_hr/avg_games),2) AS hr_per_game
FROM year_stats
GROUP BY decade;



--     6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen 
--	   base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) 
--	   Consider only players who attempted at least 20 stolen bases.
-- Christopher Scott was the most successful at 91% 

WITH steal_stats AS (
	SELECT playerid, namegiven, yearid, sb, cs, sb+cs AS steal_attempts
	FROM batting INNER JOIN (SELECT playerid, namegiven FROM people) AS names USING (playerid)
	WHERE yearid = 2016 AND sb + cs >= 20)

SELECT namegiven, sb, cs, ROUND(100*sb/steal_attempts,2) AS steal_percent
FROM steal_stats
ORDER BY steal_percent DESC;



--     7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
-- Seattle Mariners won 116 games in 2001 but didn't win the world series.

SELECT yearid, teamid, name, w, l, wswin
FROM teams
WHERE yearid >= 1970 AND wswin = 'N'
ORDER BY w DESC
LIMIT 1;

--	   What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually 
--	   small number of wins for a world series champion – determine why this is the case. 
-- Los Angeles Dodgers won 63 games and won the world series. However, the average number of games played that season was less 
-- than average (due to a player's strike that split the season in two).

SELECT yearid, teamid, name, w, l, wswin
FROM teams
WHERE yearid >= 1970 AND wswin = 'Y'
ORDER BY w
LIMIT 1;

SELECT yearid, ROUND(AVG(g),2) AS avg_games
FROM teams
WHERE yearid >= 1970
GROUP BY yearid
ORDER BY avg_games;

--	   Then redo your query, excluding the problem year. 
-- Not counting 1981, the St. Louis Cardinals won the world series with only 83 wins that season.

SELECT yearid, teamid, name, w, l, wswin
FROM teams
WHERE yearid >= 1970 AND yearid <> 1981 AND wswin = 'Y'
ORDER BY w
LIMIT 1;

--	   How often from 1970 – 2016 was it the case that a team with the most wins also won the world series?
--	   What percentage of the time?
-- It occured 12 times: Out of the 47 years recorded, that 25.5% of the time.

WITH team_win_loss AS (
	SELECT yearid, teamid, name, w, l, wswin,
		   MAX(w) OVER (PARTITION BY yearid) AS most_wins
	FROM teams
	WHERE yearid >= 1970)

SELECT COUNT(*)
FROM team_win_loss
WHERE w = most_wins AND wswin = 'Y';



--     8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance 
--	   per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks 
--	   where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 
--	   5 average attendance.

SELECT park_name, team, name, attendance/games AS att_per_game
FROM homegames INNER JOIN parks USING (park)
			    LEFT JOIN (SELECT teamid, name FROM teams WHERE yearid=2016) AS teams ON homegames.team = teams.teamid
WHERE year = 2016 AND games >= 10
ORDER BY att_per_game DESC
LIMIT 5;

SELECT park_name, team, name, attendance/games AS att_per_game
FROM homegames INNER JOIN parks USING (park)
			    LEFT JOIN (SELECT teamid, name FROM teams WHERE yearid=2016) AS teams ON homegames.team = teams.teamid
WHERE year = 2016 AND games >= 10
ORDER BY att_per_game
LIMIT 5;



--     9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
--	   Give their full name and the teams that they were managing when they won the award.
-- Davey Johnson (with the Orioles and Nationals) and Jim Leyland (with the Pirates and Tigers)

WITH tsn_al AS (
	SELECT playerid, yearid AS al_year, lgid, awardid
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year' AND lgid = 'AL'),

tsn_nl AS (
	SELECT playerid, yearid AS nl_year, lgid, awardid
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year' AND lgid = 'NL'),

tsn_both AS (
	SELECT DISTINCT playerid, al_year, nl_year
	FROM tsn_al INNER JOIN tsn_nl USING(playerid, awardid))


SELECT DISTINCT namefirst || ' ' || namelast AS fullname, 
	   teamid, name AS team_name, yearid
FROM tsn_both INNER JOIN  people  USING (playerid)
			  INNER JOIN managers USING (playerid)
			  INNER JOIN  teams   USING (teamid, yearid)
WHERE yearid = al_year OR yearid = nl_year;



--     10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the 
--	   league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the 
--	   number of home runs they hit in 2016.

WITH hr_2016 AS (
	SELECT playerid, hr AS hr_2016
	FROM batting
	WHERE yearid = 2016 AND hr > 0),

hr_stats AS (
	SELECT playerid, hr, yearid, hr_2016,
	   	   MAX(hr) OVER (PARTITION BY playerid) AS max_hr
	FROM hr_2016 LEFT JOIN batting USING (playerid)),

hr_max AS (
	SELECT DISTINCT playerid, hr_2016
	FROM hr_stats
	WHERE hr_2016 = max_hr
	ORDER BY playerid),
	
hr_names AS (
	SELECT playerid, hr_2016
	FROM hr_max LEFT JOIN salaries USING (playerid)
	WHERE yearid = 2006
	ORDER BY playerid, yearid)
-- This last CTE checks to see if there was a salary in 2006 (meaning they've been playing for at least 10 years)

SELECT namefirst || ' ' || namelast AS fullname, hr_2016
FROM hr_names LEFT JOIN people USING (playerid);


-- Or, more succinctly: 


WITH hr_stats AS (
	SELECT playerid, namefirst || ' ' || namelast AS fullname, debut, hr, yearid,
		   MAX(hr) OVER (PARTITION BY playerid) AS max_hr
	FROM batting INNER JOIN people USING (playerid))

SELECT fullname, hr
FROM hr_stats
WHERE yearid = 2016 AND hr > 0 AND hr = max_hr AND debut::DATE < '2007-01-01'
ORDER BY playerid, yearid





-- Open-ended questions

--     11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. 
--	   As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to 
--	   look on a year-by-year basis.
-- My intution is saying no, there isn't a correlation.

WITH sal_wins AS (
	SELECT yearid, teamid, SUM(salary)::numeric::money AS team_salary, MAX(w) AS wins,
		   AVG(SUM(salary) / MAX(w)) OVER (PARTITION BY yearid)::numeric::money AS yearly_dollars_per_win,
		   AVG(SUM(salary) / MAX(w)) OVER (PARTITION BY teamid)::numeric::money AS team_dollars_per_win
	FROM salaries INNER JOIN teams USING (yearid, teamid)
	WHERE yearid >= 2000
	GROUP BY yearid, teamid
	ORDER BY teamid, yearid)

SELECT yearid, MAX(yearly_dollars_per_win) AS yearly_dollars_per_win
FROM sal_wins
GROUP BY yearid
ORDER BY yearid;



--     12. In this question, you will explore the connection between number of wins and attendance.
--         Does there appear to be any correlation between attendance at home games and number of wins?
-- Teams with above average wins in a year only have above average attendance 30% of the time, so I wouldn't say there's a correlation
-- between attendance and number of wins.

WITH att AS (
	SELECT year, teamid, g, ghome, 
		   w, AVG(w) OVER (PARTITION BY year)::INT AS avg_year_wins,
		   attendance, AVG(attendance) OVER (PARTITION BY year)::INT AS avg_year_att
	FROM (SELECT teamid, g, ghome, w, l, yearid FROM teams) AS team_stats INNER JOIN homegames 
		  ON team_stats.teamid = homegames.team AND team_stats.yearid = homegames.year
	WHERE ghome IS NOT NULL
	ORDER BY year, w DESC, attendance DESC),

att_avg AS (
	SELECT year, teamid, g, ghome, 
		   w, avg_year_wins, CASE WHEN avg_year_wins < w THEN 'Y'
								  ELSE 'N' END AS above_avg_wins,
		   attendance, avg_year_att, CASE WHEN avg_year_att < attendance THEN 'Y'
										  ELSE 'N' END AS above_avg_att
	FROM att)


SELECT COUNT(*), (SELECT COUNT(*) FROM att_avg) AS total, 
	   ROUND((100*COUNT(*)::numeric / (SELECT COUNT(*) FROM att_avg)::numeric),2) AS percentage
FROM att_avg
WHERE above_avg_wins = 'Y' AND above_avg_att = 'Y'

--         Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? 
--		   Making the playoffs means either being a division winner or a wild card winner.

WITH team_att AS (
	SELECT name, year, divwin,  wcwin, wswin, AVG(attendance)::INT AS avg_attendance,
		   AVG(attendance)::INT - LAG(AVG(attendance)::INT) OVER (PARTITION BY name) AS att_diff,
		   LAG(wswin) OVER (PARTITION BY name) AS year_after_wswin
	FROM (SELECT teamid, name, yearid, divwin, wcwin, wswin FROM teams) AS teams 
		 INNER JOIN 
		 (SELECT team, year, attendance FROM homegames) AS homegames ON teamid = team AND yearid = year
	WHERE wswin IS NOT NULL
	GROUP BY name, year, divwin, wcwin, wswin
	ORDER BY name, year)

SELECT *
FROM team_att
WHERE wswin = 'Y' OR year_after_wswin = 'Y'



--     13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are 
--	   more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just 
--	   how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the 
--	   Cy Young Award? Are they more likely to make it into the hall of fame?
