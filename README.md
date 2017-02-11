# callHorizonMatlab
call horizon online matlab version
a matlab version of [callhorizons](https://github.com/mommermi/callhorizons)
but not the same ,you have to read [horizon_doc](http://ssd.jpl.nasa.gov/?horizons_doc) carefully ,and check the data carefully 
## Baisc Useage
### download file queryHorizon.m in your matlab path
### initialization for discrete epochs ,only supply for the jd or mjd format,you can use [cspice](http://git.oschina.net/vancky/mice) to do more time transform.
>>> target=queryHorizon('499');
>>> target=target.set_discreteepochs([2457446.177083, 2457446.182343,2457448.182343]);
>>> target=target.get_ephemerides();
### initialization for equal interval epochs, supply for  format 'YYYY-MM-DD [HH-MM-SS]'
>>> target=queryHorizon('Ceres');
>>> target=target.set_epochrange('2016-02-26', '2016-10-25', '1d')
>>> target=target.get_ephemerides();
### get data
>>> target.originSrc % the origin source from Horizon 
>>> target.data      % the formated ephemrides from source , a matlab table format
>>> target.official_name % check the name of object
>>> target.getitme('RA',1)  % get the first RA
>>> target.data{1,'RA'} % the same to the up 
>>> target.getitme('RA',:)  % get all RA  
Any suggest or comment ,contact vanckyli@gmail.com ! 
have fun!