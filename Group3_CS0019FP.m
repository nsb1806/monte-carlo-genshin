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
% Assigned to: Oblan

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
% Assigned to: Butaslac

% implement scenario loops using the function: simulatePlayerPullSession()


% ------------------ 3: STATISTICAL METRICS  -----------------
% Assigned to: Cueto

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
% Assigned to: Munsayac

% Cumulative Distribution Function (CDF) Plot w/ annotation


% ------------------ 5: PULL SESSION FUNCTION -----------------
% Assigned to: Butaslac

function [totalPulls, totalSpent] = simulatePlayerPullSession (startingPity, startingBudget)
% Function to simulate single player session
% Tracking variables: pullsCount, pity, moneySpent, charAcquired,
% charGuaranteed, totalPulls, totalSpent