function [distances, indices, lengths] = MERLIN3_1(TOriginal, MinL, MaxL, display_meta_info)
% Eamonn Keogh, Takaaki Nakamura, Makoto Imamura, conceived of the idea of MERLIN
% Kaveh Kamgar implemented the function discord_discovery_gemm
% Ryan Mercer implemented the function MERLIN

%Last updated 2021-07-29

if nargin == 3
    display_meta_info = false;
end

K = 1;
sumnan = sum(isnan(TOriginal));
if( sumnan> 0)
    error('Time series contains %d NaN value(s). Please handle and retry.',sumnan);
end
% for i = 1:length(TOriginal)-MinL+1
%    if std(TOriginal(i:i+MinL-1)) == 0
%        error( "There is a region so close to constant that the results will be unstable. Delete the constant region or try again with a MinL longer than the constant region.");
%    end
% end


lengths = MinL:MaxL;
numLengths = length(lengths);
distances = -1 * inf(numLengths, K);
indices = zeros(numLengths, K);
nnIndices = zeros(numLengths,K);


times = zeros(numLengths, K); % for debugging
misses = -1 * ones(numLengths, K); % for debugging

exclusionIndices = [];
kMultiplier = 1;

tempIndex = 0;
tempDist = 0;
tempNNIndex = 0;
r = 2 * sqrt(MinL);
i = 1;
T = recommendTransformation(TOriginal, lengths(i));
for ki = 1:K
    while distances(1,ki) < 0
        tic;
        % [distances(1,ki), indices(1,ki)] = DRAG_topK(T, lengths(1), r*kMultiplier, exclusionIndices);
%         disp(discord_discovery_gemm(T, lengths(1), r*kMultiplier, exclusionIndices, display_meta_info));
        [tempIndex,tempDist, tempNNIndex] = discord_discovery_gemm(T, lengths(i), r*kMultiplier, exclusionIndices, display_meta_info);
        
        resultString = "";
        if ~isempty(tempIndex) && ~isempty(tempDist)
            [distances(i,ki), maxIndex] = max(tempDist);
            indices(i,ki) = tempIndex(maxIndex);
            nnIndices(i,ki) = tempNNIndex(maxIndex);
            resultString = sprintf('The top discord of length %d is at %d, with a discord distance of %.2f. Its nearest neighbor is at %d\n', lengths(i), indices(i,ki), distances(i,ki), nnIndices(i,ki));
        end
        if display_meta_info
                resultString = resultString + "\n"; 
        end
        fprintf(resultString);
            
        if ki == 1
            r = r * 0.5;
        else
           kMultiplier = kMultiplier * 0.95;
        end
        misses(1, ki) = misses(1, ki) + 1;

    end
    times(1, ki) = toc;
    exclusionIndices = [exclusionIndices, indices(1,ki)];
end

for i = 2:5
    if i > numLengths
        return;
    end
    exclusionIndices = [];
    kMultiplier = 1;
    r =  distances(i-1, 1) * 0.99;
    for ki = 1:K
        tic;

        tempNNIndex = 0;
        while distances(i, ki) < 0
            %[distances(i, ki), indices(i, ki)] = DRAG_topK(T, lengths(i), r*kMultiplier, exclusionIndices);
            [tempIndex,tempDist, tempNNIndex] = discord_discovery_gemm(T, lengths(i), r*kMultiplier, exclusionIndices, display_meta_info);
            
            resultString = "";
            if ~isempty(tempIndex) && ~isempty(tempDist)
                [distances(i,ki), maxIndex] = max(tempDist);
                indices(i,ki) = tempIndex(maxIndex);
                nnIndices(i,ki) = tempNNIndex(maxIndex);
                resultString = sprintf('The top discord of length %d is at %d, with a discord distance of %.2f. Its nearest neighbor is at %d\n', lengths(i), indices(i,ki), distances(i,ki), nnIndices(i,ki));
            end
            if display_meta_info
                resultString = resultString + "\n"; 
            end
            fprintf(resultString);
            
            if ki == 1
                r = r * 0.99;
            else
                kMultiplier = kMultiplier * 0.95;
            end
            misses(i, ki) = misses(i, ki) + 1;
        end
        times(i, ki) = toc;
        exclusionIndices = [exclusionIndices, indices(i,ki)];
    end
