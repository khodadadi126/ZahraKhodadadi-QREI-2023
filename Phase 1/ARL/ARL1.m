
clc
clear all
warning off all
fclose all;
load Spa_Temp_Baseline
Nom=imread('Tile_Nom.bmp');
Nom=imresize(Nom,[512,512]);
pfilter='pkva';
dfilter='pkva';
nlevels=[1 2];
y = pdfbdec(double(Nom),pfilter, dfilter, nlevels);
ContourletCoeff=showpdfb(y);
Nom=ContourletCoeff.New;
Nom=imresize(Nom,[250,250]);

fault=[0,0,10,10,125,125];

nos=1000; 
UCL=11.9;
MinUCL=UCL;
yy=1;
while UCL>=MinUCL  
k=4.288;
N=pixs(1)*pixs(2);
mus2=mus.^2;
Fault_pat=zeros(pixs(1),pixs(2));
lratconst=1/2/vars;
mfiller=zeros([size(mus),1]);
mflag=0;
RL=zeros(1,nos);
FaultSquare=zeros(pixs(1),pixs(2));
FaultSquare((fault(5)-fault(3)/2):(fault(5)+fault(3)/2),...
(fault(6)-fault(4)/2):(fault(6)+fault(4)/2))...
=ones(fault(3)+1,fault(4)+1);
Fadel=1;

 jj=1;  
    while jj <= nos
        XX0=zeros([size(mus),m]);
   %while jj < 1
        counter=0;
        flag=1;
        FaultPattern=zeros(pixs(1),pixs(2));
       
           while flag==1                
            counter=counter+1;
            ratio=-inf;
         
            if counter > m
               mflag=counter-m;
                XX0(:,:,:,1:m-1)=XX0(:,:,:,2:m);
              XX0(:,:,:,m)=mfiller;
            else
               mflag=0;
            end
         
                     I=imnoise(uint8(Nom),'Poisson');
                     I=double(Nom)-double(I); 
        
                                        for i = 1:grids(1) %Run through x locations for center of serveillance box
                                            for j = 1:grids(2) %Run through y locations for center of serveillance box
                                                for stepper=1:max_steps(i,j)
                                                    if stepper==1
                                                        Img_test=I(I_2_test1_reg{i,j,stepper}(1):I_2_test1_reg{i,j,stepper}(2),I_2_test1_reg{i,j,stepper}(3):I_2_test1_reg{i,j,stepper}(4)); %Take Pixels out of Picture in box
                                                        I_test_reshape=reshape(Img_test,1,X_count(i,j,stepper)); %Reshape Pixels into a vector
                                                        XX0(i,j,stepper,counter-mflag)=sum(I_test_reshape); %Collect sums of diffs
                                                        
                                                    else
                                                        Img_testing1=I(I_2_test1_reg{i,j,stepper}(1):I_2_test1_reg{i,j,stepper}(2),I_2_test1_reg{i,j,stepper}(3):I_2_test1_reg{i,j,stepper}(4)); %Pixels on Top of box
                                                        Img_testing2=I(I_2_test2_reg{i,j,stepper}(1):I_2_test2_reg{i,j,stepper}(2),I_2_test2_reg{i,j,stepper}(3):I_2_test2_reg{i,j,stepper}(4)); %Pixels on Bottom of box
                                                        Img_testing3=I(I_2_test3_reg{i,j,stepper}(1):I_2_test3_reg{i,j,stepper}(2),I_2_test3_reg{i,j,stepper}(3):I_2_test3_reg{i,j,stepper}(4));  %Pixels on Left of box
                                                        Img_testing4=I(I_2_test4_reg{i,j,stepper}(1):I_2_test4_reg{i,j,stepper}(2),I_2_test4_reg{i,j,stepper}(3):I_2_test4_reg{i,j,stepper}(4));  %Pixels on Right of box
                                                        Img_test=[Img_testing1 Img_testing2 Img_testing3' Img_testing4']; %Take Pixels on edge of box
                                                        I_test_reshape=reshape(Img_test,1,X_count(i,j,stepper)); %Reshape Pixels into a vector
                                                        XX0(i,j,stepper,counter-mflag)=sum(I_test_reshape)+XX0(i,j,stepper-1,counter-mflag); %Collect sums of diffs
                                                    end
                                                    mioo_ES=XX0(i,j,stepper,counter-mflag)/X_count2(i,j,stepper); %Sample mean from box
                                                    rat=lratconst(i,j,stepper)*X_count2(i,j,stepper)*(mioo_ES-mus(i,j,stepper))^2;
                                                    if rat>ratio 
                                                        if rat==inf || rat ==-inf
                                                           
                                                        else
                                                        ratio=rat; %New statistic
                                                        end

                                                    end

                                                        for counter_retro=counter-1:-1:1+mflag
                                                            X_counttemp=(counter-counter_retro+1)*X_count2(i,j,stepper);
                                                            XX0(i,j,stepper,counter_retro-mflag)=XX0(i,j,stepper,counter_retro-mflag)+XX0(i,j,stepper,counter-mflag);
                                                            mioo_ES=XX0(i,j,stepper,counter_retro-mflag)/X_counttemp; %Sample mean from box
                                                           rat1=rat;
                                                        
                                                            rat=lratconst(i,j,stepper)*X_counttemp*(mioo_ES-mus(i,j,stepper))^2;
                                                            if rat>ratio
                                                
                                                
                                                                ratio=rat;
                                          
                                                            elseif rat<0
                                                                break;
                                                            end
                                                        end

                                                  
                                     
                                                  
                                                  
                                                end
                                            end
                                        end
               %______________________________________________________________________________________
            
            
  %======================================================
  %======================================================
  %===============================================
        %    out of control
      
        disp([  'the number of simulation=' num2str(jj)   '     point='  num2str(counter) '     Ratio=' num2str(ratio) '     UCL=' num2str(UCL)]);
            if ratio > UCL
                jj=jj+1;
                  break
            else
                RL(jj)=counter;
   
            end   
                
 
            end
            
            
disp('------------------------------------------------')
    end


ARL=mean(RL);
MRL=median(RL);
disp(['UCl=' num2str(UCL) '    ARL='  num2str(ARL)   '      MRL=' num2str(MRL)]);
disp('_______________________________________________________________________________________________')
disp('_______________________________________________________________________________________________')
disp('_______________________________________________________________________________________________')

Arl(yy)=ARL;
Mrl(yy)=MRL;
Ucl(yy)=UCL;
 UCL=UCL-0.05;
yy=yy+1;
end

for kk=1:(yy)-1
disp([ 'UCL=' num2str(Ucl(kk)) '    ARL=' num2str(Arl(kk))  '   MRL='   num2str(Mrl(kk))]);
disp('===================================================================================')
end
Mrl(yy)=MRL;
Ucl(yy)=UCL;
save ('RRun', 'Arl', 'Mrl' ,'Ucl');











