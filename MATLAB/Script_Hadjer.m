%% Scrpit stats matlab DOM_dedrift




%% 0 - loop over filenemqs in folder

clear all
close all

%Initiqlize results
SNRfinal=[];
Intfinal=[];
bkgstd_final=[];
uncertainty_final=[];
Intensity_final=[];

A=ls;
A=A(3:end,:);
ll=size(A,1);

for k=1:ll
    fnqme=A(k,:);
    
    if (strfind(fnqme,'_DOM_dedrift.xls')>0)
        %Figure1: density evolution of eqch dqtaset
        figure(1);
        hold on
        
        
        %% 1 - open file (dlmread/matrixread)
        %opts = delimitedTextImportOptions;
        %A = readmatrix(fnqme,opts);
        B = dlmread(fnqme,'\t',1,0) ;
        
        
        %% 1.5 save images using hist3
        x=B(:,2);
        y=B(:,3);
        
        xmin=floor(min(x));
        xmax=ceil(max(x));
        ymin=floor(min(y));
        ymax=ceil(max(y));
        H=hist3([x,y],{xmin:0.1:xmax ymin:0.1:ymax});
        filename=strrep(fnqme,'_DOM_dedrift.xls',strcat('DOM_dedrift_hist3.png'));
        imwrite(H/max(max(H)),filename,'png','bitdepth',16);
        
        %% 1.6 Compute density evolution and plot
        Area=sum(sum(H>1));
        Frame = B(:,4);
        numpeqks=max(Frame);
        rand3=k/ll; % for randering purpose
        nump=[];
        for fr=1:500:numpeqks
            nump=[nump,find(Frame>=fr,1)];
        end
        figure(1);
        plot(1:500:numpeqks,nump/Area,'Color',[0 0.5 rand3])
        xlabel('frames')
        ylabel('mol/120nm^2')
        title('Evolution of density')
        %% 2 - selct columns of interrest (SNR, inetgrqted signal)
        
        SNRB = B(:,21);
        SNRfinal=[SNRfinal;SNRB];
        
        IntB = B(:,20);
        Intfinal=[Intfinal;IntB];
        
        
        
        
        %% 3 - compute hsitogrqms qnd meqn vqlues
        M = mean(SNRB);
        
        
        
        %% 4 displqy results
        sprintf('mean SNR for %s with %f molecules= %d',fnqme,length(SNRB),mean(SNRB))
        sprintf('mean Intsignql for %s with %f molecules= %d',fnqme,length(IntB),mean(IntB))
        
    end
    
    
    
    if (strfind(fnqme,'_TS_G_GP.csv')>0)
        %% 1 - open file (dlmread/matrixread)
        %opts = delimitedTextImportOptions;
        %A = readmatrix(fnqme,opts);
        s = dir(fnqme);         
    filesize = s.bytes      ;       
        if (filesize>5000)
        K = dlmread(fnqme,',',1,0) ;
        
        %% 1.5 save images using hist3
        x=K(:,2);
        y=K(:,3);
        
        xmin=floor(min(x));
        xmax=ceil(max(x));
        ymin=floor(min(y));
        ymax=ceil(max(y));
        Z=hist3([x,y],{xmin:10:xmax ymin:10:ymax});
        filename=strrep(fnqme,'_TS_G_GP.csv',strcat('TS_G_GP_hist3.png'));
        imwrite(Z/max(max(Z)),filename,'png','bitdepth',16);
        
        
        
        
        %% 2 - selct columns of interrest (SNR, inetgrqted signal)
        
        bkgstdK = K(:,8);
        bkgstd_final=[bkgstd_final;bkgstdK];
        
        uncertainty_xy_K = K(:,10);
        uncertainty_final=[uncertainty_final;uncertainty_xy_K];
        
        Intensity_K= K(:,6);
        Intensity_final=[Intensity_final;Intensity_K];
        
        
        
        
        %% 3 - compute hsitogrqms qnd meqn vqlues
        L = mean(bkgstdK);
        
        
        
        %% 4 displqy results
        sprintf('mean bkgstd for %s with %f molecules= %d',fnqme,length(bkgstdK),mean(bkgstdK))
        sprintf('mean Intsignql for %s with %f molecules= %d',fnqme,length(Intensity_K),mean(Intensity_K))
        sprintf('mean Uncertainty for %s with %f molecules= %d',fnqme,length(uncertainty_xy_K),mean(uncertainty_xy_K))
        
        end
    end
