function [MinCost, execution_time1] = PufferfishOptimization(ProblemFunction, DisplayFlag, RandSeed)
tic;

if ~exist('ProblemFunction', 'var')
    ProblemFunction = @Ackley;
end
if ~exist('DisplayFlag', 'var')
    DisplayFlag = true;
end
if ~exist('RandSeed', 'var')
    RandSeed = round(sum(100*clock));
end

[InitFunction, CostFunction, FeasibleFunction] = Ackley;
[OPTIONS, MinCost, AvgCost, InitFunction, CostFunction, FeasibleFunction, ...
    MaxParValue, MinParValue, Population] = Init(DisplayFlag, ProblemFunction, RandSeed);
Keep = 2;
maxStepSize = 1.0;        
partition = OPTIONS.partition;
numPuffer1 = ceil(partition * OPTIONS.popsize);  
numPuffer2 = OPTIONS.popsize - numPuffer1; 
period = 1.2; 
Land1 = zeros(numPuffer1, OPTIONS.numVar);
Land2 = zeros(numPuffer2, OPTIONS.numVar);
BAR = partition;
for GenIndex = 1 : OPTIONS.Maxgen
    
    for j = 1 : Keep
        chromKeep(j,:) = Population(j).chrom;
        costKeep(j) = Population(j).cost;
    end
   
    for popindex = 1 : OPTIONS.popsize
        if popindex <= numPuffer1
            Population1(popindex).chrom = Population(popindex).chrom;
        else
            Population2(popindex-numPuffer1).chrom = Population(popindex).chrom;
        end
    end
    %% Migration operator
    for k1 = 1 : numPuffer1
        for parnum1 = 1 : OPTIONS.numVar
            r1 = rand*period;
            if r1 <= partition
                r2 = round(numPuffer1 * rand + 0.5);
                Land1(k1,parnum1) = Population1(r2).chrom(parnum1);
            else
                r3 = round(numPuffer2 * rand + 0.5);
                Land1(k1,parnum1) = Population2(r3).chrom(parnum1);
            end
        end %% for parnum1
        NewPopulation1(k1).chrom =  Land1(k1,:);
    end  
    SavePopSize = OPTIONS.popsize;
    OPTIONS.popsize = numPuffer1;
    NewPopulation1 = FeasibleFunction(OPTIONS, NewPopulation1);
    NewPopulation1 = CostFunction(OPTIONS, NewPopulation1);
    OPTIONS.popsize = SavePopSize;
  
    % Pufferfish adjustment operator
    for k2 = 1 : numPuffer2
        % Determine expansion or contraction based on some criteria
        if rand <= BAR
            % Expand
            for parnum2 = 1:OPTIONS.numVar
                Land2(k2,parnum2) = Population(1).chrom(parnum2) + rand * maxStepSize;
            end
        else
            % Contract
            for parnum2 = 1:OPTIONS.numVar
                Land2(k2,parnum2) = Population2(k2).chrom(parnum2) - rand * maxStepSize;
            end
        end
        NewPopulation2(k2).chrom = Land2(k2,:);
    end 
    SavePopSize = OPTIONS.popsize;
    OPTIONS.popsize = numPuffer2;
    % Make sure each individual is legal.
    NewPopulation2 = FeasibleFunction(OPTIONS, NewPopulation2);
    % Calculate cost
    NewPopulation2 = CostFunction(OPTIONS, NewPopulation2);
    OPTIONS.popsize = SavePopSize;
    Population = CombinePopulation(OPTIONS, NewPopulation1, NewPopulation2);
    % Sort from best to worst
    Population = PopSort(Population);
    n = length(Population);
    for k3 = 1 : Keep
        Population(n-k3+1).chrom = chromKeep(k3,:);
        Population(n-k3+1).cost = costKeep(k3);
    end 
    Population = PopSort(Population);
    % Compute the average cost
    [AverageCost, nLegal] = ComputeAveCost(Population);
    % Display info to screen
    MinCost = [MinCost Population(1).cost];
    AvgCost = [AvgCost AverageCost];
    if DisplayFlag
        disp(['The best and mean of Generation # ', num2str(GenIndex), ' are ',...
            num2str(MinCost(end)), ' and ', num2str(AvgCost(end))]);
    end
    
end 
Conclude1(DisplayFlag, OPTIONS, Population, nLegal, MinCost, AvgCost);
execution_time1 = toc;
