library(ggplot2)

#DB Connection 
source(file='./PKG_Demand/sqlStr.R')
source(file='./PKG_Demand/Function_Pxy.R')

#load Fcst Data
sql<-GetFCStSql()
dfFcst<-GetFromERPDB(sql)
rm(sql)

#新增月欄位
dfFcst<-mutate(dfFcst,month=format(PKG_FCST_DATE,"%m"))
str(dfFcst)
save(dfFcst,file="./PKG_Demand/dfFcst.RData")

'data.frame:	3932 obs. of  14 variables:
$ HEADER_ID       : int  899375 899375 899375 899375 899376 899376 899376 899376 899376 899377 ...
$ PARENT_HEADER_ID 規格ID: int  696763 696763 696763 696763 696766 696766 696766 696766 696766 696767 ...
$ FCST_TYPE       : Factor w/ 1 level "FCST": 1 1 1 1 1 1 1 1 1 1 ...
$ BU              : Factor w/ 7 levels "AUO","CHINA",..: 1 1 1 1 1 1 1 1 1 1 ...
$ AREA            : Factor w/ 2 levels "CB","TB": 2 2 2 2 2 2 2 2 2 2 ...
$ PROCESS_TYPE    製程別: Factor w/ 3 levels "LA","LIGHT BAR",..: 2 2 2 2 2 2 2 2 2 2 ...
$ APPLICATION_TYPE: Factor w/ 12 levels "AUTO","COB","CP",..: 4 4 4 4 4 4 4 4 4 4 ...
$ FCST_MODEL      需求 MODEL : Factor w/ 493 levels "LB03004.0","LB05001.0",..: 44 44 44 44 111 111 111 111 111 112 ...
$ FCST_PART_LIST  需求料號 : Factor w/ 563 levels "96.12101.000",..: 3 3 3 3 5 5 5 5 5 6 ...
$ PKG_MODEL_GROUP 對應轉換PKG : Factor w/ 33 levels "060304","150506",..: 23 23 23 23 23 23 23 23 23 23 ...
$ PKG_MODEL       對應轉換PKG : Factor w/ 144 levels "PB07H04.0","PB17H01.0",..: 96 96 96 96 96 96 96 96 96 96 ...
$ PKG_FCST_DATE   轉換為 PKG 需求日: POSIXct, format: "2018-02-26" "2018-03-05" "2018-04-16" "2018-05-07" ...
$ PKG_QTY         轉換為 PKG 數量: int  73080 34860 150000 120000 39520 52000 260000 26000 182000 39520 ...
$ month           轉換為 PKG 需求月 : chr  "02" "03" "04" "05" ...'



#取3 月份之後的PKG 各Model 需求summary by Month
#dfFcst.1<-filter(dfFcst,PKG_FCST_DATE>='2018/03/01')%>%
#group_by(PKG_MODEL,month)%>%
#summarise(PKG_QTY=sum(PKG_QTY))%>%
#as.data.frame()
#rm(dfFcst.1)


##取PKG 4014 分析
pModel<-'PT40Z14.3'

f.4014<-filter(dfFcst,PKG_FCST_DATE>='2018/03/01' & PKG_MODEL==pModel)%>%
group_by(FCST_MODEL,FCST_PART_LIST,PKG_MODEL,month)%>% 
summarise(PKG_QTY=sum(PKG_QTY))%>%
data.frame()
rm(dfFcst)
str(f.4014)
'data.frame:	73 obs. of  5 variables:
$ FCST_MODEL    : Factor w/ 493 levels "LB03004.0","LB05001.0",..: 73 73 73 73 73 78 78 78 78 78 ...
$ FCST_PART_LIST: Factor w/ 563 levels "96.12101.000",..: 79 79 79 79 79 84 84 84 84 84 ...
$ PKG_MODEL     : Factor w/ 144 levels "PB07H04.0","PB17H01.0",..: 105 105 105 105 105 105 105 105 105 105 ...
$ month         : chr  "03" "04" "05" "06" ...
$ PKG_QTY       : int  704592 1696800 982800 296800 1274000 1887248 1544400 1179200 990000 1306800 ...'



