classdef query
    properties
        targetname
        not_smallbody=1;
        cap=1;
        start_epoch
        stop_epoch
        step_size
        discreteepochs
        url
        data
    end
    
    methods % constructor 
        function self = query(targetname,smallbody,cap)
            %{
        Initialize query to Horizons
        Parameters
        ----------
        targetname         : str
           HORIZONS-readable target number, name, or designation
        smallbody          : boolean
           use ``smallbody=0`` if targetname is a planet or spacecraft (optional, default: True)
        cal                : boolean
           set to `True` to return the current apparition for comet targets.
        Results
        self
            %}
            if nargin==1
                self.not_smallbody=1;
                self.cap=1;
            else
                self.not_smallbody= ~smallbody;
                self.cap            = cap;
            end
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
        >>> import callhorizons
        >>> ceres = callhorizons.query('Ceres')
        >>> ceres.set_epochrange('2016-02-26', '2016-10-25', '1d')
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
           list of floats or strings, maximum length: 15
        Returns
        -------
        None
        
        Examples
        --------
        >>> import callhorizons
        >>> ceres = callhorizons.query('Ceres')
        >>> ceres.set_discreteepochs([2457446.177083, 2457446.182343])
        
        If more than 15 epochs are provided, the list will be cropped to 15 epochs.
        %}
        self.discreteepochs = discreteepochs;
        end
    end
    properties (Dependent)
        fields
        dates
        queryUrl
        dates_jd
    end
    methods
        function tt=get.fields(self)
            % returns list of available properties for all epochs
            try
                tt=self.data.dtype.names;
            catch
                tt=[];
            end
        end
        function tt=ephochNo(self)
            % returns total number of epochs that have been queried
            try
                tt=int(self.data.shape(1));
            catch
                tt=0;
            end
        end
        function tt=get.dates(self)
            % returns list of epochs that have been queried (format 'YYYY-MM-DD HH-MM-SS')
            try
                tt=self.data('datetime');
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
                tt=self.data('datetime_jd');
            catch
                tt=[];
            end
        end
        function tt=briefInfo(self)
            %returns brief query information
            tt=sprintf('<callhorizons.query object: %s>',self.targetname);
        end
        function tt=getitem(self,key)
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
            if isnan(self.data)||isempty(self.data)
                disp('CALLHORIZONS ERROR: run get_ephemerides or get_elements first');
                tt=nan;
            else
                tt=self.data(key);
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
        
        Results
        -------
        number of epochs queried
        
        Examples
        --------
        >>> ceres = callhorizons.query('Ceres')
        >>> ceres.set_epochrange('2016-02-23 00:00', '2016-02-24 00:00', '1h')
        >>> print (ceres.get_ephemerides(568), 'epochs queried')

        The queried properties and their definitions are:
           +------------------+-----------------------------------------------+
           | Property         | Definition                                    |
           +==================+===============================================+
           | targetname       | official number, name, designation [string]   |
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
            
            tmpurl=strcat('http://ssd.jpl.nasa.gov/horizons_batch.cgi?batch=l',...
                '&TABLE_TYPE=''OBSERVER''','&QUANTITIES=''',quantities,'''',...
            '&CSV_FORMAT=''YES''','&ANG_FORMAT=''DEG''','&CAL_FORMAT=''BOTH''',...
            '&SOLAR_ELONG=''',sprintf('%d,%d',solar_elongation),...
            sprintf('%s%d''','&CENTER=''',observatory_code),'&COMMAND=',objectname);
            if ~isnan(self.discreteepochs)
                tmpurl=strcat(tmpurl,'&TLIST=');
                for k=1:length(self.discreteepochs)
                    tmpurl=strcat(tmpurl,sprintf('''%s''',self.discreteepochs(k)));
                end
            elseif ~(isnan(self.start_epoch)||isnan(self.stop_epoch)||isnan(self.step_size))
                tmpurl=strcat(tmpurl,sprintf('&START_TIME=''%s''&STOP_TIME=''%s''&STEP_SIZE=''%s''',...
                    self.start_epoch,self.stop_epoch,self.step_size));
            else
                error('no epoch information');
            end
            tmpurl=strcat(tmpurl,sprintf('&AIRMASS=%d''',min(airmass_lessthan,99)));
            if skip_daylight
                tmpurl=strcat(tmpurl,'&SKIP_DAYLT=''YES''');
            else
                tmpurl=strcat(tmpurl,'&SKIP_DAYLT=''NO''');
            end
            self.url=tmpurl;
            disp(self.url);
        end
    end
    
    
    
end

