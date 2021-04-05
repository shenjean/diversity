# Read table
setwd("/Users/jeanlim/Desktop/")
merge=read.delim("merge.tsv",sep="\t",header=T,na.strings="")

# Convert table from wide to long based on p-values
psubset=reshape(data=merge,idvar="UniqueID",varying=c("Ia.1_CP_SprMvsH_padj","Ia.1_DE_SprMvH_padj","Ia.1_DE_SumDMvH_padj","Ia.1_DE_SumMvH_padj","Ia.3_CP_SprvSumH_padj","Ia.3_DE_SumDMvH_padj","Ia.3_DE_SumMvH_padj","Ia.5_CP_SprMvH_padj","Ia.5_CP_SumMvH_padj","Ia.5_DE_SumDMvH_padj","Ia.5_DE_SumMvH_padj","Ia.6_CP_SprMvH_padj","Ia.6_CP_SumMvH_padj","Ia.6_DE_SumDMvH_padj","Ia.6_DE_SumMvH_padj","II_CP_SumMvH_padj","II_DE_SumDMvH_padj","II_DE_SumMvH_padj","IIIa.4_CP_SprMvH_padj","IIIa.4_CP_SumMvH_padj","IIIa.4_DE_SumDMvH_padj","IIIa.4_DE_SumMvH_padj","Va_CP_SumMvH_padj","Va_DE_SumDMvH_padj","Va_DE_SumMvH_padj"),v.name=c("padj"),times=c("Ia.1_CP_SprMvsH","Ia.1_DE_SprMvH","Ia.1_DE_SumDMvH","Ia.1_DE_SumMvH","Ia.3_CP_SprvSumH","Ia.3_DE_SumDMvH","Ia.3_DE_SumMvH","Ia.5_CP_SprMvH","Ia.5_CP_SumMvH","Ia.5_DE_SumDMvH","Ia.5_DE_SumMvH","Ia.6_CP_SprMvH","Ia.6_CP_SumMvH","Ia.6_DE_SumDMvH","Ia.6_DE_SumMvH","II_CP_SumMvH","II_DE_SumDMvH","II_DE_SumMvH","IIIa.4_CP_SprMvH","IIIa.4_CP_SumMvH","IIIa.4_DE_SumDMvH","IIIa.4_DE_SumMvH","Va_CP_SumMvH","Va_DE_SumDMvH","Va_DE_SumMvH"),direction="long",new.row.names=1:50000)
psubset$padj=as.numeric(psubset$padj)
# Rename time variable to "condition" because time will be used again in the next step
smallp$condition=smallp$time
smallp$time=NULL
# Filter out rows with p.adj<0.05
smallp=subset(psubset,padj<0.05)

# Convert subset table from wide to long based on log2FC values
logsubset=reshape(data=smallp,idvar="UniqueID",varying=c("Ia.1_CP_SprMvsH_log2FoldChange","Ia.1_DE_SprMvH_log2FoldChange","Ia.1_DE_SumDMvH_log2FoldChange","Ia.1_DE_SumMvH_log2FoldChange","Ia.3_CP_SprvSumH_log2FoldChange","Ia.3_DE_SumDMvH_log2FoldChange","Ia.3_DE_SumMvH_log2FoldChange","Ia.5_CP_SprMvH_log2FoldChange","Ia.5_CP_SumMvH_log2FoldChange","Ia.5_DE_SumDMvH_log2FoldChange","Ia.5_DE_SumMvH_log2FoldChange","Ia.6_CP_SprMvH_log2FoldChange","Ia.6_CP_SumMvH_log2FoldChange","Ia.6_DE_SumDMvH_log2FoldChange","Ia.6_DE_SumMvH_log2FoldChange","II_CP_SumMvH_log2FoldChange","II_DE_SumDMvH_log2FoldChange","II_DE_SumMvH_log2FoldChange","IIIa.4_CP_SprMvH_log2FoldChange","IIIa.4_CP_SumMvH_log2FoldChange","IIIa.4_DE_SumDMvH_log2FoldChange","IIIa.4_DE_SumMvH_log2FoldChange","Va_CP_SumMvH_log2FoldChange","Va_DE_SumDMvH_log2FoldChange","Va_DE_SumMvH_log2FoldChange"),v.name=c("log2FC"),times=c("Ia.1_CP_SprMvsH","Ia.1_DE_SprMvH","Ia.1_DE_SumDMvH","Ia.1_DE_SumMvH","Ia.3_CP_SprvSumH","Ia.3_DE_SumDMvH","Ia.3_DE_SumMvH","Ia.5_CP_SprMvH","Ia.5_CP_SumMvH","Ia.5_DE_SumDMvH","Ia.5_DE_SumMvH","Ia.6_CP_SprMvH","Ia.6_CP_SumMvH","Ia.6_DE_SumDMvH","Ia.6_DE_SumMvH","II_CP_SumMvH","II_DE_SumDMvH","II_DE_SumMvH","IIIa.4_CP_SprMvH","IIIa.4_CP_SumMvH","IIIa.4_DE_SumDMvH","IIIa.4_DE_SumMvH","Va_CP_SumMvH","Va_DE_SumDMvH","Va_DE_SumMvH"),direction="long",new.row.names=1:50000)

# Match padj and log2FC values from same conditions
logmatch=subset(logsubset,condition==time)
logmatch$log2FC=as.numeric(logmatch$log2FC)

# Filter out rows with log2FC>1 or log2FC <-1
filter=subset(logmatch,(log2FC < -1 | log2FC >1))

# Convert data back from long to wide
# This will generate a wide table, however columns will be re-arranged
pwide=reshape(data=filter,idvar="UniqueID",v.names="padj",timevar="condition",direction="wide")
lwide=reshape(data=pwide,idvar="UniqueID",v.names="log2FC",timevar="time",direction="wide")

# Use merge function to extract rows in filtered table from original table
# This preserves original column names and order
ID=as.data.frame(lwide$UniqueID)
colnames(ID)=c("UniqueID")
filtered=merge(ID,merge,by="UniqueID",all.x=TRUE)
write.table(filtered,"filtered.tsv",sep="\t")
