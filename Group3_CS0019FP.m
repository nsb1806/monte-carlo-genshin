% CS0019: Final Project
% Monte-Carlo Simulation of the Genshin Impact Pity System

clc;
clear;

%----- RULES % CONSTANT VARIABLES FOR GENSHIN PITY SYSTEM ------

global PRIMOGEMS_PER_PULL PHP_PER_CRYSTAL COST_PER_PULL ... 
    BASE_PULL_PROB SOFT_PITY_START HARD_PITY_LIMIT SOFT_PITY_INCREMENT ... 
    MAX_PULLS FIFTY_FIFTY_CHANCE;

% Currency
PRIMOGEMS_PER_PULL = 160;
PHP_PER_CRYSTAL = 0.85;
COST_PER_PULL = PRIMOGEMS_PER_PULL * PHP_PER_CRYSTAL;

% 5-Star Character Pity Mechanics
BASE_PULL_PROB = 0.006;
SOFT_PITY_START = 74;
HARD_PITY_LIMIT = 90;
SOFT_PITY_INCREMENT = 0.06;

% Banner Guarantee Mechanics
MAX_PULLS = 180;
FIFTY_FIFTY_CHANCE = 0.50;

% ------------------ 1: GLOBAL CONFIGURATION -----------------

% Simulation Parameters
numSimulations = 20000;

fprintf('===================================================\n');
fprintf('        Banner Configuration & Player State        \n');
fprintf('===================================================\n');
startingPity = input('Starting Pity: ');
if isempty(startingPity), startingPity = 0; end
startingPrimogems = input('Primogems: ');
if isempty(startingPrimogems), startingPrimogems = 0; end
startingBudget = input('Budget (enter -1 for unlimited): ');
if isempty(startingBudget)
    startingBudget = -1;
end

freePulls = floor(startingPrimogems / PRIMOGEMS_PER_PULL);

% Simulation results / SCENARIO 
fprintf('===================================================\n');
fprintf('                      GOTCHA-PON                   \n');
fprintf('    A Monte-Carlo Simulation of the Pity System    \n');
fprintf('                  in Genshin Impact                \n');
fprintf('===================================================\n');
fprintf('Number of simulated sessions: %d\n', numSimulations);
fprintf('Starting Pity: %d\n', startingPity);
fprintf('Primogems: %d (=> %d free pulls)\n', startingPrimogems, freePulls);
if startingBudget < 0
    startingBudget = Inf;
    fprintf('Budget: Unlimited\n');
else
    fprintf('Budget: %.2f PHP\n', startingBudget);
end

% Display Banner rules
fprintf('===================================================\n');
fprintf('          CHARACTER BANNER RULES (5-STAR)          \n');
fprintf('===================================================\n');
fprintf('5* Pity System:\n');
fprintf('   If a player does not obtain any 5* character after\n');
fprintf('   89 wishes, the 90th wish is guaranteed to be a 5*\n');
fprintf('   character.\n');
fprintf('   - This counter will reset if the player obtains\n');
fprintf('     any 5* character\n\n');
fprintf('   When a player has not obtained any 5* on their 74th\n');
fprintf('   wish, a hidden mechanic called ''Soft Pity''\n');
fprintf('   increases the player''s chances of obtaining a 5* by\n');
fprintf('   6%% for each pull starting from the 74th wish until\n');
fprintf('   the player obtains a 5* character\n\n');
fprintf('   Every time a player obtains a 5* character, there is\n');
fprintf('   a 50%% chance it will be the promotional 5* character.\n');
fprintf('   - If the 5* character obtained is not the \n');
fprintf('     promotional character, the next 5* character is\n');
fprintf('     guaranteed to be the promotional character.\n\n');
fprintf('   Each wish of the same type shares the same pity\n');
fprintf('   counters and guarantees, meaning the pity counter\n');
fprintf('   and guarantee for the current limited character\n');
fprintf('   banner carry over to the next limited character\n');
fprintf('   banner\n');
fprintf('   1 Wish = 160 Primogems; 10 Wishes = 1600 Primogems\n\n');

% ------------------ 2: MONTE CARLO LOOP -----------------

pullsResults = zeros(1, numSimulations);
spentResults = zeros(1, numSimulations);
successResults = false(1, numSimulations);

for indexSim = 1:numSimulations 
    [pullsResults(indexSim), spentResults(indexSim), successResults(indexSim)] = ...
        simulatePlayerPullSession(startingPity, startingBudget, freePulls);
end

% ------------------ 3: STATISTICAL METRICS  -----------------
% Compute Statistical Metrics
averagePulls = mean(pullsResults);
averageSpent = mean(spentResults);
successRate = mean(successResults);

% Target Cumulative Percentiles (probability thresholds)
percentiles = [50, 80, 90, 99];
pullThresholds = prctile(pullsResults(successResults), percentiles);
spentThresholds = prctile(spentResults(successResults), percentiles);

