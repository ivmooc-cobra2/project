#### Housekeeping ####
setwd("/Users/b/GitHub/project/data/analysis/female-to-male by state")
pkgs <- c("RCurl", "dplyr", "reshape2", "ggplot2", "maptools", "scales", "RColorBrewer")
install.packages(pkgs)

library(RCurl)
library(dplyr)
library(reshape2)
library(ggplot2)
library(maptools)
library(scales)
library(RColorBrewer)

#### Read csv ####
gender.clean <- read.csv(text = getURL("https://raw.githubusercontent.com/ivmooc-cobra2/project/4503d38c79e5bfb8479273738e5df92e093095d9/data/cleaned/relations.csv"))

## Filter state counts by m/f
gender <- gender.clean %>%
    group_by(state, m_f) %>%
    summarize(count = n()) %>%
    filter(m_f %in% c("M", "F"), #Filter by gender
           state %in% c("AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", #Filter by state
                        "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", 
                        "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", 
                        "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", 
                        "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", 
                        "WY"))

## Reformat
gender.resh <- dcast(melt(gender), state ~ m_f) #Reshaping for proportion
gender.resh$F[is.na(gender.resh$F)] <- 0 #Replace na's with 0's
gender.prop <- gender.resh %>% #Add f:m proportion
    mutate("Female:Male proportion" = F / M)
colnames(gender.prop) <- c("State", "Females", "Males", "Female:Male proportion") #Rename columns
gender.prop <- gender.prop[match(states.shp$STATE_ABBR, gender.prop$State),]
glimpse(gender.prop) #Double check

#### Visualize ####
states.shp <- readShapeSpatial("states.shp") #Import states shape file
map.data <- data.frame(states=gender.prop$State, id=states.shp$STATE_FIPS, proportion=gender.prop$'Female:Male proportion') #Input data to plot on map
states.shp.f <- fortify(states.shp, region = "STATE_FIPS") #fortify shape file
merge.shp.coef<-merge(states.shp.f, map.data, by="id", all.x=TRUE) #merge with coefficients and reorder
final.plot<-merge.shp.coef[order(merge.shp.coef$order), ] 

graph <- ggplot() + #basic plot
    geom_polygon(data = final.plot, 
                 aes(x = long, y = lat, group = group, fill = proportion), 
                 color = "white", size = 0.25) + 
    coord_map() +
    scale_fill_distiller(name="Proportion", palette = "Reds", breaks = pretty_breaks(n = 5), direction = 1) +
    theme_nothing(legend = TRUE) +
    labs(title="Highest proportion of female-to-male letter writers in the United States")

#### Export ####
data.output = "/Users/b/GitHub/project/data/analysis/female-to-male by state/female.to.male.letter.writers.us.csv" #Folder to save data export

write.csv(gender.prop, data.output, row.names = FALSE)
ggsave("/Users/b/GitHub/project/viz/geospatial/female-to-male by state map.png", graph)