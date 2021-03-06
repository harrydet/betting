########################################
# scripts to clean data to usable format
# pipe directly to sim.R
# source:
# - fixtures.csv: dedicatedexcel.com
# - Historical results: https://www.kaggle.com/thefc17/epl-results-19932018
#########################################
library (dplyr)

fixtures <- read.csv("fixtures.csv", stringsAsFactors = FALSE, fileEncoding="UTF-8-BOM")

fixtures$HOME.TEAM = trimws(fixtures$HOME.TEAM)
fixtures$AWAY.TEAM = trimws(fixtures$AWAY.TEAM)

# get the team
teams <- unique(fixtures$HOME.TEAM)

# extract historic results
history <- read.csv("history.csv", stringsAsFactors = FALSE, fileEncoding="UTF-8-BOM")

history$HomeTeam = trimws(history$HomeTeam)
history$AwayTeam = trimws(history$AwayTeam)

# get info from the 2010 up to 2018
seasons <- sapply(10:17, function(x) paste0(2000+x,'-',x+1))

recent.pl <- history %>%
  filter(Season %in% seasons, Div == 'E0')

# because the two data comes from different source, so the teams name don't match
teams[!teams %in% recent.pl$HomeTeam]
unique(recent.pl$HomeTeam)

# a bland average dataframe
ave_home <- recent.pl %>%
  group_by(HomeTeam) %>%
  summarize (ave_scored_h = mean(FTHG), ave_conceded_h = mean(FTAG)) %>%
  filter (HomeTeam %in% teams) %>% rename(Team = HomeTeam)

ave_away <- recent.pl %>%
  group_by(AwayTeam) %>%
  summarize (ave_scored_a = mean(FTAG), ave_conceded_a = mean(FTHG)) %>%
  filter (AwayTeam %in% teams)  %>% rename(Team = AwayTeam)

ave <- merge(ave_home, ave_away, by = 'Team')


# more precise result with pairwise
hist_pair.pl <- recent.pl %>%
  group_by(HomeTeam, AwayTeam) %>%
  filter (HomeTeam %in% teams, AwayTeam %in% teams) %>%
  summarize (match = n(), ave_home_scored = mean(FTHG), ave_away_scored = mean(FTAG))
  
rm(history, seasons, ave_home, ave_away)
