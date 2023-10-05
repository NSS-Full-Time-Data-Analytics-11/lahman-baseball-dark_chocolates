--1. What range of years for baseball games played does the provided database cover? 
SELECT MIN(year), MAX(year)
FROM homegames;

--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

WITH shortest_player AS (SELECT playerid, CONCAT(namefirst, ' ',namelast)AS full_name, height
					     FROM people
						 ORDER BY height
						 LIMIT 1)
SELECT full_name, height, SUM(g_all) AS total_games_played, name AS team_played_for
FROM shortest_player LEFT JOIN appearances USING (playerid) LEFT JOIN teams USING (teamid)
GROUP BY full_name, name, height;

--3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

WITH vandy_players AS (SELECT DISTINCT playerid, CONCAT(namefirst, ' ', namelast)AS full_name
					   FROM collegeplaying LEFT JOIN people USING (playerid)
					   WHERE schoolid = 'vandy')
SELECT full_name, SUM(salary)::text::money AS total_salary
FROM vandy_players LEFT JOIN salaries USING (playerid)
GROUP BY full_name
ORDER BY total_salary DESC NULLS LAST;

--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT playerid,
		CASE WHEN pos = 'OF' THEN 'Outfield'
			 WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
			 WHEN pos IN ('P', 'C') THEN 'Battery' END AS field_team
FROM fielding
GROUP BY field_team, playerid
ORDER BY field_team;

WITH field_teams AS (SELECT playerid, po, yearid,
		CASE WHEN pos = 'OF' THEN 'Outfield'
			 WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
			 WHEN pos IN ('P', 'C') THEN 'Battery' END AS field_team
	FROM fielding
	GROUP BY field_team, playerid, po, yearid
	ORDER BY field_team)
SELECT field_team, SUM(po) AS total_putouts
FROM field_teams
WHERE yearid = '2016'
GROUP BY field_team;

--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?


WITH decades_table AS(SELECT SUM(CASE WHEN yearid BETWEEN 1920 AND 1929 THEN ghome END)AS total_1920s_games,
	   SUM(CASE WHEN yearid BETWEEN 1930 AND 1939 THEN ghome END)AS total_1930s_games,
	   SUM(CASE WHEN yearid BETWEEN 1940 AND 1949 THEN ghome END)AS total_1940s_games,
	   SUM(CASE WHEN yearid BETWEEN 1950 AND 1959 THEN ghome END)AS total_1950s_games,
	   SUM(CASE WHEN yearid BETWEEN 1960 AND 1969 THEN ghome END)AS total_1960s_games,
	   SUM(CASE WHEN yearid BETWEEN 1970 AND 1979 THEN ghome END)AS total_1970s_games,
	   SUM(CASE WHEN yearid BETWEEN 1980 AND 1989 THEN ghome END)AS total_1980s_games,
	   SUM(CASE WHEN yearid BETWEEN 1990 AND 1999 THEN ghome END)AS total_1990s_games,
	   SUM(CASE WHEN yearid BETWEEN 2000 AND 2009 THEN ghome END)AS total_2000s_games,
	   SUM(CASE WHEN yearid BETWEEN 2010 AND 2016 THEN ghome END)AS half_2010s_games,
	   
	   SUM(CASE WHEN yearid BETWEEN 1920 AND 1929 THEN so END)AS total_1920s_sos,
	   SUM(CASE WHEN yearid BETWEEN 1930 AND 1939 THEN so END)AS total_1930s_sos,
	   SUM(CASE WHEN yearid BETWEEN 1940 AND 1949 THEN so END)AS total_1940s_sos,
	   SUM(CASE WHEN yearid BETWEEN 1950 AND 1959 THEN so END)AS total_1950s_sos,
	   SUM(CASE WHEN yearid BETWEEN 1960 AND 1969 THEN so END)AS total_1960s_sos,
	   SUM(CASE WHEN yearid BETWEEN 1970 AND 1979 THEN so END)AS total_1970s_sos,
	   SUM(CASE WHEN yearid BETWEEN 1980 AND 1989 THEN so END)AS total_1980s_sos,
	   SUM(CASE WHEN yearid BETWEEN 1990 AND 1999 THEN so END)AS total_1990s_sos,
	   SUM(CASE WHEN yearid BETWEEN 2000 AND 2009 THEN so END)AS total_2000s_sos,
	   SUM(CASE WHEN yearid BETWEEN 2010 AND 2016 THEN so END)AS half_2010s_sos
	FROM teams)

