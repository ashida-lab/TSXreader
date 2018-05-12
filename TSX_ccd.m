close all
clear all

[slc_dat1,sar_struct1]=TSX_reader();
[slc_dat2,sar_struct2]=TSX_reader();

figure;hold on
for cnt=1:4
    plot(sar_struct1.geo_info(cnt).lat,sar_struct1.geo_info(cnt).lon,'r*')
end

for cnt=1:4
    plot(sar_struct2.geo_info(cnt).lat,sar_struct2.geo_info(cnt).lon,'b*')
end

[tform1_linepixel2latlon,tform1_latlon2linepixel]=geo_trans(sar_struct1);
[tform2_linepixel2latlon,tform2_latlon2linepixel]=geo_trans(sar_struct2);

SAR_registration(slc_dat1,tform1_linepixel2latlon,slc_dat2,tform2_latlon2linepixel);

figure;plot3(sar_struct1.orbit.x,sar_struct1.orbit.y,sar_struct1.orbit.z);
hold on
plot3(sar_struct2.orbit.x,sar_struct2.orbit.y,sar_struct2.orbit.z);

figure;plot(sar_struct1.doppler.t-sar_struct1.start_time,sar_struct1.doppler.coef0);
hold on
plot(sar_struct2.doppler.t-sar_struct2.start_time,sar_struct2.doppler.coef0);

f_dc0=sar_struct1.doppler.coef0(1)-sar_struct1.doppler.coef1(1)*sar_struct1.doppler.ref(1);
f_dc1=sar_struct1.doppler.coef0(end)-sar_struct1.doppler.coef1(end)*sar_struct1.doppler.ref(end);

f_dc_dot1=(f_dc1-f_dc0)/(sar_struct1.doppler.t(end)-sar_struct1.doppler.t(1));

f_dc0=sar_struct2.doppler.coef0(1)-sar_struct2.doppler.coef1(1)*sar_struct2.doppler.ref(1);
f_dc1=sar_struct2.doppler.coef0(end)-sar_struct2.doppler.coef1(end)*sar_struct2.doppler.ref(end);

f_dc_dot2=(f_dc1-f_dc0)/(sar_struct2.doppler.t(end)-sar_struct2.doppler.t(1));
