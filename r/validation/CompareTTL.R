###############################################################################
# FILE : CompareTTL.R
# DESCR: Compare TTL files created with R vs those from AO
# SRC  : 
# KEYS : 
# NOTES: 
#        
# INPUT: 
#      : 
# OUT  : 
# REQ  : 
# TODO : 
###############################################################################
require(rrdf)
require(dplyr) # for compare of dataframes using anti_join
# library(plyr)  # for rename

# For use with local TTL file:
setwd("C:/_gitHub/SDTM2RDF")

TWSource = load.rdf("data/rdf/cdiscpilot01.TTL", format="N3")

AOSource = load.rdf("data/rdf/Armando-21DEC16/cdiscpilot01local.TTL", format="N3")


checkPerson <- function(){
#--Person_(n)

#  All triples directly attached to Person_<n>  
# 
query = 'PREFIX cdiscpilot01: <http://example.org/cdiscpilot01#>
PREFIX custom: <http://example.org/custom#>
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX study:  <http://example.org/study#>

SELECT ?s ?p ?o
WHERE { cdiscpilot01:Person_1 ?p ?o . 
  BIND("cdiscpilot01:Person_1" as ?s)
}'
TWTriples = as.data.frame(sparql.rdf(TWSource, query))
AOTriples = as.data.frame(sparql.rdf(AOSource, query))


inTWNotAO<-anti_join(TWTriples, AOTriples)
inAONotTW<-anti_join(AOTriples, TWTriples)

# In the TW TTL file but not in the AO file                 
inTWNotAO
# In the AO TTL file but not in the TO file
inAONotTW

}

checkPredicate <- function(predicate){
#-----------------------------------------------------------------
#-- cdiscpilot01:Person_1 study:hasAgeMeasurement 
predicate <- "study:hasAgeMeasurement"
query = paste(' 
    PREFIX cdiscpilot01: <http://example.org/cdiscpilot01#>
    PREFIX custom: <http://example.org/custom#>
    PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
    PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#> 
    PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
    PREFIX study:  <http://example.org/study#>
    SELECT *
    FROM <http://localhost:8890/CDISCPILOT01>
    WHERE{
    cdiscpilot01:Person_1 ', 
    predicate,
    ' ?s .
    ?s ?p ?o
    }
    ',
    "\n"
)

# MODEL AFTER:
#-----------------
#    observations2Rq<-  paste( forsparqlprefix,
#                              '
#                              select *
#                              where { ?s a qb:Observation ; ?p ?o .}
#                              limit 10
#                              ',
#                              "\n"                               
#    )
#-----------------


TWTriples = as.data.frame(sparql.rdf(TWSource, query))
AOTriples = as.data.frame(sparql.rdf(AOSource, query))

inTWNotAO<-anti_join(TWTriples, AOTriples)
inAONotTW<-anti_join(AOTriples, TWTriples)
inAONotTW<-inAONotTW[!(inAONotTW$o==""),]  # remove cases where O is missing (atrifact from TopBraid)
# In the TW TTL file but not in the AO file                 
inTWNotAO
# In the AO TTL file but not in the TO file
inAONotTW
}
checkPredicate("study:hasAgeMeasurement")