end



%% 5 qverage and display results
F = round(mean(bkgstd_final));
S = round(mean(Intensity_final));
T = round(mean(uncertainty_final));
C = round(mean(SNRfinal));
D = round(mean(Intfinal));


figure(1) 
saveas(figure(1),'Evolution of density.png')

figure(2)
edges = [0:5:60];
histogram(SNRfinal,edges);
xlabel('SNR')
ylabel('Fraction (UA)')
title(['<SNR> final=', num2str(C)])
fnqme=strrep(fnqme,'_DOM_dedrift.xls',strcat('DOM_dedrift.png'));
saveas(gcf,'SNRmean.png')

figure(3)
edges = [0:1000:60000];
histogram(Intfinal,edges)
xlabel('Intensity')
ylabel('Fraction (UA)')
title(['<Int> final=', num2str(D)])
fnqme=strrep(fnqme,'_DOM_dedrift.xls',strcat('DOM_dedrift.png'));
saveas(gcf,'Intmean.png')

figure(4)
edges = [0:10:200];
histogram(bkgstd_final,edges);
xlabel('background')
ylabel('Fraction (UA)')
title(['<bkgstd> final=', num2str(F)])
fnqme=strrep(fnqme,'_TS_G_GP.csv',strcat('TS_G_GP.csv.png'));
saveas(gcf,'bkgstd_mean.png')

figure(5)
edges = [0:5:50];
histogram(uncertainty_final,edges);
xlabel('Uncertainty')
ylabel('Fraction (UA)')
title(['<uncertainty_xy> final=', num2str(T)])
fnqme=strrep(fnqme,'_TS_G_GP.csv',strcat('TS_G_GP.csv.png'));
saveas(gcf,'uncertainty_xy_mean.png')

figure(6)
edges = [0:1000:60000];
histogram(Intensity_final,edges);
xlabel('Intensity')
ylabel('Fraction (UA)')
title(['<Intensity> final=', num2str(S)])
fnqme=strrep(fnqme,'_TS_G_GP.csv',strcat('TS_G_GP.csv.png'));
saveas(gcf,'Intensity_mean.png')




fileID = fopen('result.txt','w');
fprintf(fileID,'%12s %12s %12s %12s %12s \r\n','mean SNR','mean Int','mean Int.G','mean bkgstd','mean uncertainty');
fprintf(fileID,'%12d %12d %12d %12d %12d \r\n',C,D,S,F,T);
fclose(fileID);

sprintf('mean SNR for %s with %f molecules= %d',fnqme,length(SNRfinal),round(mean(SNRfinal)))
sprintf('mean Intsignql for %s with %f molecules= %d',fnqme,length(Intfinal),round(mean(Intfinal)))
sprintf('mean bkgstd for %s with %f molecules= %d',fnqme,length(bkgstd_final),mean(bkgstd_final))
sprintf('mean Intsignql for %s with %f molecules= %d',fnqme,length(Intensity_final),mean(Intensity_final))
sprintf('mean Uncertainty for %s with %f molecules= %d',fnqme,length(uncertainty_final),mean(uncertainty_final))



%% useless for now
% fileip='_TS_G_GP.csv';
% g=char(fileip);
% g=g(1:end-4)
% fileop=horzcat(g,'_TS_G_GP.xls')
% g=fileip(1:end-4);
% [~,~,F]=xlsread(fileip);
% F=cellstr(F);
% xlswrite(fileop,F);
% disp(['--------------Process complete---------------------']);
% [~,~,num] = xlsread('_TS_G_GP.xls');
% data = num(1:end,[1 2 3 5 6 8 9 11 12 14 15 17 18 20 21 23 24 26 27 29 30 32 33 35 36 38 39 41 42 44 45 47 48 50 51 53 54 ]);
% dataS1 = str2double(strrep(data, ',', '.'));
% xlswrite('_TS_G_GP.xls',dataS1,'Sheet1');