end

if numLengths < 6
    return
end
for i = 6:numLengths
    exclusionIndices = [];
    kMultiplier = 1;
    m = mean(distances(i-5:i-1, 1));
    s = std(distances(i-5:i-1, 1));
    r = m - 2 * s;
    for ki = 1:K
        tic;

        while distances(i, ki) < 0
            %[distances(i, ki), indices(i, ki)] = DRAG_topK(T, lengths(i), r*kMultiplier, exclusionIndices);
            [tempIndex,tempDist, tempNNIndex] = discord_discovery_gemm(T, lengths(i), r*kMultiplier, exclusionIndices, display_meta_info);
            
            resultString = "";
            if ~isempty(tempIndex) && ~isempty(tempDist)
                [distances(i,ki), maxIndex] = max(tempDist);
                indices(i,ki) = tempIndex(maxIndex);
                nnIndices(i,ki) = tempNNIndex(maxIndex);
                resultString = sprintf('The top discord of length %d is at %d, with a discord distance of %.2f. Its nearest neighbor is at %d\n', lengths(i), indices(i,ki), distances(i,ki), nnIndices(i,ki));       
            end
            if display_meta_info
                resultString = resultString + "\n"; 
            end
            fprintf(resultString);
            
            r = r * 0.99;
            if ki == 1
                r = r * 0.99;
            else
                kMultiplier = kMultiplier * 0.95;
            end
            misses(i, ki) = misses(i, ki) + 1;
        end

        times(i, ki) = toc;
        exclusionIndices = [exclusionIndices, indices(i,ki)];
    end
end


%PLOT
figure;
tiledlayout(2,1);

ax1 = nexttile;
% subplot(2,1,1);
T_norm = TOriginal-mean(TOriginal);
T_norm = T_norm/std(T_norm);
plot(T_norm);
xlim([1,length(TOriginal)]);
box off;
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])

ax2 = nexttile;
% subplot(2,1,2);
markerSize = 4;
rectangle('Position',[1,MinL,length(T), MaxL], 'EdgeColor', [0,0,0], 'FaceColor',[0.9,0.9,0.9]);
hold on;

for ki = 1:K
    if ki == 1
        scatter(indices(:,ki),lengths,markerSize,'r', 'filled');
    else
        scatter(indices(:,ki),lengths,markerSize, 'filled');
    end
end
hold off;
xlim([1,length(T)]);

ylim([MinL, MaxL]);
yticks([MinL, MaxL]);

set(gca,'TickDir','out');
set(gca, 'YDir','reverse');
box off;

linkaxes([ax1, ax2], 'x');


% subplot(3,1,3);
% hold on;
% rectangle('Position',[1,MinL,length(T), MaxL], 'EdgeColor', [0,0,0], 'FaceColor',[0.9,0.9,0.9]);
% for ki = 1:K
%     for i=1:length(lengths)
%        plot([indices(i, ki),indices(i, ki)+lengths(i)],[lengths(i),lengths(i)])
%     end
% end
% hold off;
% xlim([1,length(T)]);
%
% ylim([MinL, MaxL]);
% yticks([MinL, MaxL]);
%
% set(gca,'TickDir','out');
% set(gca, 'YDir','reverse')
% box off;
end

function [T2] = preprocessTimeSeries(T, w)
TMean = nanmean(T);
TSTD = nanstd(T);
TNorm = (T - TMean)/TSTD;
dataSlope = (1:length(T));
T2 = TNorm(:) + dataSlope(:);
end

