#########################################################################################################
#  Clear memory
rm(list = ls())

#########################################################################################################
#  For this R-Session, change location of R-packages to be custom directory `r_packages`  
assign(".lib.loc", "r_packages/", envir = environment(.libPaths))

#########################################################################################################
#  Load haven (to import data)
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse)

#########################################################################################################
#  Import
data(diamonds)

#########################################################################################################
# Create a base for the contour plot that shades what would be the "downwind" section
BasePlot <- ggplot(data = diamond, aes(x = price, y = carat)) + 
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