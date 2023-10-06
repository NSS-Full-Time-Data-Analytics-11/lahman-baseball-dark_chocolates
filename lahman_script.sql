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
-- According to the first query, both Strikeouts and Homeruns had a peak in the 50's and 60's and have generally trended downward since
-- 		(although strikeouts rose a bit in the 2010's). This query is a little strange because of how it takes averages of averages.
-- The second query (which I believe gives more accurate info) has a trend of strikeouts generally increasing over the decades and homeruns having a 
-- 		small peak in the 50's before having a large peak in the 2000's.

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

-- Or alternatively:

WITH year_stats AS (
	SELECT yearid, MIN(FLOOR(yearid/10)*10) AS decade,
		   SUM(g)::decimal AS tot_games, SUM(so)::decimal AS tot_so, SUM(hr)::decimal AS tot_hr
	FROM batting
	WHERE yearid >= 1920
	GROUP BY yearid
	ORDER BY yearid)

SELECT decade, ROUND(10*AVG(tot_so/tot_games),2) AS so_per_game, ROUND(100*AVG(tot_hr/tot_games),2) AS hr_per_game
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

/*
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
*/

-- Or, more succinctly (and with more people): 


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
-- My intution is saying no, there isn't a correlation. Trying to find "dollars per win" may not be the best approach, but nothing
-- stands out in a way that makes me think that winning more is correlated with an increased salary.

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
		   w AS wins,  AVG(w) 		   OVER (PARTITION BY year)::INT AS avg_year_wins,
		   attendance, AVG(attendance) OVER (PARTITION BY year)::INT AS avg_year_att
	
	FROM (SELECT teamid, g, ghome, w, l, yearid FROM teams) AS team_stats INNER JOIN homegames 
		  ON team_stats.teamid = homegames.team AND team_stats.yearid = homegames.year
	
	WHERE ghome IS NOT NULL
	ORDER BY year, w DESC, attendance DESC),

att_avg AS (
	SELECT year, teamid, g, ghome, 
		   wins,   avg_year_wins, 	 CASE WHEN  avg_year_wins  <  wins   THEN 'Y'
								  		  ELSE 'N' END AS above_avg_wins,
		   attendance, avg_year_att, CASE WHEN avg_year_att < attendance THEN 'Y'
										  ELSE 'N' END AS above_avg_att
	FROM att)


SELECT COUNT(*) AS abv_avg_w_att, (SELECT COUNT(*) FROM att_avg) AS tot_w_att, 
	   ROUND((100*COUNT(*)::numeric / (SELECT COUNT(*) FROM att_avg)::numeric),2) AS percentage
FROM att_avg
WHERE above_avg_wins = 'Y' AND above_avg_att = 'Y'

--         Do teams that win the world series see a boost in attendance the following year? 
-- In general, no they do not. After labeling which years were years after a World Series win, I then took the difference in attendance
-- for the home field of each team. Out of the 116 times that the world series was followed by another season, 60 time the attendance
-- deccreased (or stayed at 0 for a few cases)! That means that 51% of the time, attendance will decrease after a World Series Win. 
-- Essentially, it's a 50-50 chance that attendance will increase after a team wins the World Series.

WITH team_att AS (
	SELECT name, year, wswin, AVG(attendance)::INT AS avg_attendance,
		   AVG(attendance)::INT - LAG(AVG(attendance)::INT) OVER (PARTITION BY name) AS att_diff,
		   LAG(wswin) OVER (PARTITION BY name) AS year_after_wswin
	FROM (SELECT teamid, name, yearid, divwin, wcwin, wswin FROM teams) AS teams 
		 INNER JOIN 
		 (SELECT team, year, attendance FROM homegames) AS homegames ON teamid = team AND yearid = year
	WHERE wswin IS NOT NULL
	GROUP BY name, year, divwin, wcwin, wswin
	ORDER BY name, year),
	
decrease AS (
	SELECT COUNT(*) AS year_after_win_decrease
	FROM team_att 
	WHERE year_after_wswin = 'Y' AND att_diff <= 0)
	
	
SELECT (SELECT year_after_win_decrease FROM decrease),
	   COUNT(*) AS year_after_win_total,
	   ROUND(100*(SELECT year_after_win_decrease FROM decrease)::decimal / COUNT(*)::decimal,2) AS percent_decrease
FROM team_att
WHERE year_after_wswin = 'Y'

--		   What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.
-- Unlike after winning a World Series, a team making the playoffs only has decreased attendance the next year 40.5% of the time.
-- So, it is more likely that attendance will increase after a team makes the playoffs than if they won the World Series (although, you
-- need to make the playoffs to win the World Series, but this query involves every single team that made playoffs).