#
#g<-ggplot(data=f.4014,aes(x=FCST_MODEL,y=PKG_QTY))+
#  geom_bar(stat = "identity",aes(fill=FCST_MODEL))
#g

#Safile<-paste0('./PKG_Demand/',pModel,Sys.Date(),'.jpeg')
#ggsave(Safile)
#rm(g)

#規格轉換 
sql<-GetPlanSPEC(pModel)
dfLBPMH<-GetFromPlan(sql)

save(dfLBPMH,file="./PKG_Demand/dfLBPMH.RData")

#規格 Header 用96!+95! Query 每個96! 的規格
str(dfLBPMH) 
'data.frame:	68 obs. of  3 variables:
$ CUSTOMER_MODEL_NAME  PKG 需求對應規格: Factor w/ 17 levels "","\"M195RTN01.1/",..: 1 3 3 3 4 4 4 5 5 5 ...
$ PART_NO          LB 料號   : Factor w/ 37 levels "96.B1851.300021N",..: 1 1 2 2 3 4 4 5 6 6 ...
$ CHILD_PART_NO    對應PKG 料號  : Factor w/ 2 levels "95.T4014.Z0B120N",..: 1 2 1 2 1 1 2 1 2 1 ...'

#整理96!規格做視覺化與統計
PMSPEC<-NULL

for(i in 1:length(dfLBPMH$PART_NO) )
{
  lb<-dfLBPMH$PART_NO[[i]]
  pkg<-dfLBPMH$CHILD_PART_NO[[i]]
  sql<-GetLBPMBin(lb,pkg)
  bin<-GetFromPlan(sql)
  bin<-cbind(bin,FCST_PART_LIST=rep(lb,length(bin$WL_Fm)),PKG=rep(pkg,length(bin$WL_Fm)))
  PMSPEC<-rbind(PMSPEC,bin)
  bin<-NULL
}

#清理資料
PMSPEC$CIE_X5<-NULL
PMSPEC$CIE_X6<-NULL
PMSPEC$CIE_X7<-NULL
PMSPEC$CIE_X8<-NULL
PMSPEC$CIE_Y5<-NULL
PMSPEC$CIE_Y6<-NULL
PMSPEC$CIE_Y7<-NULL
PMSPEC$CIE_Y8<-NULL
PMSPEC$sn<-NULL
PMSPEC$cie_base_id<-NULL
rm(i,lb,pkg,bin,dfLBPMH)