SELECT total_1920s_sos/total_1920s_games AS avg_sos_per_game_1920s,
	   total_1930s_sos/total_1930s_games AS avg_sos_per_game_1930s,
	   total_1940s_sos/total_1940s_games AS avg_sos_per_game_1940s,
	   total_1950s_sos/total_1950s_games AS avg_sos_per_game_1950s,
	   total_1960s_sos/total_1960s_games AS avg_sos_per_game_1960s,
	   total_1970s_sos/total_1970s_games AS avg_sos_per_game_1970s,
	   total_1980s_sos/total_1980s_games AS avg_sos_per_game_1980s,
	   total_1990s_sos/total_1990s_games AS avg_sos_per_game_1990s,
	   total_2000s_sos/total_2000s_games AS avg_sos_per_game_2000s,
	   half_2010s_sos/half_2010s_games AS avg_sos_per_game_2010s
FROM decades_table;


WITH home_run_table AS(SELECT SUM(CASE WHEN yearid BETWEEN 1920 AND 1929 THEN ghome END)AS total_1920s_games,
	   SUM(CASE WHEN yearid BETWEEN 1930 AND 1939 THEN ghome END)AS total_1930s_games,
	   SUM(CASE WHEN yearid BETWEEN 1940 AND 1949 THEN ghome END)AS total_1940s_games,
	   SUM(CASE WHEN yearid BETWEEN 1950 AND 1959 THEN ghome END)AS total_1950s_games,
	   SUM(CASE WHEN yearid BETWEEN 1960 AND 1969 THEN ghome END)AS total_1960s_games,
	   SUM(CASE WHEN yearid BETWEEN 1970 AND 1979 THEN ghome END)AS total_1970s_games,
	   SUM(CASE WHEN yearid BETWEEN 1980 AND 1989 THEN ghome END)AS total_1980s_games,
	   SUM(CASE WHEN yearid BETWEEN 1990 AND 1999 THEN ghome END)AS total_1990s_games,
	   SUM(CASE WHEN yearid BETWEEN 2000 AND 2009 THEN ghome END)AS total_2000s_games,
	   SUM(CASE WHEN yearid BETWEEN 2010 AND 2016 THEN ghome END)AS half_2010s_games,
	   
	   SUM(CASE WHEN yearid BETWEEN 1920 AND 1929 THEN hr END)AS total_1920s_hrs,
	   SUM(CASE WHEN yearid BETWEEN 1930 AND 1939 THEN hr END)AS total_1930s_hrs,
	   SUM(CASE WHEN yearid BETWEEN 1940 AND 1949 THEN hr END)AS total_1940s_hrs,
	   SUM(CASE WHEN yearid BETWEEN 1950 AND 1959 THEN hr END)AS total_1950s_hrs,
	   SUM(CASE WHEN yearid BETWEEN 1960 AND 1969 THEN hr END)AS total_1960s_hrs,
	   SUM(CASE WHEN yearid BETWEEN 1970 AND 1979 THEN hr END)AS total_1970s_hrs,
	   SUM(CASE WHEN yearid BETWEEN 1980 AND 1989 THEN hr END)AS total_1980s_hrs,
	   SUM(CASE WHEN yearid BETWEEN 1990 AND 1999 THEN hr END)AS total_1990s_hrs,
	   SUM(CASE WHEN yearid BETWEEN 2000 AND 2009 THEN hr END)AS total_2000s_hrs,
	   SUM(CASE WHEN yearid BETWEEN 2010 AND 2016 THEN hr END)AS half_2010s_hrs
	FROM teams)
SELECT total_1920s_hrs/total_1920s_games AS avg_hrs_per_game_1920s,
	   total_1930s_hrs/total_1930s_games AS avg_hrs_per_game_1930s,
	   total_1940s_hrs/total_1940s_games AS avg_hrs_per_game_1940s,
	   total_1950s_hrs/total_1950s_games AS avg_hrs_per_game_1950s,
	   total_1960s_hrs/total_1960s_games AS avg_hrs_per_game_1960s,
	   total_1970s_hrs/total_1970s_games AS avg_hrs_per_game_1970s,
	   total_1980s_hrs/total_1980s_games AS avg_hrs_per_game_1980s,
	   total_1990s_hrs/total_1990s_games AS avg_hrs_per_game_1990s,
	   total_2000s_hrs/total_2000s_games AS avg_hrs_per_game_2000s,
	   half_2010s_hrs/half_2010s_games AS avg_hrs_per_game_2010s
