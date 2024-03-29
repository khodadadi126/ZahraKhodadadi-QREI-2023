clc
clear all
warning off all
fclose all;

load Spa_Temp_Baseline

N=pixs(1)*pixs(2);
pixs=[250;250];
mus2=mus.^2;
fault_pat=zeros(pixs(1),pixs(2));
XX0=zeros([size(mus),m]);
lratconst=1/2/vars;
mfiller=zeros([size(mus),1]);
mflag=0;
Nom=imread('Tile_Nom.bmp');
Nom=imresize(Nom,[512,512]);
pfilter='pkva';
dfilter='pkva';
nlevels=[1 2];
y = pdfbdec(double(Nom),pfilter, dfilter, nlevels);
ContourletCoeff=showpdfb(y);
Nom=ContourletCoeff.New;
Nom=imresize(Nom,[250,250]);
Delta= [-10 -5 -3 -2 -1 1 2 3 5 10      -10 -5 -3 -2 -1 1 2 3 5 10        -10 -5 -3 -2 -1 1 2 3 5 10];
fault=[0,0,20,20,125,125];
nos=1000; 
UCL=11.9;
Obligated_Changeponit=20;
RL=zeros(1,nos);
ARL=zeros(1,length(Delta));
MRL=zeros(1,length(Delta));
coverage=zeros(length(Delta),nos);
FaultSquare=zeros(pixs(1),pixs(2));
FaultSquare((fault(5)-fault(3)/2):(fault(5)+fault(3)/2),(fault(6)-fault(4)/2):(fault(6)+fault(4)/2))=ones(fault(3)+1,fault(4)+1);
Counter=1;
while Counter<=length(Delta)
                        if Counter > 10 && Counter<=20
                            fault(5)=188;
                            falut(6)=206;
                        elseif Counter>=21
                                fault(5)=158;
                                fault(6)=78;
                        end
    fault(1)=Delta(Counter);
    if Delta(Counter)==0
        SSnow=0;
    else
        SSnow=Obligated_Changeponit;
    end 
    jj=0;
    
    while jj < nos
        counter=0;
        flag=1;
        FaultPattern=zeros(pixs(1),pixs(2));
        while flag==1                
            counter=counter+1;
            ratio=-inf;     
            if counter>SSnow && Delta(Counter)~=0
               a= normrnd(fault(1),fault(2),fault(3)+1,fault(4)+1);
                
                FaultPattern((fault(5)-fault(3)/2):(fault(5)+fault(3)/2),(fault(6)-fault(4)/2):(fault(6)+fault(4)/2))=a;
               
            end
            if counter > m
                mflag=counter-m;
                XX0(:,:,:,1:m-1)=XX0(:,:,:,2:m);
               
            else
                mflag=0;
            end
            I=imnoise(uint8(Nom),'Poisson');
            I=double(Nom)-double(I)+FaultPattern; 
            for i = 1:grids(1) 
                for j = 1:grids(2) 
                    for stepper=1:max_steps(i,j)
                        if stepper==1
                            Img_test=I(I_2_test1_reg{i,j,stepper}(1):I_2_test1_reg{i,j,stepper}(2),I_2_test1_reg{i,j,stepper}(3):I_2_test1_reg{i,j,stepper}(4)); %Take Pixels out of Picture in box
                            I_test_reshape=reshape(Img_test,1,X_count(i,j,stepper));
                            XX0(i,j,stepper,counter-mflag)=sum(I_test_reshape); 
                        else
                            Img_testing1=I(I_2_test1_reg{i,j,stepper}(1):I_2_test1_reg{i,j,stepper}(2),I_2_test1_reg{i,j,stepper}(3):I_2_test1_reg{i,j,stepper}(4)); %Pixels on Top of box
                            Img_testing2=I(I_2_test2_reg{i,j,stepper}(1):I_2_test2_reg{i,j,stepper}(2),I_2_test2_reg{i,j,stepper}(3):I_2_test2_reg{i,j,stepper}(4)); %Pixels on Bottom of box
                            Img_testing3=I(I_2_test3_reg{i,j,stepper}(1):I_2_test3_reg{i,j,stepper}(2),I_2_test3_reg{i,j,stepper}(3):I_2_test3_reg{i,j,stepper}(4));  %Pixels on Left of box
                            Img_testing4=I(I_2_test4_reg{i,j,stepper}(1):I_2_test4_reg{i,j,stepper}(2),I_2_test4_reg{i,j,stepper}(3):I_2_test4_reg{i,j,stepper}(4));  %Pixels on Right of box
                            Img_test=[Img_testing1 Img_testing2 Img_testing3' Img_testing4']; 
                            I_test_reshape=reshape(Img_test,1,X_count(i,j,stepper)); 
                            XX0(i,j,stepper,counter-mflag)=sum(I_test_reshape)+XX0(i,j,stepper-1,counter-mflag); %Collect sums of diffs
                        end
                        mioo_ES=XX0(i,j,stepper,counter-mflag)/X_count2(i,j,stepper); %Sample mean from box
                        rat=lratconst(i,j,stepper)*X_count2(i,j,stepper)*(mioo_ES-mus(i,j,stepper))^2;
                        if rat>ratio 
                            ratio=rat; 
                            fault_time_temp=counter-SSnow-1;
                            locate=[i,j,stepper];
                        end
                        
                                                         for counter_retro=counter-1:-1:1+mflag
                                                             X_counttemp=(counter-counter_retro+1)*X_count2(i,j,stepper);
                                                            XX0(i,j,stepper,counter_retro-mflag)=XX0(i,j,stepper,counter_retro-mflag)+XX0(i,j,stepper,counter-mflag);
                                                             mioo_ES=XX0(i,j,stepper,counter_retro-mflag)/X_counttemp;
                                                             rat=lratconst(i,j,stepper)*X_counttemp*(mioo_ES-mus(i,j,stepper))^2;
                                                             if rat>ratio
                                                                 ratio=rat;
                                                                 fault_time_temp=counter_retro-SSnow-1;
                                                                 locate=[i,j,stepper];
                                                            elseif rat<0
                                                                 break;
                                                            end
                                                         end
                                        
                    end
                end
            end
         
            if ratio > UCL
                if counter <= SSnow
                                    
                    break;
                else
                    jj=jj+1;
                    fault_time(Counter,jj)=fault_time_temp;
                    if Delta(Counter)~=0
                        region_square=zeros(pixs(1),pixs(2));
                      
                        region_square(center(locate(1),locate(2),1)-steps{locate(1),locate(2)}(locate(3))/2:center(locate(1),locate(2),1)+steps{locate(1),locate(2)}(locate(3))/2, center(locate(1),locate(2),2)-steps{locate(1),locate(2)}(locate(3))/2:center(locate(1),locate(2),2)+steps{locate(1),locate(2)}(locate(3))/2)=ones(steps{locate(1),locate(2)}(locate(3))+1,steps{locate(1),locate(2)}(locate(3))+1);
                  
                        FaultSquare=zeros(pixs(1),pixs(2));
                     
                            b=ones(fault(3)+1,fault(4)+1);
                        FaultSquare((fault(5)-fault(3)/2):(fault(5)+fault(3)/2),(fault(6)-fault(4)/2):(fault(6)+fault(4)/2))=b;
                       
                        Overlap=region_square.*FaultSquare;
                       coverage(Counter, jj)= 2*sum(sum(Overlap))/ (X_count2(locate(1),locate(2),locate(3))+((fault(3)+1)*(fault(4)+1)));
                    end
                    RL(jj)=counter-SSnow;
                    RL2(jj)=counter;
                
                   flag=0;
                end
            end
        end
         if ratio > UCL && counter >= SSnow
           disp( ['Delta(' num2str(Delta(Counter)) ')' '      number of simulation =' num2str(jj) '    RL=[' num2str(RL2(jj)) ']       the number of points out of UCl=[ ' num2str(RL(jj)) ']' ]);
      
         end         
    end
        
    disp(['End of delta(' num2str(Delta(Counter)) ')']);

      
    if Counter>0
    ARL(Counter)=mean(RL);MRL(Counter)=median(RL);
    end
    disp(['Delta(' num2str(Delta(Counter)) ')'   'UCl=' num2str(UCL) '    ARL='  num2str(ARL)   '      MRL=' num2str(MRL)]);
     disp('==============================================================================')
       disp('==============================================================================')
       disp('==============================================================================')
