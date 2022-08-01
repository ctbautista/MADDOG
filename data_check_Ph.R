rm(list=ls())

library(ggplot2)
seq<-seqinr::read.alignment("/Users/criseldabautista/Documents/GitHub/MADDOG/Ph_designation/Ph_designation.fasta", format = "fasta")
metadata<-read.csv("/Users/criseldabautista/Documents/GitHub/MADDOG/Ph_designation/Ph_designation_metadata.csv")



`%notin%` <- Negate(`%in%`)

seq$nam[which(seq$nam %notin% metadata$ID)]
metadata$ID[which(metadata$ID %notin% seq$nam)]

regions<-data.frame(region=unique(metadata$place), count=NA)

for (i in 1:length(regions$region)) {
  regions$count[i]<-length(which(metadata$place == regions$region[i]))
}

hosts<-data.frame(host=unique(metadata$species), count=NA)

for (i in 1:length(hosts$host)) {
  hosts$count[i]<-length(which(metadata$species == hosts$host[i]))
}

world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
plot<-
  ggplot2::ggplot(data = world) +
  ggplot2::geom_sf() +
  ggplot2::geom_point(data = metadata, aes(x = longitude, y = latitude), size = 2,
                                shape = 23, fill = "darkred")

plot

plot + coord_sf(xlim = c(28,41), ylim = c(-12,0))

years<-data.frame(year=unique(metadata$year), count=NA)

for (i in 1:length(years$year)) {
  years$count[i]<-length(which(metadata$year == years$year[i]))
}

ggplot(data=years, aes(x=year, y=count)) +
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
