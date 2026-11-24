% CS0019: Final Project
% CODE BLUEPRINT & TASKS

clc;
clear;

%----- RULES % CONSTANT VARIABLES FOR GENSHIN PITY SYSTEM ------

% Declare global constants before assigning values 
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
GUARANTEED_PULLS = 180;
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
startingBudget = input('Budget: ');
if isempty(startingBudget), startingBudget = 0; end

freePulls = floor(startingPrimogems / PRIMOGEMS_PER_PULL)

% Simulation results / SCENARIO 
fprintf('===================================================\n');
fprintf('                      GOTCHA-PON                   \n');
fprintf('    A Monte-Carlo Simulation of the Pity System    \n');
fprintf('                  in Genshin Impact                \n');
fprintf('===================================================\n');
fprintf('Number of simulated sessions: %d\n', numSimulations)
% Display Banner rules
fprintf('===================================================\n');
fprintf('             CHARACTER BANNER RULES (5*)           \n');
fprintf('===================================================\n');
fprintf('5* Pity System:\n');
fprintf('If a player does not obtain any 5* character after 89\n');
fprintf('wishes, the 90th wish is guaranteed to be a 5* character.\n');
fprintf('   - This counter will reset if the player obtains any 5* character\n\n');
fprintf('When a player has not obtained any 5* on their 74th wish, a hidden mechanic\n');
fprintf('called ''Soft Pity'' increases the player''s chances of obtaining a 5* by\n');
fprintf('6%% for each pull starting from the 75th wish until the player obtains.\n');
fprintf('a 5* character.\n\n');
fprintf('Every time a player obtains a 5* character, there is a 50%%\n');
fprintf('chance it will be the promotional 5* character.\n');
fprintf('   - If the 5* character obtained is not the promotional character,\n')
fprintf('       the next 5* character is guaranteed to be the promotional character.\n\n');
fprintf('Each wish of the same type shares the same pity counters and guarantees,\n');
fprintf('meaning that the pity counter for the current limited character banner\n');
fprintf('are carried over to the next limited character banner.\n\n');
fprintf('1 Wish = 160 Primogems; 10 Wishes = 1600 Primogems\n\n')

% Display player state (starting pity, primogems, and budget)
fprintf('---------------------------------------------------\n');
fprintf('Starting Pity: %d\n', startingPity);
fprintf('Primogems: %d\n', startingPrimogems);
fprintf('Budget: %d\n', startingBudget);

% ------------------ 2: MONTE CARLO LOOP -----------------

pullsResults = zeros(1, numSimulations);
spentResults = zeros(1, numSimulations);
successResults = false(1, numSimulations);

for indexSim = 1:numSimulations 
    [pullsResults(indexSim), spentResults(indexSim), successResults(indexSim)] = ...
        simulatePlayerPullSession(startingPity, startingBudget, ...
        freePulls);
end

% ------------------ 3: STATISTICAL METRICS  -----------------
% Compute Statistical Metrics
% variables: averagePulls, averageSpent

% Target Cumulative Percentiles (probability thresholds)
% 50%, 80%, 90%, 99% success threshold

averagePulls = mean(pullsResults);
averageSpent = mean(spentResults);
successRate = mean(successResults);

% Target Cumulative Percentiles (probability thresholds)
percentiles = [50, 80, 90, 99];
pullThresholds = prctile(pullsResults, percentiles);
spentThresholds = prctile(spentResults, percentiles);

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


% ------------------ 5: PULL SESSION FUNCTION -----------------

function [totalPulls, totalSpent, charAcquired] = ...
    simulatePlayerPullSession(startingPity, startingBudget, freePulls)

    global PRIMOGEMS_PER_PULL PHP_PER_CRYSTAL COST_PER_PULL ... 
        BASE_PULL_PROB SOFT_PITY_START HARD_PITY_LIMIT SOFT_PITY_INCREMENT ... 
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
            if startingBudget > 0 && (moneySpent + pullCost) > startingBudget
                break;
            end
        end

        pullsCount = pullsCount + 1;
        pity = pity + 1;
        moneySpent = moneySpent + pullCost;
        
        % calculate 5 star probability for one pull
        if pity < SOFT_PITY_START
            currentProbability = BASE_PULL_PROB;
        elseif pity >= SOFT_PITY_START && pity < HARD_PITY_LIMIT
            currentProbability = min(1.0, BASE_PULL_PROB + SOFT_PITY_INCREMENT * (pity - SOFT_PITY_START));
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