str(PMSPEC)
'data.frame:	12916 obs. of  26 variables:
$ bincode_naming_rule_number: int  7 7 7 7 7 7 7 7 7 7 ...
$ WL_Spec_code              : int  2 2 3 3 1 1 2 2 3 3 ...
$ WL_Fm        波段範圍     : num  448 448 450 450 445 ...
$ WL_To                     : num  450 450 452 452 448 ...
$ LEFT_TOP_X   四點座標     : num  0.298 0.298 0.298 0.298 0.298 ...
$ LEFT_TOP_Y                : num  0.271 0.271 0.271 0.271 0.271 ...
$ LEFT_BOTTOM_X             : num  0.303 0.303 0.303 0.303 0.303 ...
$ LEFT_BOTTOM_Y             : num  0.271 0.271 0.271 0.271 0.271 ...
$ RIGHT_BOTTOM_X            : num  0.306 0.306 0.306 0.306 0.306 ...
$ RIGHT_BOTTOM_Y            : num  0.277 0.277 0.277 0.277 0.277 ...
$ RIGHT_TOP_X               : num  0.301 0.301 0.301 0.301 0.301 ...
$ RIGHT_TOP_Y               : num  0.277 0.277 0.277 0.277 0.277 ...
$ POS_ID      CIE bin ID    : Factor w/ 26 levels "H500","J500",..: 1 1 1 1 1 1 1 1 1 1 ...
$ PAINT_TYPE                : int  4 4 4 4 4 4 4 4 4 4 ...
$ IV_Spec_code  IV bin ID   : Factor w/ 6 levels "IE","IF","IG",..: 1 1 1 1 1 1 1 1 1 1 ...
$ IV_LM_Fm      IV 範圍     : num  7125 7125 7125 7125 7125 ...
$ IV_LM_To                  : num  7456 7456 7456 7456 7456 ...
$ IV_MCD_Fm                 : num  21.5 21.5 21.5 21.5 21.5 21.5 21.5 21.5 21.5 21.5 ...
$ IV_MCD_To                 : num  22.5 22.5 22.5 22.5 22.5 22.5 22.5 22.5 22.5 22.5 ...
$ IV_TYPE                   : Factor w/ 1 level "MCD": 1 1 1 1 1 1 1 1 1 1 ...
$ VF_Spec_code   VF bin ID  : Factor w/ 2 levels "L","M": 1 2 1 2 1 2 1 2 1 2 ...
$ VF_Fm                     : num  2.8 3 2.8 3 2.8 ...
$ VF_To                     : num  3 3.2 3 3.2 3 ...
$ bin_code                  : Factor w/ 1018 levels "1H500IEL","1H500IEM",..: 73 74 145 146 1 2 73 74 145 146 ...
$ FCST_PART_LIST  96! 料號  : Factor w/ 37 levels "96.B1851.300021N",..: 1 1 1 1 1 1 1 1 1 1 ...
$ PKG             96! 料號  : Factor w/ 2 levels "95.T4014.Z0B120N",..: 1 1 1 1 1 1 1 1 1 1 ...'


save(PMSPEC,file="./PKG_Demand/PMSPEC.RData")

#Save LB 規格
#CIE 規格整理, CIE 格數& LB 數 , 中心做標
#取 CIE 過濾重複(95替代)
LBCIE<-distinct(PMSPEC,FCST_PART_LIST,POS_ID,LEFT_TOP_X,LEFT_TOP_Y,LEFT_BOTTOM_X,LEFT_BOTTOM_Y,RIGHT_BOTTOM_X,RIGHT_BOTTOM_Y,RIGHT_TOP_X,RIGHT_TOP_Y)
str(LBCIE)
'data.frame:	223 obs. of  10 variables:
$ LEFT_TOP_X    : num  0.298 0.301 0.304 0.307 0.311 ...
$ LEFT_TOP_Y    : num  0.271 0.277 0.283 0.289 0.295 ...
$ LEFT_BOTTOM_X : num  0.303 0.306 0.31 0.313 0.316 ...
$ LEFT_BOTTOM_Y : num  0.271 0.277 0.283 0.289 0.295 ...
$ RIGHT_BOTTOM_X: num  0.306 0.31 0.313 0.316 0.32 ...
$ RIGHT_BOTTOM_Y: num  0.277 0.283 0.289 0.295 0.301 ...
$ RIGHT_TOP_X   : num  0.301 0.304 0.307 0.311 0.314 ...
$ RIGHT_TOP_Y   : num  0.277 0.283 0.289 0.295 0.301 ...
$ POS_ID        : Factor w/ 26 levels "H500","J500",..: 1 2 3 4 5 6 1 2 3 4 ...
$ FCST_PART_LIST: Factor w/ 37 levels "96.B1851.300021N",..: 1 1 1 1 1 1 2 2 2 2 ...'


#lB CIE 對應3 月需求, 取出主分布在哪一排或中心BIN
f.4014$month<-as.numeric(f.4014$month)
f.4014<-merge(select(LBCIE,FCST_PART_LIST,POS_ID),filter(f.4014,month==3))
f.4014<-mutate(f.4014,L=substr(POS_ID, 2, 2))
f.4014<-distinct(f.4014,FCST_PART_LIST,PKG_QTY,L)
str(f.4014)

