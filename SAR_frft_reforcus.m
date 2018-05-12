clear all
close all

load('X:\DATA\TSX\Rotterdam\slc_cut.mat');

slc_cut=log10(abs(slc_cut)+1);
mn=min(min(slc_cut,[],1),[],2);
mx=max(max(slc_cut,[],1),[],2);
slc_cut=(slc_cut-mn)/(mx-mn);

slc_cut=imresize(slc_cut,[300 300]);
imwrite(slc_cut,['./img/00.png']);

% slc_cut=rot90(slc_cut,2);

Nbin=size(slc_cut,1);
Nhit=size(slc_cut,2);

slc_frft=zeros(Nbin,Nhit);
slc_frft2=zeros(Nbin,Nhit);

for cnt=1:Nbin
    slc_frft(cnt,:)=frft(slc_cut(cnt,:),1);
end
figure;imagesc(log10(abs(slc_frft)))

for acnt=1:100
    N=1+acnt/250;
    
    for cnt=1:Nbin
        slc_frft2(cnt,:)=frft(slc_frft(cnt,:),-N);
    end
    
    slc_cut2=log10(abs(slc_frft2)+1);
    mn=min(min(slc_cut2,[],1),[],2);
    mx=max(max(slc_cut2,[],1),[],2);
    slc_cut2=(slc_cut2-mn)/(mx-mn);
    slc_cut2=imresize(slc_cut2,[300 300]);
    slc_cut2=imresize(slc_cut2,[300 300]);
    imwrite(slc_cut2,['./img/' num2str(N) '.png']);
end
% figure;imagesc(log10(abs(slc_frft2)))