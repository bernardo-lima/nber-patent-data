# Create a folder called "nber-patents" and set it as the working directory
setwd("/Users/bernardolima/Documents/nber-patents")
# Check working directory
getwd()

# Create folders for downloaded data
dir.create("nber-original-data")
dir.create("nber-original-data/assigned-patents")
dir.create("nber-original-data/company-patent-matching")
dir.create("nber-original-data/utility-patents")
dir.create("data")

# Data source: https://sites.google.com/site/patentdataproject/Home/downloads
# Download the data into respective folders

# Company: patent matching
download.file("http://www.nber.org/~jbessen/matchdoc.pdf",
              "nber-original-data/company-patent-matching/matchdoc.pdf")
download.file("http://www.nber.org/~jbessen/pdpcohdr.dta.zip",
              "nber-original-data/company-patent-matching/pdpcohdr.dta.zip")
download.file("http://www.nber.org/~jbessen/dynass.dta.zip",
              "nber-original-data/company-patent-matching/dynass.dta.zip")
download.file("http://www.nber.org/~jbessen/assignee.dta.zip",
              "nber-original-data/company-patent-matching/assignee.dta.zip")

# Assigned patents
download.file("http://www.nber.org/~jbessen/patassg.dta.zip",
              "nber-original-data/assigned-patents/patassg.dta.zip")
download.file("http://www.nber.org/~jbessen/patassg.txt",
              "nber-original-data/assigned-patents/patassg.txt")

# Utility patents 
download.file("http://www.nber.org/~jbessen/pat76_06_assg.dta.zip",
              "nber-original-data/utility-patents/pat76_06_assg.dta.zip")
download.file("http://www.nber.org/~jbessen/pat76_06_ipc.dta.zip",
              "nber-original-data/utility-patents/pat76_06_ipc.dta.zip")
download.file("http://www.nber.org/~jbessen/cite76_06.dta.zip",
              "nber-original-data/utility-patents/cite76_06.dta.zip")
download.file("http://nber.org/~jbessen/orig_gen_76_06.zip",
              "nber-original-data/utility-patents/orig_gen_76_06.zip")