FROM home_run_table;

--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

SELECT CONCAT(namefirst, ' ',namelast)AS full_name, (sb*100)/(sb+cs)AS percent_success_steals
FROM batting LEFT JOIN people USING (playerid)
WHERE yearid = 2016 AND sb >0 AND cs >0
GROUP BY namefirst, namelast, sb, cs
HAVING SUM(sb + cs)>20
ORDER BY percent_success_steals DESC;

--7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT name, w, wswin, yearid
FROM teams
WHERE wswin = 'N'AND yearid BETWEEN 1970 AND 2016
ORDER BY w DESC;

SELECT name, w, wswin, yearid
FROM teams
WHERE wswin = 'Y' AND yearid BETWEEN 1970 AND 2016 AND yearid <>1981
GROUP BY yearid, w, wswin, name
ORDER BY w;




WITH wins_table AS(SELECT name, w, yearid, wswin,
			SUM(CASE WHEN wswin = 'Y' THEN 1 END)AS sum_ws_wins
			
		FROM teams
		WHERE wswin = 'Y' AND yearid BETWEEN 1970 AND 2016
		GROUP BY name, w, yearid, wswin
		UNION ALL
		SELECT name, w, yearid, wswin,
			SUM(CASE WHEN wswin = 'N' THEN 1 END)AS sum_ws_no
		FROM teams
		WHERE yearid BETWEEN 1970 AND 2016 AND w>= (SELECT MAX(w) AS max_wins
											FROM teams)
		GROUP BY name, w, yearid, wswin
		ORDER BY yearid)
SELECT name, w, yearid, wswin, ROUND((1.00/47.00)::decimal*100.00) AS percentage
FROM wins_table
GROUP BY yearid, w, name, wswin;

--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT park_name, name, homegames.attendance/games AS avg_attendance, year
FROM homegames FULL JOIN teams ON team = teamid AND homegames.year = teams.yearid 
			   LEFT JOIN parks ON homegames.park = parks.park
WHERE year = '2016' 
GROUP BY park_name, name, homegames.attendance, games, year
ORDER BY avg_attendance DESC
LIMIT 5;

SELECT park_name, name, homegames.attendance/games AS avg_attendance, year
FROM homegames FULL JOIN teams ON team = teamid AND homegames.year = teams.yearid 
			   LEFT JOIN parks ON homegames.park = parks.park
WHERE year = '2016' 
GROUP BY park_name, name, homegames.attendance, games, year
ORDER BY avg_attendance 
LIMIT 5;

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.


WITH mang_of_year AS ((SELECT DISTINCT playerid
					FROM awardsmanagers
					WHERE awardid = 'TSN Manager of the Year' AND lgid = 'NL'
					GROUP BY playerid
					ORDER BY playerid)
					INTERSECT
					(SELECT DISTINCT playerid
					FROM awardsmanagers
					WHERE awardid = 'TSN Manager of the Year' AND lgid = 'AL'
					GROUP BY playerid
					ORDER BY playerid))					
SELECT CONCAT(namefirst, ' ',namelast)AS full_name, awardsmanagers.yearid AS year, awardsmanagers.lgid, teamid
FROM mang_of_year INNER JOIN people USING (playerid)
				  INNER JOIN managers USING (playerid)
				  INNER JOIN awardsmanagers USING (playerid, yearid) 
WHERE awardid = 'TSN Manager of the Year'
GROUP BY full_name, awardsmanagers.yearid, awardsmanagers.lgid, teamid;

--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

WITH hr_2016 AS (SELECT playerid, hr, yearid
				 FROM batting
				 WHERE hr >0 AND yearid = 2016)
SELECT playerid, batting.yearid, debut::date, MAX(batting.hr)
FROM hr_2016 LEFT JOIN batting USING (playerid)
			 LEFT JOIN people USING (playerid)
WHERE debut::date < '2006-01-01'
GROUP BY playerid, batting.yearid, debut::date




				  





