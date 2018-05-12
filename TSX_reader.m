function [slc_dat,sar_struct]=TSX_reader()

addpath('TSXtools');

[FileName,PathName] = uigetfile('*.xml','Select TSX XML file');

tsx_info=parseXML([PathName FileName]);
tsx_info.level1Product.processing.doppler.dopplerCentroid.dopplerEstimate(2).timeUTC.data

fname=[PathName tsx_info.level1Product.productComponents.imageData.file.location.path.data '\' tsx_info.level1Product.productComponents.imageData.file.location.filename.data];
[slc_dat_tmp,~]=readCosFile(fname);

slc_dat=single(slc_dat_tmp(1,:,:))+1i*single(slc_dat_tmp(2,:,:));
clear slc_dat_tmp

slc_dat=squeeze(slc_dat);

figure;imagesc(log10(abs(slc_dat(1:10:end,1:10:end))))

sar_struct.mode=tsx_info.level1Product.productInfo.acquisitionInfo.imagingMode.data;
sar_struct.Nbin=str2num(tsx_info.level1Product.productInfo.imageDataInfo.imageRaster.numberOfRows.data);
sar_struct.range_spacing_sec=str2num(tsx_info.level1Product.productInfo.imageDataInfo.imageRaster.rowSpacing.data);
sar_struct.Nhit=str2num(tsx_info.level1Product.productInfo.imageDataInfo.imageRaster.numberOfColumns.data);
sar_struct.azimuth_spacing_sec=str2num(tsx_info.level1Product.productInfo.imageDataInfo.imageRaster.columnSpacing.data);

sar_struct.geo_info(1).x=str2num(tsx_info.level1Product.productInfo.sceneInfo.sceneCornerCoord(1).refRow.data);
sar_struct.geo_info(1).y=str2num(tsx_info.level1Product.productInfo.sceneInfo.sceneCornerCoord(1).refColumn.data);
sar_struct.geo_info(1).lat=str2num(tsx_info.level1Product.productInfo.sceneInfo.sceneCornerCoord(1).lat.data);
sar_struct.geo_info(1).lon=str2num(tsx_info.level1Product.productInfo.sceneInfo.sceneCornerCoord(1).lon.data);

sar_struct.geo_info(2).x=str2num(tsx_info.level1Product.productInfo.sceneInfo.sceneCornerCoord(2).refRow.data);
sar_struct.geo_info(2).y=str2num(tsx_info.level1Product.productInfo.sceneInfo.sceneCornerCoord(2).refColumn.data);
sar_struct.geo_info(2).lat=str2num(tsx_info.level1Product.productInfo.sceneInfo.sceneCornerCoord(2).lat.data);
sar_struct.geo_info(2).lon=str2num(tsx_info.level1Product.productInfo.sceneInfo.sceneCornerCoord(2).lon.data);

sar_struct.geo_info(3).x=str2num(tsx_info.level1Product.productInfo.sceneInfo.sceneCornerCoord(3).refRow.data);
sar_struct.geo_info(3).y=str2num(tsx_info.level1Product.productInfo.sceneInfo.sceneCornerCoord(3).refColumn.data);
sar_struct.geo_info(3).lat=str2num(tsx_info.level1Product.productInfo.sceneInfo.sceneCornerCoord(3).lat.data);
sar_struct.geo_info(3).lon=str2num(tsx_info.level1Product.productInfo.sceneInfo.sceneCornerCoord(3).lon.data);

sar_struct.geo_info(4).x=str2num(tsx_info.level1Product.productInfo.sceneInfo.sceneCornerCoord(4).refRow.data);
sar_struct.geo_info(4).y=str2num(tsx_info.level1Product.productInfo.sceneInfo.sceneCornerCoord(4).refColumn.data);
sar_struct.geo_info(4).lat=str2num(tsx_info.level1Product.productInfo.sceneInfo.sceneCornerCoord(4).lat.data);
sar_struct.geo_info(4).lon=str2num(tsx_info.level1Product.productInfo.sceneInfo.sceneCornerCoord(4).lon.data);

sar_struct.prf=str2num(tsx_info.level1Product.productSpecific.complexImageInfo.commonPRF.data);

sar_struct.start_time=timeUTC2sec(tsx_info.level1Product.productInfo.sceneInfo.start.timeUTC.data);

sar_struct.numberOfDopplerRecords=str2num(tsx_info.level1Product.processing.doppler.dopplerCentroid.numberOfDopplerRecords.data);

for cnt=1:sar_struct.numberOfDopplerRecords
    sar_struct.doppler.t(cnt)=timeUTC2sec(tsx_info.level1Product.processing.doppler.dopplerCentroid.dopplerEstimate(cnt).timeUTC.data);
    sar_struct.doppler.coef0(cnt)=str2num(tsx_info.level1Product.processing.doppler.dopplerCentroid.dopplerEstimate(cnt).combinedDoppler.coefficient(1).data);
    sar_struct.doppler.coef1(cnt)=str2num(tsx_info.level1Product.processing.doppler.dopplerCentroid.dopplerEstimate(cnt).combinedDoppler.coefficient(2).data);
    sar_struct.doppler.ref(cnt)=str2num(tsx_info.level1Product.processing.doppler.dopplerCentroid.dopplerEstimate(cnt).combinedDoppler.referencePoint.data);
end

sar_struct.numberOfDopplerRateRecords=size(tsx_info.level1Product.processing.geometry.dopplerRate,2);

for cnt=1:sar_struct.numberOfDopplerRateRecords
    sar_struct.doppler_rate.t(cnt)=timeUTC2sec(tsx_info.level1Product.processing.geometry.dopplerRate(cnt).timeUTC.data);
    sar_struct.doppler_rate.coef0(cnt)=str2num(tsx_info.level1Product.processing.geometry.dopplerRate(cnt).dopplerRatePolynomial.coefficient(1).data);
    sar_struct.doppler_rate.coef1(cnt)=str2num(tsx_info.level1Product.processing.geometry.dopplerRate(cnt).dopplerRatePolynomial.coefficient(2).data);
    sar_struct.doppler_rate.coef2(cnt)=str2num(tsx_info.level1Product.processing.geometry.dopplerRate(cnt).dopplerRatePolynomial.coefficient(3).data);
    sar_struct.doppler_rate.coef3(cnt)=str2num(tsx_info.level1Product.processing.geometry.dopplerRate(cnt).dopplerRatePolynomial.coefficient(4).data);
    sar_struct.doppler_rate.ref(cnt)=str2num(tsx_info.level1Product.processing.geometry.dopplerRate(cnt).dopplerRatePolynomial.referencePoint.data);
end

sar_struct.FM=(sar_struct.doppler_rate.coef0(end)+sar_struct.doppler_rate.coef0(1))/2;

sar_struct.numberOfOrbitRecords=str2num(tsx_info.level1Product.platform.orbit.orbitHeader.numStateVectors.data);

for cnt=1:sar_struct.numberOfOrbitRecords
    sar_struct.orbit.t(cnt)=timeUTC2sec(tsx_info.level1Product.platform.orbit.stateVec(cnt).timeUTC.data);
    sar_struct.orbit.x(cnt)=str2num(tsx_info.level1Product.platform.orbit.stateVec(cnt).posX.data);
    sar_struct.orbit.y(cnt)=str2num(tsx_info.level1Product.platform.orbit.stateVec(cnt).posY.data);
    sar_struct.orbit.z(cnt)=str2num(tsx_info.level1Product.platform.orbit.stateVec(cnt).posZ.data);
    sar_struct.orbit.vx(cnt)=str2num(tsx_info.level1Product.platform.orbit.stateVec(cnt).velX.data);
    sar_struct.orbit.vy(cnt)=str2num(tsx_info.level1Product.platform.orbit.stateVec(cnt).velX.data);
    sar_struct.orbit.vz(cnt)=str2num(tsx_info.level1Product.platform.orbit.stateVec(cnt).velX.data);
end

end