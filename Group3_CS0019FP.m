% CS0019: Final Project
% CODE BLUEPRINT & TASKS

clc;
clear;

%----- RULES % CONSTANT VARIABLES FOR GENSHIN PITY SYSTEM ------

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

% Initialize User Inputs: (Default is 0)
% startingPity | startingBudget | startingPrimogems
fprintf('===================================================\n');
fprintf('        Banner Configuration & Player State        \n');
fprintf('===================================================\n');


% Simulation results / SCENARIO 
fprintf('===================================================\n');
fprintf('                      GOTCHA-PON                   \n');
fprintf('    A Monte-Carlo Simulation of the Pity System    \n');
fprintf('                  in Genshin Impact                \n');
fprintf('===================================================\n');
fprintf('Number of simulated sessions: %d\n', numSimulations)
% Display Banner rules
fprintf('---------------------------------------------------\n');
% Display player state (starting pity, primogems, and budget)
fprintf('---------------------------------------------------\n');

% ------------------ 2: MONTE CARLO LOOP -----------------

pullsResults = zeros(1, numSimulations);
spentResults = zeros(1, numSimulations);

for indexSim = 1:numSimulations 
    [pullsResults(indexSim), spentResults(indexSim)] = ...
        simulatePlayerPullSession(startingPity, startingBudget);
end

% ------------------ 3: STATISTICAL METRICS  -----------------
% Compute Statistical Metrics
% variables: averagePulls, averageSpent

% Target Cumulative Percentiles (probability thresholds)
% 50%, 80%, 90%, 99% success threshold

% Display Statistical Results
fprintf('===================================================\n');
fprintf('                 STATISTICAL RESULTS               \n');
fprintf('===================================================\n');
% Display average pulls and average money spent
fprintf('---------------------------------------------------\n');
% Display cumulative probability thresholds
fprintf('---------------------------------------------------\n');

% ------------------ 4: VISUALIZATION & CDF PLOT -----------------

% Cumulative Distribution Function (CDF) Plot w/ annotation


% ------------------ 5: PULL SESSION FUNCTION -----------------

function [totalPulls, totalSpent] = simulatePlayerPullSession(startingPity, startingBudget)
    pullsCount = 0;             % pulls done in this session
    pity = startingPity;        % pity counter
    moneySpent = 0;             
    charAcquired = false;       % featured 5 star character obtained?
    charGuaranteed = false;     % lost 50/50?

    % increment the counters per pull
    while ~charAcquired && pullsCount < MAX_PULLS && ...
            moneySpent + COST_PER_PULL <= startingBudget
        pullsCount = pullsCount + 1;
        pity = pity + 1;
        moneySpent = moneySpent + COST_PER_PULL;
        
        % calculate 5 star probability for one pull
        if pity <= SOFT_PITY_START
            currentProbability = BASE_PULL_PROB;
        elseif pity > SOFT_PITY_START && pity < HARD_PITY_LIMIT
            currentProbability = min(1, BASE_PULL_PROB + SOFT_PITY_INCREMENT * (pity - SOFT_PITY_START));
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