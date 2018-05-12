% SARTOOLS - For accessing TerraSAR-X and TanDEM-X COSAR files
% Version 2 20-Mar-2014
%
% Principal functions
%   readCosFile      - reads data from a TerraSAR-X/TanDEM-X COS file
%   TanDEM2TerraSAR  - TanDEM2TerraSAR converts TanDEM-X COSAR files to TerraSAR-X COSAR files
% 
% Convenience function
%   TD2TSall         - converts TanDEM-X COS files to TerraSAR-X COS files
% 
% Helper functions
%   allfiles         - returns all files below a directory with given extensions
%   cosBurstHeader   - reads burst header for a COS file
%   cosFileHeader    - reads file header for a COS file
%   cosSamples       - reads data samples from a COS file
%   halfprecision    - halfprecision converts IEEE 754 floating point to half precision IEEE 754r
%   halfprecisionmax - halfprecisionmax returns IEEE 754r bit pattern of max half precision value
%   halfprecisionmin - halfprecisionmin returns IEEE 754r bit pattern of min half precision value

