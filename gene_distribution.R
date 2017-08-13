setwd("C:\\Users\\Administrator\\Desktop\\sp\\picture")
a <- read.csv(file="chr_length.csv", header=T,as.is = T)
a$length<-a$length/1000000
b <- read.csv(file="MHsameIndel.csv", header=T,as.is = T)

pdf(file="Same Indels locations deltail in MH63 3.pdf",height=8,width=14)
par(mfrow=c(1,1),mar = c(4.1,4.1,2.1,2.1))
barplot(a$length,ylim = c(0,48),width=2,horiz=T,axes=F,space = 1,cex.axis=1,cex.lab =1.5,cex.main =1.5,xlab = 'Location(Mb)',ylab = '',main='same Indels locations in MH63')
axis(2,at=seq(2.8,46.8,4),labels=c(1:12),tick = F)
axis(1,at=seq(0,40,5),labels=seq(0,40,5))
mtext("Chromosome", side = 2, line = 2.5,cex=1.5)
left <- b[,10]
right <- b[,10]
bottom <- 4*b[,1]-2
top <- 4*b[,1]
for (i in 1:80503) {
 rect(xleft=left[i], ybottom=bottom[i], xright=right[i], ytop=top[i],border=4,col=4,lwd=0)
}
left1 <- c(16.113268,13.149113,19.843069,8.535237,11.849549,14.517820,11.583370,11.257642,2.134375,8.811120,12.256999,9.707620)
right1 <- c(16.474603,13.175261,20.100373,8.616246,11.853331,14.641670,11.585417,12.195055,2.911387,8.856329,12.259359,10.131713)
bottom1 <- 4*c(1:12)-2
top1 <- 4*c(1:12)
for (i in 1:12) {
  rect(xleft=left1[i], ybottom=bottom1[i], xright=right1[i], ytop=top1[i],border=3,col=3)
}
dev.off()