'data.frame:	18 obs. of  3 variables:
$ FCST_PART_LIST: Factor w/ 37 levels "96.B1851.300021N",..: 2 4 6 7 7 9 11 12 14 15 ...
$ PKG_QTY       : int  704592 1887248 649000 706680 706680 3732156 3917760 2090400 359856 8120 ...
$ L   取CIE     : chr  "5" "4" "4" "5" ...'


#整理CIE 基底座標
pxy<-NULL
for( i in 1:length(LBCIE$LEFT_TOP_X))
{
  p<-Trnpos(LBCIE[i,])
  pxy<-rbind(pxy,p)
}
rm(p)

#CIE 中心座標
cie.cen<-distinct(pxy,POS_ID,cx,cy)%>%
group_by(POS_ID)%>%
summarise(cx=mean(cx),cy=mean(cy))
str(cie.cen)
'Classes ‘tbl_df’, ‘tbl’ and data.frame:	26 obs. of  3 variables:
$ POS_ID: chr  "C400" "C500" "D400" "D500" ...
$ cx    : num  0.28 0.286 0.284 0.289 0.287 ...
$ cy    : num  0.244 0.244 0.25 0.25 0.256 ...'


# CIE LB 數量
cie.cen.1<-distinct(pxy,FCST_PART_LIST,POS_ID)%>%
group_by(POS_ID)%>%
summarise(LBcon=n())


# CIE 中心位移方便顯示位址
cie.Txt<-merge(cie.cen,cie.cen.1)
rm(cie.cen.1)
cie.Txt$cy<-cie.Txt$cy-0.002

#CIE LB Count
g<-ggplot(data = pxy)
g+geom_path(aes(x=cx,y=cy,group=POS_ID))+
geom_text(data=cie.cen,aes(x=cx,y=cy,label=POS_ID))+
geom_text(data=cie.Txt,aes(x=cx,y=cy,label=LBcon))

Safile<-paste0('./PKG_Demand/',pModel,'LB_CIE',Sys.Date(),'.jpeg')
ggsave(Safile)

#LB CIE
g<-ggplot(data = pxy)
g+geom_path(aes(x=cx,y=cy,group=POS_ID))+
geom_text(data=cie.cen,aes(x=cx,y=cy,label=POS_ID),size=2)+
facet_wrap(~FCST_PART_LIST) 
Safile<-paste0('./PKG_Demand/',pModel,'LB_CIE_2',Sys.Date(),'.png')
ggsave(Safile)


#取歷史工單打點
sql<-GetWOCen(pModel)
WOCen<-GetFromT01(sql)
str(WOCen)

save(WOCen,file="./PKG_Demand/WOCen.RData")

'data.frame:	46 obs. of  7 variables:
$ MODEL_NAME    : Factor w/ 1 level "PT40Z14.3": 1 1 1 1 1 1 1 1 1 1 ...
$ MO_CREATE_DATE 工單日期: POSIXct, format: "2018-03-18 19:18:26" "2018-03-14 19:29:23" "2018-03-13 08:43:25" "2018-03-04 14:09:15" ...
$ PRODUCT_NO    PKG 料號: Factor w/ 1 level "95.T4014.Z0B120N": 1 1 1 1 1 1 1 1 1 1 ...
$ MONO          工單號碼: Factor w/ 46 levels "S00TM79733-113C4C502",..: 46 45 44 43 42 41 40 39 38 37 ...
$ SORTER_INPUT  工單數量 : int  1910094 3857775 1792570 5277428 3110175 3947198 7090491 3709733 3204432 3420460 ...
$ CIE_X_AVG     : num  0.292 0.307 0.296 0.313 0.308 ...
$ CIE_Y_AVG     : num  0.266 0.285 0.274 0.284 0.285 ...'