Counter=Counter+1;
end
Coverage_Median=median(coverage, 2);
Coverage_Mean= mean(coverage, 2);
Coverage_Std=std(coverage,0,2);
ErrorinTime=fault_time;
ErrorinTime_median= median(ErrorinTime,2);
ErrorinTime_mean= mean(ErrorinTime,2);
ErrorinTime_std=std(ErrorinTime,0,2);
for i = 1:length(Delta)
C1(i)=numel(find(ErrorinTime(i,:)==0));
C2(i)=numel(find(abs(ErrorinTime(i,:))<=2))-C1(i);
C3(i)=numel(find(ErrorinTime(i,:)<=-3));
C4(i)=numel(find(ErrorinTime(i,:)>=3));
C1(i)=(C1(i)/nos)*100;
C2(i)=(C2(i)/nos)*100;
C3(i)=(C3(i)/nos)*100;
C4(i)=(C4(i)/nos)*100;
end
save ('ARLMeanShift10SqST', 'ARL', 'MRL','Delta','fault_time','SS_Number',...
      'Coverage_Median', 'Coverage_Mean', 'Coverage_Std', 'ErrorinTime',...
      'ErrorinTime_median','ErrorinTime_mean', 'ErrorinTime_std', ....
      'C1', 'C2', 'C3', 'C4', 'coverage');
