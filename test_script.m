%%
% A test script for asteroid from JPL 
colName={'datetime' ,'datetime_jd','solar_presence','lunar_presence',...
 'RA','DEC','RA_rate','DEC_rate', 'AZ' ,'EL','V','RA_3sigma','DEC_3sigma' };
%%
testA=[1 265369 11 24 34] ;   
%testA=C.perturbed_Id;
for k=1:length(testA)
tname=sprintf('%d:',testA(k));
target = queryHorizons(tname);
target=target.set_discreteepochs([2457829.013889]);
target=target.get_ephemerides('O44');
if k==1
   allTable=target.data(:,colName);
   else
   allTable=[allTable;target.data(:,colName)];
end
%% 