#CIE -工單歷史打點
g<-ggplot(data = pxy)
g+geom_path(aes(x=cx,y=cy,group=POS_ID))+
  geom_text(data=cie.cen,aes(x=cx,y=cy,label=POS_ID))+
  geom_point(data=WOCen,aes(x=CIE_X_AVG,y=CIE_Y_AVG))

Safile<-paste0('./PKG_Demand/',pModel,'WO_CIE',Sys.Date(),'.png')
ggsave(Safile)



#取工單 & 計算分布百分比
'S00TM83709-112C4C501'
mono<-WOCen$MONO[[1]]
sql<-GetWODis(mono)
WODis<-GetFromT01(sql)

save(WODis,file="./PKG_Demand/WODis.RData")

WODis<-group_by(WODis,MONO,CIE)%>%
summarise(QTY=sum(QTY))%>%
as.data.frame()

totQyu=sum(WODis$QTY)
WODis<-mutate(WODis,Per=round((WODis$QTY/totQyu)*100,2))
rm(totQyu)
str(WODis)

'data.frame:	22 obs. of  4 variables:
$ MONO : Factor w/ 1 level "S00TM83709-112C4C501": 1 1 1 1 1 1 1 1 1 1 ...
$ CIE : Factor w/ 22 levels "C400","D400",..: 1 2 3 4 5 6 7 8 9 10 ...
$ QTY : int  1167 18641 14 134965 81 836715 19 633308 15 215836 ...
$ Per 分布百分比: num  0.06 0.98 0 7.09 0 ...'

mono<-"S00TM83706-113C4C501"
sql<-GetWODis(mono)
WODis2<-GetFromT01(sql)

save(WODis2,file="./PKG_Demand/WODis2.RData")

WODis2<-group_by(WODis2,MONO,CIE)%>%
summarise(QTY=sum(QTY))

totQyu=sum(WODis2$QTY)
WODis2<-mutate(WODis2,Per=round((WODis2$QTY/totQyu)*100,2))%>%
as.data.frame()
rm(totQyu)

mono<-"S00TM83703-112C4C501"
sql<-GetWODis(mono)
WODis3<-GetFromT01(sql)

save(WODis3,file="./PKG_Demand/WODis3.RData")

WODis3<-group_by(WODis3,MONO,CIE)%>%
summarise(QTY=sum(QTY))

totQyu=sum(WODis3$QTY)
WODis3<-mutate(WODis3,Per=round((WODis3$QTY/totQyu)*100,2))%>%
as.data.frame()
rm(totQyu)

#資料
save(f.4014,LBCIE,PMSPEC,pxy,cie.cen,WOCen,WODis,WODis2,WODis3,file="./PKG_Demand/DEMAND.RData")

#移到 MainFunction 2

"Filter double L
f.4014<-f.4014[-15,]

LDIS<-f.4014%>%
group_by(L)%>%
summarise(QTY=sum(PKG_QTY))


cie.Txt<-merge(x=cie.Txt,y=WODis,by.x='POS_ID',by.y='CIE')
#波段 5 
g<-ggplot(data = pxy)
g+geom_path(aes(x=cx,y=cy,group=POS_ID))+
  geom_text(data=cie.cen,aes(x=cx,y=cy,label=POS_ID))+
  geom_text(data=cie.Txt,aes(x=cx,y=cy,label=Per))

LBCIE<-select(LBCIE,FCST_PART_LIST,POS_ID)%>%
mutate(L=substr(POS_ID, 2, 2))

LBCIE<-merge(LBCIE,f.4014,by.x='FCST_PART_LIST',by.y = 'FCST_PART_LIST')

L5<-mutate(L5,QTY2=PKG_QTY*Per)

#波段 5 
g<-ggplot(data = pxy)
g+geom_path(aes(x=cx,y=cy,group=POS_ID))+
  geom_text(data=cie.cen,aes(x=cx,y=cy,label=POS_ID))+
  geom_text(data=L5,aes(x=cx,y=cy,label=QTY2))' "