function [T2] = recommendTransformation(T, w)
    TMean = nanmean(T);
    TSTD = nanstd(T);
    T2 = (T - TMean)/TSTD;
    Tmovstd = movstd(T2, w);
    
    figure;
    f = gcf;
    tiledlayout(1,1);
    ax = nexttile();
    
    numBins = 100;
    edges = linspace(0,max(Tmovstd), numBins);
    h = histogram(ax, Tmovstd, edges);

    title({"Histogram of subsequence std","Bins near 0 cause problems!"});
    xlabel("movstd");
    ylabel("number of subsequence");
    
    userMessage = "";
    pad = "!!!   ";
    userMessage = "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
    userMessage = userMessage + pad + "MERLIN may report false positive anomalies in subsequences with near constant values.\n";
    userMessage = userMessage + pad + "A sign that the problem exist is a spike near zero when plotting the histogram of movstd.\n";
    userMessage = userMessage + pad + "Adding a large linear trend will solve this issue.\n";
    
    userQuestion = pad + "Proceed with data modification? [y/n]\n";
    answer = "na";
    if true || sum(h.BinCounts(1:5)) > 0
        fprintf(userMessage);
        while strcmp(answer,"y") == 0 && strcmp(answer,"n") == 0
            answer = input(userQuestion, 's');
        end
    end
    
    close(f);
    
    if strcmp(answer,"y")
       T2 = preprocessTimeSeries(T, w);
    end
end