% Display Statistical Results
fprintf('===================================================\n');
fprintf('                 STATISTICAL RESULTS               \n');
fprintf('===================================================\n');
% Display average pulls and average money spent
fprintf('---------------------------------------------------\n');
fprintf('Average Pulls         : %.2f\n', averagePulls);
fprintf('Average Money Spent  : %.2f PHP\n', averageSpent);
fprintf('Session Success Rate : %.2f%%\n', successRate * 100);
% Display cumulative probability thresholds
fprintf('---------------------------------------------------\n');
for i = 1:length(percentiles)
    fprintf('%.0f%% Success Threshold - Pulls: %d, Money Spent: %.2f PHP\n', ...
        percentiles(i), pullThresholds(i), spentThresholds(i));
end
% ------------------ 4: VISUALIZATION & CDF PLOT -----------------

% Cumulative Distribution Function (CDF) Plot w/ annotation
successCosts = spentResults(successResults);
successPulls = pullsResults(successResults);

if isempty(successCosts)
    fprintf('\nNo successful sessions - CDF cannot be plotted.\n');
    return;
end

% Sort ascending and compute empirical CDF (capped at overall success rate)
[successCosts, order] = sort(successCosts);
successPulls = successPulls(order);
cdfProb = (1:numel(successCosts)) / numSimulations * 100;

figure('Name', 'Gotcha-Pon CDF', 'Color', 'w');
stairs([0, successCosts], [0, cdfProb], 'LineWidth', 2, 'Color', [0 0.45 0.74]);
hold on; grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'GridColor', [0.8 0.8 0.8]);

% Mark confidence thresholds 
xMax = max(successCosts);
for p = percentiles
    idx = find(cdfProb >= p, 1, 'first');
    if isempty(idx), continue; end

    x = successCosts(idx);
    plot([0 x x], [p p 0], '--', 'Color', [0.5 0.5 0.5]);
    plot(x, p, 'o', 'MarkerSize', 7, 'MarkerFaceColor', [0 0.45 0.74], 'MarkerEdgeColor', 'k');
    text(x + 0.015 * xMax, p - 2.5, ...
        sprintf('%d%%: %d PHP (%d pulls)', p, round(x), successPulls(idx)), ...
        'FontSize', 9, 'Color', 'k', 'BackgroundColor', 'w', 'EdgeColor', [0.7 0.7 0.7]);
end

% Mark budget cap if set
if isfinite(startingBudget)
    xline(startingBudget, '-.r', sprintf('Budget: %.0f PHP', startingBudget), ...
        'LineWidth', 1.5, 'LabelVerticalAlignment', 'bottom');
    budgetLabel = sprintf('%.0f PHP', startingBudget);
else
    budgetLabel = 'unlimited';
end

% Labels and limits
title('Gotcha-Pon: Cumulative Probability of Obtaining Featured 5*', 'Color', 'k');
subtitle(sprintf('Pity: %d | Primogems: %d | Budget: %s | Overall Success: %.2f%%', ...
    startingPity, startingPrimogems, budgetLabel, cdfProb(end)), 'Color', [0.2 0.2 0.2]);
xlabel('Money Spent (PHP)', 'Color', 'k');
ylabel('Cumulative Probability (%)', 'Color', 'k');
xlim([0, max(xMax * 1.35, 1)]);
ylim([0, 100]);
yticks(0:10:100);
ax = gca;
ax.XAxis.Exponent = 0;
xtickformat('%,.0f');
hold off;

% ------------------ 5: PULL SESSION FUNCTION -----------------

function [totalPulls, totalSpent, charAcquired] = ...
    simulatePlayerPullSession(startingPity, startingBudget, freePulls)

    global COST_PER_PULL BASE_PULL_PROB SOFT_PITY_START HARD_PITY_LIMIT SOFT_PITY_INCREMENT ... 
        MAX_PULLS FIFTY_FIFTY_CHANCE;

    pullsCount = 0;             % pulls done in this session
    pity = startingPity;        % pity counter
    moneySpent = 0;             
    freePullsRemaining = freePulls;
    charAcquired = false;       % featured 5 star character obtained?
    charGuaranteed = false;     % lost 50/50?

    % increment the counters per pull
    while ~charAcquired && pullsCount < MAX_PULLS 
        if freePullsRemaining > 0
            freePullsRemaining = freePullsRemaining - 1;
            pullCost = 0;
        else
            pullCost = COST_PER_PULL;
            if isfinite(startingBudget) && (moneySpent + pullCost) > startingBudget
                break;
            end
        end

        pullsCount = pullsCount + 1;
        pity = pity + 1;
        moneySpent = moneySpent + pullCost;
        
        % calculate 5 star probability for one pull
        if pity < SOFT_PITY_START
            currentProbability = BASE_PULL_PROB;
        elseif pity < HARD_PITY_LIMIT
            currentProbability = min(1.0, BASE_PULL_PROB + ...
                SOFT_PITY_INCREMENT * (pity - SOFT_PITY_START + 1));
        else
            currentProbability = 1.0;       % hard pity guarantee
        end

        %rolling for 5-star
        if rand() < currentProbability
            pity = 0;         % resets if 5 star acquired
            if charGuaranteed || rand() < FIFTY_FIFTY_CHANCE
                charAcquired = true;      % featured 5-star character obtained
            else
                charGuaranteed = true;    % lost 50/50; next 5 star is guaranteed
            end
        end
    end

    % return values
    totalPulls = pullsCount;
    totalSpent = moneySpent;
end