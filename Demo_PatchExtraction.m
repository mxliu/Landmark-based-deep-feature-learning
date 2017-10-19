
%% We aim to extract patches among each landmark

function Demo_PatchExtraction(m_ii)

addpath ( genpath('NIfTI') );

%% Parameter setting
d = 19 ; % patch size
step = 2 ;  % Tingle size for a specific landmark, in order to patches for a landmark in a specific subject.
num_subject = 428; % 428 for ADNI1 and 360 for ADNI2

%% Database
load landmarks_ADNI1.mat; % This is the landmarks on subject spaces
load mx_landmark_ADNC_Top100.mat;  % Index of top 100 lanmarks
load('labels_ADNI1.mat');

%% Extract 19*19*19 patches from each landmark, with each subject providing 3*3*3 patches
    
  i_landmark = landmarkIndex(m_ii,1);

  frameCnt = 1; 
  
  sub = m_ii;
  sub = sprintf('landmk%03d',sub);
      
  for i_subject = 1:1:num_subject  

    loc = landmarks (:, i_landmark, i_subject);  
    t1Folder = '../AD1/';
    filesT1 = dir([t1Folder,'Img_',int2str(i_subject),'*.hdr']);
    minInd=0;
    maxInd=0;
    maxMRVal=-1000;
    minMRVal=10000;
      
      filename = filesT1.name;
      if ~strfind(filename,sub)
          fprintf('not right sub\n');
      end
      [hdr,filetype,fileprefix,machine] = load_nii_hdr([t1Folder,filename]);
      [img,hdr] = load_nii_img(hdr,filetype,fileprefix,machine);
      img = single(img);
      vec = img(:);
      minX = quantile(vec,0.01);
      maxX = quantile(vec,0.99);
      img = 255.0*(img-minX)/(maxX-minX);
      img(find(img>255)) = 255;
      img(find(img<0)) = 0;
      
      cla = labels_ADNI1(i_subject,1);
      cla(cla==-1) = 0;
      
%% extract videos
   frameCnt = cropCubic(img,loc,cla,frameCnt,sub,d,step) ; 
   
    
  end  

end


%% Crop width*height*length from mat,and stored as image
% note,matData is 3 channels, matSet is 1 channel
% d: the patch size
% step: tingle size for each landmark
function frameCnt = cropCubic(matData,loc,label,frameCnt,saveFilename,d,step) 

    dataPath = 'normEachMR_train/';
    if nargin<7
        step = 3;
    end
    if nargin<6
        d = 15 ;
    end
    [rowData,colData,lenData] = size(matData);
   
    dirname = sprintf('%s/',saveFilename);

    mkdir([dataPath,dirname]);

    clafid = fopen([dataPath,dirname,'classdata.txt'],'a');
  
    % Tingle each landmark at 3*3*3 with step size 2;
    for i = ( round(loc(1,1)) - step ) : step : ( round(loc(1,1)) + step ) % xmin,xmax
        for j = ( round(loc(2,1)) - step ) : step : ( round(loc(2,1)) + step ) % ymin,ymax
            for k = ( round(loc(3,1)) -step ) : step : ( round(loc(3,1)) + step ) % zmin,zmax

                clastr = ['normEachMR_train/',dirname,' ',sprintf('%d',frameCnt),' ',sprintf('%d\n',label)];
                fprintf(clafid,clastr);
                
                subMatData = matData(i-fix(d/2):i+fix(d/2),j-fix(d/2):j+fix(d/2), k-fix(d/2):k+fix(d/2));
                
                %% Generate videos
                tmat = uint8(subMatData);
                myObj = VideoWriter([dataPath,dirname,int2str(frameCnt),'.avi'],'Grayscale AVI');
                frameCnt = frameCnt + 1;
                open(myObj);
                for slice = 1:size(tmat,3)
                    writeVideo(myObj,tmat(:,:,slice));
                end
                close(myObj);                
           
            end
            
        end
    end
    fclose(clafid);
   return 
   
end   


