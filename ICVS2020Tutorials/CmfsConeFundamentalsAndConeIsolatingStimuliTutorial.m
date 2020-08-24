% CmfsConeFundamentalsAndConeIsolatingStimuliTutorial
%
% Connections between color matching functions and cone fundamentals, and
% illustration of cone isolating stimuli.
%
% These ideas are illustrated using Stiles-Burch 10 degree cmfs and the
% Stockman-Sharpe 10 degree cone fundamentals, but the principles
% would apply to any tristimulus system and cone fundamentals that
% were a linear transfomration of the color matching functions.
%
% The tutorial that Stockman-Sharpe 10 degree fundamentals are a linear
% transformation of the Stiles-Burch 10 degree Cmfs, and illustrates how
% the spectrum locus, cone isolating stimulus directions, and cone response
% mechanism vectors look in the RGB tristimulus space and in the rg
% chromaticity diagram.
%
% The Stiles-Burch 10-degree cmfs are expressed with respect to primaries at
% 645.16, 526.32, 444.44 nm. Here we round to nearest integer wavelength.
%
% This tutorial was originally developed to generate figures for a book
% that David Brainard and Andrew Stockman may write someday, and has been
% extended and modified here for explanatory purposes.
%
% This tutorial is available in the github repository
%   https://github.com/BrainardLab/TeachingCode
% You can either clone the respository or just download a copy from
% that page (see green "Code" button).
%
% To run this, you will need both the Psychophysics Toolbox (PsychToolbox),
% BrainardLabToolbox and ColorBookToolbox on your path.  You can get the
% PsychToolbox from
%   psychtoolbox.org
% You can get the BrainardLabToolbox from
%   https://github.com/BrainardLab/BrainardLabToolbox
% You can get the ColorBookToolbox from
%   https://github.com/DavidBrainard/ColorBookToolbox
%
% If you use the ToolboxToolbox (https://github.com/toolboxhub/toolboxtoolbox)
% and install the TeachingCode repository in your projects folder, you can
% install the dependencies by using
%     tbUseProject('TeachingCode')
% at the Matlab prompt.

% History:
%    08/21/2020  dhb  Simplified and then expanded from a similar similar
%                     figure generating program in the ColorBookFigures
%                     repository.

%% Initialize
clear; close all; drawnow;

%% Get and plot Stiles-Burch 10-degree color matching functions
%
% Also spline to 1 nm and 10 nm sampling for plotting purposes.
load T_stiles10;
wls = SToWls(S_stiles10);

% These splines go from 390 to 750, which seems sufficient
S_1nm = [390 1 361];
wls_1nm = SToWls(S_1nm);
T_stiles10_1nm = SplineCmf(wls,T_stiles10,S_1nm);
S_10nm = [390 10 37];
wls_10nm = SToWls(S_10nm);
T_stiles10_10nm = SplineCmf(wls,T_stiles10,S_10nm);

% Plot the color matching functions.
%
% There's a bit of machinery here to make the figure look halfway decent, but this
% is an older style than what we would do today, don't really recommend
% adopting this approach for anything that you're doing at scale.
[stilesBurch10Fig,figParams] = cbFigInit;
figParams.xLimLow = 350;
figParams.xLimHigh = 750;
figParams.xTicks = [350 400 450 500 550 600 650 700 750];
figParams.xTickLabels = {'^{ }350_{ }' '^{ }400_{ }' '^{ }450_{ }' '^{ }500_{ }' ...
    '^{ }550_{ }' '^{ }600_{ }' '^{ }650_{ }' '^{ }700_{ }' '^{ }750_{ }'};
figParams.yLimLow = -1;
figParams.yLimHigh = 4;
figParams.yTicks = [-1 0 1 2 3 4];
figParams.yTickLabels = {'-1.0 ' ' 0.0 ' ' 1.0 ' ' 2.0 ' ' 3.0 ' ' 4.0 '};

plot(wls_1nm,T_stiles10_1nm(1,:)','r','LineWidth',figParams.lineWidth);
plot(wls_1nm,T_stiles10_1nm(2,:)','g','LineWidth',figParams.lineWidth);
plot(wls_1nm,T_stiles10_1nm(3,:)','b','LineWidth',figParams.lineWidth);

xlabel('Wavelength (nm)','FontSize',figParams.labelFontSize);
ylabel('CMF (energy units)','FontSize',figParams.labelFontSize);
title('Stiles-Burch 10-degree CMFs','FontSize',figParams.titleFontSize);
cbFigAxisSet(stilesBurch10Fig,figParams);

%% Load Stockman-Sharpe 10-degree cone fundamentals
load T_cones_ss10
T_cones10_1nm = SplineCmf(S_cones_ss10,T_cones_ss10,wls_1nm);

% Plot them
[stockmanSharpe10Fig,figParams] = cbFigInit;
figParams.xLimLow = 350;
figParams.xLimHigh = 750;
figParams.xTicks = [350 400 450 500 550 600 650 700 750];
figParams.xTickLabels = {'^{ }350_{ }' '^{ }400_{ }' '^{ }450_{ }' '^{ }500_{ }' ...
    '^{ }550_{ }' '^{ }600_{ }' '^{ }650_{ }' '^{ }700_{ }' '^{ }750_{ }'};
figParams.yLimLow = 0;
figParams.yLimHigh = 1;
figParams.yTicks = [0 0.5 1];
figParams.yTickLabels = {' 0.0 ' ' 0.5 ' ' 1.0 '};

% Plot the fundamentals
plot(wls_1nm,T_cones10_1nm(1,:)','r','LineWidth',figParams.lineWidth);
plot(wls_1nm,T_cones10_1nm(2,:)','g','LineWidth',figParams.lineWidth);
plot(wls_1nm,T_cones10_1nm(3,:)','b','LineWidth',figParams.lineWidth);
xlabel('Wavelength (nm)','FontSize',figParams.labelFontSize);
ylabel('Cone Fundamental (energy units)','FontSize',figParams.labelFontSize);
title('Stockman-Sharpe 10-degree CMFs','FontSize',figParams.titleFontSize);
cbFigAxisSet(stockmanSharpe10Fig,figParams);

%% Find the linear transformation from cmfs to cone fundamentals
%
% Here we know them both so we simply use linear reagression to do this.
% Obviously, that wouldn't work if you just knew the cone fundamentals,
% where you'd have to determine the linear transformation using additional
% data.  But the first point we want to make is that the cone fundamentals
% are a linear transformation of the color matching functions, which we
% will do below.
%
% This little bit of Matlab code does the linear regression, with the
% various transposes needed to match the convention of the \ operator.
M_CmfToCones = ((T_stiles10_1nm')\(T_cones10_1nm'))';

%% Get the fundamentals from the cmfs
%
% We use the matrix we found just above and voila. It isn't surprising
% that the fit is excellent, since the Stockman-Sharpe 10-degree
% fundamentals were in fact constructed as a linear transformation of the
% Stiles-Burch 10 degree cmfs.
T_cones10_fit_1nm = M_CmfToCones*T_stiles10_1nm;

% Pop on top the fit from Stiles-Burch 10 degree cmfs onto the fundamentals
% plot.  They overlay nicely (dashed black on top of colored lines.
plot(wls_1nm,T_cones10_fit_1nm(1,:)','k:','LineWidth',figParams.lineWidth-1);
plot(wls_1nm,T_cones10_fit_1nm(2,:)','k:','LineWidth',figParams.lineWidth-1);
plot(wls_1nm,T_cones10_fit_1nm(3,:)','k:','LineWidth',figParams.lineWidth-1);

%% Find the tristimulus coorindates (rgb) that isolate each of the cones.
%
% We have from above the transformation for CMFs to cones spectral sensitivies.
% This is also the transformation between tristimulus coordinates
% and cone excitations. Invert this to get transformation between
% cone excitations and tristimulus coordinates.  Then apply to the
% unit cone excitation vectors to get the cone isolating tristimulus
% vectors.
M_ConesToCmf = inv(M_CmfToCones);
coneIsolatingRGBDirs = M_ConesToCmf*[[1 0 0]', [0 1 0]', [0 0 1]'];

%% Check.
%
% Reconstruct spectra and compute cone responses from fundamentals.

% First we'll need the primaries, because we'll need to weight these by the
% cone isolating tristimulus coordinates to get the cone isolating spectra.
% The Stiles-Burch CMFs were measured with respect to monochromatic
% primaries and we know the wavelengths, so this is straightforward.
% We round wavelengths to nearest nm, which is not exact but appears to
% work to within about 1 percent numerically in various checks below.
B_1nm = zeros(S_1nm(3),3);
primaryWls = [645, 526, 444];
for i = 1:3
    wlIndex = find(wls_1nm == primaryWls(i));
    B_1nm(wlIndex,i) = 1;
end

% Construct cone isolating spectra themselves. If you plot these you'll see
% that they have negative power at some wavelengths, so if we wanted to
% look at them we'd have to add these to some background spectrum, which would
% produce a difference in spectra that was only seen by one class of cone.
coneIsolatingSpectra = B_1nm*coneIsolatingRGBDirs;

% Compute the cone responses to the cone isolating spectra.  These are good
% to about a percent, because we rounded primaries to nearest nm. Cool!
coneIsolatingSpectraLMS = T_cones10_1nm*coneIsolatingSpectra;
tolerance = 0.01;
quantity = coneIsolatingSpectraLMS-eye(3,3);
if (max(abs(quantity)) > tolerance)
    error('Cone isolating spectra LMS check fails');
end

%% Construct chromaticity diagram for the RGB tristimulus space.
%
% In a chromaticity diagram, we normalize tristimulus values in some manner
% so that we remove information about intensive variation in the stimulus
% and preserve information about variation in relative tristimulus values.
% Various different conventions for chromaticity diagrams are available.
% One common one is to normalize the tristimulus coorindates by their sum,
% and then to plot two of the three in a plane.  That's the convention we
% use here.
%
% The function XYZtoxyY does this normalization, taking tristimulus values
% as columns of its input and returning the first two normalized
% tristimulus values as well as the unnormalized second tristimulus value
% as the columns of its output. When the tristimulus values are in the XYZ
% system, this routine returns the familiar xy chromaticity and luminance
% Y.  But the routine doesn't care what trisimluus values we pass, so we
% can use it here.  We'll ignore the third row of the return, which we
% don't need for the plots below.

% Chromaticity of spectrum locus (that of the color matching functions
% themselves) at 1 nm and 10 nm spacing. We can make a prettier plot if we
% have both spacings.
T_stiles10_1nm_chrom = XYZToxyY(T_stiles10_1nm);
T_stiles10_10nm_chrom = XYZToxyY(T_stiles10_10nm);

% Make plot of spectrum locus and cone isolating chromaticities.  For
% reasons that will become apparent below, we're going to make three copies
% of the plot, one in each of three subpanels.
[chromaticityFig,figParams] = cbFigInit;
set(gcf,'Position',[100 254 1200 600]);

figParams.xLimLow = -2;
figParams.xLimHigh = 2;
figParams.xTicks = [-2 -1.5 -1 -0.5 0 0.5 1 1.5 2];
figParams.xTickLabels = {'^{ }-2.0_{ }' '^{ }-1.5_{ }' '^{ }-1.0_{ }' '^{ }-0.5_{ }' '^{ }0.0_{ }' ...
    '^{ }0.5_{ }' '^{ }1.0_{ }' '^{ }1.5_{ }' '^{ }2.0_{ }'};
figParams.yLimLow = -1;
figParams.yLimHigh = 3;
figParams.yTicks = [-1 -0.5 0 0.5 1 1.5 2 2.5 3.0];
figParams.yTickLabels = {'^{ }-1.0_{ }' '^{ }-0.5_{ }' '^{ }0.0_{ }' ...
    '^{ }0.5_{ }' '^{ }1.0_{ }' '^{ }1.5_{ }' '^{ }2.0_{ }' '^{ }2.5_{ }' '^{ }3.0_{ }'};

% Create subplots with spectrum locus
for w = 1:3
    % Setup subplot
    chromSubplotHandle(w) = subplot_tight(1,3,w,0.06); hold on;
    
    % Plot the spectrum locus on the diagram along.  The 1 nm spacing gives
    % the smooth line, and we add 10 nm spacing as yellow points.
    plot(T_stiles10_1nm_chrom(1,:)',T_stiles10_1nm_chrom(2,:)', ...
        'k','LineWidth',figParams.lineWidth-1);
    plot(T_stiles10_10nm_chrom(1,:)',T_stiles10_10nm_chrom(2,:)', ...
        'ko','MarkerFaceColor','k','MarkerSize',figParams.markerSize-figParams.subplotMarkerShrink-2)
end

%% Get dichromatic confusion lines
%
% A dichromat is missing one class of cones.  Stimuli that differ only in a
% way that is only visible to the missing class will look the same to the
% dichromat.  When the chromaticities of a set of stimuli confusable by a
% dichromat are plotted in a chromaticity diagram, they fall along a line.
% There are many such lines for each type of dichromat, each passing along
% a set of stimuli that are distinguishable.
%
% There are three classes of dichromats, protanopes (missing L cones),
% deuteranopes (missing M cones), and tritanopes (missing S cones).  We can
% compute confusion lines for each class.
%
% We do this by adding the stimuli in the cone isolating direction for the
% cone class the dichromat lacks to any stimulus, and varying the amount of
% cone isolating stimulus mixed in.  Here we'll do that starting with each
% stimulus on the spectrum locus, every 10 nm.
%
% These converge on the chromaticity of the isolating direction for each
% cone class. My intuition for this is that as you add more and more of the
% stimulus in the cone isolating direction, it dominates the tristimulus
% coordinates more and more, swamping whatever it was being added to.  In
% the limit, then, the chromaticity of the summed stimulus will be that of
% the cone isolating stimulus.

% Chromaticity of cone isolating directions
coneIsolatingRGBDirs_chrom = XYZToxyY(coneIsolatingRGBDirs);

% Set number of confusion lines to compute for each cone.
nConfusionLines = size(T_stiles10_10nm,2);

% Compute the confusion lines.
for w = 1:3
    % For each confusion line, we compute a set of points by adding
    % different magnitudes of the cone isolating tristimulus points to a
    % point on the spectrum locus.
    %
    % We have a hand tuned "length factor" set below for each class of
    % dichromat, that makes the lines a reasonable length in the plot.  For
    % the deuteranope, this factor is a negative number. The lines are the
    % same direction whether the factors are positive or negative, but the
    % projection onto the chromaticity diagram is uglier with a postive
    % factor for the deuteranope (or with a negative factor for the
    % protanope or tritanope).  I think this has to do with the direction
    % of the isolating vector in the tristimulus space and how it then
    % projects onto the chromaticity diagram, but have not really thought
    % through the projective geometry carefully.
    
    % Set length factors (and plot color) appropriately for each type of
    % dichromat.
    switch (w)
        case 1
            % Protanope
            whichConfusionColor = 'r';
            confusionLineLengthFactor = 2;
        case 2
            % Deuteranope
            whichConfusionColor = 'g';
            confusionLineLengthFactor = -3;
        case 3
            % Tritanope
            whichConfusionColor = 'b';
            confusionLineLengthFactor = 30;
    end
    
    % Here we compute the confusion lines themselves, using the length
    % factor defined above.
    %
    % Loop over points on spectrum locus
    for i = 1:nConfusionLines
        nConfusionPoints = 100;
        for j = 1:nConfusionPoints
            % Add varying degrees of cone isolating stimulus onto the
            % tristimulus values of the point on the spectrum locus.
            confusionLine{w,i}(:,j) = T_stiles10_10nm(:,i) + ...
                confusionLineLengthFactor*((j-1)/(nConfusionPoints-1))*coneIsolatingRGBDirs(:,w);
            
            % Convert to chromaticity
            confusionLine_chrom{w,i}(:,j) = XYZToxyY(confusionLine{w,i}(:,j));
        end
    end
end

% Add the cone isolating tristimulus chromaticities and confusion lines to
% the chromaticity plots, along with chromaticity of cone isolating
% directions.
%
% Note that for each type of dichromat, the confusion lines converge on the
% chromaticity of the missing cone's isolating tristimulus values.  One
% wayt to understand why this happens is that as we add in more and more of
% the cone isolating tristimulus values, these swamp the original
% tristimulus values of the point on the spectrum locus.  The length
% factors defined above were chosen to be large enough for the confusion
% lines to more or less reach the chromaticity of the cone isolating
% tristimulus values.
figure(chromaticityFig);
for w = 1:3
    % Grab the right subplot
    subplot(chromSubplotHandle(w));
    
    % Add cone isolating stimulus chromaticity for this subplot.  Note that
    % each of these is outside the spectrum locus.  Because these spectra
    % have negative power they are not physically realizable, and thus
    % cannot be produced by a convex combination of the monochromatic
    % lights on the spectrum locus.
    switch (w)
        case 1
            % Protanope
            whichConfusionColor = 'r';
            titleStr = 'Protan';
            
            plot([coneIsolatingRGBDirs_chrom(1,1)], ...
                [coneIsolatingRGBDirs_chrom(2,1)], ...
                'ro','MarkerFaceColor','r','MarkerSize',figParams.markerSize-figParams.subplotMarkerShrink);
        case 2
            % Deuteranope
            whichConfusionColor = 'g';
            titleStr = 'Deutan';
            plot([coneIsolatingRGBDirs_chrom(1,2)], ...
                [coneIsolatingRGBDirs_chrom(2,2)], ...
                'go','MarkerFaceColor','g','MarkerSize',figParams.markerSize-figParams.subplotMarkerShrink);
        case 3
            % Tritanope
            titleStr = 'Tritan';
            whichConfusionColor = 'b';
            plot([coneIsolatingRGBDirs_chrom(1,3)], ...
                [coneIsolatingRGBDirs_chrom(2,3)], ...
                'bo','MarkerFaceColor','b','MarkerSize',figParams.markerSize-figParams.subplotMarkerShrink);
    end
    
    % Add confusion line
    for i = 1:size(T_stiles10_10nm,2)
        plot(confusionLine_chrom{w,i}(1,:),confusionLine_chrom{w,i}(2,:),whichConfusionColor,...
            'LineWidth',1);
    end
    
    % Tidy up labels
    xlabel('r','FontSize',figParams.labelFontSize-figParams.subplotFontShrink);
    ylabel('g','FontSize',figParams.labelFontSize-figParams.subplotFontShrink);
    title(titleStr,'FontSize',figParams.titleFontSize-figParams.subplotFontShrink);
    axis('square');
    cbFigAxisSet(chromSubplotHandle(w),figParams);
    set(gca,'FontName',figParams.fontName,'FontSize', ...
        figParams.axisFontSize-figParams.subplotFontShrink,'LineWidth',1);
end

%% Find the cone sensitivity vectors in RGB tristimulus space.
%
% These are unit vectors such that when you project onto them, you get the
% L, M, and S responses.  When we work in cone space, thesr are just the
% unit vectors, which are conceptually best expressed as row vectors, since
% then multiplying tristimulus coordinates from the left with such a vector
% directly gives cone excitation.
%
% Having these vectors is useful in cases where we know the stimulus in
% tristimulus coordinates and want to get the cone excitations.  We don't
% often work in Stiles-Burch rgb these days, but we do often specify
% stimuli in a tristimulus space defined by the three primaries of a
% display, and the ideas for that case are exactly the same.
%
% Since cone excitations themselves must be independent of the space we
% compute them in, we seek a row vector r such that r*t = u*c, where r is
% the response row vector in tristimulus RGB, t is the tristimulus column
% vector representing a stimulus, u is a unit row vector in LMS cone space
% and c is a cone excitation column vector.  We also have t = M*c with M
% being the M_ConesToCmf computed above. Since this holds for any choice of
% c, we have r*M = u, which leads to r = u*M_inv = u*M_CmfToCones. Note
% that r does not necessarily have unit length -- it is only in the cone
% excitation space where the response vectors are guaranteed to be the unit
% vectors and to have unit length.
%
% Also produce normalized version for plotting.
coneResponseRGBVectors = [ [1 0 0] ; [0 1 0] ; [0 0 1] ]*M_CmfToCones;

% Check.  Generate a bunch of random spectra as linear combinations of the
% color matching primaries, and compute cone responses directly from
% fundamentals and from the tristimulus values.  Works as advertised.
randomTristim = rand(3,100);
randomSpectra = B_1nm*randomTristim;
randomConeExcitationsDirect = T_cones10_1nm*randomSpectra;
randomConeExcitationsFromTristim = coneResponseRGBVectors*randomTristim;
tolerance = 0.01;
if (max(abs(randomConeExcitationsDirect(:)-randomConeExcitationsFromTristim(:))) > tolerance)
    error('Cone response vector check fails');
end

%% More on cone isolating stimuli and sensitivity vectors.
%
% Here's another way to think about this, or perhaps the same way expressed
% differently. We have two color spaces to represent stimuli here, the RGB
% tristimulus space and the LMS cone space.
%
% Let's suppose we have a vector of cone excitations with values [l m s]'.
% This is a point in cone space.  In LMS cone space, the sensitivity vectors
% for the L, M, and S cones are trivial to write down.  The L cone
% sensitivity is the vector [1 0 0], the M cone is [0 1 0], and the S cone
% is [0 0 1].  For each of these vectors, taking the dot product of the
% senstiity vector and the stimulus representation in cone space yields the
% coorresponding excitation.  For example, [1 0 0]*[l m s]' = l, etc.
%
% In addition, the cone isolating vectors of unit length are trivial to
% write down in cne space. These are [1 0 0]', [0 1 0]', and [0 0 1]'.
% Adding each of these vectors to any stimulus in cone space only affects
% the responses of one class of cones.
%
% We can stack the cone sensitivity vectors into the rows of a matrix, and we
% get the identity matrix [ [1 0 0] ; [0 1 0] ; [0 0 1] ].  Similary, we
% can stack the cone isolating directions into the columns of a matrix
% [[1 0 0]', [0 1 0]', [0 0 1]'].  Both of these are the identity matrix,
% where in one case we interpret the rows and in the other the columns.
% Mulitplying the cone sensitivty matrix into the cone isolating directions
% matrix gives the identity back.  Each column of this matrix is the cone
% excitations for the corresponding isolating direction, in each case with
% one cone excited to 1 and the other two silent.  So far just a lot of
% multiplying the indentiy matrix.
%
% Now we're going to think through the same calculations in the RGB
% tristimulus space.
%
% We know how to transform stimuli from LMS cone space to RGB tristimulus
% space, from the work we did above.  So the three cone isolating
% directions in RGB space are given by
%     coneIsolatingRGBDirs = M_ConesToCmf*[[1 0 0]', [0 1 0]', [0 0 1]'];
% from the work we did above.
%
% We've also argued above that the sensitivity vectors are obtained as
%     coneResponseRGBVectors = [ [1 0 0] ; [0 1 0] ; [0 0 1]]*M_CmfToCones;
%
% It better be the case that if we compute the cone excitations of the same
% stimuli in RGB space, we get the same answer as we do if we compute them
% in cone space - the excitations to a stimulus are not property of the
% space we use to represent things.  We already know these better come out
% to be the identity matrix, so let's check:
[ [1 0 0] ; [0 1 0] ; [0 0 1] ]*M_CmfToCones*M_ConesToCmf*[[1 0 0]', [0 1 0]', [0 0 1]']

% Yep!  Examining this tells us that to transform stimuli we multiply from
% the left by M_ConesToCmf, with the stimuli in the columns in both the
% input and the output of the calculation.
%
% But to transform sensitivities, we multiply from the right with the
% sensitivies in the rows in both the input and the output.
%
% We'll visualize the result of this in RGB tristimulus space below.

%% 3D RGB plot of cone response vectors and isolating dirs.
%
% This plot shows the orthogonality between cone isolating vectors
% for one cone class and the response vectors for the other two.  To keep
% the plot simple, we illustrate with the L cone isolating direction and
% the M and S cone sensitivities.
%
% Here the isolating directions are shown as solid and the response
% sensitivities as dashed.
[stilesBurch10ConeIsolatingFig,figParams] = cbFigInit;
figParams.xLimLow = -1;
figParams.xLimHigh = 1;
figParams.xTicks = [-1 0 1];
figParams.xTickLabels = {'-1.0 ' ' 0.0 ' ' 1.0 '};
figParams.yLimLow = -1;
figParams.yLimHigh = 1;
figParams.yTicks = [-1 0 1];
figParams.yTickLabels = {'-1.0 ' ' 0.0 ' ' 1.0 '};
figParams.zLimLow = -1;
figParams.zLimHigh = 1;
figParams.zTicks = [-1 0 1];
figParams.zTickLabels = {'-1.0 ' ' 0.0 ' ' 1.0 '};

% Put a point at the origin just so that is easy to see
plot3(0,0,0,'ko','MarkerFaceColor','k','MarkerSize',12);

% Get normalized versions of isolating directions and sensitivities.  This
% makes the plot a little cleaner.
% Normalize
for i = 1:size(coneResponseRGBVectors,1)
    % Response vectors are in the rows, normalize rows
    coneResponseRGBVectorsNorm(i,:) = coneResponseRGBVectors(i,:)/vecnorm(coneResponseRGBVectors(i,:));
    
    % Stimuli are in the columns, normalize columns
    coneIsolatingRGBDirsNorm(:,i) = coneIsolatingRGBDirs(:,i)/vecnorm(coneIsolatingRGBDirs(:,i));
end

% Plot the normalized L cone isolating direction.  We draw the line between
% positive and negative excursions in this direction, to make it symmetric
% around the origin.
plot3([-coneIsolatingRGBDirsNorm(1,1) coneIsolatingRGBDirsNorm(1,1)], ...
    [-coneIsolatingRGBDirsNorm(2,1) coneIsolatingRGBDirsNorm(2,1)], ...
    [-coneIsolatingRGBDirsNorm(3,1) coneIsolatingRGBDirsNorm(3,1)], ...
    'r','LineWidth',figParams.lineWidth+1);

% Add in the M and S cone sensivities.  These should be orthogonal to the L
% cone isolating direction.
plot3([-coneResponseRGBVectorsNorm(2,1) coneResponseRGBVectorsNorm(2,1)], ...
    [-coneResponseRGBVectorsNorm(2,2) coneResponseRGBVectorsNorm(2,2)], ...
    [-coneResponseRGBVectorsNorm(2,3) coneResponseRGBVectorsNorm(2,3)], ...
    'g:','LineWidth',figParams.lineWidth+1);
plot3([-coneResponseRGBVectorsNorm(3,1) coneResponseRGBVectorsNorm(3,1)], ...
    [-coneResponseRGBVectorsNorm(3,2) coneResponseRGBVectorsNorm(3,2)], ...
    [-coneResponseRGBVectorsNorm(3,3) coneResponseRGBVectorsNorm(3,3)], ...
    'b:','LineWidth',figParams.lineWidth+1);

% Fill in the plane that contains the M and S response vectors.
% This should be orthogonal to the L cone isolating direction. Having the
% plane makes it a bit easier to visualize.
fill3([-coneResponseRGBVectorsNorm(2,1)-coneResponseRGBVectorsNorm(3,1) ...
    -coneResponseRGBVectorsNorm(2,1)+coneResponseRGBVectorsNorm(3,1) ...
    coneResponseRGBVectorsNorm(2,1)+coneResponseRGBVectorsNorm(3,1) ...
    coneResponseRGBVectorsNorm(2,1)-coneResponseRGBVectorsNorm(3,1) ...
    ]',...
    [-coneResponseRGBVectorsNorm(2,2)-coneResponseRGBVectorsNorm(3,2) ...
    -coneResponseRGBVectorsNorm(2,2)+coneResponseRGBVectorsNorm(3,2) ...
    coneResponseRGBVectorsNorm(2,2)+coneResponseRGBVectorsNorm(3,2) ...
    coneResponseRGBVectorsNorm(2,2)-coneResponseRGBVectorsNorm(3,2) ...
    ]',...
    [-coneResponseRGBVectorsNorm(2,3)-coneResponseRGBVectorsNorm(3,3) ...
    -coneResponseRGBVectorsNorm(2,3)+coneResponseRGBVectorsNorm(3,3) ...
    coneResponseRGBVectorsNorm(2,3)+coneResponseRGBVectorsNorm(3,3) ...
    coneResponseRGBVectorsNorm(2,3)-coneResponseRGBVectorsNorm(3,3) ...
    ]',...
    [0 0.25 0.25],'EdgeColor','None','FaceAlpha',0.25);

% Verify orthogonality between L isolating and M/S sensitivity, which is a bit hard to judge in the figure
angleLM = acosd(coneResponseRGBVectorsNorm(2,:)*coneIsolatingRGBDirsNorm(:,1));
fprintf('Angle between L cone isolating and M cone sensitivity vectors: %0.0f degrees\n',angleLM);
angleLS = acosd(coneResponseRGBVectorsNorm(3,:)*coneIsolatingRGBDirsNorm(:,1));
fprintf('Angle between L cone isolating and S cone sensitivity vectors: %0.0f degrees\n',angleLS);

% Add the L cone sensitivity.  This is not orthogonal to anything here.
% The projection onto this sensitivity gives the L cone response, so it is
% a good thing it isn't orthogonal, otherwise the L cones wouldn't see the
% L cone isolating stimulus.
%
% Note also that there is no reason the L cone sensitivity needs to have
% any particular relation to the M and S cone sensitivities.
plot3([-coneResponseRGBVectorsNorm(1,1) coneResponseRGBVectorsNorm(1,1)], ...
    [-coneResponseRGBVectorsNorm(1,2) coneResponseRGBVectorsNorm(1,2)], ...
    [-coneResponseRGBVectorsNorm(1,3) coneResponseRGBVectorsNorm(1,3)], ...
    'r:','LineWidth',figParams.lineWidth+1);

% Verify non-orthogonality of L cone isolating direction and L cone
% sensitivity. If these were orthogonal (90 degrees), the L cone isolating
% direction would have no effect on the L cones. 
angleLL = acosd(coneResponseRGBVectorsNorm(1,:)*coneIsolatingRGBDirsNorm(:,1));
fprintf('Angle between L cone isolating and L cone sensitivity vectors: %0.0f degrees\n',angleLL);

% Labels
xlabel('R','FontSize',figParams.labelFontSize);
ylabel('G','FontSize',figParams.labelFontSize);
zlabel('B','FontSize',figParams.labelFontSize);
title('Cone Isolating and Response Vectors','FontSize',figParams.titleFontSize);
cbFigAxisSet(stilesBurch10ConeIsolatingFig,figParams);
zlim([figParams.zLimLow figParams.zLimHigh]);
set(gca,'ZTick',figParams.zTicks);
set(gca,'ZTickLabel',figParams.zTickLabels);
set(gca,'XDir','Reverse');
set(gca,'YDir','Reverse');
az = -51; el = 34; view(az,el);
grid on





