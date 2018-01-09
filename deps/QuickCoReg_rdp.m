function QuickCoReg(ref,mov,list_applyxforms, prefix)
%%% map ref to mov

clear flags
flags.sep = [4 2]; % default
flags.params = [0 0 0  0 0 0];% default
flags.cost_fun = 'nmi'; % default; options are: 'mi'  - Mutual Information 'nmi' - Normalised Mutual Information 'ecc' - Entropy Correlation Coefficient  'ncc' - Normalised Cross Correlation
flags.tol = [0.02 0.02 0.02 0.001 0.001 0.001]; %default
flags.fwhm = [7 7]; % default
flags.graphics = ~spm('CmdLine') ;% default

%Check if files exists!
if exist(ref,'file') == 0
    error([ ref ' does not exist']);
end

if exist(mov,'file') == 0
    error([ mov ' does not exist']);
end


%Check if gzipped...
[ ~, ~, ext_ref ] = fileparts(ref);
if strcmp(ext_ref,'.gz')
    system(['gunzip ' ref ] );
    ref = strrep(ref,'.gz',''); 
    VF = spm_vol(ref);
elseif strcmp(ext_ref,'.nii');
    VF = spm_vol(ref);
else
    error([ 'ref is not .nii or .nii.gz -->' ref ]);
end

[ ~, ~, ext_mov ] = fileparts(mov);
if strcmp(ext_mov,'.gz')
    system(['gunzip ' mov ] );
    mov = strrep(mov,'.gz','');
    VG = spm_vol(mov);
elseif strcmp(ext_mov,'.nii')
    VG = spm_vol(mov);
else
    error([ 'mov is not .nii or .nii.gz -->' mov ]);
end

x = spm_coreg(VG,VF,flags);
M  = spm_matrix(x);

save CoReg.mat x M;

%%% apply the estimated transformations to the header. look at spm_run_coreg_estwrite.m
M  = spm_matrix(x);
PO = {VF.fname};
MM = zeros(4,4,numel(PO));
MM = spm_get_space(VF.fname);
spm_get_space(VF.fname, M\MM);

%%% reslice the Mean CPS image to T1 space
clear P;
P{1}  = mov;
P{2}  = ref;
clear flags;
flags.mask   = 0;
flags.mean   = 0;
flags.interp = 0; % 1 for default (B-spline). 0 for neares neighbout
flags.which  = 1;
flags.wrap   = [0 0 0];
flags.prefix = 'r';


spm_reslice(P,flags);


%%GZIP check
if strcmp(ext_ref,'.gz')
    system(['gzip ' ref ] );
end

if strcmp(ext_mov,'.gz')
    system(['gzip ' mov ]);
end

if nargin==3 && ~isempty(list_applyxforms)
    for ii=1:numel(list_applyxforms)
        [m h] = openIMG(list_applyxforms{ii});
        h2 = spm_vol(ref);
        h.mat = h2(1).mat;
        spm_write_vol(h,m);
        
        P{2} = list_applyxforms{ii};
        spm_reslice(P,flags);
    end
end