rm(list = ls())
#install.packages("FITSio")
#library("FITSio")
                                                         
require("FITSio")
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2) {
  cat("usage: Rscript hw4.R <template spectrum> <data directory>\n")
  quit(status = 1)
}
process = as.numeric(args[1])
dir = args[2]
cB58 = readFrameFromFITS("cB58_Lyman_break.fit")
n = dim(cB58)[1]
files = list.files(dir)
numfiles = length(files)
distances = vector(mode = "numeric", length = numfiles)
best_shift = vector(mode = "numeric", length = numfiles)
new_cB58 = (cB58$FLUX - mean(cB58$FLUX)) / sd(cB58$FLUX)


#before I used correlations, it fits in hw2. But this time all the top 10 spectrum are not fit.
#for each .fits file find the best distance and best shift
for (i in 1:numfiles) {
  path=paste0(dir, "/", files[i])
  data=readFrameFromFITS(path)
  spec=data$flux
  mind = Inf
  best_i = 1
  if (length(spec) < length(new_cB58)) {
    next
  } else {
    for (p in 1:(length(spec)-n+1)) {
      new_spec = (spec[p:(p+n-1)]-mean(spec[p:(p+n-1)])) /sd(spec[p:(p+n-1)])
      d = sqrt(sum((new_cB58 - new_spec) ^ 2))
      if (is.na(d)) {
        next
      } else {
        if (d < mind) {
          mind = d
          best_i = p
        }
      }
      distances[i] = mind
      best_shift[i] = best_i
    }
  }
}



for (i in 1:(length(distances))) {
  if (distances[i] == 0) {
    distances[i] == Inf
  }
}


#write .csv

distance = sort(distances, decreasing = FALSE)
spectrumID = noquote(files[order(distances)])
i = best_shift[order(distances)]
orders = data.frame(distance, spectrumID, i)
orders100= orders[orders$distance > 0,]
names(orders100) = NULL
write.csv(orders100, file = paste0(dir, ".csv"), row.names = FALSE)
