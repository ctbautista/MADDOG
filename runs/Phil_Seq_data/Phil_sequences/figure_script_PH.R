rm(list=ls())
setwd("~/Documents/GitHub/MADDOG_CTB/Phil_Seq_data/Phil_sequences")

#Import your libraries
library(ggtree)
library(rgdal)
library(ggplot2)

#Import your data - this will be the tree you just made, the sequence data output from MADDOG designation,
# and the new and relevant lineage outputs from MADDOG designation

sequence_data<-read.csv("Phil_designation/Outputs/sequence_data.csv")
lineage_info<-read.csv("Phil_designation/Outputs/relevant_lineages.csv")
new_lineage<-read.csv("Phil_designation/Outputs/new_lineages.csv")
tree<-ape::read.tree("Phil_designation/Trees/Phil_designation_combined_aligned.fasta.contree")

#Run this next line ONLY if your 'lineage_info' table in R has 7 columns:
#lineage_info<-lineage_info[,-c(1)]

#This combines the new and relevant lineages into one table
lineage_info<-rbind(lineage_info, new_lineage)

#Selecting a list of colours ready to use
lineage_info$colour<-NA

Colours<-c("Reds","Purples","YlOrBr","PuBuGn","YlOrRd","OrRd","PuBu","Pastel1","Greens","Greys",
           "GnBu","BuGn","RdPu","Oranges","BuPu","YlGn","PuRd","YlGnBu")

#Extracting the subclades from the lineage (e.g. Cosmopolitan AF1b, Cosmopolitan AF1a)
lineages<-data.frame(lineage = lineage_info$lineage, subclade = NA)

for (i in 1:length(lineages$lineage)) {
  lineages$subclade[i]<-strsplit(lineages$lineage[i], "_")[[1]][1]
}

letters <- c("A1", "B1", "C1", "D1", "E1", "F1", "G1", "H1", "I1", "J1", "K1", "L1", "M1", "N1",
             "O1", "P1", "Q1", "R1", "S1", "T1", "U1", "V1", "W1", "X1", "Y1", "Z1")

if(length(grep("_", lineage_info$lineage)) != 0) {
  if (length(which(lineages$subclade %in% letters)) != 0) {
    lineages<-lineages[-c(which(lineages$subclade %in% letters)),]
  }
}

#Assigning a colour group to each subclade (e.g. Purple may be AF1b) then giving each lineage a unique colour
# within the subclade colour group (e.g. AF1b_A1 = dark purple, AF1b_A1.1 = light purple)
clades<-unique(lineages$subclade)

lineage<-lineage_info$lineage[-c(grep("_", lineage_info$lineage))]
cols<-RColorBrewer::brewer.pal(9, "Blues")
pal<-colorRampPalette(c(cols))
pal<-rev(pal(length(lineage)))
lineage_info$colour[-c(grep("_", lineage_info$lineage))]<-pal

for (i in 1:length(clades)) {
  lineage<-grep(clades[i], lineage_info$lineage)
  cols<-RColorBrewer::brewer.pal(3, Colours[i])
  pal<-colorRampPalette(c(cols))
  pal<-rev(pal(length(lineage)))
  lineage_info$colour[(grep(clades[i], lineage_info$lineage))]<-pal
}
attach(sequence_data)

lineage_info<-lineage_info[order(lineage_info$lineage),]

#Making a nice tree with tips colours according to lineage, outlined in grey for aesthetics
plot_tree<-ggtree::ggtree(tree, colour = "grey50", ladderize = T) %<+% sequence_data +
  ggtree::geom_tippoint(color="grey50", size=4)+
  ggtree::geom_tippoint(ggplot2::aes(color=lineage), size=3)  +
  ggtree::theme(plot.title = ggplot2::element_text(size = 40, face = "bold"))+
  ggtree::scale_color_manual(values=c(lineage_info$colour)) +
  ggtree::theme(legend.position = "none")

