# R code for the steps and Stata code described in the document "matchdoc.pdf" (source: http://www.nber.org/~jbessen/matchdoc.pdf)

# In addition to the nber data, the "matchdoc.pdf"  assumes that user has one has two other files:
# - a file which contains financial data for each GVKEY-YEAR, sorted by GVKEY and YEAR (i.e. called "work" in matchdoc)
# - a file which contains the number of patents, NPAT (or any other patent metric), for each PDPASS-YEAR sorted by PDPASS and YEAR.

# Set "nber-patents" as the working directory
setwd("/Users/bernardolima/Documents/nber-patents")
# Check
getwd()

# 1) Create a file which contains the number of patents (i.e. NPAT), for each PDPASS-YEAR sorted by PDPASS and YEAR.
# pat76_06_assg.dta containt all utility patents w. citation data and assignee numbers (if assigned), one record per patent per assignee
pat_assg <- read.dta("nber-original-data/utility-patents/pat76_06_assg.dta")

# Stata code in the commented out
# drop if pdpass == .
pat_assg <- pat_assg[!is.na(pat_assg$pdpass), ]

# collapse (count) patent (sum) allcites, by(pdpass appyear)
pat_assg2 <- pat_assg %>% group_by(pdpass, appyear) %>% summarize(npat = n(), ncites_fw = sum(allcites))

# sort by (pdpass, appyear)
pat_assg2 <- pat_assg2 %>% arrange(pdpass, appyear)

# rename 
pat_assg2 <- pat_assg2 %>% rename(c(year = appyear))

# Warning from matchdoc
# "If one wants to calculate patent stocks, as opposed to simple patent counts, using a perpetual inventory method, 
# one has to first calculate patent stocks for each pdpass for each year and then merge these data into the WORK file using similar code. 
# Note that it will not work correctly to build patent stocks from the npat data because assignees acquire patents during years not necessarily captured in the WORK file."

# Create patent stock varaibles 
pat_assg3 <- pat_assg2 %>% group_by(pdpass) %>% mutate(stock4_l3_to_t0 = lag(npat, 3, default = 0) + lag(npat, 2, default = 0) + lag(npat, 1, default = 0) + npat)
pat_assg3 <- pat_assg2 %>% group_by(pdpass, year) %>% mutate(stock4_l4_to_l1 = lag(npat, 4, default = 0) + lag(npat, 3, default = 0) + lag(npat, 2, default = 0) + lag(npat, 1, default = 0))

# 2) This code below adds counts of patents and citations to "work: (i.e. Compustat dataset):
# merge dynamic assignee data into pdpass-npat file
dynass <- read.dta("nber-original-data/company-patent-matching/dynass.dta")
pat_dyn <- pat_assg3 %>% inner_join(dynass, by = c("pdpass" = "pdpass"))

# now find the appropriate gvkey to assign the patents
pat_dyn$gvkey <- NA
pat_dyn <- pat_dyn %>% 
  mutate(gvkey = case_when(
    !is.na(gvkey1) & year >= begyr1 & year <= endyr1 ~ gvkey1,
    !is.na(gvkey2) & year >= begyr2 & year <= endyr2 ~ gvkey2,
    !is.na(gvkey3) & year >= begyr3 & year <= endyr3 ~ gvkey3,
    !is.na(gvkey4) & year >= begyr4 & year <= endyr4 ~ gvkey4,
    !is.na(gvkey5) & year >= begyr5 & year <= endyr5 ~ gvkey5
    )
  )
 
# keep if gvkey~=.
pat_dyn <- pat_dyn[!is.na(pat_dyn$gvkey), ]

# drop dynass variables 
pat_dyn <- pat_dyn %>% select(gvkey, year : ncites_fw)

# sum over multiple assignees to get patents for each company (i.e. gvkey)
pat_dyn <- pat_dyn %>% arrange(gvkey, year)

# collapse (sum) npat ncites ,by(gvkey fyear)
gvkey_pat_cites <- pat_dyn %>% group_by(gvkey, year) %>% summarize(npat = sum(npat), ncites_fw = sum(ncites_fw))

# load compustat data 
work <- read.dta("nber-patents/test/work.dta")

# merge nber patent data with compustat data 
nber_pat_compustat <- work %>% 
  left_join(gvkey_pat_cites, by = c("gvkey" = "gvkey", "fyear"="year"))

# We are not quite done yet, however, because we know that some of the firms in WORK have zero patents (as opposed to NPAT = missing). This does that
# merge in match variable
pdpcohdr <- read.dta("nber-original-data/company-patent-matching/pdpcohdr.dta")

nber_pat_compustat <- nber_pat_compustat %>% 
  left_join(pdpcohdr, by = c("gvkey" = "gvkey"))

# drop pdpcohdr variables that are not necessary
nber_pat_compustat <- nber_pat_compustat %>% select(!(name:endyr))

# create match flag variable
# gen mtchflg= match~=.
nber_pat_compustat$mtchflg <- if_else(!is.na(nber_pat_compustat$match), 1, 0)

# replace ncites and npat with zero when mtchflg == 1 and patent based variables == NA
nber_pat_compustat$npat[is.na(nber_pat_compustat$npat) & nber_pat_compustat$mtchflg == 1] <- 0
nber_pat_compustat$ncites_fw[is.na(nber_pat_compustat$ncites_fw) & nber_pat_compustat$mtchflg == 1] <- 0

# DOUBLE CHECK. When mtchflg == 0 paptent data should be NA not 0
nber_pat_compustat$npat2 <- nber_pat_compustat$npat
nber_pat_compustat$npat2[nber_pat_compustat$mtchflg == 0] <- NA



