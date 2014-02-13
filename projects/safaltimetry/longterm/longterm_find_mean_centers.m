function [ numempty ] = longterm_find_mean_centers( inpath, outpath )
numempty = 0;
files = dir([inpath 't*.mat']);
nfiles = length(files)
for tidx = 1:nfiles
    clf; hold on;
    fprintf('Track %03d\n',tidx);
    load([inpath filesep files(tidx).name],'track');
    track.tracknum = tidx;
    opt_track = find_mean_centers( track );
    if isempty(opt_track)
        numempty = numempty+1;
    end    
    
    save([outpath filesep files(tidx).name],'opt_track')
end

end

function  opt_track  = find_mean_centers( intrack )
%
[npts nfiles] = size(intrack.sla);
latrange = intrack.latrange;
buffer = 5; % How far out to extend the previously selected latrage

minlat = min(latrange)-5;
maxlat = max(latrange)+5;

trunc.idx = intrack.lat >= minlat & intrack.lat <= maxlat;

intrack.skewness = skewness(intrack.sla,1);
intrack.std = nanstd(intrack.sla,1);
intrack.smoothskew=smooth(intrack.skewness,10,'mean');

trunc.lat = intrack.lat(trunc.idx);
trunc.skewness = intrack.skewness(trunc.idx);
trunc.smoothskew =intrack.smoothskew(trunc.idx);
trunc.std = intrack.std(trunc.idx);
plot(trunc.lat,trunc.smoothskew); hold on;

[maxtab mintab] = peakdet(trunc.smoothskew,0.1);

if ~isempty(maxtab) & ~isempty(mintab)
    maxtab(:,3) = trunc.lat(maxtab(:,1));
    mintab(:,3) = trunc.lat(mintab(:,1));
    
        
    maxtab = sortrows(maxtab,3);
    mintab = sortrows(mintab,3);
%     
%     inrange = maxtab(:,3) >= minlat & maxtab(:,3) <= maxlat;
%     maxtab = maxtab(inrange,:);
%     
%     inrange = mintab(:,3) >= minlat & mintab(:,3) <= maxlat;
%     mintab = mintab(inrange,:);

        maxtab
    mintab
    while maxtab(1,3) > mintab(1,3)
        mintab(1,:) = [];
        if isempty(mintab)
            break
        end
    end
    ntrans = min([size(maxtab,1) size(mintab,1)]);

    if ntrans > 0
        
        maxtab=maxtab(1:ntrans,:);
        mintab=mintab(1:ntrans,:);
        
        for i = 1:ntrans
            
            transidx = min([maxtab(i,1) mintab(i,1)]):max([maxtab(i,1) mintab(i,1)]);
            opt_track.tracknum = intrack.tracknum;
            opt_track.skewness{i} = trunc.skewness(transidx);
            opt_track.std{i} = nanmean(trunc.std(transidx));
            opt_track.lat{i} = trunc.lat(transidx);
            
%             opt_track(counter).lon{i}= trunc.lon(transidx);            
            plot(opt_track.lat{i},opt_track.skewness{i},'LineWidth',4)
        end
        opt_track
    else
        opt_track = [];
        
    end
    
end
end
