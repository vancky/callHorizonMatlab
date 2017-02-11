classdef queryHorizon
    properties
        targetname
        official_name
        start_epoch
        stop_epoch
        step_size
        discreteepochs
        url
        data
        physical
        originSrc
    end
    
    methods % constructor 
        function self = queryHorizon(targetname)
            %{
        Initialize query to Horizons
        Parameters
        ----------
        targetname         : str
           HORIZONS-readable target number, name, or designation
        Results
        self
            %}
            self.targetname = targetname;
            self.start_epoch    = nan;
            self.stop_epoch     = nan;
            self.step_size      = nan;
            self.discreteepochs = nan;
            self.url            = nan;
            self.data           = nan;
        end
    end
    methods % set epochs
        function self=set_epochrange(self,start_epoch, stop_epoch, step_size)
        %{    
        Set a range of epochs, all times are UT
        Parameters
        ----------
        start_epoch        :    str
           start epoch of the format 'YYYY-MM-DD [HH-MM-SS]'
        stop_epoch         :    str
           final epoch of the format 'YYYY-MM-DD [HH-MM-SS]' 
        step_size          :    str
           epoch step size, e.g., '1d' for 1 day, '10m' for 10 minutes...
        Returns
        -------
        None
        
        Examples
        --------
        >>> ceres =queryHorizon('Ceres')
        >>> ceres=ceres.set_epochrange('2016-02-26', '2016-10-25', '1d')
        Note that dates are mandatory; if no time is given, midnight is assumed.
        %}
        self.start_epoch = start_epoch;
        self.stop_epoch  = stop_epoch;
        self.step_size   = step_size;
        end
        function self=set_discreteepochs(self,discreteepochs)
        %{
        Set a list of discrete epochs, epochs have to be given as Julian
        Dates
        Parameters
        ----------
        discreteepochs    : list
        Returns
        -------
        None
        
        Examples
        --------
        >>> ceres = queryHorizon('Ceres')
        >>> ceres.set_discreteepochs([2457446.177083, 2457446.182343])
        %}
        self.discreteepochs = discreteepochs;
        end
    end
    properties (Dependent)
        fields
        dates
        queryUrl
        dates_jd
        ephochNo
    end
    methods
        function tt=get.fields(self)
            % returns list of available properties for all epochs
            try
                tt=self.data.Properties.VariableNames;
            catch
                tt=[];
            end
        end
        function tt=get.ephochNo(self)
            % returns total number of epochs that have been queried
            try
                tt=size(self.data,1);
            catch
                tt=0;
            end
        end
        function tt=get.dates(self)
            % returns list of epochs that have been queried (format 'YYYY-MM-DD HH-MM-SS')
            try
                tt=self.data{:,'datetime'};
            catch
                tt=[];
            end
        end
        function tt=get.queryUrl(self)
            % returns URL that has been used in calling HORIZONS
            try
                tt=self.url;
            catch
                tt=[];
            end
        end
        function tt=get.dates_jd(self)
            % returns list of epochs that have been queried (Julian Dates)
            try
                tt=self.data{:,'datetime_jd'};
            catch
                tt=[];
            end
        end
        function tt=briefInfo(self)
            %returns brief query information
            tt=sprintf('<callhorizons.query object: %s>',self.targetname);
        end
        function tt=getitem(self,key,k)
            %{
            provides access to query data

        Parameters
        ----------
        key          : str/int
           epoch index or property key

        Returns
        -------
        query data according to key

            %}
            
            if isempty(self.data)
                disp('CALLHORIZONS ERROR: run get_ephemerides or get_elements first');
                tt=nan;
            else
                if nargin>2&&max(k)<=self.ephochNo&&min(k)>0
                    tt=self.data{k,key};
                elseif nargin>2&&(max(k)>self.ephochNo||min(k)<0)&&k~=':'
                     error('out of index')
                else
                    tt=self.data{:,key};
                end
            end
        end
    end
    methods
        function self=get_ephemerides(self,observatory_code,airmass_lessthan,solar_elongation,skip_daylight)
             %{
        Call JPL HORIZONS website to obtain ephemerides based on the
        provided targetname, epochs, and observatory_code. For a list
        of valid observatory codes, refer to
        http://minorplanetcenter.net/iau/lists/ObsCodesF.html
        
        Parameters
        ----------
        observatory_code     : str/int
           observer's location code according to Minor Planet Center
        airmass_lessthan     : float
           maximum airmass (optional, default: 99)
        solar_elongation     : tuple
           permissible solar elongation range (optional, deg)
        skip_daylight        : boolean
           crop daylight epoch during query (optional)
        
        Examples
        --------
        >>> ceres = queryHorizon('Ceres')
        >>> ceres=ceres.set_epochrange('2016-02-23 00:00', '2016-02-24 00:00', '1h')
        >>> cerer=ceres.get_ephemerides('O44');
        >>> ceres.getitem('RA',1)
        >>> ceres.data(:,'RA')
        >>> ceres.data{:,'RA'}

        The queried properties and their definitions are:
           +------------------+-----------------------------------------------+
           | Property         | Definition                                    |
           +==================+===============================================+
           |official_name     | official number, name, designation [string]   |
           +------------------+-----------------------------------------------+
           | H                | absolute magnitude in V band (float, mag)     |
           +------------------+-----------------------------------------------+
           | G                | photometric slope parameter (float)           |
           +------------------+-----------------------------------------------+
           | datetime         | epoch date and time (str, YYYY-MM-DD HH:MM:SS)|
           +------------------+-----------------------------------------------+
           | datetime_jd      | epoch Julian Date (float)                     |
           +------------------+-----------------------------------------------+
           | solar_presence   | information on Sun's presence (str)           |
           +------------------+-----------------------------------------------+
           | lunar_presence   | information on Moon's presence (str)          |
           +------------------+-----------------------------------------------+
           | RA               | target RA (float, J2000.0)                    |
           +------------------+-----------------------------------------------+
           | DEC              | target DEC (float, J2000.0)                   |
           +------------------+-----------------------------------------------+
           | RA_rate          | target rate RA (float, arcsec/s)              |
           +------------------+-----------------------------------------------+
           | DEC_rate         | target RA (float, arcsec/s, includes cos(DEC))|
           +------------------+-----------------------------------------------+
           | AZ               | Azimuth meas East(90) of North(0) (float, deg)|
           +------------------+-----------------------------------------------+
           | EL               | Elevation (float, deg)                        |
           +------------------+-----------------------------------------------+
           | airmass          | target optical airmass (float)                |
           +------------------+-----------------------------------------------+
           | magextinct       | V-mag extinction due airmass (float, mag)     |
           +------------------+-----------------------------------------------+
           | V                | V magnitude (comets: total mag) (float, mag)  |
           +------------------+-----------------------------------------------+
           | illumination     | fraction of illuminated disk (float)          |
           +------------------+-----------------------------------------------+
           | EclLon           | heliocentr. ecl. long. (float, deg, J2000.0)  |
           +------------------+-----------------------------------------------+
           | EclLat           | heliocentr. ecl. lat. (float, deg, J2000.0)   |
           +------------------+-----------------------------------------------+
           | ObsEclLon        | obscentr. ecl. long. (float, deg, J2000.0)    |
           +------------------+-----------------------------------------------+
           | ObsEclLat        | obscentr. ecl. lat. (float, deg, J2000.0)     |
           +------------------+-----------------------------------------------+
           | r                | heliocentric distance (float, au)             |
           +------------------+-----------------------------------------------+
           | r_rate           | heliocentric radial rate  (float, km/s)       |
           +------------------+-----------------------------------------------+
           | delta            | distance from the observer (float, au)        |
           +------------------+-----------------------------------------------+
           | delta_rate       | obs-centric radial rate (float, km/s)         |
           +------------------+-----------------------------------------------+
           | lighttime        | one-way light time (float, s)                 |
           +------------------+-----------------------------------------------+
           | elong            | solar elongation (float, deg)                 |
           +------------------+-----------------------------------------------+
           | elongFlag        | app. position relative to Sun (str)           |
           +------------------+-----------------------------------------------+
           | alpha            | solar phase angle (float, deg)                |
           +------------------+-----------------------------------------------+
           | sunTargetPA      | PA of Sun->target vector (float, deg, EoN)    |
           +------------------+-----------------------------------------------+
           | velocityPA       | PA of velocity vector (float, deg, EoN)       |
           +------------------+-----------------------------------------------+
           | GlxLon           | galactic longitude (float, deg)               |
           +------------------+-----------------------------------------------+
           | GlxLat           | galactic latitude  (float, deg)               |
           +------------------+-----------------------------------------------+
           | RA_3sigma        | 3sigma pos. unc. in RA (float, arcsec)        |
           +------------------+-----------------------------------------------+
           | DEC_3sigma       | 3sigma pos. unc. in DEC (float, arcsec)       |
           +------------------+-----------------------------------------------+

            %}
            switch nargin
                case 1
                    observatory_code=399;% earth center
                    airmass_lessthan=99;
                    solar_elongation=[0,180];
                    skip_daylight=0;
                case 2
                    airmass_lessthan=99;
                    solar_elongation=[0,180];
                    skip_daylight=0;
                case 3
                    solar_elongation=[0,180];
                    skip_daylight=0;
                case 4
                    skip_daylight=0;
            end
            % queried fields (see HORIZONS website for details)
            % if fields are added here, also update the field identification below
            quantities = '1,3,4,8,9,10,18,19,20,21,23,24,27,31,33,36';
            % encode objectname for use in URL
            objectname = self.targetname;
            if ischar(observatory_code)
            else
                observatory_code=int2str(observatory_code);
            end
            tmpurl=strcat('http://ssd.jpl.nasa.gov/horizons_batch.cgi?batch=l',...
                '&TABLE_TYPE=''OBSERVER''','&QUANTITIES=''',quantities,'''',...
            '&CSV_FORMAT=''YES''','&ANG_FORMAT=''DEG''','&CAL_FORMAT=''BOTH''',...
            '&SOLAR_ELONG=''',sprintf('%d,%d''',solar_elongation),...
            sprintf('&CENTER=''%s''&COMMAND=''%s''',observatory_code,objectname));
            if ~isnan(self.discreteepochs)
                tmpurl=strcat(tmpurl,'&TLIST=');
                for k=1:length(self.discreteepochs)
                    tmpurl=strcat(tmpurl,sprintf('''%f''',self.discreteepochs(k)));
                end
            elseif ~(isempty(self.start_epoch)||isempty(self.stop_epoch)||isempty(self.step_size))
                tmpurl=strcat(tmpurl,sprintf('&START_TIME=''%s''&STOP_TIME=''%s''&STEP_SIZE=''%s''',...
                    self.start_epoch,self.stop_epoch,self.step_size));
            else
                error('no epoch information');
            end
            tmpurl=strcat(tmpurl,sprintf('&AIRMASS=''%d''',min(airmass_lessthan,99)));
            if skip_daylight
                tmpurl=strcat(tmpurl,'&SKIP_DAYLT=''YES''');
            else
                tmpurl=strcat(tmpurl,'&SKIP_DAYLT=''NO''');
            end
            self.url=tmpurl;
         %   disp(self.url);
            src=urlread(self.url);
           
            % get website source and resolve it into data
            % get H and G
            if isempty(regexp(src,' H= ','ONCE','start'))
                H=nan;G=nan;
            else
                H=str2double(src(regexp(src,' H= ','end','ONCE'):regexp(src,' G= ','start','ONCE')));
                G=str2double(src(regexp(src,' G= ','end','ONCE'):regexp(src,' B-V= ','start','ONCE')));
            end
            self.physical.H=H;
            self.physical.G=G;
            self.originSrc=src;
            % get target name 
             if ~isempty(regexp(src,'Multiple major-bodies match string|No matches found','ONCE'))
                error('Ambiguous target name; check URL: %s' ,self.url);
            end
            if ~isempty(regexp(src,'Matching small-bodies|No matches found','ONCE'))
                error('Ambiguous target name; check URL: %s' ,self.url);
            end
            if ~isempty(regexp(src,'ERROR','ONCE'))
                error('%s' ,src);
            end
            pos1=regexp(src,'Target body name: ','end','ONCE')+1;
            pos2=pos1+regexp(src(pos1:pos1+38),'  ','start','ONCE')-2;
            self.official_name=src(pos1:pos2);
            % not support multiple bodies
           
            % get header 
         %   pos3=regexp(src,'Date...UT...HR.MN','ONCE');
           % C=textscan(src(pos3:end),'%s',33,'Delimiter',',');
          %  fieldnames=C{1};
            fieldnames={'datetime','datetime_jd','solar_presence','lunar_presence',...
              'RA','DEC','RA_rate','DEC_rate','AZ','EL','airmass','magextinct','V',...
             'S_brt', 'illumination','EclLon','EclLat','r','r_rate','delta','delta_rate',...
             'lighttime','SOT','relativeSun','STO','sunTargetPA','velocityPA','ObsEclLon',...
             'ObsEclLat','GlxLon','GlxLat','RA_3sigma','DEC_3sigma'};
            % get ephemrides
            pos4=regexp(src,'\$\$SOE\n','ONCE','end');
            pos5=regexp(src,'\n\$\$EOE','ONCE','start');
            pattern=['%s%f%s%s',repmat('%f',[1,6]),'%s%s',repmat('%f',[1,11]),'%s',repmat('%f',[1,9])];
            C=textscan(src(pos4:pos5),pattern,'Delimiter',',');
            self.data=table(C{1:end},'VariableNames',fieldnames);
           
        end
    end
    
    
    
end

