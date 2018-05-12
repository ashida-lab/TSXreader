clear all
close all

load('X:\DATA\TSX\Rotterdam\slc_cut2.mat');

C=299792458;
PRF=4.24000000000000000E+04;
V_ref=7.02882873175895656E+03;
Freq=9.64999886148999977E+09;
lambda=C/Freq;
range_time=4.90750683226652464E-03;
R0=range_time*C/2;

Nbin=size(slc_cut,1);
Nhit=size(slc_cut,2);
start_time=46.955933;
stop_time=47.398197;


T=1:Nbin;
T=T/Nbin;
t=-Nhit/2+1:Nhit/2;

f=-Nhit/2+1:Nhit/2;
f=f*PRF/Nhit;

% return;



slc_fft=fftshift(fft(slc_cut,[],2),2);
figure;imagesc(log10(abs(slc_fft)))

slc_cut=log10(abs(slc_cut)+1);
mn=min(min(slc_cut,[],1),[],2);
mx=max(max(slc_cut,[],1),[],2);
slc_cut=(slc_cut-mn)/(mx-mn);

slc_cut=imresize(slc_cut,[300 300]);

slc_cut=rot90(slc_cut,2);

imwrite(slc_cut,['./img/00-00.png']);

Vref=0.000005;
ref=Vref.*t.*t;
figure;plot(ref);

slc_fft2=fftshift(fft(slc_fft,[],1),1);

for cnt=1:Nhit
%     slc_fft2(:,cnt)=slc_fft2(:,cnt).*exp(-1i*pi*ref(cnt).*T.*T).';
end

slc_fft3=fft(fftshift(slc_fft2,1),[],1);

figure;imagesc(abs(slc_fft));
figure;imagesc(abs(slc_fft3));

% return;

for pcnt=50
    for vcnt=1:100
        phi=0;%2.1*pi/180*(pcnt-50)/50;
        v_a=0.2*(vcnt-50)/1;
        
        fd0=-2*V_ref/lambda*sin(phi);
        fr0=2*V_ref*V_ref/lambda/R0*cos(phi)*cos(phi);
        
        fd1=-2*(V_ref-v_a)/lambda*sin(phi);
        fr1=2*(V_ref-v_a)*(V_ref-v_a)/lambda/R0*cos(phi)*cos(phi);
        
        df=fd1-fd0;
        
        theta=exp(1i*pi*(f.*f.*f.*f.*f.*f/PRF/PRF/PRF/PRF/PRF*(50-50)/50)).*exp(1i*pi*(f.*f.*f.*f/PRF/PRF/PRF*(pcnt-50)/250)).*exp(1i*pi*(f.*f*(1/fr1-1/fr0))).*exp(2i*pi*df/fr0*f).*exp(1i*pi*df*df/fr1);
        slc_fft4=slc_fft3.*repmat((theta),[Nbin 1]);
        
        %     figure;imagesc(log10(abs(slc_fft4)))
        
        slc_cut2=log10(abs(fft(fftshift(slc_fft4,2),[],2)));
        mn=min(min(slc_cut2,[],1),[],2);
        mx=max(max(slc_cut2,[],1),[],2);
        slc_cut2=(slc_cut2-mn)/(mx-mn);
        slc_cut2=imresize(slc_cut2,[300 300]);
        
        imwrite(slc_cut2,['./img/' num2str(pcnt) '-' num2str(vcnt) '.png']);
    end
end


% figure;imagesc(log10(abs(slc_cut)))
% figure;imagesc(log10(abs(rot90(slc_cut2,2))))