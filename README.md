# callHorizonMatlab
 Call horizons online matlab version .
 A matlab version of [callhorizons](https://github.com/mommermi/callhorizons).
But not the same ,you have to read [horizons_doc](http://ssd.jpl.nasa.gov/?horizons_doc) carefully ,and check the data carefully .
## Baisc Useage

#### download file queryHorizons.m in your matlab path

```matlab
runtests('queryHorizonsTest');% run the test
```
#### Initialization for discrete epochs ,only supply for the jd or mjd format,you can use [cspice](http://git.oschina.net/vancky/mice) to do more time transform.

#### A test script is added for use of doing scripts to get ephemeris from JPL 

```matlab
target=queryHorizons('499');% for Mars 
target=target.set_discreteepochs([2457446.177083, 2457446.182343,2457448.182343]);
target=target.get_ephemerides('O44');% lijiang Station
% you can get elements like 
target=target.get_elements() % sun centered
target=target.get_elements('SSB') % SSB centered
```
#### initialization for equal interval epochs, supply for  format 'YYYY-MM-DD [HH-MM-SS]'

```matlab
target=queryHorizons('Ceres');
target=target.set_epochrange('2016-02-26', '2016-10-25', '1d')
target=target.get_ephemerides('O44');
target=target.get_vectors();% get vector in (J2000,  earth mean equator plane,SSB center)
```
#### get data

```matlab
''''
target.originSrc % the origin source from Horizon 
target.data      % the formated ephemrides from source , a matlab table format 
target.official_name % check the name of object
target.getitme('RA',1)  % get the first RA
target.data{1,'RA'} % the same to the up 
target.getitme('RA',:)  % get all RA  
target.fields % show all items  
''''
```
#### importants

- get_ephemerides , default station is O44(lijiang Observatory,you can change it in line 278),default reference system is J2000 
- get_elements,default center is 10(sun,you can change it in line 444),default reference frame is J2000,default reference plane is ecliptic and mean equinox of J2000.
- get_vectors ,default center is 0(Solar System barycenter,SSB), default reference frame is J2000,default reference plane is earth mean equator and equinox .
   Any suggests or comments ,contact vanckyli[at]gmail.com ! 
   Have fun!
- when run test file failed ,you may set a break point in the last lines of get_ephemerides() or get_elements() or get_vectors() functions, to the 
print src(pos4:pos5) and  comparison with self.data table !Sometimes , it is failed for  JPL updating it's ephemeris !