
rm(list=ls())

metadata<-read.csv("/Users/criseldabautista/Documents/summer sessions/Asian_tests/SEA4_B1/metadata_B1.csv")
my_seq<-seqinr::read.alignment("/Users/criseldabautista/Documents/GitHub/MADDOG_CTB/Ph_designation/Ph_designation.fasta", format = "fasta")
public_seq<-seqinr::read.alignment("/Users/criseldabautista/Documents/summer sessions/Asian_tests/SEA4_A1.1.2/SEA4_A1.1.2.fasta",format = "fasta")

metadata<-metadata[-c(which(is.na(metadata$lab_date))),]

numbers<-which(public_seq$nam %in% metadata$Sample_ID)

public_seq$nam<-public_seq$nam[numbers]
public_seq$seq<-public_seq$seq[numbers]

numbers2<-which(my_seq$nam %in% metadata$Sample_ID)

public_seq$nam<-c(public_seq$nam, my_seq$nam[numbers2])
public_seq$seq<-c(public_seq$seq, my_seq$seq[numbers2])

length(public_seq$nam)
length(metadata$Sample_ID)

seqinr::write.fasta(sequences = my_seq$seq[numbers2], names = my_seq$nam[numbers2], file.out = "/Users/criseldabautista/Documents/summer sessions/Asian_tests/SEA4_B1/SEA4_B1.combined.fasta")