#Adding a bar along the side to show lineage colours/positions
genotype<-data.frame(lineage = sequence_data$lineage)
rownames(genotype)<-sequence_data$ID

plot_tree<-ggtree::gheatmap(plot_tree, genotype, offset=-0.01, width=.1, font.size=3, color = NA,
                            colnames_angle=-45, hjust=0) +
  ggtree::scale_fill_manual(values=c(lineage_info$colour), name="lineage")+
  ggtree::theme(legend.position = "none")

#View the tree!
plot_tree

#Save the tree!
ggsave("PH_figures/tree.png", plot = plot_tree)

#Identify which essential ancestral lineages aren't included in your dataset - for this we'll add them by hand!
'%notin%'<-Negate("%in%")

lineage_info$parent[which(lineage_info$parent %notin% lineage_info$lineage)]

write.csv(lineage_info, "PH_figures/test.csv", row.names = F)

#Now go to the test.csv file and add the necessary lineages! E.g. if C1.1 was listed here, add 'C1.1' to
# the 'lineage' column, with n_seqs = 0, and add C1 in the 'parent' column. This is easy for any with .x, as
# you just remove the .x to get the parent (parent of A1.2 is A1, parent of B1.3.1 is B1.3 etc). For any without
# .x, refer to reference sunbursts to identify parents!

# The overall clade is fine to leave as is - e.g. 'Cosmopolitan' will be identified as a parent without a listed
# lineage here, but that's fine!

#When you've corrected the lineage file, reimport it!
lineage_info<-read.csv("PH_figures/test.csv")

#Check there aren't any more missing evolutionary lineages (except the overall clade)
'%notin%'<-Negate("%in%")

lineage_info$parent[which(lineage_info$parent %notin% lineage_info$lineage)]


#If there are none - make the sunburst!
sunburst<-plotly::plot_ly(
  labels = c(lineage_info$lineage),
  parents = c(lineage_info$parent),
  values = c(lineage_info$n_seqs),
  type = "sunburst",
  marker = list(colors = (lineage_info$colour))
)

#View the sunburst
sunburst

#Save the sunburst as an interactive html!
htmlwidgets::saveWidget(plotly::as_widget(sunburst), "sunburst.html")

#Import your shapefile
shape_district<-readOGR("Shapefiles/PHLsmallTEST_fixed.shp")

#Plot a map of your shapefile
plot<-
  ggplot() +
  geom_polygon(data = shape_district, aes( x = long, y = lat, group = group), fill="grey80", color="white") +
  theme_bw() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

#Import your metadata with the lat/long info
metadata<-read.csv("Phil_metadata_prov.csv")

#If you haven't already, add the lineage info to the metadata (mine doesn't need this - so don't run this if
# you're using mine as an example!)
metadata$lineage<-NA
for (i in 1:length(metadata$ID)) {
  metadata$lineage[i]<-sequence_data$lineage[which(sequence_data$ID == metadata$ID[i])]
}

#Add the lineage colour info to the metadata so everything stays the same colour scheme
metadata$colour<-NA

for (i in 1:length(metadata$ID)) {
  metadata$colour[i]<-lineage_info$colour[which(lineage_info$lineage == metadata$lineage[i])]
}

#Add your data to the overall country plot
country_plot<-plot +
  geom_point(data = metadata, aes(x = longitude, y = latitude), size = 2,
             shape = 23, fill = metadata$colour)

#View the plot. It can take some time to appear!
country_plot

#Save the plot
ggsave("PH_figures/country_plot.png",
       plot = country_plot)

#We can zoom in on specific areas of interest by adding coordinate limits to our country plot:
zoom<-country_plot+
  coord_sf(xlim = c(120.0,123), ylim=c(12.0,15.0))

#See the plot
zoom

#Save the plot
ggsave("PH_figures/zoom_plot.png",
       plot = zoom)


