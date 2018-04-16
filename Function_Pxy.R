# Load INV
library(RODBC)
library(dplyr)

T01cn <- odbcConnect("T01HIS1",uid="fabods_ap",pwd="ods$rpt")
T05cn <- odbcConnect("T05HIS01",uid="fabods_ap",pwd="ods$rpt")
T05DEV02<-odbcConnect("T05DEV02",uid="fabods",pwd="fabods")
ERPcn <- odbcConnect("LEX_PROD",uid="lextarerp",pwd="l#erp123")
PlanCn<-odbcConnect("lexmsdb2",uid="Viewer",pwd="ShiningQI" )

Trnpos<-function(x)
{
  cx<-c(x$LEFT_BOTTOM_X,x$RIGHT_BOTTOM_X,x$RIGHT_TOP_X,x$LEFT_TOP_X)
  cy<-c(x$LEFT_BOTTOM_Y,x$RIGHT_BOTTOM_Y,x$RIGHT_TOP_Y,x$LEFT_TOP_Y)
  FCST_PART_LIST<-as.character(x$FCST_PART_LIST)
  POS_ID<-as.character(x$POS_ID)
  pos<-data.frame(FCST_PART_LIST=FCST_PART_LIST,cx=cx,cy=cy,POS_ID=POS_ID,stringsAsFactors = F)
  return (pos)
}


GetFromERPDB<-function(strsql)
{
  dt<-sqlQuery(ERPcn,strsql)
  return(dt)
}


GetFromT05<-function(strsql)
{
  dt<-sqlQuery(T05cn,strsql)
  return(dt)
}

GetFromT01<-function(strsql)
{
  dt<-sqlQuery(T01cn,strsql)
  return(dt)
}

GetFromPlan<-function(strsql)
{
  dt<-sqlQuery(PlanCn,strsql)%>%
  as.data.frame()
  return(dt)
}


