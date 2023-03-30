#########################################################################################################
# Hi Everyone
#  Clear memory
rm(list = ls())

#########################################################################################################
#  Set CRAN Mirror (place where code will be downloaded from)
local({
  r <- getOption("repos")
  r["CRAN"] <- "https://mirror.las.iastate.edu/CRAN/"
  options(repos = r)
})

#########################################################################################################
#  For this R-Session, change location of R-packages to be custom directory `r_packages`  
renv::restore()

#########################################################################################################
#  Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(renv, tidyverse)

#########################################################################################################
#  Import
data(diamonds)

#########################################################################################################
# Create a base for the contour plot that shades what would be the "downwind" section
BasePlot <- ggplot(data = diamonds, aes(x = price, y = carat)) + 
  geom_point(size = 3, alpha = .33) +
  theme_classic()

######################################################################################
# Draw and Save

# Save
ggsave("output/r_figure.png",
       plot=BasePlot,
       height  = 8,
       units = c("in"),
       dpi = 300)