function [disc_loc, cands_nn_dist, cands_nn_pos] = discord_discovery_gemm(TS, subseqlen, r, exclusionIndices, display_meta_info)
%
% discord_discovery_gemm Version 1.2
%
% Inputs
% TS: time series
% L: subsequence length
% r: range parameter
%
% Outputs
% disc_loc: starting indices of the discords in the time series TS
%
% cands_nn_dist: The distance between each discord and its nearest neighbor
%
% cands_nn_pos: The subsequence index where each discord's nearest neighbor
% was found in the time series
%
%
% This will find all subsequences of the form
% TS_i = zscore(TS(i : i + subseqlen - 1), 1)
% where for any j such that abs(i - j) >= min_sep
%
% norm(TS_i - T_j) >= r
%
%
% In matlab you can check this using
% norm(zscore(TS(i : i + subseqlen - 1), 1) - zscore(TS(j : j + subseqlen - 1), 1)
%
% if zscore is available.
%
% Implementation by Kaveh Kamgar, based on
%
% Yankov, Keogh, et al
% Disk Aware Discord Discovery: Finding Unusual Time Series in Terabyte Sized Datasets
%
% Deviations from the original paper are noted at the beginning of
% the source code.
%


% This implementation and all changes from the initial reference paper were
% made by Kaveh Kamgar.
%
% Changes from the reference paper are as follows:
%
% We use normalized cross correlation internally to allow
% comparisons to be performed in batches using dense matrix products.
%
% Nearest neighbor distance and index information is computed after Phase
% 2, once all candidates are known.
%
% Comparisons are batched by sequence block.
%
% Candidates are explicitly stored in sorted order to minimize the
% complexity of determining which comparisons between candidates and blocks
% are inadmissible.
%
% This last part introduces a minor inconsistency with the reference paper.
% In the initial paper, during Phase 1, a sequence is compared with all
% existing candidates before becoming a candidate. If any of them reject
% the sequence, both the sequence and all candidates that reject it are
% rejected.
%
% Here, we compute these in blocks with any sequences in a particular block
% being compared to sequences in the same block
% sequence never becomes a candidate and the candidate is ejected.
%
% Here, we batch comparisons between all candidates present at the beginning of a
% block and all sequences in that block, excluding those that must be
% excluded due to conflicts.
%
% We then perform any cross comparisons between
% candidates in the same block prior to adding them as candidates, so as to
% avoid redundant data movement.
%
% Both of these actions introduce minor divergence from the original paper.
%
% In the original paper:
%
% If any candidate rejects a sequence, that candidate is also immediately
% rejected and would not be compared to later sequences in Phase 1.
%
% Second, sequences that are only compared to other sequences that follow
% them if they are admitted as candidates.
%
% Here since we compare candidates based on the candidate state at the
% beginning of a block, a candidate can eject every sequence that is near
% it. This could cause the candidate list to grow too large, since sequences
% that are located close in time may eject each other if the time series is
% at mildly auto-correlated at some lag of at least min_sep. To mitigate this,
% we perform all within block comparisons during Phase 1.
%
% The candidate matrix could still grow large, but it's less likely.
%
%
%
% Last edit: 8/5/20
% Added optional display of meta info and

if nargin == 4
    display_meta_info = false;
end

disc_loc = [];
cands_nn_dist = [];
cands_nn_pos = [];


if display_meta_info
    t = tic();
end


if ~(0 < r  && r <= 2 * sqrt(subseqlen))
    if display_meta_info
        errorString = sprintf("Failure: The r parameter of %.2f was too large for the algorithm to work, try making it smaller\n", r);
        errorString = errorString + "A valid choice of r must be greater than 0 and less than or equal to 2 * sqrt(L)\n\n";
        fprintf(errorString);
    end
    return;
end

% This transforms a distance value, corresponding to z-normalized
% Euclidean distance into a correlation coefficient.
% Since this is computed numerically, it may fail to be precisely
% invertible.
r = 1 - (r^2)/(2*subseqlen);


if ~isvector(TS)
    error('Expected a 1D input for time series');
elseif isrow(TS)
    TS = transpose(TS);
end

if floor(length(TS)/2) < subseqlen || subseqlen < 4
    error('Subsequence length parameter must be in the range of 4 < L <= floor(length(TS)/2).');
end

% Implementation note:
% This could be set dynamically as an added parameter.
min_sep = subseqlen;


% compute normalization constants
subseqcount = length(TS) - subseqlen + 1;

% Set up a subsequence matrix and one for candidates
% In this case


% Implementation notes:
%
% Normalization and packing can be optionally done in blocks and folded
% into blockwise updates at each phase, if this creates too much memory pressure.
% In such an implementation, I would suggest
%
% 1. computing mean and norm in advance
%
% 2. storing subsequences 1 per row rather than 1 per column and reversing
%    the comparison order to ss' * cands. This avoids the explicit
%    transpose. Otherwise you are relying on Matlab's optimizer to call the
%    appropriate gemm implementation for A^T * A, since the transposition
%    is never assigned to any variable.
%
% I don't use this implementation, because I found that dynamically resizing
% the candidate matrix in Matlab tends to expose a lot of buffer management
% that could be more easily hidden in other languages. This can make the
% implementation less clear and harder to debug, especially as increasing the
% candidate matrix just enough as opposed to doubling its size can be costly.


ss = zeros(subseqlen, subseqcount);
for i = 1 : subseqcount
    ss(:, i) = TS(i : i + subseqlen - 1);
end

% mean and norm are computed per subsequence
% This is more reliable than the use of O(n) methods in cases that
% would result in poorly conditioned calculations, such as those with
% extremely highly local variance or missing data.

ss = ss - mean(ss, 1);
ss = ss ./ vecnorm(ss);


% Algorithm 2: Candidates Selection Phase

% Implementation note:
% This could be set dynamically. From my own observations, 256 made a
% reasonable catch all, and subseqlen / 2 worked well.
% Most matrix libraries use assembly coded kernel or micro-kernel sizes that
% are small powers of 2, so I generally stick to that convention, even for
% non power of 2 subsequence lengths

% mxblocklen can be made dynamic. In my observations, 256 worked reasonably
% well with a subsequence length of a few hundred. If it's too small, you
% get low throughput on matrix operations. If it's very large, you get
% too many unnecessary comparisons.

mxblocklen = 256;

cands = zeros(subseqlen, subseqcount);
cands_idx = zeros(subseqcount, 1);
cand_count = 0;

if display_meta_info
    elapsed_preprocessing = toc(t);
    t = tic();
end
% These contain some notes.
% These are meant to clarify parts that after profiling, were difficult
% to write in efficient matlab code without losing clarity in addition to
% some implicit details that are not strictly required by the original
% paper's suggested algorithms
%
% Since this is computed in blocks, candidates must maintain temporal
% ordering. This simplifies checks as to what can be compared to what and
% allows the use of matrix methods rather than single dot products wherever
% possible.
%

for i = 1 : mxblocklen : subseqcount
    blocklen = min(mxblocklen, subseqcount - i + 1);
    no_rej = true(blocklen, 1);

    if cand_count ~= 0

        % First test which candidates are ejected by one or more
        % comparisons to this sequence block.
        % Also mark all sequences in this block that are too close to an
        % existing candidate as non-potential candidates
        valid_cands = true(cand_count, 1);

        if cands_idx(1) <= i + blocklen - min_sep - 1
            last_cmp = find(cands_idx(1:cand_count) <= i + blocklen - min_sep - 1, 1, 'last');

            if cands_idx(1) > i - min_sep
                last_no_confl = 0;
            else
                last_no_confl = find(cands_idx(1:cand_count) <= i - min_sep, 1, 'last');
                cr = cands(:, 1 : last_no_confl)' * ss(:, i : i + blocklen - 1);
                valid_cands(any(cr > r, 2)) = false;
                no_rej(any(cr > r, 1)) = false;
            end

            for pos = last_no_confl + 1 : last_cmp
                first_cmp_seq = max(i, cands_idx(pos) + min_sep);
                cr = cands(:, pos)' * ss(:, first_cmp_seq : i + blocklen - 1);
                % matlab implementation detail:
                % We have to use find here rather than a mask
                % (the preferred method) in order to skip the
                % first part of the array.
                invalid = find(cr > r) + first_cmp_seq - i;
                if ~isempty(invalid)
                    valid_cands(pos) = false;
                    no_rej(invalid) = false;
                end
            end

            surviving_count = sum(valid_cands);
            if surviving_count < cand_count
                % matlab implementation detail:
                % If boolean array valid_cands is shorter than cands_idx, everything
                % after the last element of valid_cands is treated as false
                %
                % This is noticeably faster than assigning [] to candidate
                % positions that must be ejected.
                cands_idx(1 : surviving_count) = cands_idx(valid_cands);
                cands(:, 1 : surviving_count) = cands(:, valid_cands);
                cand_count = surviving_count;
            end
        end
    end

    % If our blocklen permits within block comparisons, we perform them
    % before moving any sequences intto the candidate list
    if blocklen >= min_sep
        for pos = 1 + min_sep : blocklen
            cr = ss(:, i + pos - 1)' * ss(:, i : i + pos - min_sep - 1);
            others = find(cr > r);
            if ~isempty(others)
                no_rej(pos) = false;
                no_rej(others) = false;
            end
        end
    end

    % Append surviving sequences to the end of the candidate matrix
    % This way we maintain temporal ordering and can separate out batchable
    % parts
    can_add = find(no_rej) + i - 1;
    if ~isempty(can_add)
        prev_count = cand_count;
        cand_count = cand_count + length(can_add);
        cands(:, prev_count + 1 : prev_count + length(can_add)) = ss(:, can_add );
        cands_idx(prev_count + 1 : prev_count + length(can_add)) = can_add;
    end

end

if display_meta_info
    elapsed_phase_1 = toc(t);
    t = tic();
end

% Algorithm 1, candidate refinement phase
% Phase 1 maintains the candidates in sorted order and ensures that
% candidates have been compared to everything within the block where they
% are found and any block that succeeds that one. Phase 2 then compares
% each candidate found in Phase 1 to all sequences in blocks that precedes
% the candidate's initial block.
%
% Explicit nearest neighbor calculations were moved to Phase 3 for all
% surviving candidates.


for i = 1 : mxblocklen : subseqcount
    % This takes the same block positions as part 1. Phase 1 takes care of
    % within block comparisons and comparisons between candidates and
    % blocks that appear after the candidate position.
    % Here we check prior to the candidate position.

    if cand_count == 0
        break;
    end

    valid_cands = true(cand_count, 1);

    blocklen = min(mxblocklen, subseqcount - i + 1);

    % Within block comparisons made at phase 1, this is just to capture
    % min_sep exceeding blocklen
    min_cand_idx = max(i + blocklen, i + min_sep);

    if cands_idx(cand_count) < min_cand_idx
        % Any comparisons that could result in rejecting additional candidates
        % were already made in Phase 1.
        break;
    end

    first_cmp_pos = find(cands_idx(1 : cand_count) >= min_cand_idx, 1);
    no_conflict_begin = i + blocklen + min_sep - 1;
    if cands_idx(cand_count) < no_conflict_begin
        no_confl_cmp_pos = cand_count + 1;
    else
        no_confl_cmp_pos = find(cands_idx(first_cmp_pos : cand_count) >= no_conflict_begin, 1) + first_cmp_pos - 1;
    end

    % This covers:
    %     i + min_sep <= cands_idx(pos) < i + blocklen + min_sep - 1
    for pos = first_cmp_pos : no_confl_cmp_pos - 1
        if any(cands(:, pos)' * ss(:, i : cands_idx(pos) - min_sep) > r)
            valid_cands(pos) = false;
        end
    end

    % This covers:
    %     i + blocklen + min_sep - 1 <= cands_idx(...)
    if no_confl_cmp_pos < cand_count
        cr = cands(:, no_confl_cmp_pos : cand_count)' * ss(:, i : i + blocklen - 1);
        valid_cands(find(any(cr > r, 2)) + no_confl_cmp_pos - 1) = false;
    end

    surviving_count = sum(valid_cands);
    if surviving_count < cand_count
        % Matlab implementation note:
        % valid_cands covers only the first cand_count members,
        % Matlab will treat the range (length(valid_cands)+1 : end)
        % as implicitly false.
        % Tested on 2020a, but this should apply to most older versions.
        cands_idx(1 : surviving_count) = cands_idx(valid_cands);
        cands(:, 1 : surviving_count) = cands(:, valid_cands);
        cand_count = surviving_count;
    end
end

disc_loc = cands_idx(1:cand_count);

if display_meta_info
    elapsed_phase_2 = toc(t);
    t = tic();
end

% After Phase 2, cands and cands_idx contain the subsequences and indices
% of the original time series which admit a
% nearest neighbor distance >= r
%
% This section computes their nearest neighbor information, distance and
% index.
%
% Blocks which do not contain conflicts use a block GEMM based normalized
% cross correlation.
% We handle conflicts between candidates and a block using
% matrix vector products (GEMMV) instead.

% Candidates are now fixed, so we truncate their array.
% The comparison method used in this phase is the same as the earlier
% phases. This avoids the ability for subtle differences in numerical
% rounding to admit certain candidates in an earlier phase, yet reject them
% here.
cands = cands(:, 1 : cand_count);
cands_idx = cands_idx(1 : cand_count);

cands_nn_dist = repmat(-1, cand_count, 1);
cands_nn_pos = repmat(-1,  cand_count, 1);

if cand_count > 0
    % This assumes that candidates are sorted in 'cands' and 'cands_idx'
    % according to their initial order of appearance in the time series.
    % This information is used to determine conflicting sections between
    % candidates and subsequence blocks, which allows for faster batching
    % of comparisons.
    for i = 1 : mxblocklen : subseqcount
        blocklen = min(mxblocklen, subseqcount - i + 1);
        first_confl = find((cands_idx > i - min_sep) & (cands_idx <= i + blocklen - 1 + min_sep), 1);
        if isempty(first_confl)
            first_confl = cand_count + 1;
            last_confl = [];
        else
            last_confl = find((cands_idx > i - min_sep) & (cands_idx <= i + blocklen - 1 + min_sep), 1, 'last');
        end

        if first_confl > 1
            [mxcr, mxcor_pos] = max(cands(:, 1 : first_confl - 1)' * ss(:, i : i + blocklen - 1), [], 2);
            update = find(mxcr > cands_nn_dist(1 : first_confl - 1));
            cands_nn_pos(update) = mxcor_pos(update) + i - 1;
            cands_nn_dist(update) = mxcr(update);
        end
        if first_confl <= cand_count
            % Matlab Implementation note:
            % Profiling showed this section could be a bottleneck for some
            % input cases, so partial batching was added for candidates
            % with 1 or more conflicts in this block.
            %
            % This covers candidates which admit at least 1 comparison
            % in the current block and exclude at least 1 comparison in
            % the current block.
            for pos = first_confl : last_confl
                if abs(cands_idx(pos) - i) < min_sep
                    % This captures candidates which conflict with the
                    % beginning of a block. If the candidate also conflicts
                    % with the end of the block, we don't perform any
                    % comparisons.
                    if abs(cands_idx(pos) - (i + blocklen - 1)) >= min_sep
                        cmp_begin = cands_idx(pos) + min_sep;
                        [mxcr, mxcr_idx] = max(cands(:, pos)' * ss(:, cmp_begin : i + blocklen - 1), [], 2);
                        if mxcr > cands_nn_dist(pos)
                            cands_nn_dist(pos) = mxcr;
                            cands_nn_pos(pos) = mxcr_idx + cmp_begin - 1;
                        end
                    end
                elseif abs(cands_idx(pos) - (i + blocklen - 1)) < min_sep
                    % This captures cases which conflict with the end of
                    % the block but not the beginning
                    [mxcr, mxcr_idx] = max(cands(:, pos)' * ss(:, i : cands_idx(pos) - min_sep), [], 2);
                    if mxcr > cands_nn_dist(pos)
                        cands_nn_dist(pos) = mxcr;
                        cands_nn_pos(pos) = mxcr_idx + i - 1;
                    end
                else
                    % This captures cases where a candidate was found
                    % in the current sequence block, but it does not conflict
                    % with the beginning or end of the block, yielding 2
                    % valid comparison ranges for this candidate in this
                    % block.

                    [mxcr_lo, mxcr_idx_lo] = max(cands(:, pos)' * ss(:, i : cands_idx(pos) - min_sep), [], 2);
                    [mxcr_hi, mxcr_idx_hi] = max(cands(:, pos)' * ss(:, cands_idx(pos) + min_sep : i + blocklen - 1), [], 2);
                    if mxcr_lo > mxcr_hi
                        mxcr = mxcr_lo;
                        mxcr_idx = mxcr_idx_lo + i - 1;
                    else
                        mxcr = mxcr_hi;
                        mxcr_idx = mxcr_idx_hi + cands_idx(pos) + min_sep - 1;
                    end
                    if mxcr > cands_nn_dist(pos)
                        cands_nn_dist(pos) = mxcr;
                        cands_nn_pos(pos) = mxcr_idx;
                    end
                end
            end

            if last_confl < cand_count
                [mxcr, mxcor_pos] = max(cands(:, last_confl + 1 : end)' * ss(:, i : i + blocklen - 1), [], 2);
                update = find(mxcr > cands_nn_dist(last_confl + 1 : end));
                cands_nn_pos(update + last_confl) = mxcor_pos(update) + i - 1;
                cands_nn_dist(update  + last_confl) = mxcr(update);
            end
        end
    end
end

if display_meta_info
    elapsed_phase_3 = toc(t);
    fprintf('Preprocessing took: %.2f seconds.\n', elapsed_preprocessing);
    fprintf('Initial candidate selection took %.2f seconds.\n', elapsed_phase_1);
    fprintf('Candidate refinement took %.2f seconds.\n', elapsed_phase_2);
    if cand_count == 0
        fprintf('No candidates with a nearest neighbor distance of at least %.2f were found.\n', r);
    else
        fprintf('Computing nearest neighbor information took %.2f seconds.\n', elapsed_phase_3);
    end
    fprintf('Total execution time was %.2f seconds\n', elapsed_preprocessing + elapsed_phase_1 + elapsed_phase_2 + elapsed_phase_3);
end

cands_nn_dist = sqrt(max(0, 2 * subseqlen * (1 - cands_nn_dist)));

end
