classdef dwiMRI_Session  < dynamicprops & matlab.mixin.SetGet
    %%% Written by: 
    %%%             Rodrigo Perea (rpereacamargo@mgh.harvard.edu)
    %%%             Aaron Schultz (aschultz@martinos.org) 
    %  Github (code also in here)
    %      Dependencies (and tested in):
    %          -FreeSurfer v6.0
    %          -SPM12
    %          -Ants tools 
    %          -DSI_studio_vMarch_2017
    %          -FSL 5.0.9
    %
    %%
    
    
    properties
        %NOT SURE IF ALL THESE PROPERTIES ARE NECESSARY TO INITIALIZE...
        T1 = '' ;
        sessionname = '';
        object_dir = ''; 
        session_location = ''; %Will be replace with session_dir
        session_dir = ''; %This should reaplce session_location
        dcm_location= '' ;
        gradfile = ''; 
        dependencies_dir = ''; 
        projectID='';
        FS_location = '';
        FSL_dir = '' ; 
        init_FS = '';

        fx_template_dir='';
        sh_gradfile = '';
        b0MoCo_rotate_bvecs_sh = '';
        init_rotate_bvecs_sh = '';
        col2rows_sh = '';
        redo_history = false ; 
        
        rawfiles = '';
        root=''; %to be modified if specified as an argument.
        dosave = false;
        wasLoaded = false;
        rawstructural = '';
        
        %HAB_1 Class Related:
        vox = [];
        dsistudio_version = '';
        HABn272_meanFA = '';
        HABn272_meanFA_skel_dst = '';
        ref_region = '';
        dctl_flag = false
        skeltoi_location = ''; 
        skeltoi_tois =  ''; 
        %%% Change things so that these are the only version used.
        fsdir = '';
        fsubj = '';
        FSdata='';
        objectHome = '';
        history=[] ; 
        pth = [];
        dbentry = [];
        Params = [];
        Trkland = [] ;
    end
    properties (GetAccess=private)
        %%% For properties that cannot be accessed or changed from outside
        %%% the class.
        %test = '12345';
    end
    properties (Constant)
        %%% For setting properties that never change.
    end
    properties (Dependent)
        %%% For setting properties that get automatically updated when
        %%% other variables change
    end
    
    %Pre- processing public methods (and MISC):
    methods
        
        %Constructor:
        function obj=dwiMRI_Session()
            setDefaultParams(obj);
        end
        
        %MISC Methods:
        function showUnpackedData(obj)
            try
                type([obj.session_location filesep 'LogFiles' filesep 'config']);
            catch
                disp('config file was not found');
            end
        end
             
        function showHistory(obj)
            disp('');
            disp('HISTORY:');
            for ii = 1:numel(obj.history)
                disp([sprintf('%0.3i',ii) '  ' regexprep(obj.history{ii}.lastRun,'\n','')]);
            end
            disp('');
        end
        
        function obj = getPaths(obj,proj)
            obj.pth = MyPaths(proj);
        end
        
        function obj = setDefaultParams(obj)
            %THIS METHODS IS OBSOLETE BASED ON THE DYNAMIC INITIALIZATION I
            %GIVEN TO MY METHODS TO INITIALIZE PARAMETERS
            for tohide=1:1
                %             %TO DOs:
                %             % 1. Initialization  of Parameters was stopped after
                %             %    proc_FS2DWI(). This is something that needs to be revisited to
                %             %    init other properties (2/13/18).
                %
                %             %%%%%%%PARAMETERS SET BASED ON EACH STEP OF THE DWI PIPELINE%%%
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             %For proc_dcm2nii:
                %             obj.Params.DCM2NII.in.first_dcmfiles = [];
                %             obj.Params.DCM2NII.scanlog = '';
                %             obj.Params.DCM2NII.seq_names='';
                %             obj.Params.DCM2NII.specific_vols = [];
                %             obj.Params.DCM2NII.in.nvols = [];
                %             obj.Params.DCM2NII.in.fsl2std_matfile = '';
                %             obj.Params.DCM2NII.in.fsl2std_param = '';
                %
                %             obj.Params.DCM2NII.out.location = [];
                %             obj.Params.DCM2NII.out.fn = [];
                %             obj.Params.DCM2NII.out.bvecs='';
                %             obj.Params.DCM2NII.out.bvals='';
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             obj.Params.DropVols.in.tmin = ''; %char type as they will be called in system('')
                %             obj.Params.DropVols.in.tsize = '';
                %             obj.Params.DropVols.in.prefix = 'dv_';
                %             obj.Params.DropVols.in.movefiles = '';
                %             obj.Params.DropVols.in.fn = [];
                %             obj.Params.DropVols.out.fn = [];
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             obj.Params.GradNonlinCorrect.in.movefiles = '';
                %             obj.Params.GradNonlinCorrect.in.prefix = 'gnc_';
                %             obj.Params.GradNonlinCorrect.in.gradfile = '';
                %             obj.Params.GradNonlinCorrect.in.fn = '';
                %             obj.Params.GradNonlinCorrect.out.b0='';
                %             obj.Params.GradNonlinCorrect.in.fn = '';
                %             obj.Params.GradNonlinCorrect.in.fslroi= [0 1];
                %             obj.Params.GradNonlinCorrect.out.b0='';
                %             obj.Params.GradNonlinCorrect.out.warpfile = [];
                %             obj.Params.GradNonlinCorrect.out.fn = [];
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             obj.Params.B0MoCo.FS = '';
                %             obj.Params.B0MoCo.in.movefiles = '';
                %             obj.Params.B0MoCo.in.prefix = 'moco_';
                %             obj.Params.B0MoCo.in.nDoF = '12' ;
                %             obj.Params.B0MoCo.in.sh_rotate_bvecs = '';
                %
                %             obj.Params.B0MoCo.in.fn = '';
                %             obj.Params.B0MoCo.in.bvals = '';
                %             obj.Params.B0MoCo.in.bvecs = '';
                %
                %             obj.Params.B0MoCo.out.fn = '';
                %             obj.Params.B0MoCo.out.bvals = '';
                %             obj.Params.B0MoCo.out.bvecs = '';
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             obj.Params.Bet2.in.movefiles = '';
                %             obj.Params.Bet2.in.fracthrsh = [];
                %             obj.Params.Bet2.in.prefix = 'bet2_';
                %             obj.Params.Bet2.in.fn = '';
                %             obj.Params.Bet2.out.mask = '';
                %             obj.Params.Bet2.out.skull = '';
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             obj.Params.Eddy.in.movefiles = '';
                %             obj.Params.Eddy.in.prefix = 'eddy_';
                %             obj.Params.Eddy.in.fn = '';
                %             obj.Params.Eddy.in.mask = '';
                %             obj.Params.Eddy.in.index= [];
                %             obj.Params.Eddy.in.acqp= [];
                %             obj.Params.Eddy.in.bvals='';
                %             obj.Params.Eddy.in.bvecs='';
                %
                %             obj.Params.Eddy.out.fn = '';
                %             obj.Params.Eddy.out.bvecs = '';
                %             obj.Params.Eddy.out.fn_acqp='';
                %             obj.Params.Eddy.out.fn_index='';
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             obj.Params.EddyMotion.in.fn_eddy = '';
                %             obj.Params.EddyMotion.in.fn_motion = '';
                %
                %             obj.Params.EddyMotion.out.fn_motion = '';
                %             obj.Params.EddyMotion.out.vals.initb0_mean = [];
                %             obj.Params.EddyMotion.out.vals.initb0_std = [];
                %             obj.Params.EddyMotion.out.vals.rel_mean = [];
                %             obj.Params.EddyMotion.out.vals.rel_std = [];
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             obj.Params.B0mean.in.movefiles = '';
                %             obj.Params.B0mean.in.fn='';
                %             obj.Params.B0mean.in.b0_nvols=[];
                %             obj.Params.B0mean.out.fn='';
                %             obj.Params.B0mean.out.allb0s='';
                %
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             obj.Params.MaskAfterEddy.in.movefiles = '';
                %             obj.Params.MaskAfterEddy.in.fn = '';
                %             obj.Params.MaskAfterEddy.in.prefix = '';
                %             obj.Params.MaskAfterEddy.in.b0 = '';
                %             obj.Params.MaskAfterEddy.out.initmask = '';
                %             obj.Params.MaskAfterEddy.out.finalmask = ''; %Corrected for inconsistent brain edges value on dtifit after using the option --wls
                %             obj.Params.MaskAfterEddy.out.brainonly = '';
                %             obj.Params.MaskAfterEddy.in.fracthrsh = '0.4';
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %
                %             obj.Params.CoRegMultiple.in.fn = '' ;
                %             obj.Params.CoRegMultiple.in.b0 = '' ;
                %             obj.Params.CoRegMultiple.in.bvals = '' ;
                %             obj.Params.CoRegMultiple.in.bvecs = '' ;
                %             obj.Params.CoRegMultiple.in.movefiles = '' ;
                %             obj.Params.CoRegMultiple.in.ref_iteration = [] ; % All images will be registered to this iteration (in ADRC, 7p5_set1, index 1 is for 2p7_set4!)
                %             obj.Params.CoRegMultiple.in.ref_prefix = '' ;
                %             obj.Params.CoRegMultiple.in.ref_file = '' ;
                %
                %             obj.Params.CoRegMultiple.out.fn = '' ;
                %             obj.Params.CoRegMultiple.out.bvals = '' ;
                %             obj.Params.CoRegMultiple.out.bvecs = '' ;
                %             obj.Params.CoRegMultiple.out.matfile = '' ;
                %             obj.Params.CoRegMultiple.out.combined_fn = '' ;
                %             obj.Params.CoRegMultiple.out.combined_bvals = '' ;
                %             obj.Params.CoRegMultiple.out.combined_bvecs = '' ;
                %             obj.Params.CoRegMultiple.out.combined_b0 = '' ;
                %             obj.Params.CoRegMultiple.out.combined_bet = '' ;
                %             obj.Params.CoRegMultiple.out.combined_mask = '' ;
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             obj.Params.Dtifit.in.movefiles = '';
                %             obj.Params.Dtifit.in.fn='';
                %             obj.Params.Dtifit.in.bvecs='';
                %             obj.Params.Dtifit.in.bvals='';
                %             obj.Params.Dtifit.in.mask='';
                %             obj.Params.Dtifit.in.prefix = '' ;
                %             obj.Params.Dtifit.out.prefix='';
                %             obj.Params.Dtifit.out.FA='';
                %             obj.Params.Dtifit.out.RD = '';
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             obj.Params.GQI.in.movefiles = '';
                %             obj.Params.GQI.in.prefix = '' ;
                %             obj.Params.GQI.in.fn = '' ;
                %             obj.Params.GQI.in.bvecs = '';
                %             obj.Params.GQI.in.bvals = '';
                %             obj.Params.GQI.in.mask = '' ;
                %
                %             obj.Params.GQI.in.method = '4'; %for gqi
                %             obj.Params.GQI.in.num_fiber = '3';  %modeling 3 fiber population
                %             obj.Params.GQI.in.param0 = '1.25';
                %
                %
                %             obj.Params.GQI.out.btable = '';
                %             obj.Params.GQI.out.src_fn = '';
                %             obj.Params.GQI.out.fibs_fn = '' ;
                %             obj.Params.GQI.out.fibs_GFA = '';
                %             obj.Params.GQI.out.export =   'gfa,nqa0,nqa1';
                %
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             obj.Params.AntsReg.in.movefiles = '';
                %             obj.Params.AntsReg.in.fn = '';
                %             obj.Params.AntsReg.in.ref = '';
                %             obj.Params.AntsReg.in.dim = '3' ;
                %             obj.Params.AntsReg.in.threads = '1' ;
                %             obj.Params.AntsReg.in.transform = 's' ;
                %             obj.Params.AntsReg.in.radius = '4' ;
                %             obj.Params.AntsReg.in.precision = 'd' ;
                %             obj.Params.AntsReg.in.prefix = '';
                %             obj.Params.AntsReg.out.fn = '';
                %             obj.Params.AntsReg.out.FA = '';
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             obj.Params.FROIS2dwi.in.dim = '3';
                %             obj.Params.FROIS2dwi.in.threads = '1';
                %             obj.Params.FROIS2dwi.in.transform = 's';
                %             obj.Params.FROIS2dwi.in.radius = '4';
                %             obj.Params.FROIS2dwi.in.precision = 'd' ;
                %             obj.Params.FROIS2dwi.in.ref  = '';
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             obj.Params.Skeletonize.in.movefiles = '';
                %             obj.Params.Skeletonize.in.fn = '' ;
                %             obj.Params.Skeletonize.in.meanFA = '';
                %             obj.Params.Skeletonize.in.skel_dst = '';
                %             obj.Params.Skeletonize.in.thr = '0.3';
                %             obj.Params.Skeletonize.in.ref_region = '';
                %             obj.Params.Skeletonize.in.prefix = [ obj.sessionname '_skel' ] ;
                %             obj.Params.Skeletonize.out.fn = '' ;
                %             obj.Params.Skeletonize.in.FA= '' ;
                %             obj.Params.Skeletonize.out.FA = '' ;
                %             obj.Params.Skeletonize.out.diffmetrics={ 'FA' 'RD' 'AxD' 'MD' } ;
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             obj.Params.Skel_TOI.in.location = '' ;
                %             obj.Params.Skel_TOI.in.masks = '' ;
                %             obj.Params.Skel_TOI.in.ext = '.nii.gz' ;
                %             obj.Params.Skel_TOI.out = [] ; %this should be populated with all the masked TOIs
                %             obj.Params.Skel_TOI.in.suffix = '';
                %
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %
                %             obj.Params.FreeSurfer.dir = '' ;
                %             obj.Params.FreeSurfer.in.T1 = '' ;
                %             obj.Params.FreeSurfer.in.T2 = '' ;
                %             obj.Params.FreeSurfer.in.T2exist = false ;
                %
                %             obj.Params.FreeSurfer.out.aparcaseg = '' ;
                %             obj.Params.FreeSurfer.init_location = '';
                %
                %
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             obj.Params.FS2dwi.in.movefiles = '';
                %             obj.Params.FS2dwi.in.b0 = '' ;
                %             obj.Params.FS2dwi.in.aparcaseg = '' ;
                %             obj.Params.FS2dwi.in.tmpfile_aparcaseg = '' ;
                %             obj.Params.FS2dwi.in.aparcaseg2009 = '' ;
                %             obj.Params.FS2dwi.in.tmpfile_aparcaseg2009 = '' ;
                %             obj.Params.FS2dwi.in.hippofield_left = '' ;
                %             obj.Params.FS2dwi.in.hippofield_right = '' ;
                %             obj.Params.FS2dwi.in.tmpfile_hippo = '' ;
                %
                %             obj.Params.FS2dwi.out.xfm_dwi2FS = '' ;
                %             obj.Params.FS2dwi.out.fn_aparc = '';
                %             obj.Params.FS2dwi.out.fn_aparc2009 = '';
            end
        end
        
        %%%%%%%%%%%%%%%%%% BEGIN Pre- Processing Methods %%%%%%%%%%%%%%%%%%
        %This functino should be only used in the older Unpack data script.
        %If NewUnpack.m is used, do not expect to call this method. 
        function obj = proc_dcm2nii(obj,~,dest,out_filename)
            fprintf('\n\n%s\n', ['PROC_DCM2NII(): MOVING RAW NIIs TO ORIG FOLDER (Total:  ' num2str(numel(obj.Params.DCM2NII.in)) ' volumes)']);
            % Initializing exec_cmd (variable to store all cmds
            if ~exist('exec_cmd','var')
                exec_cmd{:}='#INIT proc_dcm2nii()';
            end
            %Checking if module is complete
            wasRun = false;
            
            %Re-define newUnpack=false if it doesnt exist:
            if ~isfield(obj.Params.DCM2NII,'newUnpack')
                obj.Params.DCM2NII.newUnpack=false;
            end
            
            for ii=1:numel(obj.Params.DCM2NII.in)
                if nargin>2 && ~isempty(dest)
                    obj.Params.DCM2NII.out(ii).location = dest;
                end
                
                if nargin>3 && ~isempty(out_filename)
                    if numel(obj.Params.DCM2NII.in) ~= numel(out_filename)
                        error('out_filenames should have the same size (same # of file nameS) as the input DCMs');
                    else
                        obj.Params.DCM2NII.out(ii).fn = out_filename;
                    end
                end
                
                %Shortening naming comventions:
                clear in_file out_file
                %Check whether first_dcmfiles exist . If not (then newer
                %unpack is given) so select the *.nii as infile:
                if obj.Params.DCM2NII.newUnpack
                    %NEWER UNPACK DEFINITION:
                    if strcmp(obj.projectID,'ADRC')
                        [~, in_file]   = system(['ls ' obj.Params.DCM2NII.rawDiff '*' obj.Params.DCM2NII.seq_names{ii} '*.nii.gz']);
                        in_file=strtrim(in_file);
                        [~, in_bvecs]   = system(['ls ' obj.Params.DCM2NII.rawDiff '*' obj.Params.DCM2NII.seq_names{ii} '*.bvecs']);
                        in_bvecs=strtrim(in_bvecs);
                        [~, in_bvals]   = system(['ls ' obj.Params.DCM2NII.rawDiff '*' obj.Params.DCM2NII.seq_names{ii} '*.bvals']);
                        in_bvals=strtrim(in_bvals);
                    elseif strcmp(obj.projectID,'HAB')
                        [~, in_file]   = system(['ls ' obj.Params.DCM2NII.rawDiff '*.nii']);
                        in_file=strtrim(in_file);
                        [~, in_bvecs]   = system(['ls ' obj.Params.DCM2NII.rawDiff '*.bvecs']);
                        in_bvecs=strtrim(in_bvecs);
                        [~, in_bvals]   = system(['ls ' obj.Params.DCM2NII.rawDiff '*.bvals']);
                        in_bvals=strtrim(in_bvals);
                    end
                    %Double check that the files exist:
                    if exist(in_file,'file') ~= 2; error(['proc_dcm2nii(): Cannot find in_file: ' in_file ]); end
                    if exist(in_bvecs,'file') ~= 2; error(['proc_dcm2nii(): Cannot find in_bvecs: ' in_bvecs ]); end
                    if exist(in_bvals,'file') ~= 2; error(['proc_dcm2nii(): Cannot find in_bvals: ' in_bvals ]); end
                else
                    %OLD UNPACK DEFINITION:
                    in_file   = strtrim([obj.dcm_location filesep obj.Params.DCM2NII.in(ii).first_dcmfiles]);
                end
                out_file  = obj.Params.DCM2NII.out(ii).fn;
                outpath   = obj.Params.DCM2NII.out(ii).location;
                
                obj.Params.DCM2NII.in(ii).fsl2std_matfile = [outpath 'fsl2std.matfile'];
                obj.Params.DCM2NII.out(ii).bvecs=strrep(obj.Params.DCM2NII.out(ii).fn,'.nii.gz','.voxel_space.bvecs');
                obj.Params.DCM2NII.out(ii).bvals=strrep(obj.Params.DCM2NII.out(ii).fn,'.nii.gz','.bvals');
                
                %Create out_file directory if doesnt exist:
                if exist(obj.Params.DCM2NII.out(ii).location,'dir') == 0 
                    exec_cmd{:,end+1} = ['mkdir -p ' obj.Params.DCM2NII.out(ii).location ];
                    obj.RunBash(exec_cmd{end});
                    wasRun = true;
                end
                
                
                %%%PROCESSING STARTS HERE
                if exist(out_file,'file') == 0 %check if out_file exists
                    %Check whether we get the CORRECT number of volumes:
                    if  obj.Params.DCM2NII.specific_vols == obj.Params.DCM2NII.in(ii).nvols;
                        %NEWER UNPACK:
                        if  obj.Params.DCM2NII.newUnpack
                            %Copying the files...
                            exec_cmd{:,end+1}=['mri_convert ' in_file ' ' out_file ];
                            fprintf(['\nCopying in_file: ' in_file ' to Orig/ ...']);
                            obj.RunBash(exec_cmd{end},44); fprintf('done');
                            %Bvecs:
                            exec_cmd{:,end+1}=['cp ' in_bvecs ' ' obj.Params.DCM2NII.out(ii).bvecs ];
                            fprintf(['\nCopying in_file: ' in_bvecs ' to Orig/ ...']);
                            obj.RunBash(exec_cmd{end},44); fprintf('done');
                            %Bvals:
                            exec_cmd{:,end+1}=['cp ' in_bvals ' ' obj.Params.DCM2NII.out(ii).bvals ];
                            fprintf(['\nCopying in_file: ' in_bvals ' to Orig/ ...']);
                            obj.RunBash(exec_cmd{end},44); fprintf('done');
                            
                            %OLDER UNPACK:
                        else
                            exec_cmd{:,end+1}=['mri_convert ' in_file ' ' out_file ];
                            obj.RunBash(exec_cmd{end},44);
                        end
                        fprintf('\nFslreorienting to standard...');
                        %Reorient to std that nii files -->
                        exec_cmd{:,end+1}=['fslreorient2std ' out_file ' ' out_file ];
                        obj.RunBash(exec_cmd{end}); fprintf('done\n');
                        %%%
                        
                        %Reorient to std the bvecs -->
                        if isempty(obj.Params.DCM2NII.in(ii).fsl2std_param) %due to inconsitencies with bvecs from mri_convert, this should be initialize in the child class
                            exec_cmd{:,end+1}=['fslreorient2std ' out_file ' > ' obj.Params.DCM2NII.in(ii).fsl2std_matfile ];
                            obj.RunBash(exec_cmd{end});
                        else
                            fprintf(['Rotating the dwi sequence based on the provided matfile: ' obj.Params.DCM2NII.in(ii).fsl2std_matfile '...']);
                            exec_cmd{:,end+1}=[' printf '' ' obj.Params.DCM2NII.in(ii).fsl2std_param  ''' > '  obj.Params.DCM2NII.in(ii).fsl2std_matfile ];
                            obj.RunBash(exec_cmd{end});
                            fprintf('done\n');
                        end
                        %%%
                        
                        %Now dealing with bvecs:
                        disp('Fslreorienting the bvecs now...')
                        temp_bvec=[outpath 'temp.bvec' ];
                        exec_cmd{:,end+1}=[obj.init_rotate_bvecs_sh ' ' ...
                            ' ' obj.Params.DCM2NII.out(ii).bvecs ...
                            ' ' obj.Params.DCM2NII.in(ii).fsl2std_matfile ...
                            ' ' temp_bvec  ];
                        obj.RunBash(exec_cmd{end});
                        
                        exec_cmd{:,end+1}=['mv ' temp_bvec ' ' obj.Params.DCM2NII.out(ii).bvecs ];
                        obj.RunBash(exec_cmd{end});
                        wasRun = true;
                        fprintf('\n....done');
                    else
                        if isfield( obj.Params.DCM2NII.in,'prefix')
                            err_prefix=obj.Params.DCM2NII.in(ii).prefix;
                        else
                            err_prefix='-no prefix in this project -';
                        end
                        display(['In prefix: ' err_prefix '...']);
                        display(['==> obj.Params.DCM2NII.specific_vols (' num2str(obj.Params.DCM2NII.specific_vols) ')'...
                            ' not equal to obj.Params.DCM2NII.in(ii).nvols (' num2str(obj.Params.DCM2NII.in(ii).nvols)  ')']);
                        
                        fprintf('    You should double check this information in the logbook. Stopping for now!\n\n');
                        fprintf('NOTHING MORE TO DO...\n Throwing an error ~~>');
                        error('Exiting now...');
                        
                    end
                else
                    disp([ '==> out_file: ' out_file ' exists. SKIPPING...'])
                end
                %Create out_file directory if doesnt exist:
                if ~exist(obj.Params.DCM2NII.out(ii).location,'dir')
                    exec_cmd{:,end+1} = ['mkdir -p ' obj.Params.DCM2NII.out(ii).location ];
                    obj.RunBash(exec_cmd{end});
                    wasRun = true;
                end
            end
       
            %Check if something was run. If so, update history.
            if wasRun == true
                obj.UpdateHist_v2(obj.Params.DCM2NII,'proc_dcm2nii()',out_file,wasRun,exec_cmd');
                obj.resave();
            end
            %%%
            fprintf('\n');
        end
        
        function obj = proc_drop_vols(obj)
            fprintf('\n%s\n', 'PERFORMING PROC_DROP_VOLS():');
            wasRun=false;
            if ~exist('exec_cmd','var')
                exec_cmd{:}='#INIT PROC_DROP_VOLS()';
            end
            %Looping on every DWI image(if 1+ sequences are input)
            for ii=1:numel(obj.Params.DropVols.in.fn)
                clear cur_fn;
                if iscell(obj.Params.DropVols.in.fn{ii})
                    cur_fn=cell2char_rdp(obj.Params.DropVols.in.fn{ii});
                else
                    cur_fn=obj.Params.DropVols.in.fn{ii};
                end
                [a b c ] = fileparts(cur_fn);
                outpath=obj.getPath(a,obj.Params.DropVols.in.movefiles);
                clear outfile
                obj.Params.DropVols.out.fn{ii} = [ outpath obj.Params.DropVols.in.prefix  b c ];
                
                %Droppping volumes in the DWIs (niftii):
                if exist( obj.Params.DropVols.out.fn{ii},'file')==0 || obj.redo_history
                    fprintf(['\n Dropping volumes  (fslroi <input> <output> ' ...
                        obj.Params.DropVols.in.tmin ' ' obj.Params.DropVols.in.tsize  ') ...' ...
                        'Iteration: ' num2str(ii) ]);
                    exec_cmd{:,end+1} = [ 'fslroi ' obj.Params.DropVols.in.fn{ii} ...
                        ' ' obj.Params.DropVols.out.fn{ii}  ' ' obj.Params.DropVols.in.tmin ...
                        ' ' obj.Params.DropVols.in.tsize ];
                    obj.RunBash(exec_cmd{end});
                    fprintf('...done \n ');
                    wasRun=true;
                else
                    fprintf(['Dropping vols for: ' b c ' is complete. \n']) ;
                end
                %Droppping volumes in the DWIs (bvals):
                obj.Params.DropVols.in.bvals{ii}=strrep(obj.Params.DropVols.in.fn{ii},'.nii.gz','.bvals');
                obj.Params.DropVols.out.bvals{ii}=strrep(obj.Params.DropVols.out.fn{ii},'.nii.gz','.bvals');
                if exist( obj.Params.DropVols.out.bvals{ii},'file')==0  || obj.redo_history
                    exec_cmd{:,end+1}=(['sed 1,' obj.Params.DropVols.in.tmin 'd ' ...
                        obj.Params.DropVols.in.bvals{ii} ' > ' obj.Params.DropVols.out.bvals{ii} ]);
                    obj.RunBash(exec_cmd{end});
                end
                %Droppping volumes in the DWIs (bvecs):
                obj.Params.DropVols.in.bvecs{ii}=strrep(obj.Params.DropVols.in.fn{ii},'.nii.gz','.voxel_space.bvecs');
                obj.Params.DropVols.out.bvecs{ii}=strrep(obj.Params.DropVols.out.fn{ii},'.nii.gz','.voxel_space.bvecs');
                if exist(obj.Params.DropVols.out.bvecs{ii},'file')==0  || obj.redo_history
                    exec_cmd{:,end+1}=(['sed 1,' obj.Params.DropVols.in.tmin 'd ' ...
                        obj.Params.DropVols.in.bvecs{ii} ' > ' obj.Params.DropVols.out.bvecs{ii} ]);
                    obj.RunBash(exec_cmd{end});
                    wasRun=true;
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%OPTIONAL:%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Check if outfiles are in row format. If so, put them in col
            %format
            [a , b ] = size(obj.Params.DropVols.out.bvals);
            if a < b
                obj.Params.DropVols.out.bvals = obj.Params.DropVols.out.bvals';
            end
            [a , b ] = size(obj.Params.DropVols.out.bvecs);
            if a < b
                obj.Params.DropVols.out.bvecs = obj.Params.DropVols.out.bvecs';
            end
            %%%%%%%%%%%%%%%%%%END OF OPTIONAL%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if wasRun 
                obj.UpdateHist_v2(obj.Params.DropVols,'proc_drop_vols()', obj.Params.DropVols.out.fn{ii},wasRun,exec_cmd');
                obj.resave();
            end
        end
        
        function obj = proc_gradient_nonlin_correct(obj)
            fprintf('\n%s\n', 'PERFORMING PROC_GRADIENT_NONLIN_CORRECT():');
            wasRun = false;
            in_fn = obj.Params.GradNonlinCorrect.in.fn;
            if ~exist('exec_cmd','var')
                exec_cmd{:}='#INIT PROC_GNC()';
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %APPLYING GRADIENT_NON_LIN CORRECTION TO set4 and THEN EXPAND
            %IT TO ALL OTHER IMAGES
            %this will take set4 in ADRC data (shouldn;t affect it. Need to double-check!)
            [a b c ] = fileparts(in_fn{1});
            outpath=obj.getPath(a,obj.Params.GradNonlinCorrect.in.movefiles);
            
            %first extract the first b0s of the first alphabetical sequence (e.g. set4 in Connectome):
            obj.Params.GradNonlinCorrect.in.b0{1}=[outpath 'firstb0_' b c ];
            if exist(obj.Params.GradNonlinCorrect.in.b0{1},'file')==0 || obj.redo_history
                fprintf(['\nExtracting the first b0 of: ' obj.Params.GradNonlinCorrect.in.b0{1} ]);
                exec_cmd{:,end+1}=['fslroi ' in_fn{1} ' ' obj.Params.GradNonlinCorrect.in.b0{1} ...
                    ' ' num2str(obj.Params.GradNonlinCorrect.in.fslroi) ];
                obj.RunBash(exec_cmd{end});
                wasRun=true;
                fprintf('...done\n');
            end
            %now creating grad-nonlinearity in first_b0s:
            obj.Params.GradNonlinCorrect.out.b0{1}=[outpath 'gnc_firstb0_' b c ];
            first_b0_infile = obj.Params.GradNonlinCorrect.in.b0{1};
            first_b0_outfile = obj.Params.GradNonlinCorrect.out.b0{1};
            %gradfile = obj.Params.GradNonlinCorrect.in.gradfile;
            gradfile = obj.gradfile;
            
            %%% Compute the grdient nonlinearity correction or check if
            %%% file XXX_grad_reobj.RunBashl.nii.gz exists. 
            obj.Params.GradNonlinCorrect.out.warpfile{1} = strrep(first_b0_infile,'.nii','_deform_grad_rel.nii');
            if exist(obj.Params.GradNonlinCorrect.out.warpfile{1},'file')==0 || obj.redo_history
                exec_cmd{:,end+1}=['sh ' obj.sh_gradfile ' '  first_b0_infile ' ' first_b0_outfile ' ' gradfile ' '];
                obj.RunBash(exec_cmd{end},44);
                wasRun = true;
            else
                [~, bb, cc ] = fileparts(first_b0_outfile);
                fprintf([ 'The gnc file ' bb cc  ' is complete.\n'])
            end
            
            %%Apply the correction to the first_b0 or check for gnc_XXX
            %%file
            if exist(first_b0_outfile,'file')==0 || obj.redo_history
                exec_cmd{:,end+1}=['applywarp -i ' first_b0_infile ' -r ' first_b0_infile ...
                    ' -o ' first_b0_outfile ' -w ' obj.Params.GradNonlinCorrect.out.warpfile{1} ...
                    ' --interp=spline' ];
                fprintf(['\nGNC: Applying warp to first_b0_file: '  first_b0_infile]);
                obj.RunBash(exec_cmd{end});
                wasRun=true;
                fprintf('...done\n');
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %NOW APPLYING IT TO ALL DWI IMAGES:
            %%% Apply the correction to all the subsequent diffusion images.
            for ii=1:numel(in_fn)
                [a b c ] = fileparts(in_fn{ii});
                obj.Params.GradNonlinCorrect.out.fn{ii}=[ outpath 'gnc_' b c ];
                if exist(obj.Params.GradNonlinCorrect.out.fn{ii},'file')==0 || obj.redo_history
                    fprintf('\nGNC: Applying warp field to all the other images:\n');
                    fprintf(['~~~~> ' obj.Params.GradNonlinCorrect.out.fn{ii} '.']);
                    exec_cmd{:,end+1} = ['applywarp -i ' obj.Params.GradNonlinCorrect.in.fn{ii} ' -r ' first_b0_infile ...
                        ' -o ' obj.Params.GradNonlinCorrect.out.fn{ii} ' -w ' obj.Params.GradNonlinCorrect.out.warpfile{1} ' --interp=spline'];
                    obj.RunBash(exec_cmd{end});
                    fprintf('....done\n');
                    wasRun = true;
                end
            end
            
            %%%%%%%%%%%%%%%%  END OF OPTIONAL: %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Check if outfiles are in row format. If so, put them in col
            %format
            [a , b ] = size(obj.Params.GradNonlinCorrect.out.fn);
            if a < b
                obj.Params.GradNonlinCorrect.out.fn = obj.Params.GradNonlinCorrect.out.fn';
            end
            %%%%%%%%%%%%%%%%  END OF OPTIONAL  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if wasRun==true
                obj.UpdateHist_v2(obj.Params.GradNonlinCorrect,'proc_gradient_nonlin_correct()',obj.Params.GradNonlinCorrect.out.fn{ii},wasRun,exec_cmd');
                obj.resave();
            end
        end
    
        function obj = proc_b0s_MoCo(obj,refB0)
            %Motion Correction for interspersed b0s.
            wasRun=false;
            fprintf('\n%s\n', 'PERFORMING MOTION CORRECTION - PROC_B0S_MOCO():');
            if ~exist('exec_cmd')
                exec_cmd{:}='#INIT PROC_B0s_MOCO()';
            end
            %Align all images interpersed to the refB0 image. If not
            %outputted, then assigning the first one.
            %refB0 index starts at 1. so if first b0 is used
            %(vol0000.nii.gz), then refB0 should be '1' and not '0'
            if nargin < 2
                refB0=1;
                display('proc_b0S_MoCo(): No refB0 inputted. Assigning the first volume')
                pause(2)
            end
            
            %Iterate between B0s.
            for jj=1:numel(obj.Params.B0MoCo.in.fn)
                clear cur_fn;
                %INIT VARIABLES:
                if iscell(obj.Params.B0MoCo.in.fn{jj})
                    cur_fn=cell2char_rdp(obj.Params.B0MoCo.in.fn{jj});
                else
                    cur_fn=obj.Params.B0MoCo.in.fn{jj};
                end
                %Splitting the naming convention:
                [a b c ] = fileparts(cur_fn);
                %Creating an output directory:
                outpath=obj.getPath(a,obj.Params.B0MoCo.in.movefiles);
                %Initializing obj.Params.B0MoCo.out.XX:
                if strcmp(c,'.nii') %not gzipped
                    obj.Params.B0MoCo.out.fn{jj}= [ outpath obj.Params.B0MoCo.in.prefix b c '.gz' ] ;
                else
                    obj.Params.B0MoCo.out.fn{jj}= [ outpath obj.Params.B0MoCo.in.prefix b c ] ;
                end
                %Is the fname *.nii? or *.nii.gz
                if strcmp(c,'.nii')
                    obj.Params.B0MoCo.out.bvecs{jj}= [ outpath  obj.Params.B0MoCo.in.prefix strcat(b,'','.voxel_space.bvecs') ];
                    obj.Params.B0MoCo.out.bvals{jj}= [ outpath  obj.Params.B0MoCo.in.prefix strcat(b,'','.bvals') ];
                else
                    obj.Params.B0MoCo.out.bvecs{jj}= [ outpath  obj.Params.B0MoCo.in.prefix strrep(b,'.nii','.voxel_space.bvecs') ];
                    obj.Params.B0MoCo.out.bvals{jj}= [ outpath  obj.Params.B0MoCo.in.prefix strrep(b,'.nii','.bvals') ];
                end
                %%%%%%%%ENTRERING CODE IF OUTPUT DOESNT EXIST%%%%%%%%%%
                if exist(obj.Params.B0MoCo.out.fn{jj}, 'file') == 0 || obj.redo_history
                    %%%%%%%%STEP 1: SPLIT EACH DWI INTO MULTIPLE 3D VOLUMES
                    fprintf('\n\tSTEP1:SPLIT EACH DWI INTO MULTIPLE 3D VOLUMES...');
                    for tohide=1:1
                        %Splitting the current DWI:
                        clear tmp_fslsplit;
                        tmp_fslsplit=[ outpath 'tmp' filesep ...
                            'tmp_' strrep(b,'.nii','') filesep ];
                        if exist([tmp_fslsplit '0000.nii.gz' ],'file') == 0  || obj.redo_history
                            exec_cmd{end+1,:} = (['mkdir -p ' tmp_fslsplit ] );
                            obj.RunBash(exec_cmd{end});
                            exec_cmd{end+1,:}=([obj.FSL_dir  'bin/fslsplit ' obj.Params.B0MoCo.in.fn{jj} ...
                                ' ' tmp_fslsplit ' -t ']);
                            obj.RunBash(exec_cmd{end});
                        end
                    end
                    fprintf('DONE \n'); pause(0.25);
                    %%%%%%%%
                    
                    
                    %%%%%%%%STEP2:CHECKING FOR THE REF B0 TO BE USED
                    fprintf('\n\tSTEP2:CHECKING FOR REF B0 TO BE USED...');
                    for tohide=1:1
                        %Load bval information:
                        clear tmp_bval_idx b0idx
                        tmp_bval_idx=load(obj.Params.B0MoCo.in.bvals{jj});
                        b0idx=0; %Indexing each location of a b0 image
                        %PADDING NAMING STRUCTURE AND FINDINF refB0:
                        clear refB0_fname  refB0_index bn_refB0
                        for ii=1:numel(tmp_bval_idx)
                            dwi_idx=ii-1  ; %indexing from fslsplit starts at 0 not 1 so we need this additional indexing (MATLAB array index starts at 1, so focus on it!)
                            %Get single dwi (indexed at 0000 or 0010)
                            if ii < 11 % (idx start at 1 in matlab but fslsplit idx starts at 0, hence the difference!!
                                cur_in_dwi{ii} = [ tmp_fslsplit '000' num2str(dwi_idx) '.nii.gz' ];
                            elseif ii < 101
                                cur_in_dwi{ii} = [ tmp_fslsplit '00' num2str(dwi_idx) '.nii.gz' ];
                            else
                                cur_in_dwi{ii} = [ tmp_fslsplit '0' num2str(dwi_idx) '.nii.gz' ];
                            end
                            [ ~, bn_curdwi{ii}, ~ ] = fileparts(cur_in_dwi{ii});
                            %Remove '.nii' string notation if exists:
                            if strcmp(bn_curdwi{ii}(end-3:end),'.nii')
                                bn_curdwi{ii}=bn_curdwi{ii}(1:end-4);
                            end
                            if ii==refB0
                                refB0_fname = cur_in_dwi{ii};
                                refB0_index = ii ;
                                bn_refB0=bn_curdwi{ii};
                            end
                        end
                    end
                    fprintf('\t\tDONE STEP2 \n'); pause(0.25);
                    %%%%%%%%
                    
                    %%%%%%%%STEP3: CREATING MATFILES WITHIN B0s
                    fprintf('\n\tSTEP3: CREATING MATFILES WITHIN B0s\n'); pause(1);
                    for ii=1:numel(tmp_bval_idx)
                        if strcmpi(obj.projectID,'habsiic')
                            b0_tval = 5;
                        else
                            b0_tval = 0;
                            
                        end
                        %If the value is 0, then its a B0 image
                        if tmp_bval_idx(ii) == b0_tval %it it's a b0 image
                            %Init variables used below:
                            outmat_dwi2refb0{ii} =  [ tmp_fslsplit 'toref_' bn_curdwi{ii} '_2_' bn_refB0 '.mat' ];
                            if ii == refB0 %Reference B0Volume_irst b0 volume
                                %if ref volume,then we will created the
                                %eye.mat matrix for reference on the refb0 for rotation
                                %matrices that will be used for rot. bvecs
                                outmat_dwi2earlierb0{1}=outmat_dwi2refb0{ii};
                                if exist(outmat_dwi2refb0{ii}, 'file' ) == 0  || obj.redo_history
                                    exec_cmd{end+1,:}=([ ' printf "1 0 0 0 \n0 1 0 0 \n0 0 1 0 \n0 0 0 1 " > ' ...
                                        outmat_dwi2refb0{ii} ]);
                                    obj.RunBash(exec_cmd{end});
                                end
                            else
                                %The idea here is to create the two
                                %matrices needed for converting each B0
                                %to the ref using and also each B0 to
                                %its consecuent one.
                                outmat_dwi2earlierb0{ii} =  [ tmp_fslsplit 'dwi_' bn_curdwi{ii} '_2_' ...
                                    b0_padded_name{b0idx} '.mat' ];
                                if exist(outmat_dwi2refb0{ii}, 'file' ) == 0  || obj.redo_history
                                    %Transform to ref b0 -->
                                    exec_cmd{end+1,:}=[obj.FSL_dir 'bin/flirt -in ' cur_in_dwi{ii} ' -ref ' refB0_fname   '  -omat ' outmat_dwi2refb0{ii} ];
                                    fprintf(['\n (FSL)Flirting and creating matfile b0 ' bn_curdwi{ii} ' to refb0: ' bn_refB0 ]);
                                    obj.RunBash(exec_cmd{end});
                                    fprintf('...done')
                                    %Additional stepfor the N>2 b0 volumes
                                    exec_cmd{end+1,:}=[obj.FSL_dir 'bin/flirt -in ' cur_in_dwi{ii} ' -ref ' b0_fname{b0idx}  '  -omat ' outmat_dwi2earlierb0{ii} ];
                                    fprintf(['\n (FSL)Flirting and creating matfile b0 ' bn_curdwi{ii} ' to earlier b0: '  b0_padded_name{b0idx} ]);
                                    obj.RunBash(exec_cmd{end});
                                    fprintf('...done');
                                end
                            end
                            %Keep previous b0 image and the index:
                            b0idx=b0idx+1; %TODO: Fix this indexing if refb0 is not the first one!!
                            b0_fname{b0idx}=cur_in_dwi{ii};
                            b0_padded_name{b0idx}=bn_curdwi{ii};
                            b0_idx_fslnot{b0idx}=ii-1; % minus 1 because fslsplit index starts at 0 and this loop at 1
                            b0idx_MATLABnot{b0idx}=ii;
                            omat_2_refb0{b0idx} = outmat_dwi2refb0{ii} ;
                            omat_2_earlierb0{b0idx} = outmat_dwi2earlierb0{ii} ;
                            
                        end
                    end
                    fprintf('\n\t\tDONE STEP3! (STEP3: CREATING MATFILES WITHIN B0s)'); pause(1);
                    %%%%%%%%
                    
                    %%%%%%%%STEP4: APPLYING TRANSFORMS TO 3D VOLUMES TO
                    %%%%%%%%CREATE FINAL MATFILES AND NIIs
                    fprintf('\n\n\tSTEP4: APPLYING TRANSFORMS TO CREATE AFFINE CORRECTED B0s and DWIs \n'); pause(1);
                    for ii=1:numel(tmp_bval_idx)
                        %Create a number to compare
                        number_curdwi{ii}=str2num(bn_curdwi{ii});
                        %Init the final matfile to use and the output
                        %3D filename
                        final_mat_dwi2B0{ii} = [ tmp_fslsplit 'final_mat_' bn_curdwi{ii} '_2_combinedB0s.mat' ];
                        final_nii_dwi2B0{ii} =  [ tmp_fslsplit 'final_nii_' bn_curdwi{ii} '_2_combinedB0s.nii.gz' ]; %This will be merged
                        fprintf(['\t\tIn 3D volume:' bn_curdwi{ii}  ' and matlab index: ' num2str(ii) '\n' ])
                        %Applying apply_warp and convert_xfm
                        if ii==refB0 %b0 ref index in MATLAB notation (e.g. index 0000.nii.gz is refB0=1)
                            %Copy refb0 (for reference b0s to be used):
                            if exist(final_nii_dwi2B0{ii} ,'file') == 0 || obj.redo_history
                                exec_cmd{end+1,:}=[ 'cp -r ' cur_in_dwi{ii} ' ' final_nii_dwi2B0{ii}  ];
                                obj.RunBash(exec_cmd{end});
                                wasRun=true;
                            end
                            %Copy eye.mat matrix (for reference b0 chosen)
                            if exist(final_mat_dwi2B0{ii} ,'file') == 0 || obj.redo_history
                                exec_cmd{end+1,:}=[ 'cp -r ' omat_2_refb0{ii} ' ' final_mat_dwi2B0{ii}  ]; %only for consistency
                                obj.RunBash(exec_cmd{end});
                                wasRun=true;
                            end
                            
                        else
                            %check if it's a b0 image, if so, apply the
                            %flirt to ref b0.
                            is2B0=false;
                            for bb=1:numel(b0idx_MATLABnot) ; if b0idx_MATLABnot{bb} == ii ; is2B0=true; break ; end ; end
                            if is2B0==true
                                %Copy only the flirt matrix
                                if exist(final_mat_dwi2B0{ii} ,'file') == 0 || obj.redo_history
                                    exec_cmd{end+1,:}=[ 'cp -r ' omat_2_refb0{bb} ' ' final_mat_dwi2B0{ii}  ];
                                    obj.RunBash(exec_cmd{end});
                                    wasRun=true;
                                end
                            else
                                %Working here with DWIs (not b0s...)
                                %Check if 'ii' is above the last b0
                                if ii > b0idx_MATLABnot{end}
                                    %Omat will be the same as the last
                                    %indexed
                                    if exist(final_mat_dwi2B0{ii} ,'file') == 0 || obj.redo_history
                                        exec_cmd{end+1,:}=[ 'cp -r ' omat_2_refb0{end} ' ' final_mat_dwi2B0{ii}  ];
                                        obj.RunBash(exec_cmd{end});
                                        wasRun=true;
                                    end
                                else
                                    %If not, what b0 are in between?
                                    clear B0_btw B0torefB0
                                    %for loop that tell us the b0 and necessary files in between
                                    for bb=1:numel(b0idx_MATLABnot) ; if b0idx_MATLABnot{bb} > ii ; B0_btw=omat_2_earlierb0{bb} ; B0torefB0=omat_2_refb0{bb-1} ; break ; end ; end
                                    
                                    %Apply convert_xfm usinf the AtoC
                                    %notation in FSL convert_xfm
                                    if exist(final_mat_dwi2B0{ii} ,'file') == 0 || obj.redo_history
                                        % Given C=refB0, A=lateB0 and B=early b0 --> convert_xfm  -omat <outmat_AtoC> -concat <mat_BtoC> <mat_AtoB>
                                        exec_cmd{end+1,:}=[obj.FSL_dir 'bin/convert_xfm -omat ' final_mat_dwi2B0{ii} ' -concat ' B0torefB0 ' ' B0_btw   ];
                                        obj.RunBash(exec_cmd{end});
                                        wasRun=true;
                                    end
                                end
                            end
                            %Apply flirt with the created final_mat_dwi2B0{ii}
                            if exist(final_nii_dwi2B0{ii} ,'file') == 0 || obj.redo_history
                                %CHANGED TO SPLINE RESAMPLING (TEND TO HAVE BETTER RESULTS)
                                %BUT KEEP PREVIOUS PROCESSING STEPS FOR
                                %ADRC THE SAME:
                                if strcmpi(obj.projectID,'ADRC')
                                    exec_cmd{end+1,:}=[obj.FSL_dir 'bin/flirt -in ' cur_in_dwi{ii} ...
                                        ' -ref ' refB0_fname ' -applyxfm  -init ' final_mat_dwi2B0{ii} ' -out ' final_nii_dwi2B0{ii} ' -interp nearestneighbour'  ];
                                else
                                    exec_cmd{end+1,:}=[obj.FSL_dir 'bin/flirt -in ' cur_in_dwi{ii} ...
                                        ' -ref ' refB0_fname ' -applyxfm  -init ' final_mat_dwi2B0{ii} ' -out ' final_nii_dwi2B0{ii} ' -interp spline'  ];
                                end
                                obj.RunBash(exec_cmd{end});
                                wasRun=true;
                            end
                        end
                    end
                    fprintf('\n\t \tDONE STEP4! (STEP4: APPLYING TRANSFORMS)'); pause(1);
                    %%%%%%%%
                    
                    
                    %%%%%%%%STEP5: APPLYING TRANSFORMS TO BVECS AND COPY BVALS
                    %BVECS:
                    %Applying rotate_bvecs.sh...
                    if exist(obj.Params.B0MoCo.out.bvecs{jj},'file') == 0 || obj.redo_history
                        fprintf('\n\tSTEP5a: APPLYING TRANSFORMS TO BVECS AND COPY BVALS \n');
                        fprintf('Applying rotation only .mat files to bvecs..');
                        TEMP_BVEC = load(obj.Params.B0MoCo.in.bvecs{jj});
                        
                        %Transpose bvecs to be in 3xN notation:
                        if size(TEMP_BVEC,1) < size(TEMP_BVEC,2)
                            TEMP_BVEC = TEMP_BVEC';
                        end
                        for pp=1:size(TEMP_BVEC,1)
                            exec_cmd{end+1,:}=[obj.Params.B0MoCo.in.sh_rotate_bvecs ...
                                ' ' num2str(TEMP_BVEC(pp,:)) ...
                                ' ' final_mat_dwi2B0{pp} ...
                                ' >> ' (obj.Params.B0MoCo.out.bvecs{jj}) ];
                            obj.RunBash(exec_cmd{end});
                            wasRun=true;
                        end
                        fprintf('...done');
                        fprintf('\n\t \tDONE STEP5! (APPLYING TRANSFORMS TO BVECS AND COPY BVALS) \n'); pause(1);
                    end
                    
                    
                    %BVALS:
                    %Copy bval_in to bvals_out (just a simple copy as
                    %its not affected):
                    if exist(obj.Params.B0MoCo.out.bvals{jj},'file') == 0 || obj.redo_history
                        fprintf('\n\tSTEP5b: COPYING  BVALS \n'); pause(1);
                        TEMP_BVAL = load(obj.Params.B0MoCo.in.bvals{jj});
                        %Transpose bvecs to be in 3xN notation:
                        if size(TEMP_BVAL,1) < size(TEMP_BVAL,2)
                            TEMP_BVAL= TEMP_BVAL';
                        end
                        fileID=fopen(obj.Params.B0MoCo.out.bvals{jj},'w');
                        exec_cmd{end+1,:}=['fprintf(fileID,''%d\n'', TEMP_BVAL);' ];
                        fprintf('Copying bvals ..');
                        eval(exec_cmd{end});
                        fprintf('...done\n');
                        fclose(fileID);
                        wasRun=true;
                    end
                    %%%%%%%%
                    
                    %%%%%%%%STEP6: MERGING MOTION CORRECTED DWI%%%%%%%%
                    %Check if input was *.nii:
                    if strcmp(c,'.nii')
                        fn_out = strcat(obj.Params.B0MoCo.out.fn{jj},'.gz');
                    else
                        fn_out = obj.Params.B0MoCo.out.fn{jj};
                    end
                    
                    if exist(fn_out,'file')==0 || obj.redo_history
                        fprintf('\n\tSTEP6: MERGING SINGELE MOTION CORRECTED DWIs \n'); pause(1);  for tohide=1:1
                            clear all_niis
                            for bb=1:numel(final_nii_dwi2B0)
                                if bb==1
                                    all_niis{jj} = [ final_nii_dwi2B0{bb} ' ' ];
                                else
                                    all_niis{jj} = [ all_niis{jj} final_nii_dwi2B0{bb} ' ' ];
                                end
                            end
                            display(['Merging all volumes (total: ' num2str(numel(final_nii_dwi2B0)) ')']);
                            exec_cmd{end+1,:}=[obj.FSL_dir 'bin/fslmerge -t '  obj.Params.B0MoCo.out.fn{jj} ' ' all_niis{jj} ];
                            wasRun=true;
                            obj.RunBash(exec_cmd{end});
                        end
                        fprintf('\n\t\tDONE STEP6! (MERGING SINGLE MOTION CORRECTED DWIs) \n'); pause(1);
                    end
                    %%%%%%%%
                else
                    fprintf([ '\t ' obj.Params.B0MoCo.out.fn{jj} ' exists. Nothing to do... \n' ]);
                end
                %%%%%%%%
                %TO UPDATE HISTORY AND RESAVE:
                if wasRun == true
                    obj.UpdateHist_v2(obj.Params.B0MoCo,'proc_B0MoCo', obj.Params.B0MoCo.out.fn{jj},wasRun,exec_cmd');
                    obj.resave();
                end
                %%%%%%%%
            end
        end
 
        function obj = proc_bet2(obj)
            wasRun=false;
            fprintf('\n%s\n', 'PERFORMING PROC_BET2():');
            
            %Static init of prefix:
            obj.Params.Bet2.in.prefix = 'bet2_';
            
            
            if ~exist('exec_cmd','var')
                exec_cmd{:} = '#INIT PROC_BET2()';
            end
            
            for ii=1:numel(obj.Params.Bet2.in.fn)
                clear cur_fn;
                if iscell(obj.Params.Bet2.in.fn{ii})
                    cur_fn=cell2char_rdp(obj.Params.Bet2.in.fn{ii});
                else
                    cur_fn=obj.Params.Bet2.in.fn{ii};
                end
                [a b c ] = fileparts(cur_fn);
                outpath=obj.getPath(a,obj.Params.Bet2.in.movefiles);
                clear outfile
                obj.Params.Bet2.out.skull{ii} = [ outpath obj.Params.Bet2.in.prefix  b c ];
                obj.Params.Bet2.out.mask{ii} = strrep(obj.Params.Bet2.out.skull{ii},'.nii.gz','_mask.nii.gz');
                %EXEC command to store:
                if exist( obj.Params.Bet2.out.mask{ii},'file')==0 || obj.redo_history
                    exec_cmd{:,end+1} = [ obj.FSL_dir  'bin/bet2 ' obj.Params.Bet2.in.fn{ii} ' ' obj.Params.Bet2.out.skull{ii}  ' -m -f ' num2str(obj.Params.Bet2.in.fracthrsh) ];
                    fprintf(['\nExtracting the skull using bet2 for : ' obj.Params.Bet2.in.fn{ii} ]);
                    obj.RunBash(exec_cmd{end});
                    exec_cmd{:,end+1} = (['mv ' obj.Params.Bet2.out.skull{ii} '_mask.nii.gz ' obj.Params.Bet2.out.mask{ii} ] ) ;
                    obj.RunBash(exec_cmd{end});
                    wasRun=true;
                else
                    [aa, bb, cc ] = fileparts(obj.Params.Bet2.out.mask{ii});
                    fprintf(['File ' bb cc ' is now complete. \n']) ;
                end
            end
            %Record if some RunBash process is applied
            if wasRun==true
                obj.UpdateHist_v2(obj.Params.Bet2,'proc_bet2()', obj.Params.Bet2.out.mask{ii},wasRun,exec_cmd');
                obj.resave();
            end
        end
        
        function obj = proc_eddy(obj)
            wasRun=false;
            fprintf('\n%s\n', 'PERFORMING PROC_EDDY():');
            
            %Init static prefix:
            obj.Params.Eddy.in.prefix = 'eddy_'; 
           if ~exist('exec_cmd','var')
                exec_cmd{:} = '#INIT PROC_EDDY()';
            end
            for ii=1:numel(obj.Params.Eddy.in.fn)
                clear cur_fn;
                if iscell(obj.Params.Eddy.in.fn{ii})
                    cur_fn=cell2char_rdp(obj.Params.Eddy.in.fn{ii});
                else
                    cur_fn=obj.Params.Eddy.in.fn{ii};
                end
                [a b c ] = fileparts(cur_fn);
                outpath=obj.getPath(a,obj.Params.Eddy.in.movefiles);
                clear outfile
                %(dependency) Attempting to create acqp file:
                if isfield(obj.Params.Eddy,'out') == 0 
                    obj.Params.Eddy.out = [] ; 
                end
                if isfield(obj.Params.Eddy.out,'fn_acqp') == 0 
                    obj.Params.Eddy.out.fn_acqp{ii}= [ outpath 'acqp.txt' ] ;
                end
                %For HABSIIC, this should be passed in the child class
                %after TOPUP is run:
                if exist(obj.Params.Eddy.out.fn_acqp{ii},'file')==0 || obj.redo_history
                    exec_cmd{:,end+1}=['printf " ' num2str(obj.Params.Eddy.in.acqp) ' " >> ' obj.Params.Eddy.out.fn_acqp{ii}  ];
                    fprintf(['\n Creating ' obj.Params.Eddy.out.fn_acqp{ii}  ]);
                    obj.RunBash(exec_cmd{end});
                    wasRun=true;
                    fprintf(' ...done\n');
                end
                %(dependency) Attempting to create index file:
                obj.Params.Eddy.out.fn_index{ii}= [ outpath 'index.txt' ] ;
                if exist(obj.Params.Eddy.out.fn_index{ii},'file')==0 || obj.redo_history
                    exec_cmd{:,end+1}=['printf "' num2str(obj.Params.Eddy.in.index) '" >> ' obj.Params.Eddy.out.fn_index{ii}  ];
                    fprintf(['\n Creating ' obj.Params.Eddy.out.fn_index{ii}  ]);
                    obj.RunBash(exec_cmd{end});
                    wasRun=true;
                    fprintf(' ...done\n');
                end
                %Attempting to run eddy_openmp now:
                obj.Params.Eddy.out.fn{ii} = [ outpath obj.Params.Eddy.in.prefix  b c ];
                obj.Params.Eddy.out.bvecs{ii} = [ outpath obj.Params.Eddy.in.prefix strrep(b,'.nii','.eddy_rotated_bvecs') ];
                %EXEC command to store:
                if exist(obj.Params.Eddy.out.fn{ii},'file')==0 || obj.redo_history
                    if isfield(obj.Params.Eddy.in,'topup')
                         exec_cmd{:,end+1}=[  obj.FSL_dir 'bin/eddy_openmp  --imain=' obj.Params.Eddy.in.fn{ii} ...
                            ' --mask=' obj.Params.Eddy.in.mask{ii} ...
                            ' --index=' obj.Params.Eddy.out.fn_index{ii} ...
                            ' --acqp='  obj.Params.Eddy.out.fn_acqp{ii}  ...
                            ' --bvecs='  obj.Params.Eddy.in.bvecs{ii} ...
                            ' --bvals=' obj.Params.Eddy.in.bvals{ii}  ...
                            ' --topup='  obj.Params.Eddy.in.topup ...
                            ' --repol --out=' [ outpath obj.Params.Eddy.in.prefix strrep(b,'.nii','') ]  ];
                    else
                        exec_cmd{:,end+1}=[  obj.FSL_dir 'bin/eddy_openmp  --imain=' obj.Params.Eddy.in.fn{ii} ...
                            ' --mask=' obj.Params.Eddy.in.mask{ii} ...
                            ' --index=' obj.Params.Eddy.out.fn_index{ii} ...
                            ' --acqp='  obj.Params.Eddy.out.fn_acqp{ii}  ...
                            ' --bvecs='  obj.Params.Eddy.in.bvecs{ii} ...
                            ' --bvals=' obj.Params.Eddy.in.bvals{ii}  ...
                            ' --repol --out=' [ outpath obj.Params.Eddy.in.prefix strrep(b,'.nii','') ]  ];
                    end
                    fprintf(['\nApplying eddy in: ' obj.Params.Eddy.in.fn{ii} ]);
                    fprintf('\n this will take a couple  of minutes...');
                    keyboard
                    obj.RunBash(exec_cmd{end},44);
                    fprintf('...done \n');
                    wasRun=true;
                else
                    [~, bb, cc] = fileparts(obj.Params.Eddy.out.fn{ii});
                    fprintf(['File ' bb cc ' is now complete \n']) ;
                end
            end
            
            %Update history if wasRun==1
            if wasRun == true
                obj.UpdateHist_v2(obj.Params.Eddy,'proc_eddy()', obj.Params.Eddy.out.fn{ii},wasRun,exec_cmd');
                obj.resave();
            end
        end
        
        function obj = proc_get_eddymotion(obj)
            wasRun=false;
            if ~exist('exec_cmd','var')
                exec_cmd{:} = '#INIT PROC_GET_EDDYMOTION()';
            end
            fprintf('\n%s\n', 'PERFORMING MOTION EXTRACTION (from eddy) - PROC_GET_EDDYMOTION():');
            
            for ii=1:numel(obj.Params.EddyMotion.in.fn_eddy)
                clear cur_fn;
                %Dealing with INPUT:
                %obj.Params.EddyMotion.in.fn_motion --> using restricted
                %movement file instead of the non_restricted as it give us
                %the actual movement disregarding the tranlation in the PE
                %direction (double check:
                %https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/eddy/UsersGuide )
                obj.Params.EddyMotion.in.fn_motion{ii} = ...
                    strrep(obj.Params.EddyMotion.in.fn_eddy{ii},'.nii.gz','.eddy_restricted_movement_rms');
                if exist(obj.Params.EddyMotion.in.fn_motion{ii} ) || obj.redo_history
                    if iscell(obj.Params.EddyMotion.in.fn_motion{ii})
                        cur_fn=cell2char_rdp(obj.Params.EddyMotion.in.fn_motion{ii});
                    else
                        cur_fn=obj.Params.EddyMotion.in.fn_motion{ii};
                    end
                    [a b c ] = fileparts(cur_fn);
                else
                    error(['No eddy_motion file exist with this name: ' ...
                        obj.Params.EddyMotion.in.fn_motion{ii} ' exiting...']);
                end
                %Dealing with OUTPUT:
                %Attempting to create the eddy_motion file:
                outpath=obj.getPath(a,obj.Params.EddyMotion.in.movefiles);
                obj.Params.EddyMotion.out.fn_motion{ii}= [ outpath 'motion_' b '.txt' ] ;
                
                %BELOW (AND HIDDEN) IS THE CODE IN SHELL: (REPLACED DUE TO PROBLEM WHEN
                %SHELL IN NOT BASH)
                for tohide=1:1
%                 cmd_1=sprintf([ 'awk ''{for(i=1;i<=NF;i++) {sum[i] += $i; sumsq[i] += ($i)^2}} \n ' ...
%                     '  END {for (i=1;i<=NF;i++) { \n' ...
%                     ' printf "' ] );
%                 cmd_2= ('%f %f \n", sum[i]/NR, sqrt((sumsq[i]-sum[i]^2/NR)/NR)} ' ) ;
%                 cmd_3= sprintf(['\n }'' ' obj.Params.EddyMotion.in.fn_motion{ii}  ' > ' obj.Params.EddyMotion.out.fn_motion{ii} ]);
                end
                
                if exist(obj.Params.EddyMotion.out.fn_motion{ii},'file')==0 || obj.redo_history
                    fprintf(['\nGetting motion parameters from: ' obj.Params.EddyMotion.in.fn_motion{ii} ]);
                    %Break the command so I can denote the newline (\n
                    %character):
                    
                    fileID=fopen(obj.Params.EddyMotion.in.fn_motion{ii});
                    temp_motion{ii}=textscan(fileID,'%f %f ');
                    fclose(fileID);
                    
                    obj.Params.EddyMotion.out.vals.rel_2_firstb0{ii}= temp_motion{ii}{1};
                    obj.Params.EddyMotion.out.vals.rel_2_previous{ii}= temp_motion{ii}{2};
                    
                    
                    obj.Params.EddyMotion.out.vals.initb0_mean{ii}=mean(obj.Params.EddyMotion.out.vals.rel_2_firstb0{ii});
                    obj.Params.EddyMotion.out.vals.initb0_std{ii}=std(obj.Params.EddyMotion.out.vals.rel_2_firstb0{ii});
                    obj.Params.EddyMotion.out.vals.rel_mean{ii}=mean(obj.Params.EddyMotion.out.vals.rel_2_previous{ii});
                    obj.Params.EddyMotion.out.vals.rel_std{ii}=std(obj.Params.EddyMotion.out.vals.rel_2_previous{ii});
                    
                    fn_motion=1;
                    
                    %Writing to file:
                    fileID=fopen(obj.Params.EddyMotion.out.fn_motion{ii},'w');
                    fprintf(fileID,'%2.4f %2.4f\n',[ obj.Params.EddyMotion.out.vals.initb0_mean{ii} obj.Params.EddyMotion.out.vals.initb0_std{ii}]);
                    fprintf(fileID,'%2.4f %2.4f\n',[obj.Params.EddyMotion.out.vals.rel_mean{ii} obj.Params.EddyMotion.out.vals.rel_std{ii} ]);
                    fclose(fileID);
                    %OUTPUT SHOULD LOOK LIKE THESE:
                    % rdp20@kant 05_MotionFromEDDY] $ cat motion_eddy_moco_gnc_dv_ep2d_diff_2p5k_set4E60.txt
                    % 0.919434 (A) 0.313574 (B)
                    % 0.234648 (C) 0.297711 (D), where:
                    %                     A: average root mean squared movement of each slice relative to first volume
                    %                     B: standard deviation of A
                    %                     C: average root meat squared movement of each slice relative to the previous one
                    %                     D: standard deviation of C
                    %                     SOME ADDITIONAL USEFUL INFORMATION  FROM: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/eddy
                    for tohide=1:1
                    %                     my_eddy_output.eddy_movement_rms:
                    %                     A summary of the "total movement" in each volume is created by calculating
                    %                     the displacement of each voxel and then averaging the squares of those
                    %                     displacements across all intracerebral voxels (as determined by --mask
                    %                     and finally taking the square root of that. The file has two columns where
                    %                     the first contains the RMS movement relative the first volume and the second
                    %                     column the RMS relative the previous volume.
                    %
                    %                     my_eddy_output.eddy_restricted_movement_rms:
                    %                     There is an inherent ambiguity between any EC component that has
                    %                     a non-zero mean across the FOV and subject movement (translation)
                    %                     in the PE direction. They will affect the data in identical
                    %                     (or close to identical if a susceptibility field is specified) ways.
                    %                         That means that both these parameters are estimated by eddy with
                    %                         large uncertainty.
                    %                         This doesn't matter for the correction of the images, it makes
                    %                         no difference if we estimate a large constant EC components and
                    %                         small movement or if we estimate a small EC component and large
                    %                         movement. The corrected images will be (close to) identical.
                    %                         But it matters if one wants to know how much the subject moved.
                    %                         We therefore supplies this file that estimates the movement RMS as
                    %                         above, but which disregards translation in the PE direction.
                    end
                    fprintf('...done \n');
                    wasRun=true;
                else
                    [~, bb, cc ] =  fileparts(obj.Params.EddyMotion.out.fn_motion{ii});
                    fprintf(['File ' bb cc ' exists\n']) ;
                end
            end
            
            %Average grand total movement
            obj.Params.EddyMotion.out.vals.initb0_mean_grandtotal = mean(cell2mat(obj.Params.EddyMotion.out.vals.initb0_mean)); %Init variables
            obj.Params.EddyMotion.out.vals.initb0_std_grandtotal = mean(cell2mat(obj.Params.EddyMotion.out.vals.initb0_std));
            obj.Params.EddyMotion.out.vals.rel_mean_grandtotal = mean(cell2mat(obj.Params.EddyMotion.out.vals.rel_mean));
            obj.Params.EddyMotion.out.vals.rel_std_grandtotal = mean(cell2mat(obj.Params.EddyMotion.out.vals.rel_std));
        
            %Update history if possible
            if  wasRun == true
               obj.UpdateHist_v2(obj.Params.EddyMotion,'proc_getmotion_from_eddy()', obj.Params.EddyMotion.out.fn_motion{ii},wasRun,exec_cmd');
               obj.resave()
            end
            clear exec_cmd wasRun;
            
            %REMOVE PREVIOUS ADD-ON IF EXISTS (02/26/2018)
            if isfield(obj.Params.EddyMotion,'history_saved')
                obj.Params.EddyMotion=rmfield(obj.Params.EddyMotion,'history_saved');
                obj.resave();
            end
        end
        
        function obj = proc_meanb0(obj)
            wasRun=false;
            if ~exist('exec_cmd','var')
                exec_cmd{:} = '#INIT PROC_MEANB0()';
            end
            fprintf('\n%s\n', 'PERFORMING PROC_MEANB0():');
            for jj=1:numel(obj.Params.B0mean.in.fn)
                clear cur_fn;
                if iscell(obj.Params.B0mean.in.fn{jj})
                    cur_fn=cell2char_rdp(obj.Params.B0mean.in.fn{jj});
                else
                    cur_fn=obj.Params.B0mean.in.fn{jj};
                end
                [a, b, c ] = fileparts(cur_fn);
                outpath=obj.getPath(a,obj.Params.B0mean.in.movefiles);
                clear outfile
                %Init variable names:
                obj.Params.B0mean.out.allb0s{jj}= [ outpath 'all_b0s_' b c ] ;
                obj.Params.B0mean.out.fn{jj}= [ outpath 'b0mean_' b c ] ;
                
                
                %Since code was previously implemented for
                %obj.project_ID='HAB' (b0s only at the beginning), I will
                %create an if statement to separate this (earlier)
                %implementation with the later one (for HABS_IISC):
                if ~strcmpi(obj.projectID,'hab')
                    %Check equal number of elementes in *Bval and *fnames:
                    if numel(obj.Params.B0mean.in.fn) ~= numel(obj.Params.B0mean.in.fn_bvals)
                        error('proc_meanb0(): Number of bvals are not equalt to number of U.niis files inputted. Please check!');
                    end
                    %CHECK IF B0Mean exists:
                    if exist(obj.Params.B0mean.out.fn{jj}, 'file') == 0 || obj.redo_history
                        %Splitting the current DWI:
                        clear tmp_fslsplit;
                        tmp_fslsplit=[ outpath 'tmp' filesep ...
                            'tmp_' strrep(b,'.nii','') filesep ];
                        if exist([tmp_fslsplit '0000.nii.gz' ],'file') == 0  || obj.redo_history
                            exec_cmd{:,end+1} = (['mkdir -p ' tmp_fslsplit ] );
                            obj.RunBash(exec_cmd{end});
                            fprintf(['splitting..' obj.Params.B0MoCo.in.fn{jj}  ]);
                            exec_cmd{:,end+1}=([obj.FSL_dir  'bin/fslsplit ' obj.Params.B0MoCo.in.fn{jj} ...
                                ' ' tmp_fslsplit ' -t ']);
                            obj.RunBash(exec_cmd{end});
                            fprintf('...done \n');
                        end
                        
                        
                        %%%%%%%%Splitting and selecting b0s
                        obj.Params.B0mean.out.b0_fnames{jj} = [] ;
                        for tohide=1:1
                            %Load bval information:
                            clear tmp_bval_idx b0idx
                            tmp_bval_idx=load(obj.Params.B0mean.in.fn_bvals{jj});
                            idx_b0s=find(tmp_bval_idx==obj.Params.B0mean.in.b0idx);
                            obj.Params.B0mean.out.b0idxs{jj} = idx_b0s-1;
                            %PADDING NAMING STRUCTURE AND FINDINF refB0:
                            clear refB0_fname  refB0_index bn_refB0
                            for ii=1:numel(tmp_bval_idx)
                                dwi_idx=ii-1  ; %indexing from fslsplit starts at 0 not 1 so we need this additional indexing (MATLAB array index starts at 1, so focus on it!)
                                %Get single dwi (indexed at 0000 or 0010)
                                if ii < 11 % (idx start at 1 in matlab but fslsplit idx starts at 0, hence the difference!!
                                    cur_in_dwi{ii} = [ tmp_fslsplit '000' num2str(dwi_idx) '.nii.gz' ];
                                elseif ii < 101
                                    cur_in_dwi{ii} = [ tmp_fslsplit '00' num2str(dwi_idx) '.nii.gz' ];
                                else 
                                    cur_in_dwi{ii} = [ tmp_fslsplit '0' num2str(dwi_idx) '.nii.gz' ];
                                end
                                [ ~, bn_curdwi{ii}, ~ ] = fileparts(cur_in_dwi{ii});
                                %Remove '.nii' string notation if exists:
                                if strcmp(bn_curdwi{ii}(end-3:end),'.nii')
                                    bn_curdwi{ii}=bn_curdwi{ii}(1:end-4);
                                end
                                if any(ismember( obj.Params.B0mean.out.b0idxs{jj},str2num(bn_curdwi{ii})))
                                    obj.Params.B0mean.out.b0_fnames{jj} = [ obj.Params.B0mean.out.b0_fnames{jj} cur_in_dwi(ii) ];
                                end
                            end
                            obj.Params.B0mean.out.b0_fnames{jj} = obj.Params.B0mean.out.b0_fnames{jj}' ;
                        end
                        %Creating a 4D volume with all_b0s:
                        temp_allb0s = [] ;
                        for pp=1:numel(obj.Params.B0mean.out.b0_fnames{jj})
                            temp_allb0s = [ temp_allb0s ' ' obj.Params.B0mean.out.b0_fnames{jj}{pp}  ];
                        end
                        exec_cmd{:,end+1} = [ obj.FSL_dir  '/bin/fslmerge -t ' obj.Params.B0mean.out.allb0s{jj} ' ' temp_allb0s  ];
                        obj.RunBash(exec_cmd{end});
                        
                        %Meaning b0s:
                        exec_cmd{:,end+1}=[  obj.FSL_dir 'bin/fslmaths  '  obj.Params.B0mean.out.allb0s{jj} ' -Tmean ' obj.Params.B0mean.out.fn{jj}  ];
                        fprintf(['\n Meaning all b0s from : ' cur_fn]);
                        obj.RunBash(exec_cmd{end});
                        fprintf('...done \n');
                        wasRun=true;
                    end
                else
                    try
                        %Attempting to create B0means:
                        if exist( obj.Params.B0mean.out.allb0s{jj},'file')==0 || obj.redo_history
                            exec_cmd{:,end+1}=[  obj.FSL_dir 'bin/fslroi '  cur_fn ' ' obj.Params.B0mean.out.allb0s{jj} ' 0 ' ...
                                num2str(obj.Params.B0mean.in.b0_nvols)  ];
                            fprintf(['\nMerging all b0s from : ' cur_fn]);
                            obj.RunBash(exec_cmd{end});
                            fprintf('...done');
                            wasRun=true;
                        end
                        if exist( obj.Params.B0mean.out.fn{jj},'file')==0 || obj.redo_history
                            exec_cmd{:,end+1}=[  obj.FSL_dir 'bin/fslmaths ' obj.Params.B0mean.out.allb0s{jj} ...
                                ' -Tmean ' obj.Params.B0mean.out.fn{jj}];
                            fprintf(['\n Meaning all b0s from : ' cur_fn]);
                            obj.RunBash(exec_cmd{end});
                            fprintf('...done \n');
                            wasRun=true;
                        else
                            [~, bb, cc] = fileparts(obj.Params.B0mean.out.fn{jj});
                            fprintf(['The file ' bb cc ' is complete. \n']);
                        end
                    catch
                        errormsg=['PROC_B0MEAN: Cannnot create the following meanB0 from:'  ...
                            cur_fn 'Please check this input location!\n' ];
                    end
                end
            end
            %Update history if possible
            if wasRun == true
                obj.UpdateHist_v2(obj.Params.B0mean,'proc_B0Mean()', obj.Params.B0mean.out.allb0s{jj},wasRun,exec_cmd');
                obj.resave();
            end
            
            %REMOVE PREVIOUS ADD-ON IF EXISTS (02/26/2018)
            if isfield(obj.Params.B0mean,'history_saved')
                obj.Params.B0mean=rmfield(obj.Params.B0mean,'history_saved');
                obj.resave();
            end
            
        end
        
        function obj = proc_topup(obj)
            wasRun=false;
            if ~exist('exec_cmd','var')
                exec_cmd{:} = '#INIT PROC_TOPUP()';
            end
            fprintf('\n%s\n', 'PERFORMING PROC_TOPUP():');
            
            [a, b, c ] = fileparts(obj.Params.Topup.in.fn_AP{end});
            outpath=obj.getPath(a,obj.Params.Topup.in.movefiles);
            
            obj.Params.Topup.out.b0merged = [outpath 'meanb0s_AP_PA.nii.gz' ] ;
            
            obj.Params.Topup.out.fname_acqp = [ outpath 'acqp.txt'] ;
            if exist(obj.Params.Topup.out.fname_acqp,'file') == 0
                fprintf('\nCreating acqp.txt...');
                fileID=fopen(obj.Params.Topup.out.fname_acqp,'w');
                fprintf(fileID,'%f %f %f %f \n',obj.Params.Topup.in.acqp_params');
                fclose(fileID)
                fprintf('...done\n');
            end
            
            %Merging b0s:
            if exist(obj.Params.Topup.out.b0merged, 'file') == 0 
                %Making sure a single 3D volums is passed per each pahse
                %enconding
                if numel(obj.Params.Topup.in.b0_AP) > 1 ; error('obj.Params.Topup.in.b0_AP contiains >1 filename. Please combine them before running topup') ; end
                if numel(obj.Params.Topup.in.b0_PA) > 1 ; error('obj.Params.Topup.in.b0_AP contiains >1 filename. Please combine them before running topup') ; end
                fprintf('\nMerging b0s...');
                exec_cmd{:,end+1} = [obj.FSL_dir '/bin/fslmerge -t ' obj.Params.Topup.out.b0merged  ' ' obj.Params.Topup.in.b0_AP{end}  ' ' obj.Params.Topup.in.b0_PA{end}  ] ;
                obj.RunBash(exec_cmd{end});
                fprintf('...done\n')
                wasRun =true;
            end
            
            %Creating topup_config directory
            obj.Params.Topup.out.cnf_prefix = [outpath 'topup_results' ] ; 
            obj.Params.Topup.out.cnf_movpar = [outpath 'topup_results_movpar.txt' ] ;
            %Creating topup files:
            if exist(obj.Params.Topup.out.cnf_movpar,'file' ) == 0
                exec_cmd{:,end+1} = [obj.FSL_dir '/bin/topup --imain=' obj.Params.Topup.out.b0merged ' --datain=' obj.Params.Topup.out.fname_acqp  ' --config=b02b0.cnf  --out=' obj.Params.Topup.out.cnf_prefix  ];
                fprintf('\n Creating topup files based on b0s....');
                obj.RunBash(exec_cmd{end},44); %44 allows us to see output in the MATLAB terminal window.
                fprintf('...done');
                wasRun =true;
            end
            
            
            %Applying topup
            obj.Params.Topup.out.topup_mergedb0s = [outpath 'topup_mergedb0s_dMRI.nii.gz' ] ;
            if exist(obj.Params.Topup.out.topup_mergedb0s,'file') == 0 
                fprintf('\nApplying topup....');
                exec_cmd{:,end+1} = [obj.FSL_dir '/bin/applytopup --imain=' obj.Params.Topup.in.b0_AP{end} ',' obj.Params.Topup.in.b0_PA{end} ' --inindex=1,2  --datain=' obj.Params.Topup.out.fname_acqp  ' --topup=' obj.Params.Topup.out.cnf_prefix ' --out=' obj.Params.Topup.out.topup_mergedb0s  ];
                obj.RunBash(exec_cmd{end},44); %44 allows us to see output in the MATLAB terminal window.
                fprintf('...done');
                wasRun =true;
            end    
                
            %Generating a mask from Eddy:
            obj.Params.Topup.out.bet = [outpath 'topup_mergedb0s_dMRI_bet' ] ;
            obj.Params.Topup.out.bet_mask = [outpath 'topup_mergedb0s_dMRI_bet_mask.nii.gz' ] ;
            if exist(obj.Params.Topup.out.bet_mask,'file') == 0 
                fprintf('\n Generating mask for eddy....');
                exec_cmd{:,end+1} = [obj.FSL_dir '/bin/bet2 ' obj.Params.Topup.out.topup_mergedb0s ' ' obj.Params.Topup.out.bet ' -m -f 0.4 ' ];
                obj.RunBash(exec_cmd{end},44); %44 allows us to see output in the MATLAB terminal window.
                fprintf('...done');
                wasRun =true;
            end    
                    
            
            %Update history if possible
            if wasRun == true
                obj.UpdateHist_v2(obj.Params.Topup,'proc_topup()', obj.Params.Topup.out.cnf_movpar,wasRun,exec_cmd');
                obj.resave();
            end
            
            fprintf('\n%s\n', 'END OF PROC_TOPUP():');
        end
        
        function obj = proc_mask_after_eddy(obj)
            wasRun=false;
            if ~exist('exec_cmd','var')
                exec_cmd{:} = '#INIT PROC_MASK_AFTER_EDDY()';
            end            
            fprintf('\n%s\n', 'PERFORMING PROC_MASK_AFTER_EDDY():');
            for ii=1:numel(obj.Params.MaskAfterEddy.in.fn)
                [a b c ] = fileparts(obj.Params.MaskAfterEddy.in.fn{ii});
                outpath=obj.getPath(a,obj.Params.MaskAfterEddy.in.movefiles);
                clear outfile
                
                %Check whether the input was a b0 or the whole DWI:
                [~ , tmp_nvols ] =system(['fslinfo ' obj.Params.MaskAfterEddy.in.fn{ii} ' | grep ^dim4 | awk ''{print $2}''' ]);
                if strcmp(strtrim(tmp_nvols),'1')
                    %Here, we assume you pass a b0 argument (no need for
                    %more complicated naming) --> compatible with dwi_HAB.m
                    obj.Params.MaskAfterEddy.in.b0{ii} =  obj.Params.MaskAfterEddy.in.fn{ii} ;
                    obj.Params.MaskAfterEddy.out.brainonly{ii} = [ outpath obj.Params.MaskAfterEddy.in.prefix  '_brainonly.nii.gz' ];
                    exec_cmd{:,end+1} = ['#No extra step needed (ok). obj.Params.MaskAfterEddy.in.fn{ii} should be 1 volume'];
                else
                    %Else we need extra steps to extract the first b0...
                    %(compatible with dwi_ADRC.m)
                    obj.Params.MaskAfterEddy.in.b0{ii} = [ outpath 'b0_' b c ] ;
                    
                    %Make sure there is only one versio of b0mean:
                    [b0mean_dir, b0mean_fname, b0mean_ext ] = fileparts(obj.Params.MaskAfterEddy.in.fn{ii});
                    if exist([b0mean_dir filesep b0mean_fname ]) && exist(obj.Params.MaskAfterEddy.in.fn{ii})
                       obj.RunBash(['rm ' b0mean_dir filesep b0mean_fname ]) 
                    end
                    
                    
                    if exist(obj.Params.MaskAfterEddy.in.b0{ii},'file') == 0 || obj.redo_history
                        fprintf(['\n proc_mask_after_eddy: Extracting the first b0 for iteration: ' num2str(ii) ]);
                        exec_cmd{:,end+1} = ([  obj.FSL_dir 'bin/fslroi ' obj.Params.MaskAfterEddy.in.fn{ii} ...
                            ' '  obj.Params.MaskAfterEddy.in.b0{ii} ' 0 1 ' ]);
                        obj.RunBash(exec_cmd{end});
                        fprintf('...done\n');
                    end
                    obj.Params.MaskAfterEddy.out.brainonly{ii} = strrep(obj.Params.MaskAfterEddy.in.b0{ii},'b0_','brainonly_');
                end
                
                obj.Params.MaskAfterEddy.out.initmask{ii} = strrep(obj.Params.MaskAfterEddy.out.brainonly{ii},'brainonly_','initmask_');
                obj.Params.MaskAfterEddy.out.finalmask{ii} = strrep(obj.Params.MaskAfterEddy.out.brainonly{ii},'brainonly_','finalmask_');
                
                
                if exist( obj.Params.MaskAfterEddy.out.finalmask{ii},'file')==0 || obj.redo_history
                    fprintf(['\nExtracting the brain only using bet2 for : ' obj.Params.MaskAfterEddy.in.b0{ii} ]);
                    %execs:
                    %execs...
                    exec_cmd{:,end+1} = [ 'bet2 ' obj.Params.MaskAfterEddy.in.b0{ii} ' ' obj.Params.MaskAfterEddy.out.brainonly{ii}  ' -m -f ' num2str(obj.Params.MaskAfterEddy.in.fracthrsh) ];
                    obj.RunBash(exec_cmd{end});
                    exec_cmd{:,end+1} = ['mv ' obj.Params.MaskAfterEddy.out.brainonly{ii} '_mask.nii.gz ' obj.Params.MaskAfterEddy.out.initmask{ii} ];
                    obj.RunBash(exec_cmd{end});
                    exec_cmd{:,end+1} = [ 'fslmaths ' obj.Params.MaskAfterEddy.in.b0{ii} ' -thr 10 -bin -mas ' ...
                        obj.Params.MaskAfterEddy.out.initmask{ii} ' '  obj.Params.MaskAfterEddy.out.finalmask{ii} ];
                    obj.RunBash(exec_cmd{end});
                    wasRun=true;
                else
                    [~, bb, cc] = fileparts(obj.Params.MaskAfterEddy.out.finalmask{ii});
                    fprintf(['File ' bb cc ' is now complete. \n']) ;
                end
            end
            
            %Update history if possible
            if  wasRun == true
                obj.UpdateHist_v2(obj.Params.MaskAfterEddy,'proc_mask_after_eddy()', obj.Params.MaskAfterEddy.out.finalmask{ii},wasRun,exec_cmd);
                obj.resave();                
            end
            
            %REMOVING VARIABLES THAT WERE PREVIOUSLY CREATED
            if isfield(obj.Params.MaskAfterEddy,'history_saved')
                obj.Params.MaskAfterEddy = rmfield(obj.Params.MaskAfterEddy,'history_saved');
            end
            clear exec_cmd to_exec wasRun;
            
        end
        
         %T1/FreeSurfer related method
        %(TODO: replace/modify it to work simliarly to other objects' methods). 
        
        function obj = proc_t1_spm(obj)
            fprintf('\n\n%s\n', 'PROCESS T1 WITH SPM:');
            wasRun = false;
            %Check if obj.fsdir has been initialized correctly:
            if ~isfield(obj,'fsdir')
                obj.fsdir = '';
            end            
            if isempty(obj.fsdir)
               temp_fsdir=[obj.FS_location filesep obj.sessionname];
               temp_fsdir=strrep(temp_fsdir,[filesep filesep],filesep); %Removes '//' --> <FOLDE>//<SUBFOLDER>
               
               %Check if the FreeSurfer Folder exists:
               if exist([temp_fsdir filesep 'mri' ],'dir' ) == 7 
                   obj.fsdir = temp_fsdir;
               else
                   error(['The FreeSurfer directory: ' temp_fsdir ' does not exist. Please make sure you have run FreeSurfer ob this subject (' obj.sessionname ')']);
               end
            end
            
            %Check if .in and .out are fields. if not create them
            if isfield(obj.Params,'spmT1_Proc') == 0
                obj.Params.spmT1_Proc = ''; end
            if isfield(obj.Params.spmT1_Proc,'in') == 0
                obj.Params.spmT1_Proc.in = ''; end
            if isfield(obj.Params.spmT1_Proc,'out') == 0
                obj.Params.spmT1_Proc.out = ''; end
            if isfield(obj.Params.spmT1_Proc.in,'outdir' ) == 0 
                obj.Params.spmT1_Proc.in.outdir = '' ; end
            if isfield(obj.Params.spmT1_Proc.in,'T1' ) == 0 
                obj.Params.spmT1_Proc.in.t1 = '' ; end
            
            %%
            
            if isempty(obj.Params.spmT1_Proc.in.outdir) || isempty(obj.Params.spmT1_Proc.in.t1)
                if exist([obj.fsdir filesep 'mri' filesep 'spm12' filesep ],'dir')==0 
                    mkdir([obj.fsdir filesep 'mri' filesep 'spm12' filesep ])
                end
                if exist([obj.fsdir filesep obj.fsubj '/mri/spm12/orig.nii'],'file')==0
                    obj.RunBash(['mri_convert ' obj.fsdir filesep obj.fsubj '/mri/orig.mgz ' obj.fsdir filesep obj.fsubj '/mri/spm12/orig.nii']);
                end
                obj.Params.spmT1_Proc.in.outdir = [obj.fsdir filesep 'mri' filesep 'spm12' filesep ];
                obj.Params.spmT1_Proc.in.t1 = [obj.fsdir filesep obj.fsubj 'mri' filesep 'spm12' filesep 'orig.nii'];
            end
            
            root = obj.Params.spmT1_Proc.in.outdir;
            root = regexprep(root,'//','/');
            
            t1 =  obj.Params.spmT1_Proc.in.t1;
            [a b c] = fileparts(t1);

            %%%
            if exist([root filesep 'Affine.mat'],'file')==0
                %%% could put something in here to redo subseuqent steps if
                %%% this step is not complete.
                fprintf('%s\n', 'Running affine registration...');
                            
                 %Flag parameters copied from fMRI_Session.m object:
                %---> in = obj.Params.spmT1_Proc.in.pars; (from
                %fMRI_Session.m)
                in.samp =2; in.fwhm1=16; in.fwhm2=0; in.regtype='mni';
                in.P = t1;
                
                %If TPM not assigned, assign it. 
                if ~isfield(obj.Params.spmT1_Proc.in,'tpm')
                    obj.Params.spmT1_Proc.in.tpm = [ fileparts(which('spm')) filesep 'tpm/TPM.nii'];
                end
                
                in.tpm = spm_load_priors8(obj.Params.spmT1_Proc.in.tpm);
                
                obj.Params.spmT1_Proc.in.pars = in;
                
                in.M=[];
                [Affine,h] = spm_maff8(in.P,in.samp,in.fwhm1,in.tpm,in.M,in.regtype);
                in.M = Affine;
                [Affine,h] = spm_maff8(in.P,in.samp,in.fwhm2,in.tpm,in.M,in.regtype);
                save([a filesep 'Affine.mat'],'Affine');
                wasRun=true;
            else
                load([a filesep 'Affine.mat']);
            end
            fprintf('%s\n', 'Affine Registration is complete:');
            
            
            if exist([a filesep 'Norm_Seg8.mat'],'file')==0
                wasRun=true;
                fprintf('%s\n', 'Running normalization...');

                %Again, copy params from fmri_Session.m
                %--> NormPars = obj.Params.spmT1_Proc.in.NormPars;
                NormPars.fwhm = 0;
                NormPars.biasreg=1.0000e-04;
                NormPars.biasfwhm= 60;
                NormPars.reg= [0 1.0000e-03 0.5000 0.0500 0.2000] ;
                NormPars.samp = 2;
                NormPars.lkp =  [];
                NormPars.image = spm_vol(t1);
                NormPars.Affine = Affine;
                
                NormPars.tpm = spm_load_priors8(obj.Params.spmT1_Proc.in.tpm);
                
                obj.Params.spmT1_Proc.in.NormPars = NormPars;
                
                results = spm_preproc8(NormPars);
                save([a filesep 'Norm_Seg8.mat'],'results');
                wasRun=true;
            else
                load([a filesep 'Norm_Seg8.mat']);
            end
            fprintf('%s\n', 'Normalization computation is complete:');
            
            c = regexprep(c,',1','');
            
            if exist([a filesep 'y_' b c],'file')==0
                fprintf('%s\n', 'Writting normalizaation...');
                %replaced from fMRI_Session.m parameters below
                %--> [cls,M1] = spm_preproc_write8(results,obj.Params.spmT1_Proc.in.rflags.writeopts,[1 1],[1 1],0,1,obj.Params.spmT1_Proc.in.rflags.bb,obj.Params.spmT1_Proc.in.rflags.vox);
                bb= [ -78  -112   -70
                    78    76    90 ] ;
                
                [cls,M1] = spm_preproc_write8(results,ones(6,4),[1 1],[1 1],0,1,bb,1);
                %%% I forget what some of these static options do.  Will leave
                %%% them fixed as is for now.
                wasRun=true;
            end
            fprintf('%s\n', 'Normalization files have been written out:');

            if exist([a filesep 'w' b c],'file')==0
                fprintf('%s\n', 'Applying normalization steps to the t1...');
                %Replaced params with fMRI_Session.m standars:
                %--> defs = obj.Params.spmT1_Proc.in.defs;
                defs.out{1}.pull.interp=5;
                defs.out{1}.pull.mask=1;
                defs.out{1}.pull.fwhm=[0 0 0];
                defs.out{1}.pull.savedir.savesrc = 1 ;
                defs.comp{2}.idbbvox.vox= [1 1 1];
                defs.comp{2}.idbbvox.bb= [ -78  -112   -70
                    78    76    90 ] ;
                defs.comp{1}.def = {[a filesep 'y_' b c]};
                defs.out{1}.pull.fnames = {t1};
                
                obj.Params.spmT1_Proc.in.defs = defs;
                
                spm_deformations(defs);
                wasRun=true;
            end
            obj.Params.spmT1_Proc.out.normT1 = [a filesep 'w' b c];
            fprintf('%s\n', 'Normalization has been applied to the T1:');
            
            obj.Params.spmT1_Proc.out.estTPM{1,1} = [a filesep 'c1' b c];
            obj.Params.spmT1_Proc.out.estTPM{2,1} = [a filesep 'c2' b c];
            obj.Params.spmT1_Proc.out.estTPM{3,1} = [a filesep 'c3' b c];
            obj.Params.spmT1_Proc.out.estTPM{4,1} = [a filesep 'c4' b c];
            obj.Params.spmT1_Proc.out.estTPM{5,1} = [a filesep 'c5' b c];
            obj.Params.spmT1_Proc.out.estTPM{6,1} = [a filesep 'c6' b c];
            
            obj.Params.spmT1_Proc.out.regfile = [a filesep 'y_' b c];
            obj.Params.spmT1_Proc.out.iregfile = [a filesep 'iy_' b c];
            
            
            if wasRun == true
                %If exec_cmd has only one line, it won't wrtie to
                %obj.history so make sure you add a two liner exec_cmd on
                %the fly if you want output in obj.histoy as below:
                obj.UpdateHist_v2(obj.Params.spmT1_Proc,'proc_t1_spm()',[a filesep 'y_' b c],wasRun,{'To check:' ; 'check proc_t1_spm() method for more info.'});
                obj.resave();
            end
            fprintf('\n');
        end
       
        function obj = proc_getFreeSurfer(obj)
            wasRun=false;
            if ~exist('exec_cmd','var')
                exec_cmd{:}='#INIT PROC_getFreeSurfer()';
            end
            fprintf('\n%s\n', 'PERFORMING PROC_GETFREESURFER():');
            %display([ 'The whoami output is: obj.Params.FreeSurfer.shell ])
            
            %Assign directory where the T1/T2s were acquired:
            %T1_dir:
            [obj.Params.FreeSurfer.in.T1_dir, T1_fname, ~ ] = fileparts(obj.Params.FreeSurfer.in.T1raw);
            %T2_dir:
            if obj.Params.FreeSurfer.in.T2exist==true
                [obj.Params.FreeSurfer.in.T2_dir, ~, ~ ] = fileparts(obj.Params.FreeSurfer.in.T2raw);
            end
            
            %Doing Grad-non linearity in T1:
            if strcmp(obj.projectID,'ADRC')
                obj.Params.FreeSurfer.in.T1_grad_non = [obj.Params.FreeSurfer.in.T1_dir filesep 'gnc_T1.nii' ];
                
                %TO fix issues with previous unpack...
                [~, warpfile_tmp] =system(['ls  ' obj.Params.FreeSurfer.in.T1_dir filesep   '*_deform_grad_rel.nii' ])
                obj.Params.FreeSurfer.in.T1_warpfile = strtrim(warpfile_tmp);
                %obj.Params.FreeSurfer.in.T1_warpfile  = strtrim([obj.Params.FreeSurfer.in.T1_dir filesep  T1_fname '_deform_grad_rel.nii']);
                
                %Getting the warp fields....
                if exist( obj.Params.FreeSurfer.in.T1_warpfile, 'file' ) == 0 || obj.redo_history
                    exec_cmd{:,end+1}=['sh ' obj.sh_gradfile ' ' strtrim(obj.Params.FreeSurfer.in.T1raw) ' ' obj.Params.FreeSurfer.in.T1_grad_non ' ' obj.gradfile ' '];
                    obj.RunBash(exec_cmd{end},44);
                    %Re-evaluate warfile assignation...
                    [~, warpfile_tmp] =system(['ls  ' obj.Params.FreeSurfer.in.T1_dir filesep   '*_deform_grad_rel.nii' ])
                    obj.Params.FreeSurfer.in.T1_warpfile = strtrim(warpfile_tmp);
                end
                if exist(obj.Params.FreeSurfer.in.T1_grad_non , 'file' ) == 0 || obj.redo_history
                    %Applywing the warp fields...
                    fprintf(['\nGNC: Applying warp to T1: '  obj.Params.FreeSurfer.in.T1raw]);
                    exec_cmd{:,end+1}=[ obj.FSL_dir 'bin/applywarp  -i ' obj.Params.FreeSurfer.in.T1raw ' -r ' obj.Params.FreeSurfer.in.T1raw ...
                        ' -o ' obj.Params.FreeSurfer.in.T1_grad_non ' -w ' obj.Params.FreeSurfer.in.T1_warpfile ...
                        ' --interp=spline' ];
                    obj.RunBash(exec_cmd{end});
                    system(['gunzip ' obj.Params.FreeSurfer.in.T1_dir filesep '*.gz ']);
                    fprintf('...done\n');
                end
                obj.Params.FreeSurfer.in.T1=obj.Params.FreeSurfer.in.T1_grad_non;
            else
                %Assuming HABS datasets for now...(IMPLEMENT FOR OTHER IS
                %PRE-VALUES ARE NEEDED HERE)
                obj.Params.FreeSurfer.in.T1=obj.Params.FreeSurfer.in.T1raw;
            end
            
            %Doing Grad-non linearity in T2:
            if obj.Params.FreeSurfer.in.T2exist==true
                if strcmp(obj.projectID,'ADRC')
                    obj.Params.FreeSurfer.in.T2_grad_non = [obj.Params.FreeSurfer.in.T2_dir filesep 'gnc_T2.nii' ];
                    if exist(obj.Params.FreeSurfer.in.T2_grad_non , 'file' ) == 0 || obj.redo_history
                        %Applying the warip fields from the T1 (yielding similar results).
                        exec_cmd{:,end+1}=[ obj.FSL_dir 'bin/applywarp  -i ' obj.Params.FreeSurfer.in.T2raw ' -r ' obj.Params.FreeSurfer.in.T2raw ...
                            ' -o ' obj.Params.FreeSurfer.in.T2_grad_non ' -w ' obj.Params.FreeSurfer.in.T1_warpfile ...
                            ' --interp=spline' ];
                        fprintf(['\nGNC: Applying warp to T2: '  obj.Params.FreeSurfer.in.T2raw]);
                        obj.RunBash(exec_cmd{end});
                        system(['gunzip ' obj.Params.FreeSurfer.in.T2_dir filesep '*.gz ']);
                        fprintf('...done\n');
                    end
                    obj.Params.FreeSurfer.in.T2=obj.Params.FreeSurfer.in.T2raw;
                    
                else
                    %ASSUMING NOT PRE-ARRANGEMENT IS NEEDED. IF SO, IMPLEMENT:
                    obj.Params.FreeSurfer.in.T2=obj.Params.FreeSurfer.in.T2raw;
                end
            end
            
            
            %PREPARING THE SHELLS (THIS SHOULD CHANGE!!):
            if strcmp(obj.Params.FreeSurfer.shell,'bash') %due to launchpad errors, I decided to use this 'whoami' instead of shell. NEED TO FIX IT!
                export_shell=[ 'export FREESURFER_HOME=' obj.Params.FreeSurfer.init_location ' ; '...
                    ' source $FREESURFER_HOME/SetUpFreeSurfer.sh ;' ...
                    ' export SUBJECTS_DIR=' obj.Params.FreeSurfer.dir ' ; '];
            else
                export_shell=[ ' setenv FREESURFER_HOME ' obj.Params.FreeSurfer.init_location ' ; ' ...
                    ' source $FREESURFER_HOME/SetUpFreeSurfer.csh ; ' ...
                    ' setenv SUBJECTS_DIR ' obj.Params.FreeSurfer.dir ' ; '];
            end
            %APPLYING THE ACTUAL RECON-ALL:
            if exist(obj.Params.FreeSurfer.out.aparcaseg, 'file') == 0 || obj.redo_history
                %CHECKING RECON-ALL AND WHETHER A T2 IMAGE IS USED
                [~ , exec_FS ] = system('which recon-all ' );
                if obj.Params.FreeSurfer.in.T2exist==true
                    %use T2 for recon-all
                    exec_cmd{:,end+1}=[ export_shell ...
                        ' ' strtrim(exec_FS) ' -all -subjid ' obj.sessionname ...
                        ' -deface -i ' strtrim(obj.Params.FreeSurfer.in.T1) ...
                        ' -T2 ' strtrim(obj.Params.FreeSurfer.in.T2) ...
                        ' -hippocampal-subfields-T1T2 ' strtrim(obj.Params.FreeSurfer.in.T2) ' T2 -parallel -openmp 8 ' ];
                else
                    %no T2 so use only T1 for recon-all
                    exec_cmd{:,end+1}=[ export_shell ...
                        ' ' strtrim(exec_FS) ' -all  -subjid ' obj.sessionname ...
                        ' -deface -i ' strtrim(obj.Params.FreeSurfer.in.T1) ...
                        ' -hippocampal-subfields-T1  -parallel -openmp 8' ];
                end
                disp('Running FreeSurfer... (this will take ~<24 hours)')
                tic;
                %Running the script:
                obj.RunBash(exec_cmd{end},44); % '44' codes for seeing the output!
                %THE PREVIOUS LINE OF CODE MAY NOT WORK DUE TO PERMISSION
                %ERRORS READING /cluster/* folder. To see if this is not the
                %error try a simple `ls` command (e.g.  ls /cluster/cluster/HAB_Project1/FreeSurferv6.0/100902_4TT01167/mri %)
                obj.Params.FreeSurfer.out.timelapsed_mins=[ 'FreeSurfer took ' toc/60 ' minutes to complete'];
                disp('Done with FreeSurfer');
                wasRun=true;
            else
                [~,bb,cc ] = fileparts(obj.Params.FreeSurfer.out.aparcaseg) ;
                fprintf(['The aparc aseg file ' bb cc ' exists. \n' ]);
            end
            if wasRun== true
                obj.UpdateHist_v2(obj.Params.FreeSurfer,'proc_getFreeSurfer()', obj.Params.FreeSurfer.out.aparcaseg,wasRun,exec_cmd');
            end
            %OBSOLETE CODE, PLEASE REMOVE:
            %             %Convert final brain.mgz into brain.nii so it can be used for
            %             %normalization purposes
            %             %Brain into nii
            %             obj.Params.FreeSurfer.out.brain_mgz = strrep(obj.Params.FreeSurfer.out.aparcaseg,'aparc+aseg.mgz','brain.mgz');
            %             obj.Params.FreeSurfer.out.brain_nii = strrep(obj.Params.FreeSurfer.out.aparcaseg,'aparc+aseg.mgz','brain.nii');
            %             [~ , to_exec ] = system('which mri_convert');
            %             exec_cmd{6}=[ strtrim(to_exec) ' ' obj.Params.FreeSurfer.out.brain_mgz ' ' obj.Params.FreeSurfer.out.brain_nii ] ;
            %             if exist(obj.Params.FreeSurfer.out.brain_nii,'file') == 0
            %                 obj.RunBash(exec_cmd{6});
            %             end
            
            
            %             %Orig into nii
            %             obj.Params.FreeSurfer.out.orig_mgz = strrep(obj.Params.FreeSurfer.out.aparcaseg,'aparc+aseg.mgz','orig.mgz');
            %             obj.Params.FreeSurfer.out.orig_nii = strrep(obj.Params.FreeSurfer.out.aparcaseg,'aparc+aseg.mgz','orig.nii');
            %             exec_cmd{7}= [strtrim(to_exec)  ' ' obj.Params.FreeSurfer.out.orig_mgz ' ' obj.Params.FreeSurfer.out.orig_nii ] ;
            %             if exist(obj.Params.FreeSurfer.out.orig_nii,'file') == 0
            %                 obj.RunBash(exec_cmd{7});
            %             end

            
            %             %Update history if possible
            %             if ~isfield(obj.Params.FreeSurfer,'history_saved') || wasRun == true
            %                 obj.Params.FreeSurfer.history_saved = 0 ;
            %             end
            %             if obj.Params.FreeSurfer.history_saved == 0
            %                 obj.Params.FreeSurfer.history_saved = 1 ;
            %
            %                 obj.UpdateHist_v2(obj.Params.FreeSurfer,'proc_FreeSurfer', obj.Params.FreeSurfer.out.aparcaseg,wasRun,exec_cmd);
            %             end
            %END OF OBSOLETE CODE. 
        end
       
        function obj = proc_T1toDWI(obj)
            wasRun=false;
            fprintf('\n%s\n', 'PERFORMING PROC_T1toDWI():');
            if ~exist('exec_cmd','var')
                exec_cmd{:} = '#INIT PROC_T1toDWI()';
            end
            outpath=obj.getPath(obj.root,obj.Params.T1toDWI.in.movefiles);
            
            %Filepart the inputs
            [ ~, T1_bname, T1_ext ] = fileparts(obj.Params.T1toDWI.in.T1);
            [ ~, b0_bname, b0_ext ] = fileparts(obj.Params.T1toDWI.in.b0);
            
            %if files are *.nii.gz, then remove the *.nii as part of
            %thename:
            if strcmp(T1_bname(end-3:end),'.nii')
                T1_bname=T1_bname(1:end-4);
            end
            
            if strcmp(b0_bname(end-3:end),'.nii')
                b0_bname=b0_bname(1:end-4);
            end
            
            %Initialize output files
            obj.Params.T1toDWI.out.dir=outpath;
            obj.Params.T1toDWI.out.origT1 = [ outpath  T1_bname '.nii'];
            
            obj.Params.T1toDWI.out.T12b0 = [ outpath  'coreg2dwi_' T1_bname '.nii'];
            obj.Params.T1toDWI.out.reslicedT12b0 = [ outpath 'resliced_coreg2dwi_' T1_bname '.nii'];
            
            obj.Params.T1toDWI.out.gzip_reslicedT12b0 = [ outpath 'resliced_coreg2dwi_' T1_bname '.nii.gz'];
            
            %Unsliced T1:
            if exist(obj.Params.T1toDWI.out.reslicedT12b0,'file') ~= 0 || exist(obj.Params.T1toDWI.out.gzip_reslicedT12b0,'file') ~= 0 
                 display('proc_T1toDWI is complete.');
            else
                %MRI_convert to get the *.nii format
                display('Copying T1...');
                exec_cmd{:,end+1} = ['mri_convert ' strtrim(obj.Params.T1toDWI.in.T1) ' ' obj.Params.T1toDWI.out.origT1 ];
                obj.RunBash(exec_cmd{end});
      
                
                %Creating the CoReg.mat file:
                display('Creating CoReg.mat matrix...');
                exec_cmd{:,end+1} = 'obj.proc_coreg2dwib0(obj.Params.T1toDWI.out.origT1,obj.Params.T1toDWI.in.b0,outpath);';
                eval(exec_cmd{end});
                
                %Applying this CoReg.mat file:
                display('Applying the CoReg.mat matrix...');
                exec_cmd{:,end+1} = 'obj.proc_apply_coreg2dwib0(obj.Params.T1toDWI.out.origT1,1,obj.Params.T1toDWI.in.b0);';
                eval(exec_cmd{end});
                
                %BELOW GZIP IS COMMENTED OUT AS *.nii will be used in the
                %future. 
                %exec_cmd{:,end+1} = ['gzip '  obj.Params.T1toDWI.out.dir  '*.nii '] ;
                %obj.RunBash(exec_cmd{end});
                wasRun=true;
            end  
            
            %Update history if wasRun==1
             if wasRun == true
                obj.UpdateHist_v2(obj.Params.T1toDWI,'proc_T1toDWI()', obj.Params.T1toDWI.out.reslicedT12b0,wasRun,exec_cmd');
                obj.resave();
             end
        end
        
        function obj = proc_FS2dwi(obj)
            wasRun=false;
            fprintf('\n%s\n', 'PERFORMING PROC_FS2DWI():');
            if ~exist('exec_cmd','var')
                exec_cmd{:}='#INIT PROC_FS2dwi()';
            end
            %INIT SPECS:
            for tohide=1:1
                %Create folder to put ouput:
                [a, ~, ~] = fileparts(obj.Params.FS2dwi.in.b0{1});
                outpath=obj.getPath(a,obj.Params.FS2dwi.in.movefiles );
                %Init outputs:
                obj.Params.FS2dwi.out.xfm_dwi2FS = [ outpath 'xfm_dwi2FS.lta' ] ;
                obj.Params.FS2dwi.out.fn_aparc = [ outpath  'dwi_aparc+aseg.nii.gz' ] ;
                obj.Params.FS2dwi.out.fn_aparc2009 = [ outpath 'dwi_aparc.a2009+aseg.nii.gz' ] ;
                obj.Params.FS2dwi.out.hippofield_left = [ outpath  'dwi_hippofields_lh.nii.gz' ] ;
                obj.Params.FS2dwi.out.hippofield_right = [ outpath  'dwi_hippofields_rh.nii.gz' ] ;
                
                %Making directory for all the other output
                obj.RunBash(['mkdir -p ' outpath filesep 'aparc_aseg' filesep]);
                obj.RunBash(['mkdir -p ' outpath filesep 'aparc2009_aseg' filesep]);
                obj.RunBash(['mkdir -p ' outpath filesep 'hippos' filesep]);
                %Sourcing FS and SUBJECTS_DIR:
                if strcmp(obj.Params.FreeSurfer.shell,'bash') %due to launchpad errors, I decided to use this 'whoami' instead of shell. NEED TO FIX IT!
                    export_shell=[ 'export FREESURFER_HOME=' obj.Params.FreeSurfer.init_location ' ; '...
                        ' source $FREESURFER_HOME/SetUpFreeSurfer.sh ;' ...
                        ' export SUBJECTS_DIR=' obj.Params.FreeSurfer.dir ' ; '];
                else
                    export_shell=[ ' setenv FREESURFER_HOME ' obj.Params.FreeSurfer.init_location ' ; ' ...
                        ' source $FREESURFER_HOME/SetUpFreeSurfer.csh ; ' ...
                        ' setenv SUBJECTS_DIR ' obj.Params.FreeSurfer.dir ' ; '];
                end
            end
            %APARCASEG EXTRACTION:
            for tohide=1:1
                if exist(obj.Params.FS2dwi.in.aparcaseg, 'file') == 2
                   if exist(obj.Params.FS2dwi.out.xfm_dwi2FS,'file') == 0 || obj.redo_history
                        %bbreg b0 to FS_T1:
                        disp('proc_FS2dwi: Running bbreg dwi2FS_T1...')
                        %BBreg dwi (b0) to FS:
                        exec_cmd{:,end+1}=[ export_shell ...
                            obj.init_FS '/bin/bbregister --s ' obj.sessionname ...
                            ' --mov ' obj.Params.FS2dwi.in.b0{1} ...
                            ' --reg ' obj.Params.FS2dwi.out.xfm_dwi2FS ' --dti --init-fsl '];
                        obj.RunBash(exec_cmd{end},44); % '44' codes for seeing the output!
                        disp('..done');
                        wasRun=true;
                   end
                   %Check if aparc_aseg exists:
                   if exist(obj.Params.FS2dwi.out.fn_aparc,'file') == 0  || obj.redo_history
                        disp('proc_FS2dwi: Running bbreg in aparc+aseg.mgz...')
                        %Aparc+aseg to dwi using bbregister:
                        exec_cmd{:,end+1}=[ export_shell ' ' obj.init_FS '/bin/mri_vol2vol --mov ' obj.Params.FS2dwi.in.b0{1} ...
                            ' --targ ' obj.Params.FS2dwi.in.aparcaseg ...
                            ' --o ' obj.Params.FS2dwi.out.fn_aparc ...
                            ' --inv --nearest --reg ' obj.Params.FS2dwi.out.xfm_dwi2FS  ];
                        obj.RunBash(exec_cmd{end},44); % '44' codes for seeing the output!
                        disp('..done');
                        wasRun=true;
                    end
                    
                    %Extracting all ROIs for aparc:
                    [num_aparc name_aparc ] =textread(obj.Params.FS2dwi.in.tmpfile_aparcaseg,'%s %s');
                    %Looping on every image we included in temp. file:
                    for ff=1:numel(num_aparc)
                        tmp_curname{ff} = [ outpath  'aparc_aseg' filesep 'dwi_' name_aparc{ff} '.nii.gz'];
                        if exist(strtrim(tmp_curname{ff}), 'file') == 0  || obj.redo_history
                            fprintf(['Displaying now: ' tmp_curname{ff} '...' ] )
                            exec_cmd{:,end+1} = [ obj.FSL_dir 'bin/fslmaths '  obj.Params.FS2dwi.out.fn_aparc ...
                                ' -uthr ' num_aparc{ff} ' -thr ' num_aparc{ff} ...
                                ' -div '  num_aparc{ff} ' ' tmp_curname{ff} ] ;
                            obj.RunBash(exec_cmd{end});
                            fprintf('done \n')
                        end
                    end
                    fprintf('aparc+aseg extraction complete\n')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                else
                    error([ 'in proc_FS2dwi(obj): FS aparc_aseg (supposely) located in: ' obj.Params.FS2dwi.in.aparcaseg ' does not exist'])
                end
                fprintf('aparc+aseg extraction complete. \n')
            end
            
            %APARCASEGa2009 EXTRACTION:
            for tohide=1:1
                if exist(obj.Params.FS2dwi.in.aparcaseg2009,'file')==2
                    %Aparc.a2009+aseg to dwi:
                    if exist(obj.Params.FS2dwi.out.fn_aparc2009,'file') == 0 || obj.redo_history
                        %bbreg b0 to FS_T1:
                        disp('proc_FS2dwi: Running bbreg in aparc2009+aseg.mgz...')
                        exec_cmd{:,end+1}=[ export_shell ' ' obj.init_FS '/bin/mri_vol2vol --mov ' obj.Params.FS2dwi.in.b0{1} ...
                            ' --targ ' obj.Params.FS2dwi.in.aparcaseg2009 ...
                            ' --o '  obj.Params.FS2dwi.out.fn_aparc2009 ...
                            ' --inv --nearest --reg ' obj.Params.FS2dwi.out.xfm_dwi2FS  ];
                        obj.RunBash(exec_cmd{end},44); % '44' codes for seeing the output!
                        wasRun=true;
                        disp('..done');
                    end
                    %Extracting all ROIs for aparc2009:
                    [num_aparc2009 name_aparc2009 ] =textread(obj.Params.FS2dwi.in.tmpfile_aparcaseg2009,'%s %s');
                    clear tmp_curname;
                    %Looping on every image we included in temp. file:
                    for ff=1:numel(num_aparc2009)
                        tmp_curname{ff} = [ outpath  'aparc2009_aseg' filesep  'dwi_' name_aparc2009{ff}  '.nii.gz' ];
                        if exist(strtrim(tmp_curname{ff}), 'file') == 0 || obj.redo_history
                            fprintf(['Displaying now: ' tmp_curname{ff} '...' ] )
                            exec_cmd{:,end+1} = [ obj.FSL_dir  'bin/fslmaths  ' obj.Params.FS2dwi.out.fn_aparc ...
                                ' -uthr ' num_aparc2009{ff} ' -thr ' num_aparc2009{ff} ...
                                ' -div '  num_aparc2009{ff} ' ' tmp_curname{ff} ] ;
                            obj.RunBash(exec_cmd{end});
                            fprintf('done \n');
                            wasRun=true;
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                else
                    error([ 'in proc_FS2dwi(obj): FS aparc_aseg (supposely) located in: ' obj.Params.FS2dwi.out.fn_aparc2009 ' does not exist'])
                end
                fprintf('aparc+aseg2009 extraction complete. \n')
            end
            
            
            %(Creating using some scripts arguments for Viviana Siless TractClustering method)
            %WM_APARCASEGa2009 EXTRACTION:
            
            %mri_aparc2aseg --s 170810_8CSAD00153 --labelwm --hypo-as-wm --rip-unknown --labelwm --hypo-as-wm --rip-unknown --o wm2009parc_noctx.nii.gz
            %Creating newer parcellation wmparc2009
            obj.Params.FS2dwi.in.wm_aparcaseg2009 = strrep(obj.Params.FS2dwi.in.aparcaseg,'aparc+aseg.mgz','wmparc2009.nii.gz');
            if exist(obj.Params.FS2dwi.in.wm_aparcaseg2009 ,'file') == 0 || obj.redo_history
                disp('proc_FS2dwi: Running mri_aparc2aseg for creating wmparc2009.nii.gz...')
                exec_cmd{:,end+1}=[ export_shell ' ' obj.init_FS '/bin/mri_aparc2aseg  --s ' obj.sessionname ...
                    ' --labelwm --hypo-as-wm --rip-unknown --labelwm --hypo-as-wm --rip-unknown ' ...
                    ' --o '  obj.Params.FS2dwi.in.wm_aparcaseg2009 ...
                    ' --ctxseg aparc.a2009s+aseg.mgz ' ];
                obj.RunBash(exec_cmd{end},44); % '44' codes for seeing the output!
                wasRun=true;
                disp('..done');
            end
            %Moving newer parcellation into dwi space:
            obj.Params.FS2dwi.out.wm_aparcaseg2009 = strrep(obj.Params.FS2dwi.out.fn_aparc,'aparc+aseg.nii.gz','wmparc2009.nii.gz');
            for tohide=1:1
                if exist( obj.Params.FS2dwi.in.wm_aparcaseg2009,'file') ==2
                    %Aparc.a2009+aseg to dwi:
                    if exist(obj.Params.FS2dwi.out.wm_aparcaseg2009 ,'file') == 0 || obj.redo_history
                        %bbreg b0 to FS_T1:
                        disp('proc_FS2dwi: Running bbreg in wmparc2009.nii.gz...')
                        exec_cmd{:,end+1}=[ export_shell ' ' obj.init_FS '/bin/mri_vol2vol  --mov ' obj.Params.FS2dwi.in.b0{1} ...
                            ' --targ ' obj.Params.FS2dwi.in.wm_aparcaseg2009 ...
                            ' --o '   obj.Params.FS2dwi.out.wm_aparcaseg2009 ...
                            ' --inv --nearest --reg ' obj.Params.FS2dwi.out.xfm_dwi2FS  ];
                        obj.RunBash(exec_cmd{end},44); % '44' codes for seeing the output!
                        wasRun=true;
                        disp('..done');
                    end
                    %EXTRACTING ROIS NOT IMPLEMENTED AT THIS MOMEMT
%                     %(04/03/2018):
%                     %Extracting all ROIs for aparc2009:
%                     [num_aparc2009 name_aparc2009 ] =textread(obj.Params.FS2dwi.in.tmpfile_aparcaseg2009,'%s %s');
%                     clear tmp_curname;
%                     %Looping on every image we included in temp. file:
                    for ff=1:numel(num_aparc2009)
                        %FOR LOOPING NOT IMPLEMENTED AT THIS MOMEMT
                        %(04/03/2018)
%                         tmp_curname{ff} = [ outpath  'aparc2009_aseg' filesep  'dwi_' name_aparc2009{ff}  '.nii.gz' ];
%                         [~, to_exec ] = system('which fslmaths');
%                         if exist(strtrim(tmp_curname{ff}), 'file') == 0 || obj.redo_history
%                             fprintf(['Displaying now: ' tmp_curname{ff} '...' ] )
%                             exec_cmd{:,end+1} = [ 'fslmaths  ' obj.Params.FS2dwi.out.fn_aparc ...
%                                 ' -uthr ' num_aparc2009{ff} ' -thr ' num_aparc2009{ff} ...
%                                 ' -div '  num_aparc2009{ff} ' ' tmp_curname{ff} ] ;
%                             obj.RunBash(exec_cmd{end});
%                             fprintf('done \n');
%                             wasRun=true;
%                         end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                else
                    error([ 'in proc_FS2dwi(obj): FS wmaparc2009 (supposely) located in: ' obj.Params.FS2dwi.in.wm_aparcaseg2009 ' does not exist'])
                end
                fprintf('wmparc2009 extraction complete. \n')
            end
            
            
            %HIPPOFIELD_LEFT EXTRACTION:
            for tohide=1:1
                if exist( obj.Params.FS2dwi.in.hippofield_left ,'file') == 2
                    if exist(obj.Params.FS2dwi.out.hippofield_left,'file') == 0 || obj.redo_history
                        %bbreg b0 to FS_T1:
                        disp('proc_FS2dwi: Running bbreg in aparc+aseg.mgz...');
                        exec_cmd{:,end+1}=[ obj.init_FS '/bin/mri_vol2vol --mov ' obj.Params.FS2dwi.in.b0{1} ...
                            ' --targ ' obj.Params.FS2dwi.in.hippofield_left ...
                            ' --o ' obj.Params.FS2dwi.out.hippofield_left ...
                            ' --inv --nearest --reg ' obj.Params.FS2dwi.out.xfm_dwi2FS  ];
                        obj.RunBash(exec_cmd{end}); % '44' codes for seeing the output!
                        disp('..done');
                        wasRun=true;
                    end
                    
                    [num_hippo_lh name_hippo_lh ] =textread(obj.Params.FS2dwi.in.tmpfile_hippo_bil,'%s %s');
                    clear tmp_curname;
                    %Looping on every image we included in temp. file:
                    for ff=1:numel(num_hippo_lh)
                        tmp_curname{ff} = [ outpath  'hippos' filesep 'dwi_lh_' name_hippo_lh{ff} '.nii.gz' ];
                        if exist(strtrim(tmp_curname{ff}), 'file') == 0 || obj.redo_history
                            fprintf(['Displaying now: ' tmp_curname{ff} '...' ] )
                            exec_cmd{:,end+1} = [ obj.FSL_dir 'bin/fslmaths ' obj.Params.FS2dwi.out.hippofield_left ...
                                ' -uthr ' num_hippo_lh{ff} ' -thr ' num_hippo_lh{ff} ...
                                ' -div '  num_hippo_lh{ff} ' ' tmp_curname{ff} ] ;
                            obj.RunBash(exec_cmd{end});
                            fprintf('done \n')
                            wasRun=true;
                        end
                    end
                elseif strcmp(obj.Params.FS2dwi.in.hippofield_left ,'nothing')
                    display(['No hippofield_lh found in this processing. Skipping  for now...']);
                else
                    fprintf(['Need to run (or try): \n '  'export FREESURFER_HOME=' obj.Params.FreeSurfer.init_location ' ; '...
                        ' source $FREESURFER_HOME/SetUpFreeSurfer.sh ;' ...
                        ' export SUBJECTS_DIR=' obj.Params.FreeSurfer.dir ' ; ' ...
                        ' recon-all -s ' obj.sessionname ' -hippocampal-subfields-T2 ' obj.Params.FreeSurfer.in.T2 ...
                        ' T2'
                        ])
                    error([ 'in proc_FS2dwi(obj): FS hippofield_left (supposely) located in: ' obj.Params.FS2dwi.in.hippofield_left ' does not exist'])
                end
                fprintf('hippofield_lh extraction complete\n')
            end
            
            %HIPPOFIELD_RIGHT EXTRACTION:
            for tohide=1:1
                if exist( obj.Params.FS2dwi.in.hippofield_right ,'file') == 2
                    if exist(obj.Params.FS2dwi.out.hippofield_right,'file') == 0 || obj.redo_history
                        %bbreg b0 to FS_T1:
                        disp('proc_FS2dwi: Running bbreg in aparc+aseg.mgz...')
                        exec_cmd{:,end+1}=[ obj.init_FS '/bin/mri_vol2vol --mov ' obj.Params.FS2dwi.in.b0{1} ...
                            ' --targ ' obj.Params.FS2dwi.in.hippofield_right ...
                            ' --o ' obj.Params.FS2dwi.out.hippofield_right ...
                            ' --inv --nearest --reg ' obj.Params.FS2dwi.out.xfm_dwi2FS  ];
                        obj.RunBash(exec_cmd{end}); % '44' codes for seeing the output!
                        disp('..done');
                        wasRun=true;
                    end
                    
                    %Extracting all ROIs for aparc2009:
                    [num_hippo_rh name_hippo_rh ] =textread(obj.Params.FS2dwi.in.tmpfile_hippo_bil,'%s %s');
                    clear tmp_curname;
                    for ff=1:numel(num_hippo_rh)
                        tmp_curname{ff} = [outpath  'hippos' filesep 'dwi_rh_' name_hippo_rh{ff} '.nii.gz' ];
                        if exist(strtrim(tmp_curname{ff}), 'file') == 0 || obj.redo_history
                            fprintf(['Displaying now: ' tmp_curname{ff} '...' ] )
                            exec_cmd{:,end+1} = [ obj.FSL_dir 'bin/fslmaths ' obj.Params.FS2dwi.out.hippofield_right ...
                            ' -uthr ' num_hippo_rh{ff} ' -thr ' num_hippo_rh{ff} ...
                            ' -div '  num_hippo_rh{ff} ' ' tmp_curname{ff} ] ;
                            obj.RunBash(exec_cmd{end});
                            fprintf('done \n')
                            wasRun=true;
                        end
                    end
                elseif strcmp(obj.Params.FS2dwi.in.hippofield_right ,'nothing')
                    display(['No hippofield_lh found in this processing. Skipping  for now...']);
                else
                    error([ 'in proc_FS2dwi(obj): FS hippofield_right (supposely) located in: ' obj.Params.FS2dwi.in.hippofield_right ' does not exist'])
                end
                fprintf('hippofield_rh extraction complete\n')
            end
            
            %Update history if possible
            if wasRun == true
                obj.UpdateHist_v2(obj.Params.FS2dwi,'proc_FS2dwi()', tmp_curname{ff} , wasRun,exec_cmd'); 
                obj.resave();
            end
            
            %#########
            %Remove earlier .history_saved variable (previously create) that is not needed anymore
            if isfield( obj.Params.FS2dwi,'history_saved')
                obj.Params.FS2dwi=rmfield(obj.Params.FS2dwi,'history_saved');
            end
            clear exec_cmd  wasRun;
        end
             
        %Use when multiple DWIs sequences are acquired
        function obj = proc_mergeDWIs(obj,in,out)
            %in should be formatted: in.dwi in.bval in.bvec
            %out should be formatted: out.dwi out.bval out.bvec
            
            
            AA=2;
            if exist(out.dwi,'file') == 0
                tmp_nii = '' ;
                for ii=1:numel(in.dwi)
                    tmp_nii = [ tmp_nii in.dwi{ii} ' '  ] ;
                    if exist(in.bval{ii}, 'file' ) ~= 0 ;
                        tmp_bval{ii} = load(in.bval{ii});
                        if size(tmp_bval{ii},1) < size(tmp_bval{ii},2)  tmp_bval{ii} = tmp_bval{ii}' ; end
                    else
                        error(['File: ' in.bval{ii} ' doest not exist' ] );
                    end
                    if exist(in.bvec{ii}, 'file' ) ~= 0 ;
                        tmp_bvec{ii} = load(in.bvec{ii});
                        if size(tmp_bvec{ii},1) < size(tmp_bvec{ii},2) ; tmp_bvec{ii} = tmp_bvec{ii}' ; end
                    else
                        error(['File: ' in.bvec{ii} ' doest not exist' ] );
                    end
                end
                
                %Merging Niis:
                fprintf(['Merging using...']);
                toexec = [ 'fslmerge -t ' out.dwi ' ' tmp_nii ] ;
                fprintf([ toexec '\n']);
                system(toexec);
                fprintf('...done\n');
                
                %Is it in *.nii space? 
                [a , b, c ] = fileparts(out.dwi);
                if strcmp(c,'.nii')
                    fprintf('gunzipping...')
                    system(['gunzip ' out.dwi '.gz' ]);
                    fprintf('done\n');
                end
            else
                display([out.dwi ' exists. Nothing to do...']);
            end
            %Merging bvals and bvecs:
            if exist(out.bval,'file') == 0
                fileID=fopen(out.bval,'w');
                for ii=1:numel(in.bval)
                    fprintf(fileID,'%d \n',tmp_bval{ii});
                end
                fclose(fileID);
            end
            
            if exist(out.bvec,'file') == 0
                fileID=fopen(out.bvec,'w');
                for ii=1:numel(in.bvec)
                    fprintf(fileID,'%f %f %f \n',tmp_bvec{ii}'); %somehow transposing here for filewrite works correctly :/ 
                end
                fclose(fileID);
            end
        end
        
        function obj = proc_coreg_multiple(obj)
            wasRun=false;
            fprintf('\n%s\n', 'PERFORMING PROC_COREG_MULTIPLE():');
            if ~exist('exec_cmd','var')
                exec_cmd{:}='#INIT PROC_getFreeSurfer()';
            end
            %First, select the ref_files needed:
            for ii=1:numel(obj.Params.CoRegMultiple.in.fn)
                [a b c ] = fileparts(obj.Params.CoRegMultiple.in.fn{ii});
                outpath=obj.getPath(a,obj.Params.CoRegMultiple.in.movefiles);
                %Copy bvecs, bvals and fn
                obj.Params.CoRegMultiple.out.fn{ii} = [ outpath 'coreg_' b c ];
                obj.Params.CoRegMultiple.out.bvals{ii} = [ outpath 'coreg_' strrep(b,'.nii','.bvals') ] ;
                obj.Params.CoRegMultiple.out.bvecs{ii} = [ outpath 'coreg_' strrep(b,'.nii','.bvecs') ] ;
                
                if ii ==  obj.Params.CoRegMultiple.in.ref_iteration
                    tmp_b_split = strsplit(b,'_');
                    obj.Params.CoRegMultiple.in.ref_prefix = cell2char_rdp(strrep(tmp_b_split(end),'.nii',''));
                    obj.Params.CoRegMultiple.in.ref_file = obj.Params.CoRegMultiple.in.b0{ii};
                    %Copy the files in this for loop (since nothing will be done to ref)
                    if exist(obj.Params.CoRegMultiple.out.fn{ii},'file') == 0 || obj.redo_history
                        %*.nii.gz:
                        exec_cmd{:,end+1}=(['cp ' obj.Params.CoRegMultiple.in.fn{ii} ...
                            ' ' obj.Params.CoRegMultiple.out.fn{ii}  ]);
                        obj.RunBash(exec_cmd{end});
                        wasRun=true;
                    end
                    if exist(obj.Params.CoRegMultiple.out.bvals{ii},'file') == 0 || obj.redo_history
                        %*.bvals:
                        exec_cmd{:,end+1}=(['cp ' obj.Params.CoRegMultiple.in.bvals{ii} ...
                            ' ' obj.Params.CoRegMultiple.out.bvals{ii}  ]);
                        obj.RunBash(exec_cmd{end});
                        wasRun=true;
                    end
                    if exist(obj.Params.CoRegMultiple.out.bvecs{ii},'file') == 0 || obj.redo_history
                        %*.bvecs:
                        exec_cmd{:,end+1}=(['sh ' obj.col2rows_sh ' ' obj.Params.CoRegMultiple.in.bvecs{ii} ...
                            ' > ' obj.Params.CoRegMultiple.out.bvecs{ii}  ]);
                        obj.RunBash(exec_cmd{end});
                        wasRun=true;
                    end
                end
            end
            %Now apply flirt in all the other images:
            for ii=1:numel(obj.Params.CoRegMultiple.in.fn)
                %Initializing matfiles:
                [aa bb cc ] = fileparts(obj.Params.CoRegMultiple.in.fn{ii});
                tmp_bb_split = strsplit(bb,'_');
                obj.Params.CoRegMultiple.out.matfile{ii} = [ outpath ...
                    'xfm_b0' cell2char_rdp(strrep(tmp_bb_split(end),'.nii','_2_')) ...
                    obj.Params.CoRegMultiple.in.ref_prefix '.mat' ];
                %End of init
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ii ~=  obj.Params.CoRegMultiple.in.ref_iteration
                    %Dealing with *.nii.gz:
                    if exist(obj.Params.CoRegMultiple.out.matfile{ii},'file') == 0 || obj.redo_history
                        %Creating matfiles:
                        exec_cmd{:,end+1}=['flirt -in ' obj.Params.CoRegMultiple.in.b0{ii} ...
                            ' -ref ' obj.Params.CoRegMultiple.in.ref_file ...
                            ' -omat ' obj.Params.CoRegMultiple.out.matfile{ii} ...
                            ' -interp spline ' ];
                        fprintf(['\n proc_coreg_multiple: rigid coregistratio with iteration: ' num2str(ii)]);
                        obj.RunBash(exec_cmd{end});
                        wasRun=true;
                        fprintf('...done\n');
                    end
                    if exist(obj.Params.CoRegMultiple.out.fn{ii},'file') == 0 || obj.redo_history
                        %Applying the matfile from b0s:
                        exec_cmd{:,end+1}=(['applywarp -i ' obj.Params.CoRegMultiple.in.fn{ii} ' -r ' obj.Params.CoRegMultiple.in.ref_file ...
                            ' -o ' obj.Params.CoRegMultiple.out.fn{ii} ...
                            ' --postmat=' obj.Params.CoRegMultiple.out.matfile{ii} ' --interp=spline ' ]);
                        fprintf(['\n proc_coreg_multiple: applying warp (iter ' num2str(ii) ')']);
                        obj.RunBash(exec_cmd{end});
                        wasRun=true;
                        fprintf('...done\n');
                    end
                    
                    %Dealing with *.bvecs:
                    for tohide=1:1
                        if exist(obj.Params.CoRegMultiple.out.bvecs{ii},'file') == 0 || obj.redo_history
                            %*.bvecs:
                            %% from rows 3-by-XX to cols XX-by-3:
                            out_tmp_bvecs{ii}= [outpath 'tmp_bvecs_iter' num2str(ii) ] ;
                            if exist(out_tmp_bvecs{ii},'file') == 0 || obj.redo_history
                                exec_cmd{:,end+1}=(['sh ' obj.col2rows_sh ' ' obj.Params.CoRegMultiple.in.bvecs{ii} ...
                                    ' > ' out_tmp_bvecs{ii}  ]);
                                obj.RunBash(exec_cmd{end});
                                if  obj.redo_history
                                    system(exec_cmd{end});
                                end
                                wasRun=true;
                            end
                            %Extracting the rotation matrix only using
                            %avscale (this will be used for modifying
                            %the bvecs output)
                            tmp_rot_avscale{ii}= [outpath 'tmp_rotonly_iter' num2str(ii) ] ;
                            if exist(tmp_rot_avscale{ii}, 'file' ) == 0 || obj.redo_history
                                exec_cmd{:,end+1}=(['avscale ' obj.Params.CoRegMultiple.out.matfile{ii} ...
                                    ' | head -5 | tail -4 > ' tmp_rot_avscale{ii} ]);
                                obj.RunBash(exec_cmd{end});
                                wasRun=true;
                            end
                            %Now apply rotation values to the newer bvecs:
                            fprintf([' applying rotation only .mat files to bvecs..(iter:' num2str(ii) ') ']);
                            %if obj.redo_history
                                TEMP_BVEC{ii} = load(out_tmp_bvecs{ii});
                            %end
                            %remove cause it will be replaced:
                            if exist(obj.Params.CoRegMultiple.out.bvecs{ii},'file') == 2
                                system(['rm ' obj.Params.CoRegMultiple.out.bvecs{ii} ]);
                            end
                            for pp=1:size(TEMP_BVEC{ii},1)
                                exec_cmd{:,end+1}=[obj.b0MoCo_rotate_bvecs_sh ...
                                    ' ' num2str(TEMP_BVEC{ii}(pp,:)) ...
                                    ' ' tmp_rot_avscale{ii}  ...
                                    ' >> ' (obj.Params.CoRegMultiple.out.bvecs{ii}) ];
                                obj.RunBash(exec_cmd{end});
                                wasRun=true;
                            end
                            system(['rm ' tmp_rot_avscale{ii}]);
                            system(['rm ' out_tmp_bvecs{ii}]);
                            fprintf('...done');
                        end
                    end
                    %Copying bvals:
                    if exist(obj.Params.CoRegMultiple.out.bvals{ii},'file') == 0 || obj.redo_history
                        %*.bvals:
                        exec_cmd{:,end+1}=(['cp ' obj.Params.CoRegMultiple.in.bvals{ii} ...
                            ' ' obj.Params.CoRegMultiple.out.bvals{ii}  ]);
                        obj.RunBash(exec_cmd{end});
                        wasRun=true;
                    end
                end
            end
            %Creating the combined niftiis:
            for tohide=1:1
                obj.Params.CoRegMultiple.out.combined_fn = [outpath 'combined_preproc_' num2str(numel(obj.Params.CoRegMultiple.out.fn)) 'sets' '.nii.gz' ] ;
                if exist( obj.Params.CoRegMultiple.out.combined_fn , 'file') == 0 || obj.redo_history
                    tmp_nii_cmd = [] ;
                    for ii=1:numel(obj.Params.CoRegMultiple.out.fn)
                        if ii ~=  obj.Params.CoRegMultiple.in.ref_iteration
                            tmp_nii_cmd = [  tmp_nii_cmd ' ' obj.Params.CoRegMultiple.out.fn{ii} ] ;
                        end
                    end
                    exec_cmd{:,end+1} = [ 'fslmerge -t ' obj.Params.CoRegMultiple.out.combined_fn ...
                        ' ' obj.Params.CoRegMultiple.out.fn{obj.Params.CoRegMultiple.in.ref_iteration} ...
                        ' ' tmp_nii_cmd ];
                    fprintf('\nMerging niis...')
                    obj.RunBash(exec_cmd{end});
                    wasRun=true;
                    fprintf('...done\n');
                end
                
                %Combining bvals:
                obj.Params.CoRegMultiple.out.combined_bvals =  [outpath 'combined_preproc_' num2str(numel(obj.Params.CoRegMultiple.out.bvals)) 'sets' '.bvals' ] ;
                if exist( obj.Params.CoRegMultiple.out.combined_bvals , 'file') == 0 || obj.redo_history
                    tmp_bvals_cmd = [] ;
                    for ii=1:numel(obj.Params.CoRegMultiple.out.bvals)
                        if ii ~=  obj.Params.CoRegMultiple.in.ref_iteration
                            tmp_bvals_cmd = [  tmp_bvals_cmd ' ' obj.Params.CoRegMultiple.out.bvals{ii} ] ;
                        end
                    end
                    exec_cmd{:,end+1} = [ 'cat '  obj.Params.CoRegMultiple.out.bvals{obj.Params.CoRegMultiple.in.ref_iteration} ...
                        ' ' tmp_bvals_cmd ' > ' obj.Params.CoRegMultiple.out.combined_bvals     ];
                    fprintf('\nMerging bvals...')
                    obj.RunBash(exec_cmd{end});
                    wasRun=true;
                    fprintf('\n...done.')
                end
                
                %Combining bvecs:
                obj.Params.CoRegMultiple.out.combined_bvecs =  [outpath 'combined_preproc_' num2str(numel(obj.Params.CoRegMultiple.out.bvecs)) 'sets' '.bvecs' ] ;
                if exist(obj.Params.CoRegMultiple.out.combined_bvecs , 'file') == 0 || obj.redo_history
                    tmp_bvecs_cmd = [] ;
                    for ii=1:numel(obj.Params.CoRegMultiple.out.bvecs)
                        if ii ~=  obj.Params.CoRegMultiple.in.ref_iteration
                            tmp_bvecs_cmd = [  tmp_bvecs_cmd ' ' obj.Params.CoRegMultiple.out.bvecs{ii} ] ;
                        end
                    end
                    exec_cmd{:,end+1} = [ 'cat '  obj.Params.CoRegMultiple.out.bvecs{obj.Params.CoRegMultiple.in.ref_iteration} ...
                        ' ' tmp_bvecs_cmd ' > ' obj.Params.CoRegMultiple.out.combined_bvecs     ];
                    fprintf('\nMerging bvecs...')
                    obj.RunBash(exec_cmd{end});
                    wasRun=true;
                    fprintf('\n...done.')
                end
            end
            
            %Extracting the combined b0/mask:
            obj.Params.CoRegMultiple.out.combined_b0 = [outpath 'combined_preproc_b0.nii.gz'] ;
            obj.Params.CoRegMultiple.out.combined_bet = [outpath 'combined_preproc_bet.nii.gz'] ;
            
            obj.Params.CoRegMultiple.out.combined_mask = [outpath 'combined_preproc_bet_mask.nii.gz'] ;
            %b0:
            if exist(obj.Params.CoRegMultiple.out.combined_b0,'file') == 0 || obj.redo_history
                exec_cmd{:,end+1} = [ 'cp '  obj.Params.CoRegMultiple.in.b0{obj.Params.CoRegMultiple.in.ref_iteration} ...
                    ' ' obj.Params.CoRegMultiple.out.combined_b0 ];
                fprintf('\n Copying b0 combined...')
                obj.RunBash(exec_cmd{end});
                wasRun=true;
                fprintf('..done \n')
            end
            %bet and mask:
            if exist(obj.Params.CoRegMultiple.out.combined_bet,'file') == 0 || obj.redo_history
                exec_cmd{:,end+1} = [ 'bet2 ' obj.Params.CoRegMultiple.out.combined_b0 ...
                    ' ' obj.Params.CoRegMultiple.out.combined_bet  ' -f 0.3 -m ' ];
                fprintf('\n Bet masking combined...')
                obj.RunBash(exec_cmd{end});
                wasRun=true;
                fprintf('..done \n')
            end
            
            %Renaming the mask created in the previous step
            if exist([obj.Params.CoRegMultiple.out.combined_bet '_mask.nii.gz']) ~= 0
                if exist(obj.Params.CoRegMultiple.out.combined_mask,'file') == 0
                    movefile([obj.Params.CoRegMultiple.out.combined_bet '_mask.nii.gz'],  obj.Params.CoRegMultiple.out.combined_mask);
                end
            end
            if wasRun==true
                obj.UpdateHist_v2(obj.Params.CoRegMultiple,'proc_coreg_multiple()', obj.Params.CoRegMultiple.out.combined_bet,wasRun,exec_cmd');
                obj.resave();                
                %fprintf(' proc_coreg_multiple(obj) is complete\n');
            end
            
        end
        
        function obj = proc_dtifit(obj)
            wasRun=false; %internal flag denoting whether the last process in this method has been run
            fprintf('\n%s\n', 'PERFORMING PROC_DTIFIT():');
            if ~exist('exec_cmd','var')
                exec_cmd{:} = '#INIT PROC_DTIFIT()';
            end
            for ii=1:numel(obj.Params.Dtifit.in.fn)
                clear cur_fn;
                if iscell(obj.Params.Dtifit.in.fn{ii})
                    cur_fn=cell2char_rdp(obj.Params.Dtifit.in.fn{ii});
                else
                    cur_fn=obj.Params.Dtifit.in.fn{ii};
                end
                [a b c ] = fileparts(cur_fn);
                outpath=obj.getPath(a,obj.Params.Dtifit.in.movefiles);
                clear outfile
                %Init variable names:
                obj.Params.Dtifit.out.FA{ii} = [ outpath  obj.Params.Dtifit.in.prefix '_FA.nii.gz' ] ;
                obj.Params.Dtifit.out.prefix{ii} = [ outpath  obj.Params.Dtifit.in.prefix ];
                %Check if *FA.nii is unzipped, if so gzip it. 
                if exist(strrep(obj.Params.Dtifit.out.FA{ii},'.nii.gz','.nii'),'file')==2
                    system(['gzip ' strrep(obj.Params.Dtifit.out.FA{ii},'.nii.gz','.nii')]);
                end
                
                %Attempting to dtifit:
                if exist( obj.Params.Dtifit.out.FA{ii},'file')==0 || obj.redo_history
                    fprintf('Dtifit reconstruction...');
                    exec_cmd{:,end+1}=[  obj.FSL_dir 'bin/dtifit  -k ' obj.Params.Dtifit.in.fn{ii} ...
                        ' -o ' obj.Params.Dtifit.out.prefix{ii} ...
                        ' -m ' obj.Params.Dtifit.in.mask{ii} ...
                        ' -r ' obj.Params.Dtifit.in.bvecs{ii} ...
                        ' -b ' obj.Params.Dtifit.in.bvals{ii} ...
                        ' --wls --sse' ]; %weighted least squared for improving inadequate noisy data
                    obj.RunBash(exec_cmd{end},44);
                    fprintf('...done');
                    
                    fprintf('\nCopying L1 to AxD...');
                    exec_cmd{:,end+1} = [ 'cp  ' strrep(obj.Params.Dtifit.out.FA{ii},'FA','L1') ' ' strrep(obj.Params.Dtifit.out.FA{ii},'FA','AxD') ] ;
                    obj.RunBash(exec_cmd{end});
                    fprintf('...done');
                    wasRun=true;
                else
                    [~,bb,cc] = fileparts(obj.Params.Dtifit.out.FA{ii} );
                    fprintf([ 'File ' bb cc ' is now complete.\n'])
                end
                
                %Outputting RD:
                obj.Params.Dtifit.out.RD{ii} = strrep(obj.Params.Dtifit.out.FA{ii},'FA','RD');
                if exist(obj.Params.Dtifit.out.RD{ii},'file')==0 || obj.redo_history
                    fprintf('\nCreating RD dtifit...');
                    exec_cmd{:,end+1}=[ ' fslmaths ' strrep(obj.Params.Dtifit.out.FA{ii},'FA','L2') ...
                        ' -add ' strrep(obj.Params.Dtifit.out.FA{ii},'FA','L3') ...
                        ' -div 2 ' obj.Params.Dtifit.out.RD{ii}  ];
                    obj.RunBash(exec_cmd{end});
                    fprintf('...done \n');
                    wasRun=true;
                end
            end
            %Update history if possible
            if wasRun == true
                obj.UpdateHist_v2(obj.Params.Dtifit,'proc_dtifit()', obj.Params.Dtifit.out.RD{ii},wasRun,exec_cmd');
            end
        end
        
        function obj = proc_gqi(obj)
            wasRun=false;
            fprintf('\n%s\n', 'PERFORMING PROC_GQI():');
            if ~exist('exec_cmd','var')
                exec_cmd{:} = '#INIT PROC_GQI()';
            end
            for ii=1:numel(obj.Params.GQI.in.fn)
                clear cur_fn;
                if iscell(obj.Params.GQI.in.fn{ii})
                    cur_fn=cell2char_rdp(obj.Params.GQI.in.fn{ii});
                else
                    cur_fn=obj.Params.GQI.in.fn{ii};
                end
                [a b c ] = fileparts(cur_fn);
                outpath=obj.getPath(a,obj.Params.GQI.in.movefiles);
                clear outfile
                %Init variable names:
                obj.Params.GQI.out.btable{ii}= [ outpath  obj.Params.GQI.in.prefix '_btable.txt' ] ;
                %Attempting to create b_table:
                temp_bvecs{ii}=[ outpath 'temp.txt' ];
                if exist(obj.Params.GQI.out.btable{ii},'file')==0 || obj.redo_history
                    [~, nrow ]=system(['cat ' obj.Params.GQI.in.bvecs{ii} ' | wc -l | awk  '' {print $1} '' '  ] );
                    nrow=str2num(nrow);
                    if nrow == 3 ; %then its in column form, change it...
                        exec_cmd{:,end+1}=[ obj.col2rows_sh ' ' obj.Params.GQI.in.bvecs{ii} ...
                            ' > ' temp_bvecs{ii}];
                        obj.RunBash(exec_cmd{end});
                        wasRun=true;
                    else
                        exec_cmd{:,end+1}=[ 'cat ' obj.Params.GQI.in.bvecs{ii} ' >> ' temp_bvecs{ii} ];
                        obj.RunBash(exec_cmd{end});
                        wasRun=true;
                    end
                    %creating b-table now..
                    exec_cmd{:,end+1}=[' paste ' obj.Params.GQI.in.bvals{ii} ' ' ...
                        temp_bvecs{ii} ' | sed ''s/\t/ /g'' >' obj.Params.GQI.out.btable{ii}  ];
                    obj.RunBash(exec_cmd{end});
                    exec_cmd{:,end+1}=(['rm ' temp_bvecs{ii}]);
                    obj.RunBash(exec_cmd{end});
                    wasRun=true;
                end
                
                %NOW ATTEMPTING TO MODEL THE GQI MODEL:
                %Attempting to create the src.fz file:
                obj.Params.GQI.out.src_fn{ii} = [ outpath obj.Params.GQI.in.prefix '.src.gz' ];
                if exist(obj.Params.GQI.out.src_fn{ii},'file')==0 || obj.redo_history
                    fprintf('Source gz file reconstruction...');
                    exec_cmd{:,end+1}=[ '/usr/pubsw/packages/DSI-Studio/20170531/dsi_studio_run   --action=src ' ...
                        ' --source=' obj.Params.GQI.in.fn{ii} ...
                        ' --b_table=' obj.Params.GQI.out.btable{ii} ...
                        ' --output=' obj.Params.GQI.out.src_fn{ii} ];
                    obj.RunBash(exec_cmd{end},1); %for some reason the execution of system under obj.Bash exits with 1 hence 11 (probably a problem with compiled dsi_studio scripts) ce...:/
                    fprintf('...done\n');
                    pause(2) ; %this will add enough time for the src.gz to be completed before being read by fib.gz creation.
                    wasRun=true;
                else
                    [~, bb, cc ] = fileparts(obj.Params.GQI.out.src_fn{ii});
                    fprintf(['The file ' bb cc ' is complete\n']);
                end
                try
                    obj.Params.GQI.out.fibs_fn{ii} = ls([outpath '*gqi*.fib.gz' ] );
                    %strtrimming fibs:
                    obj.Params.GQI.out.fibs_fn{ii}= strtrim(obj.Params.GQI.out.fibs_fn{ii});
                catch
                    obj.Params.GQI.out.fibs_fn{ii} = '';
                end
                %Creating/verifying *.fib.gz existence:
                if isempty(obj.Params.GQI.out.fibs_fn{ii})
                    fprintf('Fib gz file reconstruction...');
                    %Attempting to create the fib.fz file:
                    exec_cmd{:,end+1}=[ '/usr/pubsw/packages/DSI-Studio/20170531/dsi_studio_run    --action=rec ' ...
                        ' --source=' obj.Params.GQI.out.src_fn{ii} ...
                        ' --method=' obj.Params.GQI.in.method ...
                        ' --num_fiber=' obj.Params.GQI.in.num_fiber ...
                        ' --param0=' obj.Params.GQI.in.param0 ...
                        ' --mask=' obj.Params. GQI.in.mask{ii} ];
                    obj.RunBash(exec_cmd{end},1);
                    fprintf('...done\n ');
                    wasRun=true;
                    %Assigning the fib_fn value again (if created)
                    try
                        obj.Params.GQI.out.fibs_fn{ii} = ls([outpath '*.fib.gz' ] );
                        %strtrimming fibs:
                        obj.Params.GQI.out.fibs_fn{ii}= strtrim(obj.Params.GQI.out.fibs_fn{ii});
                    catch
                        obj.Params.GQI.out.fibs_fn{ii} = '';
                    end
                else
                    [~, bb, cc ] = fileparts(obj.Params.GQI.out.fibs_fn{ii});
                    fprintf(['The file ' bb strtrim(cc) ' is complete \n']);
                end
                
                
                %EXTRACTING DIFFUSIVITY METRICS:
                obj.Params.GQI.out.fibs_GFA{ii} = [ strtrim(obj.Params.GQI.out.fibs_fn{ii}) '.gfa.nii.gz' ];
                %Now exporting some values (GFA,...):
                if exist(obj.Params.GQI.out.fibs_GFA{ii},'file') == 0 || obj.redo_history
                    exec_cmd{:,end+1}=([ '/usr/pubsw/packages/DSI-Studio/20170531/dsi_studio_run  --action=exp ' ...
                        ' --source=' strtrim(obj.Params.GQI.out.fibs_fn{ii}) ...
                        ' --export=' obj.Params.GQI.out.export ]);
                    obj.RunBash(exec_cmd{end},1);
                    wasRun=true;
                end
            end
            
            %Update history if possible
            if wasRun == true
                obj.UpdateHist_v2(obj.Params.GQI,'proc_gqi_fib()', strtrim(obj.Params.GQI.out.fibs_fn{ii}),wasRun,exec_cmd');
                obj.resave();
            end
            
            %#########
            %Remove earlier .history_saved variable (previously create) that is not needed anymore
            if isfield( obj.Params.GQI,'history_saved')
               obj.Params.GQI=rmfield(obj.Params.GQI,'history_saved');
            end
        end
        
        %Data management (datacentral) related  methods:
        function obj = getDB(obj)
            R = DataCentral(['SELECT * FROM Sessions.MRI WHERE MRI_Session_Name="' obj.sessionname '"']);
            obj.dbentry = R;
            try
                obj.collectiondate = R.MRI_SessionDate;
            catch
                disp('Cant get collectiondate')
            end
        end
        
        function obj = proc_getskeltois(obj)
            wasRun=false;
            fprintf('\n%s\n', 'PERFORMING PROC_GETSKELTOIS():');
            if ~exist('exec_cmd','var')
                exec_cmd{:} = '#INIT PROC_GETSKELTOIS()';
            end
            for kk=1:numel(obj.Params.Skeletonize.out.FA)
                for jj=1:numel( obj.Params.Skeletonize.out.diffmetrics)
                    for ii=1:numel(obj.Params.Skel_TOI.in.masks)
                        cur_name = [ obj.Params.Skeletonize.out.diffmetrics{jj} '_' obj.Params.Skel_TOI.in.masks{ii} obj.Params.Skel_TOI.in.suffix ] ;
                        %Init out field:
                        if ~isfield(obj.Params.Skel_TOI,'out')
                            obj.Params.Skel_TOI.out=[];
                        end
                        %init cur_name field:
                        if ~isfield(obj.Params.Skel_TOI.out,cur_name)
                            obj.Params.Skel_TOI.out.(cur_name) = '';
                        end
                        if isempty(obj.Params.Skel_TOI.out.(cur_name)) || size(obj.Params.Skel_TOI.out.(cur_name),2) ~= 10 %if not 10 characters, thena mistake occured!
                            cur_field=[ obj.Params.Skeletonize.out.diffmetrics{jj} ...
                                '_' obj.Params.Skel_TOI.in.masks{ii}  obj.Params.Skel_TOI.in.suffix ];
                            in_file=strrep(obj.Params.Skeletonize.out.FA{kk},'_FA.nii',[ '_' obj.Params.Skeletonize.out.diffmetrics{jj} '.nii' ] );
                            mask_file=[ obj.Params.Skel_TOI.in.location obj.Params.Skel_TOI.in.masks{ii}   '.nii.gz' ] ;
                            exec_cmd{:,end+1}=[ obj.FSL_DIR '/bin/fslstats  ' in_file ' -k ' mask_file ' -M '  ];
                            fprintf([ ' now in ' cur_name '\n'] );
                            [~ , obj.Params.Skel_TOI.out.(cur_name) ] =  system(exec_cmd{end});
                            
                            last_cur_name=cur_name;
                            wasRun=true;
                        end
                        clear cur_field  in_file out_file mask_file cur_name ;
                    end
                end
                fprintf('...done\n');
            end
            fprintf('proc_getskeltois() is complete.\n')
            
            
            %Update history if possible
            if ~isfield(obj.Params.Skel_TOI,'history_saved') || wasRun == true
                obj.Params.Skel_TOI.history_saved = 0 ;
            end
            if obj.Params.Skel_TOI.history_saved == 0
                obj.Params.Skel_TOI.history_saved = 1 ;
                obj.UpdateHist_v2(obj.Params.Skel_TOI,'proc_getskeltois()', obj.Params.Skeletonize.out.FA{end} , wasRun,exec_cmd'); %no file is created in this step but update it iteratively
            end
            clear exec_cmd  wasRun;
        end
        
        function obj = getdata_FreeSurfer(obj)
            fprintf('\n%s\n', 'EXTRACTING FREESURFER VALUES...');
            
            files = {[obj.FS_location filesep obj.sessionname filesep 'stats' filesep 'lh.aparc.stats'];
                [obj.FS_location filesep obj.sessionname filesep 'stats' filesep 'rh.aparc.stats'];
                [obj.FS_location filesep obj.sessionname filesep 'stats' filesep 'aseg.stats']};
            labs = {'lh' 'rh' 'vol'};
            
            %Apply for loop only if wasRun == true or field obj.FSdata.vol
            %does not exist
            
            for zz = 1:3
                tmp_all = ReadInFile(files{zz},'\t',0); tmp = tmp_all(contains_rdp20('^# ColHeaders',tmp_all):end);
                
                for ii = 1:50
                    tmp = regexprep(tmp,'  ', ' ');
                end
                
                tmp = regexp(tmp,' ','split');
                T = {};
                for ii = 1:numel(tmp);
                    if isempty(tmp{ii}{end}); tmp{ii} = tmp{ii}(1:end-1); end
                    if ii == 1
                        T(ii,:) = tmp{ii}(3:end);
                    else
                        if isempty(str2num(tmp{ii}{1}))
                            tmp{ii}([2:numel(tmp{ii})]) = num2cell(str2num(char(tmp{ii}([2:numel(tmp{ii})]))));
                        else
                            tmp{ii}([1:4 6:numel(tmp{ii})]) = num2cell(str2num(char(tmp{ii}([1:4 6:numel(tmp{ii})]))));
                        end
                        T(ii,:) = tmp{ii}(1:numel(tmp{ii}));
                    end
                end
                
                %Getting estimated measures
                if zz == 3 %In aparc.stats
                    col_estimatedMeas=tmp_all(contains_rdp20('^# Measure',tmp_all));
                    for jj=1:numel(col_estimatedMeas)
                        spl_TICV{jj}=strsplit(col_estimatedMeas{jj},', ');
                        T(end+1,4)=  num2cell(str2num(strrep(spl_TICV{jj}{end-1},',','')));
                        T(end,5) = {(strrep(spl_TICV{jj}{2},'.',''))};
                    end
                end
                obj.FSdata.(labs{zz}) = cell2table(T(2:end,:),'VariableName',T(1,:));
            end
            
            fprintf('...done \n');
        end
        
        %Datacentral DWIskel UPLOADS (used in HAB1 TBSS for now - 04/12/18)
        function obj = UploadData_DWI(obj,redo)
            id = obj.sessionname;
            if nargin < 2
                redo = false; %Flag to redo uplaoding if necesarry
            end
            %Add datacentral Params:
            if ~isfield(obj.Params,'DBupload')
                obj.Params.DBupload=[];
            end
            if ~isfield(obj.Params.DBupload,'skelDWI')
                obj.Params.DBupload.skelDWI = false;%Denotes whether the data was uploaded or not. Initialize as 'false' and change later in the method
            end
            
            if isempty(id);
                disp('No Session_ID.  Cannot upload data');
                return
            end
            
            if isnumeric(id)
                id = num2str(id);
            end
            
            redo_warning_flag=false; %denotes whether a warning for duplicated data exists! 
            
            %%Select current SessionID
            dctl_cmd = [ 'SELECT MRI_Session_ID FROM Sessions.MRI  WHERE ' ' MRI_Session_Name = ''' id '''' ];
            cur_DC_ID = DataCentral(dctl_cmd);
            
            %%Eddymotion uploading ( DataCetral FIELDS <--->
            %%ObjectDatafields:
            MOTION_DBfields   = { 'initb0_mean' 'initb0_std' 'rel_mean' 'rel_std'  } ;
            MOTION_datafields = { 'initb0_mean_grandtotal'  'initb0_std_grandtotal' 'rel_mean_grandtotal' 'rel_std_grandtotal'  }' ; 
            if  ~obj.Params.DBupload.skelDWI || redo == true  % <~~~denotes whether data was previously output!
                %Motion vals to upload:
                for ii=1:numel(MOTION_DBfields)
                    if ~isfield(obj.Params.EddyMotion,'out')
                        obj.proc_get_eddymotion();
                    else
                        fprintf(['\nUploading motion value: ' MOTION_datafields{ii} '(' ...
                            strtrim(num2str(obj.Params.EddyMotion.out.vals.(MOTION_datafields{ii})))  ') for ' obj.sessionname ]);
                        dctl_cmd = [ ' SELECT MRI_skelDWI_motion_eddyres_' MOTION_DBfields{ii} ...
                            ' FROM MRI.skelDWI  WHERE MRI_Session_ID = ' num2str(cur_DC_ID.MRI_Session_ID)  ];
                        check_dctl_cmd = DataCentral(dctl_cmd);
                        if isempty(check_dctl_cmd.(['MRI_skelDWI_motion_eddyres_' MOTION_DBfields{ii}]))
                            fprintf(['Motion values: ' MOTION_datafields{ii} ' is: '   ])
                            dctl_cmd = [ 'INSERT INTO MRI.skelDWI (MRI_Session_ID,  MRI_skelDWI_motion_eddyres_' MOTION_DBfields{ii} ') ' ...
                                ' values ( ' num2str(cur_DC_ID.MRI_Session_ID) ',' strtrim(num2str(obj.Params.EddyMotion.out.vals.(MOTION_datafields{ii}))) ')'   ] ;
                            DataCentral(dctl_cmd);
                            fprintf('...done\n');
                        elseif isnan(check_dctl_cmd.(['MRI_skelDWI_motion_eddyres_' MOTION_DBfields{ii}]))
                            fprintf(['Skel TOI ==> Uploading to DataCentral: ' id ' and TOI: ' MOTION_datafields{ii}  ])
                            dctl_cmd = [ 'UPDATE MRI.skelDWI SET MRI_skelDWI_motion_eddyres_' MOTION_DBfields{ii} ...
                                ' = ''' strtrim(num2str(obj.Params.EddyMotion.out.vals.(MOTION_datafields{ii}))) ''' WHERE MRI_Session_ID =  ' ...
                                num2str(cur_DC_ID.MRI_Session_ID)   ] ;
                            DataCentral(dctl_cmd);
                            fprintf('...done\n');
                        else
                            if ~redo
                                display(['\nDB~~~> Eddy motion values for: ' obj.sessionname  ' exists.\n'])
                                display(['If you want to re-insert, run obj.UploadData_DWI(true), using the first argument as a ''redo'' flag\n']);
                                redo_warning_flag=true;
                            else
                                fprintf(['Skel TOI ==> Uploading to DataCentral: ' id ' and TOI: ' MOTION_datafields{ii}  ])
                                dctl_cmd = [ 'UPDATE MRI.skelDWI SET MRI_skelDWI_motion_eddyres_' MOTION_DBfields{ii} ...
                                    ' = ''' strtrim(num2str(obj.Params.EddyMotion.out.vals.(MOTION_datafields{ii}))) ''' WHERE MRI_Session_ID =  ' ...
                                    num2str(cur_DC_ID.MRI_Session_ID)   ] ;
                                DataCentral(dctl_cmd);
                                fprintf('...done\n');
                            end
                        end
                    end
                end
                %%Skel vals to upload
                TOI_fields=fields(obj.Params.Skel_TOI.out);
                fprintf('\n skelDWIs Uploading ~~> ');
                for ii=1:numel(TOI_fields)
                    dctl_cmd = [ ' SELECT MRI_skelDWI_' TOI_fields{ii} ...
                        ' FROM MRI.skelDWI  WHERE MRI_Session_ID = ' num2str(cur_DC_ID.MRI_Session_ID)  ];
                    check_dctl_cmd = DataCentral(dctl_cmd);
                    
                    %Add 1000 to AxD, RD, and MD
                    if isempty(strfind(TOI_fields{ii},'FA'))
                        cur_value=strtrim(num2str(str2num(obj.Params.Skel_TOI.out.(TOI_fields{ii}))*1000));
                    else
                        cur_value=strtrim(obj.Params.Skel_TOI.out.(TOI_fields{ii}));
                    end
                    
                    if isempty(check_dctl_cmd.(['MRI_skelDWI_' TOI_fields{ii}]))
                        fprintf(['Skel TOI ==> Uploading to DataCentral: ' id ' and TOI: ' TOI_fields{ii}  ])
                        dctl_cmd = [ 'INSERT INTO MRI.skelDWI (MRI_Session_ID,  MRI_skelDWI_' TOI_fields{ii} ') ' ...
                            ' values ( ' num2str(cur_DC_ID.MRI_Session_ID) ',' cur_value ')'   ] ;
                        DataCentral(dctl_cmd);
                        fprintf('...done\n');
                    elseif isnan(check_dctl_cmd.(['MRI_skelDWI_' TOI_fields{ii}]))
                        fprintf(['Updating ' TOI_fields{ii} ]);
                        dctl_cmd = [ 'UPDATE MRI.skelDWI SET MRI_skelDWI_' TOI_fields{ii} ...
                            ' = ''' cur_value ''' WHERE MRI_Session_ID =  ' ...
                            num2str(cur_DC_ID.MRI_Session_ID)   ] ;
                        DataCentral(dctl_cmd);
                        fprintf('...done\n');
                    else
                        if redo
                            fprintf([TOI_fields{ii} '...' ])
                            if mod(ii,4) == 0
                                fprintf('\n');
                            end
                            dctl_cmd = [ 'UPDATE MRI.skelDWI SET MRI_skelDWI_' TOI_fields{ii} ...
                                ' = ''' cur_value ''' WHERE MRI_Session_ID =  ' ...
                                num2str(cur_DC_ID.MRI_Session_ID)   ] ;
                            DataCentral(dctl_cmd);
                            fprintf('...done\n');
                        else
                            disp(['skelDWI data for ' obj.sessionname ' and tract: ' TOI_fields{ii} 'exists. Please run obj.UploadDAta_DWI(true) to re-upload']); %Skip uploading because it already exists!
                            redo_warning_flag=true;
                        end
                    end
                end
                disp('skelTOIs values have been uploaded to DataCentral');
                obj.Params.DBupload.skelDWI = true;
                if redo_warning_flag
                    warning('Some fields were not replaced as obj.UploadDAta_DWI(true) was not used with ''redo'' as the 1st true argument. Please check!')
                    fprintf('Leaving obj.UploadData_DWI() ...\n \n ');
                    pause(1)
                end
                
            else
                disp('skelTOIs values have been already uploaded/ Nothing to do...');
            end
        end
        
        %TBSS related:
        function obj = proc_antsreg(obj)
            wasRun=false;
            if ~exist('exec_cmd','var')
                exec_cmd{:} = '#INIT PROC_ANTSREG()';
            end
            fprintf('\n%s\n', 'PERFORMING PROC_ANTSREG() :');
            for ii=1:numel(obj.Params.AntsReg.in.fn)
                clear cur_fn;
                if iscell(obj.Params.AntsReg.in.fn{ii})
                    cur_fn=cell2char_rdp(obj.Params.AntsReg.in.fn{ii});
                else
                    cur_fn=obj.Params.AntsReg.in.fn{ii};
                end
                [a b c ] = fileparts(cur_fn);
                outpath=obj.getPath(a,obj.Params.AntsReg.in.movefiles);
                clear outfile
                obj.Params.AntsReg.out.fn{ii} = [ outpath obj.Params.AntsReg.in.prefix 'Warped.nii.gz' ];
                if exist(obj.Params.AntsReg.out.fn{ii},'file')==0 || obj.redo_history
                    % [~, to_exec ] = system('which
                    %exec_cmd{:,end+1}=[ strtrim(to_exec) ' '  ...
                    % NOTE: antsRegistrationSyN.sh'); %due to many versions, we
                    % modify this and call the one we needed explicitly
                    % with obj.Params.AntsReg.in.run_ants
                    run_path = obj.addtoSHELLPATH(obj.Params.AntsReg.in.run_ants);
                    exec_cmd{:,end+1}=[ run_path  ' antsRegistrationSyN.sh  '  ...
                        obj.Params.AntsReg.in.antsparams ...
                        ' -f '  obj.Params.AntsReg.in.ref ...
                        ' -m '  obj.Params.AntsReg.in.fn{ii} ...
                        ' -o '  [ outpath obj.Params.AntsReg.in.prefix]  ];
                    fprintf('\nCoregistering Ants to reference... ');
                    tic
                    obj.RunBash(exec_cmd{end},44)
                    obj.Params.AntsReg.out.time_taken=[ toc ' seconds'];
                    fprintf('...done.\n');
                    wasRun=true;
                else
                    [~, bb,cc ] = fileparts(obj.Params.AntsReg.out.fn{ii} );
                    fprintf(['The file ' bb cc ' is complete (' obj.sessionname  ')\n']) ;
                end
                for tocomment_diffmetrics=1:1
                    obj.Params.AntsReg.out.FA{ii} = [ outpath obj.Params.AntsReg.in.prefix 'FA.nii.gz' ];
                     if  exist(obj.Params.AntsReg.out.FA{ii},'file')==0
                         fprintf('\n Warping dtifit metrics...');
                         %FA:                         
                         %[~, to_exec ] = system('which WarpImageMultiTransform');
                         %exec_cmd{:,end+1}=[ strtrim(to_exec)  ' 3 ' ...
                         run_path = obj.addtoSHELLPATH(obj.Params.AntsReg.in.run_ants);
                         exec_cmd{:,end+1}=[ run_path ' WarpImageMultiTransform 3 ' ...
                             ' ' obj.Params.Dtifit.out.FA{ii}  ...
                             ' ' obj.Params.AntsReg.out.FA{ii} ...
                             ' -R '  obj.Params.AntsReg.in.ref ...
                             ' ' strrep(obj.Params.AntsReg.out.fn{ii},'_Warped','_1Warp') ...
                             ' ' strrep(obj.Params.AntsReg.out.fn{ii},'_Warped.nii.gz','_0GenericAffine.mat')];
                         fprintf('FA...');
                         obj.RunBash(exec_cmd{end});
                         %RD:
                         %exec_cmd{:,end+1}=[ strtrim(to_exec) ' 3 ' ...
                         exec_cmd{:,end+1}=[ obj.Params.AntsReg.in.run_ants filesep 'WarpImageMultiTransform 3  '  ...
                             ' ' obj.Params.Dtifit.out.RD{ii}  ...
                             ' ' strrep(obj.Params.AntsReg.out.FA{ii},'FA','RD') ...
                             ' -R '  obj.Params.AntsReg.in.ref ...
                             ' ' strrep(obj.Params.AntsReg.out.fn{ii},'_Warped','_1Warp') ...
                             ' ' strrep(obj.Params.AntsReg.out.fn{ii},'_Warped.nii.gz','_0GenericAffine.mat') ];
                         fprintf('RD...');
                         obj.RunBash(exec_cmd{end});
                         %AxD:
                         %exec_cmd{:,end+1}=[ strtrim(to_exec) ' 3 ' ...
                         exec_cmd{:,end+1}=[ obj.Params.AntsReg.in.run_ants filesep 'WarpImageMultiTransform 3  '  ...    
                             ' ' strrep(obj.Params.Dtifit.out.FA{ii},'FA','L1') ...
                             ' ' strrep(obj.Params.AntsReg.out.FA{ii},'FA','AxD') ...
                             ' -R '  obj.Params.AntsReg.in.ref ...
                             ' ' strrep(obj.Params.AntsReg.out.fn{ii},'_Warped','_1Warp') ...
                             ' ' strrep(obj.Params.AntsReg.out.fn{ii},'_Warped.nii.gz','_0GenericAffine.mat') ];
                         fprintf('AxD...');
                         obj.RunBash(exec_cmd{end});
                         %MD:
                         %exec_cmd{:,end+1}=[ strtrim(to_exec) ' 3 ' ...
                         exec_cmd{:,end+1}=[ obj.Params.AntsReg.in.run_ants filesep 'WarpImageMultiTransform 3  '  ...
                             ' ' strrep(obj.Params.Dtifit.out.FA{ii},'FA','MD')  ...
                             ' ' strrep(obj.Params.AntsReg.out.FA{ii},'FA','MD') ...
                             ' -R '  obj.Params.AntsReg.in.ref ...
                             ' ' strrep(obj.Params.AntsReg.out.fn{ii},'_Warped','_1Warp') ...
                             ' ' strrep(obj.Params.AntsReg.out.fn{ii},'_Warped.nii.gz','_0GenericAffine.mat') ];
                         fprintf('MD...');
                         obj.RunBash(exec_cmd{end});
                         fprintf('...done.\n');
                         wasRun=true;
                    end
                end
            end
            
            %Update history if possible
            if wasRun == true
                obj.UpdateHist_v2(obj.Params.AntsReg,'proc_antsReg()', obj.Params.AntsReg.out.fn{ii},wasRun,exec_cmd');
                obj.resave();
            end
            clear exec_cmd to_exec wasRun;
            
            %#########
            %Remove earlier .history_saved variable (previously create) that is not needed anymore
            if isfield( obj.Params.AntsReg,'history_saved')
                obj.Params.AntsReg=rmfield(obj.Params.AntsReg,'history_saved');
                obj.resave();
            end
            
        end
        
          
        function obj = proc_skeletonize(obj)
            wasRun=false;
            if ~exist('exec_cmd','var')
                exec_cmd{:} = '#INIT PROC_SKELETONIZE()';
            end
            fprintf('\n%s\n', 'PERFORMING PROC_SKELETONIZE():');
            for ii=1:numel(obj.Params.Skeletonize.in.fn)
                clear cur_fn;
                if iscell(obj.Params.Skeletonize.in.fn{ii})
                    cur_fn=cell2char_rdp(obj.Params.Skeletonize.in.fn{ii});
                else
                    cur_fn=obj.Params.Skeletonize.in.fn{ii};
                end
                [a, ~, ~] = fileparts(cur_fn);
                outpath=obj.getPath(a,obj.Params.Skeletonize.in.movefiles);
                clear outfile
                obj.Params.Skeletonize.out.fn{ii} = [ outpath obj.Params.Skeletonize.in.prefix '.nii.gz' ];
                if exist(obj.Params.Skeletonize.out.fn{ii},'file')==0 || obj.redo_history
                    exec_cmd{:,end+1}=[  obj.FSL_dir '/bin/tbss_skeleton ' ...
                        ' -i '  obj.Params.Skeletonize.in.meanFA ...
                        ' -p '  obj.Params.Skeletonize.in.thr ...
                        ' '  obj.Params.Skeletonize.in.skel_dst ...
                        ' '  obj.Params.Skeletonize.in.ref_region  ...
                        ' '  obj.Params.Skeletonize.in.fn{ii} ...
                        ' '  obj.Params.Skeletonize.out.fn{ii} ];
                    fprintf('\nSkeletonizing to reference... ');
                    tic
                    %Running the object:
                    obj.RunBash(exec_cmd{end});
                    fprintf('...done.\n');
                    wasRun=true;
                else
                    [ ~ , bb, cc ] = fileparts(obj.Params.AntsReg.out.fn{ii});
                    fprintf(['The file ' bb cc ' is complete.\n']) ;
                end
                %NOW OTHER METRICS:
                obj.Params.Skeletonize.in.FA{ii}  = obj.Params.AntsReg.out.FA{ii} ;
                obj.Params.Skeletonize.out.FA{ii} = [ outpath obj.Params.Skeletonize.in.prefix '_FA.nii.gz' ];
                [ ~ , bbb, ccc ] = fileparts(obj.Params.Skeletonize.out.FA{ii});
                if exist(obj.Params.Skeletonize.out.FA{ii},'file')==0 || obj.redo_history
                    fprintf('\nSkeletonizing  dtimetrics... ');
                    %FA:
                    exec_cmd{:,end+1} =[ 'cp ' obj.Params.Skeletonize.out.fn{ii} ' ' obj.Params.Skeletonize.out.FA{ii} ];
                    fprintf('...FA');
                    obj.RunBash(exec_cmd{end});
                    %RD:
                    exec_cmd{:,end+1}=[ obj.FSL_dir '/bin/tbss_skeleton ' ...
                        ' -i '  obj.Params.Skeletonize.in.meanFA ...
                        ' -p '  obj.Params.Skeletonize.in.thr ...
                        ' '  obj.Params.Skeletonize.in.skel_dst ...
                        ' '  obj.Params.Skeletonize.in.ref_region  ...
                        ' '  obj.Params.Skeletonize.in.FA{ii} ...
                        ' '  strrep(obj.Params.Skeletonize.out.FA{ii},'FA','RD') ...
                        ' -a ' strrep(obj.Params.Skeletonize.in.FA{ii},'FA','RD')  ];
                    fprintf('...RD');
                    obj.RunBash(exec_cmd{end});
                    %AxD:
                    exec_cmd{:,end+1}=[obj.FSL_dir '/bin/tbss_skeleton ' ...
                        ' -i '  obj.Params.Skeletonize.in.meanFA ...
                        ' -p '  obj.Params.Skeletonize.in.thr ...
                        ' '  obj.Params.Skeletonize.in.skel_dst ...
                        ' '  obj.Params.Skeletonize.in.ref_region  ...
                        ' '  obj.Params.Skeletonize.in.FA{ii} ...
                        ' '  strrep(obj.Params.Skeletonize.out.FA{ii},'FA','AxD') ...
                        ' -a ' strrep(obj.Params.Skeletonize.in.FA{ii},'FA','AxD')  ];
                    fprintf('...AxD');
                    obj.RunBash(exec_cmd{end});
                    
                    %MD:
                    exec_cmd{:,end+1}=[ obj.FSL_dir '/bin/tbss_skeleton ' ...
                        ' -i '  obj.Params.Skeletonize.in.meanFA ...
                        ' -p '  obj.Params.Skeletonize.in.thr ...
                        ' '  obj.Params.Skeletonize.in.skel_dst ...
                        ' '  obj.Params.Skeletonize.in.ref_region  ...
                        ' '  obj.Params.Skeletonize.in.FA{ii} ...
                        ' '  strrep(obj.Params.Skeletonize.out.FA{ii},'FA','MD') ...
                        ' -a ' strrep(obj.Params.Skeletonize.in.FA{ii},'FA','MD')];
                    fprintf('...MD');
                    obj.RunBash(exec_cmd{end});
                    fprintf('...done\n');
                    wasRun = true;
                else
                    [~, bb, cc ] = fileparts(obj.Params.AntsReg.out.fn{ii});
                    fprintf(['The file ' bbb ccc ' and others are completed (' obj.sessionname  ')\n']) ;
                    
                end
                obj.Params.Skeletonize.out.diffmetrics={ 'FA' 'RD' 'AxD' 'MD' } ;
            end
            %Update history if possible
            if wasRun == true
                obj.UpdateHist_v2(obj.Params.Skeletonize,'proc_skeletonize()', strrep(obj.Params.Skeletonize.in.FA{ii},'FA','MD'),wasRun,exec_cmd');
                obj.resave();
            end
            %Remove earlier .history_saved variable (previously created) that is not needed anymore
            if isfield( obj.Params.Skeletonize,'history_saved')
                obj.Params.Skeletonize=rmfield(obj.Params.Skeletonize,'history_saved');
                obj.resave();
            end
            clear exec_cmd  wasRun;
        end
        
        %!!!
        %DEPRECATED methods: Methods that were not finished and unusable but the code could be recycle 
        function obj = deprecated_proc_FROIS2dwi(obj)
            wasRun=false;
            fprintf('\n%s\n', 'PERFORMING PROC_FROIS2DWI():');
            [a, ~, ~ ] = fileparts(obj.Params.FROIS2dwi.in.fn);
            outpath=obj.getPath(a,obj.Params.FROIS2dwi.in.movefiles);
            
            %make a list of all *.gz that exist in that direcotry
            [ok_check, tmp_frois_list ]  = system(['ls -1 '  ...
                obj.Params.FROIS2dwi.in.FROIS_dir '*.nii.gz']);
            if ok_check ~= 0
                error(['In proc_FROIS2dwi(): cannot find any *.nii.gz images in:'...
                    obj.Params.FROIS2dwi.in.FROIS_dir 'Double check']);
            end
            
            tmp_cellarray=textscan(tmp_frois_list,'%s');
            obj.Params.FROIS2dwi.in.FROIS_list=tmp_cellarray{1};
            
            
            %Check if the MNI_T1 exists....
            if exist(obj.Params.FROIS2dwi.in.MNI_T1,'file') == 0
                error(['In proc_FROIS2dwi(): Cannnot find the MNI_T1 in:' obj.Params.FROIS2dwi.in.MNI_T1 ] );
            end
            
            %Assigend outpath of coreg using ants
            obj.Params.FROIS2dwi.out.MNI_2_dwi = [ outpath obj.Params.FROIS2dwi.in.prefix 'Warped.nii.gz' ];
            if exist(obj.Params.FROIS2dwi.out.MNI_2_dwi ,'file')==0
                fprintf('\n In proc_FROIS(): Coregistering Ants to reference... ');
                aa=1;
                %obj.proc_as_coreg(obj.Params.FROIS2dwi.in.FROIS_list
                fprintf('...done.\n');
            end
        end
        
        function obj = deprecated_proc_b0s_MoCo(obj)
            %Motion Correction for interspersed b0s.
            wasRun=false;
            fprintf('\n%s\n', 'PERFORMING MOTION CORRECTION - PROC_B0S_MOCO():');
            if ~exist('exec_cmd')
                exec_cmd{:}='#INIT PROC_B0s_MOCO()';
            end
            %Check if the FreeSurfer location exists (due to bbreg dependency):
            if exist(obj.Params.B0MoCo.FS,'dir') ~=0 %if so continue, else break!
                for jj=1:numel(obj.Params.B0MoCo.in.fn)
                %%%%%%%%STEP 1: SPLIT EACH DWI INTO MULTIPLE 3D VOLUMES%%%%%%%%%%%%%%%%%%
                    clear cur_fn;
                    %Variable type fixing issues:
                    if iscell(obj.Params.B0MoCo.in.fn{jj})
                        cur_fn=cell2char_rdp(obj.Params.B0MoCo.in.fn{jj});
                    else
                        cur_fn=obj.Params.B0MoCo.in.fn{jj};
                    end
                    %Splitting the naming convention:
                    [a b c ] = fileparts(cur_fn);
                    %Creating an output directory:
                    outpath=obj.getPath(a,obj.Params.B0MoCo.in.movefiles);
                    %Initializing obj.Params.B0MoCo.out.XX:
                    obj.Params.B0MoCo.out.fn{jj}= [ outpath obj.Params.B0MoCo.in.prefix b c ] ;
                    obj.Params.B0MoCo.out.bvecs{jj}= [ outpath  obj.Params.B0MoCo.in.prefix strrep(b,'.nii','.voxel_space.bvecs') ];
                    obj.Params.B0MoCo.out.bvals{jj}= [ outpath  obj.Params.B0MoCo.in.prefix strrep(b,'.nii','.bvals') ];
                    %Splitting the current DWI:
                    clear tmp_fslsplit;
                    tmp_fslsplit=[ outpath 'tmp' filesep ...
                        'tmp_' strrep(b,'.nii','') filesep ];
                    if exist([tmp_fslsplit '0000.nii.gz' ],'file') == 0 || obj.redo_history
                        exec_cmd{end+1,:} = (['mkdir -p ' tmp_fslsplit ] );
                        obj.RunBash(exec_cmd{end});
                        exec_cmd{end+1,:}=([obj.FSL_dir 'bin/fslsplit ' obj.Params.B0MoCo.in.fn{jj} ...
                            ' ' tmp_fslsplit ' -t ']);
                        obj.RunBash(exec_cmd{end});
                    end
                    
                    %Load bval information:
                    clear tmp_bval_idx
                    tmp_bval_idx=load(obj.Params.B0MoCo.in.bvals{jj});
                    
                    %CHECK SHELL TO SEE WHAT SYNTAX USED TO EXPORT
                    %FREESURFER:
                    [~, tmp_SHELL]=system('echo $SHELL');
                    [~, SHELL , ~ ] = fileparts(tmp_SHELL);
                    SHELL=strtrim(SHELL);
                    
                    %%%%%%%%STEP 2: EXRTACT INFO FROM B0s%%%%%%%%%%%%%%%%%%
                    flag_b0_idx = [] ; %this will denote what b0idx to use (later in dwi_b0_idx{ii} variable (at end of for loop)
                    if exist(obj.Params.B0MoCo.out.fn{jj}, 'file') == 0 || obj.redo_history
                        %Apply bbreg to all b0s:
                        for ii=1:numel(tmp_bval_idx)
                            dwi_idx=ii-1  ; %indexing from fslsplit starts at 0 not 1 so we need this additional indexing
                            %Get single dwi (indexed at 0000 or 0010)
                            if ii < 11 % (idx start at 1 in matlab but fslsplit idx starts at 0, hence the difference!!
                                cur_in_dwi{ii} = [ tmp_fslsplit '000' num2str(dwi_idx) '.nii.gz' ];
                            else
                                cur_in_dwi{ii} = [ tmp_fslsplit '00' num2str(dwi_idx) '.nii.gz' ];
                            end
                            [ ~, bn_curdwi{ii}, ~ ] = fileparts(cur_in_dwi{ii});
                            
                            
                            
                            %INIT VARIABLE (ISOLATED from other inits (that are
                            %inside the if b0 loop because we will use them to
                            %apply warp in step 2 of this method...
                            out_dwi2firstb0{ii} =  [ tmp_fslsplit 'dwi' strrep(bn_curdwi{ii},'.nii','') '_2_modfirstb0.nii.gz' ];
                            
                            if strcmpi(obj.projectID,'habsiic')
                                b0_tval=5; %For some reason the b0-value in project HABS_IIC (TAW, HCP-A, same project different names has a b0 value of 5) 
                            else
                                b0_tval=0;
                            end
                            %Bbregister starts here (only for b0s!):
                            if tmp_bval_idx(ii) == b0_tval %it it's a b0 image
                                flag_b0_idx = ii ;
                                %Init variables (b0 dependable):
                                out_trnii{ii}= [ tmp_fslsplit 'dwi_' strrep(bn_curdwi{ii},'.nii','') '_2_fsT1.nii.gz' ];
                                out_dwi2fslmat{ii} = [ tmp_fslsplit 'mat_dwi' strrep(bn_curdwi{ii},'.nii','') '_2_fsT1.mat' ];
                                out_dwi2firstmat{ii} = [ tmp_fslsplit 'mat_dwi' strrep(bn_curdwi{ii},'.nii','') '_2_firstdwi.mat' ];
                                out_dwi2firstmat_rot_only{ii} = [ tmp_fslsplit 'rotonly_mat_dwi' strrep(bn_curdwi{ii},'.nii','') '_2_firstdwi.mat' ];
                                out_dwi2fsmat{ii} =  [ tmp_fslsplit 'fs_mat_dwi' strrep(bn_curdwi{ii},'.nii','') '_2_fsT1.dat' ];
                                %bbregister on every b0:
                                if exist(out_dwi2fslmat{ii},'file') == 0 || obj.redo_history
                                    if strcmp(SHELL,'bash')
                                    exec_cmd{end+1,:} = ([ 'export SUBJECTS_DIR=' obj.FS_location ';' ...
                                        ' bbregister --s ' obj.sessionname ' --' obj.Params.B0MoCo.in.nDoF ...
                                        ' --mov ' cur_in_dwi{ii} ' --dti --o ' out_trnii{ii}  ...
                                        ' --init-header --reg ' out_dwi2fsmat{ii} ...
                                        ' --fslmat ' out_dwi2fslmat{ii}   ]);
                                    else
                                        exec_cmd{end+1,:} = ([ 'setenv SUBJECTS_DIR ' obj.FS_location ';' ...
                                            ' bbregister --s ' obj.sessionname ' --' obj.Params.B0MoCo.in.nDoF ...
                                            ' --mov ' cur_in_dwi{ii} ' --dti --o ' out_trnii{ii}  ...
                                            ' --init-header --reg ' out_dwi2fsmat{ii} ...
                                            ' --fslmat ' out_dwi2fslmat{ii}   ]);
                                    end
                                    %BBregister seems not to give us an
                                    %adequate reconstruction but does gives
                                    %us a set of tranformation parameters
                                    %that we can apply to all b0s and DWIs.
                                    obj.RunBash(exec_cmd{end},44);
                                end
                                %Convert dwi2T1 to T12dwi and apply_warp
                                %(different from the 1st b0 and consequent
                                %ones, hence the if else statement:
                                if ii == 1
                                    out_fsl2firstdwimat = [ tmp_fslsplit 'mat_fslT1_2_dwi' strrep(bn_curdwi{1},'.nii','') '.mat' ];
                                    %Convert dwi2T1 into T12dwi:
                                    if exist(out_fsl2firstdwimat,'file') == 0 || obj.redo_history
                                        exec_cmd{end+1,:}=[obj.FSL_dir 'bin/convert_xfm -omat ' out_fsl2firstdwimat ...
                                            ' -inverse ' out_dwi2fslmat{ii} ];
                                        obj.RunBash(exec_cmd{end});
                                    end
                                    %Apply the disco_rel here using applywarp
                                    %I am not sure if we have to add the
                                    %warpfile again. The brain look more
                                    %spherical if added, and since this is
                                    %recycled code from Qiuyun Fang, I'll leave it as it is: 
                                    if exist(out_dwi2firstb0{ii} ,'file') == 0 || obj.redo_history
                                        exec_cmd{end+1,:}=([obj.FSL_dir 'bin/applywarp -i ' cur_in_dwi{ii} ' -r ' cur_in_dwi{1} ...
                                            ' -o ' out_dwi2firstb0{ii}  ' -w ' obj.Params.B0MoCo.in.grad_rel{1} ...
                                            ' --rel --interp=spline' ]);
                                        obj.RunBash(exec_cmd{end});
                                    end
                                    
                                    %Creating the eye.mat function for
                                    %reference on the firstb0 for rotation
                                    %matrices that will be used for rot. bvecs
                                    if exist(out_dwi2firstmat_rot_only{ii}, 'file' ) == 0 || obj.redo_history
                                        exec_cmd{end+1,:}=([ ' printf "1 0 0 0 \n0 1 0 0 \n0 0 1 0 \n0 0 0 1 " > ' ...
                                            out_dwi2firstmat_rot_only{ii} ]);
                                        obj.RunBash(exec_cmd{end});
                                    end
                                    
                                else
                                    %Convert dwi2T1 into T12dwi (concating the firstb0):
                                    if exist(out_dwi2firstmat{ii},'file') == 0 || obj.redo_history
                                        exec_cmd{end+1,:}=[obj.FSL_dir 'bin/convert_xfm -omat ' out_dwi2firstmat{ii}  ...
                                            ' -concat ' out_fsl2firstdwimat ' ' out_dwi2fslmat{ii} ];
                                        obj.RunBash(exec_cmd{end});
                                    end
                                    
                                    %Apply the disco_rel here using applywarp
                                    if exist(out_dwi2firstb0{ii} ,'file') == 0 || obj.redo_history
                                        exec_cmd{end+1,:}=([obj.FSL_dir 'bin/applywarp -i ' cur_in_dwi{ii} ' -r ' cur_in_dwi{1} ...
                                            ' -o ' out_dwi2firstb0{ii} ' -w ' obj.Params.B0MoCo.in.grad_rel{1} ...
                                            ' --postmat=' out_dwi2firstmat{ii} ' --interp=spline --rel ' ]);
                                        obj.RunBash(exec_cmd{end});
                                    end
                                    
                                    %Extracing the rotation matrix only using
                                    %avscale (this will be used for modifying
                                    %the bvecs output)
                                    if exist(out_dwi2firstmat_rot_only{ii}, 'file' ) == 0 || obj.redo_history
                                        exec_cmd{end+1,:}=([obj.FSL_dir 'bin/avscale ' out_dwi2firstmat{ii} ...
                                            ' | head -5 | tail -4 > ' out_dwi2firstmat_rot_only{ii} ]);
                                        obj.RunBash(exec_cmd{end});
                                    end
                                end
                            end
                            dwi_b0_idx{ii} = flag_b0_idx ; %This will keep the idx of what b0 to be used (for when applying warp to all b0s)
                        end
                        
                        %%%%%%%%STEP 2: APPLY INFO DERIVED FROM B0s%%%%%%%%%%%%
                        %Now applying all the information derived from B0s to
                        %all the DWIs (including the B0s)
                        
                        disp('In proc_b0s_MoCo Step 2: apply info from derived b0s');
                        disp(['In file iteration number: ' num2str(jj) ]);
                        fprintf('\n In DWI: ')
                        for ii=1:numel(tmp_bval_idx)
                            %Applying warp to all non-B0s (as it is done in
                            %Step1)
                            
                            if exist(out_dwi2firstb0{ii},'file') == 0 || obj.redo_history
                                fprintf([ '...' bn_curdwi{ii} ] );
                                exec_cmd{end+1,:}=([obj.FSL_dir 'bin/applywarp -i ' cur_in_dwi{ii} ...
                                    ' -r ' cur_in_dwi{1} ' -o ' out_dwi2firstb0{ii} ...
                                    ' -w ' obj.Params.B0MoCo.in.grad_rel{1} ...
                                    ' --postmat=' out_dwi2firstmat{dwi_b0_idx{ii}} ...
                                    ' --interp=spline' ]);
                                obj.RunBash(exec_cmd{end});
                            end
                            
                            %Modify bvecs information now...
                            AA=1;
                        end
                        fprintf('...done');
                        
                        
                        
                        %%%%%%%%STEP 3: APPLY ROT_MATFILES TO BVECS%%%%%%%%
                        %Extracing the rotation matrix only using
                        %avscale (this will be used for modifying the bvecs output)
                        if exist(out_dwi2firstmat_rot_only{ii}, 'file' ) == 0 || obj.redo_history
                            exec_cmd{end+1,:}=([obj.FSL_dir 'bin/avscale ' out_dwi2firstmat{ii} ...
                                ' | head -5 | tail -4 > ' out_dwi2firstmat_rot_only{ii} ]);
                            obj.RunBash(exec_cmd{end});
                        end
                        
                        
                        if exist(obj.Params.B0MoCo.out.bvecs{jj},'file') == 0 || obj.redo_history
                            fprintf('Applying rotation only .mat files to bvecs..');
                            TEMP_BVEC = load(obj.Params.B0MoCo.in.bvecs{jj});
                            for pp=1:size(TEMP_BVEC,1)
                                exec_cmd{end+1,:}=[obj.Params.B0MoCo.in.sh_rotate_bvecs ...
                                    ' ' num2str(TEMP_BVEC(pp,:)) ...
                                    ' ' out_dwi2firstmat_rot_only{dwi_b0_idx{pp}} ...
                                    ' >> ' (obj.Params.B0MoCo.out.bvecs{jj}) ];
                                obj.RunBash(exec_cmd{end});
                            end
                            fprintf('...done');
                        end
                        
                        %Copy bval_in to bvals_out (just a simple copy as
                        %its not affected):
                        if exist(obj.Params.B0MoCo.out.bvals{jj},'file') == 0 || obj.redo_history
                            exec_cmd{end+1,:}=['cp ' obj.Params.B0MoCo.in.bvals{jj} ' ' obj.Params.B0MoCo.out.bvals{jj} ];
                            obj.RunBash(exec_cmd{end});
                        end
                        
                        
                        %%%%%%%CREATING OUTPUT DWI NOW %%%%%%%%%%%%%%%%%%%%
                        %Fslmerging all the corrected values at this point
                        all_DWI_str = [];
                        for kk=1:numel(out_dwi2firstb0)
                            %First check that all volumes exist:
                            if ~exist(out_dwi2firstb0{kk},'file')==2
                                error_txt=[ 'Error: ' out_dwi2firstb0{kk} ' does not exist!. Please check' ];
                                exec_cmd=['echo "' error_txt '"  >> ' outpath 'error.txt' ]
                                obj.RunBash(exec_cmd);
                            end
                            all_DWI_str = [ all_DWI_str ' ' out_dwi2firstb0{kk} ]  ;
                        end
                        exec_cmd{end+1,:} = [ obj.FSL_dir 'bin/fslmerge -t ' obj.Params.B0MoCo.out.fn{jj}  ' ' all_DWI_str ];
                        fprintf('\n(FSL)Fslmerging all newer b0MoCo corrected volumes...')
                        obj.RunBash(exec_cmd{end});
                        wasRun=true;
                        obj.UpdateHist_v2(obj.Params.B0MoCo,'proc_B0MoCo', obj.Params.B0MoCo.out.fn{jj},wasRun,exec_cmd);
                        
                        fprintf('...done \n')
                        
                    else
                        [aa, bb, cc ] = fileparts(obj.Params.B0MoCo.out.fn{jj});
                        fprintf([ 'File ' bb cc ' is complete.\n' ]);
                    end
                end
            else
                error(['proc_b0s_MoCo(): Unable to find FreeSurfer directory here: ' obj.Params.B0MoCo.FS])
            end
        end
        
        %%%%%%%%%%%%%%%%%%% END  Pre-Processing Methods %%%%%%%%%%%%%%%%%%
        %------------------------------------------------------------------
        
    end
    
    %Post- procesing methods:
    methods 
        %%%%%%%%%%%%%%%%%% BEGIN  Post-Processing Methods %%%%%%%%%%%%%
        %QBOOT RELATED (Multiple shell ODF estimation for probabilistic
        %tractography:
        function obj = proc_qboot(obj)
            wasRun = false ;
           
            fprintf('\n%s\n', 'PERFORMING QBOOT:');
            if ~exist('exec_cmd','var')
                exec_cmd{:}='#INIT proc_tqboot() exec_cmd:';
            end
            
            [a b c ] = fileparts(obj.Params.Qboot.in.fn);
            outpath=obj.getPath(a,obj.Params.Qboot.in.movefiles);
            obj.Params.Qboot.out.dir = outpath ; 
            
            obj.Params.Qboot.out.merged_fn = [ obj.Params.Qboot.out.dir  'merged_th2samples.nii.gz'] ;
            if exist(obj.Params.Qboot.out.merged_fn, 'file') == 0 || obj.redo_history
                exec_cmd{:,end+1} = ['qboot -k ' obj.Params.Tracula.in.fn ...
                    ' -m ' obj.Params.CoRegMultiple.out.combined_mask ...
                    ' -r ' obj.Params.CoRegMultiple.out.combined_bvecs ...
                    ' -b ' obj.Params.CoRegMultiple.out.combined_bvals ...
                    ' --logdir='   obj.Params.Qboot.out.dir  ' --forcedir' ... %denotes folder output and --forcedir removes creating + and ++ folders
                    ' --model=3 ' ];
                obj.RunBash(exec_cmd{:,end},44);
                wasRun=true;
            else
                display('Qboot files already exist. Nothing to do');
            end
            
            if wasRun == true
                obj.UpdateHist_v2(obj.Params.Qboot,'proc_qboot()', obj.Params.Qboot.out.merged_fn,wasRun,exec_cmd');
                obj.resave();
            end
        end
        
        %TRACULA related:
        function obj = proc_tracula(obj)
            % try
            wasRun=false;
            if ~exist('exec_cmd','var')
                exec_cmd{:}='#INIT proc_tracula()_step1 exec_cmd:';
            end
            fprintf('\n%s\n', 'PERFORMING PROC_TRACULA():');
            %Creating root directory:
            for tohide=1:1
                [a b c ] = fileparts(obj.Params.Tracula.in.fn);
                outpath=obj.getPath(a,obj.Params.Tracula.in.movefiles);
                obj.Params.Tracula.out.dcmirc = [outpath 'dcmrirc.' obj.projectID ] ;
                
                %Creating a symbolic link due to file mount space concerns
                %(Change this if /cluster/** is replaced)
                if strcmp(obj.projectID,'HAB')
                    replaced_outpath = outpath ;
                    outpath = [ '/cluster/bang/HAB_Project1/TRACULA' filesep obj.sessionname filesep ];
                    exec_cmd{:,end+1}=(['mkdir -p ' outpath ]);
                    obj.RunBash(exec_cmd{:,end});
                    if exist([replaced_outpath  obj.sessionname]) == 0 || obj.redo_history
                        exec_cmd{:,end+1}=(['ln -s ' outpath ' ' replaced_outpath filesep obj.sessionname ]);
                        obj.RunBash(exec_cmd{:,end});
                    end
                    %After creating ln -s, select outpath to be the
                    %symbolic link:
                    outpath=[replaced_outpath obj.sessionname filesep];
                end
            end
            %Create the necessary dcmirc file:
            for tohide=1:1
                if exist(obj.Params.Tracula.out.dcmirc,'file') == 0 || obj.redo_history
                    exec_cmd{:,end+1} = [ 'cat ' obj.Params.Tracula.in.dcmrirc ' | sed s%''<SUBJECTID>''%' ...
                        obj.sessionname '%g | sed s%''<DTROOT>''%' outpath ...
                        '%g | sed s%''<FSSUBJECTSDIR>''%' obj.Params.Tracula.in.FSDIR ...
                        '%g | sed s%''<BVECFILE>''%' obj.Params.Tracula.in.bvec ...
                        '%g | sed s%''<BVALFILE>''%' obj.Params.Tracula.in.bval ...
                        '%g | sed s%''<NB0>''%' num2str(obj.Params.Tracula.in.nb0) ...
                        '%g > ' obj.Params.Tracula.out.dcmirc ];
                    obj.RunBash(exec_cmd{:,end});
                    wasRun=true;
                else
                    [~, bb, cc ] = fileparts(obj.Params.Tracula.out.dcmirc);
                    fprintf(['The file ' bb cc ' exists.\n']);
                end
            end
            %Run the three necessary steps for TRACULA (and bedpostx)
            for tohide=1:1
                %Set output directory:
                obj.Params.Tracula.out.dir = outpath ;
                %
                %Check for final file for step 1:;;;;
                obj.Params.Tracula.out.prep_check = [ obj.Params.Tracula.out.dir  obj.sessionname ...
                    filesep 'dlabel' filesep 'diff' filesep 'lh.cst_AS_avg33_mni_bbr_cpts_6.nii.gz' ];
                
                obj.Params.Tracula.out.isrunning = [ obj.Params.Tracula.out.dir  obj.sessionname ...
                    filesep  'scripts' filesep 'IsRunning.trac' ];
                if exist(obj.Params.Tracula.out.prep_check,'file') == 0 || obj.redo_history
                    %Remove IsRunning.trac if exists
                    if exist( obj.Params.Tracula.out.isrunning, 'file') ~= 0
                        system(['rm '  obj.Params.Tracula.out.isrunning ]);
                    end
                    AA=1;
                        exec_cmd{:,end+1} = ['trac-all -prep -c ' obj.Params.Tracula.out.dcmirc ' -i ' obj.Params.Tracula.in.fn ];
                        obj.RunBash(exec_cmd{:,end},44);
                        wasRun=true;
                else
                    [~, bb, cc ] = fileparts(obj.Params.Tracula.out.prep_check);
                    fprintf(['trac-all -prep filecheck ' bb cc ' exists.\n']);
                end
                %Step 2: Trac-all -prep
                clear exec_cmd; exec_cmd{:}='#INIT proc_tracula()_step2_bedpostx exec_cmd:';
                obj.Params.Tracula.out.bedp_check = [ obj.Params.Tracula.out.dir  obj.sessionname ...
                    filesep 'dmri.bedpostX' filesep 'merged_th2samples.nii.gz' ];
                if exist(obj.Params.Tracula.out.bedp_check, 'file') == 0 || obj.redo_history
                    %Remove IsRunning.trac if exists
                    if exist( obj.Params.Tracula.out.isrunning, 'file') ~= 0
                        system(['rm '  obj.Params.Tracula.out.isrunning ]);
                    end
                    exec_cmd{:,end+1} = ['trac-all -bedp -c ' obj.Params.Tracula.out.dcmirc ' -i ' obj.Params.Tracula.in.fn ];
                    obj.RunBash(exec_cmd{:,end},44);
                    wasRun = true;
                else
                    [~, bb, cc ] = fileparts(obj.Params.Tracula.out.bedp_check);
                    fprintf(['trac-all -bedp file ' bb cc ' exists.\n']);
                end
                %Step 3: Trac-all -path
                clear exec_cmd; exec_cmd{:}='#INIT proc_tracula()_step3_tract-all exec_cmd:';
                obj.Params.Tracula.out.path_check = [ obj.Params.Tracula.out.dir  obj.sessionname ...
                    filesep 'dpath' filesep 'merged_avg33_mni_bbr.mgz' ];
                if exist(obj.Params.Tracula.out.path_check,'file') == 0 || obj.redo_history
                    %Remove IsRunning.trac if exists
                    if exist( obj.Params.Tracula.out.isrunning, 'file') ~= 0
                        system(['rm '  obj.Params.Tracula.out.isrunning ]);
                    end
                    exec_cmd{:,end+1} = ['trac-all -path -c ' obj.Params.Tracula.out.dcmirc ' -i ' obj.Params.Tracula.in.fn ];
                    obj.RunBash(exec_cmd{:,end},44);
                    wasRun = true;
                else
                    [~, bb, cc ] = fileparts(obj.Params.Tracula.out.path_check);
                    fprintf(['trac-all -path ' bb cc ' exists.\n']);
                end
                
                %Check if saved in history:
                if wasRun == true
                    obj.UpdateHist_v2(obj.Params.Tracula.out,'proc_tracula()', obj.Params.Tracula.out.path_check,wasRun,exec_cmd');
                    obj.resave();
                end
            end
        end
        
        %TRKLAND related
        function obj = trkland_fx(obj)
            wasRun = false ;
            %SINCE I ACCESS OTHER METHODS WIHTIN THIS METHOD, WE HAVE THE VARIABLE BELOW:
            obj.Trkland.fx.wasRun = false;
            
            fprintf('\n%s\n', 'PERFORMING TRKLAND FORNIX: TRKLAND_FX():');
            if ~exist('exec_cmd','var')
                exec_cmd{:}='#INIT proc_trkland_fx()_step1 exec_cmd:';
            end
            %Initialize which image you'll use for FLIRT (either FA or b0)
            %This is changeable!
            obj.Trkland.fx.in.ref = obj.Trkland.fx.in.b0;
            %obj.Trkland.fx.in.ref = obj.Trkland.fx.in.FA;
            
            %Initialize inputs:
             obj.initinputsTRKLAND('fx');
            
            %Initialize fx Trks storage variables:
            if ~isfield(obj.Trkland,'Trks')
                obj.Trkland.Trks = [];
            end
            if ~isfield(obj.Trkland.fx,'data')
                obj.Trkland.fx.data=[] ;
            end
            if ~isfield(obj.Trkland.fx.data,'lh_done')
                %A value of ~= 1 will make date to be loaded at the
                %object. This should always be the case if some
                %modificaitons are done in the tracking/cleaning up of the
                %streamlines...
                obj.Trkland.fx.data.lh_done = 0 ;
                obj.Trkland.fx.data.rh_done = 0 ;
            end
            
            %Initialize outputs:
            obj.initoutputsTRKLAND('fx',obj.Trkland.root);
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %MATFILE TRANSFORMATION SECTION:
            for tohide=1:1
                %Create fx directory (if doesn't exist)
                if exist(obj.Trkland.root,'dir') == 0 
                    exec_cmd{:,end+1} = [ 'mkdir -p ' obj.Trkland.root ];
                    obj.RunBash(exec_cmd{end});
                end
                %Create the matfile of the fx tranformation
                if exist(obj.Trkland.fx.in.tmp2b0_matfile,'file') == 0
                    %USING FLIRT, HERE WE COULD ALSO TRY SPM_COREG (not sure if
                    %I'll get/how to get the *.mat though...). Flirt does a decent job anyhow
                    exec_cmd{:,end+1} = [ obj.FSL_dir '/bin/flirt  -in ' obj.Trkland.fx.tmp.b0  ...
                        ' -ref ' obj.Trkland.fx.in.ref ' -omat ' obj.Trkland.fx.in.tmp2b0_matfile ...
                        ' -out ' obj.Trkland.fx.in.fn_tmp2b0 ];
                    fprintf(['\n Coregistering TMP-B0 to:' obj.Trkland.fx.in.ref ])
                    obj.RunBash(exec_cmd{end}); wasRun=true
                    fprintf(['\n Orientation  is:  (' obj.Trkland.fx.tmp.ori ')\n' ] );
                    fprintf('...done \n');
                end
            end
            %%%%%%%%%%%%%%%%%%%%%
            %BILATERAL SECTION:
            for tohide=1:1
                %Apply the matfile to the roi:
                if exist(obj.Trkland.fx.in.roi_bil, 'file') == 0 
                    exec_cmd{:,end+1} = [ obj.FSL_dir '/bin/flirt -in '  obj.Trkland.fx.tmp.roi_bil  ...
                        ' -ref ' obj.Trkland.fx.in.ref ' -applyxfm -init ' obj.Trkland.fx.in.tmp2b0_matfile ...
                        ' -interp  nearestneighbour -out ' obj.Trkland.fx.in.roi_bil ];
                    fprintf('\n Coregistering bil_roi...')
                    obj.RunBash(exec_cmd{end}); wasRun=true;
                    fprintf('...done \n');
                end
                %Apply the matfile to the dilated solid fx:
                if exist(obj.Trkland.fx.in.roa_bil_solid, 'file') == 0 
                    exec_cmd{:,end+1} = [ obj.FSL_dir '/bin/flirt  -in ' obj.Trkland.fx.tmp.roa_solid_bil ...
                        ' -ref ' obj.Trkland.fx.in.ref ' -applyxfm -init ' obj.Trkland.fx.in.tmp2b0_matfile ...
                        ' -interp  nearestneighbour -out ' obj.Trkland.fx.in.roa_bil_solid ];
                    fprintf('\n Coregistering bil_solid...')
                    obj.RunBash(exec_cmd{end});
                    fprintf('...done \n');
                end
                %Erode the solid ROA:
                if exist(obj.Trkland.fx.in.roa_bil_ero , 'file') == 0 
                    exec_cmd{:,end+1} = [ obj.FSL_dir '/bin/fslmaths  ' obj.Trkland.fx.in.roa_bil_solid ...
                        ' -ero ' obj.Trkland.fx.in.roa_bil_ero  ];
                    fprintf('\n Eroding TMP_B0_fx_solid...')
                    obj.RunBash(exec_cmd{end});
                    fprintf('...done \n');
                end
                %Creating the hollow ROA:
                if exist(obj.Trkland.fx.in.roa_bil_hollow, 'file') == 0
                    exec_cmd{:,end+1} = [ obj.FSL_dir '/bin/fslmaths ' obj.Trkland.fx.in.roa_bil_solid ...
                        ' -sub ' obj.Trkland.fx.in.roa_bil_ero ' ' obj.Trkland.fx.in.roa_bil_hollow ];
                    fprintf('\n Hollowing the ROA...')
                    obj.RunBash(exec_cmd{end});
                    fprintf('...done \n');
                end
            end
            %%%%%%%%%%%%%%%%%%
            %ROI MODIFICATIONS:LEFT HEMISPHERE SECTION:
            for tohide=1:1
                %Apply the matfile to the roi:
                if exist(obj.Trkland.fx.in.roi_lh, 'file') == 0
                    exec_cmd{:,end+1} = [obj.FSL_dir '/bin/flirt  -in '  obj.Trkland.fx.tmp.roi_lh  ...
                        ' -ref ' obj.Trkland.fx.in.ref ' -applyxfm -init ' obj.Trkland.fx.in.tmp2b0_matfile ...
                        ' -interp  nearestneighbour -out ' obj.Trkland.fx.in.roi_lh ];
                    fprintf('\n Coregistering lh_roi...')
                    obj.RunBash(exec_cmd{end});
                    fprintf('...done \n');
                end
                %Apply the matfile to the dilated solid fx:
                if exist(obj.Trkland.fx.in.roa_lh_solid, 'file') == 0
                    exec_cmd{:,end+1} = [obj.FSL_dir '/bin/flirt -in ' obj.Trkland.fx.tmp.roa_solid_lh ...
                        ' -ref ' obj.Trkland.fx.in.ref ' -applyxfm -init ' obj.Trkland.fx.in.tmp2b0_matfile ...
                        ' -interp  nearestneighbour -out ' obj.Trkland.fx.in.roa_lh_solid ];
                    fprintf('\n Coregistering lh_solid...')
                    obj.RunBash(exec_cmd{end});
                    fprintf('...done \n');
                end
                %Erode the solid ROA:
                if exist(obj.Trkland.fx.in.roa_lh_ero , 'file') == 0 
                    exec_cmd{:,end+1} = [obj.FSL_dir '/bin/fslmaths ' obj.Trkland.fx.in.roa_lh_solid ...
                        ' -ero ' obj.Trkland.fx.in.roa_lh_ero  ];
                    fprintf('\n Eroding TMP_B0_fx_solid...')
                    obj.RunBash(exec_cmd{end});
                    fprintf('...done \n');
                end
                %Creating the hollow ROA:
                if exist(obj.Trkland.fx.in.roa_lh_hollow, 'file') == 0
                    exec_cmd{:,end+1} = [obj.FSL_dir '/bin/fslmaths ' obj.Trkland.fx.in.roa_lh_solid ...
                        ' -sub ' obj.Trkland.fx.in.roa_lh_ero ' ' obj.Trkland.fx.in.roa_lh_hollow ];
                    fprintf('\n Hollowing the ROA...')
                    obj.RunBash(exec_cmd{end});
                    fprintf('...done \n');
                end
            end
            %%%%%%%%%%%%%%%%%%
            %ROIS MODIFICATIONS: RIGHT HEMISPHERE SECTION:
            for tohide=1:1
                %Apply the matfile to the roi:
                if exist(obj.Trkland.fx.in.roi_rh, 'file') == 0
                    [~, to_exec ] = system('which flirt');
                    exec_cmd{:,end+1} = [strtrim(to_exec) ' -in '  obj.Trkland.fx.tmp.roi_rh  ...
                        ' -ref ' obj.Trkland.fx.in.ref ' -applyxfm -init ' obj.Trkland.fx.in.tmp2b0_matfile ...
                        ' -interp  nearestneighbour -out ' obj.Trkland.fx.in.roi_rh ];
                    fprintf('\n Coregistering rh_roi...')
                    obj.RunBash(exec_cmd{end});
                    fprintf('...done \n');
                end
                %Apply the matfile to the dilated solid fx:
                if exist(obj.Trkland.fx.in.roa_rh_solid, 'file') == 0 
                    exec_cmd{:,end+1} = [obj.FSL_dir '/bin/flirt -in ' obj.Trkland.fx.tmp.roa_solid_rh ...
                        ' -ref ' obj.Trkland.fx.in.ref ' -applyxfm -init ' obj.Trkland.fx.in.tmp2b0_matfile ...
                        ' -interp  nearestneighbour -out ' obj.Trkland.fx.in.roa_rh_solid ];
                    fprintf('\n Coregistering rh_solid...')
                    obj.RunBash(exec_cmd{end});
                    fprintf('...done \n');
                end
                %Erode the solid ROA:
                if exist(obj.Trkland.fx.in.roa_rh_ero , 'file') == 0 
                    exec_cmd{:,end+1} = [obj.FSL_dir '/bin/fslmaths '  obj.Trkland.fx.in.roa_rh_solid ...
                        ' -ero ' obj.Trkland.fx.in.roa_rh_ero  ];
                    fprintf('\n Eroding TMP_B0_fx_solid...')
                    obj.RunBash(exec_cmd{end});
                    fprintf('...done \n');
                end
                %Creating the hollow ROA:
                if exist(obj.Trkland.fx.in.roa_rh_hollow, 'file') == 0
                    exec_cmd{:,end+1} = [obj.FSL_dir '/bin/fslmaths ' obj.Trkland.fx.in.roa_rh_solid ...
                        ' -sub ' obj.Trkland.fx.in.roa_rh_ero ' ' obj.Trkland.fx.in.roa_rh_hollow ];
                    fprintf('\n Hollowing the ROA...')
                    obj.RunBash(exec_cmd{end});
                    fprintf('...done \n');
                end
            end
            %STARTING THE ACTUAL TRACKING NOW:
            for tohide=1:1
                if exist(obj.Trkland.fx.QCfile_bil,'file') == 0
                    if exist(obj.Trkland.fx.QCfile_lh) == 0
                        %Left side trking:
                        if exist(obj.Trkland.fx.out.raw_lh,'file') == 0 
                            if strcmp(obj.projectID,'ADRC')
                                exec_cmd{:,end+1} = ['/usr/pubsw/packages/DSI-Studio/20170531/dsi_studio_run  --action=trk --source=' obj.Trkland.fx.in.fib ...
                                    ' --seed_count=10000 --smoothing=0.01 --method=0 --interpolation=0 --thread_count=10' ...
                                    ' --seed=' obj.Trkland.fx.in.roi_lh ' --roa=' obj.Trkland.fx.in.roa_lh_hollow ...
                                    ' --threshold_index=nqa  --fa_threshold=0.04 --fiber_count=500' ...
                                    ' --step_size=1 --turning_angle=40 --min_length=80 --max_length=250 --fiber_count=500' ...
                                    ' --output=' obj.Trkland.fx.out.raw_lh ];
                                obj.RunBash(exec_cmd{end},144); wasRun = true;
                            else
                                exec_cmd{:,end+1} = ['/usr/pubsw/packages/DSI-Studio/20170531/dsi_studio_run  --action=trk --source=' obj.Trkland.fx.in.fib ...
                                    ' --seed_count=100000 --smoothing=0.01 --method=0 --interpolation=0 --thread_count=10' ...
                                    ' --smoothing=0.01 --method=0 --interpolation=0 --thread_count=10' ...
                                    ' --seed=' obj.Trkland.fx.in.roi_lh ' --roa=' obj.Trkland.fx.in.roa_lh_hollow ...
                                    ' --step_size=1 --turning_angle=40 --min_length=80 --max_length=250 --fiber_count=500' ...
                                    ' --output=' obj.Trkland.fx.out.raw_lh ];
                                 obj.RunBash(exec_cmd{end},144); wasRun = true;
                            end
                        else
                            [~, bb, cc ] = fileparts(obj.Trkland.fx.in.roa_lh_hollow);
                            fprintf(['The file ' bb cc ' exists. \n']);
                        end
                    else
                        display('QC_flag_lh found in trkland_fx. Skipping and removing data points...')
                        obj=obj.clearTRKLANDdata('fx','lh');
                        %RefreshFields(obj,'fx','lh')
                    end
                    
                    if exist(obj.Trkland.fx.QCfile_rh) == 0
                        %Right side trking:
                        if exist(obj.Trkland.fx.out.raw_rh,'file') == 0 
                            if strcmp(obj.projectID,'ADRC')
                                exec_cmd{:,end+1} = ['/usr/pubsw/packages/DSI-Studio/20170531/dsi_studio_run --action=trk --source=' obj.Trkland.fx.in.fib ...
                                    ' --seed_count=10000 --smoothing=0.01 --method=0 --interpolation=0 --thread_count=10' ...
                                    ' --seed=' obj.Trkland.fx.in.roi_rh ' --roa=' obj.Trkland.fx.in.roa_rh_hollow ...
                                    ' --threshold_index=nqa  --fa_threshold=0.04 --fiber_count=500' ...
                                    ' --step_size=1 --turning_angle=40 --min_length=80 --max_length=250 --fiber_count=500' ...
                                    ' --output=' obj.Trkland.fx.out.raw_rh ];
                                obj.RunBash(exec_cmd{end},144); wasRun = true;
                            else %for other projects....default
                                exec_cmd{:,end+1} = ['/usr/pubsw/packages/DSI-Studio/20170531/dsi_studio_run --action=trk --source=' obj.Trkland.fx.in.fib ...
                                    ' --seed_count=100000 --smoothing=0.01 --method=0 --interpolation=0 --thread_count=10' ...
                                    ' --seed=' obj.Trkland.fx.in.roi_rh ' --roa=' obj.Trkland.fx.in.roa_rh_hollow ...
                                    ' --step_size=1 --turning_angle=40 --min_length=80 --max_length=250 --fiber_count=500' ...
                                    ' --output=' obj.Trkland.fx.out.raw_rh ];
                                obj.RunBash(exec_cmd{end},144); wasRun = true;
                            end
                        else
                            [~, bb, cc ] = fileparts(obj.Trkland.fx.out.raw_rh);
                            fprintf(['The file ' bb cc ' exists. \n']);
                        end
                    else
                        display('QC_flag_rh found in trkland_fx. Skipping and removing data points...')
                        obj=obj.clearTRKLANDdata('fx','rh');
                        %                         RefreshFields(obj,'fx','rh')
                    end
                else
                    display('QC_flag_bil found in trkland_fx. Skipping and removing data points...')
                    obj=obj.clearTRKLANDdata('fx','bil');
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            %CLEAN UP OF THE TRACT, EXTRACTING CENTERLINE AND GET DATA
            %For left side (centerline approach):
            obj.applyTRKLAND('fx','lh');
            
            obj.getdataTRKLAND('fx','lh');%getting the lh data
            %For right side (centerline approach):
            obj.applyTRKLAND('fx','rh');
            
            obj.getdataTRKLAND('fx','rh');%getting the rh data
            
            %Update history if possible
            exec_cmd{:,end+1} = 'THIS COMMAND HISTORY DOES NOT SHOW THE CLEANING PROCESSES.';
            exec_cmd{:,end+1} = 'REFER TO obj.applyTRKLAND(''fx'',''lh/rh'') and  obj.getdataTRKLAND(''fx'',''lh/rh'') FOR ADDITIONAL INFORMATION.';
            
            if wasRun == true || obj.Trkland.fx.wasRun
                if exist(obj.Trkland.fx.QCfile_lh,'file') == 2
                    obj.UpdateHist_v2(obj.Trkland.fx,'proc_trkland_fx() - excl_lh', obj.Trkland.fx.out.clineFAHighFA_rh, wasRun,exec_cmd');
                elseif exist(obj.Trkland.fx.QCfile_rh,'file') == 2
                    obj.UpdateHist_v2(obj.Trkland.fx,'proc_trkland_fx() - excl_rh', obj.Trkland.fx.out.clineFAHighFA_lh, wasRun,exec_cmd');
                elseif exist(obj.Trkland.fx.QCfile_bil,'file') == 2
                    obj.UpdateHist_v2(obj.Trkland.fx,'proc_trkland_fx() - excl_bil', obj.Trkland.fx.QCfile_bil, wasRun,exec_cmd');
                else
                     obj.UpdateHist_v2(obj.Trkland.fx,'proc_trkland_fx()', obj.Trkland.fx.out.clineFAHighFA_rh, wasRun,exec_cmd');
                end
                obj.resave();
            end
            clear exec_cmd to_exec wasRun;
        end        
     
        function obj = trkland_fx_nonFA(obj,diffM)
            obj.applyTRKLAND_nonFA(diffM, 'fx','lh');
            obj.applyTRKLAND_nonFA(diffM, 'fx','rh');
            obj.resave();
        end
        
        %This accesor method 'trkland_adddata()' will allow us to create data specific to
        %out filenames in *.trk.gz and denoted in obj.Trkland.<TOI>.out.XX (e.g. nonFA values that deviate from
        %normal functioning of the data:
        function obj = trkland_adddata(obj,TOI,HEMI,out_fname,do_paths)
            obj.getdataTRKLAND(TOI,HEMI,out_fname);
            %obj.resave(); 
        end
        
        
        %fMRI or any masks to probabilistic tracking (it will
        %generate a shell script to run it from SHELL):
        function obj = proc_probtrackx(obj,mask_fname,mask_SPACE,do_paths)
            wasRun=false;
            if nargin <4
                do_paths=false ; %Variable that will create another *.sh file for creating targetpaths of probablistic tractography. 
                %ONLY USE THIS IF YOU HAVE FEW REGIONS AS IT WILL GENERATE
                %NxN paths, N being the number of regions.
            end
                
            %%%%%%%%%%%%%%%FILE CHECKING AND INIT STARTS HERE%%%%%%%%%%%%%%
            for tohide_fileChecking=1:1
                %Checking arguments:
                if nargin < 2
                    error('Please make sure you input at least the filename of the masks you want to use (3D volume with one intensity value per subject')
                end
                if nargin < 3
                    mask_SPACE=[fileparts(which('spm')) '/canonical/single_subj_T1.nii'];
                    obj.Params.probtrackx.tmp = mask_SPACE;
                    warning('Assuming your mask is in MNI space...'); pause(1);
                elseif strcmp(mask_SPACE,'MNI')
                    mask_SPACE=[fileparts(which('spm')) '/canonical/single_subj_T1.nii'];
                else
                    mni_to_error=[fileparts(which('spm')) '/canonical/single_subj_T1.nii'];
                    error(['Please make sure your mask is in MNI space (or registered to): ' mni_to_error ]);
                end
                
                [fname_dir, fname_bname, fname_ext ]  = fileparts(mask_fname);
                %Check if gzipped:
                if strcmp(fname_ext,'.gz')
                    error(['You fname_mask: ' mask_fname ' ends in *.gz ~~> Make sure you gunzip your mask_image! Quitting now...']);
                end
                
                %INIT exec_cmd:
                if ~exist('exec_cmd','var')
                    exec_cmd{:} = ' INIT probtrackx()';
                end
                
                %INIT VARIABLES
                obj.Params.probtrackx.root = [obj.root 'post_PROBTRACKX' filesep];
                if strcmp(obj.projectID,'ADRC')
                 obj.Params.probtrackx.b0 = obj.Params.CoRegMultiple.out.combined_b0;
                 obj.Params.probtrackx.b0_mask = obj.Params.CoRegMultiple.out.combined_mask;
                elseif strcmp(obj.projectID,'HAB')
                 obj.Params.probtrackx.b0 = [ obj.Params.Tracula.out.dir  obj.sessionname ...
                    filesep 'dmri' filesep 'lowb_brain.nii.gz' ];
                 obj.Params.probtrackx.b0_mask = [ obj.Params.Tracula.out.dir  obj.sessionname ...
                    filesep 'dmri' filesep 'nodif_brain_mask.nii.gz' ] ;          
                else
                  warning(['Please implement this for other project: obj.projectID=' obj.projectID  ' not recognized' ]);
                end
                obj.Params.probtrackx.probtracx2_args = ...
                ' -l --onewaycondition -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd  ' ;
            
                obj.Params.probtrackx.(fname_bname).in.fname     = mask_fname;
                if ~exist(obj.Params.probtrackx.root,'dir')
                    mkdir(obj.Params.probtrackx.root);
                end
                
                %CHECK IF THE BEDPOSTX DIRECTORY EXISTS AND IF IT CONTAINS
                %THE CORRECT NUMBER OF MERGED_* FILES:
                if isfield(obj.Params,'Tracula')
                    [obj.Params.probtrackx.bedp_dir, ~, ~ ]  = fileparts(obj.Params.Tracula.out.bedp_check);
                    if exist(obj.Params.probtrackx.bedp_dir,'dir') == 7
                        temp_mergeds = dir_wfp([ obj.Params.probtrackx.bedp_dir filesep 'merged*' ]);
                        size_mergeds = size(temp_mergeds,1);
                        if size_mergeds ~=6
                            error(['Incomplete number of merged_* files in: ' obj.Params.probtrackx.bedp_dir  'Should be 6 and there is: ' num2str(size_mergeds)]);
                        end
                        
                        %Check if the merged* files have the same
                        %dimensions as our data. If not, the best solution
                        %is to re-run tracula:
                        if isempty(obj.FSL_dir)
                            obj.setMyParams();
                        end
                        [~, b0_dim1 ]  = system([obj.FSL_dir '/bin/fslinfo ' obj.Params.probtrackx.b0 '  | grep ^dim1 | awk ''{print $2}'' '   ]);
                        b0_dim1=strtrim(b0_dim1);
                        [~, b0_dim2 ]  = system([obj.FSL_dir '/bin/fslinfo ' obj.Params.probtrackx.b0 '  | grep ^dim2 | awk ''{print $2}'' '   ]);
                        b0_dim2=strtrim(b0_dim2);
                        [~, b0_dim3 ]  = system([obj.FSL_dir '/bin/fslinfo ' obj.Params.probtrackx.b0 '  | grep ^dim3 | awk ''{print $2}'' '   ]);
                        b0_dim3=strtrim(b0_dim3);
                        
                        [~, merged_dim1 ]  = system([obj.FSL_dir '/bin/fslinfo ' temp_mergeds{end} '  | grep ^dim1 | awk ''{print $2}'' '   ]);
                        merged_dim1=strtrim(merged_dim1);
                        [~, merged_dim2 ]  = system([obj.FSL_dir '/bin/fslinfo ' temp_mergeds{end} '  | grep ^dim2 | awk ''{print $2}'' '   ]);
                        merged_dim2=strtrim(merged_dim2);
                        [~, merged_dim3 ]  = system([obj.FSL_dir '/bin/fslinfo ' temp_mergeds{end} '  | grep ^dim3 | awk ''{print $2}'' '   ]);
                        merged_dim3=strtrim(merged_dim3);
                        
                        
                        if str2num(b0_dim1) ~= str2num(merged_dim1)
                            fprintf(['\ndim1 is not equal in: \n  obj.Params.probtrackx.b0  (' b0_dim1 ') and merged_th2samples.nii.gz (' merged_dim1  ')\n']) ;
                            warning('This error occurs because TRACULA (or more specific bedpostx did not successfully completed');
                            error('Please re-run TRACULA');
                        end
                        
                        if str2num(b0_dim2) ~= str2num(merged_dim2)
                            fprintf(['\ndim2 is not equal in: \n  obj.Params.probtrackx.b0  (' b0_dim2 ') and  merged_th2samples.nii.gz (' merged_dim2  ')\n']) ;
                            warning('This error occurs because TRACULA (or more specific bedpostx did not successfully completed');
                            error('Please re-run TRACULA');
                        end
                        
                        if str2num(b0_dim3) ~= str2num(merged_dim3)
                            fprintf(['\ndim3 is not equal in: \n  obj.Params.probtrackx.b0  (' b0_dim3 ') and merged_th2samples.nii.gz (' merged_dim3  ')\n']) ;
                            warning('This error occurs because TRACULA (or more specific bedpostx did not successfully completed\n');
                            error('Please consider re-running TRACULA! ');
                        end
                        
                        
                    else
                        error(['Cannot find bedpostx directory: ' ' Was obj.proc_tracula() completely run? Exiting now...']);
                    end
                else
                    error('obj.Params.Tracula is not a field. Was obj.proc_tracula() run? Exiting now');
                end
                %TRYING TO USE the post_QBOOT bedpostx but commented as I
                %am not sure if it works with only 2 b-values:
%                 if strcmp(obj.projectID,'ADRC')
%                     %obj.Params.probtrackx.bedp_dir = obj.Params.Qboot.out.dir;
%                     obj.Params.probtrackx.bedp_dir = obj.Params.tracxBYmask.tracula.bedp_dir;
%                 else
%                     obj.Params.probtrackx.bedp_dir = obj.Params.tracxBYmask.tracula.bedp_dir;
%                 end

                %if strcmp(obj.projectID,'ADRC')
                % obj.Params.probtrackx.dwi_fn  = obj.Params.CoRegMultiple.out.combined_fn;
                %elseif strcmp(obj.projectID,'HAB')
                % obj.Params.probtrackx.dwi_fn  = obj.Params.Tracula.in.fn;       
                %else
                %  warning(['Please implement this for other project: obj.projectID=' obj.projectID  ' not recognized' ]);
                %end
                %Creating working directory for specific mask:
                obj.Params.probtrackx.(fname_bname).out.root     = [obj.Params.probtrackx.root fname_bname filesep ];
                if ~exist(obj.Params.probtrackx.(fname_bname).out.root,'dir')
                    mkdir(obj.Params.probtrackx.(fname_bname).out.root);
                end
                %~~~
                %%%%%%%%%%%%%% FILE CHECKING: IF EXIST %%%%%%%%%%%%%%%%%%%%%%%%%
                for tohide=1:1
                    %Check b0 exists:
                   % if ~exist(obj.Params.probtrackx.dwi_fn,'file');
                   %     error(['proc_probtrackx: b0 file ' '' obj.Params.probtrackx.dwi_fn '' ' does not exist. Returning...']);
                   %     return
                   % end
                   % %Check if mask_fname exists
                   % if ~exist(mask_fname,'file');
                   %     error(['proc_probtrackx: filename ' '' mask_fname''  ' does not exist. Returning...']);
                   %     return
                   % end
                end
                %~~%%%%%%%%%%% END OF FILE CHECKING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
                        
            %%%%%%%%%%%%%% START TRACX IMPLEMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%
            %IMPLEMENTATION STARTS HERE:
            %Initialize the probtracx shell command.
            %If created, we can skip all these loops
            %Integrate the probtracx commands in here:
            obj.Params.probtrackx.(fname_bname).sh_cmd_torun = [ obj.Params.probtrackx.root 'torun_pbs_' fname_bname  '.sh'];
            if exist(obj.Params.probtrackx.(fname_bname).sh_cmd_torun,'file') == 0 || obj.redo_history
                %Check if masks are aligned to MNI. If not, align
                [m_TMP h_TMP] = openIMG(mask_SPACE);
                [m_curMASK h_curMASK] = openIMG(mask_fname);
                
                if ~isequal(h_curMASK.dim,h_TMP.dim)
                    warning([' Template: obj.Params.probtrackx.tmp has different dimensions as: ' mask_fname  ' if in MNI, make sure its 2mm isotropic']);
                end
                
                %If *.mats differ, copy the same MNI:
                if ~isequal(h_curMASK.mat,h_TMP.mat)
                    fprintf(['Correcting h.matrix to match header...']);
                    h_curMASK.mat= h_TMP.mat;
                    spm_write_vol(h_curMASK,m_curMASK);
                    pause(2);
                    fprintf('..done\n');
                end

                
                %Create split mask directory for each mask
                cur_split_dir= [obj.Params.probtrackx.(fname_bname).out.root 'split_' fname_bname filesep];
                cur_split_dir=regexprep(cur_split_dir,[filesep filesep], filesep);
                if exist(cur_split_dir,'dir') == 0 ; mkdir(cur_split_dir); end
                obj.Params.probtrackx.(fname_bname).out.split_dir = cur_split_dir;
                
                %Reverse normalize the mask so its align with T1 or b0
                obj.Params.probtrackx.(fname_bname).out.revN_fname= [ obj.Params.probtrackx.(fname_bname).out.root 'revN_' fname_bname fname_ext];
                if exist(obj.Params.probtrackx.(fname_bname).out.revN_fname,'file') == 0 || obj.redo_history
                    exec_cmd{:,end+1} = [ 'obj.proc_apply_resversenorm(mask_fname, ' ...
                        ' obj.Params.spmT1_Proc.out.iregfile,obj.Params.probtrackx.b0, obj.Params.probtrackx.(fname_bname).out.root, ''revN_'' );'] ;
                    if ~isfield(obj.Params,'spmT1_Proc')
                        obj.proc_t1_spm();
                    end
                    
                    %Fixing previous faulty varaible assignation:
                    if ~isfield(obj.Params.spmT1_Proc.in,'tpm')
                        obj.Params.spmT1_Proc.in.tpm = '/autofs/space/schopenhauer_002/users/spm12/tpm/TPM.nii';
                    end
                    if ~ischar(obj.Params.spmT1_Proc.in.tpm)
                        obj.Params.spmT1_Proc.in.tpm = '/autofs/space/schopenhauer_002/users/spm12/tpm/TPM.nii';
                    end
                    eval(exec_cmd{end});
                    wasRun=true;
                end
                %QuickReslice:
                obj.Params.probtrackx.(fname_bname).out.reslicedN= [ obj.Params.probtrackx.(fname_bname).out.root 'resliced_revN_' fname_bname fname_ext];
                if exist(obj.Params.probtrackx.(fname_bname).out.reslicedN,'file') == 0 || obj.redo_history
                    exec_cmd{:,end+1} = 'obj.proc_reslice(obj.Params.probtrackx.(fname_bname).out.revN_fname,obj.Params.probtrackx.b0,'''', ''resliced_'' );';
                    eval(exec_cmd{end});
                    wasRun=true;
                end
                %Splitting the reversed normalized, resliced mask:
                [~, obj.Params.probtrackx.(fname_bname).out.n_masks ] = ...
                    system(['fslstats  ' obj.Params.probtrackx.(fname_bname).out.reslicedN ' -R | awk ''{print $2}'' ' ]);
                %making it a number (instead of a character class):
                obj.Params.probtrackx.(fname_bname).out.n_masks = str2num(obj.Params.probtrackx.(fname_bname).out.n_masks);
                
                %Pad the last mask number with zeros:
                if obj.Params.probtrackx.(fname_bname).out.n_masks < 10
                    pad_lastmask = [ '000' num2str(obj.Params.probtrackx.(fname_bname).out.n_masks)];
                elseif obj.Params.probtrackx.(fname_bname).out.n_masks < 100
                    pad_lastmask = [ '00' num2str(obj.Params.probtrackx.(fname_bname).out.n_masks)];
                elseif obj.Params.probtrackx.(fname_bname).out.n_masks < 1000
                    pad_lastmask = [ '0' num2str(obj.Params.probtrackx.(fname_bname).out.n_masks)];
                else
                    pad_lastmask = [ num2str(obj.Params.probtrackx.(fname_bname).out.n_masks)];
                end
                
                %Splitting the mask by intensity:
                obj.Params.probtrackx.(fname_bname).out.last_mask = [ cur_split_dir 'split_' pad_lastmask '_' fname_bname '.nii.gz'];
                if exist(obj.Params.probtrackx.(fname_bname).out.last_mask,'file') == 0 || obj.redo_history
                    %Then, we will redo the split...first remove previous
                    %splits:
                    display(['Removing previous split_* for ' cur_split_dir]);
                    [~, b] = system(['rm ' cur_split_dir 'split*']);
                    %then split by mask
                    fprintf(['\nSplitting ' fname_bname '...'])
                    display('In iteration: ' )
                    exec_cmd{:,end+1} = ['Splitting mask: ' obj.Params.probtrackx.(fname_bname).out.reslicedN ' using fslmaths -thr -uthr arguments.'];
                    for ss=1:obj.Params.probtrackx.(fname_bname).out.n_masks
                        %padding zeros:
                        if ss < 10
                            idx = [ '000' num2str(ss)];
                        elseif ss < 100
                            idx = [ '00' num2str(ss)];
                        elseif ss < 1000
                            idx = [ '0' num2str(ss)];
                        else
                            idx = [ num2str(ss)];
                        end
                        system(['fslmaths ' obj.Params.probtrackx.(fname_bname).out.reslicedN ...
                            ' -uthr ' idx ' -thr ' idx ' ' cur_split_dir 'split_' idx '_' fname_bname ]);
                        fprintf([ idx ' ']);
                        if ~mod(ss,20); fprintf('\n'); end
                    end
                    fprintf('..done \n');
                end
                
                %Is the txt file created?
                obj.Params.probtrackx.(fname_bname).out.txt_masks = [ obj.Params.probtrackx.(fname_bname).out.root 'seeds_' fname_bname '.txt'];
                if exist(obj.Params.probtrackx.(fname_bname).out.txt_masks,'file')
                    system(['rm ' obj.Params.probtrackx.(fname_bname).out.txt_masks  ]);
                end
                %Creating the file:
                fprintf(['\nInitializing the seeds_*.txt file for mask: ' fname_bname ' in filename' fname_bname]);
                system(['touch ' obj.Params.probtrackx.(fname_bname).out.txt_masks]);
                
                %Creating a list of the split*
                [~, tmp_list ] = system(['ls -1 ' cur_split_dir 'split*']);
                %Write to txt now:
                fileID=fopen(obj.Params.probtrackx.(fname_bname).out.txt_masks,'w');
                fprintf(fileID,'%s',tmp_list) ; fclose(fileID);
                fprintf('..done \n');
                
                %Move probtracx2 directory if it exists:
                obj.Params.probtrackx.(fname_bname).out.probtrackx2_dir = [ obj.Params.probtrackx.(fname_bname).out.root 'pbtrackx2_out_' fname_bname ];
                %unless it has already been moved:
                if exist([obj.Params.probtrackx.(fname_bname).out.probtrackx2_dir '_bak_' date],'dir') ~= 0
                    error(['Cannot move ' obj.Params.probtrackx.(fname_bname).out.probtrackx2_dir ' to a backup directory. The date already exists! ']);
                end
                %if not, move it
                if exist(obj.Params.probtrackx.(fname_bname).out.probtrackx2_dir,'dir') ~= 0
                    system(['mv ' obj.Params.probtrackx.(fname_bname).out.probtrackx2_dir ' ' ...
                        obj.Params.probtrackx.(fname_bname).out.probtrackx2_dir '_bak_' date]);
                end
                %NO NEED TO CREATE THIS->: system(['mkdir -p ' obj.Params.probtrackx.(fname_bname).out.probtrackx2_dir{ii}]);
                
                %Create a shell script with the necessary commands in this specific mask:
                [ ~, cmd_probtrackx2 ] = system('which probtrackx2');
                cmd_probtrackx2=strtrim(cmd_probtrackx2);
                exec_cmd{:,end+1} = [cmd_probtrackx2  ' --network -x  ' ...
                    obj.Params.probtrackx.(fname_bname).out.txt_masks ' ' ...
                    obj.Params.probtrackx.probtracx2_args ' ' ...
                    ' -s ' obj.Params.probtrackx.bedp_dir filesep 'merged' ...
                    ' -m ' obj.Params.probtrackx.b0_mask  ...
                    ' --dir=' obj.Params.probtrackx.(fname_bname).out.probtrackx2_dir ...
                    ];
                
                %Writing out the command shell needed:
                fprintf(['\nIntegrating the probtrackx2 command into a shell script... \n']);
                if exist(obj.Params.probtrackx.(fname_bname).sh_cmd_torun,'file') ~= 0
                    system(['mv ' obj.Params.probtrackx.(fname_bname).sh_cmd_torun ' ' ...
                        obj.Params.probtrackx.(fname_bname).sh_cmd_torun '_bak_' date]);
                end
                system(['touch ' obj.Params.probtrackx.(fname_bname).sh_cmd_torun ]);
                %Write to sh now:
                fileID=fopen(obj.Params.probtrackx.(fname_bname).sh_cmd_torun,'w');
                fprintf(fileID,'%s',exec_cmd{end}) ;
                fprintf(fileID,'\n\n');
                wasRun=true;
                fclose(fileID); fprintf('..done \n');
                
                
                %Creating targetpaths:
                if do_paths
                    obj.Params.probtrackx.(fname_bname).do_paths = true; 
                    display(['Creating do_paths shell ... ']);
                    cmd_probtrackx2=strtrim(cmd_probtrackx2);
                    exec_cmd{:,end+1} = [cmd_probtrackx2  ' -x  ' ...
                        obj.Params.probtrackx.(fname_bname).out.txt_masks ' ' ...
                        obj.Params.probtrackx.probtracx2_args ' ' ...
                        ' -s ' obj.Params.probtrackx.bedp_dir filesep 'merged' ...
                        ' -m ' obj.Params.probtrackx.b0_mask  ...
                        ' --dir=' obj.Params.probtrackx.(fname_bname).out.probtrackx2_dir '_do_paths' ...
                        ' --targetmasks=' obj.Params.probtrackx.(fname_bname).out.txt_masks ...
                        ' --os2t --otargetpaths ' ...
                        ];
                    obj.Params.probtrackx.(fname_bname).sh_cmd_torun_dopaths  =  strrep(obj.Params.probtrackx.(fname_bname).sh_cmd_torun,'.sh','_dopaths.sh');
                    if exist(obj.Params.probtrackx.(fname_bname).sh_cmd_torun_dopaths,'file') ~= 0
                        system(['mv ' obj.Params.probtrackx.(fname_bname).sh_cmd_torun_dopaths ' ' ...
                            obj.Params.probtrackx.(fname_bname).sh_cmd_torun_dopaths '_bak_' date]);
                    end
                    system(['touch ' obj.Params.probtrackx.(fname_bname).sh_cmd_torun_dopaths ]);
                    %Write to sh now:
                    fileID=fopen(obj.Params.probtrackx.(fname_bname).sh_cmd_torun_dopaths,'w');
                    fprintf(fileID,'%s',exec_cmd{end}) ;
                    fprintf(fileID,'\n\n');
                    wasRun=true;
                    fclose(fileID); fprintf('..done \n');
                else
                    obj.Params.probtrackx.(fname_bname).do_paths = false;
                end
            else
                fprintf([ '\n\n' obj.Params.probtrackx.(fname_bname).sh_cmd_torun ' exists. Nothing to do...']);
            end
            
            %Letting the user know that these commands should be run
            %away from the matlab environment (so it can be easily
            %batch in pbs).
            if wasRun
                fprintf('\nRun the following script from command line: \n');
                fprintf([obj.Params.probtrackx.(fname_bname).sh_cmd_torun '\n']);
                
                obj.UpdateHist_v2(obj.Params.probtrackx.(fname_bname),['probtrackx-> ' fname_bname ], obj.Params.probtrackx.(fname_bname).sh_cmd_torun,wasRun,exec_cmd');
                fprintf('**ALTERNTATIVELY: create a protected method prot_run_TRACTx() <ontheworks> \n');
            end
            fprintf(['\n\nPROBTRACKX2 SH COMMAND CREATION COMPLETED \n\n']);
            %%%%%%%%%%%%%% END OF  TRACX IMPLEMENTATION %%%%%%%%%%%%%%%%%%%
            
        end
        
        %CoReg related (accesor method):
        function obj = get_coreg2dwi(obj,mov,ref,outdir)
            AA=1;
            if exist(outdir,'dir') == 0 
                mkdir(outdir);                
            end
            
            %Copy mov to outdir
            if ischar(mov) %most likely the case of one argument...
                [mov_dir, mov_fn, mov_ext ] = fileparts(mov);
                if strcmp(mov_ext,'.gz')
                    mov_out = [  strrep([outdir filesep ],[filesep filesep ], filesep) mov_fn ];
                else
                    mov_out = [  strrep([outdir filesep ],[filesep filesep ], filesep) mov_fn mov_ext ] ;
                end
                if exist(mov_out{ii},'file') == 0
                    system(['mri_convert ' mov ' ' mov_out ]);
                end
                obj.proc_coreg2dwib0(mov,ref,outdir);
            else
                for ii=1:numel(mov)
                    [mov_dir{ii}, mov_fn{ii}, mov_ext{ii} ] = fileparts(mov{ii});
                    if strcmp(mov_ext{ii},'.gz')
                        mov_out{ii} = [  strrep([outdir filesep ],[filesep filesep ], filesep) mov_fn{ii} ] ;
                    else
                        mov_out{ii} = [  strrep([outdir filesep ],[filesep filesep ], filesep) mov_fn{ii} mov_ext{ii} ] ;
                    end
                    if exist(mov_out{ii},'file') == 0
                        system(['mri_convert ' mov{ii} ' '  mov_out{ii} ]);
                    end
                end
                warning(['mov argument has more than 1 filename. Coregistering the first filename and applying it to subsequents...']);
                pause(1)
                obj.proc_coreg2dwib0(mov{1},ref,outdir);
            end
            
            %Apply correction:
            obj.proc_apply_coreg2dwib0(mov_out,1,ref)
        end
        
        %!!!
        %ON THE WORKS:
        %proc_AFQ on the works (not finished/used yet. issues with AC-PC alignment, check: https://github.com/vistalab/vistasoft/issues/246 )
        function obj = ontheworks_proc_AFQ(obj)
            % Adding paths for: https://github.com/vistalab/vistasoft
            wasRun=false;
            fprintf('\n%s\n', 'PERFORMING PROC_AFQ():');
            %Creating root directory:
            for tohide=1:1
                [a b c ] = fileparts(obj.Params.AFQ.in.dwi);
                outpath=obj.getPath(a,obj.Params.AFQ.in.movefiles);
            end
            %Run the three necessary steps for AFQ
            for tohide=1:1
                %Set output directory:
                obj.Params.AFQ.out.dir = outpath ;
                obj.Params.AFQ.out.dwi = 'AFQ_dn.mat';
                %
                [obj.Params.AFQ.out.dwi, obj.Params.AFQ.out.dir] = dtiInit(obj.Params.AFQ.in.dwi, obj.Params.AFQ.in.T1, []);
            end
        end
        
        %!!
        %DEPRECATED_OBSOLETES:
        %trkland_atr won't work as isolating a centerline is useless in this tract
        function obj = obsolete_trkland_atr(obj)
            display( 'trkland_atr implementation has not been. Please check before using it (improvements were given to trimmmed_clean and ordeing so check. Dat stamped 10162017!!!');
            display('Skipping trkland_atr() ...')
            
            %             wasRun = false;
            %             %Create trkland directory (if doesn't exist)
            %             exec_cmd = [ 'mkdir -p ' obj.Trkland.root ];
            %             obj.RunBash(exec_cmd);
            %             outpath=obj.Trkland.root;
            %
            %             %ROIs/SEEDs PREPARATION
            %
            %             obj.Trkland.atr.in.roi_antroscing_lh = [ obj.Trkland.root 'atr_roi_antrostralcingulateDil1_lh.nii.gz' ] ;
            %             obj.Trkland.atr.in.roi_antroscing_rh = [ obj.Trkland.root 'atr_roi_antrostralcingulateDil1_rh.nii.gz' ] ;
            %
            %             obj.Trkland.atr.in.seed_thalamus_lh = [ obj.Trkland.root 'atr_seed_thalamusDil1_lh.nii.gz' ] ;
            %             obj.Trkland.atr.in.seed_thalamus_rh = [ obj.Trkland.root 'atr_seed_thalamusDil1_rh.nii.gz' ] ;
            %             for tohide=1:1
            %                 %anterior cingulate dilation:
            %                 if exist(obj.Trkland.atr.in.roi_antroscing_lh , 'file') == 0
            %                     fprintf('\ntrkland_atr(): Working on anterior cingulate_lh...')
            %                     exec_cmd = ['fslmaths '  obj.Trkland.atr.in.rostantcing_lh ...
            %                         ' -dilM ' obj.Trkland.atr.in.roi_antroscing_lh  ];
            %                     obj.RunBash(exec_cmd);
            %                     fprintf('...done \n');
            %                 end
            %
            %                 if exist(obj.Trkland.atr.in.roi_antroscing_rh , 'file') == 0
            %                     fprintf('\ntrkland_atr(): Working on anterior cingulate_rh...')
            %                     exec_cmd = ['fslmaths '  obj.Trkland.atr.in.rostantcing_rh ...
            %                         ' -dilM ' obj.Trkland.atr.in.roi_antroscing_rh  ];
            %                     obj.RunBash(exec_cmd);
            %                     fprintf('...done \n');
            %                 end
            %
            %                 %Thalamus dilation
            %                 if exist(obj.Trkland.atr.in.seed_thalamus_lh , 'file') == 0
            %                     fprintf('\n Working on posterior cingulate_lh...')
            %                     exec_cmd = ['fslmaths ' obj.Trkland.atr.in.thalamus_lh ...
            %                         ' -dilM ' obj.Trkland.atr.in.seed_thalamus_lh  ];
            %                     obj.RunBash(exec_cmd);
            %                     fprintf('...done \n');
            %                 end
            %                 if exist(obj.Trkland.atr.in.seed_thalamus_rh , 'file') == 0
            %                     fprintf('\n Working on posterior cingulate_rh...')
            %                     exec_cmd = ['fslmaths ' obj.Trkland.atr.in.thalamus_rh ...
            %                         ' -dilM ' obj.Trkland.atr.in.seed_thalamus_rh  ];
            %                     obj.RunBash(exec_cmd);
            %                     fprintf('...done \n');
            %                 end
            %
            %             end
            %
            %             %CLEANUP OF THE TRACTS
            %
            %             %TRACKING STARS HERE:
            %             for tohide=1:1
            %                 obj.Trkland.atr.out.trk_lh = [ obj.Trkland.root  'trkk_atr_lh.trk.gz'];
            %                 obj.Trkland.atr.out.trk_rh = [ obj.Trkland.root  'trkk_atr_rh.trk.gz'];
            %                 if exist(obj.Trkland.atr.cingulum.QCfile_bil,'file') == 0
            %                     %Left side trking:
            %                     if exist( obj.Trkland.atr.cingulum.QCfile_lh,'file')==0
            %                         if exist(obj.Trkland.atr.out.trk_lh,'file') == 0
            %                             exec_cmd = ['dsi_studio_run --action=trk --source=' obj.Trkland.fx.in.fib ...
            %                                 ' --seed_count=20000 --smoothing=0.01 --method=0 --interpolation=0 --thread_count=10' ...
            %                                 ' --seed=' obj.Trkland.atr.in.seed_thalamus_lh ' --roi=' obj.Trkland.atr.in.roi_antroscing_lh ...
            %                                 ' --step_size=1 --turning_angle=40 --min_length=110 --max_length=250 ' ...
            %                                 ' --output=' obj.Trkland.atr.out.trk_lh ];
            %                             for dd=1:4 %trying 4 times to get a trk. If not, quit!
            %                                 if exist(obj.Trkland.atr.out.trk_lh,'file') == 0
            %                                     obj.RunBash(exec_cmd,144);
            %                                 end
            %                             end
            %                             wasRun=true;
            %                             obj.UpdateHist(obj.Trkland.atr,'trkland_atr', obj.Trkland.atr.out.trk_lh,wasRun);
            %                         end
            %                     else
            %                         display('QC_flag_rh found in trkland_atr. Skipping and removing data points...')
            %                         RefreshFields(obj,'atr','rh')
            %                     end
            %                     %Right side trking:
            %                     if exist( obj.Trkland.atr.cingulum.QCfile_rh,'file')==0
            %                         if exist(obj.Trkland.atr.out.trk_rh,'file') == 0
            %                             exec_cmd = ['dsi_studio_run --action=trk --source=' obj.Trkland.fx.in.fib ...
            %                                 ' --seed_count=20000 --smoothing=0.01 --method=0 --interpolation=0 --thread_count=10' ...
            %                                 ' --seed=' obj.Trkland.atr.in.seed_thalamus_rh ' --roi=' obj.Trkland.atr.in.roi_antroscing_rh ...
            %                                 ' --step_size=1 --turning_angle=40 --min_length=110 --max_length=250 ' ...
            %                                 ' --output=' obj.Trkland.atr.out.trk_rh ];
            %
            %                             for dd=1:4 %trying 4 times to get a trk. If not, quit!
            %                                 if exist(obj.Trkland.atr.out.trk_rh,'file') == 0
            %                                     obj.RunBash(exec_cmd,144);
            %                                 end
            %                             end
            %                             wasRun=true;
            %                             obj.UpdateHist(obj.Trkland.atr,'trkland_atr', obj.Trkland.atr.out.trk_rh,wasRun);
            %
            %                         end
            %                     else
            %                         display('QC_flag_lh found in trkland_atr. Skipping and removing data points...')
            %                         RefreshFields(obj,'atr','rh')
            %                     end
            %                 else
            %                     display('QC_flag_bil found in trkland_atr. Skipping and removing data points...')
            %                     RefreshFields(obj,'atr','bil')
            %                 end
            %             end
            %
            %
            %             %LEFT SIDE:
            %
            %
            %             %RIGHT SIDE:
            %
        end
        %post-processing after TRACULA. Results not ideal at this point...
        function obj = obsolete_proc_tracx2thal11(obj)
            % Make sure you
            wasRun=false;
            %Creating Proc specific Directory:
            obj.Params.tracx_thal2ctx11.in_dir=obj.getPath(obj.Params.tracx_thal2ctx11.in.bedp_dir,obj.Params.tracx_thal2ctx11.in.movefiles);
            
            
            %PREPARING 10 CTX SEGMENTATIONS (per L/H hemispheres)
            %check if the dependency list exists...
            if exist(obj.Params.tracx_thal2ctx11.in.prep_segs_list,'file') == 0
                error(['\n proc_tracx2thal11(): ' obj.Params.tracx_thal2ctx11.in.prep_segs_list ' does not exit' ]);
            else
                tmp_readTXT=fileread([ obj.Params.tracx_thal2ctx11.in.prep_segs_list ]);
                
            end
            obj.Params.tracx_thal2ctx11.in.temp_list=textscan(tmp_readTXT,' %s %s %s %s %s %s %s %s %s %s %s');
            
            %Creating segs dir
            obj.Params.tracx_thal2ctx11.in.segs_dir = [ obj.Params.tracx_thal2ctx11.in_dir 'segs' filesep ]
            exec_cmd = [ 'mkdir -p ' obj.Params.tracx_thal2ctx11.in.segs_dir ];
            obj.RunBash(exec_cmd);
            
            
            %Creating segmentations...
            obj.Params.tracx_thal2ctx11.in.seg_list = '' ;
            for ii=1:size(obj.Params.tracx_thal2ctx11.in.temp_list,2)
                %For loop on every column that makes each iteration
                temp_seg_L = ' '; temp_seg_R = ' ';
                cur_FSseg_L = ' ' ; cur_FSseg_R =  ' ' ;
                for jj=2:size(obj.Params.tracx_thal2ctx11.in.temp_list{ii},1)
                    %check if current segmentation exists ("NA" no character), if not quit and
                    %throw error!
                    if ~strcmp(obj.Params.tracx_thal2ctx11.in.temp_list{ii}{jj},'NA')
                        cur_FSseg_L = [ obj.Params.tracx_thal2ctx11.in.FSaparc_dir ...
                            'dwi_ctx-lh-'  obj.Params.tracx_thal2ctx11.in.temp_list{ii}{jj} '.nii.gz'];
                        %check lh here:
                        if exist(cur_FSseg_L,'file') == 0
                            error(['In proc_tracx2thal11(): ' cur_FSseg_L ' does not exist. Needed for merge segmentations']);
                        end
                        
                        cur_FSseg_R = [ obj.Params.tracx_thal2ctx11.in.FSaparc_dir ...
                            'dwi_ctx-rh-'  obj.Params.tracx_thal2ctx11.in.temp_list{ii}{jj} '.nii.gz' ];
                        %check rh here:
                        if exist(cur_FSseg_R,'file') == 0
                            error(['\nIn proc_tracx2thal11(): ' cur_FSseg_R ' does not exist. Needed for merge segmentations']);
                        end
                        %Initial "-add" is not needed for first element
                        if jj == 2
                            temp_seg_L = [ temp_seg_L  ' ' cur_FSseg_L ' '   ];
                            temp_seg_R = [ temp_seg_R  ' ' cur_FSseg_R ' ' ];
                        else
                            temp_seg_L = [ temp_seg_L ' -add ' cur_FSseg_L  ' ' ];
                            temp_seg_R = [ temp_seg_R ' -add ' cur_FSseg_R  ' ' ];
                        end
                    end
                end
                
                %Add all directories in a merge file using fslmaths:
                %lh:
                cur_segname_L = [ obj.Params.tracx_thal2ctx11.in.segs_dir 'lh_' ...
                    obj.Params.tracx_thal2ctx11.in.temp_list{ii}{1} '.nii.gz' ];
                exec_cmd = ['fslmaths ' temp_seg_L  cur_segname_L] ;
                %Creating a list to be saved:
                obj.Params.tracx_thal2ctx11.in.seg_list{ii} = obj.Params.tracx_thal2ctx11.in.temp_list{ii}{1};
                
                
                if exist(cur_segname_L,'file') == 0
                    display([' In proc_tracx2thal11(): merging ' cur_segname_L '...'])
                    obj.RunBash(exec_cmd);
                    display('...done');
                end
                %rh:
                cur_segname_R = [ obj.Params.tracx_thal2ctx11.in.segs_dir 'rh_' ...
                    obj.Params.tracx_thal2ctx11.in.temp_list{ii}{1} '.nii.gz' ];
                exec_cmd = ['fslmaths ' temp_seg_R cur_segname_R ] ;
                if exist(cur_segname_R) == 0
                    display([' In proc_tracx2thal11(): merging ' cur_segname_R '...'])
                    obj.RunBash(exec_cmd);
                    display('...done');
                end
            end
            
            %Creating the txt files:
            %lh:
            obj.Params.tracx_thal2ctx11.in.lh_txt =  [ obj.Params.tracx_thal2ctx11.in.segs_dir 'segs_lh.txt' ];
            exec_cmd = [ ' ls -1 ' obj.Params.tracx_thal2ctx11.in.segs_dir ...
                'lh_* > ' obj.Params.tracx_thal2ctx11.in.lh_txt  ];
            obj.RunBash(exec_cmd);
            %rh:
            obj.Params.tracx_thal2ctx11.in.rh_txt =  [ obj.Params.tracx_thal2ctx11.in.segs_dir 'segs_rh.txt' ];
            exec_cmd = [ ' ls -1 ' obj.Params.tracx_thal2ctx11.in.segs_dir ...
                'rh_* > ' obj.Params.tracx_thal2ctx11.in.rh_txt  ];
            obj.RunBash(exec_cmd);
            
            
            
            %Now ready to perform probablistic tractograhy with the
            %parameters of interest:
            %Selecingt our seeds of interes:
            obj.Params.tracx_thal2ctx11.in.lh_seed = strrep(obj.Params.tracx_thal2ctx11.in.FSaparc_dir,['_aseg' filesep'],['2009_aseg' filesep 'dwi_fs_Left-Thalamus-Proper.nii.gz']);
            obj.Params.tracx_thal2ctx11.in.rh_seed = strrep(obj.Params.tracx_thal2ctx11.in.FSaparc_dir,['_aseg' filesep'],['2009_aseg' filesep 'dwi_fs_Right-Thalamus-Proper.nii.gz']);
            
            %lh:
            exec_cmd = ['probtrackx2 -x ' obj.Params.tracx_thal2ctx11.in.lh_seed ...
                ' -l --loopcheck -c 0.2 -S 2000 --steplength=0.5 -P 5000' ...
                ' --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s ' ...
                ' ' obj.Params.tracx_thal2ctx11.in.bedp_dir filesep 'merged' ...
                ' -m ' obj.Params.tracx_thal2ctx11.in.bedp_dir filesep 'nodif_brain_mask' ...
                ' --dir=' obj.Params.tracx_thal2ctx11.in_dir ' --otargetpaths' ...
                ' --targetmasks=' obj.Params.tracx_thal2ctx11.in.lh_txt ' --os2t'];
            
            
            
            obj.Params.tracx_thal2ctx11.out.seed2temporal_lh = [ obj.Params.tracx_thal2ctx11.in_dir 'seeds_to_lh_temporal_3.nii.gz'] ;
            if exist(obj.Params.tracx_thal2ctx11.out.seed2temporal_lh) == 0
                obj.RunBash(exec_cmd,44);
            end
            %rh:
            exec_cmd = ['probtrackx2 -x ' obj.Params.tracx_thal2ctx11.in.rh_seed ...
                ' -l --loopcheck -c 0.2 -S 2000 --steplength=0.5 -P 5000' ...
                ' --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s ' ...
                ' ' obj.Params.tracx_thal2ctx11.in.bedp_dir filesep 'merged' ...
                ' -m ' obj.Params.tracx_thal2ctx11.in.bedp_dir filesep 'nodif_brain_mask' ...
                ' --dir=' obj.Params.tracx_thal2ctx11.in_dir ' --otargetpaths' ...
                ' --targetmasks=' obj.Params.tracx_thal2ctx11.in.rh_txt ' --os2t'];
            
            obj.Params.tracx_thal2ctx11.out.seed2temporal_rh = [ obj.Params.tracx_thal2ctx11.in_dir 'seeds_to_lh_temporal_3.nii.gz'] ;
            if exist(obj.Params.tracx_thal2ctx11.out.seed2temporal_rh,'file') == 0
                obj.RunBash(exec_cmd,44);
            end
            
            %Now find the biggest
            %lh:
            obj.Params.tracx_thal2ctx11.out.biggest_lh = [ obj.Params.tracx_thal2ctx11.in_dir 'lh_thal2ctx11.nii.gz'] ;
            if exist(obj.Params.tracx_thal2ctx11.out.biggest_lh,'file') == 0
                exec_cmd = ['find_the_biggest ' obj.Params.tracx_thal2ctx11.in_dir  ...
                    'seeds_to_lh_* '  obj.Params.tracx_thal2ctx11.out.biggest_lh ]
                obj.RunBash(exec_cmd,44);
            end
            %Extracting the values and uploading data
            [check_ok , tmp_lh_vals] = system(['fslstats ' ...
                obj.Params.tracx_thal2ctx11.out.biggest_lh  ' -h ' num2str([1+numel(obj.Params.tracx_thal2ctx11.in.seg_list)]) ]);
            if check_ok ~= 0
                error('In  proc_tracx2thal11(): failed to parcellate find_the_biggest for thal2ctx11_lh');
            end
            %formating the values for double characters
            floats_tmp_lh_vals=textscan(tmp_lh_vals,'%f');
            obj.Params.tracx_thal2ctx11.out.biggest_vals_lh = floats_tmp_lh_vals{1};
            
            
            %rh
            obj.Params.tracx_thal2ctx11.out.biggest_rh = [ obj.Params.tracx_thal2ctx11.in_dir 'rh_thal2ctx11.nii.gz'] ;
            if exist(obj.Params.tracx_thal2ctx11.out.biggest_rh,'file') == 0
                exec_cmd = ['find_the_biggest ' obj.Params.tracx_thal2ctx11.in_dir  ...
                    'seeds_to_rh_* '  obj.Params.tracx_thal2ctx11.out.biggest_rh ]
                obj.RunBash(exec_cmd,44);
            end
            
            
            %Extracting the values and uploading data
            [check_ok , obj.Params.tracx_thal2ctx11.out.biggest_vals_rh] = system(['fslstats ' ...
                obj.Params.tracx_thal2ctx11.out.biggest_rh  ' -h ' num2str([1+numel(obj.Params.tracx_thal2ctx11.in.seg_list)]) ])
            if check_ok ~= 0
                error('In  proc_tracx2thal11(): failed to parcellate find_the_biggest for thal2ctx11_rh' );
            end
            
            
            %Saving object:
            obj.resave
            
        end
        function obj = obsolete_proc_tracx2papez(obj)
            % Make sure you
            wasRun=false;
            %Creating Proc specific Directory:
            obj.Params.tracx_thal2papez.in_dir=obj.getPath(obj.Params.tracx_thal2papez.in.bedp_dir,obj.Params.tracx_thal2papez.in.movefiles);
            
            
            %PREPARING 10 CTX SEGMENTATIONS (per L/H hemispheres)
            %check if the dependency list exists...
            if exist(obj.Params.tracx_thal2papez.in.prep_segs_list,'file') == 0
                error(['\n proc_tracx2papez(): ' obj.Params.tracx_thal2papez.in.prep_segs_list ' does not exit' ]);
            else
                tmp_readTXT=fileread([ obj.Params.tracx_thal2papez.in.prep_segs_list ]);
                
            end
            obj.Params.tracx_thal2papez.in.temp_list=textscan(tmp_readTXT,' %s %s %s %s %s %s %s %s ');
            
            %Creating segs dir
            obj.Params.tracx_thal2papez.in.segs_dir = [ obj.Params.tracx_thal2papez.in_dir 'segs' filesep ];
            exec_cmd = [ 'mkdir -p ' obj.Params.tracx_thal2papez.in.segs_dir ];
            %%COMMENTED: obj.RunBash(exec_cmd);
            
            
            %Creating segmentations...
            obj.Params.tracx_thal2papez.in.seg_list = '' ;
            for ii=1:size(obj.Params.tracx_thal2papez.in.temp_list,2)
                %For loop on every column that makes each iteration
                temp_seg_L = ' '; temp_seg_R = ' ';
                cur_FSseg_L = ' ' ; cur_FSseg_R =  ' ' ;
                for jj=2:size(obj.Params.tracx_thal2papez.in.temp_list{ii},1)
                    %check if current segmentation exists ("NA" no character), if not quit and
                    %throw error!
                    if ~strcmp(obj.Params.tracx_thal2papez.in.temp_list{ii}{jj},'NA')
                        cur_FSseg_L = [ obj.Params.tracx_thal2papez.in.FSaparc_dir ...
                            'dwi_ctx-lh-'  obj.Params.tracx_thal2papez.in.temp_list{ii}{jj} '.nii.gz'];
                        %check lh here:
                        if exist(cur_FSseg_L,'file') == 0
                            error(['In proc_tracx2papez(): ' cur_FSseg_L ' does not exist. Needed for merge segmentations.  ij={' num2str(ii) '}{' num2str(jj) '}']);
                        end
                        
                        cur_FSseg_R = [ obj.Params.tracx_thal2papez.in.FSaparc_dir ...
                            'dwi_ctx-rh-'  obj.Params.tracx_thal2papez.in.temp_list{ii}{jj} '.nii.gz' ];
                        %check rh here:
                        if exist(cur_FSseg_R,'file') == 0
                            error(['\nIn proc_tracx2papez(): ' cur_FSseg_R ' does not exist. Needed for merge segmentations. ij={' num2str(ii) '}{' num2str(jj) '}']);
                        end
                        %Initial "-add" is not needed for first element
                        if jj == 2
                            temp_seg_L = [ temp_seg_L  ' ' cur_FSseg_L ' '   ];
                            temp_seg_R = [ temp_seg_R  ' ' cur_FSseg_R ' ' ];
                        else
                            temp_seg_L = [ temp_seg_L ' -add ' cur_FSseg_L  ' ' ];
                            temp_seg_R = [ temp_seg_R ' -add ' cur_FSseg_R  ' ' ];
                        end
                    end
                end
                
                %Add all directories in a merge file using fslmaths:
                %lh:
                cur_segname_L = [ obj.Params.tracx_thal2papez.in.segs_dir 'lh_' ...
                    obj.Params.tracx_thal2papez.in.temp_list{ii}{1} '.nii.gz' ];
                exec_cmd = ['fslmaths ' temp_seg_L  cur_segname_L] ;
                %Creating a list to be saved:
                obj.Params.tracx_thal2papez.in.seg_list{ii} = obj.Params.tracx_thal2papez.in.temp_list{ii}{1};
                
                
                if exist(cur_segname_L,'file') == 0
                    display([' In proc_tracx2papez(): merging ' cur_segname_L '...'])
                    %%COMMENTED:obj.RunBash(exec_cmd);
                    display('...done');
                end
                %rh:
                cur_segname_R = [ obj.Params.tracx_thal2papez.in.segs_dir 'rh_' ...
                    obj.Params.tracx_thal2papez.in.temp_list{ii}{1} '.nii.gz' ];
                exec_cmd = ['fslmaths ' temp_seg_R cur_segname_R ] ;
                if exist(cur_segname_R) == 0
                    display([' In proc_tracx2papez(): merging ' cur_segname_R '...'])
                    %%COMMENTED: obj.RunBash(exec_cmd);
                    display('...done');
                end
            end
            
            %Creating the txt files:
            %lh:
            obj.Params.tracx_thal2papez.in.lh_txt =  [ obj.Params.tracx_thal2papez.in.segs_dir 'segs_lh.txt' ];
            exec_cmd = [ ' ls -1 ' obj.Params.tracx_thal2papez.in.segs_dir ...
                'lh_* > ' obj.Params.tracx_thal2papez.in.lh_txt  ];
            %%COMMENTED: obj.RunBash(exec_cmd);
            %rh:
            obj.Params.tracx_thal2papez.in.rh_txt =  [ obj.Params.tracx_thal2papez.in.segs_dir 'segs_rh.txt' ];
            exec_cmd = [ ' ls -1 ' obj.Params.tracx_thal2papez.in.segs_dir ...
                'rh_* > ' obj.Params.tracx_thal2papez.in.rh_txt  ];
            %%COMMENTED: obj.RunBash(exec_cmd);
            
            
            
            %Now ready to perform probablistic tractograhy with the
            %parameters of interest:
            %Selecingt our seeds of interes:
            obj.Params.tracx_thal2papez.in.lh_seed = strrep(obj.Params.tracx_thal2papez.in.FSaparc_dir,['_aseg' filesep'],['2009_aseg' filesep 'dwi_fs_Left-Thalamus-Proper.nii.gz']);
            obj.Params.tracx_thal2papez.in.rh_seed = strrep(obj.Params.tracx_thal2papez.in.FSaparc_dir,['_aseg' filesep'],['2009_aseg' filesep 'dwi_fs_Right-Thalamus-Proper.nii.gz']);
            
            %lh:
            exec_cmd = ['probtrackx2 -x ' obj.Params.tracx_thal2papez.in.lh_seed ...
                ' -l --loopcheck -c 0.2 -S 2000 --steplength=0.5 -P 5000' ...
                ' --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s ' ...
                ' ' obj.Params.tracx_thal2papez.in.bedp_dir filesep 'merged' ...
                ' -m ' obj.Params.tracx_thal2papez.in.bedp_dir filesep 'nodif_brain_mask' ...
                ' --dir=' obj.Params.tracx_thal2papez.in_dir ' --otargetpaths' ...
                ' --targetmasks=' obj.Params.tracx_thal2papez.in.lh_txt ' --os2t'];
            
            
            
            obj.Params.tracx_thal2papez.out.seed2temporal_lh = [ obj.Params.tracx_thal2papez.in_dir 'seeds_to_lh_temporal.nii.gz'] ;
            if exist(obj.Params.tracx_thal2papez.out.seed2temporal_lh) == 0
                %%COMMENTED: obj.RunBash(exec_cmd,44);
            end
            %rh:
            exec_cmd = ['probtrackx2 -x ' obj.Params.tracx_thal2papez.in.rh_seed ...
                ' -l --loopcheck -c 0.2 -S 2000 --steplength=0.5 -P 5000' ...
                ' --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s ' ...
                ' ' obj.Params.tracx_thal2papez.in.bedp_dir filesep 'merged' ...
                ' -m ' obj.Params.tracx_thal2papez.in.bedp_dir filesep 'nodif_brain_mask' ...
                ' --dir=' obj.Params.tracx_thal2papez.in_dir ' --otargetpaths' ...
                ' --targetmasks=' obj.Params.tracx_thal2papez.in.rh_txt ' --os2t'];
            
            obj.Params.tracx_thal2papez.out.seed2temporal_rh = [ obj.Params.tracx_thal2papez.in_dir 'seeds_to_lh_temporal.nii.gz'] ;
            if exist(obj.Params.tracx_thal2papez.out.seed2temporal_rh,'file') == 0
                %%COMMENTED: obj.RunBash(exec_cmd,44);
            end
            
            %Now find the biggest
            %lh:
            obj.Params.tracx_thal2papez.out.biggest_lh = [ obj.Params.tracx_thal2papez.in_dir 'lh_thal2ctx11.nii.gz'] ;
            if exist(obj.Params.tracx_thal2papez.out.biggest_lh,'file') == 0
                exec_cmd = ['find_the_biggest ' obj.Params.tracx_thal2papez.in_dir  ...
                    'seeds_to_lh_* '  obj.Params.tracx_thal2papez.out.biggest_lh ]
                %%COMMENTED: obj.RunBash(exec_cmd,44);
            end
            %Extracting the values and uploading data
            [check_ok , tmp_lh_vals] = system(['fslstats ' ...
                obj.Params.tracx_thal2papez.out.biggest_lh  ' -h ' num2str([1+numel(obj.Params.tracx_thal2papez.in.seg_list)]) ]);
            if check_ok ~= 0
                error('In  proc_tracx2papez(): failed to parcellate find_the_biggest for thal2ctx11_lh');
            end
            %formating the values for double characters
            floats_tmp_lh_vals=textscan(tmp_lh_vals,'%f');
            obj.Params.tracx_thal2papez.out.biggest_vals_lh = floats_tmp_lh_vals{1};
            
            
            %rh
            obj.Params.tracx_thal2papez.out.biggest_rh = [ obj.Params.tracx_thal2papez.in_dir 'rh_thal2ctx11.nii.gz'] ;
            if exist(obj.Params.tracx_thal2papez.out.biggest_rh,'file') == 0
                exec_cmd = ['find_the_biggest ' obj.Params.tracx_thal2papez.in_dir  ...
                    'seeds_to_rh_* '  obj.Params.tracx_thal2papez.out.biggest_rh ]
                %%COMMENTED: obj.RunBash(exec_cmd,44);
            end
            
            
            %Extracting the values and uploading data
            [check_ok , obj.Params.tracx_thal2papez.out.biggest_vals_rh] = system(['fslstats ' ...
                obj.Params.tracx_thal2papez.out.biggest_rh  ' -h ' num2str([1+numel(obj.Params.tracx_thal2papez.in.seg_list)]) ]);
            if check_ok ~= 0
                error('In  proc_tracx2papez(): failed to parcellate find_the_biggest for thal2ctx11_rh' );
            end
            
            
            %Saving object:
            display('Exiting....')
            return
            %%COMMENTED:obj.resave
            
        end
        function obj = obsolete_proc_tracxBYmask(obj,tracx_name)
            %COMMENTED OUT. CHECK THE NON_OBSOLETE METHOD:
            
            %             wasRun=false;
            %             fprintf('\n%s\n', 'PERFORMING PROC_TRACXBYMASK():');
            %
            %             %COREGISTERING T1 to DWI
            %             obj.Params.tracxBYmask.T1coregDWI.dir = '' ;
            %
            
            %
            %             %LINE BELOW WILL MAKE SURE MNI IS IN THE SAME SPACE AS THE
            %             %MASKS!
            %             %             [m h] = openIMG('mask_100_v1.nii'); h2 = spm_vol('MNI152_T1_2mm.nii'); h.fname = 'test.nii'; h.mat = h2.mat; spm_write_vol(h,m);
            %
            %
            %
            % %INIT VARIABLES
            %             %Introducing local variable for ease of method implementation
            %             in_b0           = obj.Params.tracxBYmask.all_masks.(tracx_name).in.b0;
            %             in_txtfname     = obj.Params.tracxBYmask.all_masks.(tracx_name).in.txt_fname;
            %             in_bedp_dir     = obj.Params.tracxBYmask.all_masks.(tracx_name).in.bedp_dir;
            %             in_movefiles    = obj.Params.tracxBYmask.all_masks.(tracx_name).in.movefiles;
            %             %Creating working directory and assigning a short name:
            %             obj.Params.tracxBYmask.all_masks.(tracx_name).out.dir=obj.getPath(in_bedp_dir,in_movefiles);
            %             out_dir = obj.Params.tracxBYmask.all_masks.(tracx_name).out.dir;%short-naming
            %
            %             obj.Params.tracxBYmask.all_masks.(tracx_name).coreg.out_dir =  [ out_dir filesep 'coreg' ];
            %             coreg_dir = obj.Params.tracxBYmask.all_masks.(tracx_name).out.coreg_dir; %short-naming
            %             %~~~
            %
            %             %%%%%%%%%%%%%% FILE CHECKING: IF EXIST %%%%%%%%%%%%%%%%%%%%%%%%%
            %             for tohide=1:1
            %                 %Check b0 exists:
            %                 if ~exist(in_b0,'file');
            %                     error(['proc_tracxBYmask: b0 file ' '' in_b0 '' ' does not exist. Returning...']);
            %                     return
            %                 end
            %                 %Check if txt_mask_name exists
            %                 if ~exist(in_txtfname,'file');
            %                     error(['proc_tracxBYmask: txt filename ' '' in_txtfname''  ' does not exist. Returning...']);
            %                     return
            %                 end
            %
            %                 %Check to see that all filepaths and image exist in in_txtfname
            %                 fileID=fopen(in_txtfname);
            %                 %TODEBUG fileID=fopen('/cluster/cluster/ADRC/Scripts/DEPENDENCIES/fMRI_masks/mask_txt/try_masks_BAD.txt');;
            %                 tmp_txtscan=textscan(fileID,'%s');
            %                 list_MASKS=tmp_txtscan{1};
            %                 for ii=1:numel(list_MASKS)
            %                     if ~exist(list_MASKS{ii})
            %                         fprintf('\n\n')
            %                         display(['proc_tracxBYmask: The ' num2str(ii) 'th iteration filepath: ' '' list_MASKS{ii} '' ]);
            %                         display(['\nIn: ' '' in_txtfname '' ' does not exist. Please change!'])
            %                         error('Returning...')
            %                         return
            %                     end
            %                 end
            %             end
            %             %~~%%%%%%%%%%% END OF FILE CHECKING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %
            %
            %
            %             %%%%%%%%%%%%%% START IMPLEMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%
            %             %Init exec_cmd
            %             exec_cmd{:} = ['STARTING proc_tracxBYmask for ' tracx_name ]  ;
            %
            %
            %
            %             %IMPLEMENTATION STARTS HERE:
            %             %Loading fMRI object for reverse normalization:
            %             obj.Params.tracxBYmask.all_masks.(tracx_name).in.fmri_matfile = [obj.root '../restingState/' obj.sessionname '.mat'];
            %             fMRI_mat = obj.Params.tracxBYmask.all_masks.(tracx_name).in.fmri_matfile ;
            %
            %             if ~exist(fMRI_mat, 'file' )
            %                 error(['fMRI object mat file: ''' fMRI_mat  ''' does not exist. Please CHECK or run fMRI object!' ]);
            %             end
            %             fMRI_object=load(fMRI_mat);
            %             %Make sure this process is good:
            %             fMRI_object.obj.proc_t1_spm();
            %
            %
            %             %Check if b0 is gzipped...
            %             [ tmp_b0_dirname tmp_b0_fname  tmp_b0_ext ] = fileparts(in_b0);
            %             if strcmp(tmp_b0_ext,'.gz')
            %                 exec_cmd{:,end+1} = ['gunzip ' in_b0 ] ;
            %                 obj.RunBash(exec_cmd{end});
            %                 touse_b0= [ tmp_b0_dirname filesep tmp_b0_fname ];
            %             else
            %                 touse_b0=in_b0;
            %             end
            %
            %
            %             %Create coreg_directory:
            %             exec_cmd{:,end+1} = ['mkdir -p '   coreg_dir ] ;
            %             obj.RunBash(exec_cmd{end});
            %
            %
            %             %Loop for every mask created
            %             display('LOOPING THORUGH THE TXT_FILE. MAKE SURE');
            %             display('THEY ARE IN THE SAME SPACE AS THE FIRST FILENAME/MASK');
            %             pause(2)
            %
            %             %assigning coreg template (always the first on the list)
            %             obj.Params.tracxBYmask.all_masks.(tracx_name).coreg.mv_img=list_MASKS{1};
            %             obj.Params.tracxBYmask.all_masks.(tracx_name).coreg.ref_img=''
            %             obj.Params.tracxBYmask.all_masks.(tracx_name).coreg.out_dir=''
            %             obj.Params.tracxBYmask.all_masks.(tracx_name).coreg.out_warped=''
            %             obj.Params.tracxBYmask.all_masks.(tracx_name).coreg.out_warped=''
            %
            %             %
            %
            %             for ii=1:numel(list_MASKS)
            %                 %Fileparts the mask (always assing touse_curmask as nii):
            %                 [ tmp_curmask_dir tmp_curmask_fname tmp_curmask_ext ] = fileparts(list_MASKS{ii});
            %                 if strcmp(tmp_curmask_ext,'.gz')
            %                     touse_curmask = [coreg_dir filesep tmp_curmask_fname ] ;
            %                 elseif strcmp(tmp_curmask_ext,'.nii')
            %                     touse_curmask = [coreg_dir filesep tmp_curmask_fname tmp_curmask_ext ] ;
            %                 else
            %                     error(['Mask file in the ' num2str(ii) 'th iteration of the *.txt file is not in *.nii or *.nii.gz format. Please check!']);
            %                 end
            %
            %                 if ~exist(touse_curmask,'file')
            %                     %Copy file:
            %                     exec_cmd{:,end+1} = ['cp ' list_MASKS{ii} ' ' coreg_dir ] ;
            %                     obj.RunBash(exec_cmd{end});
            %
            %                     %Check if cur_mask is gzipped:
            %                     if strcmp(tmp_curmask_ext,'.gz')
            %                         exec_cmd{:,end+1} = ['gunzip ' coreg_dir filesep tmp_curmask_fname tmp_curmask_ext   ] ;
            %                         obj.RunBash(exec_cmd{end});
            %                     end
            %                 end
            %
            %                 %Save information about what masks were extracted
            %                 obj.Params.tracxBYmask.all_masks.(tracx_name).out.coreg_in{ii} = touse_curmask;
            %
            %                 fMRI_object.obj.Params.ApplyReverseNormNew.in.movefiles = coreg_dir;
            %                 fMRI_object.obj.Params.ApplyReverseNormNew.in.fn = touse_curmask;
            %                 fMRI_object.obj.Params.ApplyReverseNormNew.in.targ = touse_b0;
            %                 fMRI_object.obj.Params.ApplyReverseNormNew.in.regfile = obj.Params.spmT1_Proc.out.iregfile;
            %                 fMRI_object.obj.proc_apply_reservsenorm_new();
            %             end
            %
            %
            %             %Gzip again:
            %             if strcmp(tmp_b0_ext,'.gz')
            %                 exec_cmd{:,end+1} = ['gzip ' tmp_b0_dirname  filesep tmp_b0_fname ];
            %                 obj.RunBash(exec_cmd{end});
            %             end
            %
            %
            %             %~~%%%%%%%%%%% END OF MKDIR AND COREG %%%%%%%%%%%%%%%%%%%%%%%%%
            %
            
        end
        %Having problem with using ants for dwi2MNI....hence deprecated!
        function obj = obsolete_proc_ants_dwi2MNI(obj)
            wasRun=false;
            fprintf('\n%s\n', 'PERFORMING PROC_ANTS_DWI2MNI():');
            %First, select the ref_files needed:
            [a b c ] = fileparts(obj.Params.ants_dwi2MNI.in.b0_fn);
            obj.Params.ants_dwi2MNI.out.dir=obj.getPath(a,obj.Params.ants_dwi2MNI.in.movefiles);
            
            
            %Check if input exists:
            if ~exist(obj.Params.ants_dwi2MNI.in.b0_fn, 'file')
                error('PROC_ANTS_dwi2MINI: b0 dwi (obj.Params.ants_dwi2MNI.in.b0_fn) not found. please check!')
            end
            if ~exist(obj.Params.ants_dwi2MNI.in.MNI_tocopy, 'file')
                error('PROC_ANTS_dwi2MINI: MNI image (obj.Params.ants_dwi2MNI.in.MNI_tocopy) not found. please check!')
            end
            
            
            
            %INITIALIZE OUTPUT:
            %output filename
            obj.Params.ants_dwi2MNI.out.dwi2mni_fn = [obj.Params.ants_dwi2MNI.out.dir ...
                filesep obj.Params.ants_dwi2MNI.in.output_prefix '.nii.gz' ];
            %output MNI template (to be copied)
            [~, tmp_MNI_mask_fname, tmp_mask_ext ] = fileparts(obj.Params.ants_dwi2MNI.in.MNI_tocopy); %MNI to be copied into output_dir
            obj.Params.ants_dwi2MNI.in.mni_template = [obj.Params.ants_dwi2MNI.out.dir ...
                filesep tmp_MNI_mask_fname tmp_mask_ext ] ;
            exec_cmd{:} = '#INITIALIZING PROC_ANTS_DWI2MNI() EXEC_CMD';
            
            %IMPLEMENTATION STARTS HERE
            %copying location of MNI to actual MNI to be used:
            if ~exist(obj.Params.ants_dwi2MNI.in.mni_template, 'file')
                exec_cmd{:,end+1} = ['cp ' obj.Params.ants_dwi2MNI.in.MNI_tocopy ...
                    ' ' obj.Params.ants_dwi2MNI.in.mni_template ];
                obj.RunBash(exec_cmd{end});
            end
            
            %Check if warped filename has been created
            if exist( obj.Params.ants_dwi2MNI.out.dwi2mni_fn ,'file') == 0
                %First, cd to current directory:
                exec_cmd{:,end+1} = ['cd ' obj.Params.ants_dwi2MNI.out.dir ];
                tmp_PWD=pwd;
                cd(obj.Params.ants_dwi2MNI.out.dir);
                fprintf(['\n\n' 'ANTSREG NOT WORKING. NEED TO IMPLEMENT A BETTER COREG '   '\n\n'])
                [~ , ants_exec ] = system('which antsRegistrationSyN.sh');
                exec_cmd{:,end+1}=([strtrim(ants_exec) ' -d 3 -n 1 -t b -r 4 -p d ' ...
                    ' -m ' obj.Params.ants_dwi2MNI.in.b0_fn ...
                    ' -f ' obj.Params.ants_dwi2MNI.in.mni_template ...
                    ' -o ' obj.Params.ants_dwi2MNI.in.output_prefix ]);
                tic
                obj.RunBash(exec_cmd{end},44);
                obj.Params.ants_dwi2MNI.out.time_completion=[ num2str(toc) ' seconds '];
                wasRun = true;
                cd(PWD);
            end
            obj.UpdateHist_v2(obj.Params.ants_dwi2MNI,'proc_ants_dwi2MNI', obj.Params.ants_dwi2MNI.out.dwi2mni_fn,wasRun,exec_cmd);
            fprintf(' proc_ants_dwi2MNI(obj) is complete\n');
        end
        function obj = obsolete_proc_ants_RegSyN(obj,fixed_img,mov_img,out_dir,out_prefix,other_args)
            if nargin < 5
                error('In obj.proc_ants_RegSyN(): not enough arguments')
            end
            if nargin < 6
                fprintf('In obj.proc_ants_RegSyN(): applying default optional arguments...\n')
                other_args=' -d 3 -n 1 -t b -r 4 -p d  ';
            end
            
            %Check if files input exist:
            if ~exist(fixed_img, 'file')
                error('In obj.proc_ants_RegSyN(): fixed_img not found. please check!')
            end
            if ~exist(mov_img, 'file')
                error('In obj.proc_ants_RegSyN(): mov_img not found. please check!')
            end
            
            %Navigate to directory:
            PWD=pwd;
            cd(out_dir)
            warped_img = [ out_prefix '.nii.gz'];
            if exist(warped_img,'file')  ~= 0
                fprintf(['Warped_img: ' out_dir filesep warped_img ' exists. Returning...\n'])
                return
            else
                [~ , ants_exec ] = system('which antsRegistrationSyN.sh');
                exec_cmd=([ strtrim(ants_exec) ' ' other_args ' -m ' mov_img ' -f ' fixed_img ' -o '  out_prefix ]);
                fprintf('\n\n');
                display(exec_cmd);
                fprintf('\n\n');
                fprintf(['Starting coreg in 3 seconds...'])
                pause(3)
                obj.RunBash(exec_cmd,44);
            end
            cd(PWD);
            
        end
        function obj = toremove_replaced_proc_tracxBYmask(obj,tmp_txtfname)
            wasRun=false;
            %INIT exec_cmd:
            if ~exist('exec_cmd','var')
                exec_cmd{:} = 'FIRST INIT proc_tracxBYmask';
            end
            %INIT VARIABLES
            %Introducing local variable for ease of method implementation
            in_bedp_dir     = obj.Params.tracxBYmask.tracula.bedp_dir;
            in_b0           = obj.Params.tracxBYmask.tracula.b0;
            in_txtfname     = obj.Params.tracxBYmask.allmasks.(tmp_txtfname).in.txt_fname;
            in_movefiles    = obj.Params.tracxBYmask.allmasks.(tmp_txtfname).in.movefiles;
            %Creating working directory and assigning a short name:
            obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.dir=obj.getPath(obj.root,in_movefiles);
            out_dir = obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.dir; %short-naming
            
            %~~~
            %%%%%%%%%%%%%% FILE CHECKING: IF EXIST %%%%%%%%%%%%%%%%%%%%%%%%%
            for tohide=1:1
                %Check b0 exists:
                if ~exist(in_b0,'file');
                    error(['proc_tracxBYmask: b0 file ' '' in_b0 '' ' does not exist. Returning...']);
                    return
                end
                %Check if txt_mask_name exists
                if ~exist(in_txtfname,'file');
                    error(['proc_tracxBYmask: txt filename ' '' in_txtfname''  ' does not exist. Returning...']);
                    return
                end
                
                %Check to see that all filepaths/nii.gzs exist in the
                %in_txtfname:
                fileID=fopen(in_txtfname);
                %TODEBUG fileID=fopen('/cluster/cluster/ADRC/Scripts/DEPENDENCIES/fMRI_masks/mask_txt/try_masks_BAD.txt');;
                tmp_txtscan=textscan(fileID,'%s');
                list_MASKS=tmp_txtscan{1};
                for ii=1:numel(list_MASKS)
                    if ~exist(list_MASKS{ii})
                        fprintf('\n\n')
                        display(['proc_tracxBYmask: The ' num2str(ii) 'th iteration filepath: ' '' list_MASKS{ii} '' ]);
                        display(['\nIn: ' '' in_txtfname '' ' does not exist. Please check/change!'])
                        error('Returning...')
                        return
                    end
                end
            end
            %~~%%%%%%%%%%% END OF FILE CHECKING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%% START T1<-->DWI IMPLEMENTATION %%%%%%%%%%%%%%%%%
            %~
            %##########FIRST, DEALING WITH T1 <--> DWI DEPENDENCES ########
            for tohide=1:1
                %COREGISTERING T1 to DWI
                obj.Params.tracxBYmask.T1coregDWI.dir = [obj.root 'post_tracx' filesep 'T1_coreg_dwi' ];
                obj.Params.tracxBYmask.T1coregDWI.in_T1 = [ obj.Params.tracxBYmask.T1coregDWI.dir filesep 'orig_T1.nii' ];
                obj.Params.tracxBYmask.T1coregDWI.out_dwiT1 = [ obj.Params.tracxBYmask.T1coregDWI.dir filesep 'coreg2dwi_orig_T1.nii' ];
                obj.Params.tracxBYmask.T1coregDWI.in_b0 = [ obj.Params.tracxBYmask.T1coregDWI.dir filesep 'b0.nii' ];
                obj.Params.tracxBYmask.T1coregDWI.in_CoRegmat = [ obj.Params.tracxBYmask.T1coregDWI.dir filesep 'CoReg.mat' ];
                %check if files exist:
                %directory:
                if exist(obj.Params.tracxBYmask.T1coregDWI.dir,'dir') == 0
                    exec_cmd{:,end+1} = [  'mkdir -p ' obj.Params.tracxBYmask.T1coregDWI.dir ];
                    obj.RunBash(exec_cmd{end});
                end
                %T1:
                if exist( obj.Params.tracxBYmask.T1coregDWI.in_T1, 'file') == 0
                    display('Copying the T1...');
                    exec_cmd{:,end+1} = ['mri_convert ' strtrim(obj.Params.FreeSurfer.in.T1) ' ' strtrim(obj.Params.tracxBYmask.T1coregDWI.in_T1)  ];
                    obj.RunBash(exec_cmd{end});
                end
                %B0:
                if exist( obj.Params.tracxBYmask.T1coregDWI.in_b0, 'file') == 0
                    if strcmp(obj.Params.tracxBYmask.tracula.b0(end-6:end),'.nii.gz')
                        display('Copying the b0...');
                        exec_cmd{:,end+1} = ['cp ' obj.Params.tracxBYmask.tracula.b0 ' ' obj.Params.tracxBYmask.T1coregDWI.in_b0 '.gz'  ];
                        obj.RunBash(exec_cmd{end});
                        exec_cmd{:,end+1} = ['gunzip ' obj.Params.tracxBYmask.T1coregDWI.in_b0 '.gz'  ];
                        obj.RunBash(exec_cmd{end});
                        
                    elseif strcmp(obj.Params.tracxBYmask.tracula.b0(end-3:end),'.nii')
                        display('Copying the b0...')
                        exec_cmd{:,end+1} = ['cp ' obj.Params.FreeSurfer.in.T1 ' ' obj.Params.tracxBYmask.T1coregDWI.in_b0  ];
                        obj.RunBash(exec_cmd{end});
                    end
                end
                
                %Coregistering now...
                if exist(obj.Params.tracxBYmask.T1coregDWI.in_CoRegmat,'file') == 0
                    exec_cmd{:,end+1} = 'obj.proc_coreg2dwib0(obj.Params.tracxBYmask.T1coregDWI.in_T1,obj.Params.tracxBYmask.T1coregDWI.in_b0,obj.Params.tracxBYmask.T1coregDWI.dir);';
                    eval(exec_cmd{end});
                end
                
                if exist(obj.Params.tracxBYmask.T1coregDWI.out_dwiT1,'file') == 0
                    exec_cmd{:,end+1} = 'obj.proc_apply_coreg2dwib0(obj.Params.tracxBYmask.T1coregDWI.in_T1,0,obj.Params.tracxBYmask.T1coregDWI.in_b0);';
                    eval(exec_cmd{end});
                end
                %END OF COREGISTRERING T1 to DWI
                %~~~
                
                
                %PROCESSING T1 BASED ON SPM.
                obj.Params.tracxBYmask.coregT12DWI.dir = [obj.root 'post_tracx' filesep 'coregT1_spm_proc' ];
                obj.Params.tracxBYmask.coregT12DWI.in_T1 = obj.Params.tracxBYmask.T1coregDWI.out_dwiT1;
                obj.Params.tracxBYmask.coregT12DWI.in_Affinemat = [ obj.Params.tracxBYmask.coregT12DWI.dir  filesep 'Affine.mat' ];
                
                [~, tmp_coT1_bname, tmp_cT1_ext ] = fileparts(obj.Params.tracxBYmask.coregT12DWI.in_T1);
                obj.Params.tracxBYmask.coregT12DWI.out_regfile = [ obj.Params.tracxBYmask.coregT12DWI.dir  filesep 'iy_' tmp_coT1_bname, tmp_cT1_ext  ];
                %check if files exist:
                %directory:
                if exist(obj.Params.tracxBYmask.coregT12DWI.dir,'dir') == 0
                    exec_cmd{:,end+1} = [  'mkdir -p ' obj.Params.tracxBYmask.coregT12DWI.dir ];
                    obj.RunBash(exec_cmd{end});
                end
                %regile:
                if exist(obj.Params.tracxBYmask.coregT12DWI.out_regfile) == 0
                    exec_cmd{:,end+1} = 'obj.proc_t1_spm(obj.Params.tracxBYmask.coregT12DWI.in_T1,obj.Params.tracxBYmask.coregT12DWI.dir);' ;
                    eval(exec_cmd{end});
                end
            end
            %##########END OF DEALING WITH T1 <--> DWI DEPENDENCES ########
            %##############################################################
            
            %%%%%%%%%%%%%% START TRACX IMPLEMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%
            %IMPLEMENTATION STARTS HERE:
            fprintf('\n\nLOOPING THORUGH THE TXT_FILE....\n');
            display('MAKE SURE FILENAMES ARE IN THE SAME SPACE AS THE FIRST FILENAME/MASK');
            fprintf('*Supporting only *.nii for now.\n\n');
            pause(2)
            %Loop for every mask created
            for ii=1:numel(list_MASKS)
                %Split parts:
                [curmask_dir , curmask_bname, curmask_ext ] = fileparts(list_MASKS{ii});
                
                %Initialize the probtracx shell command.
                %If created, we can skip all these loops
                %Integrate the probtracx commands in here:
                obj.Params.tracxBYmask.allmasks.(tmp_txtfname).sh_cmd_torun{ii} = [ out_dir 'torun_probtracx2_' curmask_bname  '.sh'];
                if exist(obj.Params.tracxBYmask.allmasks.(tmp_txtfname).sh_cmd_torun{ii},'file') == 0
                    %Check if masks are aligned to MNI. If not, align
                    [m_TMP h_TMP] = openIMG(obj.Params.tracxBYmask.T1_tmp);
                    [m_curMASK h_curMASK] = openIMG(list_MASKS{ii});
                    if isequal(h_curMASK.dim,h_TMP.dim)
                        %If *.mats differ, copy the same MNI:
                        if ~isequal(h_curMASK.mat,h_TMP.mat)
                            fprintf(['In txt iteration ' '' num2str(ii) ''  ' Correcting h.matrix to match header...']);
                            h_curMASK.mat= h_TMP.mat;
                            spm_write_vol(h_curMASK,m_curMASK);
                            fprintf('..done\n');
                        end
                    else
                        error([' Template: obj.Params.tracxBYmask.T1_tmp has different dimenisions than mask at iteration: ' num2str(ii) ]);
                    end
                    
                    %Create split mask directory for each mask
                    cur_split_dir{ii}= [out_dir filesep 'split_' curmask_bname filesep];
                    cur_split_dir{ii}=regexprep(cur_split_dir{ii},[filesep filesep], filesep);
                    system(['mkdir -p ' cur_split_dir{ii} ]);
                    %Reverse normalize the mask so its align with T1 or b0
                    obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.revN{ii}= [ cur_split_dir{ii} 'revN_' curmask_bname curmask_ext];
                    if exist(obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.revN{ii},'file') == 0
                        exec_cmd{:,end+1} = [ 'obj.proc_apply_resversenorm(list_MASKS{ii}, ' ...
                            ' obj.Params.tracxBYmask.coregT12DWI.out_regfile,in_b0, cur_split_dir{ii}, ''revN_'' );'] ;
                        eval(exec_cmd{end});
                    end
                    %QuickReslice:
                    obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.reslicedN{ii}= [ cur_split_dir{ii} 'resliced_revN_' curmask_bname curmask_ext];
                    if exist(obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.reslicedN{ii},'file') == 0
                        exec_cmd{:,end+1} = 'obj.proc_reslice([ cur_split_dir{ii} ''revN_'' curmask_bname curmask_ext ],in_b0,'''', ''resliced_'' );';
                        eval(exec_cmd{end});
                    end
                    %Splitting the reversed normalized, resliced mask:
                    [~, obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.n_masks{ii} ] = ...
                        system(['fslstats  ' obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.reslicedN{ii} ' -R | awk ''{print $2}'' ' ]);
                    %making it a number (instead of a character class):
                    obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.n_masks{ii} = str2num(obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.n_masks{ii});
                    
                    %Pad the last mask number with zeros:
                    if obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.n_masks{ii} < 10
                        pad_lastmask = [ '000' num2str(obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.n_masks{ii})];
                    elseif obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.n_masks{ii} < 100
                        pad_lastmask = [ '00' num2str(obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.n_masks{ii})];
                    elseif obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.n_masks{ii} < 1000
                        pad_lastmask = [ '0' num2str(obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.n_masks{ii})];
                    else
                        pad_lastmask = [ num2str(obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.n_masks{ii})];
                    end
                    
                    %Splitting the mask by intensity:
                    obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.last_mask{ii} = [ cur_split_dir{ii} 'split_' pad_lastmask '_' curmask_bname '.nii.gz'];
                    if exist(obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.last_mask{ii},'file') == 0
                        %Then, we will redo the split...first remove previous
                        %splits:
                        display(['Removing previous split_* for ' cur_split_dir{ii}]);
                        [~, b] = system(['rm ' cur_split_dir{ii} 'split*']);
                        %then split by mask
                        fprintf(['\nSplitting ' curmask_bname '...'])
                        display('In iteration: ' )
                        exec_cmd{:,end+1} = ['Splitting mask: ' obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.reslicedN{ii} ' using fslmaths -thr -uthr arguments.'];
                        for ss=1:obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.n_masks{ii}
                            %padding zeros:
                            if ss < 10
                                idx = [ '000' num2str(ss)];
                            elseif ss < 100
                                idx = [ '00' num2str(ss)];
                            elseif ss < 1000
                                idx = [ '0' num2str(ss)];
                            else
                                idx = [ num2str(ss)];
                            end
                            system(['fslmaths ' obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.reslicedN{ii} ...
                                ' -uthr ' idx ' -thr ' idx ' ' cur_split_dir{ii} 'split_' idx '_' curmask_bname ]);
                            fprintf([ idx ' ']);
                            if ~mod(ss,20); fprintf('\n'); end
                        end
                        fprintf('..done \n');
                    end
                    
                    %Is the txt file created?
                    obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.txt_masks{ii} = [ cur_split_dir{ii} 'seeds_' curmask_bname '.txt'];
                    if exist(obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.txt_masks{ii},'file')
                        system(['rm ' obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.txt_masks{ii}  ]);
                    end
                    %Creating the file:
                    fprintf(['\nInitializing the seeds_*.txt file for mask: ' tmp_txtfname ' in filename' curmask_bname  ' (iteration: ' num2str(ii) ' )']);
                    system(['touch ' obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.txt_masks{ii}]);
                    
                    %Creating a list of the split*
                    [~, tmp_list{ii} ] = system(['ls -1 ' cur_split_dir{ii} 'split*']);
                    %Write to txt now:
                    fileID=fopen(obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.txt_masks{ii},'w');
                    fprintf(fileID,'%s',tmp_list{ii}) ; fclose(fileID);
                    fprintf('..done \n');
                    
                    %Move probtracx2 directory if it exists:
                    obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.probtrackx2_dir{ii} = [ out_dir 'pbtrackx2_out_' curmask_bname ];
                    %unless it has already been moved:
                    if exist([obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.probtrackx2_dir{ii} '_bak_' date],'dir') ~= 0
                        error(['Cannot move ' obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.probtrackx2_dir{ii} ' to a backup directory. The date already exists! ']);
                    end
                    %if not, move it
                    if exist(obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.probtrackx2_dir{ii},'dir') ~= 0
                        system(['mv ' obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.probtrackx2_dir{ii} ' ' ...
                            obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.probtrackx2_dir{ii} '_bak_' date]);
                    end
                    %NO NEED TO CREATE THIS->: system(['mkdir -p ' obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.probtrackx2_dir{ii}]);
                    
                    %Create a shell script with the necessary commands in this specific mask:
                    exec_cmd{:,end+1} = ['/usr/pubsw/packages/fsl/5.0.9/bin/probtrackx2 --network -x  ' ...
                        obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.txt_masks{ii} ' ' ...
                        obj.Params.tracxBYmask.allmasks.(tmp_txtfname).probtracx2_args ' ' ...
                        ' -s ' obj.Params.tracxBYmask.tracula.bedp_dir filesep 'merged' ...
                        ' -m ' obj.Params.tracxBYmask.tracula.bedp_dir filesep 'nodif_brain_mask' ...
                        ' --dir=' obj.Params.tracxBYmask.allmasks.(tmp_txtfname).out.probtrackx2_dir{ii} ...
                        ];
                    
                    %Writing out the command shell needed:
                    fprintf(['\nIntegrating the probtrackx2 command into a shell script. txt_mask_fname line iteratoin: ' num2str(ii) '\n']);
                    if exist(obj.Params.tracxBYmask.allmasks.(tmp_txtfname).sh_cmd_torun{ii},'file') ~= 0
                        system(['mv ' obj.Params.tracxBYmask.allmasks.(tmp_txtfname).sh_cmd_torun{ii} ' ' ...
                            obj.Params.tracxBYmask.allmasks.(tmp_txtfname).sh_cmd_torun{ii} '_bak_' date]);
                    end
                    system(['touch ' obj.Params.tracxBYmask.allmasks.(tmp_txtfname).sh_cmd_torun{ii} ]);
                    %Write to sh now:
                    fileID=fopen(obj.Params.tracxBYmask.allmasks.(tmp_txtfname).sh_cmd_torun{ii},'w');
                    fprintf(fileID,'%s',exec_cmd{end}) ;
                    fprintf(fileID,'\n\n');
                    wasRun=true;
                    fclose(fileID); fprintf('..done \n');
                end
            end
            
            %Letting the user know that these commands should be run
            %away from the matlab environment (so it can be easily
            %batch in pbs).
            if wasRun
                fprintf('\nRun the following script from command line: \n');
                for jj=1:numel(obj.Params.tracxBYmask.allmasks.(tmp_txtfname).sh_cmd_torun)
                    fprintf([obj.Params.tracxBYmask.allmasks.(tmp_txtfname).sh_cmd_torun{ii} '\n']);
                end
                obj.UpdateHist_v2(obj.Params.tracxBYmask.allmasks.(tmp_txtfname),'proc_tracxBYmask', obj.Params.tracxBYmask.allmasks.(tmp_txtfname).sh_cmd_torun{end},wasRun,exec_cmd);
                fprintf('**ALTERNTATIVELY: create a protected method prot_run_TRACTx() <ontheworks> \n');
            end
            fprintf(['\n\nPROBTRACKX2 SH COMMAND CREATION COMPLETED \n\n']);
            %%%%%%%%%%%%%% END OF  TRACX IMPLEMENTATION %%%%%%%%%%%%%%%%%%%
            
        end
        
        %%%%%%%%%%%%%%%%%%% END Data Post-Processing Methods %%%%%%%%%%%%%%
    end
    
    %Protected methods:
    methods (Access = protected)
        %TODOS:
        % 1. Prefix all these methods prot_* instead of proc_* or nothing
        % so it will be easier to know how/where it was accessed. 
        %TRKLAND DEPENDENT METHODS:
        function obj = initinputsTRKLAND(obj,TOI)
            %INIT INPUTS
            switch TOI
                case 'fx'
                    %CHECKING FORNIX TEMPLATE INPUT ORIENTATION:
                    if strcmp(obj.Trkland.fx.tmp.ori,'LPS')
                        obj.Trkland.fx.tmp.b0 = [ obj.fx_template_dir 'LPS_141210_8CS00178_b0.nii.gz' ] ;
                        obj.Trkland.fx.tmp.roa_solid_bil =[ obj.fx_template_dir 'LPS_TMP_178_bil_fx_dil11.nii.gz' ] ;
                        obj.Trkland.fx.tmp.roa_solid_lh = [ obj.fx_template_dir 'LPS_TMP_178_lh_fx_dil11.nii.gz' ] ;
                        obj.Trkland.fx.tmp.roa_solid_rh = [ obj.fx_template_dir 'LPS_TMP_178_rh_fx_dil11.nii.gz' ] ;
                        obj.Trkland.fx.tmp.roi_bil = [ obj.fx_template_dir 'LPS_TMP_178_bil_fx_dil.nii.gz' ] ;
                        obj.Trkland.fx.tmp.roi_lh = [ obj.fx_template_dir 'LPS_TMP_178_lh_fx_dil.nii.gz' ] ;
                        obj.Trkland.fx.tmp.roi_rh = [ obj.fx_template_dir 'LPS_TMP_178_rh_fx_dil.nii.gz' ] ;
                    elseif strcmp(obj.Trkland.fx.tmp.ori,'RAS')
                        obj.Trkland.fx.tmp.b0 = [ obj.fx_template_dir 'RAS_141210_8CS00178_b0.nii.gz' ] ;
                        obj.Trkland.fx.tmp.roa_solid_bil =[ obj.fx_template_dir 'RAS_TMP_178_bil_fx_dil11.nii.gz' ] ;
                        obj.Trkland.fx.tmp.roa_solid_lh = [ obj.fx_template_dir 'RAS_TMP_178_lh_fx_dil11.nii.gz' ] ;
                        obj.Trkland.fx.tmp.roa_solid_rh = [ obj.fx_template_dir 'RAS_TMP_178_rh_fx_dil11.nii.gz' ] ;
                        obj.Trkland.fx.tmp.roi_bil = [ obj.fx_template_dir 'RAS_TMP_178_bil_fx_dil.nii.gz' ] ;
                        obj.Trkland.fx.tmp.roi_lh = [ obj.fx_template_dir 'RAS_TMP_178_lh_fx_dil.nii.gz' ] ;
                        obj.Trkland.fx.tmp.roi_rh = [ obj.fx_template_dir 'RAS_TMP_178_rh_fx_dil.nii.gz' ] ;
                    else
                        error('In trkland_fx() Init: Cannot find the right fornix template orientation to use for co-registration. Quitting...');
                    end
                    %IN PARAMS:
                    %Hippocampi:
                    obj.Trkland.fx.in.hippo_lh =  strrep(obj.Params.FS2dwi.out.fn_aparc,'dwi_aparc+aseg.nii.gz','aparc2009_aseg/dwi_fs_Left-Hippocampus.nii.gz');
                    obj.Trkland.fx.in.hippo_rh =  strrep(obj.Params.FS2dwi.out.fn_aparc,'dwi_aparc+aseg.nii.gz','aparc2009_aseg/dwi_fs_Right-Hippocampus.nii.gz');
                    %Thalami:
                    obj.Trkland.fx.in.thalamus_lh = strrep(obj.Params.FS2dwi.out.fn_aparc,'dwi_aparc+aseg.nii.gz','aparc2009_aseg/dwi_fs_Left-Thalamus-Proper.nii.gz');
                    obj.Trkland.fx.in.thalamus_rh = strrep(obj.Params.FS2dwi.out.fn_aparc,'dwi_aparc+aseg.nii.gz','aparc2009_aseg/dwi_fs_Right-Thalamus-Proper.nii.gz');
                    %tmp2b0s params:
                    obj.Trkland.fx.in.fn_tmp2b0 =  [ obj.Trkland.root 'fx_tmp2b0.nii.gz' ];
                    obj.Trkland.fx.in.tmp2b0_matfile = [ obj.Trkland.root 'fx_tmp2b0.mat'];
                    %bil params:
                    obj.Trkland.fx.in.roi_bil = [ obj.Trkland.root 'fx_roi_bil.nii.gz'];
                    obj.Trkland.fx.in.roa_bil_solid = [ obj.Trkland.root 'fx_roa_bil_solid.nii.gz'];
                    obj.Trkland.fx.in.roa_bil_ero =  [ obj.Trkland.root 'fx_roa_bil_ero.nii.gz'];
                    obj.Trkland.fx.in.roa_bil_hollow = [ obj.Trkland.root 'fx_roa_bil_hollow.nii.gz'];
                    %lh params:
                    obj.Trkland.fx.in.roi_lh_hippo = strrep(obj.Params.FS2dwi.out.fn_aparc2009, ...
                        'dwi_aparc.a2009+aseg',[ 'aparc2009_aseg' filesep 'dwi_fs_Left-Hippocampus' ]);
                    obj.Trkland.fx.in.roi_lh = [ obj.Trkland.root 'fx_roi_lh.nii.gz'];
                    obj.Trkland.fx.in.roa_lh_solid = [ obj.Trkland.root 'fx_roa_lh_solid.nii.gz'];
                    obj.Trkland.fx.in.roa_lh_ero = [ obj.Trkland.root 'fx_roa_lh_ero.nii.gz'];
                    obj.Trkland.fx.in.roa_lh_hollow = [ obj.Trkland.root 'fx_roa_lh_hollow.nii.gz'];
                    %rh params:
                    obj.Trkland.fx.in.roi_rh_hippo = strrep(obj.Params.FS2dwi.out.fn_aparc2009, ...
                        'dwi_aparc.a2009+aseg',[ 'aparc2009_aseg' filesep 'dwi_fs_Right-Hippocampus' ]);
                    obj.Trkland.fx.in.roi_rh = [ obj.Trkland.root 'fx_roi_rh.nii.gz'];
                    obj.Trkland.fx.in.roa_rh_solid = [ obj.Trkland.root 'fx_roa_rh_solid.nii.gz'];
                    obj.Trkland.fx.in.roa_rh_ero = [ obj.Trkland.root 'fx_roa_rh_ero.nii.gz'];
                    obj.Trkland.fx.in.roa_rh_hollow = [ obj.Trkland.root 'fx_roa_rh_hollow.nii.gz'];
                otherwise
                    error([ TOI  'initiazliing input  not implemented yet. Please do!']);
            end
        end
        function obj = initoutputsTRKLAND(obj,TOI,outpath)
            %INIT OUTPUTS
            obj.Trkland.(TOI).out.raw_lh = [ obj.Trkland.root  'trkk_' TOI '_raw_lh.trk.gz'];
            obj.Trkland.(TOI).out.raw_rh = [ obj.Trkland.root  'trkk_' TOI '_raw_rh.trk.gz'];
            
            obj.Trkland.(TOI).out.trimmed_lh = [  obj.Trkland.root  'trkk_' TOI '_trimmed_lh.trk.gz' ];
            obj.Trkland.(TOI).out.trimmed_rh = [  obj.Trkland.root  'trkk_' TOI '_trimmed_rh.trk.gz'];
            
            %For FX vs. stria terminalis criteria (Updated)
            if strcmp(TOI,'fx')
                obj.Trkland.(TOI).out.trimmedC4_lh = [  obj.Trkland.root  'trkk_' TOI '_trimmedC4_lh.trk.gz' ];
                obj.Trkland.(TOI).out.trimmedC4_rh = [  obj.Trkland.root  'trkk_' TOI '_trimmedC4_rh.trk.gz'];
            end
            
            obj.Trkland.(TOI).out.trimmedclean_lh = [ obj.Trkland.root  'trkk_' TOI '_trimmedclean_lh.trk.gz'];
            obj.Trkland.(TOI).out.trimmedclean_rh = [ obj.Trkland.root  'trkk_' TOI '_trimmedclean_rh.trk.gz'];
            
            obj.Trkland.(TOI).out.trimmedclean_interp_lh = [  obj.Trkland.root  'trkk_' TOI '_trimmedclean_interp_lh.trk.gz' ];
            obj.Trkland.(TOI).out.trimmedclean_interp_rh = [  obj.Trkland.root  'trkk_' TOI '_trimmedclean_interp_rh.trk.gz'];
            
            obj.Trkland.(TOI).out.clineFAHighFA_lh = [ obj.Trkland.root  'trkk_' TOI '_clineFAHighFA_lh.trk.gz'];
            obj.Trkland.(TOI).out.clineFAHighFA_rh = [ obj.Trkland.root  'trkk_' TOI '_clineFAHighFA_rh.trk.gz'];
            
            
            obj.Trkland.(TOI).out.clineFAHDorff_lh = [ obj.Trkland.root  'trkk_' TOI '_clineHDorff_lh.trk.gz'];
            obj.Trkland.(TOI).out.clineFAHDorff_rh = [ obj.Trkland.root  'trkk_' TOI '_clineHDorff_rh.trk.gz'];
            
            obj.Trkland.(TOI).QCfile_lh =  [outpath 'QC_' TOI '_lh.flag'] ;
            obj.Trkland.(TOI).QCfile_rh =  [outpath 'QC_' TOI '_rh.flag'] ;
            obj.Trkland.(TOI).QCfile_bil = [outpath 'QC_' TOI '_bil.flag'] ;
        end
        function obj = addDTI(obj,trk_name)
            %If statements avoid repeating value extraction (fixed 3/21/18):
            if isempty(find(ismember( obj.Trkland.Trks.(trk_name).header.scalar_name,'FA'), 1))
                obj.Trkland.Trks.(trk_name) = rotrk_add_sc(  obj.Trkland.Trks.(trk_name) ,obj.Params.Dtifit.out.FA{end} , 'FA');
            end
            if isempty(find(ismember( obj.Trkland.Trks.(trk_name).header.scalar_name,'RD'),1))
                obj.Trkland.Trks.(trk_name) = rotrk_add_sc(  obj.Trkland.Trks.(trk_name) ,strrep(obj.Params.Dtifit.out.FA{end},'FA','RD') , 'RD');
            end
            if isempty(find(ismember( obj.Trkland.Trks.(trk_name).header.scalar_name,'AxD'),1))
                obj.Trkland.Trks.(trk_name) = rotrk_add_sc(  obj.Trkland.Trks.(trk_name) ,strrep(obj.Params.Dtifit.out.FA{end},'FA','AxD') , 'AxD');
            end
            if isempty(find(ismember( obj.Trkland.Trks.(trk_name).header.scalar_name,'MD'),1))
                obj.Trkland.Trks.(trk_name) = rotrk_add_sc(  obj.Trkland.Trks.(trk_name) ,strrep(obj.Params.Dtifit.out.FA{end},'FA','MD') , 'MD');
            end
        end
        function obj = applyTRKLAND(obj,TOI,HEMI)
            %TOI is the tract of interest (e.g. 'fx')
            %HEMI is the hemisphere (e.g. 'lh')
            %CLEANING UP THE STREAMLINES
            if  exist(obj.Trkland.(TOI).out.(['raw_' HEMI]),'file') ~= 0
                %ADD VALUES TO FIELDS IF IT DOESN'T EXIST
                if ~isfield(obj.Trkland.Trks,[TOI '_raw_' HEMI])
                    fprintf(['\nPopulating obj.Trkland.Trks.' TOI '_raw_' HEMI '...' ]);
                    obj.Trkland.Trks.([TOI '_raw_' HEMI ]) = rotrk_read(obj.Trkland.(TOI).out.(['raw_' HEMI]), obj.sessionname, obj.Params.Dtifit.out.FA{end}, [TOI '_raw_' HEMI]);
                    %add DTI scalars
                    obj.addDTI([TOI '_raw_' HEMI ]);
                    obj.Trkland.(TOI).data.([HEMI '_done']) = 0 ; %Denoting we want the data to be extracted again!
                    fprintf('done\n');
                end
                %~~~
                %START TRIMMED PROCESS:~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                if exist(obj.Trkland.(TOI).out.(['trimmed_' HEMI ]),'file') == 0 
                    %Trim tracts here:
                    switch TOI
                        case 'fx'
                        obj.Trkland.Trks.([TOI '_trimmed_' HEMI ]) = rotrk_trimmedbyTOI(obj.Trkland.Trks.([ TOI '_raw_' HEMI]), ...
                            [ {obj.Trkland.(TOI).in.(['hippo_' HEMI])} {obj.Trkland.(TOI).in.(['thalamus_' HEMI])}  ], [ TOI '_' HEMI ]);
                        case 'cingulum'
                        obj.Trkland.Trks.([TOI '_trimmed_' HEMI ])  = rotrk_trimmedbyTOI(obj.Trkland.Trks.([ TOI '_raw_' HEMI]), ...
                            [ {obj.Trkland.(TOI).in.(['seed_postcing_' HEMI ])}  {obj.Trkland.(TOI).in.(['rostantcing_' HEMI ])}  ], ['cingulum_' HEMI]);
                        case 'hippocing'
                        obj.Trkland.Trks.([TOI '_trimmed_' HEMI]) = rotrk_trimmedbyTOI(obj.Trkland.Trks.([ TOI '_raw_' HEMI]), ...
                            [ {obj.Trkland.(TOI).in.(['hippo_' HEMI ])} {obj.Trkland.(TOI).in.(['roi_postcing_' HEMI ])} ], ['postcing_' HEMI]);
                        otherwise
                            error(['In obj.applyTRKLAND(): Canot recognize ''' TOI ''' as an implemented tract of interest. Please check!'])
                    end
                    if ~isempty(obj.Trkland.Trks.([TOI '_trimmed_' HEMI ]).sstr)
                        %Saving trimmed tracts:
                        rotrk_write(obj.Trkland.Trks.([ TOI '_trimmed_' HEMI ]).header,...
                            obj.Trkland.Trks.([TOI '_trimmed_' HEMI]).sstr,obj.Trkland.(TOI).out.(['trimmed_' HEMI ]));
                        fprintf(['\nPopulating obj.Trkland.Trks.' TOI '_trimmed_' HEMI '...']);
                        obj.Trkland.Trks.([TOI '_trimmed_' HEMI]) = rotrk_read(obj.Trkland.(TOI).out.([ 'trimmed_' HEMI]),obj.sessionname,obj.Params.Dtifit.out.FA{end},[TOI '_trimmed_' HEMI]);
                        obj.addDTI([TOI '_trimmed_' HEMI]);
                        obj.Trkland.(TOI).data.([HEMI '_done']) = 0;
                        fprintf('done\n');
                        
                    else
                        %Empty the fields in the MATLAB envinronment:
                        obj.Trkland.Trks.([ TOI '_trimmed_' HEMI ]).header = [];
                        obj.Trkland.Trks.([ TOI '_trimmed_' HEMI ]).sstr = [];
                        obj.Trkland.(TOI).data.([HEMI '_done']) = 0;
                    end
                end
                
                %Check if the obj.Trkland.Trks.<TRIMMED_VALUES> are empty:
                if obj.Trkland.(TOI).data.([HEMI '_done']) == 0
                    obj.repopulateTRKLAND([TOI '_trimmed_' HEMI],TOI,HEMI);
                end
            else
                obj.Trkland.Trks.([ TOI '_trimmed_' HEMI ]).header = [];
                obj.Trkland.Trks.([ TOI '_trimmed_' HEMI ]).sstr = [];
                obj.Trkland.(TOI).data.([HEMI '_done']) = 0;
            end
            %~~~~~~~~~~~~~~~~~~~~~~~~~~~END OF TRIMMED PROCESSS

            
            
            %TRIMMEDCLEAN, INTERPOLATION, CLINEHIGHFA nad HAUSDORFF
            %STARTS HERE:
            %AS IT's DEPENDENT ON A SUCCESSFULL TRIMMING...
            if  exist(obj.Trkland.(TOI).out.(['trimmed_' HEMI ]),'file') ~= 0
                %START TRIMMEDCLEAN PROCESS:~~~~~~~~~~~~~~~~~~~~~~~
                %Check if the object Trks is located, if not loaded.
                if exist(obj.Trkland.(TOI).out.(['trimmedclean_' HEMI ]),'file') == 0
                    %Adding criteria 4 (for FX only, separating FX vs.
                    %stria terminalis:
                    if strcmp(TOI,'fx')
                        %START TRIMMEDC4 PROCESS:~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if exist(obj.Trkland.(TOI).out.(['trimmedC4_' HEMI ]),'file') == 0
                            %Apply Criteria 4:
                            obj.Trkland.Trks.([TOI '_trimmedC4_' HEMI ]) = rotrk_trimmedbyTOI_fx_crit4(obj.Trkland.Trks.([ TOI '_trimmed_' HEMI]), ...
                                [ {obj.Trkland.(TOI).in.(['hippo_' HEMI])} {obj.Trkland.(TOI).in.(['thalamus_' HEMI])}  ], [ TOI '_' HEMI ]);
                            
                            %Saving trimmed tracts:
                            rotrk_write(obj.Trkland.Trks.([ TOI '_trimmedC4_' HEMI ]).header,...
                                obj.Trkland.Trks.([TOI '_trimmedC4_' HEMI]).sstr,obj.Trkland.(TOI).out.(['trimmedC4_' HEMI ]));
                            obj.Trkland.(TOI).data.([HEMI '_done' ]) = 0;
                            
                            %Empty the consequence field to update the
                            %matlab environment with the newer value:
                            obj.Trkland.Trks = rmfield(obj.Trkland.Trks,[TOI '_trimmedC4_' HEMI]);
                        end
                        %~~~~~~~~~~~~~~~~~~~~~~~~~~~END OF TRIMMEDC4 PROCESSS
                    end
                    if obj.Trkland.(TOI).data.([HEMI '_done']) == 0
                        obj.repopulateTRKLAND([TOI '_trimmedC4_' HEMI],TOI,HEMI);
                    end
                    %TRIMMED PROCESSING STARTS HERE:
                    if strcmp(TOI,'fx')
                        %Select the HDorff centerline(first pass)
                        obj.Trkland.Trks.([ TOI '_clineinit_' HEMI ]) = rotrk_centerline(obj.Trkland.Trks.([ TOI '_trimmedC4_' HEMI ]),'hausdorff');
                        %Create a trimmedclean tract:
                        obj.Trkland.Trks.([ TOI '_trimmedclean_' HEMI ]) = rotrk_rm_byHDorff(obj.Trkland.Trks.([ TOI '_clineinit_' HEMI ]),  ...
                            obj.Trkland.Trks.([ TOI '_trimmedC4_' HEMI ] ),obj.Trkland.Trks.([ TOI '_trimmedC4_' HEMI ]));
                    else
                        %Select the HDorff centerline(first pass)"
                        obj.Trkland.Trks.([ TOI '_clineinit_' HEMI ]) = rotrk_centerline(obj.Trkland.Trks.([ TOI '_trimmed_' HEMI ]),'hausdorff');
                        %Create a trimmed clean tract:
                        obj.Trkland.Trks.([ TOI '_trimmedclean_' HEMI ]) = rotrk_rm_byHDorff(obj.Trkland.Trks.([ TOI '_clineinit_' HEMI ]),  ...
                            obj.Trkland.Trks.([ TOI '_trimmed_' HEMI ] ),obj.Trkland.Trks.([ TOI '_trimmed_' HEMI ]));
                    end
                    %Saving trimmed and trimmed_clean trks:
                    rotrk_write(obj.Trkland.Trks.([TOI '_trimmedclean_' HEMI ]).header,obj.Trkland.Trks.([ TOI '_trimmedclean_' HEMI ]).sstr,obj.Trkland.(TOI).out.(['trimmedclean_' HEMI ]));
                    obj.Trkland.(TOI).data.([HEMI '_done']) = 0;
                    obj.repopulateTRKLAND([TOI '_trimmedclean_' HEMI],TOI,HEMI);
                end
                %~~~~~~~~~~~~~~~~~~~~~~END OF TRIMMEDCLEAN PROCESSS
                
                %START TRIMMEDCLEAN_INTERP PROCESS:~~~~~~~~~~~~~~~~
                if exist(obj.Trkland.(TOI).out.(['trimmedclean_interp_' HEMI ]),'file') == 0 
                    obj.Trkland.Trks.([TOI '_trimmedclean_interp_' HEMI ]) = rotrk_interp(obj.Trkland.Trks.([ TOI '_trimmedclean_' HEMI]),obj.Trkland.(TOI).in.n_interp);
                    rotrk_write(obj.Trkland.Trks.([TOI '_trimmedclean_interp_' HEMI ]).header,...
                        obj.Trkland.Trks.([TOI '_trimmedclean_interp_' HEMI ]).sstr,obj.Trkland.(TOI).out.(['trimmedclean_interp_' HEMI ]));
                    obj.Trkland.(TOI).data.([HEMI '_done']) = 0;
                    
                    %remove field for matlab environment to re-populate:
                    obj.Trkland.Trks=rmfield(obj.Trkland.Trks,[ TOI '_trimmedclean_interp_' HEMI]);
                end
                %~~~~~~~~~~~~~~~END OF TRIMMEDCLEAN_INTERP PROCESS
                if obj.Trkland.(TOI).data.([HEMI '_done']) == 0
                    obj.repopulateTRKLAND([ TOI '_trimmedclean_interp_' HEMI],TOI,HEMI);
                end
                %START SELECTING HIGHFA PROCESS:~~~~~~~~~~~~~~~~~~~
                if exist(obj.Trkland.(TOI).out.(['clineFAHighFA_' HEMI ]),'file') == 0
                    obj.addDTI([ TOI '_trimmedclean_interp_' HEMI]);
                    obj.Trkland.Trks.([ TOI '_clineFAHighFA_' HEMI ]) = rotrk_centerline(obj.Trkland.Trks.([ TOI '_trimmedclean_interp_' HEMI]), 'high_sc','FA');
                    rotrk_write(obj.Trkland.Trks.([TOI '_clineFAHighFA_' HEMI ]).header, ...
                        obj.Trkland.Trks.([ TOI '_clineFAHighFA_' HEMI ]).sstr,obj.Trkland.(TOI).out.(['clineFAHighFA_' HEMI ]) );
                    obj.Trkland.(TOI).data.([HEMI '_done']) = 0;
                    
                    %remove field for matlab envinronment to repopulate
                    obj.Trkland.Trks=rmfield(obj.Trkland.Trks,[TOI '_clineFAHighFA_' HEMI]);
                end
                if obj.Trkland.(TOI).data.([HEMI '_done']) == 0
                    obj.repopulateTRKLAND([TOI '_clineFAHighFA_' HEMI],TOI,HEMI);
                end
                %~~~~~~~~~~~~~~~~~~~END OF SELECTING HIGHFA PROCESS
                
                %START SELECTING MOD-HAUSDORFF PROCESS:~~~~~~~~~~~~
                if exist(obj.Trkland.(TOI).out.(['clineFAHDorff_' HEMI ]),'file') == 0
                    obj.Trkland.Trks.([TOI '_clineHDorff_' HEMI ]) = rotrk_centerline(obj.Trkland.Trks.([ TOI '_trimmedclean_interp_' HEMI ]), 'hausdorff');
                    rotrk_write(obj.Trkland.Trks.([ TOI '_clineHDorff_' HEMI ]).header,...
                        obj.Trkland.Trks.([TOI '_clineHDorff_' HEMI ]).sstr,obj.Trkland.(TOI).out.(['clineFAHDorff_' HEMI ]) );
                    obj.Trkland.(TOI).data.([HEMI '_done']) = 0;
                    
                    %Remove MATLAB environment field to repopulate:
                    obj.Trkland.Trks=rmfield(obj.Trkland.Trks,[TOI '_clineHDorff_' HEMI]);
                end
                
                %CANNOT USE --> obj.repopulateTRKLAND([TOI '_clineHDorff_' HEMI],TOI,HEMI);
                %BECAUSETHERE ARE ISSUES WITH NAMING CONVENTION (TOFIX)
                %_clineHDorff_ vs. _clineFAHDorff_ 
                %DO IT SEPARATELY!
                if obj.Trkland.(TOI).data.([HEMI '_done']) == 0
                    %If the file trk is empty:
                    %Two conditions: 1) if the file trk is not a field:
                    if ~isfield(obj.Trkland.Trks,[TOI '_clineHDorff_' HEMI])
                        fprintf(['\nPopulating obj.Trkland.Trks.' TOI '_clineHDorff_' HEMI ' ...']);
                        obj.Trkland.Trks.([TOI '_clineHDorff_' HEMI]) = rotrk_read(obj.Trkland.(TOI).out.(['clineFAHDorff_' HEMI ]), ...
                            obj.sessionname,obj.Params.Dtifit.out.FA{end},[ TOI '_clineHDorff_' HEMI ]);
                        obj.addDTI([ TOI '_clineHDorff_' HEMI]);
                        obj.Trkland.(TOI).data.([HEMI '_done']) = 0;
                        fprintf('done\n');
                    end
                    %Two conditions: 2) if the file trk.headaer is empty:
                    if ~isempty(obj.Trkland.Trks.([TOI '_clineHDorff_' HEMI]).header)
                        fprintf(['\nPopulating obj.Trkland.Trks.' TOI '_clineHDorff_' HEMI ' ...']);
                        obj.Trkland.Trks.([TOI '_clineHDorff_' HEMI]) = rotrk_read(obj.Trkland.(TOI).out.(['clineFAHDorff_' HEMI ]), ...
                            obj.sessionname,obj.Params.Dtifit.out.FA{end},[ TOI '_clineHDorff_' HEMI ]);
                        obj.addDTI([ TOI '_clineHDorff_' HEMI]);
                        obj.Trkland.(TOI).data.([HEMI '_done']) = 0;
                        fprintf('done\n');
                    end
                end
                %~~~~~~~~~~~~~~~END SELECTING MOD-HAUSDORFF PROCESS
            else
                obj.Trkland.Trks.([TOI '_trimmedclean_' HEMI]).header = [];
                obj.Trkland.Trks.([TOI '_trimmedclean' HEMI]).sstr = [];
                obj.Trkland.Trks.([TOI '_trimmedclean_interp_' HEMI]).header = [];
                obj.Trkland.Trks.([TOI '_trimmedclean_interp_' HEMI]).sstr = [];
                obj.Trkland.Trks.([TOI '_clineFAHighFA_' HEMI]).sstr = [];
                obj.Trkland.Trks.([TOI '_clineFAHighFA_' HEMI]).header = [] ;
                obj.Trkland.Trks.([TOI '_clineHDorff_' HEMI]).sstr = [] ;
                obj.Trkland.Trks.([TOI '_clineHDorff_' HEMI]).header = [] ;
                obj.Trkland.(TOI).data.([HEMI '_done']) = 0;
            end
            
            if obj.Trkland.(TOI).data.([HEMI '_done']) ~= 0
                fprintf(['INFORMATION FOR obj.Trkland_' TOI '() - ' HEMI ' - IS COMPLETE. NOTHING TO DO.\n'])
            end
        end
        
        function obj = applyTRKLAND_nonFA(obj,diffM, TOI,HEMI)
            if ( strcmp(diffM,'MD') || strcmp(diffM,'RD') ) || strcmp(diffM,'AxD')
                TRK_NAME = ['nonFA_clineLow' diffM '_' HEMI ];
                lowFLAG=true; %Flagging for the naming convention...
            else
                TRK_NAME = ['nonFA_clineHigh' diffM '_' HEMI ];
                lowFLAG=false;
            end
            
            %INIT output trk.gz file:
            obj.Trkland.(TOI).out.(TRK_NAME) = [ obj.Trkland.root  'trkk_' TOI '_' TRK_NAME '.trk.gz'];
                    
            if exist(obj.Trkland.(TOI).QCfile_bil,'file') == 0
                if exist(obj.Trkland.(TOI).(['QCfile_' HEMI]),'file') == 0 
                    %START SELECTING HIGH-NONDIFF PROCESS:~~~~~~~~~~~~~~~~~~~
                    if exist(obj.Trkland.(TOI).out.(TRK_NAME),'file') == 0 && ~isempty(obj.Trkland.Trks.([ TOI '_trimmedclean_interp_' HEMI]).header) 
                        obj.addDTI([ TOI '_trimmedclean_interp_' HEMI]);
                        %Method to use (Either low_sc or high_sc, depending on the metric of interest):
                        if lowFLAG == true
                            obj.Trkland.Trks.([ TOI '_' TRK_NAME]) = rotrk_centerline(obj.Trkland.Trks.([ TOI '_trimmedclean_interp_' HEMI]), 'low_sc',diffM);
                            rotrk_write(obj.Trkland.Trks.([ TOI '_' TRK_NAME]).header, ...
                                obj.Trkland.Trks.([ TOI '_' TRK_NAME]).sstr,[ obj.Trkland.root  'trkk_' TOI '_' TRK_NAME '.trk.gz']);
                        else
                            obj.Trkland.Trks.([ TOI '_' TRK_NAME]) = rotrk_centerline(obj.Trkland.Trks.([ TOI '_trimmedclean_interp_' HEMI]), 'high_sc',diffM);
                            rotrk_write(obj.Trkland.Trks.([ TOI '_' TRK_NAME]).header, ...
                                obj.Trkland.Trks.([ TOI '_' TRK_NAME]).sstr,[ obj.Trkland.root  'trkk_' TOI '_' TRK_NAME '.trk.gz']);
                        end
                        %Adding data:
                        match_diffM=find(ismember(obj.Trkland.Trks.([ TOI '_' TRK_NAME]).header.scalar_IDs(:),diffM));
                        obj.Trkland.(TOI).data.(TRK_NAME) =  mean(obj.Trkland.Trks.([ TOI '_' TRK_NAME]).unique_voxels(:,3+match_diffM(1)));
                    end
                else
                    obj.Trkland.(TOI).data.(TRK_NAME) = [] ; 
                end
            else
                obj.Trkland.(TOI).data.(TRK_NAME) = [] ; 
            end
            
            %Bring values to object in XX.Trks.XXX if output exists:
           % if exist(obj.Trkland.(TOI).out.(TRK_NAME),'file') ~= 0
                obj.repopulateTRKLAND([TOI '_' TRK_NAME],TOI,HEMI,true);
            %end
            %~~~~~~~~~~~~~~~~~~~END OF SELECTING HIGHFA PROCESS
        end
        
        function obj = getdataTRKLAND(obj,TOI,HEMI,opt_outfname)
            %Check if optional 'opt_outfname' is given to avoid
            %obj.Trkland.(TOI).data.([HEMI '_done'])  'if' condition. 
            if nargin <4
                flag_opt_outfname = false;
            else                
                flag_opt_outfname = true;
            end
            if  obj.Trkland.(TOI).data.([HEMI '_done']) ~= 1 || flag_opt_outfname == true
                %Get data for all interesting values:
                if  flag_opt_outfname == true
                    data_trks= {opt_outfname};
                else
                    data_trks= fields(obj.Trkland.(TOI).out);
                end
                for ii=1:numel(data_trks)
                    %split data to see whether we want to change the lh
                    %or rh data...[ NOTE: we could've use contains() but conflict
                    %occurs between local function and updated function in
                    %Matlab2017a ]
                    splits=strsplit(data_trks{ii},'_');
                    %SPLITS will help us check only those TRKS that have
                    %the same HEMI variable (eg. 'lh' or 'rh')
                    for jj=1:numel(splits)
                        if strcmp(splits(jj),HEMI)
                            if ~strcmp(data_trks{ii},'QC') %NOT SURE WHY THIS QC variable exists...easy fix for now.
                                if exist(obj.Trkland.(TOI).out.(data_trks{ii}),'file') ~= 0
                                    %if isfield(obj.Trkland.Trks.([])
                                    %Reading and adding scalars:
                                    temp_read = rotrk_read(obj.Trkland.(TOI).out.(data_trks{ii}),'no_warning',obj.Params.Dtifit.out.FA{end});
                                    temp_read = rotrk_add_sc(temp_read ,obj.Params.Dtifit.out.FA{end} , 'FA');
                                    temp_read = rotrk_add_sc(temp_read ,strrep(obj.Params.Dtifit.out.FA{end},'FA','RD') , 'RD');
                                    temp_read = rotrk_add_sc(temp_read ,strrep(obj.Params.Dtifit.out.FA{end},'FA','AxD') , 'AxD');
                                    temp_read = rotrk_add_sc(temp_read ,strrep(obj.Params.Dtifit.out.FA{end},'FA','MD') , 'MD');
                                    
                                    
                                    fprintf(['\ntrkland_' TOI '(): Getting ' TOI '_data for ' data_trks{ii} '...'] ) ;
                                    obj.Trkland.(TOI).data.([ (data_trks{ii}) '_vol' ])  = temp_read.num_uvox;
                                    obj.Trkland.(TOI).data.([ (data_trks{ii}) '_FA' ]) = mean(temp_read.unique_voxels(:,4));
                                    obj.Trkland.(TOI).data.([ (data_trks{ii}) '_RD' ]) = mean(temp_read.unique_voxels(:,5));
                                    obj.Trkland.(TOI).data.([ (data_trks{ii}) '_AxD' ]) = mean(temp_read.unique_voxels(:,6));
                                    obj.Trkland.(TOI).data.([ (data_trks{ii}) '_MD' ] ) = mean(temp_read.unique_voxels(:,7));
                                    fprintf('done\n');
                                else
                                    fprintf(['\ntrkland_' TOI '():  No filename found for ' data_trks{ii} '...'] ) ;
                                    obj.Trkland.(TOI).data.([ (data_trks{ii}) '_vol' ]) = [];
                                    obj.Trkland.(TOI).data.([ (data_trks{ii}) '_FA' ]) = [];
                                    obj.Trkland.(TOI).data.([ (data_trks{ii}) '_RD' ]) = [];
                                    obj.Trkland.(TOI).data.([ (data_trks{ii}) '_AxD' ]) = [];
                                    obj.Trkland.(TOI).data.([ (data_trks{ii}) '_MD' ] ) = [];
                                    
                                end
                            end
                        end
                    end
                end
                clear data_trks
                obj.Trkland.(TOI).data.([HEMI '_done']) = 1;
                obj.Trkland.(TOI).wasRun = true ; 
            end
        end
        function obj = clearTRKLANDdata(obj,TOI,HEMI)
            %Create a list of all the fields stored in data:
            all_trks= fields(obj.Trkland.(TOI).data);
            %Check what HEMI is passed:
            if strcmp(HEMI,'rh') || strcmp(HEMI,'lh')
                %Select those who are in the HEMI of interest:
                AA=strfind(all_trks,HEMI);
                %Remove nans that done correspond:
                data_trks=all_trks(cellfun(@(AA) any(~isnan(AA)),AA));
                
            else %Assuming bilateral
                data_trks=all_trks;
            end
            
            %FOR LOOP TO CLEAR THE CORRESPONDING DATA VALUE:
            for ii=1:numel(data_trks)
                if strcmp(data_trks{ii},'lh_done') || strcmp(data_trks{ii},'rh_done')
                    % Change the value of the corresponding data lh/rh_done
                    % variable (this is a flag to denote data was uploaded)
                    obj.Trkland.(TOI).data.(data_trks{ii}) = 1;
                else
                    obj.Trkland.(TOI).data.(data_trks{ii}) = []; 
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %REMOVE obj.Trkland.Trks INFORMATION NOW:
            if ~isempty(obj.Trkland.Trks)
                allfields=fields(obj.Trkland.Trks);
                for ii=1:numel(allfields)
                    SPLIT=strsplit(allfields{ii},'_');
                    %Check what TOI:
                    if strcmp(SPLIT(1),TOI)
                        %Check what hemisphere:
                        if strcmp(HEMI,'bil')
                            obj.Trkland.Trks=rmfield(obj.Trkland.Trks,allfields{ii});
                        elseif strcmp(HEMI,allfields{ii}(end-1:end))
                            obj.Trkland.Trks=rmfield(obj.Trkland.Trks,allfields{ii});
                        end
                    end
                end
            end
        end
        function obj = repopulateTRKLAND(obj,TRK_NAME,TOI,HEMI,nonFA_flag)
            if nargin < 5
                nonFA_flag=false; %denoting not coming from  a nonFA accesor...
            end
            
            %Two conditions: 1) if the file trk is not a field:
            if ~isfield(obj.Trkland.Trks,TRK_NAME)
                fprintf(['\nPopulating obj.Trkland.Trks.' TRK_NAME ' ...']);
                %Check if output exists:
                if exist(obj.Trkland.(TOI).out.(strrep(TRK_NAME,[ TOI '_'],'')),'file')
                    obj.Trkland.Trks.(TRK_NAME) = rotrk_read(obj.Trkland.(TOI).out.(strrep(TRK_NAME,[ TOI '_'],'')),obj.sessionname,obj.Params.Dtifit.out.FA{end},TRK_NAME);
                    obj.addDTI(TRK_NAME);
                else
                    obj.Trkland.Trks.(TRK_NAME).header = [];
                    obj.Trkland.Trks.(TRK_NAME).sstr = [];
                end
                
                if nonFA_flag == false
                    obj.Trkland.(TOI).data.([HEMI '_done']) = 0;
                end
                fprintf('done\n');
            end
            
            %Two conditions: 2) if the file trk.headaer is empty:
            if isempty(obj.Trkland.Trks.(TRK_NAME).header) && exist(obj.Trkland.(TOI).out.(strrep(TRK_NAME,[ TOI '_'],'')),'file') ~=0
                fprintf(['\nPopulating obj.Trkland.Trks.' TRK_NAME ' ...']);
                obj.Trkland.Trks.(TRK_NAME) = rotrk_read(obj.Trkland.(TOI).out.(strrep(TRK_NAME,[ TOI '_'],'')),obj.sessionname,obj.Params.Dtifit.out.FA{end},TRK_NAME);
                obj.addDTI(TRK_NAME);
                if nonFA_flag == false
                    obj.Trkland.(TOI).data.([HEMI '_done']) = 0;
                end
                fprintf('done\n');
            end
        end
        
        %EXEC BASH SCRIPTS METHOD:
        function obj = RunBash(obj,exec_cmd, exit_status)
            if  ~(obj.redo_history) %NOTHING WILL BE EXECUTED IF obj.redo_history exists --> MAKE SURE YOU REMOVE THIS BEFORE REPLACING HISTORY!
                %     display(exec_cmd)
                %Code values:
                %   44  --> Show output
                %   144 --> Show output and exist_status is 1
                if nargin < 3 %This will allow us to pass other exit status, such as 1 for DSISTUDIO in GQI
                    exit_status = 0 ;
                end
                
                if exit_status == 44 || exit_status == 144 % 44 codes for non-comment when running system:
                    [ sys_success , sys_error ] = system(exec_cmd,'-echo') ;
                    if exit_status == 44
                        exit_status = 0; %return exit_status to zero.
                    elseif exit_status== 255
                        error(['obj.RunBash...when this command is run: \n ' exec_cmd  ])
                    else
                        exit_status = 1; %return exit_status to one.
                    end
                else
                    [ sys_success , sys_error ] = system(exec_cmd) ;
                end
                
                if sys_success==exit_status; disp('');
                else
                    fprintf('\n\n===================================');
                    fprintf('===================================\n\n');
                    fprintf(['\n \t\tError in exec_cmd: \n ' exec_cmd '\n\n\n' ]);
                    fprintf(['\n \t\tError output by system(exec_cmd) is:\n ' sys_error '\n'])
                    fprintf('\n\n===================================');
                    fprintf('===================================\n\n');
                    error('Stopping now....');
                end
            end
        end
        
        function [oneliner ] = addtoSHELLPATH(obj,file_path)
            [ ~ , temp_shell ] = system('echo $SHELL');
            [sys_ok, temp_PATH ] = system('echo $PATH');
            if sys_ok ~= 0
                error('Error when trying to look for the SHELL path! ');
            end
            %Making sure the fileseparator '/'(unix), '\' (windows) is added at the end
            file_path=[file_path filesep ] ; 
            file_path=regexprep(file_path,[filesep filesep ], filesep);
            %Remove '/' and '\' at the end:
            if strcmp(file_path(end),filesep)
                file_path=file_path(1:end-1);
            end
            %Added path here:
            added_PATH = strtrim(regexprep(temp_PATH,file_path,file_path));
            [~ , temp_shell_bname ] = fileparts(temp_shell);
            if strcmp(strtrim(temp_shell),'bash')
                oneliner = ['export PATH = ' added_PATH ' ; ' ];
            else
                oneliner = ['setenv PATH ' added_PATH ' ; ' ];
            end
        end
        
        function outpath = getPath(obj,a,movefiles)
            if isempty(movefiles)
                outpath = [a filesep movefiles filesep];
            else
                if movefiles(1)==filesep || movefiles(1)=='~'
                    outpath = [movefiles filesep];
                else
                    outpath = [a filesep movefiles filesep];
                end
            end
            outpath = regexprep(outpath,[filesep filesep],filesep);
            
            %%%% Do I want to do the below?
            if ~exist(outpath,'dir');
                mkdir(outpath);
            end
            hm = pwd;
            cd(outpath)
            
            outpath = [pwd filesep];
            cd(hm);
        end
        
        
        %COMMAND HISTORY METHODS (Adapted from fmri_Session.m):
        function [ind, assume] = CheckHist(obj,step,wasRun)
            assume = false;
            ind = [];
            
            for ii = 1:numel(obj.history)
                tmp = obj.history{ii};
                if isfield(tmp,'assume')
                    ind(ii,1) = isequaln(rmfield(tmp,'assume'),step);
                else
                    ind(ii,1) = isequaln(tmp,step);
                end
            end
            ind = find(ind==1);
            
            if isempty(ind);
                disp('reading history....just Did');
                ind = numel(obj.history)+1;
                if ~wasRun
                    assume=true;
                end
            else
                disp('Already done');
            end
        end
        function obj = UpdateHist_v2(obj,Params,process_to_update,checkFile,wasRun,exec_cmd)
           
           %Make sure we do not overwrite (in history) something that has been already recorded:
           in_history=false;
           sth_toupdate=true;
           for gg=1:numel(obj.history)
               if strcmp(obj.history{gg}.lastRun(1:size(process_to_update,2)),process_to_update)
                   in_history=true;
                   in_history_idx=gg;
               end
           end
            %Making sure the file exists:
            if exist(checkFile,'file') == 0
                warning([ checkFile ' doesnt exist. Nothing updated to history.' ] );
                sth_toupdate=false;
                pause(2);
            else
                
                %                 if wasRun
                %                     info = regexprep(sprintf('%-35s%s', [process_to_update ':'], obj.UserTime),'\n','');
                %                 else
                %%% For Linux
                %Gets you the username:
                [a theUser] = system(['ls -l --full-time ' checkFile ' |  awk  ''{print $3}''']);
                %Gets you the time:
                [a theTime] = system(['ls -l --full-time ' checkFile ' |  awk  ''{print $6" "$7}''']);
                theTime = datestr(theTime(1:end-11));
                if in_history==true
                    info = regexprep(sprintf('%-35s%s', [process_to_update ':'], ['(re-ran) by ' theUser ' on ' theTime]),'\n','');
                else
                    info = regexprep(sprintf('%-35s%s', [process_to_update ':'], ['last run by ' theUser ' on ' theTime]),'\n','');
                end
            end
            
            
            %Is there any relevant exec_cmd that need to be update?
            if isempty(exec_cmd)
                sth_toupdate=false;
            end
            if size(exec_cmd,1) == 1 
                sth_toupdate=false;
            end
            
            Params.assume=true; %At this point no real meaninful use for this variable. 
            if sth_toupdate==true
                Params.lastRun = info;
                Params.exec_cmd=exec_cmd;
                if in_history == true
                    temp_iter=obj.history{in_history_idx};
                    if ~isfield(Params,'iternum')
                        Params.iternum=2; %denoting second time this script will be modified
                    else
                        Params.iternum=Params.iternum+1;
                    end
                    Params.previousParams = temp_iter;
                    obj.history{in_history_idx,1} = Params;                    
                else
                    %[ind assume] = obj.CheckHist(Params,wasRun);
                    ind=numel(obj.history)+1;
                    display(['Recording in history: ' info ]);
                    obj.history{ind,1} = Params;
                end
            end
        end
    
        
        %SPM COREG METHODS:
        function obj = proc_reslice(obj,mov,ref,list_applyxforms, prefix)
            %function proc_reslice(mov,ref,list_applyxforms, prefix)
            
            %Check if files exists!
            if exist(ref,'file') == 0
                error([ ref ' does not exist']);
            end
            
            if exist(mov,'file') == 0
                error([ mov ' does not exist']);
            end
            
            if nargin > 3
                for ijk=1:numel(list_applyxforms)
                    if exist(list_applyxforms{ijk},'file') == 0
                        error(['proc_QuickCoReg: ' list_applyxforms{ijk} ' not found!' ]);
                    end
                end
            end
            
            %Check if gzipped...
            [ ~, ~, ext_mov ] = fileparts(mov);
            if strcmp(ext_mov,'.gz')
                system(['gunzip ' mov ] );
                mov = strrep(mov,'.gz','');
                VF = spm_vol(mov);
            elseif strcmp(ext_mov,'.nii')
                VF = spm_vol(mov);
            else
                error([ 'mov is not .nii or .nii.gz -->' mov ]);
            end
            
            
            [ ~, ~, ext_ref ] = fileparts(ref);
            if strcmp(ext_ref,'.gz')
                system(['gunzip ' ref ] );
                ref = strrep(ref,'.gz','');
                VG = spm_vol(ref);
            elseif strcmp(ext_ref,'.nii');
                VG = spm_vol(ref);
            else
                error([ 'ref is not .nii or .nii.gz -->' ref ]);
            end
            
            %%% reslice the Mean CPS image to T1 space
            clear P;
            P{1}  = ref;
            P{2}  = mov;
            clear flags;
            flags.mask   = 0;
            flags.mean   = 0;
            flags.interp = 0; % 1 for default (B-spline). 0 for neares neighbout
            flags.which  = 1;
            flags.wrap   = [0 0 0];
            if nargin >4
                flags.prefix=prefix;
            else
                display('Using default prefix ''r_'' ');
                pause(2);
                flags.prefix = 'r_';
            end
            
            spm_reslice(P,flags);
            
            %%GZIP check
            if strcmp(ext_ref,'.gz')
                system(['gzip ' ref ] );
            end
            
            if strcmp(ext_mov,'.gz')
                system(['gzip ' mov ]);
            end
            
            if nargin>3 && ~isempty(list_applyxforms)
                for ii=1:numel(list_applyxforms)
                    %Now reslicing...
                    P{2} = list_applyxforms{ii};
                    spm_reslice(P,flags);
                end
            end
        end
        function obj = proc_remove_spm_nans(obj,f_name)
            %Replaces NaNs with 0s so images can be viewed in other non-spm
            %related viewers (e.g. fslview)
            
            %No need to check for *.nii.gz as this method purpose is to
            %remove spm_nans hence the f_names passed should be *.nii
            %always (SPM output/input does not support *.nii.gz)
            display(['Removing NaNs for: ' f_name ])
            V = spm_vol(f_name);
            Y = spm_read_vols(V);
            Y(isnan(Y))  = 0 ;
            spm_write_vol(V,Y);
            fprintf(' ...done\n');
        end
        function obj = proc_coreg2dwib0(obj,mov,ref,outdir)
            fprintf('\n%s\n', 'PERFORMING COREGISTRATION');
            wasRun = false;
            
            if nargin<4
                error('Invalid number of arguments. Please enter the source and target images');
            end
            
            if iscell(mov)
                [a b c] = fileparts(mov{end});
            else
                [a b c] = fileparts(mov);
            end
            outpath2 = obj.getPath(outdir,'./');
            disp('USING SPM:');
            if exist([outpath2 'CoReg.mat'],'file')==0
                wasRun=true;
                %READING VG:
                [ref_dir,ref_bname,ref_ext] = fileparts(ref);
                if strcmp(ref_ext,'.gz') %assume gzip
                    system(['gunzip ' ref ] );
                    VG = spm_vol([ref_dir filesep ref_bname]);
                else
                    VG = spm_vol(ref);
                end
                %READING VF:
                [mov_dir,mov_bname,mov_ext] = fileparts(mov);
                if strcmp(mov_ext,'.gz') %assume gzip
                    system(['gunzip ' mov ] );
                    VF = spm_vol([mov_dir filesep mov_bname]);
                else
                    VF = spm_vol(mov);
                end
                
                %flags (copy from obj.Params.Coreg.in.spm):
                flags.sep = [4  2 ] ;
                params = [ 0 0 0 0 0 0 ];
                cost_func = 'nmi';
                tol = [0.0200 0.0200 0.0200 1.0000e-03 1.0000e-03 1.0000e-03 0.0100 0.0100 0.0100 1.0000e-03 1.0000e-03 1.0000e-03] ;
                fwhm = [ 7 7 ] ;
                graphics = 1;
                
                x = spm_coreg(VG,VF,flags);
                M  = spm_matrix(x);
                save([outpath2 'CoReg.mat'],'x','M');
                
                %TAKING CARE OF GZIP:
                %VG (mov):
                if strcmp(mov_ext,'.gz') %gzip now
                    system(['gzip ' mov_dir filesep mov_bname]);
                end
                %VF (mov):
                if strcmp(ref_ext,'.gz') %gzip now
                    system(['gzip ' ref_dir filesep ref_bname ] );
                end
                
            else
                load([outpath2 'CoReg.mat']);
            end
            disp('CoReg.mat has been saved.');
        end
        function obj = proc_apply_coreg2dwib0(obj,fn,reslice,dwib0)
            fprintf('\n%s\n', '\t\tPERFORMING COREGISTRATION TO B0...');
            wasRun = false;
            if ischar(fn)
                fn = cellstr(fn);
            end
            
            if nargin < 3
                reslice = 0;
            end
            
            [a b c] = fileparts(fn{1});
            if isempty(a); a = pwd; end;
            outpath2 = obj.getPath(a,'./');
            
            disp('    USING SPM:');
            load([outpath2 'CoReg.mat']);
            
            for ii = 1:numel(fn)
                [a b c] = fileparts(fn{ii});
                if isempty(a); a = pwd; end
                nfn{ii,1} = [outpath2 'coreg2dwi_' b c];
                if exist(nfn{ii},'file')==0
                    wasRun=true;
                    copyfile(fn{ii},nfn{ii});
                    MM = spm_get_space(nfn{ii});
                    spm_get_space(nfn{ii}, M\MM);
                end
                if reslice == 1
                    [res_dirname, res_bname , res_ext ] = fileparts(fn{ii});
                    h1.fname = [res_dirname filesep 'resliced_coreg2dwi_' res_bname res_ext];
                    if exist(h1.fname,'file') == 0
                        %h1 = spm_vol(obj.Params.tracxBYmask.T1coregDWI.in_b0);
                        [dwi_dir,dwib0_bname,dwib0_ext] = fileparts(dwib0);
                        if strcmp(dwib0_ext,'.gz') %assume gzip
                            system(['gunzip ' dwib0 ] );
                            h1 = spm_vol([dwi_dir filesep dwib0_bname]);
                        else
                            h1 = spm_vol(dwib0);
                        end
                        if strcmp(dwib0_ext,'.gz') %gzip now
                            system(['gzip ' dwi_dir filesep dwib0_bname ] );
                        end
                        h2 = spm_vol(nfn{ii});
                        m = dwi_resizeVol2(h2,h1,[3 0 ]);
                        %Adding resclied to the naming convention
                        [res_dirname, res_bname , res_ext ] = fileparts(fn{ii});
                        h1.fname = [res_dirname filesep 'resliced_coreg2dwi_' res_bname res_ext];
                        h1.dt = h2.dt;
                        spm_write_vol(h1,m);
                    end
                end
                disp('Coregistration has been applied to the run:');
            end
            fprintf('\n');
        end
        function obj = proc_apply_resversenorm(obj,fn,regfile,targ,outdir,prefix)
            fprintf('\n%s\n', 'APPLYING SPM STYLE REVERSE NORMALIZATION:');
            wasRun = false;
            if nargin <6
                prefix = '' ;
            end
            if nargin <5
                error('Incorrect number of arguments. Please enter at least 5');
            end
            
            
            if ischar(fn)
                fn = cellstr(fn);
            end
            
            outpath = outdir;
            if exist(outpath,'dir')==0
                mkdir(outpath);
            end
            
            nfn = [];
            for ii = 1:numel(fn);
                [a1 b1 c1] = fileparts(fn{ii});
                ff = regexprep([outpath prefix b1 c1],[filesep filesep],filesep);
                nfn{end+1,1} = ff;
            end
            
            check = 0;
            for ii = 1:numel(nfn)
                if exist(nfn{ii},'file')>0
                    check = check+1;
                end
            end
            
            if check ~= (numel(fn))
                wasRun = true;
                [targ_dir, targ_bname,  targ_ext ] = fileparts(targ);
                
                if strcmp(targ_ext,'.gz')
                    system(['gunzip ' targ ]);
                    targ=[targ_dir filesep targ_bname ] ;
                end
                h = spm_vol(targ);
                if strcmp(targ_ext,'.gz')
                    system(['gzip ' targ ]);
                end
                x = spm_imatrix(h.mat);
                
                %defs = obj.Params.ApplyNormNew.in.pars;
                %defs = obj.Params.ApplyReverseNormNew.in.pars;
                defs.comp{1}.def = {regfile};
                defs.out{1}.pull.fnames  = fn(:)';
                
                defs.out{1}.pull.savedir.savesrc=1;
                defs.out{1}.pull.interp=0;
                defs.out{1}.pull.mask=1;
                defs.out{1}.pull.fwhm=[0 0 0];
                defs.comp{2}.idbbvox.vox = abs(x(7:9));
                defs.comp{2}.idbbvox.bb = world_bb_v2(h);
                
                spm_deformations(defs);
                
                nfn = [];
                for ii = 1:numel(fn);
                    [a1 b1 c1] = fileparts(fn{ii});
                    ff = [outpath prefix b1 c1];
                    movefile([a1 filesep 'w' b1 c1], ff);
                    obj.proc_remove_spm_nans(ff);
                    nfn{end+1,1} = ff;
                end
            end
            disp('Applying Normalization is complete');
            fprintf('\n');
        end
        function obj = obsolete_replaced_proc_t1_spm(obj,coreg2dwi_T1,outdir)
            fprintf('\n\n%s\n', 'PROCESS T1 WITH SPM:');
            wasRun = false;
            
            if nargin <3
                error('Not enough arguments. Please check. Exiting...');
            end
            
            if exist(coreg2dwi_T1,'file') == 0
                error(['No ' '' coreg2dwi_T1 '' 'exists. Exiting...'])
            end
            
            root = outdir;
            root = regexprep(root,'//','/');
            
            
            [a b c] = fileparts(coreg2dwi_T1);
            
            %Copying coreg2dwi_T1 to ourdir if it's not already there:
            %Check that '//' doesnt occur:
            if strcmp(outdir(end),filesep)
                outdir = outdir(1:end-1);
            end
            %Check if outdir and dir of T1 are the same:
            if ~strcmp(outdir,a)
                if exist([outdir filesep b c], 'file')
                    %Check if existing file and coreg2dwi_T1 are equal, if
                    %not send a error
                    [sys_1, sys_2] = system(['diff ' [outdir filesep b c] ' ' coreg2dwi_T1   ]);
                    if ~isempty(sys_2)
                        error(sys_2);
                    end
                else
                    display(['Copying ' coreg2dwi_T1 ' to ' a filesep '...']);
                    system(['cp ' coreg2dwi_T1 ' ' outdir filesep]) ;
                end
                coreg2dwi_T1 =  [ outdir filesep b c ];
            end
            
            %%%
            if exist([root filesep 'Affine.mat'],'file')==0
                %%% could put something in here to redo subseuqent steps if
                %%% this step is not complete.
                wasRun=true;
                
                %Flag parameters copied from fMRI_Session.m object:
                %---> in = obj.Params.spmT1_Proc.in.pars; (from
                %fMRI_Session.m)
                in.samp =2; in.fwhm1=16; in.fwhm2=0; in.regtype='mni';
                %
                in.P = coreg2dwi_T1;
                %---> in.tpm = spm_load_priors8(obj.Params.spmT1_Proc.in.tpm);
                in.tpm = spm_load_priors8([ obj.dependencies_dir filesep 'MNI_masks' filesep 'TPM.nii' ]);
                in.M=[];
                [Affine,h] = spm_maff8(in.P,in.samp,in.fwhm1,in.tpm,in.M,in.regtype);
                in.M = Affine;
                [Affine,h] = spm_maff8(in.P,in.samp,in.fwhm2,in.tpm,in.M,in.regtype);
                save([outdir filesep 'Affine.mat'],'Affine');
            else
                load([outdir filesep 'Affine.mat']);
            end
            fprintf('%s\n', 'Affine Registration is complete:');
            
            
            if exist([outdir filesep 'Norm_Seg8.mat'],'file')==0
                wasRun=true;
                %Again, copy params from fmri_Session.m
                %--> NormPars = obj.Params.spmT1_Proc.in.NormPars;
                NormPars.fwhm = 0;
                NormPars.biasreg=1.0000e-04;
                NormPars.biasfwhm= 60;
                NormPars.reg= [0 1.0000e-03 0.5000 0.0500 0.2000] ;
                NormPars.samp = 2;
                NormPars.lkp =  [];
                NormPars.image = spm_vol(coreg2dwi_T1);
                NormPars.Affine = Affine;
                %--> NormPars.tpm = spm_load_priors8(obj.Params.spmT1_Proc.in.tpm);
                NormPars.tpm = spm_load_priors8([ obj.dependencies_dir filesep 'MNI_masks' filesep 'TPM.nii' ]);
                results = spm_preproc8(NormPars);
                save([outdir filesep 'Norm_Seg8.mat'],'results');
            else
                load([outdir filesep 'Norm_Seg8.mat']);
            end
            fprintf('%s\n', 'Normalization computation is complete:');
            
            c = regexprep(c,',1','');
            
            if exist([root filesep 'y_' b c],'file')==0
                %%% I forget what some of these static options do.  Will leave
                %%% them fixed as is for now.
                wasRun=true;
                %replaced from fMRI_Session.m parameters below
                %--> [cls,M1] = spm_preproc_write8(results,obj.Params.spmT1_Proc.in.rflags.writeopts,[1 1],[1 1],0,1,obj.Params.spmT1_Proc.in.rflags.bb,obj.Params.spmT1_Proc.in.rflags.vox);
                bb= [ -78  -112   -70
                    78    76    90 ] ;
                
                [cls,M1] = spm_preproc_write8(results,ones(6,4),[1 1],[1 1],0,1,bb,1);
            end
            fprintf('%s\n', 'Normalization files have been written out:');
            
            if exist([root filesep 'w' b c],'file')==0
                wasRun=true;
                %Replaced params with fMRI_Session.m standars:
                %--> defs = obj.Params.spmT1_Proc.in.defs;
                defs.out{1}.pull.interp=5;
                defs.out{1}.pull.mask=1;
                defs.out{1}.pull.fwhm=[0 0 0];
                defs.out{1}.pull.savedir.savesrc = 1 ;
                defs.comp{2}.idbbvox.vox= [1 1 1];
                defs.comp{2}.idbbvox.bb= [ -78  -112   -70
                    78    76    90 ] ;
                defs.comp{1}.def = {[outdir filesep 'y_' b c]};
                
                defs.out{1}.pull.fnames = {coreg2dwi_T1};
                
                
                spm_deformations(defs);
            end
            %             obj.Params.spmT1_Proc.out.normT1 = [a filesep 'w' b c];
            fprintf('%s\n', 'Normalization has been applied to the T1:');
            %
            %             obj.Params.spmT1_Proc.out.estTPM{1,1} = [a filesep 'c1' b c];
            %             obj.Params.spmT1_Proc.out.estTPM{2,1} = [a filesep 'c2' b c];
            %             obj.Params.spmT1_Proc.out.estTPM{3,1} = [a filesep 'c3' b c];
            %             obj.Params.spmT1_Proc.out.estTPM{4,1} = [a filesep 'c4' b c];
            %             obj.Params.spmT1_Proc.out.estTPM{5,1} = [a filesep 'c5' b c];
            %             obj.Params.spmT1_Proc.out.estTPM{6,1} = [a filesep 'c6' b c];
            %
            %             obj.Params.spmT1_Proc.out.regfile = [a filesep 'y_' b c];
            %             obj.Params.spmT1_Proc.out.iregfile = [a filesep 'iy_' b c];
            
            fprintf('\n');
        end %replaced with a public method
        
        %MISC FUNCTIONALITIES
        function out = UserTime(obj)
            tmp = pwd;
            cd ~
            user = pwd;
            cd(tmp);
            
            ind = find(user == filesep);
            if ind(end)==numel(user);
                user = user(ind(end-1)+1:ind(end)-1);
            else
                user = user(ind(end)+1:end);
            end
            out = ['last run by ' user ' on ' datestr(clock)];
        end
        function obj = make_root(obj)
            if exist(obj.root,'dir')==0
                try
                    system(['mkdir -p ' obj.root ]);
                catch
                    disp([ 'Trying to create /DWIs/ in:' obj.root ...
                        ' Maybe some permission issues?'])
                end
            end
        end
        function obj = RefreshFields(obj,whatParam,direction)
            if nargin <3
                direction = 'bil' ; %assuming bilateral directionality if not 3rd argument given
            end
            switch whatParam
                case 'hippocing'
                    fields_out = fields(obj.Trkland.hippocing.out);
                    fields_data = fields(obj.Trkland.hippocing.data);
                    for ii=1:numel(fields_out)
                        if strcmp(direction,'bil')
                            obj.Trkland.hippocing.out.(fields_out{ii}) = '' ;
                        else
                            if ~isempty(strfind(fields_out{ii},direction))
                                obj.Trkland.hippocing.out.(fields_out{ii}) = '' ;
                            end
                        end
                    end
                    for ii=1:numel(fields_data)
                        if strcmp(direction,'bil')
                            obj.Trkland.hippocing.data.(fields_data{ii}) = [];
                        else
                            if ~isempty(strfind(fields_data{ii},direction))
                                obj.Trkland.hippocing.data(fields_data{ii}) = [] ;
                            end
                        end
                    end
                case 'atr'
                    fields_out = fields(obj.Trkland.atr.out);
                    fields_data = fields(obj.Trkland.atr.data);
                    for ii=1:numel(fields_out)
                        if strcmp(direction,'bil')
                            obj.Trkland.atr.out.(fields_out{ii}) = '' ;
                        else
                            if ~isempty(strfind(fields_out{ii},direction))
                                obj.Trkland.atr.out.(fields_out{ii}) = '' ;
                            end
                        end
                    end
                    for ii=1:numel(fields_data)
                        if strcmp(direction,'bil')
                            obj.Trkland.atr.data.(fields_data{ii}) = [];
                        else
                            if ~isempty(strfind(fields_data{ii},direction))
                                obj.Trkland.atr.data(fields_data{ii}) = [] ;
                            end
                        end
                    end
                case 'fx'
                    fields_out = fields(obj.Trkland.fx.out);
                    fields_data = fields(obj.Trkland.fx.data);
                    for ii=1:numel(fields_out)
                        if strcmp(direction,'bil')
                            obj.Trkland.fx.out.(fields_out{ii}) = '' ;
                        else
                            if ~isempty(strfind(fields_out{ii},direction))
                                obj.Trkland.fx.out.(fields_out{ii}) = '' ;
                            end
                        end
                    end
                    for ii=1:numel(fields_data)
                        if strcmp(direction,'bil')
                            obj.Trkland.fx.data.(fields_data{ii}) = [];
                        else
                            if ~isempty(strfind(fields_data{ii},direction))
                                obj.Trkland.fx.data.(fields_data{ii}) = [] ;
                            end
                        end
                    end
                case 'cingulum'
                    fields_out = fields(obj.Trkland.cingulum.out);
                    fields_data = fields(obj.Trkland.cingulum.data);
                    for ii=1:numel(fields_out)
                        if strcmp(direction,'bil')
                            obj.Trkland.cingulum.out.(fields_out{ii}) = '' ;
                        else
                            if ~isempty(strfind(fields_out{ii},direction))
                                obj.Trkland.cingulum.out.(fields_out{ii}) = '' ;
                            end
                        end
                    end
                    for ii=1:numel(fields_data)
                        if strcmp(direction,'bil')
                            obj.Trkland.cingulum.data.(fields_data{ii}) = [];
                        else
                            if ~isempty(strfind(fields_data{ii},direction))
                                obj.Trkland.cingulum.data.(fields_data{ii}) = [] ;
                            end
                        end
                    end
                otherwise
                    error(['In RefreshFields(). I do not understand the argument: --> ' whatParam ' <-- please check']);
            end
            obj.resave;
        end
        
        %!!
        %DEPRECATED:
        function obj = deprecated_UploadData_Trkland(obj)
            id = obj.sessionname;
            if isempty(id);
                disp('No Session_ID.  Cannot upload data');
                return
            end
            
            if isnumeric(id)
                id = num2str(id);
            end
            
            %%Select current SessionID
            dctl_cmd = [ 'SELECT MRI_Session_ID FROM Sessions.MRI  WHERE ' ' MRI_Session_Name = ''' id '''' ];
            cur_DC_ID = DataCentral(dctl_cmd);
            
            %%Creating all the files that will be uploaded:
            FX_fields = fields(obj.Trkland.fx.data);
            CING_fields = fields(obj.Trkland.cingulum.data);
            HIPPOCING_fields=fields(obj.Trkland.hippocing.data);
            
            %STARTING THE UPLOADING SEQUENCE:
            
            fprintf('\n Uploading: ');
            
            %FOR FX:
            for ii=1:numel(FX_fields)
                dctl_cmd = [ ' SELECT fx_' FX_fields{ii} ...
                    ' FROM rdp20.TRKLAND  WHERE MRI_Session_ID = ' num2str(cur_DC_ID.MRI_Session_ID)  ];
                check_dctl_cmd = DataCentral(dctl_cmd);
                
                %Add 1000 to AxD, RD, and MD
                if ~isempty(obj.Trkland.fx.data.(FX_fields{ii}))
                    if ~isempty(strfind(FX_fields{ii},'RD')) || ~isempty(strfind(FX_fields{ii},'MD')) || ~isempty(strfind(FX_fields{ii},'AxD'))
                        cur_value=num2str(obj.Trkland.fx.data.(FX_fields{ii})*1000);
                    else
                        cur_value=num2str(obj.Trkland.fx.data.(FX_fields{ii}));
                    end
                    
                    if isempty(check_dctl_cmd.(['fx_' FX_fields{ii}]))
                        fprintf(['FX Trkland ==> Inserting to DataCentral: ' id ' on: ' FX_fields{ii} '=' cur_value  ])
                        dctl_cmd = [ 'INSERT INTO rdp20.TRKLAND (MRI_Session_ID,  fx_' FX_fields{ii} ') ' ...
                            ' values ( ' num2str(cur_DC_ID.MRI_Session_ID) ',' cur_value ')'   ] ;
                        DataCentral(dctl_cmd);
                        fprintf('...done\n');
                    else
                        fprintf(['FX Trkland ==> Updating to DataCentral: ' id ' on: ' FX_fields{ii} '=' cur_value  ])
                        dctl_cmd = [ 'UPDATE rdp20.TRKLAND SET fx_' FX_fields{ii} ...
                            ' = ''' cur_value ''' WHERE MRI_Session_ID =  ' ...
                            num2str(cur_DC_ID.MRI_Session_ID)   ] ;
                        DataCentral(dctl_cmd);
                        fprintf('...done\n');
                    end
                end
                %%% upload ROI data
                obj.resave;
            end
            
            
            %FOR CING:
            for ii=1:numel(CING_fields)
                dctl_cmd = [ ' SELECT cing_' CING_fields{ii} ...
                    ' FROM rdp20.TRKLAND  WHERE MRI_Session_ID = ' num2str(cur_DC_ID.MRI_Session_ID)  ];
                check_dctl_cmd = DataCentral(dctl_cmd);
                display(num2str(ii))
                if ~isempty(obj.Trkland.cingulum.data.(CING_fields{ii}))
                    %Add 1000 to AxD, RD, and MD
                    if ~isempty(strfind(CING_fields{ii},'RD')) || ~isempty(strfind(CING_fields{ii},'MD')) || ~isempty(strfind(CING_fields{ii},'AxD'))
                        cur_value=num2str(obj.Trkland.cingulum.data.(CING_fields{ii})*1000);
                    else
                        cur_value=num2str(obj.Trkland.cingulum.data.(CING_fields{ii}));
                    end
                    
                    if isempty(check_dctl_cmd.(['cing_' CING_fields{ii}]))
                        fprintf(['CINGULUM Trkland ==> Inserting to DataCentral: ' id ' on: ' CING_fields{ii} '=' cur_value  ])
                        dctl_cmd = [ 'INSERT INTO rdp20.TRKLAND (MRI_Session_ID,  cing_' CING_fields{ii} ') ' ...
                            ' values ( ' num2str(cur_DC_ID.MRI_Session_ID) ',' cur_value ')'   ] ;
                        DataCentral(dctl_cmd);
                        fprintf('...done\n');
                    else
                        fprintf(['CINGULUM Trkland ==> Updating to DataCentral: ' id ' on: ' CING_fields{ii} '=' cur_value  ])
                        dctl_cmd = [ 'UPDATE rdp20.TRKLAND SET cing_' CING_fields{ii} ...
                            ' = ''' cur_value ''' WHERE MRI_Session_ID =  ' ...
                            num2str(cur_DC_ID.MRI_Session_ID)   ] ;
                        DataCentral(dctl_cmd);
                        fprintf('...done\n');
                    end
                end
                %%% upload ROI data
                obj.resave;
            end
            
            %FOR HIPPOCING:
            for ii=1:numel(HIPPOCING_fields)
                dctl_cmd = [ ' SELECT hippocing_' HIPPOCING_fields{ii} ...
                    ' FROM rdp20.TRKLAND  WHERE MRI_Session_ID = ' num2str(cur_DC_ID.MRI_Session_ID)  ];
                check_dctl_cmd = DataCentral(dctl_cmd);
                display(num2str(ii))
                if ~isempty(obj.Trkland.hippocing.data.(HIPPOCING_fields{ii}))
                    %Add 1000 to AxD, RD, and MD
                    if ~isempty(strfind(HIPPOCING_fields{ii},'RD')) || ~isempty(strfind(HIPPOCING_fields{ii},'MD')) || ~isempty(strfind(HIPPOCING_fields{ii},'AxD'))
                        cur_value=num2str(obj.Trkland.hippocing.data.(HIPPOCING_fields{ii})*1000);
                    else
                        cur_value=num2str(obj.Trkland.hippocing.data.(HIPPOCING_fields{ii}));
                    end
                    
                    if isempty(check_dctl_cmd.(['hippocing_' HIPPOCING_fields{ii}]))
                        fprintf(['HIPPOCINGULUM Trkland ==> Inserting to DataCentral: ' id ' on: ' HIPPOCING_fields{ii} '=' cur_value  ])
                        dctl_cmd = [ 'INSERT INTO rdp20.TRKLAND (MRI_Session_ID,  hippocing_' HIPPOCING_fields{ii} ') ' ...
                            ' values ( ' num2str(cur_DC_ID.MRI_Session_ID) ',' cur_value ')'   ] ;
                        DataCentral(dctl_cmd);
                        fprintf('...done\n');
                    else
                        fprintf(['HIPPOCINGULUM Trkland ==> Updating to DataCentral: ' id ' on: ' HIPPOCING_fields{ii} '=' cur_value  ])
                        dctl_cmd = [ 'UPDATE rdp20.TRKLAND SET hippocing_' HIPPOCING_fields{ii} ...
                            ' = ''' cur_value ''' WHERE MRI_Session_ID =  ' ...
                            num2str(cur_DC_ID.MRI_Session_ID)   ] ;
                        DataCentral(dctl_cmd);
                        fprintf('...done\n');
                    end
                end
                %%% upload ROI data
                obj.resave;
            end
            disp('skelTOIs values have been uploaded to DataCentral');
        end
        function obj = deprecated_proc_as_coreg(obj,source,target,list_toxform,coreg_tech)
            %              fprintf('\n%s\n', 'PERFORMING COREGISTRATION');
            %              wasRun = false;
            %
            %              if nargin<2
            %                  error(['Please specify a source (movable image) when ' ...
            %                      'running proc_as_coreg. One arguments missing']);
            %              end
            %
            %              if iscell(source)
            %                  source = char(source);
            %              end
            %
            %              if nargin<3
            %                  error(['Please specify a target (reference image) when ' ...
            %                      'running proc_as_coreg. Two argument missing']);
            %              end
            %
            %             if nargin<4
            %                  fprintf('Coregistering only source image, not list_toxform provided...')
            %                  list_toxform = '';
            %              end
            %
            %              if nargin<5
            %                  coreg_tech = 'spm';
            %              end
            %
            %              if iscell(target)
            %                  target = char(target);
            %              end
            %
            %              [a, ~, ~] = fileparts(source);
            %              outpath1 = obj.getPath(a,source);
            %
            %
            %              switch coreg_tech
            %                  case 'spm'
            %                      disp('USING SPM:');
            %                      if exist([outpath2 'CoReg.mat'],'file')==0
            %                          wasRun=true;
            %
            %                          VG = spm_vol(target);
            %                          VF = spm_vol(source);
            %
            %                          x = spm_coreg(VG,VF,obj.Params.Coreg.in.spm);
            %                          M  = spm_matrix(x);
            %                          save([outpath2 'CoReg.mat'],'x','M');
            %                      else
            %                          load([outpath2 'CoReg.mat']);
            %                      end
            %                      obj.Params.Coreg.out.regfile = [outpath2 'CoReg.mat'];
            %                      disp('Coregistration Estimation has been performed:');
            %
            %                      [a1 b1 c1] = fileparts(source);
            %                      new = [outpath1  obj.Params.Coreg.in.prefix b1 c1];
            %                      if exist(new,'file')==0
            %                          wasRun=true;
            %                          copyfile(source,new);
            %                          MM = spm_get_space(new);
            %                          spm_get_space(new, M\MM);
            %                          if obj.Params.Coreg.in.reslice
            %                              h1 = spm_vol(obj.Params.Coreg.in.target);
            %                              h2 = spm_vol(new);
            %                              m = dwi_resizeVol2(h2,h1,obj.Params.Coreg.in.resampopt);
            %                              [a b c] = fileparts(new);
            %                              h1.fname = [a filesep 'rs_' b c];
            %                              h1.dt = h2.dt;
            %                              spm_write_vol(h1,m);
            %                          end
            %                      end
            %                      obj.Params.Coreg.out.regimage = new;
            %                      disp('Coregistration has been applied to the mean image:');
            %
            %                  case 'bbreg'
            %                      error('Not implemented yet...');
            % %                      disp('    USING BBREGISTER:');
            % %                      [a1 b1 c1] = fileparts(source);
            % %
            % %                      reg = [outpath2 'reg_' b1 '.dat'];
            % %                      if exist(reg,'file')==0
            % %                          wasRun = true;
            % %                          cmd = ['bbregister --s  '  obj.fsdir ' --mov ' source ' --init-' obj.Params.FS_Params.bbreg ' --' obj.Params.FS_Params.conweight ' --reg ' reg];
            % %                          runFS(cmd,obj.fsdir);
            % %                      end
            % %                      disp('Coregistration Estimation has been performed:');
            % %                      obj.Params.Coreg.out.regfile = reg;
            % %
            % %                      new = [outpath1 obj.Params.Coreg.in.prefix b1 c1];
            % %                      obj.Params.Coreg.out.regimage = new;
            % %
            % %                      if exist(new,'file')==0
            % %                          wasRun = true;
            % %                          if obj.Params.Coreg.in.reslice
            % %                              cmd = ['mri_vol2vol --s ' obj.fsubj ' --mov ' source ' --reg ' reg ' --fstarg --o ' new];
            % %                          else
            % %                              cmd = ['mri_vol2vol --s ' obj.fsubj ' --mov ' source ' --reg ' reg ' --fstarg --no-resample --o ' new];
            % %                          end
            % %                          runFS(cmd,obj.fsdir);
            % %                      end
            % %
            % %                      disp('coregistration with bbregister is complete');
            %                  case 'iuw'
            %                      disp('Perform this step with the IUW module');
            %                      return;
            %                  otherwise
            %                      disp('unknown coregistration style option');
            %                      return
            %            end
        end
        function obj = deprecated_remove_trkland_fields(obj,curTRK)
            if isfield(obj.Trkland.Trks,curTRK)
                temp_fields = fieldnames(obj.Trkland.Trks.(curTRK));
                for ii=1:numel(temp_fields)
                    display(temp_fields{ii});
                    if ( strcmp(temp_fields{ii},'filename') || strcmp(temp_fields{ii},'trk_name') ) || strcmp(temp_fields{ii},'id')
                        donothing=1;
                    else
                        obj.Trkland.Trks.(curTRK).(temp_fields{ii}) = [];
                    end
                end
                clear donothing;
            else
                obj.Trkland.Trks.(curTRK).sstr = [] ;
                obj.Trkland.Trks.(curTRK).header = [] ;
                
            end
        end
        
    end
end



