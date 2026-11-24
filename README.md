# Gotcha-Pon: A Monte Carlo Simulation of the Pity System in Genshin Impact

A MATLAB simulation of a randomized gacha pull engine modeling 5-star character banner mechanics—including base pull probability, soft pity scaling, a hard pity cap, and the 50/50 promotional character guarantee—across thousands of automated player pulling sessions to evaluate pull counts, PHP expenditures, success rates, and cumulative probability thresholds under configurable starting pity, Primogems, and budget. 

### Features:
* **Configurable Player State & Banner Constants**: Prompts for starting pity, starting Primogems, and PHP budget (defaulting to 0 if left blank), while converting Primogems into free pulls (160 Primogems per pull) and pricing paid pulls at 136.00 PHP (160 * 0.85).
* **5-Star Pity, Soft Pity & 50/50 Guarantee Logic:** Models a 0.6% base pull rate, ramping probability starting at pity 74, a 100% hard pity guarantee at 90, and a 50% promotional win rate (with a guaranteed featured 5-star on the next 5-star if lost).
* **20,000-Session Monte Carlo Evaluation:** Simulates numSimulations = 20000 independent pull sessions (capped at MAX_PULLS = 180 pulls per session) and computes average pulls, average PHP spent, session success rate, and 50%, 80%, 90%, and 99% percentile thresholds.

### Groups:
* Butaslac, NJ
* Cueto, Janine Mae
* Munsayac, Jilliane Margaret
* Oblan, Neo Achiless

## Run Instructions
1. Open the project .m script in MATLAB
2. Run the script and enter values when prompted for Starting Pity, Primogems, and Budget (or press Enter to default each to 0).
3. Review the printed banner rules, player state summary, and Monte Carlo statistical results in the Command Window.
4. Implement Section 4 (Visualization & CDF Plot) to generate and annotate the Cumulative Distribution Function plot.

## Sample Output
```
===================================================
        Banner Configuration & Player State        
===================================================
Starting Pity: 0
Primogems: 0
Budget: 0
===================================================
                      GOTCHA-PON                   
    A Monte-Carlo Simulation of the Pity System    
                  in Genshin Impact                
===================================================
Number of simulated sessions: 20000
===================================================
             CHARACTER BANNER RULES (5*)           
===================================================
...
---------------------------------------------------
Starting Pity: 0
Primogems: 0
Budget: 0
===================================================
                 STATISTICAL RESULTS               
===================================================
---------------------------------------------------
Average Pulls         : 
Average Money Spent  : 
Session Success Rate : 
---------------------------------------------------
50% Success Threshold - Pulls: , Money Spent:  PHP
80% Success Threshold - Pulls: , Money Spent:  PHP
90% Success Threshold - Pulls: , Money Spent:  PHP
99% Success Threshold - Pulls: , Money Spent:  PHP
```

## Roles & System Outline
Programming Language: MATLAB <br>
Compiler: MATLAB <br>
IDE: MATLAB <br>

1. Global Configuration 
   - Coded by: Oblan
   - Initializes workspace (clc; clear;), global pity/cost constants, simulation count (20000), interactive player inputs, and banner rule output
     - Converts startingPrimogems into freePulls via floor(startingPrimogems / PRIMOGEMS_PER_PULL)
     - Sets COST_PER_PULL = PRIMOGEMS_PER_PULL * PHP_PER_CRYSTAL (136 PHP)
     - Prints character banner mechanics and starting player state
2. Monte Carlo Loop
   - Coded by: Butaslac
   - Preallocates result vectors and runs simulatePlayerPullSession across 20,000 iterations
     - Tracks pullsResults, spentResults, and successResults per session
     - Passes startingPity, startingBudget, and freePulls into each simulation run
     - Stops each session once the featured 5-star is acquired, MAX_PULLS (180) is reached, or paid budget is exceeded
3. Statistical Metrics
   - Coded by: Cueto
   - Aggregates simulation outcomes into summary statistics and percentile thresholds
     - Computes averagePulls, averageSpent, and successRate using mean(...)
     - Computes 50%, 80%, 90%, and 99% thresholds for pulls and PHP spent via prctile(..., [50, 80, 90, 99])
   - Prints formatted statistical metrics and thresholds to the console
4. Visualization & CDF
   - Coded by: Munsayac
   - Plots and annotates the empirical Cumulative Distribution Function (CDF) of PHP spent for successful sessions
     - Filters spentResults and pullsResults using successResults (successCosts, successPulls), sorts costs ascending, and computes cdfProb scaled to 0–100% across numSimulations
     - Renders a white-themed step plot (stairs) with threshold markers and text callouts for 50%, 80%, 90%, and 99% confidence levels
     - Draws a vertical budget reference line (xline) when startingBudget is finite, formats axes/ticks, and sets the title and subtitle summary

## Coding Standards
Functions
* simulatePlayerPullSession(startingPity, startingBudget, freePulls) — Returns [totalPulls, totalSpent, charAcquired] for one simulated pull session.

Variables
* Global Constants:
  * PRIMOGEMS_PER_PULL (160)
  * PHP_PER_CRYSTAL (0.85)
  * COST_PER_PULL (136, calculated from PRIMOGEMS_PER_PULL * PHP_PER_CRYSTAL)
  * BASE_PULL_PROB (0.006)
  * SOFT_PITY_START (74)
  * HARD_PITY_LIMIT (90)
  * SOFT_PITY_INCREMENT (0.06)
  * MAX_PULLS (180)
  * FIFTY_FIFTY_CHANCE (0.50)
* Script and Visualization Variables
  * numSimulations (20000)
  * startingPity
  * startingPrimogems
  * startingBudget (Inf when entered as -1 or empty)
  * freePulls
  * pullsResults
  * spentResults
  * successResults
  * indexSim (loop counter 1:numSimulations)
  * averagePulls
  * averageSpent
  * successRate
  * percentiles ([50, 80, 90, 99])
  * pullThresholds
  * spentThresholds
  * i (loop counter 1:length(percentiles))
  * successCosts
  * successPulls
  * order
  * cdfProb
  * xMax
  * p (loop counter over percentiles)
  * idx
  * x
  * budgetLabel
  * ax

Function Parameters, Return Variables & Local Variables (simulatePlayerPullSession)
* Inputs: startingPity, startingBudget, freePulls
* Output: totalPulls, totalSpent, charAcquired
* Locals: pullsCount, pity, moneySpent, freePullsRemaining, charGuaranteed, pullCost, currentProbability