WITH team_att AS (
	SELECT name, year, divwin, wcwin, 
		   CASE WHEN divwin = 'Y' OR wcwin = 'Y' THEN 'Y'
				ELSE 'N' END AS playoff,
		   AVG(attendance)::INT AS avg_attendance,
		   AVG(attendance)::INT - LAG(AVG(attendance)::INT) OVER (PARTITION BY name) AS att_diff,
		   LAG(divwin) OVER (PARTITION BY name) AS year_after_divwin,
		   LAG(wcwin)  OVER (PARTITION BY name) AS year_after_wcwin
	FROM (SELECT teamid, name, yearid, divwin, wcwin, wswin FROM teams) AS teams 
		 INNER JOIN 
		 (SELECT team, year, attendance FROM homegames) AS homegames ON teamid = team AND yearid = year
	WHERE wswin IS NOT NULL
	GROUP BY name, year, divwin, wcwin, wswin
	ORDER BY name, year),
	
playoff AS (
	SELECT name, year, playoff, att_diff,
		   CASE WHEN year_after_divwin = 'Y' OR year_after_wcwin = 'Y' THEN 'Y'
				ELSE 'N' END AS year_after_playoff
	FROM team_att
	WHERE playoff = 'Y' OR year_after_divwin = 'Y' OR year_after_wcwin = 'Y')

SELECT (SELECT COUNT(*) FROM playoff WHERE year_after_playoff = 'Y') AS year_after_playoff_total,
	   COUNT(*) AS year_after_playoff_decrease,
	   ROUND(100*COUNT(*)::decimal / (SELECT COUNT(*) FROM playoff WHERE year_after_playoff = 'Y')::decimal,2) AS percent_decrease
FROM playoff
WHERE year_after_playoff = 'Y' AND att_diff <= 0;



--     13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are 
--	   more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just 
--	   how rare left-handed pitchers are compared with right-handed pitchers. 
-- Only 26.63% of pitchers are left handed, so they are more rare.

WITH left_pitchers AS (
	SELECT DISTINCT *
	FROM (SELECT playerid, namefirst || ' ' || namelast AS fullname, throws FROM people) AS hand 
		 RIGHT JOIN 
		 (SELECT playerid FROM pitching) AS pitch USING (playerid)
	WHERE throws = 'L'),

all_pitchers AS (
	SELECT DISTINCT playerid, namefirst || ' ' || namelast AS fullname, throws
	FROM people INNER JOIN pitching USING (playerid))

SELECT ROUND(100*(SELECT COUNT(*) FROM left_pitchers)::decimal / (SELECT COUNT(*) FROM all_pitchers)::decimal,2) AS left_percent

--		Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?
-- 53 right handed pitchers received the Cy Young Award when only 24 left handed pitchers did the same.
-- 347 right handed pitchers got into the Hall of Fame while only 141 left handed pitchers got in.
-- Overall, right handed pitchers get more awards likely because there are more of them to receive awards. As such, there may not be 
-- a distinct advantage of using left handed pitchers as a strategic move.

WITH left_pitchers AS (
	SELECT DISTINCT *
	FROM (SELECT playerid, namefirst || ' ' || namelast AS fullname, throws FROM people) AS hand 
		 RIGHT JOIN 
		 (SELECT playerid FROM pitching) AS pitch USING (playerid)
	WHERE throws = 'L'),

right_pitchers AS (
	SELECT DISTINCT *
	FROM (SELECT playerid, namefirst || ' ' || namelast AS fullname, throws FROM people) AS hand 
		 RIGHT JOIN 
		 (SELECT playerid FROM pitching) AS pitch USING (playerid)
	WHERE throws = 'R'),

left_cy AS (
	SELECT DISTINCT playerid, fullname, throws
	FROM left_pitchers INNER JOIN awardsplayers USING (playerid)
	WHERE awardid = 'Cy Young Award'),

right_cy AS (
	SELECT DISTINCT playerid, fullname, throws
	FROM right_pitchers INNER JOIN awardsplayers USING (playerid)
	WHERE awardid = 'Cy Young Award'),
	
left_fame AS (
	SELECT DISTINCT playerid, fullname, throws
	FROM left_pitchers INNER JOIN halloffame USING (playerid)),

right_fame AS (
	SELECT DISTINCT playerid, fullname, throws
	FROM right_pitchers INNER JOIN halloffame USING (playerid))

SELECT (SELECT COUNT(*) FROM left_cy)  AS  left_cy_count, 
	   (SELECT COUNT(*) FROM right_cy) AS right_cy_count,
	   (SELECT COUNT(*) FROM left_fame)  AS  left_fame_count,
	   (SELECT COUNT(*) FROM right_fame) AS right_fame_count;







