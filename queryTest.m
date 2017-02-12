classdef queryTest < matlab.unittest.TestCase    
    properties (TestParameter)
    end
    methods (Test)
        function asteroid_ephemerides(test)
            target = queryHorizons('Ceres');
            target=target.set_discreteepochs([2451544.500000]);
            target=target.get_ephemerides('O44');
            test.verifyEqual(target.getitem('datetime',1),{'2000-Jan-01 00:00:00.000'});
            test.verifyEqual(target.getitem('datetime_jd',1),2451544.500000);
            test.verifyEqual(target.getitem('solar_presence',1),{'C'});
            test.verifyEqual(target.getitem('lunar_presence',1),{'m'});
            test.verifyEqual(target.getitem('RA',1),1.887026100e+02);
            test.verifyEqual(target.getitem('DEC',1),9.09796);
            test.verifyEqual(target.getitem('RA_rate',1),33.51543);
            test.verifyEqual(target.getitem('DEC_rate',1),-2.71216);
            test.verifyEqual(target.getitem('AZ',1),213.3483);
            test.verifyEqual(target.getitem('EL',1),69.3971);
            test.verifyEqual(target.getitem('airmass',1),1.068);
            test.verifyEqual(target.getitem('magextinct',1),0.136);
            test.verifyEqual(target.getitem('V',1), 8.27);
            test.verifyEqual(target.getitem('S_brt',1),6.83);
            test.verifyEqual(target.getitem('illumination',1),96.171);
            test.verifyEqual(target.getitem('EclLon',1),161.3828);
            test.verifyEqual(target.getitem('EclLat',1),10.4528);
            test.verifyEqual(target.getitem('r',1),2.551098889633);
            test.verifyEqual(target.getitem('lighttime',1), 18.821722);
            test.verifyEqual(target.getitem('RA_3sigma',1), 0.058);
            test.verifyEqual(target.getitem('DEC_3sigma',1), 0.050);
        end
%          function asteroid_elements(test)
%              
%          end
    end
    
end

