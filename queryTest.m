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
            test.verifyEqual(target.getitem('RA',1),1.8870260360000e+02);
            test.verifyEqual(target.getitem('DEC',1),9.09796630);
            test.verifyEqual(target.getitem('RA_rate',1),33.5154200);
            test.verifyEqual(target.getitem('DEC_rate',1),-2.71216);
            test.verifyEqual(target.getitem('AZ',1),213.3483);
            test.verifyEqual(target.getitem('EL',1),69.3971);
            test.verifyEqual(target.getitem('airmass',1),1.068);
            test.verifyEqual(target.getitem('magextinct',1),0.136);
            test.verifyEqual(target.getitem('V',1), 8.27);
            test.verifyEqual(target.getitem('S_brt',1),6.83);
            test.verifyEqual(target.getitem('illumination',1),96.171);
            test.verifyEqual(target.getitem('EclLon',1),161.382784);
            test.verifyEqual(target.getitem('EclLat',1),10.452780);
            test.verifyEqual(target.getitem('r',1),2.551099015575);
            test.verifyEqual(target.getitem('lighttime',1), 18.821722);
            test.verifyEqual(target.getitem('RA_3sigma',1), 0);
            test.verifyEqual(target.getitem('DEC_3sigma',1), 0);
        end
          function asteroid_elements(test)
            target = queryHorizons('50278:');
            target=target.set_epochrange('2016-02-23 00:00', '2016-02-24 00:00', '1h') ;
            target=target.get_elements('@sun');
            test.verifyEqual(target.getitem('e',1),3.745046914535793e-02);
            test.verifyEqual(target.getitem('i',1),1.265558218548466);
            test.verifyEqual(target.getitem('M',1),4.726148747089238e+01);              
          end
           function asteroid_vectors(test)
            target = queryHorizons('499');
            target=target.set_discreteepochs([2455562.500766 2455563.500766 2455564.500766 2455565.500766 2455566.500766 2455567.500766]);
            target=target.get_vectors('@SSB');
            test.verifyEqual(target.getitem('y',3),-1.154468372839617);
            test.verifyEqual(target.getitem('RR',3),-8.889653366064838e-04);          
          end
    end
    
end

